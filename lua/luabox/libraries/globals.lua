--Copyright 2014 Nathan Beals
local container , ply , env = ...
--local n = container:GetNetworker()

local p = print

function print( ... )
    p("this sghould",SERVER)
    if SERVER then
        local input = {...}

        for key , value in pairs( input ) do
            input[ key] = tostring( value )
        end
        local n = container:GetNetworker()
        local str= table.concat( input , "    " )
        --print("who not run",str)
        n:StartMessage( "func_print" )
            --print("sending",n.CurrentBuffer)
            n:WriteString( "test" )
            --print(" wtf")
        n:Send()
        --print("NO WAY")
    else



        --print(...)
    end
end
local n = container:GetNetworker()
n:Receive( "func_print" , function()
    print("receiving")
    local str = n:ReadString()
    print( "PRINTING SOMETHING:", str )
end)




local TEST = true
--print = print
msg = msg

PrintTable = PrintTable
print("globals loaded",container,ply,SERVER)

CLIENT = CLIENT
SERVER = SERVER

hook=hook
