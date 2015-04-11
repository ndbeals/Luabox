--Copyright 2014 Nathan Beals
local container , ply , env = ...
local netc = container:GetNetworker()

local EntLookup = {} --two way look up table, use the actual entity as the key to get the entity proxy class, or use the entity proxy class as the key and get the actual entity
local EntityProxy = luabox.Class()
local G_Entity = Entity

local check = luabox.CanUse


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

if SERVER then
function EntityProxy:CreatedByMap()
    return EntLookup[ self ]:CreatedByMap()
end
end

function EntityProxy:
    return EntLookup[ self ]




function Entity( num )
    local ent = G_Entity( num )
    if not ent or not IsValid( ent ) then return EntLookup[ ent ] end

    local p_ent = EntLookup[ ent ]

    if not p_ent then
        p_ent = EntityProxy( ent )
    end

    return p_ent
end

local null_proxy = EntityProxy( NULL ) --there's always a NULL entity, so I i'm going to create one here, i may also have to edit this to make functions called on it error out.
EntLookup[ NULL ] = null_proxy
EntLookup[ null_proxy ] = NULL





print("entity lib loaded")
