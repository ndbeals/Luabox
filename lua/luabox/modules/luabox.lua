--Copyright 2014 Nathan Beals

local coroutine = coroutine


module("luabox",package.seeall)
Libraries = {}
Containers = {}

local function GetLibraryNameFromFileName( path )
	return string.StripExtension( path )
end

--- Class Creator
-- Creates a basic class template and returns it to be used for further editing and extending
-- Supports infinite class inheritence
-- @param base The baseclass for the newly created class to inherit from
-- @return Returns the brand new class template to be edited
-- @usage local dog = Class() 
-- function dog:Test() end
function Class(base)
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

		local library = Library(GetLibraryNameFromFileName( File ))

		librarymeta.__newindex = function(self,k,v)
			library.Functions[k] = v
		end

		setfenv(CompileFile("luabox/libraries/" .. File ) , setmetatable( {} , librarymeta ) )() --convoluted line, but this whole function gets grey, This line. 1. Loads a library file as a function 2. Changes the environment of said function so that anything added to it is actually put into the function table of hte library class created above this. and 3. Calls the loaded and edited function
	end
end

function CreateDefaultLibrary()
	DefaultFunctions = Library( "DefaultFunctions" ) -- Create a library which is all of the default libraries merged into one table to be used as the base for generic lua sandboxes
	DefaultFunctions:UnRegister() -- unregister it from the default functions library, so we dont get infinite recursion

	for LibraryName , Library in pairs(Libraries) do
		for Key , Value in pairs(Library:GetFunctions()) do
			DefaultFunctions[Key] = Value
		end
	end
end


Environment = Class() -- Environment just holds all data and functions for any given lua environment. It does not control the actual function that has it's environment changed

function Environment:Initialize( basefunctions , func )
	self.Environment = {}
	self.Environment["_G"] = self.Environment
	self.Environment["self"] = self.Environment

	self:SetBaseFunctions( basefunctions )

	if func then
		self:SetFunction( func )
	end
end

function Environment:SetBaseFunctions( functab )
	self.Environment = setmetatable( self.Environment , {__index = functab} )
end

--function Environment:SetFunction( func )
--	self.Function = setfenv( func , self.Environment )
--end
--
--function Environment:GetFunction()
--	return self.Function
--end
--
--function Environment:InitialExecute()
--	return self.Function()
--end

function Environment:GetEnvironment()
	return self.Environment
end


Script = Class()

function Script:Initialize( environment , func)
	self:SetEnvironment( environment )
	self:SetFunction(func)
end

function Script:SetFunction( func )
	self.Function = setfenv( func , self.Environment:GetEnvironment() )
end

function Script:SetScript( funcstr )
	self.Function = setfenv( CompileString( funcstr ) , self.Environment:GetEnvironment() )
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

Container = Class()	-- Container class is in charge of executing sandbox code and holding the environment

function Container:Initialize( defaultfuncs )
	Containers[#Containers + 1] = self

	self.Scripts = {}

	self.Environment = Environment( defaultfuncs or DefaultFunctions:GetFunctions() )
end

function Container:AddScript( func )
	self.Scripts[#self.Scripts + 1] = Script( self.Environment , func )


	--self.Environment:SetFunction( func )
end

function Container:InitializeEnvironment()
	self.Environment:InitialExecute()
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

Library = Class()

function Library:Initialize( name )
	rawset(self , "Functions" , {})
	rawset(self , "Name" , name)

	self:Register()
end

function Library:Register()
	Libraries[self.Name] = self
end

function Library:UnRegister()
	Libraries[self.Name] = nil
end

function Library.__newindex( self , key , value )
	--print( "what did I add?", self , key , value )
	self.Functions[key] = value
end

function Library:GetFunctions()
	return self.Functions
end

function Library:AddFunction( name , func ) 
	self.Functions[name] = func
end

function Library:RemoveFunction( name ) 
	self.Functions[name] = nil
end


concommand.Add("reload_luabox", function()
	for k , ply in pairs(player.GetAll()) do 
		ply:SendLua([[include("luabox/modules/luabox.lua")]])
	end
	include("luabox/modules/luabox.lua")
	print("luabox module reloaded")
end)


LoadLibraries()
CreateDefaultLibrary()

