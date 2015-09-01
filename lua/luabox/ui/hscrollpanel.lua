local PANEL = {}
PANEL.ClassName = "Luabox_Scroll_Panel"
PANEL.Base = "DPanel"

AccessorFunc( PANEL, "Padding", 	"Padding" )
AccessorFunc( PANEL, "pnlCanvas", 	"Canvas" )

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self.pnlCanvas 	= vgui.Create( "Panel", self )
	self.pnlCanvas.OnMousePressed = function( self, code ) self:GetParent():OnMousePressed( code ) end
	self.pnlCanvas:SetMouseInputEnabled( true )
    --[[ As far as I can tell, this is un-needed
	self.pnlCanvas.PerformLayout = function( pnl )
        self:InvalidateLayout()
	end
    --]]

	-- Create the scroll bar
    self.HBar = vgui.Create( "Luabox_HScroll_Bar" , self )
    self.HBar:Dock( BOTTOM )

	self.VBar = vgui.Create( "DVScrollBar", self )
	self.VBar:Dock( RIGHT )

	self:SetPadding( 0 )
	self:SetMouseInputEnabled( true )

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackground( false )

end

--[[---------------------------------------------------------
   Name: AddItem
-----------------------------------------------------------]]
function PANEL:AddItem( pnl )

	pnl:SetParent( self:GetCanvas() )

end

function PANEL:OnChildAdded( child )

	self:AddItem( child )

end

--[[---------------------------------------------------------
   Name: SizeToContents
-----------------------------------------------------------]]
function PANEL:SizeToContents()

	self:SetSize( self.pnlCanvas:GetSize() )

end

--[[---------------------------------------------------------
   Name: GetVBar
-----------------------------------------------------------]]
function PANEL:GetVBar()

	return self.VBar

end

--[[---------------------------------------------------------
   Name: GetHBar
-----------------------------------------------------------]]
function PANEL:GetHBar()

	return self.HBar

end

--[[---------------------------------------------------------
   Name: GetCanvas
-----------------------------------------------------------]]
function PANEL:GetCanvas()

	return self.pnlCanvas

end

function PANEL:InnerWidth()

	return self:GetCanvas():GetWide()

end

local function recursechildren( tab , width , height )
	width = width or 0
    height = height or 0
    local mw = 0

	if #tab > 0 then
		width = width + tab[1]:GetIndentSize() + 3

		for k , pnl in pairs( tab ) do
			if pnl.ChildNodes then
				local w , h

				height = height + 17

				if #pnl.ChildNodes:GetChildren() > 0 and pnl.m_bExpanded then
					w , height = recursechildren( pnl.ChildNodes:GetChildren() , 0 , height  )
	            else
	                w , h = pnl.Label:GetContentSize()
	            end

				if w > mw then
					mw = w
				end
			end
		end
        width = width + mw
	end

	return width , height
end

function PANEL:SizeCanvasToContents()

	if self.RootNode then
	    if self.RootNode.ChildNodes then
	        self:GetCanvas():SetSize( recursechildren( self.RootNode.ChildNodes:GetChildren() , 16 , 50 ) )
	    end
	else
		self:GetCanvas():SizeToChildren( true , true )
	end

    if self:GetWide() > self:GetCanvas():GetWide() then
        self:GetCanvas():SetWide( self:GetWide() )
    end

    if self:GetTall() > self:GetCanvas():GetTall() then
        self:GetCanvas():SetTall( self:GetTall() )
    end
end

--[[---------------------------------------------------------
   Name: Rebuild
-----------------------------------------------------------]]
function PANEL:Rebuild()
    self:SizeCanvasToContents()
    self.HBar:SetScroll( self.HBar:GetScroll() )
    self.VBar:SetScroll( self.VBar:GetScroll() )
end

--[[---------------------------------------------------------
   Name: OnMouseWheeled
-----------------------------------------------------------]]
function PANEL:OnMouseWheeled( dlta )

	return self.VBar:OnMouseWheeled( dlta )

end

--[[---------------------------------------------------------
   Name: OnVScroll
-----------------------------------------------------------]]
function PANEL:OnVScroll( iOffset )
    local x , y = self:GetCanvas():GetPos()

	self.pnlCanvas:SetPos( x, iOffset )
end

function PANEL:OnHScroll( iOffset )
    local x , y = self:GetCanvas():GetPos()

	self.pnlCanvas:SetPos( iOffset , y )
end

--[[---------------------------------------------------------
   Name: ScrollToChild
-----------------------------------------------------------]]
function PANEL:ScrollToChild( panel )

	self:PerformLayout()

	local x, y = self.pnlCanvas:GetChildPosition( panel )
	local w, h = panel:GetSize()

	y = y + h * 0.5;
	y = y - self:GetTall() * 0.5;

	self.VBar:AnimateTo( y, 0.5, 0, 0.5 );
    self.HBar:AnimateTo( x, 0.5, 0, 0.5 )

end


--[[---------------------------------------------------------
   Name: PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout( Wide , Tall )
	self:Rebuild()


	self.pnlCanvas:SetPos( self.HBar:GetOffset() , self.VBar:GetOffset() )

	if self.VBar.Enabled and not self.RootNode then
		self.pnlCanvas:SetWide( Wide - self.VBar:GetWide() )
	end
	if self.HBar.Enabled and not self.RootNode then
		self.pnlCanvas:SetTall( Tall - self.HBar:GetTall() )
	end

    self.VBar:SetUp( Tall, self.pnlCanvas:GetTall() )
    self.HBar:SetUp( Wide, self.pnlCanvas:GetWide() )

    --self:Rebuild()
end

function PANEL:Clear()

	return self.pnlCanvas:Clear()

end

function PANEL:OnKeyCodePressed( code )
    if self:GetParent().OnKeyCodePressed then
        self:GetParent():OnKeyCodePressed( code )
    end
end

vgui.Register( PANEL.ClassName , PANEL, PANEL.Base )
