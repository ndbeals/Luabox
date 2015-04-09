--Copyright 2014 Nathan Beals
local container , ply , env = ...
local netc = container:GetNetworker()

CLIENT = CLIENT
SERVER = SERVER

RealTime = RealTime

function print( ... )
    if SERVER then
        local input = {...}

        for key , value in pairs( input ) do
            input[ key ] = tostring( value )
        end

        local str= table.concat( input , "\t" )

        netc:Start( "func_print" )
            netc:WriteString( str )
        netc:Send()
    else
        print(...)
    end
end
netc:Receive( "func_print" , function()
    print( netc:ReadString() )
end)

local function printtab( t, indent, done )
	done = done or {}
	indent = indent or 0
	local keys = table.GetKeys( t )
    local send = ""

	table.sort( keys, function( a, b )
		if ( isnumber( a ) and isnumber( b ) ) then return a < b end
		return tostring( a ) < tostring( b )
	end )

	for i = 1, #keys do
		local key = keys[ i ]
		local value = t[ key ]
		send = send .. string.rep( "\t", indent )

		if  ( istable( value ) and not done[ value ] ) then

			done[ value ] = true
            send = send .. tostring( key ) .. ":" .. "\n"
            send = send .. printtab ( value, indent + 2, done )

		else

            send = send ..tostring( key ) .. "\t=\t"
            send = send ..tostring( value ) .. "\n"

		end

	end
    return send
end

function PrintTable( t , indent , done )
    if SERVER then
        local send = printtab( t , indent , done )
        netc:Start( "func_printtab" )
            netc:WriteString( send )
        netc:Send()
    else
        PrintTable( t , indent , done )
    end
end
netc:Receive( "func_printtab" , function()
    Msg( netc:ReadString() )
end)


env:CallOnRemove( "Test_Removing" , function()
    print("REMOVING")

    error("teste error")

end)


Msg = print
MsgN = print

print("globals loaded",container,ply,SERVER)


hook=hook
