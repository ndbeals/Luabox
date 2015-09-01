PANEL = {}
PANEL.ClassName = "Luabox_Tab_Close"
PANEL.Base = "DButton"

local crossPoly1 =
{
	{ x = 0, y = 0 },
	{ x = 2, y = 0 },
	{ x = 8, y = 7 },
	{ x = 8, y = 8 },
	{ x = 7, y = 8 },
	{ x = 0, y = 2 }
}

local crossPoly2 =
{
	{ x = 8, y = 0 },
	{ x = 7, y = 0 },
	{ x = 0, y = 7 },
	{ x = 0, y = 8 },
	{ x = 2, y = 8 },
	{ x = 8, y = 2 }
}

function PANEL:DrawCross( col , xo , yo )
	local sw , sh = ScrW() , ScrH()

	render.SetViewPort( 2 + xo , 2 + yo , sw , sh )

	surface.SetTexture ( -1 )
	surface.SetDrawColor ( col )
	surface.DrawPoly ( crossPoly1 )
	surface.DrawPoly ( crossPoly2 )

    render.SetViewPort( 0 , 0 , sw , sh )
end

function PANEL:Init()
	self:SetText( "" )
    self:SetMouseInputEnabled( true )
end

function PANEL:Paint( w , h )
    if self:IsHovered () then
		-- Enabled and hovered
		if self.Pressed then
			draw.RoundedBox (4, 0, 0, w , h , luabox.Colors.Gray)
			draw.RoundedBox (4, 1, 1, w - 2, h - 2, luabox.Colors.DarkGray)
		else
			draw.RoundedBox (4, 0, 0, w , h , luabox.Colors.Gray)
			draw.RoundedBox (4, 1, 1, w - 2, h - 2, luabox.Colors.LightGray)
		end
	end

    if not self:GetDisabled() then
        -- Enabled
        if self.Pressed then
            self:DrawCross( luabox.Colors.Gray , 1 , 1 )
        elseif self:IsHovered () then
            self:DrawCross( luabox.Colors.Gray , 0 , 0 )
        else
            if self:GetParent () and not self:GetParent ():IsSelected () then
                self:DrawCross( luabox.Colors.BorderGray , 0 , 0 )
            else
                self:DrawCross( luabox.Colors.DarkGray , 0 , 0 )
            end
        end
    else
        -- Disabled
        self:DrawCross( luabox.Colors.Gray , 0 , 0 )
    end
end

function PANEL:OnDepressed()
	self.Pressed = true
end

function PANEL:OnReleased()
	self.Pressed = false
end

function PANEL:DoClick()
end

function PANEL:PerformLayout()
	self.BaseClass.PerformLayout( self )
end

function PANEL:OnKeyCodePressed( code )
    if self:GetParent().OnKeyCodePressed then
        self:GetParent():OnKeyCodePressed( code )
    end
end

vgui.Register( PANEL.ClassName , PANEL , PANEL.Base )
