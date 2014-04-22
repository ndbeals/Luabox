--Copyright 2014 Nathan Beals

luabox = luabox or {}--										Create the global table

if SERVER then--											--this file strictly loads the main files of the project, all other file loading happens in sh_luabox.lua
	AddCSLuaFile("luabox/cl_luabox.lua")
	AddCSLuaFile("luabox/sh_luabox.lua")

	include("luabox/sv_luabox.lua")
else
	include("luabox/cl_luabox.lua")
end

include("luabox/sh_luabox.lua")