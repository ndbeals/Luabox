--Copyright 2014 Nathan Beals
local container , ply , env = ...
--local n = container:GetNetworker()

--local p = print

function print( ... )
    --print("REALM SERVER:",SERVER)
    if SERVER then
        ---[[
        local input = {...}

        for key , value in pairs( input ) do
            input[ key ] = tostring( value )
        end


        local str= table.concat( input , "\t" )
        --]]
        --print("who not run",str)
        local n = container:GetNetworker()
        n:StartMessage( "func_print" )
            --print("sending",n.CurrentBuffer)
            n:WriteString( str )
            --print(" wtf")
        n:Send()
        --print("NO WAY")
    else



        --print(...)
    end
end

local n = container:GetNetworker()
n:Receive( "func_print" , function()
    --print("receiving")
    local str = n:ReadString()
    print( str )
end)




local TEST = true
--print = print
msg = msg

PrintTable = PrintTable
print("globals loaded",container,ply,SERVER)

CLIENT = CLIENT
SERVER = SERVER

hook=hook
