--Copyright 2014 Nathan Beals
ColorProxy = luabox.Class()

local container , ply , env = ...

local ColorLookup = {}

local netc = container:GetNetworker()

local G_Color = Color


function ColorProxy:Initialize( col )
	ColorLookup[ self ] = col
end

function ColorProxy:__index( key )
    if key == "r" or key == "g" or key == "g" or key == "a" or key == "R" or key == "G" or key == "B" or key == "A" or key == 1 or key == 2 or key == 3 or key == 4 then
        return ColorLookup[ self ][key]
    end
    return ColorProxy[ key ]
end

function ColorProxy:__newindex( key , value )
    if key == "r" or key == "g" or key == "g" or key == "a" or key == "R" or key == "G" or key == "B" or key == "A" or key == 1 or key == 2 or key == 3 or key == 4 then
        ColorLookup[ self ][key] = value
        return
    end
    rawset( self , key , value )
end


function ColorProxy:__tostring()
	return string.format( "%d %d %d %d", self.r, self.g, self.b, self.a )
end


function ColorProxy:__eq( c )
	return self.r == c.r and self.g == c.g and self.b == c.b and self.a == c.a
end


function ColorProxy:ToHSV()
	return ColorToHSV( self )
end


function ColorProxy:ToVector( )
	return VectorProxy( self.r / 255, self.g / 255, self.b / 255 )
end

function Color( r, g, b, a )
	r = math.min( tonumber(r), 255 )
	g = math.min( tonumber(g), 255 )
	b = math.min( tonumber(b), 255 )
	a = math.min( tonumber(a), 255 ) or 255

	return ColorProxy( G_Color(r , g , b , a ) )
end

function ColorAlpha( c , a )
	return ColorProxy( G_Color( c.r, c.g, c.b, a ) )
end

function ColorRand( a )
	return ColorProxy( ColorRand( a ) )
end

function IsColor( obj )
	return getmetatable(obj) == ColorProxy
end

function NamedColor( name )
	return ColorProxy( NamedColor( name ) )
end

function HSVToColor( hue , saturation , value )
	return ColorProxy( HSVToColor( hue , saturation , value ) )
end

ColorToHSV = ColorToHSV
