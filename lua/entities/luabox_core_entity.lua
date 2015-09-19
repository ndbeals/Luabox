
DEFINE_BASECLASS( "base_anim" )

AddCSLuaFile()

print("\n\n\n\n\n\nthis is running\n\n\n\n\n\n")

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

end
