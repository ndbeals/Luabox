local util = util


module( "luabox.luapack" , function( self )
	return setmetatable( self , { __index = luabox } )
end )


local function writePack( pack )
	if not pack then return end
	pack = util.Compress( util.TableToJSON( pack ) )

	net.WriteUInt( #pack , 32 )
	net.WriteData( pack , #pack )
end

local function readPack( )
	local dataLength = net.ReadUInt( 32 )
	local pack = util.JSONToTable( util.Decompress( net.ReadData( dataLength ) ) )

	return pack
end

local function hashPack( pack )
	if not pack then return "" end
	return util.CRC( table.concat( pack.Checksums ) )
end

local callbacks = {}

Packs = {}

Handlers = {}

---[[
if SERVER then
	util.AddNetworkString( "luabox_requestpack_reply" )
	util.AddNetworkString( "luabox_requestpack" )
	util.AddNetworkString( "luabox_sendpack_requestclientcrc" )
	util.AddNetworkString( "luabox_sendpack_replyclientcrc" )
	util.AddNetworkString( "luabox_sendpack" )


	function RequestLuaPack( player , callback )
		if not player or not callback then
			luabox.ErrorPrint( "No player or callback provided" )
			return
		end

		table.insert( callbacks , callback )

		net.Start( "luabox_requestpack" )
			net.WriteUInt( #callbacks , 16 )
		net.Send( player )

	end

	function SendPackToClient( handler , player , pack  )
		--local packCRC = util.CRC( table.concat( pack.Checksums ) )
		if not pack.ClientSide then return ErrorPrint("No client files in this luabox project") end

		Packs[ pack.ID ] = { Pack = pack , Handler = handler }

		net.Start( "luabox_sendpack_requestclientcrc" )
			net.WriteUInt( pack.ID , 32 )
		net.Send( player )
	end


	net.Receive( "luabox_sendpack_replyclientcrc" , function( length, player )
		local pack = Packs[ net.ReadUInt( 32 ) ]
		local crc = net.ReadString()

		if not pack then return ErrorPrint( "Critical error, somehow a luapack was deleted in between asking a client if it had it and the clietn replying" ) end

		if crc == "" then

			net.Start( "luabox_sendpack" )
				net.WriteString( pack.Handler )
				writePack( pack.Pack )
			net.Send( player )

		elseif crc != hashPack( pack.Pack ) then -- Packs are different, check file hashes now

			for file , hash in ipairs( pack.Pack.Checksums ) do


			end
		end
	end)

	net.Receive( "luabox_requestpack_reply" , function( length , player )
		local id = net.ReadUInt( 16 )
		local success = net.ReadBool()
		local callback = callbacks[ id ]

		if success then
			--local dataLength = net.ReadUInt( 32 )
			local pack = readPack()

			table.remove( callbacks , id )
			callback( pack )

		else

			table.remove( callbacks , id )
			callback( false )

		end

	end)

else

	local function resolveIncludes( pack , filesystem , clientside , dir )
		dir = dir or ""
		clientside = clientside or false


		for i , file in ipairs( filesystem:GetFiles() ) do
			local filedata = { Name = dir .. file:GetName() , Body = file:Read() , Client = clientside }

			local index = table.insert( pack.FileData , filedata )
			table.insert( pack.Checksums , util.CRC( filedata.Body ) )

			if string.lower( file:GetName() ) == "init.lua" or "init.txt" then

				if string.lower( dir ) == "client/" then
					pack.EntryPoints.Client = index
				elseif string.lower( dir ) == "server/" then
					pack.EntryPoints.Server = index
				end
			end
		end


		for i , directory in ipairs( filesystem:GetDirectories() ) do

			resolveIncludes( pack ,  directory , clientside , dir .. directory:GetName() .. "/" )

		end

		-- for inc in string.gmatch(  body , "include%s*%(?[%s%p]*([%w./]*)[%s%p]*%)?[%c%s;]*") do
	end


	--- Build Lua Pack
	-- resolves includes (TODO:REQUIREs) in the selected lua file and builds a pack of it to send to the server.
	function BuildLuaPack( mainfile )
		if not mainfile then return false , "No file or directory selected" end

		local pack = {
			FileData = {},
			Checksums = {},
			EntryPoints = {},
			ClientSide = false,
			ID = tonumber( util.CRC( tostring( pack ) ) ),
		}

		if mainfile:GetProjectFile() then
			local projectdir = mainfile:GetProjectFile():GetRootFileSystem()

			for i , file in ipairs( projectdir:GetFiles() ) do
				local filedata = { Name = file:GetName() , Body = file:Read() , Client = true }

				local index = table.insert( pack.FileData , filedata )
				table.insert( pack.Checksums , util.CRC( filedata.Body ) )

				if string.lower( file:GetName() ) == "init.lua" or "init.txt" then
					pack.ClientSide = true
					pack.EntryPoints.Shared = index
				end
			end

			for i , directory in ipairs( projectdir:GetDirectories() ) do

				if string.lower( directory:GetName() ) == "server" then

					resolveIncludes( pack ,  directory , false , "server/" )

				elseif string.lower( directory:GetName() ) == "client" then
					pack.ClientSide = true

					resolveIncludes( pack ,  directory , true , "client/" )

				end
			end

			return true , pack
		else
			if mainfile:GetSingleFile() then
				pack.ClientSide = true

				pack.FileData[ 1 ] = { Name = mainfile:GetName() , Body = mainfile:Read() , Client = true }

				pack.EntryPoints.Shared = 1

				pack.Checksums[ 1 ] = util.CRC( pack.FileData[ 1 ].Body )

				return true , pack
			end
		end

		return false , "Directory with no project Selected"
	end


	net.Receive( "luabox_requestpack" , function( length )
		local id = net.ReadUInt( 16 )

		local success , pack = BuildLuaPack( luabox.GetCurrentScript() )

		if success then
			-- pack = util.Compress( util.TableToJSON( pack ) )

			net.Start( "luabox_requestpack_reply" )
				net.WriteUInt( id , 16 )
				net.WriteBool( true )
				writePack( pack )
				-- net.WriteUInt( #pack , 32 )
				-- net.WriteData( pack , #pack )
			net.SendToServer()
		else

			notification.AddLegacy( "Error Building Luapack: " .. pack , NOTIFY_ERROR, 6 )
			surface.PlaySound( "buttons/button10.wav" )

			net.Start( "luabox_requestpack_reply" )
				net.WriteUInt( id , 16 )
				net.WriteBool( false )
				--net.WriteUInt( #pack , 32 )
				--net.WriteData( pack , #pack )
			net.SendToServer()
		end
	end)

	net.Receive( "luabox_sendpack_requestclientcrc" , function( length )
		local id = net.ReadUInt( 32 )
		local crc = ""

		if Packs[ id ] then
			crc = hashPack( pack )
		end

		net.Start( "luabox_sendpack_replyclientcrc" )
			net.WriteUInt( id , 32 )
			net.WriteString( crc )
		net.SendToServer()
	end)

	net.Receive( "luabox_sendpack" , function( length )
		local handler = Handlers[ net.ReadString() ]
		local pack = readPack()

		if not handler then return ErrorPrint( "No handler function provided" ) end
		if not pack then return ErrorPrint( "No Luapack received from server" ) end

		Packs[ pack.ID ] = pack

		handler( pack )

	end)

end

function Receive( handler , func )
	Handlers [ handler ] = func
end


function RunPack( container , pack )
	local env = container:AddNewEnvironment()

	env.LuaPack = pack
	-- pack.Env = env

	local entryPoint = pack.EntryPoints.Shared
	local script

	if entryPoint then
		script = container:AddScript( pack.FileData[entryPoint].Body , env , pack.FileData[entryPoint].Name )

		script:Execute()
	end

	if SERVER then
		entryPoint = pack.EntryPoints.Server

		if entryPoint then
			script = container:AddScript( pack.FileData[entryPoint].Body , env , pack.FileData[entryPoint].Name )

			script:Execute()
		end
	elseif CLIENT then
		entryPoint = pack.EntryPoints.Client

		if entryPoint then
			script = container:AddScript( pack.FileData[entryPoint].Body , env , pack.FileData[entryPoint].Name )

			script:Execute()
		end
	end

	return env
end
