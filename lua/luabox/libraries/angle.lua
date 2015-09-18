--Copyright 2014 Nathan Beals
AngleProxy = luabox.Class()

local container , ply , env = ...

local AngLookup = luabox.WeakTable( "k" ) --must have weak keys only because the only reference to the actual angle object is being held in this table
local netc = container:GetNetworker()

local check = luabox.CanUse

local G_Angle = Angle

function AngleProxy:Initialize( ang )
    AngLookup[ self ] = ang
end

function AngleProxy:__index( key )
    if key == "p" or key == "y" or key == "r" or key == "P" or key == "Y" or key == "R" or key == 1 or key == 2 or key == 3 then
        return AngLookup[ self ][key]
    end
    return AngleProxy[ key ]
end

function AngleProxy:__newindex( key , value )
    if key == "p" or key == "y" or key == "r" or key == "P" or key == "Y" or key == "R" or key == 1 or key == 2 or key == 3 then
        AngLookup[ self ][key] = value
        return
    end
    rawset( self , key , value )
end


function AngleProxy:__tostring()
    return string.format( "Angle [P:%s][Y:%s][R:%s]" , self.p , self.y , self.r )
end

function AngleProxy:Forward()
    return VectorProxy( AngLookup[ self ]:Forward() )
end

function AngleProxy:Right()
    return VectorProxy( AngLookup[ self ]:Right() )
end

function AngleProxy:Up()
    return VectorProxy( AngLookup[ self ]:Up() )
end

function AngleProxy:Normalize()
    AngLookup[ self ]:Normalize()
end

function AngleProxy:RotateAroundAxis( vec , deg )
    AngLookup[ self ]:RotateAroundAxis( env.VecLookup[ vec ] , deg )
end

function AngleProxy:Set( angle )
    AngLookup[ self ].p = angle.p
    AngLookup[ self ].y = angle.y
    AngLookup[ self ].r = angle.r
end

function AngleProxy:IsZero()
    return AngLookup[ self ]:IsZero()
end

function AngleProxy:SnapTo( axis , target )
    return AngLookup[ self ]:SnapTo( axis , target )
end

function AngleProxy:Zero()
    return AngLookup[ self ]:Zero()
end

function Angle( pitch , yaw , roll )
    pitch = pitch or 0
    yaw = yaw or 0
    roll = roll or 0

    return AngleProxy( G_Angle( pitch , yaw , roll ) )
end

print("Angle lib loaded")
