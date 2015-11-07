--Copyright 2015 Nathan Beals
local container , ply , env = ...
local netc = container:GetNetworker()

Links = {}

function Links.Print()
	PrintTable( env.Entity.LuaboxLinks )
end
