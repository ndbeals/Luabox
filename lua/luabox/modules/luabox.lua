--Copyright 2014 Nathan Beals

local table = table
local coroutine = coroutine
local error = error
local bit = bit

local prn = print

local sethook = debug.sethook

--- Luabox Module
--@module Luabox
luabox = luabox or {}
module("luabox",package.seeall)
local Libraries			=	{}
local Containers		=	{}
local ContainerLookup	=	{}

print = function(...)
	prn( RealTime() ,"\t:", ... )
end

--- Get Player Container.
-- Gets a the container that the player owns, caches the results because why not. creates a container if there isn't one.
--@param player The player to get the container of.
--@return Container: The player's container.
function PlayerContainer( player )
	if CLIENT then player = LocalPlayer() end
	if not player or not IsValid( player ) then error("No Player object provided",2) end

	local ret = ContainerLookup[ player ]

	if not ret then
		for k , container in pairs( Containers ) do
			if container:GetOwner() == player then
				ret = container
				ContainerLookup[ player ] = container
			end
		end
		if not ret then
			ret = luabox.Container( player )
		end
	end

	return ret
end

--- Get Libraries.
-- Gets a copied list of all loaded Luabox libraries
--@return Libraries: A copy of the default library tables
function GetLibraries()
	return table.Copy(Libraries)
end

--- Get Containers.
-- Gets the direct list of containers that luabox currently has registered.
-- Be careful with how you change data in this table, unintended results could occur
--@return Containers: Direct table containing the containers.
function GetContainers()
	return Containers
end

--- Remove Container.
-- Removes a container from the luabox list of containers, removing it from the execution stack.
-- You can also remove a container by calling Container:Remove()
--@param container
function RemoveContainer( container )
	if type( container ) == "number" then
		Containers[ container ] = nil
	elseif type( container ) == "table" and container.Remove then
		container:Remove()
	end
end

--- Class Creator.
-- Creates a basic class template and returns it to be used for further editing and extending.
-- Supports infinite class inheritence.
--@function Class
--@param base The baseclass for the newly created class to inherit from.
--@return class Returns the new class template to be edited.
function Class( base )
	local class = { -- a new class metatable
		base = base
	}
	class.__index = class

	local classmt = { -- the new classes' meta table, this allows inheritence if the class has a base, and lets you create a new instance with <classname>()
		__index = base
	}

	classmt.__call = function( class , ... ) -- expose a constructor which can be called by <classname>(<args>)
		local obj = {} -- new instance of the class to be manipulated.
		setmetatable( obj , class )

		if class.Initialize then
			class.Initialize( obj , ... )
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
			AddCSLuaFile("luabox/libraries/" .. File )
		end

		--local library =
		Library( "luabox/libraries/" .. File )

		--librarymeta.__newindex = function(self,k,v)
		--	library.Functions[k] = v
		--end

		--library:SetTemplate(CompileFile("luabox/libraries/" .. File ) )

	end
end


--- Library Class
--@section Library
Library = Class()

--- Library Class Constructor.
-- Holds basic function templates which are abstracted to work per player.
--@param file file to load for the library
function Library:Initialize( file )
	print()
	self.Path = file
	self.Name = string.StripExtension( string.GetFileFromFilename( file ) ) or tostring(self)

	self:SetTemplateFile( file )

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

--- Set Template File.
-- Sets the library template, this template is a function, that when called, creates a library of functions specific to players (I.E those players permissions to entities, hooks, etc)
--@param func function template, Typically an entire lua file (as files are just functions which are executed once)
function Library:SetTemplateFile( name )
	if file.Exists( name , "LUA" ) then
		self:SetTemplate( CompileFile( name ) )
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

--- Get Path.
-- Gets the Path of the library
--@return Library Path
function Library:GetPath()
	return self.Path
end

--- Set Path.
-- sets the Path of the library
--@param Path New Path
function Library:SetPath( path )
	self.Path = path
end



--- Environment Class
--@section Environment
Environment = Class()

--- Environment Class Constructor.
-- Creates an environment class which holds one lua environment. This includes variables and player specific functions.
function Environment:Initialize()
	self.RemoveHooks = {}

	self:SetEnvironment( {} )
end

--- Get Environment.
-- Gets the Environment table of the given Environment class.
--@return Environment: The Environment Table.
function Environment:GetEnvironment()
	return self.Environment
end

--- Set Environment.
-- Sets the environment table of the class to a new table.
--@param env New enviroment to use.
function Environment:SetEnvironment( env )
	self.Environment = env
	self.Environment["_G"] = env
	self.Environment["self"] = {}
end

--- Set Index.
-- Sets the index of the Environment, used by the container class as a means of keeping track of what's what.
--@param index The index number to be set
function Environment:SetIndex( index )
	self.Index = index
end

--- Get Index.
-- Gets the index of the Environment, used by the container class as a means of keeping track of what's what.
--@return Index: The index number of the environment.
function Environment:GetIndex()
	return self.Index
end

--- Call on Remove.
-- Adds a function to be called on remove
--@param name Unique identifier of remove hook
--@param func function to be called
function Environment:CallOnRemove( name , func )
	self.RemoveHooks[ name ] = func
end

--- Remove.
-- Removes all references on the self table.
function Environment:Remove()

	for name , func in pairs( self.RemoveHooks ) do
		local err , msg  = pcall( func )
		if not err then
			print( "Unloading function: ''" .. name .. "'' Failed with error:" , msg )
		end
	end

	for key , val in pairs( self ) do
		self[key] = nil
	end
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

--- Get Function.
-- Gets the scripts sandboxed function.
function Script:GetFunction()
	return self.Function
end

--- Get Environment.
-- Returns the environment object the script is using.
--@return Environment.
function Script:GetEnvironment()
	return self.Environment
end

--- Set Environment.
-- Sets the environment onject for the script to use.
--@param environment The environment object.
function Script:SetEnvironment( environment )
	self.Environment = environment
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

--- Execute.
-- Executes the script, each script should only be executed once.
-- todo: better error handling.
function Script:Execute()
	return pcall( self.Function )
end

--- Set Index.
-- Sets the index of the Script, used by the container class as a means of keeping track of what's what.
--@param index The index number to be set
function Script:SetIndex( index )
	self.Index = index
end

--- Get Index.
-- Gets the index of the Script, used by the container class as a means of keeping track of what's what.
--@return Index: The index number of the Script.
function Script:GetIndex()
	return self.Index
end

--- Remove.
-- Removes all references on the self table.
function Script:Remove()
	for key , val in pairs( self ) do
		self[key] = nil
	end
end





--- Networker Class.
--@section Networker
Networker = Class()	-- In charge of networking all of a players needs

--- Networker Class Constructor.
-- Creates a Networker class instance, Limits network usage so users don't flood the server.
--@param player Player to send it to (if used server side)
function Networker:Initialize( player )
	self.SendBuffer = {}
	self.Receivers = {}
	self.ReceiverTemplates = {}
	self.PooledNames = {}
	self.PooledNum = 0

	self.Player = player
end

--- Set Player.
-- Sets the player object the networker class will send data too (only useful serverside as clients always send to server)
-- Cannot change player while any buffers are open.
--@param player Player to send it to.
function Networker:SetPlayer( player )
	if not player or not IsValid( player ) then error("Invalid Player object",2) return end

	if #self.SendBuffer > 0 then error("Cannot change player while any buffers are still open",2) return end

	self.Player = player
end

--- Get Player.
-- Gets the player object the networker class will send data too (only useful serverside as clients always send to server)
--@return player Player to send it to.
function Networker:GetPlayer( player )
	return self.Player
end


--- Add To Buffer.
-- adds a variable to the send buffer, basically a wrapper for table.insert.
--@param tab Table input to be added to the send buffer
function Networker:AddToBuffer( tab )
	if not self.CurrentBuffer then error("No Current buffer, no message started",2) end

	self.CurrentBuffer.Size = self.CurrentBuffer.Size + tab.Size

	table.insert( self.CurrentBuffer , tab )
end

--- Write Integer.
-- Writes an Integer to the network buffer.
--@param int Integer to send.
function Networker:WriteInteger( int )
	self:AddToBuffer( { net.WriteInt , int , 32 , Size = 4 } )
end

--- Write Unsigned Integer.
-- Writes an unsigned integer to the network buffer.
--@param int Integer to send.
function Networker:WriteUInteger( int )
	self:AddToBuffer( { net.WriteUInt , int , 32 , Size = 4 } )
end

--- Write Number.
-- Writes a Number of a given size in bits to the network buffer.
--@param num Number to be written.
--@param size Size in bits of number.
function Networker:WriteNumber( num , size )
	size = size or 32

	self:AddToBuffer( { net.WriteInt , num , size , Size = size/8 } )
end

--- Write Unsigned Number.
-- Writes an Unsigned Number of a given size in bits to the network buffer.
--@param num Number to be written.
--@param size Size in bits of number.
function Networker:WriteUNumber( num , size )
	size = size or 32

	self:AddToBuffer( { net.WriteUInt , num , size , Size = size/8 } )
end

--- Write Angle.
-- Writes an angle to the network buffer.
--@param ang Angle to send.
function Networker:WriteAngle( ang )
	self:AddToBuffer( { net.WriteAngle , ang , Size = 8 } )
end

--- Write Bit.
-- Writes a bit to the network buffer.
--@param bit Bit to send.
function Networker:WriteBit( bit )
	self:AddToBuffer( { net.WriteBit , bit , Size = 0.125 } )
end

--- Write Bool.
-- Writes a boolean to the network buffer.
--@param bool Boolean to send.
function Networker:WriteBool( bool )
	self:AddToBuffer( { net.WriteBool, bool , Size = 0.125 } )
end

--- Write Color.
-- Writes a color to the network buffer.
--@param col Color object to send.
function Networker:WriteColor( col )
	self:AddToBuffer( { net.WriteColor , col , Size = 4 } )
end

--- Write Data.
-- Writes binary string data to the network buffer.
--@param data Data to send.
function Networker:WriteData( data )
	self:AddToBuffer( { net.WriteData , data , Size = #data } )
end

--- Write Doube.
-- Writes a double to the network buffer.
--@param dbl Double to send.
function Networker:WriteDouble( dbl )
	self:AddToBuffer( { net.WriteDouble , dbl , Size = 8 } )
end

--- Write Entity.
-- Writes an Entity to the network buffer.
--@param ent Entity to send.
function Networker:WriteEntity( ent )
	self:AddToBuffer( { net.WriteEntity , ent , Size = 2 } )
end

--- Write Float.
-- Writes a float to the network buffer.
--@param float Float to send.
function Networker:WriteFloat( float )
	self:AddToBuffer( { net.WriteFloat , float , Size = 4 } )
end

--- Write Normal.
-- Writes a vector normal to the network buffer.
--@param nrm Normal to send
function Networker:WriteNormal( nrm )
	self:AddToBuffer( { net.WriteNormal , nrm , Size = 4 } )
end

--- Write Vector.
-- Writes a Vector to the network buffer.
--@param vec Vector to send.
function Networker:WriteVector( vec )
	self:AddToBuffer( { net.WriteVector , vec , Size = 9 } )
end

--- Write Table.
-- Writes a table to the network buffer. Don't use this often.
--@param tab Table to send.
function Networker:WriteTable( tab )
	self:AddToBuffer( { net.WriteTable , tab , Size = 200 } )
end

--- Write String.
-- Writes a String to the network buffer.
--@param str String to send.
function Networker:WriteString( str )
	if #str <= 250 then --base message is atleast 4 bytes long
		self:AddToBuffer( { net.WriteUInt , 1 , 16 , Size = 2 } )
		self:AddToBuffer( { net.WriteString , str , Size = #str } )
	else
		local chunks = math.ceil( #str / 250 )

		if chunks > 2^16 then error("Net message too large >15.625 Mega Bytes (why on earth do you need a single string this large?)",3) end

		self:AddToBuffer( { net.WriteUInt , chunks , 16 , Size = 2 } )

		for index = 1 , #str , 250 do
			self:AddToBuffer( { net.WriteString , str:sub(index,index + 249) , Size = #(str:sub(index,index + 249)) } )
		end
	end
end

--- Read String.
-- Reads a String from the network buffer.
--@return String.
function Networker:ReadString()
	coroutine.yield()
	local ret , chunks = {} , net.ReadUInt( 16 )

	while chunks >= 1 do
		coroutine.yield()

		table.insert( ret , net.ReadString() )

		chunks = chunks - 1
	end

	return table.concat( ret )
end

--- Read Integer.
-- Reads a signed integer from the network buffer.
--@return Integer.
function Networker:ReadInteger()
	coroutine.yield()

	return net.ReadInt( 32 )
end

--- Read Unsigned Integer.
-- Reads an unsigned integer from the network buffer.
--@return UInteger.
function Networker:ReadUInteger()
	coroutine.yield()

	return net.ReadUInt( 32 )
end

--- Read Number.
-- Reads a Number of a given size in bits from the network buffer.
--@param size Size in bits of number.
--@return Number.
function Networker:ReadNumber( size )
	size = size or 32

	coroutine.yield()

	return net.ReadInt( size )
end

--- Read Unsigned Number.
-- Reads an Unsigned Number of a given size in bits from the network buffer.
--@param size Size in bits of number.
--@return UNumber.
function Networker:ReadUNumber(size )
	size = size or 32

	coroutine.yield()

	return net.ReadUInt( size )
end

--- Read Angle.
-- Reads an angle from the network buffer.
--@return Angle.
function Networker:ReadAngle()
	coroutine.yield()

	return net.ReadAngle()
end

--- Read Bit.
-- Reads a bit from the network buffer.
--@return Bit.
function Networker:ReadBit( )
	coroutine.yield()

	return net.ReadBit()
end

--- Read Bool.
-- Reads a boolean from the network buffer.
--@return Boolean.
function Networker:ReadBool()
	coroutine.yield()

	return net.ReadBool()
end

--- Read Color.
-- Reads a color from the network buffer.
--@return Color.
function Networker:ReadColor()
	coroutine.yield()

	return net.ReadColor()
end

--- Read Data.
-- Reads binary string data from the network buffer.
--@return Data.
function Networker:ReadData()
	coroutine.yield()

	return net.ReadData()
end

--- Read Doube.
-- Reads a double from the network buffer.
--@return Double.
function Networker:ReadDouble()
	coroutine.yield()

	return net.ReadDouble()
end

--- Read Entity.
-- Reads an Entity from the network buffer.
--@return Entity.
function Networker:ReadEntity()
	coroutine.yield()

	return net.ReadEntity()
end

--- Read Float.
-- Reads a float from the network buffer.
--@return Float.
function Networker:ReadFloat()
	coroutine.yield()

	return net.ReadFloat()
end

--- Read Normal.
-- Reads a vector normal from the network buffer.
--@return Normal.
function Networker:ReadNormal()
	coroutine.yield()

	return net.ReadNormal()
end

--- Read Vector.
-- Reads a Vector from the network buffer.
--@return Vector.
function Networker:ReadVector()
	coroutine.yield()

	return net.ReadVector()
end

--- Read Table.
-- Reads a table from the network buffer, Don't use much.
--@param tab Table to send.
function Networker:ReadTable()
	coroutine.yield()

	return net.ReadTable()
end

--- Start Message.
-- Wrapping around net.Start to control resource usage
--@param name Name of the message to be sent
function Networker:Start( name )
	if not name then return end

	identity = self:PoolMessage( name )

	self.CurrentBuffer = self.SendBuffer[ table.insert( self.SendBuffer , { Name = identity, Size = 0 } ) ]
	self.CurrentBuffer.Position = 0
end

--- End Message.
-- Simple wrapper to use the proper net.Send functions depending on server or client
--@param player Optional, Player to send it to, serverside only
function Networker:EndMessage( player )
	player = player or self.Player

	if SERVER then
		net.Send( player )
	elseif CLIENT then
		net.SendToServer()
	end
end

--- Send Batch.
-- Sends a batch of info to the other realm (server to client or client to server).
--@param player optional, defaulted to container owner.
function Networker:SendBatch( player )
	player = player or self.Player

	local curbuffer , size , messages = self.SendBuffer[ 1 ] , 4 , 0

	for msg = 1 , #curbuffer do
		local message = curbuffer[msg + curbuffer.Position ]

		if not message then
			size = size - 256 -- make sure it returns true
			break
		end

		if math.ceil( size + message.Size ) > 256 then
			size = math.ceil( size + message.Size )
			break
		end

		messages = msg
		size = size + message.Size
	end

	net.Start( "luabox_sendmessage" )
		net.WriteUInt( bit.lshift( curbuffer.Name - 1 , 9 ) + ( messages - 1 ) , 32 )

		for msg = 1 , messages do
			local message = curbuffer[ msg + curbuffer.Position ]

			message[ 1 ]( unpack( message , 2 ) )

		end
		curbuffer.Position =  curbuffer.Position + messages

	self:EndMessage()

	return size < 256
end

---Finish Send.
-- Removes the net data from the send buffer.
function Networker:FinishSend()
	table.remove( self.SendBuffer , 1 )
end


function Networker:Send()
	if not self:SendBatch() then
		hook.Add( "Think" , "Luabox_NetworkThink:"..tostring( self ) , function()
			if self.SendBuffer[1] then
				if self:SendBatch() then
					hook.Remove( "Think" , "Luabox_NetworkThink:"..tostring( self ) )

					self:FinishSend()
				end
			end
		end)
	else
		self:FinishSend()
	end

	self.CurrentBuffer = nil
end

function Networker:Receive( name , func )
	if not func or not name then return end

	--name = self:GetPooledIndex( name )

	self.Receivers[ name ] = coroutine.create( func )
	self.ReceiverTemplates[ name ] = func

	self.FirstExecute = true -- Work around for coroutines needing to be resumed once to start their execution, Runs only when a new coroutine hasn't been ran at all.

end


function Networker:ProcessReceiver( name )
	if not name then return end
	local coro = self.Receivers[ name ]

	if self.FirstExecute then
		coroutine.resume( coro )

		self.FirstExecute = false
	end

	coroutine.resume( coro )

	if coroutine.status( coro ) == "dead" then
		self:Receive( name , self.ReceiverTemplates[ name ] )
	end
end

function Networker:PoolMessage( name , index )
	if self.PooledNames[ name ] then return self.PooledNames[ name ] end

	if not index then
		index = self.PooledNum + 1
	end

	--if table.HasValue( self.PooledNames[ name ] , int ) then error("Tried to pool different messages with same identifier" ) end

	self.PooledNames[ index ] = name
	self.PooledNames[ name ] = index

	if SERVER then
		net.Start( "luabox_poolmessagename" )
			net.WriteString( name )
			net.WriteUInt( index , 24 )
		net.Send( self.Player )
	end

	self.PooledNum = index

	return index
end

function Networker:GetPooledName( idx )
	return self.PooledNames [ idx ]
end

if SERVER then
	util.AddNetworkString( "luabox_sendmessage" )
	util.AddNetworkString( "luabox_poolmessagename" )
end

net.Receive( "luabox_sendmessage" , function( length , ply )
	if CLIENT then
		ply = LocalPlayer()
	end

	local networker , info = PlayerContainer( ply ):GetNetworker() , net.ReadUInt(32)

	local identity = bit.rshift( info , 9 ) + 1
	local messages = bit.rshift( bit.lshift( info , 23 ) , 23 ) + 1

	while messages > 0 do
		networker:ProcessReceiver( networker.PooledNames[ identity ] )

		messages = messages - 1
	end
end)

net.Receive( "luabox_poolmessagename" , function( length , ply )
	if CLIENT then
		ply = LocalPlayer()
	end

	local networker , name , poolnum = PlayerContainer( ply ):GetNetworker() , net.ReadString() , net.ReadUInt(24)

	networker.PooledNames[ poolnum ] = name
	networker.PooledNames[ name ] = poolnum
end)




--- Container Class.
--@section Container
Container = Class()	-- Container class is in charge of executing sandbox code and holding the environment, one per player (so far)

--- Container Class Constructor.
-- Creates the container class instance, most users will only need to interface with this class.
--@param player Player object the container is linked to, one container per player
--@param default_libs Defaults libraries to use.
function Container:Initialize( player , default_libs )
	self.Index = table.insert( Containers , self )

	if CLIENT then
		player = LocalPlayer()
	end
	self.Player = player

	self.Networker = Networker( player )

	self.Scripts				=	{} -- since there can be multiple scripts per environment, scripts are stored as keys and environments as the values
	self.Environments			=	{}

	self:SetLibraries( default_libs or GetLibraries() )

	self.ops = 0
	self.OpHook = function(event)
		self.ops = self.ops + 500
		if self.ops > 100000 then
			sethook(nil)
			error("Operations quota exceeded.",2)
		end
	end
end

--- Set Libraries.
-- Sets the list of libraries that the container will use
--@param libraries the list of libraries to use
function Container:SetLibraries( libraries )
	self.Libraries = libraries
end

--- Get Libraries.
-- Gets the list of libraries that the container will use
--@return libraries the list of libraries to use
function Container:GetLibraries()
	return self.Libraries
end

--- Add Functions to Environment.
-- Populates an environment with functions specific to the container owner (player).
-- Uses container specific list of libraries to load from
function Container:AddFunctionsToEnvironment( env )
	local environment = env:GetEnvironment()

	local meta = {
		__index = _G,
		__newindex = function(self,k,v)
			environment[k] = v
		end
	}
	for Name , Library in pairs( self:GetLibraries() ) do

		setfenv( Library:GetTemplate() , setmetatable( {} , meta ) ) ( self , self.Player , env ) --
	end
end

--- Select Environment.
-- Returns an already existing environment object from the containers Environment table
--@param index the index of the environment in the table, starts at 1
--@return Environment: The environment object
function Container:SelectEnvironment( index )
	return self.Environments[ index ]
end

--- Add New Environment.
-- Adds a new environment object to the container object, stores it in the selfEnvironments list.
--@return Environment: The new environment object.
function Container:AddNewEnvironment()
	local env = Environment()

	table.insert( self:GetEnvironments() , env )
	env:SetIndex( #self:GetEnvironments() )

	self:AddFunctionsToEnvironment( env )

	return env
end

--- Get Environments.
-- Returns the environment table.
--@return Environments: The environments table.
function Container:GetEnvironments()
	return self.Environments
end

--- Remove Environment.
-- Removes a specific environment and all associated scripts.
--@param env either the index or the actual environment
function Container:RemoveEnvironment( env )
	env = self:SelectEnvironment( env ) or env

	if type( env ) == "table" and self:SelectEnvironment( env:GetIndex() ) then

		for _ , script in pairs( self:GetScripts() ) do
			if script:GetEnvironment() == env then
				script:Remove()
			end
		end

		table.remove( self:GetEnvironments() , env:GetIndex() )

		env:Remove()
	end
end

--- Select Script.
-- Returns an already existing Script object from the containers script table.
--@param index the index of the script in the table, starts at 1.
--@return Script: The script object.
function Container:SelectScript( index )
	return self.Scripts[ index ]
end

--- Add Script.
-- Adds a new script to the container with it's own new environment by default or an already existing environment with the index parameter.
--@param func Script function.
--@param env OPTIONAL: use an already existing environment.
--@return newscript: The new script object.
function Container:AddScript( func , env )
	if not func then return end
	--if not self:GetEnvironment( envindex ) then return end

	env = env or self:AddNewEnvironment()

	local newscript = Script( env , func )

	table.insert( self:GetScripts() , newscript )
	newscript:SetIndex( #self:GetScripts() )

	return newscript
end

--- Get Scripts.
-- Returns the Scripts table.
--@return Scripts: The scripts table.
function Container:GetScripts()
	return self.Scripts
end

--- Run Scripts.
-- Execute all of the scripts on the container object once.
-- todo: better error checking.
function Container:RunScripts()

	for i = 1 , #self.Scripts do
		local success , msg = self.Scripts[i]:Execute()

		if not success then

			break
		end
	end

end

--- Remove Script.
-- Removes a specific script and all associated scripts.
--@param env either the index or the actual script
function Container:RemoveScript( script )
	script = self:SelectScript( script ) or script

	if type( script ) == "table" and self:SelectScript( script:GetIndex() ) then
		print("iscript")
		table.remove( self:GetScripts() , script:GetIndex() )

		script:Remove()
	end
end

--- Get Owner.
-- Returns the container's owner.
--@return Owner: Owner player object.
function Container:GetOwner()
	return self.Player
end

--- Remove.
-- Removes the container from the master list and therefore execution, cleans up variables nicely and maybe calls the GC.
function Container:Remove()
	for _ , env in pairs( self:GetEnvironments() ) do
		env:Remove()
	end

	for _ , script in pairs( self:GetScripts() ) do
		script:Remove()
	end

	table.remove( Containers , self.Index )
	ContainersLookup[ self:GetOwner() ] = nil


	local mem = collectgarbage( "count" )
	print("c4:",mem)
	for key , val in pairs( self ) do
		self[key] = nil
	end
	local data = collectgarbage( "collect" )
	local meme = collectgarbage( "count" )
	print(data,"c5:",mem - meme)
end

--- Get Networker.
-- Returns the container's networker object.
--@return Networker: Networker object.
function Container:GetNetworker()
	return self.Networker
end

local function infloop_detection_replacement()
	error("Infinite Loop Detected!",2)
end

--- Run Sandbox Function.
-- Runs the sandboxed function you pass it with the arguments you pass it. this assumes the functions you pass it were created in the sandbox
--@param func the function to call
--@param ... varargs to call the function with
function Container:RunSandboxFunction( func , ... )
	self.ops = 0

	sethook(self.OpHook,"",500)
	local rt = {pcall( func , ... )}
	sethook(nil)

	return rt
end

if not luabox.HookCall then
	luabox.HookCall = hook.Call
end
local times = 0
local env , container , retvalues
local hooke = {}
hooke.Call = function( name, gm, ... )
	--arg = { ... }
	--print("too much")
	for i = 1 , #Containers do
		container = Containers[i]

		for o = 1 , #container.Environments do
			env = container.Environments[o].Environment.self

			if env[name] then
				--print("trying")
				retvalues = container:RunSandboxFunction( env[name] , env , ... )--{ pcall( env[name] , env , ... ) }


				if ( retvalues[1] and retvalues[2] != nil ) then

					--table.remove( retvalues, 1 )
					return unpack( retvalues , 2 )
				elseif ( !retvalues[1] ) then
					print("Hook '" .. name .. "' in plugin '" .. "plugin.Title" .. "' failed with error:" )
					--print(unpack(retvalues,2) )
					print(retvalues[2])

					env[name] = nil
				end
			end
		end
	end

	return HookCall( name, gm, ... )
end
LoadLibraries()













function reload()
	Containers = {}
	Libraries = {}
	include("luabox/modules/luabox.lua")
	print("luabox module reloaded")
end


concommand.Add("reload_luabox", function()
	reload()

	for k , ply in pairs(player.GetAll()) do
		ply:SendLua([[luabox.reload()]])
	end
end)
