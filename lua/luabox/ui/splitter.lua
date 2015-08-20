PANEL = {}
PANEL.ClassName = "Luabox_Splitter"
PANEL.Base = "DPanel"

--AccessorFunc( PANEL, "Orientation", "Orientation" ) -- 0 is horizontal, 1 is vertical

local colors = {
    Gray        = Color (0x80, 0x80, 0x80, 0xFF),
    DarkGray    = Color (0xA9, 0xA9, 0xA9, 0xFF),
    LightGray   = Color (0xD3, 0xD3, 0xD3, 0xFF),
    Gray707070  = Color (0x70, 0x70, 0x70, 0xFF)
}

function PANEL:Init()
    self:SetMouseInputEnabled( true )
    self:SetBackgroundColor( Color( 170, 170, 170, 255 ) )

    self:SetOrientation( 0 )

    self.MinX = 0
    self.MaxX = 0
    self.MinY = 0
    self.MaxY = 0
end

function PANEL:SetOrientation( orient )
    if orient == 0 then --horizontal
        self:SetCursor( "sizens" )
        self:SetTall( 10 )
    elseif orient == 1 then --vertical
        self:SetCursor( "sizewe" )
        self:SetWide( 10 )
    end
    self.Orientation = orient
end

function PANEL:GetOrientation()
    return self.Orientation
end

function PANEL:GetActiveTab()
end

function PANEL:Paint( w , h )
    --derma.SkinHook( "Paint" , "Panel" , self , w , h )
    derma.SkinHook( "Paint" , "PropertySheet" , self , w , h )
    --draw.RoundedBox( 2 , 0 , 0 , w , h , self:GetBackgroundColor() )

    surface.SetDrawColor (GLib.Colors.LightGray)
	if self.Orientation == 1 then
		local x = math.floor (w * 0.5 - 1)
		for y = h * 0.5 - 6, h * 0.5 + 6, 2 do
			surface.DrawRect (x, y, 1, 1)
		end
		x = math.floor (w * 0.5 + 1 )
		for y = h * 0.5 - 6, h * 0.5 + 6, 2 do
			surface.DrawRect (x, y, 1, 1)
		end
	else
		local y = math.floor (h * 0.5 - 1)
		for x = w * 0.5 - 6, w * 0.5 + 6, 2 do
			surface.DrawRect (x, y, 1, 1)
		end
		y = math.floor (h * 0.5 + 1)
		for x = w * 0.5 - 6, w * 0.5 + 6, 2 do
			surface.DrawRect (x, y, 1, 1)
		end
	end
end

function PANEL:OnDepressed()
    self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
end

function PANEL:OnReleased()
    self.Dragging = nil
end

function PANEL:Think()
    if ( self.Depressed ) then
        local mousex = math.Clamp( gui.MouseX(), 0, ScrW()-1 )
	    local mousey = math.Clamp( gui.MouseY(), 0, ScrH()-1 )

        local x = mousex - self.Dragging[1]
        local y = mousey - self.Dragging[2]

        x = math.Clamp( x, self.MinX , self.MaxX )
        y = math.Clamp( y, self.MinY , self.MaxY )

        if self:GetOrientation() == 1  then

            local diff = x - self.x

            if self.Panel1 and diff != 0 then
                self.Panel1:SetWide( self.Panel1:GetWide() + diff )
                self.Panel1:InvalidateParent( true )
                self.Panel1:InvalidateChildren( true )
            end
            if self.Panel2 and diff != 0 then
                self.Panel2:SetWide( self.Panel2:GetWide() - diff )
                self.Panel2.x = self.Panel2.x + diff
                self.Panel2:InvalidateParent( true )
                self.Panel2:InvalidateChildren( true )
            end

            self.x = x
        else
            local diff = y - self.y

            if self.Panel1 and diff != 0 then
                self.Panel1:SetTall( self.Panel1:GetTall() + diff )
                self.Panel1:InvalidateParent( true )
                self.Panel1:InvalidateChildren( true )
            end
            if self.Panel2 and diff != 0 then
                self.Panel2:SetTall( self.Panel2:GetTall() - diff )
                self.Panel2.y = self.Panel2.y + diff
                self.Panel2:InvalidateParent( true )
                self.Panel2:InvalidateChildren( true )
            end

            self.y = y
        end
    end
end

function PANEL:SetPanel1( pnl ) -- always the panel above or left
    self.Panel1 = pnl
    if self.Panel1 then
        self.MinY = self.Panel1.y - 1
        self.MinX = self.Panel1.x
    end
end

function PANEL:SetPanel2( pnl ) -- always the panel below or right
    self.Panel2 = pnl
    if self.Panel2 then
        self.MaxY = self.Panel2.y + self.Panel2:GetTall() - self:GetTall()
        self.MaxX = self.Panel2.x + self.Panel2:GetWide() - self:GetWide()
    end
end

function PANEL:SetupBounds( Min , Max )
    Min = Min or 0
    Max = Max or 10
    if self.Orientation == 1 then
        self.MinX = Min
        self.MaxX = Max
    elseif self.Orientation == 0 then
        self.MinY = Min
        self.MaxY = Max
    end
end

function PANEL:PerformLayout()
	self.BaseClass.PerformLayout( self )
end

function PANEL:OnMousePressed( mousecode )
	if ( self:GetDisabled() ) then return end

	self:MouseCapture( true )
	self.Depressed = true
	self:OnDepressed()
	self:InvalidateLayout( true )
end

function PANEL:OnMouseReleased( mousecode )

	self:MouseCapture( false )

	if ( self:GetDisabled() ) then return end
	if ( !self.Depressed ) then return end

	self.Depressed = nil
	self:OnReleased()
	self:InvalidateLayout( true )
	--
	-- If we were being dragged then don't do the default behaviour!
	--
    --[[
	if ( self:DragMouseRelease( mousecode ) ) then
		return
	end

	if ( self:IsSelectable() && mousecode == MOUSE_LEFT ) then

		local canvas = self:GetSelectionCanvas()
		if ( canvas ) then
			canvas:UnselectAll()
		end

	end

	if ( !self.Hovered ) then return end

	--
	-- For the purposes of these callbacks we want to
	-- keep depressed true. This helps us out in controls
	-- like the checkbox in the properties dialog. Because
	-- the properties dialog will only manualloy change the value
	-- if IsEditing() is true - and the only way to work out if
	-- a label/button based control is editing is when it's depressed.
	--
	self.Depressed = true

	if ( mousecode == MOUSE_RIGHT ) then
		self:DoRightClick()
	end

	if ( mousecode == MOUSE_LEFT ) then
		self:DoClickInternal()
		self:DoClick()
	end

	if ( mousecode == MOUSE_MIDDLE ) then
		self:DoMiddleClick()
	end

	self.Depressed = nil
    --]]

end

function PANEL:OnKeyCodePressed( code )
    if self:GetParent().OnKeyCodePressed then
        self:GetParent():OnKeyCodePressed( code )
    end
end

vgui.Register( PANEL.ClassName , PANEL , PANEL.Base )
--[[
function PANEL:OnMousePressed( mousecode )
    print("test",mousecode)

	if ( self:GetDisabled() ) then return end

	if ( mousecode == MOUSE_LEFT && !dragndrop.IsDragging() && self.m_bDoubleClicking ) then

		if ( self.LastClickTime && SysTime() - self.LastClickTime < 0.2 ) then

			self:DoDoubleClickInternal()
			self:DoDoubleClick()
			return

		end

		self.LastClickTime = SysTime()
	end

	-- If we're selectable and have shift held down then go up
	-- the parent until we find a selection canvas and start box selection
	if ( self:IsSelectable() && mousecode == MOUSE_LEFT ) then

		if ( input.IsShiftDown() ) then
			return self:StartBoxSelection()
		end

	end

	self:MouseCapture( true )
	self.Depressed = true
	self:OnDepressed()
	self:InvalidateLayout( true )

	--
	-- Tell DragNDrop that we're down, and might start getting dragged!
	--
	self:DragMousePress( mousecode )

end

function PANEL:OnDepressed()

end

function PANEL:OnMouseReleased( mousecode )
	self:MouseCapture( false )

	if ( self:GetDisabled() ) then return end
	if ( !self.Depressed ) then return end

	self.Depressed = nil
	self:OnReleased()
	self:InvalidateLayout( true )
	--
	-- If we were being dragged then don't do the default behaviour!
	--
	if ( self:DragMouseRelease( mousecode ) ) then
		return
	end

	if ( self:IsSelectable() && mousecode == MOUSE_LEFT ) then

		local canvas = self:GetSelectionCanvas()
		if ( canvas ) then
			canvas:UnselectAll()
		end

	end

	if ( !self.Hovered ) then return end

	--
	-- For the purposes of these callbacks we want to
	-- keep depressed true. This helps us out in controls
	-- like the checkbox in the properties dialog. Because
	-- the properties dialog will only manualloy change the value
	-- if IsEditing() is true - and the only way to work out if
	-- a label/button based control is editing is when it's depressed.
	--
	self.Depressed = true

	if ( mousecode == MOUSE_RIGHT ) then
		self:DoRightClick()
	end

	if ( mousecode == MOUSE_LEFT ) then
		self:DoClickInternal()
		self:DoClick()
	end

	if ( mousecode == MOUSE_MIDDLE ) then
		self:DoMiddleClick()
	end

	self.Depressed = nil

end
--]]
