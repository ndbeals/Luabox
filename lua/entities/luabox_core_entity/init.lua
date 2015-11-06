AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

end



function ENT:SendPackToClient( pack , client )
	luabox.luapack.SendPackToClient( "luabox_core_entity" .. self:EntIndex() , client , pack )
end

function ENT:SetLuaPack( pack )
	duplicator.StoreEntityModifier( self , "luabox_luapack" , pack )
	self.LuaPack = pack
end


local function makeCore( player , pos , ang , model , data )
	if not data.EntityMods.luabox_luapack then
		luabox.ErrorPrint( "No Lua Pack attached to this duplication" )
		return
	end

	PrintTable(data)

	print(Entity(data.EntityMods.luabox_ent_link.Ent))

	local ent = ents.Create( "luabox_core_entity" )

	ent:SetLuaboxPlayer( player )

	ent:SetPos( pos )
	ent:SetAngles( ang )
	ent:SetModel( model )

	ent:Spawn()

	ent:RunLuaPack( data.EntityMods.luabox_luapack )
	ent:SendPackToClient( data.EntityMods.luabox_luapack , player)

	return ent
end

duplicator.RegisterEntityClass( "luabox_core_entity" , makeCore , "Pos" , "Ang" , "Model" , "Data" )

function luabox.CreateCore( player , model )
	local ent = ents.Create( "luabox_core_entity" )

	ent:SetLuaboxPlayer( player )

	ent:SetModel( model )

	return ent
end




function ENT:SetScript( script )
	self.Container:AddScript( script )

	self.Container:RunScripts()
end
