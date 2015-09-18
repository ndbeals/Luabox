--Copyright 2014 Nathan Beals
VectorProxy = luabox.Class()
local container , ply , env = ...

local VecLookup = luabox.WeakTable( "k" )--must have weak keys only because the only reference to the actual vector object is being held in this table
env.VecLookup = VecLookup

local netc = container:GetNetworker()

local check = luabox.CanUse

local G_Vector = Vector


function VectorProxy:Initialize( vec )
    --VecLookup[ vec ] = self
    VecLookup[ self ] = vec
end

function VectorProxy:__index( key )
    if key == "x" or key == "y" or key == "z"  or key == "X" or key == "Y" or key == "Z" or key == 1 or key == 2 or key == 3 then
        return VecLookup[ self ][key]
    end
    return VectorProxy[ key ]
end

function VectorProxy:__newindex( key , value )
    if key == "x" or key == "y" or key == "z"  or key == "X" or key == "Y" or key == "Z" or key == 1 or key == 2 or key == 3 then
        VecLookup[ self ][key] = value
        return
    end
    rawset( self , key , value )
end


function VectorProxy:__tostring()
    return string.format( "Vector [X:%s][Y:%s][Z:%s]" , self.x , self.y , self.z )
end


function Vector( x , y , z )
    x = x or 0
    y = y or 0
    z = z or 0

    return VectorProxy( G_Vector( x , y , z ) )
end

print("Vector lib loaded")
