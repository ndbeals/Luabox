local util = util


module( "luabox.luapack" , package.seeall )

local callbacks = {}

---[[
if SERVER then
	util.AddNetworkString( "luabox_requestpack_reply" )
	util.AddNetworkString( "luabox_requestpack" )


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


	net.Receive( "luabox_requestpack_reply" , function( length , player )
		local id = net.ReadUInt( 16 )
		local success = net.ReadBool()
		local callback = callbacks[ id ]

		if success then
			local dataLength = net.ReadUInt( 32 )
			local data = net.ReadData( dataLength )
			local deco = util.Decompress( data )
			print("was success" , dataLength , id , #data  , #deco)
			--print(deco)
			local pack = util.JSONToTable( deco )

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
		}

		if mainfile:GetProjectFile() then
			local projectdir = mainfile:GetProjectFile():GetRootFileSystem()

			for i , file in ipairs( projectdir:GetFiles() ) do
				local filedata = { Name = file:GetName() , Body = file:Read() , Client = true }

				local index = table.insert( pack.FileData , filedata )
				table.insert( pack.Checksums , util.CRC( filedata.Body ) )

				if string.lower( file:GetName() ) == "init.lua" or "init.txt" then
					pack.EntryPoints.Shared = index
				end
			end

			for i , directory in ipairs( projectdir:GetDirectories() ) do
				print(i , directory:GetName())

				if string.lower( directory:GetName() ) == "server" then

					resolveIncludes( pack ,  directory , false , "server/" )

				elseif string.lower( directory:GetName() ) == "client" then

					resolveIncludes( pack ,  directory , true , "client/" )

				end
			end

			return true , pack
		else
			if mainfile:GetSingleFile() then

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
			pack = util.Compress( util.TableToJSON( pack ) )

			local test = util.JSONToTable( util.Decompress( pack ) )
			print(test,#pack)

			net.Start( "luabox_requestpack_reply" )
				net.WriteUInt( id , 16 )
				net.WriteBool( true )
				net.WriteUInt( #pack , 32 )
				net.WriteData( pack , #pack )
			net.SendToServer()
		else

			notification.AddLegacy( "Error building luapack: " .. pack , NOTIFY_ERROR, 6 )
			surface.PlaySound( "buttons/button10.wav" )

			net.Start( "luabox_requestpack_reply" )
				net.WriteUInt( id , 16 )
				net.WriteBool( false )
				--net.WriteUInt( #pack , 32 )
				--net.WriteData( pack , #pack )
			net.SendToServer()
		end
	end)

end


function RunPack( container , env , pack )
	env.LuaPack = pack
	pack.Env = env

	local entryPoint = pack.EntryPoints.Shared
	local script

	if entryPoint then
		script = Container:AddScript( pack.FileData[entryPoint].Body , env , pack.FileData[entryPoint].Name )

		script:Execute()
	end

	if SERVER then
		entryPoint = pack.EntryPoints.Server

		if entryPoint then
			script = Container:AddScript( pack.FileData[entryPoint].Body , env , pack.FileData[entryPoint].Name )

			script:Execute()
		end
	elseif CLIENT then
		entryPoint = pack.EntryPoints.Client

		if entryPoint then
			script = Container:AddScript( pack.FileData[entryPoint].Body , env , pack.FileData[entryPoint].Name )

			script:Execute()
		end
	end
end
