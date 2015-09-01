PANEL = {}
PANEL.ClassName = "Luabox_Splitter"
PANEL.Base = "DPanel"

local colors = {
    Gray        = Color (0x80, 0x80, 0x80, 0xFF),
    DarkGray    = Color (0xA9, 0xA9, 0xA9, 0xFF),
    LightGray   = Color (0xD3, 0xD3, 0xD3, 0xFF),
    Gray707070  = Color (0x70, 0x70, 0x70, 0xFF),
	Outline     = Color ( 59 , 59 , 59 ),
	FillerGray  = Color ( 153 , 157 , 162 ),
}

--AccessorFunc( PANEL, "Orientation", "Orientation" ) -- 0 is horizontal, 1 is vertical

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

function PANEL:Paint( w , h )
    draw.RoundedBox( 2 , 0 , 0 , w , h , colors.Outline )
    draw.RoundedBox( 2 , 1 , 1 , w - 2 , h - 2 , colors.FillerGray )


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

function PANEL:PerformLayout()
    self.BaseClass.PerformLayout( self )

    if ( self.Depressed ) then
        local mousex = math.Clamp( gui.MouseX(), 0, ScrW()-1 )
	    local mousey = math.Clamp( gui.MouseY(), 0, ScrH()-1 )

        if self:GetOrientation() == 1  then
            local x = mousex - self.Dragging[1]
            x = math.Clamp( x, self.MinX , self.MaxX )

            local diff = x - self.x

            if self.Panel1 and diff != 0 then
                self.Panel1:SetWide( self.Panel1:GetWide() + diff )
            end
            if self.Panel2 and diff != 0 then
                self.Panel2:SetWide( self.Panel2:GetWide() - diff )
                self.Panel2.x = self.Panel2.x + diff
            end

            self.x = x
        else
            local y = mousey - self.Dragging[2]
            y = math.Clamp( y, self.MinY , self.MaxY )

            local diff = y - self.y

            if self.Panel1 and diff != 0 then
                self.Panel1:SetTall( self.Panel1:GetTall() + diff )
            end
            if self.Panel2 and diff != 0 then
                self.Panel2:SetTall( self.Panel2:GetTall() - diff )
                self.Panel2.y = self.Panel2.y + diff
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

function PANEL:OnCursorMoved()
    if self.Depressed then
        --self:PerformLayout()
        self:InvalidateLayout( true )
    end
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
end

function PANEL:OnKeyCodePressed( code )
    if self:GetParent().OnKeyCodePressed then
        self:GetParent():OnKeyCodePressed( code )
    end
end

vgui.Register( PANEL.ClassName , PANEL , PANEL.Base )
