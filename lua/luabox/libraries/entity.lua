--Copyright 2014 Nathan Beals
local container , ply , env = ...
local netc = container:GetNetworker()

local EntLookup = luabox.WeakTable()--{} --two way look up table, use the actual entity as the key to get the entity proxy class, or use the entity proxy class as the key and get the actual entity
EntityProxy = luabox.Class()
local G_Entity = Entity

local check = luabox.CanUse
--local IsValid = IsValid


EntityProxy.EntIndex = 0
EntityProxy.Class = "NULL"
function EntityProxy:Initialize( ent )
    EntLookup[ ent ] = self
    EntLookup[ self ] = ent

    if not IsValid(ent) then return end

    self.EntIndex = ent:EntIndex()
    self.Class = ent:GetClass()
end

function EntityProxy:__tostring()
    return string.format( "Entity [%s][%s]" , tostring( self.EntIndex ) , self.Class )
end

function EntityProxy:Remove()
    return EntLookup[ self ]:Remove()
end

function EntityProxy:Test()
    print("hi there")
end

if SERVER then
function EntityProxy:CreatedByMap()
    return EntLookup[ self ]:CreatedByMap()
end
else


end

function EntityProxy:AlignAngles( ... )
    return EntLookup[ self ]:AlignAngles( ... )
end

function EntityProxy:BoundingRadius()
    return EntLookup[ self ]:BoundingRadius()
end

function EntityProxy:BoneLength( ... )
    return EntLookup[ self ]:BoneLength( ... )
end

function EntityProxy:BoneHasFlag( ... )
    return EntLookup[ self ]:BoneHasFlag( ... )
end

function EntityProxy:Entindex()
    return EntLookup[ self ]:EndIndex()
end

function EntityProxy:EyeAngles()
    return AngleProxy( EntLookup[ self ]:EyeAngles() )
end

function EntityProxy:EyePos()
    return EntLookup[ self ]:EyePos()
end

function EntityProxy:FindBodygroupByName( ... )
    return EntLookup[ self ]:FindBodygroupByName( ... )
end

function EntityProxy:FindTransitionSequence( ... )
    return EntLookup[ self ]:FindTransitionSequence( ... )
end

function EntityProxy:FollowBone( ... )
    return EntLookup[ self ]:FollowBone( ... )
end

function EntityProxy:GetAbsVelocity()
    return VectorProxy( EntLookup[ self ]:GetAbsVelocity() )
end

function EntityProxy:GetAngles()
    return AngleProxy( EntLookup[ self ]:GetAngles() )
end

function EntityProxy:GetAttachment( ... )
    return EntLookup[ self ]:GetAttachment( ... )
end

function EntityProxy:GetAttachments()
    return EntLookup[ self ]:GetAttachments()
end

function EntityProxy:GetClass()
    return EntLookup[ self ]:GetClass()
end

function EntityProxy:GetCollisionBounds()
	local min, max = EntLookup[ self ]:GetCollisionBounds()()
	return VectorProxy( min ), VectorProxy( max )
end

function EntityProxy:GetCollisionGroup()
    return EntLookup[ self ]:GetCollisionGroup()
end

function EntityProxy:GetColor()
    return EntLookup[ self ]:GetColor()
end

function EntityProxy:GetForward()
	return VectorProxy( EntLookup[ self ]:GetForward() )
end

function EntityProxy:GetGravity()
	return EntLookup[ self ]:GetGravity()
end

function EntityProxy:GetGroundEntity()
	return EntLookup[ self ]:GetGroundEntity()
end

function EntityProxy:GetHitBoxBone( ... )
	return EntLookup[ self ]:GetHitBoxBone( ... )
end

function EntityProxy:GetHitBoxBounds( ... )
	local min, max = EntLookup[ self ]:GetHitBoxBounds()()
	return VectorProxy( min ), VectorProxy( max )
end

function EntityProxy:GetHitBoxCount( ... )
	return EntLookup[ self ]:GetHitBoxCount( ... )
end

function EntityProxy:GetHitBoxGroupCount()
	return EntLookup[ self ]:GetHitBoxGroupCount()
end

function EntityProxy:GetHitboxSet()
	return EntLookup[ self ]:GetHitboxSet()
end

function EntityProxy:GetHitboxSetCount()
	return EntLookup[ self ]:GetHitboxSetCount()
end

function EntityProxy:GetLocalAngles()
	return AngleProxy( EntLookup[ self ]:GetLocalAngles() )
end

function EntityProxy:GetLocalAngularVelocity()
	return AngleProxy( EntLookup[ self ]:GetLocalAngularVelocity() )
end

function EntityProxy:GetLocalPos()
	return VectorProxy( EntLookup[ self ]:GetLocalPos() )
end

function EntityProxy:GetManipulateBoneAngles( ... )
	return AngleProxy( EntLookup[ self ]:GetManipulateBoneAngles( ... ) )
end

function EntityProxy:GetManipulateBoneJiggle( ... )
	return EntLookup[ self ]:GetManipulateBoneJiggle( ... )
end

function EntityProxy:GetManipulateBonePosition( ... )
	return VectorProxy( EntLookup[ self ]:GetManipulateBonePosition( ... ) )
end

function EntityProxy:GetManipulateBoneScale( ... )
	return VectorProxy( EntLookup[ self ]:GetManipulateBoneScale( ... ) )
end

function EntityProxy:GetMaterial()
	return EntLookup[ self ]:GetMaterial()
end

function EntityProxy:GetMaterials()
	return EntLookup[ self ]:GetMaterials()
end

function EntityProxy:GetMaxHealth()
	return EntLookup[ self ]:GetMaxHealth()
end

function EntityProxy:GetModel()
	return EntLookup[ self ]:GetModel()
end

function EntityProxy:GetModelBounds()
	local min, max = EntLookup[ self ]:GetModelBounds()()
	return VectorProxy( min ), VectorProxy( max )
end

function EntityProxy:GetModelRadius()
	return EntLookup[ self ]:GetModelRadius()
end

function EntityProxy:GetModelRenderBounds()
	local min, max = EntLookup[ self ]:GetModelRenderBounds()
	return VectorProxy( min ), VectorProxy( max )
end

function EntityProxy:GetModelScale()
	return EntLookup[ self ]:GetModelScale()
end

function EntityProxy:GetMoveCollide()
	return EntLookup[ self ]:GetMoveCollide()
end

function EntityProxy:GetMoveParent()
	return EntLookup[ self ]:GetMoveParent()
end

function EntityProxy:GetMoveType()
	return EntLookup[ self ]:GetMoveType()
end

function EntityProxy:GetNoDraw()
	return EntLookup[ self ]:GetNoDraw()
end

function EntityProxy:GetNumBodyGroups()
	return EntLookup[ self ]:GetNumBodyGroups()
end

function EntityProxy:GetNumPoseParameters()
	return EntLookup[ self ]:GetNumPoseParameters()
end

function EntityProxy:GetOwner()
	return EntLookup[ self ]:GetOwner()
end

function EntityProxy:GetParent()
	return EntLookup[ self ]:GetParent()
end

function EntityProxy:GetParentAttachment()
	return EntLookup[ self ]:GetParentAttachment()
end

function EntityProxy:GetPhysicsObject() -- ????
	return EntLookup[ self ]:GetPhysicsObject()
end

function EntityProxy:GetPhysicsObjectCount()
	return EntLookup[ self ]:GetPhysicsObjectCount()
end

function EntityProxy:GetPhysicsObjectNum( ... )
	return EntLookup[ self ]:GetPhysicsObjectNum( ... )
end

function EntityProxy:GetPlaybackRate()
	return EntLookup[ self ]:GetPlaybackRate()
end

function EntityProxy:GetPos()
	return EntLookup[ self ]:GetPos()
end

function EntityProxy:GetPoseParameter( ... )
	return EntLookup[ self ]:GetPoseParameter( ... )
end

function EntityProxy:GetPoseParameterName( ... )
	return EntLookup[ self ]:GetPoseParameterName( ... )
end

function EntityProxy:GetPoseParameterRange( ... )
	return EntLookup[ self ]:GetPoseParameterRange( ... )
end

function EntityProxy:GetRagdollOwner()
	return EntLookup[ self ]:GetRagdollOwner()
end

function EntityProxy:GetRenderFX()
	return EntLookup[ self ]:GetRenderFX()
end

function EntityProxy:GetRenderMode()
	return EntLookup[ self ]:GetRenderMode()
end

function EntityProxy:GetRight()
	return VectorProxy( EntLookup[ self ]:GetRight() )
end

function EntityProxy:GetRotatedAABB( ... )
	local min, max = EntLookup[ self ]:GetRotatedAABB()
	return VectorProxy( min ), VectorProxy( max )
end

function EntityProxy:GetSequence()
	return EntLookup[ self ]:GetSequence()
end

function EntityProxy:GetSequenceActivity( ... )
	return EntLookup[ self ]:GetSequenceActivity( ... )
end

function EntityProxy:GetSequenceActivityName( ... )
	return EntLookup[ self ]:GetSequenceActivityName( ... )
end

function EntityProxy:GetSequenceCount()
	return EntLookup[ self ]:GetSequenceCount()
end

function EntityProxy:GetSequenceGroundSpeed( ... )
	return EntLookup[ self ]:GetSequenceGroundSpeed( ... )
end

function EntityProxy:GetSequenceInfo( ... )
	return EntLookup[ self ]:GetSequenceInfo( ... )
end

function EntityProxy:GetSequenceList()
	return EntLookup[ self ]:GetSequenceList()
end

function EntityProxy:GetSequenceName( ... )
	return EntLookup[ self ]:GetSequenceName( ... )
end

function EntityProxy:GetShouldPlayPickupSound()
	return EntLookup[ self ]:GetShouldPlayPickupSound()
end

function EntityProxy:GetShouldServerRagdoll()
	return EntLookup[ self ]:GetShouldServerRagdoll()
end

function EntityProxy:GetSkin()
	return EntLookup[ self ]:GetSkin()
end

function EntityProxy:GetSolid()
	return EntLookup[ self ]:GetSolid()
end

function EntityProxy:GetSolidFlags()
	return EntLookup[ self ]:GetSolidFlags()
end

function EntityProxy:GetSpawnEffect()
	return EntLookup[ self ]:GetSpawnEffect()
end

function EntityProxy:GetSpawnFlags()
	return EntLookup[ self ]:GetSpawnFlags()
end

function EntityProxy:GetSubMaterial( ... )
	return EntLookup[ self ]:GetSubMaterial( ... )
end

function EntityProxy:GetSubModels()
	return EntLookup[ self ]:GetSubModels()
end

function EntityProxy:GetTable()
	return EntLookup[ self ]:GetTable()
end

function EntityProxy:GetTouchTrace()
	return EntLookup[ self ]:GetTouchTrace()
end

function EntityProxy:GetTransmitWithParent()
	return EntLookup[ self ]:GetTransmitWithParent()
end

function EntityProxy:GetUp()
	return VectorProxy( EntLookup[ self ]:GetUp() )
end

function EntityProxy:GetVelocity()
	return VectorProxy( EntLookup[ self ]:GetVelocity() )
end

function EntityProxy:HasBoneManipulations()
	return EntLookup[ self ]:HasBoneManipulations()
end

function EntityProxy:HasFlexManipulatior()
	return EntLookup[ self ]:HasFlexManipulatior()
end

function EntityProxy:HasSpawnFlags( ... )
	return EntLookup[ self ]:HasSpawnFlags( ... )
end

function EntityProxy:Health()
	return EntLookup[ self ]:Health()
end

function EntityProxy:IsConstrained()
	return EntLookup[ self ]:IsConstrained()
end

function EntityProxy:IsDormant()
	return EntLookup[ self ]:IsDormant()
end

function EntityProxy:IsEffectActive( ... )
	return EntLookup[ self ]:IsEffectActive( ... )
end

function EntityProxy:IsEFlagSet( ... )
	return EntLookup[ self ]:IsEFlagSet( ... )
end

function EntityProxy:IsFlagSet( ... )
	return EntLookup[ self ]:IsFlagSet( ... )
end

function EntityProxy:IsLineOfSightClear( ... )
	return EntLookup[ self ]:IsLineOfSightClear( ... )
end

function EntityProxy:IsNPC()
	return EntLookup[ self ]:IsNPC()
end

function EntityProxy:IsOnFire()
	return EntLookup[ self ]:IsOnFire()
end

function EntityProxy:IsOnGround()
	return EntLookup[ self ]:IsOnGround()
end

function EntityProxy:IsPlayer()
	return EntLookup[ self ]:IsPlayer()
end

function EntityProxy:IsRagdoll()
	return EntLookup[ self ]:IsRagdoll()
end

function EntityProxy:IsSolid()
	return EntLookup[ self ]:IsSolid()
end

function EntityProxy:IsValid()
	return EntLookup[ self ]:IsValid()
end

function EntityProxy:IsVehicle()
	return EntLookup[ self ]:IsVehicle()
end

function EntityProxy:IsWeapon()
	return EntLookup[ self ]:IsWeapon()
end

function EntityProxy:IsWidget()
	return EntLookup[ self ]:IsWidget()
end

function EntityProxy:IsWorld()
	return EntLookup[ self ]:IsWorld()
end

function EntityProxy:LocalToWorld( ... )
	return VectorProxy( EntLookup[ self ]:LocalToWorld( ... ) )
end

function EntityProxy:LocalToWorldAngles( ... )
	return AngleProxy( EntLookup[ self ]:LocalToWorldAngles( ... ) )
end

function EntityProxy:LookupAttachment( ... )
	return EntLookup[ self ]:LookupAttachment( ... )
end

function EntityProxy:LookupBone( ... )
	return EntLookup[ self ]:LookupBone( ... )
end

function EntityProxy:LookupSequence( ... )
	return EntLookup[ self ]:LookupSequence( ... )
end

function EntityProxy:NearestPoint( ... )
	return VectorProxy( EntLookup[ self ]:NearestPoint( ... ) )
end

function EntityProxy:OBBCenter()
	return VectorProxy( EntLookup[ self ]:OBBCenter() )
end

function EntityProxy:OBBMaxs()
	return VectorProxy( EntLookup[ self ]:OBBMaxs() )
end

function EntityProxy:OBBMins()
	return VectorProxy( EntLookup[ self ]:OBBMins() )
end

function EntityProxy:OnGround()
	return EntLookup[ self ]:OnGround()
end

function EntityProxy:WaterLevel()
	return EntLookup[ self ]:WaterLevel()
end

function EntityProxy:WorldSpaceAABB()
	local min, max = EntLookup[ self ]:WorldSpaceAABB()
	return VectorProxy( min ), VectorProxy( max )
end

function EntityProxy:WorldSpaceCenter()
	return VectorProxy( EntLookup[ self ]:WorldSpaceCenter() )
end

function EntityProxy:WorldToLocal( ... )
	return VectorProxy( EntLookup[ self ]:WorldToLocal( ... ) )
end

function EntityProxy:WorldToLocalAngles( ... )
	return AngleProxy( EntLookup[ self ]:WorldToLocalAngles( ... ) )
end
--[[
function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end

function EntityProxy:
    return EntLookup[ self ]:
end
--]]

function Entity( num )
    local ent = G_Entity( num )
    print("what?",IsValid(ent))
    print("enitty",num,ent,EntLookup)

    if not IsValid( ent ) then return EntLookup[ NULL ] end
    print("what")
    print("prereturning", ent )
    local p_ent = EntLookup[ ent ]

    if not p_ent then
        p_ent = EntityProxy( ent )
    end

    print("returning", ent , p_ent)
    return p_ent
end

local null_proxy = EntityProxy( NULL ) --there's always a NULL entity, so I'm going to create one here, i may also have to edit this to make functions called on it error out.
EntLookup[ NULL ] = null_proxy
EntLookup[ null_proxy ] = NULL





print("entity lib loaded")
