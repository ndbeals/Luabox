TOOL.Category   = "Luabox"
TOOL.Name       = "#tool.luabox_core.name"
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

	language.Add ("sboxlimit_luabox_cores",      "You've hit the Luabox Core limit!")
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

	print(self:GetOwner())
	print("aa",self:GetSWEP():CheckLimit( "luabox_cores" ),self:GetOwner():CheckLimit( "luabox_cores" ))
	print(self:GetClientInfo( "model" ))

	--PrintTable(trace)

	return true
end

function TOOL:LeftClick( trace )
	if CLIENT then return true end

	if not self:GetSWEP():CheckLimit( "luabox_cores" ) then return false end

	local owner = self:GetOwner()
	local luaboxCore = luabox.CreateCore( owner  , self:GetClientInfo( "model" ) )
	local min = luaboxCore:OBBMins()
	local pos = trace.HitPos - trace.HitNormal * min.z
	local ang = trace.HitNormal:Angle()

	ang.p = ang.p + 90

	luaboxCore:SetPos( pos )
	luaboxCore:SetAngles( ang )

	luaboxCore:Spawn()

	luabox.luapack.RequestLuaPack( owner , function( pack )
		if pack then

			luaboxCore:RunLuaPack( pack )
			luaboxCore:SendPackToClient( pack , owner )
			duplicator.StoreEntityModifier( luaboxCore , "luabox_test" , pack )
		else

			SafeRemoveEntity( luaboxCore )
		end
	end)



	undo.Create( "luabox_core" )
		undo.AddEntity( luaboxCore )
		if IsValid( trace.Entity ) then
			duplicator.StoreEntityModifier( luaboxCore , "luabox_ent_link" , {Ent = trace.Entity:EntIndex()})
			luaboxCore:CreateLink( "Test" , trace.Entity )
			duplicator.StoreEntityModifier( luaboxCore , "LuaboxLinkInfo" , {Test = trace.Entity:EntIndex()})
			undo.AddEntity( constraint.Weld( luaboxCore , trace.Entity , 0 , trace.HitBoxBone , 0 , true , true ) )
		end
		undo.SetPlayer( owner )
	undo.Finish()

	owner:AddCount( "luabox_cores" , luaboxCore )
	owner:AddCleanup( "luabox_cores" , luaboxCore )

	return true
end


function TOOL:Think()
	local model = self:GetClientInfo( "model" )
	if not IsValid(self.GhostEntity) or self.GhostEntity:GetModel() ~= model then
		if self.GetGhostAngle then -- the tool as a function for getting the proper angle for the ghost
			self:MakeGhostEntity( model, Vector(0,0,0), self:GetGhostAngle(self:GetOwner():GetEyeTrace()) )
		else -- the tool gives a fixed angle to add else use a zero'd angle
			self:MakeGhostEntity( model, Vector(0,0,0), self.GhostAngle or Angle(0,0,0) )
		end
		if IsValid(self.GhostEntity) and CLIENT then self.GhostEntity:SetPredictable(true) end
	end
	self:UpdateGhost( self.GhostEntity )
end

function TOOL:UpdateGhost( ent )
	if not IsValid(ent) then return end

	local trace = self:GetOwner():GetEyeTrace()
	if not trace.Hit then return end

	-- don't draw the ghost if we hit nothing, a player, an npc, the type of device this tool makes, or any class this tool says not to
	if IsValid(trace.Entity) and (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass() == "luabox_core_entity" ) then
		ent:SetNoDraw( true )
		return
	end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( Ang )

	ent:SetNoDraw( false )
end
