PANEL = {}
PANEL.ClassName = "Luabox_Console_Output"
PANEL.Base = "Luabox_Editor"

function PANEL:Init()
	self:SetText( "" )
    self:SetMouseInputEnabled( true )
    self:SetMultiline( true )

	self.Rows = {}
	self.RowColors = {}

	self:AddRow( "" )

    --self:SetCursorColor( Color( 0 , 0 , 0 , 0 ) )
end

function PANEL:CursorToCaret()
	local x, y = self:CursorPos();

	--x = x - (self.FontWidth * 3 + 6);
	x = x - self.FontWidth
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

function PANEL:SyntaxColorLine(row)
	return self.RowColors[ row ]
end

function PANEL:AddRow( ... )
	local args = {...}
	local rowcols = {}
	local text = ""

	for i , v in ipairs( args ) do
		if type(v) == "string" then
			text = text .. v
			if type( args[ i + 1 ] ) == "string" then
				table.insert( rowcols , { v , {Color(197, 200, 198,255),false}} )
			end

		elseif type(v) == "table" and v.r >= 0 then
			table.insert( rowcols , { args[ i - 1 ] , {v,false}})

		end
	end

	if #args == 1 then
		table.insert( rowcols , {args[1] , {Color(197, 200, 198,255) , false }})
	end

	local row = table.insert( self.Rows , text )

	self.RowColors[ row ] = rowcols
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
		surface.DrawRect(0, (row - self.Scroll[1]) * height, self:GetWide() , height)
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
			--surface.DrawRect(char * width + width * 3 + 6, (row - self.Scroll[1]) * height, width * (endchar - char), height)
            surface.DrawRect(char * width , (row - self.Scroll[1]) * height, width * (endchar - char), height)
		elseif(row == line) then
			--surface.DrawRect(char * width + width * 3 + 6, (row - self.Scroll[1]) * height, width * (length - char + 1), height)
            surface.DrawRect(char * width , (row - self.Scroll[1]) * height, width * (length - char + 1), height)
		elseif(row == endline) then
			--surface.DrawRect(width * 3 + 6, (row - self.Scroll[1]) * height, width * endchar, height)
            surface.DrawRect( 0 , (row - self.Scroll[1]) * height, width * endchar, height)
		elseif(row > line and row < endline) then
			--surface.DrawRect(width * 3 + 6, (row - self.Scroll[1]) * height, width * (length + 1), height)
            surface.DrawRect( 0 , (row - self.Scroll[1]) * height, width * (length + 1), height)
		end
	end

	--draw.SimpleText(tostring(row), "luaboxEditor", width * 3, (row - self.Scroll[1]) * height, Color(128, 128, 128, 255), TEXT_ALIGN_RIGHT)

	local offset = -self.Scroll[2] + 1
	for i,cell in ipairs(self.PaintRows[row]) do
        --print( "denug" , i )
        --PrintTable(cell)
		if(offset < 0) then
			if(string.len(cell[1]) > -offset) then
				line = string.sub(cell[1], -offset + 1)
				offset = string.len(line)

				if(cell[2][2]) then
					--draw.SimpleText(line, "luaboxEditor_Bold", width * 3 + 6, (row - self.Scroll[1]) * height, cell[2][1])
                    draw.SimpleText(line, "luaboxEditor_Bold", 0 , (row - self.Scroll[1]) * height, cell[2][1])
				else
					--draw.SimpleText(line, "luaboxEditor", width * 3 + 6, (row - self.Scroll[1]) * height, cell[2][1])
                    draw.SimpleText(line, "luaboxEditor", 0 , (row - self.Scroll[1]) * height, cell[2][1])
				end
			else
				offset = offset + string.len(cell[1])
			end
		else
			if(cell[2][2]) then
				--draw.SimpleText(cell[1], "luaboxEditor_Bold", offset * width + width * 3 + 6, (row - self.Scroll[1]) * height, cell[2][1])
                draw.SimpleText(cell[1], "luaboxEditor_Bold", offset * width , (row - self.Scroll[1]) * height, cell[2][1])
			else
				--draw.SimpleText(cell[1], "luaboxEditor", offset * width + width * 3 + 6, (row - self.Scroll[1]) * height, cell[2][1])
                draw.SimpleText(cell[1], "luaboxEditor", offset * width , (row - self.Scroll[1]) * height, cell[2][1])
			end

			offset = offset + string.len(cell[1])
		end
	end

	if(row == self.Caret[1] and self.TextEntry:HasFocus()) then
		if((RealTime() - self.Blink) % 0.8 < 0.4) then
			if(self.Caret[2] - self.Scroll[2] >= 0) then
				surface.SetDrawColor(255, 255, 255, 160)
				--surface.DrawRect((self.Caret[2] - self.Scroll[2]) * width + width * 3 + 6, (self.Caret[1] - self.Scroll[1]) * height, 1, height)
                surface.DrawRect((self.Caret[2] - self.Scroll[2]) * width , (self.Caret[1] - self.Scroll[1]) * height, 1, height)
			end
		end
	end
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
	--surface.DrawRect(0, 0, self.FontWidth * 3 + 4, self:GetTall())

	surface.SetDrawColor(23, 23, 23, 255)
	--surface.DrawRect(self.FontWidth * 3 + 5, 0, self:GetWide() - (self.FontWidth * 3 + 5), self:GetTall())
    surface.DrawRect( 0 , 0, self:GetWide() , self:GetTall())

	self.Scroll[1] = math.floor(self.ScrollBar:GetScroll() + 1)

	for i=self.Scroll[1],self.Scroll[1]+self.Size[1]+1 do
		self:PaintLine(i)
	end

	return true
end
---[[
function PANEL:_OnTextChanged()
	local ctrlv = false
	local text = self.TextEntry:GetValue()
	self.TextEntry:SetText("")
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
		elseif(code == KEY_X) then
			if(self:HasSelection()) then
				self.clipboard = self:GetSelection()
				self.clipboard = string.Replace(self.clipboard, "\n", "\r\n")
				SetClipboardText(self.clipboard)
				self:SetSelection()
			end
		elseif(code == KEY_C) then
			if(self:HasSelection()) then
				self.clipboard = self:GetSelection()
				self.clipboard = string.Replace(self.clipboard, "\n", "\r\n")
				SetClipboardText(self.clipboard)
			end
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
		if(code == KEY_UP) then
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
		end
	end
end

function PANEL:OnDepressed()
	self.Pressed = true
    print("pressed")
end

function PANEL:OnReleased()
	self.Pressed = false
    print("released")
end

function PANEL:DoClick()
	print "clocked"
end

function PANEL:PerformLayout()
	self.BaseClass.PerformLayout( self )
end

function PANEL:OnShortcut( code )
	if self:GetParent().OnKeyCodePressed then
	    self:GetParent():OnKeyCodePressed( code )
	end
end

vgui.Register( PANEL.ClassName , PANEL , PANEL.Base )
