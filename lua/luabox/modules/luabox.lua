--Copyright 2014 Nathan Beals

--local coroutine = coroutine
local table = table

--- Luabox Module
--@module Luabox
module("luabox",package.seeall)
local Libraries			=	{}
local Containers		=	{}
--DefaultFunctions	=	{}

--- Get Libraries.
-- Gets a copied list of all loaded Luabox libraries
--@return Libraries: A copy of the default library tables
function GetLibraries()
	return table.Copy(Libraries)
end


--- Class Creator.
-- Creates a basic class template and returns it to be used for further editing and extending.
-- Supports infinite class inheritence.
--@function Class
--@param base The baseclass for the newly created class to inherit from.
--@return class Returns the new class template to be edited.
function Class( base )
	local class = {} -- a new class metatable
	class.__index = class

	local classmt = {
		__index = base,
		base = base,
	} -- the new classes' meta table, this allows inheritence if the class has a base, and lets you create a new instance with <classname>()


	classmt.__call = function(_, ...) -- expose a constructor which can be called by <classname>(<args>)
		local obj = {} -- new instance of the class to be manipulated.
		setmetatable(obj,class)

		if class.Initialize then
			class.Initialize(obj,...)
		end

		return obj
	end

	setmetatable(class, classmt)
	return class
end


--- Library Loader.
-- Can be called after initialize but won't really work well for client libraries.
-- Todo:replace.
function LoadLibraries()
	local librarymeta = {
		__index = _G
	}

	local files = file.Find("luabox/libraries/*.lua","LUA")

	for _, File in pairs(files) do
		--print("added:","luabox/libraries/" .. File )
		if SERVER then
			AddCSLuaFile("luabox/libraries/".. File )
		end

		--local library =
		Library( "luabox/libraries/"..File )

		--librarymeta.__newindex = function(self,k,v)
		--	library.Functions[k] = v
		--end

		--library:SetTemplate(CompileFile("luabox/libraries/" .. File ) )

	end
end
LoadLibraries()

function CreateDefaultLibrary()
	DefaultFunctions = {}--Library( "DefaultFunctions" ) -- Create a library which is all of the default libraries merged into one table to be used as the base for generic lua sandboxes
	--DefaultFunctions:UnRegister() -- unregister it from the default functions library, so we dont get infinite recursion

	for LibraryName , Library in pairs(Libraries) do
		for Key , Value in pairs(Library:GetFunctions()) do
			DefaultFunctions[Key] = Value
		end
	end
end

--- Library Class
--@section Library
Library = Class()

--- Library Class Constructor.
-- Holds basic function templates which are abstracted to work per player.
--@param file file to load for the library
function Library:Initialize( file )
	self.Name = string.StripExtension( file ) or tostring(self)

	self:SetTemplate( CompileFile( file ) )

	self:Register()
end

--- Set Template.
-- Sets the library template, this template is a function, that when called, creates a library of functions specific to players (I.E those players permissions to entities, hooks, etc)
--@param func function template, Typically an entire lua file (as files are just functions which are executed once)
function Library:SetTemplate( func )
	if type(func) == "function" then
		self.Template = func
	end
end

--- Get Template.
-- Returns the function template of the library object
--@return The function template
function Library:GetTemplate()
	return self.Template
end

--- Register Library.
-- Registers the library with the master Luabox library list, this is called automatically in the constructor, but one can unregister and register with a different name
function Library:Register()
	Libraries[self.Name] = self
end

--- UnRegister Library.
-- Unregisters the library from the master list
function Library:UnRegister()
	Libraries[self.Name] = nil
end

--- Get Name.
-- Gets the name of the library
--@return Library Name
function Library:GetName()
	return self.Name
end

--- Set Name.
-- sets the name of the library
--@param name New name
function Library:SetName( name )
	self.Name = name
end



function Library:CreateLibrary( container )


end

--- Environment Class
--@section Environment
Environment = Class()

--- Environment Class Constructor.
-- Creates an environment class which holds one lua environment. This includes variables and player specific functions.
function Environment:Initialize()
	
end

--- Get Environment.
-- Gets the Environment table of the given Environment class.
--@return Environment: The Environment Table.
function Environment:GetEnvironment()
	return self.Environment
end

--
--function Environment:SetBaseFunctions( functab )
--	if not functab then return end
--	self:SetEnvironment( setmetatable( self.Environment , {__index = functab} ) )
--end

--- Set Environment.
-- Sets the environment table of the class to a new table.
--@param env New enviroment to use.
function Environment:SetEnvironment( env )
	self.Environment = env
	self.Environment["_G"] = env
	self.Environment["self"] = env
end

--- Script Class
--@section Script
Script = Class()

--- Script Class Constructor.
-- Creates a Script class which contains user made scripts to be sandboxed.
--@param environment The environment that the script will use.
--@param funcstr The function string to be ran in the sandbox.
function Script:Initialize( environment , funcstr )
	self:SetEnvironment( environment )
	self:SetScript( funcstr )
end

--- Set Function.
-- INTERNAL: Sets the script classes function to be sandboxed, called by the constructor.
--@param func The function to be ran in the sandbox
function Script:SetFunction( func )
	if not func or not type( func ) == "function" then return end

	self.Function = setfenv( func , self.Environment:GetEnvironment() )
end

--- Set Script.
-- Sets the script string to a string of (valid) Lua code, is then compiled to a function and set as the script's function as well.
-- todo: error catch string code.
--@param funcstr The function string to be ran in the sandbox.
function Script:SetScript( funcstr )
	if not funcstr or not type( funcstr ) == "string" then return end
	if not self:GetEnvironment() then return end

	self:SetFunction( CompileString( funcstr , tostring(self) ))
end

--- Get Function.
-- Gets the scripts sandboxed function.
function Script:GetFunction()
	return self.Function
end

--- Get Environment.
-- Returns the environment object the script is using.
--@return Environment.
function Script:GetEnvironemnt()
	return self.Environment
end

--- Set Environment.
-- Sets the environment onject for the script to use.
--@param environment The environment object.
function Script:SetEnvironment( environment )
	self.Environment = environment
end

--- Execute.
-- Executes the script, each script should only be executed once.
-- todo: better error handling.
function Script:Execute()
	return pcall( self.Function )
end


--- Container Class.
--@section Container
Container = Class()	-- Container class is in charge of executing sandbox code and holding the environment, one per player (so far)

--- Container Class Constructor.
-- Creates the container class instance, most users will only need to interface with this class.
--@param player Player object the container is linked to, one container per player
--@param default_libs Defaults libraries to use.
function Container:Initialize( player , default_libs )
	Containers[#Containers + 1]	=	self

	self.Scripts				=	{}
	self.Environments			=	{}

	self.Libraries = default_libs or GetLibraries()

	--self.Environment = Environment( defaultfuncs )

	-- add include function directly from here, kind of hacky
	--self.Environment.Environment.include = function()
	--
	--end
end

function Container:AddFunctionsToEnvironment()

end

--- Add Script.
-- Adds a new script to the container.
--@param func Script function.
--@return newscript: The new script object
function Container:AddScript( func )
	if not func then return end

	local newscript = Script( self.Environment , func )
	self.Scripts[#self.Scripts + 1] = newscript

	return newscript
end

--- Run Scripts.
-- Execute all of the scripts on the container object once.
-- todo: better error checking
function Container:RunScripts()

	for i = 1 , #self.Scripts do
		local success , msg = self.Scripts[i]:Execute()

		if not success then
			print("errored with:" , msg)

			break
		end
	end

end




if !HookCall then HookCall = hook.Call end
local arg , env , container , retvalues
hook.Call = function( name, gm, ... )
	arg = { ... }

	for i = 1 , #Containers do
		container = Containers[i]
		env = container.Environment.Environment

		if env[name] then
			retvalues = { pcall( env[name] , env , ... ) }


			if ( retvalues[1] and retvalues[2] != nil ) then
				table.remove( retvalues, 1 )
				return unpack( retvalues )
			elseif ( !retvalues[1] ) then
				print("Hook '" .. name .. "' in plugin '" .. "plugin.Title" .. "' failed with error:" )
				print(retvalues[2] )
			end
		end
	end

	return HookCall( name, gm, ... )
end



















concommand.Add("reload_luabox", function()
	for k , ply in pairs(player.GetAll()) do
		ply:SendLua([[include("luabox/modules/luabox.lua")]])
	end
	include("luabox/modules/luabox.lua")
	print("luabox module reloaded")
end)




CreateDefaultLibrary()
