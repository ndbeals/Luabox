AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.LuaboxLinks = {}
end

function ENT:SendPackToClient( pack , client )
	luabox.luapack.SendPackToClient( "luabox_core_entity" .. self:EntIndex() , client , pack )
end

function ENT:SetLuaPack( pack )
	duplicator.StoreEntityModifier( self , "luabox_luapack" , pack )
	self.LuaPack = pack
end

function ENT:CreateLink( name , ent )
	self.LuaboxLinks[ name ] = ent
end


local function makeCore( player , pos , ang , model , data )
	if not data.EntityMods.luabox_luapack then
		luabox.ErrorPrint( "No Lua Pack attached to this duplication" )
		return
	end

	local ent = ents.Create( "luabox_core_entity" )

	ent:SetLuaboxPlayer( player )

	ent:SetPos( pos )
	ent:SetAngles( ang )
	ent:SetModel( model )

	ent:Spawn()

	return ent
end

duplicator.RegisterEntityClass( "luabox_core_entity" , makeCore , "Pos" , "Ang" , "Model" , "Data" )

function luabox.CreateCore( player , model )
	local ent = ents.Create( "luabox_core_entity" )

	ent:SetLuaboxPlayer( player )

	ent:SetModel( model )

	return ent
end

if WireLib then -- this code is modified from wiremod (Licensed under Apache 2.0) to work with wire but not depend on it.

	function ENT:BuildWireDupeInfo()
		return WireLib.BuildDupeInfo(self)
	end


	function ENT:PreEntityCopy()
		-- build the DupeInfo table and save it as an entity mod
		local DupeInfo = self:BuildWireDupeInfo()
		if DupeInfo then
			duplicator.StoreEntityModifier(self, "WireDupeInfo", DupeInfo)
		end
	end
end

function ENT:ApplyWireDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo(ply, ent, info, GetEntByID)
end

function ENT:ApplyLuaboxDupeInfo( CreatedEntities )
	local links = self.EntityMods.LuaboxLinkInfo
	if not links then return end

	local newLinks = {}

	for name , entid in pairs( links ) do
		local ent = CreatedEntities[ entid ]

		if IsValid( ent ) then
			newLinks[ name ] = ent
		end
	end

	self.LuaboxLinks = newLinks
end


local function EntityLookup(CreatedEntities)
	return function(id, default)
		if id == nil then return default end
		if id == 0 then return game.GetWorld() end
		local ent = CreatedEntities[id] or (isnumber(id) and ents.GetByIndex(id))
		if IsValid(ent) then return ent else return default end
	end
end


function ENT:PostEntityPaste(player,_,createdEntities)
	-- We manually apply the entity mod here rather than using a
	-- duplicator.RegisterEntityModifier because we need access to the
	-- CreatedEntities table.
	if self.EntityMods and self.EntityMods.WireDupeInfo and WireLib then
		self:ApplyWireDupeInfo(player, self, self.EntityMods.WireDupeInfo, EntityLookup(createdEntities))
	end

	if self.EntityMods and self.EntityMods.LuaboxLinkInfo then
		self:ApplyLuaboxDupeInfo( createdEntities )

	end

	self:RunLuaPack( self.EntityMods.luabox_luapack )
	self:SendPackToClient( self.EntityMods.luabox_luapack , player)
end
