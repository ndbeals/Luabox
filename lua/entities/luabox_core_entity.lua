
DEFINE_BASECLASS( "base_anim" )

AddCSLuaFile()

print("\n\n\n\n\n\nthis is running\n\n\n\n\n\n")

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

end

function ENT:OnRemove()
    self.Container:RemoveEnvironment( self.Environment )
end

function ENT:SetLuaboxPlayer( ply )
    self.Container = luabox.PlayerContainer( ply )
end

function ENT:SetScript( script )
    self.Container:AddScript( script )

    self.Container:RunScripts()
end
