PANEL = {}
PANEL.ClassName = "Luabox_Console_Output"
PANEL.Base = "Luabox_Editor"

function PANEL:Init()
	self:SetText( "" )
    self:SetMouseInputEnabled( true )
    self:SetMultiline( true )



    --self:SetCursorColor( Color( 0 , 0 , 0 , 0 ) )
end

function PANEL:aPaint( w , h )
    --draw.RoundedBox( 8 , 0 , 0 , w , h , Color( 255,0,0) )
    surface.DrawRect( 0 , 0 , w , h )

    self:DrawTextEntryText( self.m_colText, self.m_colHighlight, self.m_colCursor )
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

function PANEL:_OnTextChanged()
	local ctrlv = false
	local text = self.TextEntry:GetValue()
	self.TextEntry:SetText("")

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

	--self:SetSelection(text)
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

vgui.Register( PANEL.ClassName , PANEL , PANEL.Base )
