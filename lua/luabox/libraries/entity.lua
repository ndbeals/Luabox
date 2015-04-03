--Copyright 2014 Nathan Beals
local container , ply , env = ...
local netc = container:GetNetworker()

local EntLookup = {} --two way look up table, use the actual entity as the key to get the entity proxy class, or use the entity proxy class as the key and get the actual entity
local EntityProxy = luabox.Class()
local G_Entity = Entity


--EntityProxy.EntIndex = 0
--EntityProxy.Class = "test"
function EntityProxy:Initialize( ent )
    EntLookup[ ent ] = self
    EntLookup[ self ] = ent

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

function Entity( num )
    local ent = G_Entity( num )
    --print("first",num,ent)
    if not ent or not IsValid( ent ) then return end
    --print("still")
    local p_ent = EntLookup[ ent ]

    --print("still more",p_ent,EntLookup[ent])

    --PrintTable(EntLookup)

    if not p_ent then
        p_ent = EntityProxy( ent )



        --print("stiller",p_ent)
    end
    --print("stilleed",ent,p_ent)
    --print(ent,p_ent)
    --print("stillest")
    return p_ent
end

print("entity lib loaded")
