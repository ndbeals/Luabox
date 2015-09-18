--Copyright 2014 Nathan Beals

luabox = luabox or {} --								Create the global table

include("luabox/modules/luabox.lua")

if SERVER then
	AddCSLuaFile("luabox/cl_luabox.lua")
	AddCSLuaFile("luabox/sh_luabox.lua")
	AddCSLuaFile("luabox/sh_cppi.lua")

	AddCSLuaFile("luabox/modules/luabox.lua")
	AddCSLuaFile("luabox/ui/editor.lua")
	AddCSLuaFile("luabox/ui/editorframe.lua")
	AddCSLuaFile("luabox/ui/filetree.lua")
	AddCSLuaFile("luabox/ui/hscrollbar.lua")
	AddCSLuaFile("luabox/ui/hscrollpanel.lua")
	AddCSLuaFile("luabox/ui/consoleoutput.lua")
	AddCSLuaFile("luabox/ui/splitter.lua")
	AddCSLuaFile("luabox/ui/filetree_node.lua")
	AddCSLuaFile("luabox/ui/toolmenu.lua")
	AddCSLuaFile("luabox/ui/tab_close.lua")
	AddCSLuaFile("luabox/ui/filemanager.lua")
	AddCSLuaFile("luabox/ui/folderview.lua")

	include("luabox/sh_luabox.lua")
	include("luabox/sv_luabox.lua")
	include("luabox/sh_cppi.lua")
else
	include("luabox/ui/editor.lua")
	include("luabox/ui/editorframe.lua")
	include("luabox/ui/filetree.lua")
	include("luabox/ui/hscrollbar.lua")
	include("luabox/ui/hscrollpanel.lua")
	include("luabox/ui/consoleoutput.lua")
	include("luabox/ui/splitter.lua")
	include("luabox/ui/filetree_node.lua")
	include("luabox/ui/tab_close.lua")
	include("luabox/ui/filemanager.lua")
	include("luabox/ui/folderview.lua")

	include("luabox/sh_luabox.lua")
	include("luabox/cl_luabox.lua")
	include("luabox/sh_cppi.lua")
end
