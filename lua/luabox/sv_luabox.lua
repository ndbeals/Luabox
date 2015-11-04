--Copyright 2014 Nathan Beals

util.AddNetworkString("luabox_create_container")

CreateConVar( "sbox_maxluabox_cores" , 4  , {FCVAR_ARCHIVE , FCVAR_NOTIFY , FCVAR_REPLICATED } , "Sets max amount of Luabox Cores" )
