TOOL.Category   = "Luabox"
TOOL.Name       = "Luabox Editor"
TOOL.Command    = nil
TOOL.ConfigName = ""
TOOL.Tab        = "Wire"

TOOL.ClientConVar =
{
	model = "models/foran/luabox/pentium4.mdl"
}
---[[
if CLIENT then
	language.Add ("Tool.luabox_core.name",      "Luabox Editor")
	language.Add ("Tool.luabox_core.desc",      "Spawns and allows editing of a Luabox core")
	language.Add ("Tool.luabox_core.0",         "Primary: Create / update Core, Secondary: Open Core in editor.")

	language.Add ("SBoxLimit_Luabox_cores",      "You've hit the Luabox Core limit!")
	language.Add ("Undone_luabox_core",         "Undone Core")
	language.Add ("Cleanup_luabox_cores",       "Luabox Cores")
	language.Add ("Cleaned_luabox_cores",       "Cleaned up all Luabox Cores.")

	function TOOL.BuildCPanel( pnl )
		local menudef = vgui.RegisterFile( "luabox/ui/toolmenu.lua" )

		local luaboxmenu = vgui.CreateFromTable( menudef )
		pnl:AddPanel( luaboxmenu )

		function RELOADCPANEL()
			local menudef = vgui.RegisterFile( "../addons/Luabox/lua/luabox/ui/toolmenu.lua" )

			print("remenudeved",pnl:GetSize())

			pnl:DockPadding( 0 , 0 , 0 , 0 )


			pnl:Clear()

			local luaboxmenu = vgui.CreateFromTable( menudef )
			pnl:AddPanel( luaboxmenu )

		end
	end
end

cleanup.Register ("luabox_cores")


function TOOL:RightClick (trace,...)
	if CLIENT then return true end

	print(trace,...)

	PrintTable(trace)

	return true
end
