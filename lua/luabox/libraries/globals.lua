--Copyright 2014 Nathan Beals
local container , ply , env = ...
local netc = container:GetNetworker()

--local p = print

function print( ... )
    if SERVER then
        local input = {...}

        for key , value in pairs( input ) do
            input[ key ] = tostring( value )
        end

        local str= table.concat( input , "\t" )

        netc:StartMessage( "func_print" )
            netc:WriteString( str )
        netc:Send()
    else
        print(...)
    end
end

netc:Receive( "func_print" , function()
    print( netc:ReadString() )
end)




local TEST = true
--print = print
msg = msg

PrintTable = PrintTable
print("globals loaded",container,ply,SERVER)

CLIENT = CLIENT
SERVER = SERVER

hook=hook
