--Copyright 2014 Nathan Beals
local container , ply , env = ...
local netc = container:GetNetworker()


table = luabox.CopyTable( table )
string = luabox.CopyTable( string )
math = luabox.CopyTable( math )


CLIENT = CLIENT
SERVER = SERVER

pairs = pairs
Msg = print
MsgN = print
RealTime = RealTime
CurTime = CurTime
tostring = tostring
tonumber = tonumber
IsValid = IsValid
getfenv = getfenv

-- rawget = rawget
-- RestoreCursorPosition = RestoreCursorPosition

TimedCos = TimedCos
istable = istable

-- setfenv = setfenv
-- DeriveGamemode = DeriveGamemode
-- DrawMotionBlur = DrawMotionBlur

-- DermaMenu = DermaMenu

assert = assert

-- AddonMaterial = AddonMaterial
-- GetConVarNumber = GetConVarNumber
next = next
LocalToWorld = LocalToWorld
-- MsgAll = MsgAll
-- JS_Language = JS_Language
STNDRD = STNDRD
-- GetGlobalFloat = GetGlobalFloat
-- Derma_DrawBackgroundBlur = Derma_DrawBackgroundBlur
-- rawset = rawset
-- IncludeCS = IncludeCS
-- EyeVector = EyeVector
-- RunConsoleCommand = RunConsoleCommand
-- LerpVector = LerpVector
-- ChangeTooltip = ChangeTooltip
RealTime = RealTime
pcall = pcall
-- DrawMaterialOverlay = DrawMaterialOverlay
-- CreateConVar = CreateConVar
-- module = module
-- DynamicLight = DynamicLight
-- GetGlobalEntity = GetGlobalEntity
-- GetGlobalBool = GetGlobalBool
-- newproxy = newproxy
-- RenderSuperDoF = RenderSuperDoF
WorldToLocal = WorldToLocal
-- DOF_Start = DOF_Start
-- gcinfo = gcinfo
-- GetConVar = GetConVar
ScrH = ScrH
-- Vector = Vector
-- error = error
-- getmetatable = getmetatable
-- DrawBloom = DrawBloom
-- TextEntryLoseFocus = TextEntryLoseFocus
-- DrawSharpen = DrawSharpen
-- GetGlobalAngle = GetGlobalAngle
ScrW = ScrW
GetRenderTarget = GetRenderTarget
-- CreateClientConVar = CreateClientConVar
AccessorFunc = AccessorFunc
tobool = tobool
-- OrderVectors = OrderVectors
-- Model = Model
SoundDuration = SoundDuration
-- FindMetaTable = FindMetaTable
Format = Format
EyePos = EyePos
NumModelSkins = NumModelSkins
-- ClientsideRagdoll = ClientsideRagdoll
isangle = isangle
tonumber = tonumber
Lerp = Lerp
-- WorkshopFileBase = WorkshopFileBase
RandomPairs = RandomPairs
-- CreateSound = CreateSound
-- AddConsoleCommand = AddConsoleCommand
TypeID = TypeID
-- Angle = Angle
-- SetGlobalAngle = SetGlobalAngle
-- PlaceDecal_delayed = PlaceDecal_delayed
unpack = unpack
-- AddWorldTip = AddWorldTip
-- SetPhysConstraintSystem = SetPhysConstraintSystem
-- CreateContextMenu = CreateContextMenu
-- GetGlobalString = GetGlobalString
isnumber = isnumber
-- CreateSprite = CreateSprite
-- VGUIRect = VGUIRect
-- rawequal = rawequal
GetHostName = GetHostName
-- Derma_Hook = Derma_Hook
-- EndTooltip = EndTooltip
UTIL_IsUselessModel = UTIL_IsUselessModel
-- Label = Label
-- ParticleEffect = ParticleEffect
-- CreateMaterial = CreateMaterial
-- DrawTexturize = DrawTexturize
-- RenderDoF = RenderDoF
-- JS_Utility = JS_Utility
-- RenderStereoscopy = RenderStereoscopy
-- DrawSobel = DrawSobel
ProtectedCall = ProtectedCall
-- DOF_Kill = DOF_Kill
SScale = SScale
-- DrawColorModify = DrawColorModify
-- TauntCamera = TauntCamera
-- SetClipboardText = SetClipboardText
-- Derma_StringRequest = Derma_StringRequest
-- Derma_Query = Derma_Query
-- Derma_Anim = Derma_Anim
-- RegisterDermaMenuForClose = RegisterDermaMenuForClose
ValidPanel = ValidPanel
ScreenScale = ScreenScale
SortedPairsByMemberValue = SortedPairsByMemberValue
SortedPairsByValue = SortedPairsByValue
-- PositionSpawnIcon = PositionSpawnIcon
RealFrameTime = RealFrameTime
-- FindTooltip = FindTooltip
-- RemoveTooltip = RemoveTooltip
VisualizeLayout = VisualizeLayout
-- LerpAngle = LerpAngle
-- GetRenderTargetEx = GetRenderTargetEx
SQLStr = SQLStr
-- RememberCursorPosition = RememberCursorPosition
-- Add_NPC_Class = Add_NPC_Class
Either = Either
-- IsMounted = IsMounted
-- IsFriendEntityName = IsFriendEntityName
-- IsEnemyEntityName = IsEnemyEntityName
TimedSin = TimedSin
IsUselessModel = IsUselessModel
-- SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
IsValid = IsValid
-- Sound = Sound
-- AngleRand = AngleRand
-- VectorRand = VectorRand
-- ClientsideModel = ClientsideModel
xpcall = xpcall
Localize = Localize
-- Derma_Install_Convar_Functions = Derma_Install_Convar_Functions
ErrorNoHalt = ErrorNoHalt
SysTime = SysTime
-- ParticleEmitter = ParticleEmitter
-- Mesh = Mesh
-- RenderAngles = RenderAngles
-- EyeAngles = EyeAngles
-- SavePresets = SavePresets
-- LoadPresets = LoadPresets
-- EmitSound = EmitSound
-- BroadcastLua = BroadcastLua
-- EmitSentence = EmitSentence
-- DrawToyTown = DrawToyTown
-- GetGlobalVector = GetGlobalVector
-- GetGlobalInt = GetGlobalInt
-- GetGlobalVar = GetGlobalVar
-- SetGlobalEntity = SetGlobalEntity
-- SetGlobalVector = SetGlobalVector
-- SetGlobalFloat = SetGlobalFloat
-- SetGlobalInt = SetGlobalInt
-- SetGlobalString = SetGlobalString
-- SetGlobalVar = SetGlobalVar
GetViewEntity = GetViewEntity
-- DOFModeHack = DOFModeHack
IsEntity = IsEntity
-- AddCSLuaFile = AddCSLuaFile
LocalPlayer = LocalPlayer
-- HTTP = HTTP
-- ParticleEffectAttach = ParticleEffectAttach
-- CompileFile = CompileFile
FrameTime = FrameTime
CurTime = CurTime
UnPredictedCurTime = UnPredictedCurTime
ispanel = ispanel
isfunction = isfunction
isbool = isbool
isvector = isvector
-- CompileString = CompileString
-- RunStringEx = RunStringEx
-- ConVarExists = ConVarExists
-- GetConVarString = GetConVarString
-- include = include
MsgN = MsgN
-- DebugInfo = DebugInfo
SortedPairs = SortedPairs
tostring = tostring
-- SetGlobalBool = SetGlobalBool
VGUIFrameTime = VGUIFrameTime
-- RunString = RunString
-- DisableClipping = DisableClipping
-- SendUserMessage = SendUserMessage
-- PrintTable = PrintTable
-- OnModelLoaded = OnModelLoaded
-- FrameNumber = FrameNumber
-- Player = Player
IsFirstTimePredicted = IsFirstTimePredicted
-- getfenv = getfenv
-- Msg = Msg
-- DamageInfo = DamageInfo
select = select
-- Material = Material
-- Derma_Message = Derma_Message
-- Entity = Entity
type = type
-- setmetatable = setmetatable
-- GetHUDPanel = GetHUDPanel
ipairs = ipairs
-- Matrix = Matrix
-- ClientsideScene = ClientsideScene
-- SafeRemoveEntity = SafeRemoveEntity
-- DrawSunbeams = DrawSunbeams
isentity = isentity
-- CloseDermaMenus = CloseDermaMenus
-- pairs = pairs
-- require = require
-- Error = Error
-- PrecacheParticleSystem = PrecacheParticleSystem
-- EffectData = EffectData
isstring = isstring
-- collectgarbage = collectgarbage
-- IsTableOfEntitiesValid = IsTableOfEntitiesValid
-- MsgC = MsgC










local _print = print
function print( ... )
    --_print("I am being called")
    if SERVER then
        local input = {...}

        for key , value in pairs( input ) do
            input[ key ] = tostring( value )
        end

        local str= table.concat( input , "\t" )

        netc:Start( "func_print" )
            netc:WriteString( str )
        netc:Send()
    else
        _print(...)
    end
end
netc:Receive( "func_print" , function()
    _print( netc:ReadString() )
end)

local function printtab( t, indent, done )
	done = done or {}
	indent = indent or 0
	local keys = table.GetKeys( t )
    local send = ""

	table.sort( keys, function( a, b )
		if ( isnumber( a ) and isnumber( b ) ) then return a < b end
		return tostring( a ) < tostring( b )
	end )

	for i = 1, #keys do
		local key = keys[ i ]
		local value = t[ key ]
		send = send .. string.rep( "\t", indent )

		if  ( istable( value ) and not done[ value ] ) then

			done[ value ] = true
            send = send .. tostring( key ) .. ":" .. "\n"
            send = send .. printtab ( value, indent + 2, done )

		else

            send = send ..tostring( key ) .. "\t=\t"
            send = send ..tostring( value ) .. "\n"

		end

	end
    return send
end

local _PrintTable = PrintTable
function PrintTable( t , indent , done )
    if SERVER then
        local send = printtab( t , indent , done )
        netc:Start( "func_printtab" )
            netc:WriteString( send )
        netc:Send()
    else
        _PrintTable( t , indent , done )
    end
end
netc:Receive( "func_printtab" , function()
    Msg( netc:ReadString() )
end)




print("Globals Loaded")
function env:OnRemove()
    print("ON REMOVE: ", self)
end
