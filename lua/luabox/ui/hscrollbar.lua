local PANEL = {}
PANEL.ClassName = "Luabox_HScroll_Bar"
PANEL.Base = "Panel"

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self.Offset = 0
	self.Scroll = 0
	self.CanvasSize = 1
	self.BarSize = 1

	self.btnLeft = vgui.Create( "DButton", self )
	self.btnLeft:SetText( "" )
	self.btnLeft.DoClick = function ( self ) self:GetParent():AddScroll( -1 ) end
	self.btnLeft.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "ButtonLeft", panel, w, h ) end

	self.btnRight = vgui.Create( "DButton", self )
	self.btnRight:SetText( "" )
	self.btnRight.DoClick = function ( self ) self:GetParent():AddScroll( 1 ) end
	self.btnRight.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "ButtonRight", panel, w, h ) end

	self.btnGrip = vgui.Create( "DScrollBarGrip", self )

	self:SetSize( 15, 15 )

end

--[[---------------------------------------------------------
   Name: SetEnabled
-----------------------------------------------------------]]
function PANEL:SetEnabled( b )

	if ( !b ) then

		self.Offset = 0
		self:SetScroll( 0 )
		self.HasChanged = true

	end

	self:SetMouseInputEnabled( b )
	self:SetVisible( b )

	-- We're probably changing the width of something in our parent
	-- by appearing or hiding, so tell them to re-do their layout.
	if ( self.Enabled != b ) then

		self:GetParent():InvalidateLayout()

		if ( self:GetParent().OnScrollbarAppear ) then
			self:GetParent():OnScrollbarAppear()
		end

	end

	self.Enabled = b

end


--[[---------------------------------------------------------
   Name: Value
-----------------------------------------------------------]]
function PANEL:Value()

	return self.Pos

end

--[[---------------------------------------------------------
   Name: Value
-----------------------------------------------------------]]
function PANEL:BarScale()

	if ( self.BarSize == 0 ) then return 1 end

	return self.BarSize / (self.CanvasSize+self.BarSize)

end

--[[---------------------------------------------------------
   Name: SetPos
-----------------------------------------------------------]]
function PANEL:SetUp( _barsize_, _canvassize_ )

	self.BarSize 	= _barsize_
	self.CanvasSize = math.max( _canvassize_ - _barsize_, 1 )

	self:SetEnabled( _canvassize_ > _barsize_ )

	self:InvalidateLayout()

end

--[[---------------------------------------------------------
   Name: OnMouseWheeled
-----------------------------------------------------------]]
function PANEL:OnMouseWheeled( dlta )

	if ( !self:IsVisible() ) then return false end

	-- We return true if the scrollbar changed.
	-- If it didn't, we feed the mousehweeling to the parent panel

	return self:AddScroll( dlta * -2 )

end

--[[---------------------------------------------------------
   Name: AddScroll (Returns true if changed)
-----------------------------------------------------------]]
function PANEL:AddScroll( dlta )

	local OldScroll = self:GetScroll()

	dlta = dlta * 25
	self:SetScroll( self:GetScroll() + dlta )

	return OldScroll != self:GetScroll()

end

--[[---------------------------------------------------------
   Name: SetScroll
-----------------------------------------------------------]]
function PANEL:SetScroll( scrll )

	if ( !self.Enabled ) then self.Scroll = 0 return end

	self.Scroll = math.Clamp( scrll, 0, self.CanvasSize )

	self:InvalidateLayout()

	-- If our parent has a OnVScroll function use that, if
	-- not then invalidate layout (which can be pretty slow)

	local func = self:GetParent().OnHScroll
	if ( func ) then

		func( self:GetParent(), self:GetOffset() )

	else

		self:GetParent():InvalidateLayout()

	end

end

--[[---------------------------------------------------------
   Name: AnimateTo
-----------------------------------------------------------]]
function PANEL:AnimateTo( scrll, length, delay, ease )

	local anim = self:NewAnimation( length, delay, ease )
	anim.StartPos = self.Scroll
	anim.TargetPos = scrll
	anim.Think = function( anim, pnl, fraction )

		pnl:SetScroll( Lerp( fraction, anim.StartPos, anim.TargetPos ) )

	end

end

--[[---------------------------------------------------------
   Name: GetScroll
-----------------------------------------------------------]]
function PANEL:GetScroll()

	if ( !self.Enabled ) then self.Scroll = 0 end
	return self.Scroll

end

--[[---------------------------------------------------------
   Name: GetOffset
-----------------------------------------------------------]]
function PANEL:GetOffset()

	if ( !self.Enabled ) then return 0 end
	return self.Scroll * -1

end

--[[---------------------------------------------------------
   Name: Think
-----------------------------------------------------------]]
function PANEL:Think()

end

function PANEL:Paint (w, h)
	derma.SkinHook ("Paint", "VScrollBar", self, w, h)
	return true
end


--[[---------------------------------------------------------
   Name: OnMouseReleased
-----------------------------------------------------------]]
function PANEL:OnMousePressed()

	local x, y = self:CursorPos()

	local PageSize = self.BarSize

	if ( x > self.btnGrip.x ) then
		self:SetScroll( self:GetScroll() + PageSize )
	else
		self:SetScroll( self:GetScroll() - PageSize )
	end

end

--[[---------------------------------------------------------
   Name: OnMouseReleased
-----------------------------------------------------------]]
function PANEL:OnMouseReleased()

	self.Dragging = false
	self.DraggingCanvas = nil
	self:MouseCapture( false )

	self.btnGrip.Depressed = false

end

--[[---------------------------------------------------------
   Name: OnCursorMoved
-----------------------------------------------------------]]
function PANEL:OnCursorMoved( x, y )

	if ( !self.Enabled ) then return end
	if ( !self.Dragging ) then return end

	local x = gui.MouseX()
	local y = 0--gui.MouseY()
	local x, y = self:ScreenToLocal( x, y )

	-- Uck.
	x = x - self.btnLeft:GetWide()
	x = x - self.HoldPos

	local TrackSize = self:GetWide() - self:GetTall() * 2 - self.btnGrip:GetWide()

	x = x / TrackSize

	self:SetScroll( x * self.CanvasSize )

end

--[[---------------------------------------------------------
   Name: Grip
-----------------------------------------------------------]]
function PANEL:Grip()

	if ( !self.Enabled ) then return end
	if ( self.BarSize == 0 ) then return end

	self:MouseCapture( true )
	self.Dragging = true

	local x, y = gui.MouseX() , 0--gui.MouseY()
	local x, y = self.btnGrip:ScreenToLocal( x, y )
	self.HoldPos = x

	self.btnGrip.Depressed = true

end

--[[---------------------------------------------------------
	PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()

	local Tall = self:GetTall()
	local Scroll = self:GetScroll() / self.CanvasSize
	local BarSize = math.max( self:BarScale() * (self:GetWide() - (Tall * 2)), 10 )
	local Track = self:GetWide() - (Tall * 2) - BarSize
	Track = Track + 1

	Scroll = Scroll * Track

	self.btnGrip:SetPos( Tall + Scroll , 0 )
	self.btnGrip:SetSize( BarSize , Tall )

	self.btnLeft:SetPos( 0, 0 )
	self.btnLeft:SetSize( Tall, Tall )

	self.btnRight:SetPos( self:GetWide() - Tall , 0 )
	self.btnRight:SetSize( Tall, Tall )

end

vgui.Register( PANEL.ClassName , PANEL, PANEL.Base )
