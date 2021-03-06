-- Andreas "Syranide" Svensson's editor for Wire Expression 2
-- edited by DarKSunrise aka Assassini
-- to work with Luapad and with Lua-syntax

-- modified slightly by CapsAdmin to make it work as a mini lua editor in pac3
-- source https://code.google.com/p/lua-pad/

--modified slightly (yet again) by TGiFallen to make it work for Luabox

local PANEL = {};

PANEL.ClassName = "Luabox_Editor"
PANEL.Base = "Panel"

surface.CreateFont("luaboxEditor" , { font = "Lucida Console" , size = 14 , weight = 400 } )
surface.CreateFont("luaboxEditor_Bold" , { font = "Lucida Console" , size = 16 , weight = 800 })

local lookat = {
	_G,
	FindMetaTable("Entity"),
	FindMetaTable("Vector"),
	FindMetaTable("Angle"),
	FindMetaTable("Player"),
	FindMetaTable("PhysObj"),
	FindMetaTable("Weapon"),
}

local function lookupfunc( tbl , key )
	for _ , tab in ipairs( lookat ) do
		if tab[ key ] then
			return tab[ key ]
		end
	end

end

function PANEL:Init()
	self:SetCursor("beam");

	surface.SetFont("luaboxEditor");
	self.FontWidth, self.FontHeight = surface.GetTextSize(" ");

	self.Rows = {""};
	self.Caret = {1, 1};
	self.Start = {1, 1};
	self.Scroll = {1, 1};
	self.Size = {1, 1};
	self.Undo = {};
	self.Redo = {};
	self.PaintRows = {};

	self.Blink = RealTime();

	self.ScrollBar = vgui.Create("DVScrollBar", self);
	self.ScrollBar:SetUp(1, 1);

	self.TextEntry = vgui.Create("TextEntry", self);
	self.TextEntry:SetMultiline(true);
	self.TextEntry:SetSize(0, 0);

	self.TextEntry.OnLoseFocus = function (self) self.Parent:_OnLoseFocus(); end
	self.TextEntry.OnTextChanged = function (self) self.Parent:_OnTextChanged(); end
	self.TextEntry.OnKeyCodeTyped = function (self, code) self.Parent:_OnKeyCodeTyped(code); end

	self.TextEntry.Parent = self;

	self.LastClick = 0;
	self.QueueIndent = 0
	self.AutoIndents = {}
	self.AutoUnIndents = {}
	self.LastWord = ""

	self.DefinedHighlights = setmetatable( {} , lookup )
end

function PANEL:RequestFocus()
	self.TextEntry:RequestFocus();
end

function PANEL:OnGetFocus()
	self.TextEntry:RequestFocus();
end

function PANEL:SetCaretPos(x, y)
	self.Caret = {x, y or 0}
	self.Start = {x, y or 0}
end

function PANEL:CursorToCaret()
	local x, y = self:CursorPos();

	x = x - (self.FontWidth * 3 + 6);
	if(x < 0) then x = 0; end
	if(y < 0) then y = 0; end

	local line = math.floor(y / self.FontHeight);
	local char = math.floor(x / self.FontWidth + 0.5);

	line = line + self.Scroll[1];
	char = char + self.Scroll[2];

	if(line > #self.Rows) then line = #self.Rows; end
	local length = string.len(self.Rows[line]);
	if(char > length + 1) then char = length + 1; end

	return { line, char };
end

function PANEL:OnMousePressed(code)
	if(code == MOUSE_LEFT) then
		if((CurTime() - self.LastClick) < 1 and self.tmp and self:CursorToCaret()[1] == self.Caret[1] and self:CursorToCaret()[2] == self.Caret[2]) then
			self.Start = self:getWordStart(self.Caret)
			self.Caret = self:getWordEnd(self.Caret)
			self.tmp = false
			return
		end

		self.tmp = true

		self.LastClick = CurTime()
		self:RequestFocus()
		self.Blink = RealTime()
		self.MouseDown = true

		self.Caret = self:CursorToCaret()
		if(!input.IsKeyDown(KEY_LSHIFT) and !input.IsKeyDown(KEY_RSHIFT)) then
			self.Start = self:CursorToCaret()
		end
	elseif(code == MOUSE_RIGHT) then
		local menu = DermaMenu()

		if(self:CanUndo()) then
			menu:AddOption("Undo",  function()
				self:DoUndo()
			end)
		end
		if(self:CanRedo()) then
			menu:AddOption("Redo",  function()
				self:DoRedo()
			end)
		end

		if(self:CanUndo() or self:CanRedo()) then
			menu:AddSpacer()
		end

		if(self:HasSelection()) then
			menu:AddOption("Cut",  function()
				self:Cut()
			end)
			menu:AddOption("Copy",  function()
				self:Copy()
			end)
		end

		menu:AddOption("Paste",  function()
			self:Paste()
		end)

		if(self:HasSelection()) then
			menu:AddOption("Delete",  function()
				self:SetSelection()
			end)
		end

		menu:AddSpacer()

		menu:AddOption("Select all",  function()
			self:SelectAll()
		end)

		menu:Open()
	end
end

function PANEL:OnMouseReleased(code)
	if(!self.MouseDown) then return end

	if(code == MOUSE_LEFT) then
		self.MouseDown = nil
		if(!self.tmp) then return end
		self.Caret = self:CursorToCaret()
	end
end

function PANEL:SetText(text)
	self.Rows = string.Explode("\n", text);
	if(self.Rows[#self.Rows] != "") then
		self.Rows[#self.Rows + 1] = "";
	end

	self.Caret = {1, 1};
	self.Start = {1, 1};
	self.Scroll = {1, 1};
	self.Undo = {};
	self.Redo = {};
	self.PaintRows = {};

	self.ScrollBar:SetUp(self.Size[1], #self.Rows - 1);
end

function PANEL:GetValue()
	return string.Implode("\n", self.Rows)
end

function PANEL:NextChar()
	if(!self.char) then return end

	self.str = self.str .. self.char
	self.pos = self.pos + 1

	if(self.pos <= string.len(self.line)) then
		self.char = string.sub(self.line, self.pos, self.pos)
	else
		self.char = nil
	end
end

function PANEL:IndentOnEnter()
	self.QueueIndent = self.QueueIndent + 1
end

function PANEL:UnIndentOnEnter()
	self.QueueIndent = self.QueueIndent - 1
end

local lasttoken
local lastword = ""
local colors = {
	["none"] =  { Color(197, 200, 198,255), false},
	["number"] =    { Color(255, 115, 253, 255), false},
	["function"] =  { Color(218,208,133, 255), false},
	["functiondef"] =  { Color(255, 210, 167, 255), false},
	["string"] =    { Color(168, 255, 96, 255), false},
	["expression"] =    { Color(150,203,254, 255), false},
	["operator"] =  { Color(237, 237, 237, 255), false},--Color(100, 100, 100, 255), false},
	["comment"] =   { Color(124, 124, 124 , 255), false},
	["variable"] = 	{ Color(198,197,254, 255), false},
}

function PANEL:SyntaxColorLine(row)
	local cols = {}
	local lasttable;
	local nexttoken
	local prevtoken
	local token
	self.line = self.Rows[row]
	self.pos = 0
	self.char = ""
	self.str = ""

	-- TODO: Color customization?
	--[[
	local colors = {
		["none"] =  { Color(198,197,254, 255), false},
		["number"] =    { Color(249,238,152, 255), false},
		["function"] =  { Color(218,208,133, 255), false},
		["enumeration"] =  { Color(184, 134, 11, 255), false},
		["metatable"] =  { Color(140, 100, 90, 255), false},
		["string"] =    { Color(120, 120, 120, 255), false},
		["expression"] =    { Color(150,203,254, 255), false},
		["operator"] =  { Color(200, 200, 200, 255), false},--Color(100, 100, 100, 255), false},
		["comment"] =   { Color(0, 120, 0, 255), false},
	}
	--]]

	colors["string2"] = colors["string"];

	self:NextChar();

	while self.char do

		self.str = "";

		while self.char and self.char == " " do self:NextChar()
			if lasttoken == "function" then
				nexttoken = "functiondef"
			elseif lasttoken == "vardef" then
				nexttoken = "variable"
			end

			if lasttoken == "functiondef" then
				self.DefinedHighlights[ lastword ] = "f"
				lasttoken = ""
			elseif lasttoken == "variable" then
				self.DefinedHighlights[ lastword ] = "v"
				lasttoken = ""
			end
		end

		token = "";

		if(!self.char) then break end

		if(self.char >= "0" and self.char <= "9") then
			while self.char and (self.char >= "0" and self.char <= "9" or self.char == "." or self.char == "_") do self:NextChar() end

			token = "number"
		elseif(self.char >= "a" and self.char <= "z" or self.char >= "A" and self.char <= "Z") then

			while self.char and (self.char >= "a" and self.char <= "z" or self.char >= "A" and self.char <= "Z" or
			self.char >= "0" and self.char <= "9" or self.char == "_" or self.char == "." ) do self:NextChar(); end

			local sstr = string.Trim(self.str)


			if(sstr == "if" or sstr == "elseif" or sstr == "else" or sstr == "then" or sstr == "end" or sstr == "function"
			or sstr == "do" or sstr == "while" or sstr == "break" or sstr == "for" or sstr == "in" or sstr == "local"
			or sstr == "true" or sstr == "false" or sstr == "nil" or sstr == "NULL" or sstr == "and" or sstr == "not"
			or sstr == "or" or sstr == "||" or sstr == "&&" or sstr == "return") then

				token = "expression"

				if sstr == "function" then
					lasttoken = "function"
				elseif sstr == "local" then
					lasttoken = "vardef"
				end

			elseif self:CheckHighlight(sstr) == "f" then

				token = "function"

			elseif self:CheckHighlight( sstr ) == "v" then

				token = "variable"

			else

				lasttable = nil;
				token = "none"

				local explo = string.Explode( "[%s,]+" , self.line , true )
				for _ , str in ipairs(explo) do
					if str == sstr then
						for i = _ , #explo do
							local str2 = explo[i]

							if str2 == "=" then
								token = "variable"
								self.DefinedHighlights[ sstr ] = "v"
							end
						end
					end
				end
			end

			if nexttoken == "functiondef" then
				token = "functiondef"
				nexttoken = ""
				lasttoken = "functiondef"

				lastword = sstr
			elseif nexttoken == "variable" then
				token = "variable"
				nexttoken = ""
				lasttoken = "variable"
				lastword = sstr

				if sstr == "function" then
					token = "expression"
					nexttoken = "functiondef"
				end
			end
			lastword = sstr
		elseif(self.char == "\"") then -- TODO: Fix multiline strings, and add support for [[stuff]]!

			self:NextChar()
			while self.char and self.char != "\"" do
				if(self.char == "\\") then self:NextChar() end
				self:NextChar()
			end
			self:NextChar()

			token = "string"
		elseif(self.char == "'") then

			self:NextChar()
			while self.char and self.char != "'" do
				if(self.char == "\\") then self:NextChar() end
				self:NextChar()
			end
			self:NextChar()

			token = "string2"
		elseif(self.char == "/" or self.char == "-") then -- TODO: Multiline comments!

			local lastchar = self.char;
			self:NextChar()

			if(self.char == lastchar) then
				while self.char do
					self:NextChar()
				end

				token = "comment"
			else
				token = "none";
			end

		else
			self:NextChar()

			token = "operator"
		end


		if self:CheckHighlight( string.Trim(self.str) ) == "f" then
			token = "function"
		elseif self:CheckHighlight( string.Trim(self.str) ) == "v" then
			token = "variable"
		end

		color = colors[token]
		if(#cols > 1 and color == cols[#cols][2]) then
			cols[#cols][1] = cols[#cols][1] .. self.str
		else
			cols[#cols + 1] = {self.str, color}
		end
	end

	return cols;
end

local function indexType( tab , idx )
	return tab[idx]
end

function PANEL:CheckHighlight( str )
	local explo = string.Explode( "." , str )
	if #explo > 1 then
		local err
		local next = self.DefinedHighlights[ explo[1] ]
		for i = 2 , #explo do
			if not next then break end
			suc , next = pcall( indexType , next , explo[i] )

			if not suc then return "v" end
		end
		if type( next )== "function" then
			return "f"
		elseif type( next ) != "nil" then
			return "v"
		end
	end
	if self.DefinedHighlights[ str ] == "f" or type(self.DefinedHighlights[ str]) == "function" then
		return "f"
	elseif (self.DefinedHighlights[ str ] == "v" or type(self.DefinedHighlights[ str]) != "function") and self.DefinedHighlights[ str ] then
		return "v"
	end

	return
end

function PANEL:PaintLine(row)
	if(row > #self.Rows) then return end

	if(!self.PaintRows[row]) then
		self.PaintRows[row] = self:SyntaxColorLine(row)
	end

	local width, height = self.FontWidth, self.FontHeight

	if(self.error_line == row or row == self.Caret[1] and self.TextEntry:HasFocus()) then
		if self.error_line == row then
			surface.SetDrawColor(255, 0, 0, 10)
		else
			surface.SetDrawColor(220, 220, 220, 5)
		end
		surface.DrawRect(width * 3 + 5, (row - self.Scroll[1]) * height, self:GetWide() - (width * 3 + 5), height)
	end

	if(self:HasSelection()) then
		local start, stop = self:MakeSelection(self:Selection())
		local line, char = start[1], start[2]
		local endline, endchar = stop[1], stop[2]

		surface.SetDrawColor(170, 170, 170, 10)
		local length = string.len(self.Rows[row]) - self.Scroll[2] + 1

		char = char - self.Scroll[2]
		endchar = endchar - self.Scroll[2]
		if(char < 0) then char = 0 end
		if(endchar < 0) then endchar = 0 end

		if(row == line and line == endline) then
			surface.DrawRect(char * width + width * 3 + 6, (row - self.Scroll[1]) * height, width * (endchar - char), height)
		elseif(row == line) then
			surface.DrawRect(char * width + width * 3 + 6, (row - self.Scroll[1]) * height, width * (length - char + 1), height)
		elseif(row == endline) then
			surface.DrawRect(width * 3 + 6, (row - self.Scroll[1]) * height, width * endchar, height)
		elseif(row > line and row < endline) then
			surface.DrawRect(width * 3 + 6, (row - self.Scroll[1]) * height, width * (length + 1), height)
		end
	end

	draw.SimpleText(tostring(row), "luaboxEditor", width * 3, (row - self.Scroll[1]) * height, Color(128, 128, 128, 255), TEXT_ALIGN_RIGHT)

	local offset = -self.Scroll[2] + 1
	for i,cell in ipairs(self.PaintRows[row]) do
		if(offset < 0) then
			if(string.len(cell[1]) > -offset) then
				line = string.sub(cell[1], -offset + 1)
				offset = string.len(line)

				if(cell[2][2]) then
					draw.SimpleText(line, "luaboxEditor_Bold", width * 3 + 6, (row - self.Scroll[1]) * height, cell[2][1])
				else
					draw.SimpleText(line, "luaboxEditor", width * 3 + 6, (row - self.Scroll[1]) * height, cell[2][1])
				end
			else
				offset = offset + string.len(cell[1])
			end
		else
			if(cell[2][2]) then
				draw.SimpleText(cell[1], "luaboxEditor_Bold", offset * width + width * 3 + 6, (row - self.Scroll[1]) * height, cell[2][1])
			else
				draw.SimpleText(cell[1], "luaboxEditor", offset * width + width * 3 + 6, (row - self.Scroll[1]) * height, cell[2][1])
			end

			offset = offset + string.len(cell[1])
		end
	end

	if(row == self.Caret[1] and self.TextEntry:HasFocus()) then
		if((RealTime() - self.Blink) % 0.8 < 0.4) then
			if(self.Caret[2] - self.Scroll[2] >= 0) then
				surface.SetDrawColor(255, 255, 255, 160)
				surface.DrawRect((self.Caret[2] - self.Scroll[2]) * width + width * 3 + 6, (self.Caret[1] - self.Scroll[1]) * height, 1, height)
			end
		end
	end
end

function PANEL:PerformLayout()
	self.ScrollBar:SetSize(16, self:GetTall())
	self.ScrollBar:SetPos(self:GetWide() - 16, 0)

	self.Size[1] = math.floor(self:GetTall() / self.FontHeight) - 1
	self.Size[2] = math.floor((self:GetWide() - (self.FontWidth * 3 + 6) - 16) / self.FontWidth) - 1

	self.ScrollBar:SetUp(self.Size[1], #self.Rows - 1)
end

function PANEL:Paint()
	if(!input.IsMouseDown(MOUSE_LEFT)) then
		self:OnMouseReleased(MOUSE_LEFT)
	end

	if(!self.PaintRows) then
		self.PaintRows = {}
	end

	if(self.MouseDown) then
		self.Caret = self:CursorToCaret()
	end

	surface.SetDrawColor(20, 20, 20, 255)
	surface.DrawRect(0, 0, self.FontWidth * 3 + 4, self:GetTall())

	--surface.SetDrawColor(23, 23, 23, 255)
	surface.SetDrawColor( 29, 31, 33 , 255)
	surface.DrawRect(self.FontWidth * 3 + 5, 0, self:GetWide() - (self.FontWidth * 3 + 5), self:GetTall())

	self.Scroll[1] = math.floor(self.ScrollBar:GetScroll() + 1)

	self.DefinedHighlights = setmetatable( {} , {__index = lookupfunc } )

	for i=self.Scroll[1],self.Scroll[1]+self.Size[1]+1 do
		self:PaintLine(i)
	end

	return true
end

function PANEL:SetErrorLine(i)
	self.error_line = i
end

function PANEL:SetCaret(caret)
	self.Caret = self:CopyPosition(caret)
	self.Start = self:CopyPosition(caret)
	self:ScrollCaret()
end

function PANEL:CopyPosition(caret)
	return { caret[1], caret[2] }
end

function PANEL:MovePosition(caret, offset)
	local caret = { caret[1], caret[2] }

	if(offset > 0) then
		while true do
			local length = string.len(self.Rows[caret[1]]) - caret[2] + 2
			if(offset < length) then
				caret[2] = caret[2] + offset
				break
			elseif(caret[1] == #self.Rows) then
				caret[2] = caret[2] + length - 1
				break
			else
				offset = offset - length
				caret[1] = caret[1] + 1
				caret[2] = 1
			end
		end
	elseif(offset < 0) then
		offset = -offset

		while true do
			if(offset < caret[2]) then
				caret[2] = caret[2] - offset
				break
			elseif(caret[1] == 1) then
				caret[2] = 1
				break
			else
				offset = offset - caret[2]
				caret[1] = caret[1] - 1
				caret[2] = string.len(self.Rows[caret[1]]) + 1
			end
		end
	end

	return caret
end

function PANEL:HasSelection()
	return self.Caret[1] != self.Start[1] || self.Caret[2] != self.Start[2]
end

function PANEL:Selection()
	return { { self.Caret[1], self.Caret[2] }, { self.Start[1], self.Start[2] } }
end

function PANEL:MakeSelection(selection)
	local start, stop = selection[1], selection[2]

	if(start[1] < stop[1] or start[1] == stop[1] and start[2] < stop[2]) then
		return start, stop
	else
		return stop, start
	end
end

function PANEL:GetArea(selection)
	local start, stop = self:MakeSelection(selection)

	if(start[1] == stop[1]) then
		return string.sub(self.Rows[start[1]], start[2], stop[2] - 1)
	else
		local text = string.sub(self.Rows[start[1]], start[2])

		for i=start[1]+1,stop[1]-1 do
			text = text .. "\n" .. self.Rows[i]
		end

		return text .. "\n" .. string.sub(self.Rows[stop[1]], 1, stop[2] - 1)
	end
end

function PANEL:SetArea(selection, text, isundo, isredo, before, after)
	local start, stop = self:MakeSelection(selection)

	local buffer = self:GetArea(selection)

	if(start[1] != stop[1] or start[2] != stop[2]) then
		-- clear selection
		self.Rows[start[1]] = string.sub(self.Rows[start[1]], 1, start[2] - 1) .. string.sub(self.Rows[stop[1]], stop[2])
		self.PaintRows[start[1]] = false

		for i=start[1]+1,stop[1] do
			table.remove(self.Rows, start[1] + 1)
			table.remove(self.PaintRows, start[1] + 1)
			self.PaintRows = {} -- TODO: fix for cache errors
		end

		-- add empty row at end of file (TODO!)
		if(self.Rows[#self.Rows] != "") then
			self.Rows[#self.Rows + 1] = ""
			self.PaintRows[#self.Rows + 1] = false
		end
	end

	if(!text or text == "") then
		self.ScrollBar:SetUp(self.Size[1], #self.Rows - 1)

		self.PaintRows = {}

		self:OnTextChanged()

		if(isredo) then
			self.Undo[#self.Undo + 1] = { { self:CopyPosition(start), self:CopyPosition(start) }, buffer, after, before }
			return before
		elseif(isundo) then
			self.Redo[#self.Redo + 1] = { { self:CopyPosition(start), self:CopyPosition(start) }, buffer, after, before }
			return before
		else
			self.Redo = {}
			self.Undo[#self.Undo + 1] = { { self:CopyPosition(start), self:CopyPosition(start) }, buffer, self:CopyPosition(selection[1]), self:CopyPosition(start) }
			return start
		end
	end

	-- insert text
	local rows = string.Explode("\n", text)

	local remainder = string.sub(self.Rows[start[1]], start[2])
	self.Rows[start[1]] = string.sub(self.Rows[start[1]], 1, start[2] - 1) .. rows[1]
	self.PaintRows[start[1]] = false

	for i=2,#rows do
		table.insert(self.Rows, start[1] + i - 1, rows[i])
		table.insert(self.PaintRows, start[1] + i - 1, false)
		self.PaintRows = {} // TODO: fix for cache errors
	end

	local stop = { start[1] + #rows - 1, string.len(self.Rows[start[1] + #rows - 1]) + 1 }

	self.Rows[stop[1]] = self.Rows[stop[1]] .. remainder
	self.PaintRows[stop[1]] = false

	-- add empty row at end of file (TODO!)
	if(self.Rows[#self.Rows] != "") then
		self.Rows[#self.Rows + 1] = ""
		self.PaintRows[#self.Rows + 1] = false
		self.PaintRows = {} // TODO: fix for cache errors
	end

	self.ScrollBar:SetUp(self.Size[1], #self.Rows - 1)

	self.PaintRows = {}

	self:OnTextChanged()

	if(isredo) then
		self.Undo[#self.Undo + 1] = { { self:CopyPosition(start), self:CopyPosition(stop) }, buffer, after, before }
		return before
	elseif(isundo) then
		self.Redo[#self.Redo + 1] = { { self:CopyPosition(start), self:CopyPosition(stop) }, buffer, after, before }
		return before
	else
		self.Redo = {}
		self.Undo[#self.Undo + 1] = { { self:CopyPosition(start), self:CopyPosition(stop) }, buffer, self:CopyPosition(selection[1]), self:CopyPosition(stop) }
		return stop
	end
end

function PANEL:GetSelection()
	return self:GetArea(self:Selection())
end

function PANEL:SetSelection(text)
	self:SetCaret(self:SetArea(self:Selection(), text))
end

function PANEL:_OnLoseFocus()
	if(self.TabFocus) then
		self:RequestFocus()
		self.TabFocus = nil
	end
end

function PANEL:SetIgnoreTilde( ignore )
	self.IgnoreTilde = ignore
end

function PANEL:_OnTextChanged()
	local ctrlv = false
	local text = self.TextEntry:GetValue()
	self.TextEntry:SetText("")

	if self.IgnoreTilde and text == "`" then return end

	if text == " " or text == "\n" then
		self.LastWord = ""
	else
		self.LastWord = self.LastWord .. text
	end

	if self.LastWord == "then" or self.LastWord == "function" or self.LastWord == "{" then
		self:IndentOnEnter()
	elseif self.LastWord == "end" or self.LastWord == "}" then
		self:UnIndentOnEnter()
	end


	if((input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)) and not (input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT))) then
		-- ctrl+[shift+]key
		if(input.IsKeyDown(KEY_V)) then
			-- ctrl+[shift+]V
			ctrlv = true
		else
			-- ctrl+[shift+]key with key ~= V
			return
		end
	end

	if(text == "") then return end
	if(not ctrlv) then
		if(text == "\n") then return end
		if(text == "end") then
			local row = self.Rows[self.Caret[1]]
		end
	end

	self:SetSelection(text)
end

function PANEL:SetScrollPosition(pos)
	if(pos < 1) then pos = 1 end
	if(pos > #self.Rows) then pos = #self.Rows end
	self.ScrollBar:SetScroll(pos - 1)
	self.Scroll[1] = pos
end

function PANEL:GetScrollPosition()
	return self.Scroll[1]
end

function PANEL:OnMouseWheeled(delta)
	self:SetScrollPosition(self:GetScrollPosition() - 4 * delta)
end

function PANEL:ScrollCaret()
	if(self.Caret[1] - self.Scroll[1] < 2) then
		self.Scroll[1] = self.Caret[1] - 2
		if(self.Scroll[1] < 1) then self.Scroll[1] = 1 end
	end

	if(self.Caret[1] - self.Scroll[1] > self.Size[1] - 2) then
		self.Scroll[1] = self.Caret[1] - self.Size[1] + 2
		if(self.Scroll[1] < 1) then self.Scroll[1] = 1 end
	end

	if(self.Caret[2] - self.Scroll[2] < 4) then
		self.Scroll[2] = self.Caret[2] - 4
		if(self.Scroll[2] < 1) then self.Scroll[2] = 1 end
	end

	if(self.Caret[2] - 1 - self.Scroll[2] > self.Size[2] - 4) then
		self.Scroll[2] = self.Caret[2] - 1 - self.Size[2] + 4
		if(self.Scroll[2] < 1) then self.Scroll[2] = 1 end
	end

	self.ScrollBar:SetScroll(self.Scroll[1] - 1)
end

local function unindent(line)
	local i = line:find("%S")
	if(i == nil or i > 5) then i = 5 end
	return line:sub(i)
end

function PANEL:CanUndo()
	return #self.Undo > 0
end

function PANEL:DoUndo()
	if(#self.Undo > 0) then
		local undo = self.Undo[#self.Undo]
		self.Undo[#self.Undo] = nil

		self:SetCaret(self:SetArea(undo[1], undo[2], true, false, undo[3], undo[4]))
	end
end

function PANEL:CanRedo()
	return #self.Redo > 0
end

function PANEL:DoRedo()
	if(#self.Redo > 0) then
		local redo = self.Redo[#self.Redo]
		self.Redo[#self.Redo] = nil

		self:SetCaret(self:SetArea(redo[1], redo[2], false, true, redo[3], redo[4]))
	end
end

function PANEL:SelectAll()
	self.Caret = {#self.Rows, string.len(self.Rows[#self.Rows]) + 1}
	self.Start = {1, 1}
	self:ScrollCaret()
end

function PANEL:_OnKeyCodeTyped(code)
	self.Blink = RealTime()

	local alt = input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)
	local shift = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)
	local control = input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)

	if alt then return end

	--if(alt or control or shift) then
		self:OnShortcut(code)
	--end

	if(control) then
		if(code == KEY_A) then
			self:SelectAll()
		elseif(code == KEY_Z) then
			self:DoUndo()
		elseif(code == KEY_Y) then
			self:DoRedo()
		elseif(code == KEY_X) then
			self:Cut()
		elseif(code == KEY_C) then
			self:Copy()
		elseif(code == KEY_UP) then
			self.Scroll[1] = self.Scroll[1] - 1
			if(self.Scroll[1] < 1) then self.Scroll[1] = 1 end
		elseif(code == KEY_DOWN) then
			self.Scroll[1] = self.Scroll[1] + 1
		elseif(code == KEY_LEFT) then
			if(self:HasSelection() and !shift) then
				self.Start = self:CopyPosition(self.Caret)
			else
				self.Caret = self:getWordStart(self:MovePosition(self.Caret, -2))
			end

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif(code == KEY_RIGHT) then
			if(self:HasSelection() and !shift) then
				self.Start = self:CopyPosition(self.Caret)
			else
				self.Caret = self:getWordEnd(self:MovePosition(self.Caret, 1))
			end

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif(code == KEY_HOME) then
			self.Caret[1] = 1
			self.Caret[2] = 1

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif(code == KEY_END) then
			self.Caret[1] = #self.Rows
			self.Caret[2] = 1

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		end

	else
		if(code == KEY_ENTER) then
			local row = self.Rows[self.Caret[1]]:sub(1,self.Caret[2]-1)
			local diff = (row:find("%S") or (row:len()+1))-1

			if self.QueueIndent > 0 then
				diff = diff + 4

				self.TabFocus = true
				self.QueueIndent = 0
			elseif self.QueueIndent < 0 then
				local newbuff = unindent( self:GetArea( {self.Caret, {self.Caret[1], 1}} ) )

				self:SetArea( {self.Caret, {self.Caret[1], 1}} , newbuf)
				self:SetSelection( newbuff )

				diff = math.Max( diff - 4 , 0 )

				self.TabFocus = true
				self.QueueIndent = 0
			end

			local tabs = string.rep("    ", math.floor(diff / 4))

			self:SetSelection("\n" .. tabs)

		elseif(code == KEY_UP) then
			if(self.Caret[1] > 1) then
				self.Caret[1] = self.Caret[1] - 1

				local length = string.len(self.Rows[self.Caret[1]])
				if(self.Caret[2] > length + 1) then
					self.Caret[2] = length + 1
				end
			end

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif(code == KEY_DOWN) then
			if(self.Caret[1] < #self.Rows) then
				self.Caret[1] = self.Caret[1] + 1

				local length = string.len(self.Rows[self.Caret[1]])
				if(self.Caret[2] > length + 1) then
					self.Caret[2] = length + 1
				end
			end

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif(code == KEY_LEFT) then
			if(self:HasSelection() and !shift) then
				self.Start = self:CopyPosition(self.Caret)
			else
				self.Caret = self:MovePosition(self.Caret, -1)
			end

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif(code == KEY_RIGHT) then
			if(self:HasSelection() and !shift) then
				self.Start = self:CopyPosition(self.Caret)
			else
				self.Caret = self:MovePosition(self.Caret, 1)
			end

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif(code == KEY_PAGEUP) then
			self.Caret[1] = self.Caret[1] - math.ceil(self.Size[1] / 2)
			self.Scroll[1] = self.Scroll[1] - math.ceil(self.Size[1] / 2)
			if(self.Caret[1] < 1) then self.Caret[1] = 1 end

			local length = string.len(self.Rows[self.Caret[1]])
			if(self.Caret[2] > length + 1) then self.Caret[2] = length + 1 end
			if(self.Scroll[1] < 1) then self.Scroll[1] = 1 end

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif(code == KEY_PAGEDOWN) then
			self.Caret[1] = self.Caret[1] + math.ceil(self.Size[1] / 2)
			self.Scroll[1] = self.Scroll[1] + math.ceil(self.Size[1] / 2)
			if(self.Caret[1] > #self.Rows) then self.Caret[1] = #self.Rows end
			if(self.Caret[1] == #self.Rows) then self.Caret[2] = 1 end

			local length = string.len(self.Rows[self.Caret[1]])
			if(self.Caret[2] > length + 1) then self.Caret[2] = length + 1 end

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif(code == KEY_HOME) then
			local row = self.Rows[self.Caret[1]]
			local first_char = row:find("%S") or row:len()+1
			if(self.Caret[2] == first_char) then
				self.Caret[2] = 1
			else
				self.Caret[2] = first_char
			end

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif(code == KEY_END) then
			local length = string.len(self.Rows[self.Caret[1]])
			self.Caret[2] = length + 1

			self:ScrollCaret()

			if(!shift) then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif(code == KEY_BACKSPACE) then
			if(self:HasSelection()) then
				self:SetSelection()
			else
				local buffer = self:GetArea({self.Caret, {self.Caret[1], 1}})

				if(self.Caret[2] % 4 == 1 and string.len(buffer) > 0 and string.rep(" ", string.len(buffer)) == buffer) then
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, -4)}))
				else
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, -1)}))
				end

			end
		elseif(code == KEY_DELETE) then
			if(self:HasSelection()) then
				self:SetSelection()
			else
				local buffer = self:GetArea({{self.Caret[1], self.Caret[2] + 4}, {self.Caret[1], 1}})
				if(self.Caret[2] % 4 == 1 and string.rep(" ", string.len(buffer)) == buffer and string.len(self.Rows[self.Caret[1]]) >= self.Caret[2] + 4 - 1) then
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, 4)}))
				else
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, 1)}))
				end
			end
		end
	end

	if(code == KEY_TAB or (control and (code == KEY_I or code == KEY_O))) then
		if(code == KEY_O) then shift = not shift end
		if(code == KEY_TAB and control) then shift = not shift end
		if(self:HasSelection()) then
			self:Indent(shift)
		else

			if(shift) then
				local newpos = self.Caret[2]-4
				if(newpos < 1) then newpos = 1 end
				self.Start = { self.Caret[1], newpos }
				if(self:GetSelection():find("%S")) then
					self.Start = self:CopyPosition(self.Caret)
				else
					self:SetSelection("")
				end
			else
				local count = (self.Caret[2] + 2) % 4 + 1
				self:SetSelection(string.rep(" ", count))
			end
		end
		self.TabFocus = true
	end
end

function PANEL:getWordStart(caret)
	local line = string.ToTable(self.Rows[caret[1]])
	if(#line < caret[2]) then return caret end
	for i=0,caret[2] do
		if(!line[caret[2]-i]) then return {caret[1],caret[2]-i+1} end
		if(line[caret[2]-i] >= "a" and line[caret[2]-i] <= "z" or line[caret[2]-i] >= "A" and line[caret[2]-i] <= "Z" or line[caret[2]-i] >= "0" and line[caret[2]-i] <= "9") then else return {caret[1],caret[2]-i+1} end
	end
	return {caret[1],1}
end

function PANEL:getWordEnd(caret)
	local line = string.ToTable(self.Rows[caret[1]])
	if(#line < caret[2]) then return caret end
	for i=caret[2],#line do
		if(!line[i]) then return {caret[1],i} end
		if(line[i] >= "a" and line[i] <= "z" or line[i] >= "A" and line[i] <= "Z" or line[i] >= "0" and line[i] <= "9") then else return {caret[1],i} end
	end
	return {caret[1],#line+1}
end

function PANEL:Indent(shift)
	local tab_scroll = self:CopyPosition(self.Scroll)
	local tab_start, tab_caret = self:MakeSelection(self:Selection())
	tab_start[2] = 1

	if(tab_caret[2] ~= 1) then
		tab_caret[1] = tab_caret[1] + 1
		tab_caret[2] = 1
	end

	self.Caret = self:CopyPosition(tab_caret)
	self.Start = self:CopyPosition(tab_start)

	if (self.Caret[2] == 1) then
		self.Caret = self:MovePosition(self.Caret, -1)
	end

	if(shift) then
		local tmp = self:GetSelection():gsub("\n ? ? ? ?", "\n")
		self:SetSelection(unindent(tmp))
	else
		self:SetSelection("    " .. self:GetSelection():gsub("\n", "\n    "))
	end

	self.Caret = self:CopyPosition(tab_caret)
	self.Start = self:CopyPosition(tab_start)
	self.Scroll = self:CopyPosition(tab_scroll)
	self:ScrollCaret()
end

function PANEL:Paste()
	self.TextEntry:PostMessage ("DoPaste", "", "")
end

function PANEL:Copy()
	if(self:HasSelection()) then
		self.clipboard = self:GetSelection()
		self.clipboard = string.Replace(self.clipboard, "\n", "\r\n")
		SetClipboardText(self.clipboard)
	end
end

function PANEL:Cut()
	if(self:HasSelection()) then
		self.clipboard = self:GetSelection()
		self.clipboard = string.Replace(self.clipboard, "\n", "\r\n")
		SetClipboardText(self.clipboard)
		self:SetSelection()
	end
end

function PANEL:OnTextChanged()
end

function PANEL:OnShortcut( code )
	if self:GetParent().OnKeyCodePressed then
	    self:GetParent():OnKeyCodePressed( code )
	end
end

vgui.Register( PANEL.ClassName , PANEL , PANEL.base )
