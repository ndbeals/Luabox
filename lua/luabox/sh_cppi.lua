--Copyright 2014 Nathan Beals

if CPPI then --check cppi if it exists

    --- Get Owner.
    -- Gets the CPPI owner of the entity
    --@param entity Entity to check
    --@return owner Player owner
    function luabox.GetOwner( entity )
        if not IsValid( entity ) then return end
        local owner = entity:CPPIGetOwner( )

        if not IsValid( owner ) then return end

        return owner
    end

    --- Is Owner.
    -- Checks if a player is the CPPI owner of an entity
    --@param entity entity to check if player is the owner off
    --@param player player entity to check if it's the owner
    --@return boolean IS owner
    function luabox.IsOwner( entity, player )
        if not IsValid( entity ) or not IsValid( player ) then return false end

        local owner = entity:CPPIGetOwner( )

        return IsValid( owner ) and owner == player
    end

    --- Is Friend.
    -- Checks if a player is the CPPI friend of another player
    --@param friend player entity to check if he's a friend
    --@param player player entity to check if it's the owner
    --@return boolean IS friend
    function luabox.IsFriend( friend, player )
        if not IsValid( friend ) or not IsValid( player ) then return false end

        if friend == player then return true end

        local friends = player:CPPIGetFriends( )

        if type( friends ) == "table" then
            for _, _friend in pairs( friends ) do
                if _friend == friend then return true end
            end
        end
        return false
    end

    --- Can Use.
    -- Checks if a player can use an entity
    --@param player player entity to check if it can use the entity
    --@param entity entity to check if player can manipulate
    --@return boolean Can Manipulate
    function luabox.CanUse( player , entity )
        if not IsValid( entity ) or not IsValid( player ) then return false end

        return luabox.IsFriend( player , luabox.GetOwner( entity ) )
    end

    else -- if no CPPI then just allow everything


    function luabox.GetOwner( ent )
        return ent
    end

    function luabox.IsOwner()
        return true
    end

    function luabox.IsFriend()
        return true
    end

    function luabox.CanUse()
        return true
    end
end
