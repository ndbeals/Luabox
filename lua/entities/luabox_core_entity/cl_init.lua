include( "shared.lua" )

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetLuaboxPlayer( LocalPlayer() )

	luabox.luapack.Receive( "luabox_core_entity" .. self:EntIndex() , function( pack )
		self:RunLuaPack( pack )
	end)
end
