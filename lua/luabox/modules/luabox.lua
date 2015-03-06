--Copyright 2014 Nathan Beals

--local coroutine = coroutine

--- Luabox Module
--@module Luabox
module("luabox",package.seeall)
Libraries			=	{}
Containers			=	{}
DefaultFunctions	=	{}


--- Class Creator.
-- Creates a basic class template and returns it to be used for further editing and extending.
-- Supports infinite class inheritence.
-- @param base The baseclass for the newly created class to inherit from.
-- @return class Returns the new class template to be edited.
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


--- Library loading function.
-- Can be called after initialize but won't really work well for client libraries.
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

		local library = Library(string.StripExtension( File ))

		--librarymeta.__newindex = function(self,k,v)
		--	library.Functions[k] = v
		--end

		library:SetTemplate(CompileFile("luabox/libraries/" .. File ) )

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


Library = Class()

--- Library Class Constructor
-- Holds basic function templates which are abstracted to work per player.
--@param name Name of the library

function Library:Initialize( name )
	name = name or tostring(self)
	self.Name = name

	self:Register()
end

function Library:SetTemplate( func )
	if type(func) == "function" then
		self.Template = func
	end
end

function Library:CreateLibrary( container )


end

function Library:Register()
	Libraries[self.Name] = self
end

function Library:UnRegister()
	Libraries[self.Name] = nil
end



Environment = Class() -- Environment just holds all data and functions for any given lua environment. It does not control the actual function that has it's environment changed (fix wording)

function Environment:Initialize( basefunctions )
	basefunctions = basefunctions or DefaultFunctions

	self:SetEnvironment({})
	self:SetBaseFunctions( basefunctions )
end

function Environment:SetBaseFunctions( functab )
	if not functab then return end
	self:SetEnvironment( setmetatable( self.Environment , {__index = functab} ) )
end

function Environment:GetEnvironment()
	return self.Environment
end

function Environment:SetEnvironment( env )
	self.Environment = env
	self.Environment["_G"] = env
	self.Environment["self"] = env
end


Script = Class()

function Script:Initialize( environment , func)
	self:SetEnvironment( environment )
	self:SetFunction( func )
end

function Script:SetFunction( func )
	if not func then return end

	self.Function = setfenv( func , self.Environment:GetEnvironment() )
end

-- todo: error catch string code
function Script:SetScript( funcstr )
	if not funcstr then return end
	if not self:GetEnvironment() then return end

	self.Function = setfenv( CompileString( funcstr , tostring(self) ) , self.Environment:GetEnvironment() )
end

function Script:GetFunction()
	return self.Function
end

function Script:GetEnvironemnt()
	return self.Environment
end

function Script:SetEnvironment( environment )
	self.Environment = environment
end

function Script:Execute()
	return pcall( self.Function )
end


Container = Class()	-- Container class is in charge of executing sandbox code and holding the environment, one per player (so far)

function Container:Initialize( default_libs , player )
	Containers[#Containers + 1]	=	self
	
	self.Scripts				=	{}
	self.Environments			=	{}

	self.Libraries = default_libs or table.Copy( Libraries )

	--self.Environment = Environment( defaultfuncs )

	-- add include function directly from here, kind of hacky
	--self.Environment.Environment.include = function()
	--
	--end
end

function Container:AddFunctionsToEnvironment()

function Container:AddScript( func )
	if not func then return end

	local newscript = Script( self.Environment , func )
	self.Scripts[#self.Scripts + 1] = newscript

	return newscript
end

function Container:RunScripts()

	for i = 1 , #self.Scripts do
		local success , msg = self.Scripts[i]:Execute()

		if not success then
			print("errored with:" , msg)

			break
		end
	end

end

function Container:UnloadScripts()
	for name , lib in pairs( self.LoadedLibraries ) do

	end
end

--[[
local tmp
hook.Add("Think","TESTESTESTESTEST" , function()

	for I = 1 , #Containers do
		tmp = Containers[I]

		tmp.Environment:GetEnvironment():Think()

	end

end)
--]]



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
