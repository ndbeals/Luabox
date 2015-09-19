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

	local const
	local owner = self:GetOwner()
	local ent = ents.Create( "luabox_core_entity" )
	local min = ent:OBBMins()
	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch + 90

	ent:SetModel( self:GetClientInfo( "model" ) )

	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( ang )
	--ent:SetPlayer( owner )
	ent.Player = pl

	ent:Spawn()

	if IsValid( trace.Entity ) then
		const = constraint.Weld( ent , trace.Entity , 0 , trace.HitBoxBone , 0 , true , true )
	end

	undo.Create( "luabox_core" )
		undo.AddEntity( ent )
		undo.AddEntity( const )
		undo.SetPlayer( owner )
	undo.Finish()

	owner:AddCount( "luabox_cores" , ent )
	owner:AddCleanup( "luabox_cores" , ent )

	return true
end

local function MakeCore( pl , pos , ang , model , test )
	if not pl then pl = game.GetWorld() end

	if IsValid( pl ) and not pl:CheckLimit( "luabox_cores" ) then return false end

	local ent = ents.Create( "luabox_core_entity" )
	if not IsValid( ent ) then return end

	ent:SetModel( model )
	ent:SetPos( pos )
	ent:SetAngles( ang )
	--ent:SetPlayer( pl )
	ent.Player = pl

	ent:Spawn()

	if IsValid( pl ) then
		pl:AddCount( "luabox_cores" , ent )
		pl:AddCleanup( "luabox_cores" , ent )

		undo.Create( "luabox_core" )
			undo.AddEntity( ent )
			undo.SetPlayer( pl )
		undo.Finish()
	end

	return ent
end
duplicator.RegisterEntityClass("luabox_core_entity", MakeCore , "Pos" , "Ang" , "Model" )

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
