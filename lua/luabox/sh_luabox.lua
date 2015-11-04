--Copyright 2014 Nathan Beals

hook.Add( "OnEntityCreated" , "Luabox_Player_Spawn" ,function( ent )
	if ent:IsPlayer() then
		luabox.PlayerContainer( ent )
	end
end)
