--Copyright 2014 Nathan Beals

luabox = luabox or {}--										Create the global table



if SERVER then
	AddCSLuaFile("luabox/cl_luabox.lua")
	AddCSLuaFile("luabox/sh_luabox.lua")

	AddCSLuaFile("luabox/modules/luabox.lua")

	include("luabox/sh_luabox.lua")
	include("luabox/sv_luabox.lua")
else
	include("luabox/sh_luabox.lua")
	include("luabox/cl_luabox.lua")
end

include("luabox/modules/luabox.lua")
