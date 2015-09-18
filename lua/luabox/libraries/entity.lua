--Copyright 2014 Nathan Beals
local container , ply , env = ...
local netc = container:GetNetworker()

local EntLookup = luabox.WeakTable() --two way look up table, use the actual entity as the key to get the entity proxy class, or use the entity proxy class as the key and get the actual entity
env.EntLookup = EntLookup

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
    return EntLookup[ self ]:GetCollisionBounds()
end

function EntityProxy:GetCollisionGroup()
    return EntLookup[ self ]:GetCollisionGroup()
end

function EntityProxy:GetColor()
    return EntLookup[ self ]:GetColor()
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
