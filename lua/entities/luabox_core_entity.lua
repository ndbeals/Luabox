
DEFINE_BASECLASS( "base_anim" )

AddCSLuaFile()

print("\n\n\n\n\n\nthis is running\n\n\n\n\n\n")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	-- self:SetModel("models/error.mdl")

end

function ENT:OnRemove()
	if self.Container then
		self.Container:RemoveEnvironment( self.Environment )
	end
end

function ENT:SetLuaboxPlayer( ply )
	self.Container = luabox.PlayerContainer( ply )
end

function ENT:SetContainer( container )
	self.Container = container
end

function ENT:GetContainer()
	return self.Container
end

function ENT:SetEnvironment( env )
	self.Environment = env
end

function ENT:GetEnvironment()
	return self.Environment
end





function ENT:SetScript( script )
	self.Container:AddScript( script )

	self.Container:RunScripts()
end
