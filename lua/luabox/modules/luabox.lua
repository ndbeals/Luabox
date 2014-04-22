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

function Environment:Initialize()
	self.BaseFunctions = {}
	self.Environment = setmetatable( {} , {__index=self.BaseFunctions})

end

function Environment:AddAllDefaultLibraries()
	for LibraryName , Library in pairs(Libraries) do
		for Key , Value in pairs(Library.Functions) do
			self.BaseFunctions[Key] = Value
		end
	end
end

Library = Class()

function Library:Initialize( name )
	print("Library initialized",name)

	self:Register(name)

	rawset(self , "Functions" , {})
end

function Library:Register( name )
	Libraries[name] = self
end

function Library.__newindex( self , key , value )
	print( "what did I add?", self , key , value )
	self.Functions[key] = value
end


print("test from luabox module")

Container = Class()															-- Container class is in charge of executing sandbox code and holding the environment

function Container:Initialize()
	self.Environment = {}
end





do--																		-- Do event for easy code folding, this loads default libraries
	local files = file.Find("luabox/libraries/*.lua","LUA")

	for _, File in pairs(files) do
		print("added:","luabox/libraries/" .. File )
		include("luabox/libraries/" .. File )
	end
end

concommand.Add("reload_luabox", function()
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