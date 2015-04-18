--Copyright 2014 Nathan Beals
local container , ply , env = ...
local netc = container:GetNetworker()

local AngLookup = luabox.WeakTable( "k" ) --must have weak keys only because the only reference to the actual angle object is being held in this table
AngleProxy = luabox.Class()
local G_Angle = Angle

local check = luabox.CanUse


function AngleProxy:Initialize( ang )
    --AngLookup[ ang ] = self
    AngLookup[ self ] = ang
end

function AngleProxy:__index( key )
    if key == "p" or key == "y" or key == "r" then
        return AngLookup[ self ][key]
    end
    return AngleProxy
end

function AngleProxy:__newindex( key , value )
    if key == "p" or key == "y" or key == "r" then
        AngLookup[ self ][key] = value
        return
    end
    rawset( self , key , value )
end


function AngleProxy:__tostring()
    return string.format( "Angle [P:%s][Y:%s][R:%s]" , self.p , self.y , self.r )
end


function Angle( pitch , yaw , roll )
    pitch = pitch or 0
    yaw = yaw or 0
    roll = roll or 0

    return AngleProxy( G_Angle( pitch , yaw , roll ) )
end

print("Angle lib loaded")
