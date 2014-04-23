--Copyright 2014 Nathan Beals

local coroutine = coroutine


module("luabox",package.seeall)
Libraries = {}

function Class(base)
	local class = {}-- 														-- a new class metatable
	local classmt = {}--													-- the new classes' meta table, this allows inheritence if the class has a base, and lets you create a new instance with <classname>()
	class.__index = class
	class.base = base


	classmt.__call = function(_, ...)--										-- expose a constructor which can be called by <classname>(<args>)
		local obj = {}--													-- new instance of the class to be manipulated.
		setmetatable(obj,class)

		if class.Initialize then
			class.Initialize(obj,...)
		end
			
		return obj
	end

	setmetatable(class, classmt)
	return class
end

Environment = Class()														-- Environment just holds all data and functions for any given lua environment. It does not control the actual function that has it's environment changed

function Environment:Initialize( basefunctions , func )
	self.Environment = {}
	self.Environment["_G"] = self.Environment

	self:SetBaseFunctions( basefunctions )
end

function Environment:SetBaseFunctions( functab )
	self.Environment = setmetatable( self.Environment , {__index = functab})
end

function Environment:SetFunction( func )
	self.Function = setfenv( func , self.Environment )
end

function Environment:GetFunction()
	return self.Function
end

function Environment:GetEnvironment()
	return self.Environment
end



Library = Class()

function Library:Initialize( name )
	--print("Library initialized",name)
	rawset(self , "Functions" , {})
	rawset(self , "Name" , name )


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

--print("test from luabox module")

Container = Class()															-- Container class is in charge of executing sandbox code and holding the environment

function Container:Initialize()
	self.Environment = {}
end

--MsgN("WHY NOT BOTH",CLIENT,SERVER)



local files = file.Find("luabox/libraries/*.lua","LUA")

for _, File in pairs(files) do
	--print("added:","luabox/libraries/" .. File )
	if SERVER then
		AddCSLuaFile("luabox/libraries/".. File )
	end
	include("luabox/libraries/" .. File )
end

DefaultFunctions = Library( "DefaultFunctions" )
DefaultFunctions:UnRegister()

for LibraryName , Library in pairs(Libraries) do
	--print(LibraryName,Library)
	for Key , Value in pairs(Library:GetFunctions()) do
		--print(CLIENT,Key,Value)
		DefaultFunctions[Key] = Value
	end
end



concommand.Add("reload_luabox", function()
	for k , ply in pairs(player.GetAll()) do 
		ply:SendLua([[include("luabox/modules/luabox.lua")]])
	end
	include("luabox/modules/luabox.lua")
	print("luabox module reloaded")
end)









local function testprint(str)
	print("TESTESTSETS",str)
end

luabox.Functions = {
	print = testprint,
}

function SandBox( func )										--takes a function and returns sandbox object



	return setfenv( func , luabox.Functions )
end






Moongate = {}
Moongate.Functions = {
--print=function(str) print("GAAY AF",str) end,
PLAYER = TGiFallen,
Entity = Entity,
pairs = pairs,
}

--function Moongate.Functions:print( str )
--	self:PrintMessage(HUD_PRINTCONSOLE , "ur gaay!" .. str )
--end

local function playercode()
	print("TEST")
end

--local playercode = 
playercode = setfenv( playercode , {print=nil} )

--playercode()