--Copyright 2014 Nathan Beals
local container , ply , env = ...
local netc = container:GetNetworker()
local VecLookup = luabox.WeakTable( "k" )--must have weak keys only because the only reference to the actual vector object is being held in this table
VectorProxy = luabox.Class()
local G_Vector = Vector

local check = luabox.CanUse


function VectorProxy:Initialize( vec )
    --VecLookup[ vec ] = self
    VecLookup[ self ] = Vec
end

function VectorProxy:__index( key )
    if key == "x" or key == "y" or key == "z" then
        return VecLookup[ self ][key]
    end
    return VectorProxy
end

function VectorProxy:__newindex( key , value )
    if key == "x" or key == "y" or key == "z" then
        VecLookup[ self ][key] = value
        return
    end
    rawset( self , key , value )
end


function VectorProxy:__tostring()
    return string.format( "Vector [X:%s][Y:%s][Z:%s]" , self.x , self.y , self.Z )
end


function Vector( x , y , z )
    x = x or 0
    y = y or 0
    z = z or 0

    return VectorProxy( G_Vector( x , y , z ) )
end

print("Vector lib loaded")
