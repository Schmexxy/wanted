---- Wanted

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_msgstack.lua")
AddCSLuaFile("cl_hudpickup.lua")
AddCSLuaFile("cl_keys.lua")
AddCSLuaFile("cl_wepswitch.lua")
AddCSLuaFile("cl_popups.lua")
AddCSLuaFile("cl_equip.lua")
AddCSLuaFile("equip_items_shd.lua")
AddCSLuaFile("cl_help.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_voice.lua")
AddCSLuaFile("util.lua")
AddCSLuaFile("lang_shd.lua")
AddCSLuaFile("corpse_shd.lua")
AddCSLuaFile("player_ext_shd.lua")
AddCSLuaFile("weaponry_shd.lua")
AddCSLuaFile("playermodels.lua")
AddCSLuaFile("cl_targetid.lua")
AddCSLuaFile("vgui/ColoredBox.lua")
AddCSLuaFile("vgui/SimpleIcon.lua")
AddCSLuaFile("vgui/ProgressBar.lua")
AddCSLuaFile("vgui/ScrollLabel.lua")
AddCSLuaFile("vgui/sb_main.lua")
AddCSLuaFile("vgui/sb_row.lua")
AddCSLuaFile("vgui/sb_team.lua")
AddCSLuaFile("vgui/sb_info.lua")

include("shared.lua")

include("entity.lua")
include("admin.lua")
include("traitor_state.lua")
include("propspec.lua")
include("weaponry.lua")
include("gamemsg.lua")
include("ent_replace.lua")
include("corpse.lua")
include("player_ext_shd.lua")
include("player_ext.lua")
include("player.lua")

-- sets variable 'playermodels'
include("playermodels.lua")

CreateConVar("wntd_roundtime_minutes", "30", FCVAR_NOTIFY)
CreateConVar("wntd_preptime_seconds", "30", FCVAR_NOTIFY)
CreateConVar("wntd_posttime_seconds", "30", FCVAR_NOTIFY)
CreateConVar("wntd_firstpreptime", "60")

local wntd_haste = CreateConVar("wntd_haste", "1", FCVAR_NOTIFY)
CreateConVar("wntd_haste_starting_minutes", "5", FCVAR_NOTIFY)
CreateConVar("wntd_haste_minutes_per_death", "0.5", FCVAR_NOTIFY)

CreateConVar("wntd_spawn_wave_interval", "0")

CreateConVar("wntd_traitor_pct", "0.25")
CreateConVar("wntd_traitor_max", "32")

CreateConVar("wntd_detective_pct", "0.13", FCVAR_NOTIFY)
CreateConVar("wntd_detective_max", "32")
CreateConVar("wntd_detective_min_players", "8")


-- Traitor credits
CreateConVar("wntd_credits_starting", "2")
CreateConVar("wntd_credits_award_pct", "0.35")
CreateConVar("wntd_credits_award_size", "1")
CreateConVar("wntd_credits_award_repeat", "1")
CreateConVar("wntd_credits_detectivekill", "1")

CreateConVar("wntd_credits_alonebonus", "1")

-- Detective credits
CreateConVar("wntd_det_credits_starting", "1")
CreateConVar("wntd_det_credits_traitorkill", "0")
CreateConVar("wntd_det_credits_traitordead", "1")


CreateConVar("wntd_use_weapon_spawn_scripts", "1")
CreateConVar("wntd_weapon_spawn_count", "0")

CreateConVar("wntd_round_limit", "6", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED)
CreateConVar("wntd_time_limit_minutes", "75", FCVAR_NOTIFY + FCVAR_REPLICATED)

CreateConVar("wntd_idle_limit", "180", FCVAR_NOTIFY)

CreateConVar("wntd_voice_drain", "0", FCVAR_NOTIFY)
CreateConVar("wntd_voice_drain_normal", "0.2", FCVAR_NOTIFY)
CreateConVar("wntd_voice_drain_admin", "0.05", FCVAR_NOTIFY)
CreateConVar("wntd_voice_drain_recharge", "0.05", FCVAR_NOTIFY)

CreateConVar("wntd_namechange_kick", "1", FCVAR_NOTIFY)
CreateConVar("wntd_namechange_bantime", "10")

local wntd_detective = CreateConVar("wntd_sherlock_mode", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY)
local wntd_minply = CreateConVar("wntd_minimum_players", "2", FCVAR_ARCHIVE + FCVAR_NOTIFY)

-- debuggery
local wntd_dbgwin = CreateConVar("wntd_debug_preventwin", "0")

-- Localise stuff we use often. It's like Lua go-faster stripes.
local math = math
local table = table
local net = net
local player = player
local timer = timer
local util = util

-- Pool some network names.
util.AddNetworkString("WNTD_AssignedPlayer")
util.AddNetworkString("WNTD_WonPlayers")
util.AddNetworkString("WNTD_WonScore")
util.AddNetworkString("WNTD_RoundState")
util.AddNetworkString("WNTD_GameMsg")
util.AddNetworkString("WNTD_GameMsgColor")
util.AddNetworkString("WNTD_RoleChat")
util.AddNetworkString("WNTD_TraitorVoiceState")
util.AddNetworkString("WNTD_LastWordsMsg")
util.AddNetworkString("WNTD_RadioMsg")
util.AddNetworkString("WNTD_ReportStream")
util.AddNetworkString("WNTD_LangMsg")
util.AddNetworkString("WNTD_ServerLang")
util.AddNetworkString("WNTD_Equipment")
util.AddNetworkString("WNTD_Credits")
util.AddNetworkString("WNTD_Bought")
util.AddNetworkString("WNTD_BoughtItem")
util.AddNetworkString("WNTD_PlayerSpawned")
util.AddNetworkString("WNTD_PlayerDied")
util.AddNetworkString("WNTD_CorpseCall")
util.AddNetworkString("WNTD_ClearClientState")
util.AddNetworkString("WNTD_PerformGesture")
util.AddNetworkString("WNTD_Role")
util.AddNetworkString("WNTD_RoleList")
util.AddNetworkString("WNTD_ConfirmUseTButton")
util.AddNetworkString("WNTD_C4Config")
util.AddNetworkString("WNTD_C4DisarmResult")
util.AddNetworkString("WNTD_C4Warn")
util.AddNetworkString("WNTD_ShowPrints")
util.AddNetworkString("WNTD_ScanResult")
util.AddNetworkString("WNTD_FlareScorch")

---- Round mechanics
function GM:Initialize()
	MsgN("Wanted gamemode initializing...")
	ShowVersion()

	-- Force friendly fire to be enabled. If it is off, we do not get lag compensation.
	RunConsoleCommand("mp_friendlyfire", "1")

	-- Default crowbar unlocking settings, may be overridden by config entity
	GAMEMODE.crowbar_unlocks = {
		[OPEN_DOOR] = true,
		[OPEN_ROT] = true,
		[OPEN_BUT] = true,
		[OPEN_NOTOGGLE]= true
	};

	-- More map config ent defaults
	GAMEMODE.force_plymodel = ""
	GAMEMODE.propspec_allow_named = true

	GAMEMODE.MapWin = WIN_NONE
	GAMEMODE.AwardedCredits = false
	GAMEMODE.AwardedCreditsDead = 0

	GAMEMODE.round_state = ROUND_WAIT
	GAMEMODE.FirstRound = true
	GAMEMODE.RoundStartTime = 0

	GAMEMODE.LastRole = {}
	GAMEMODE.AssignedPlayer = {}
	GAMEMODE.playercolor = COLOR_WHITE

	GAMEMODE.playermodels = playermodels

	-- Delay reading of cvars until config has definitely loaded
	GAMEMODE.cvar_init = false

	SetGlobalFloat("wntd_round_end", -1)
	SetGlobalFloat("wntd_haste_end", -1)

	-- For the paranoid
	math.randomseed(os.time())

	WaitForPlayers()

	if cvars.Number("sv_alltalk", 0) > 0 then
		ErrorNoHalt("WANTED WARNING: sv_alltalk is enabled. Dead players will be able to talk to living players. WNTD will now attempt to set sv_alltalk 0.\n")
		RunConsoleCommand("sv_alltalk", "0")
	end

	local cstrike = false
	for _, g in pairs(engine.GetGames()) do
		if g.folder == 'cstrike' then cstrike = true end
	end
	if not cstrike then
		ErrorNoHalt("WANTED WARNING: CS:S does not appear to be mounted by GMod. Things may break in strange ways. Server admin? Check the WNTD readme for help.\n")
	end
end

-- Used to do this in Initialize, but server cfg has not always run yet by that
-- point.
function GM:InitCvars()
	MsgN("Wanted initializing convar settings...")

	-- Initialize game state that is synced with client
	SetGlobalInt("wntd_rounds_left", GetConVar("wntd_round_limit"):GetInt())
	GAMEMODE:SyncGlobals()

	self.cvar_init = true
end

function GM:InitPostEntity()
	WEPS.ForcePrecache()
end

function GM:GetGameDescription() return self.Name end

-- Convar replication is broken in gmod, so we do this.
-- I don't like it any more than you do, dear reader.
function GM:SyncGlobals()
	SetGlobalBool("wntd_detective", wntd_detective:GetBool())
	SetGlobalBool("wntd_haste", wntd_haste:GetBool())
	SetGlobalInt("wntd_time_limit_minutes", GetConVar("wntd_time_limit_minutes"):GetInt())
	SetGlobalBool("wntd_highlight_admins", GetConVar("wntd_highlight_admins"):GetBool())
	SetGlobalBool("wntd_locational_voice", GetConVar("wntd_locational_voice"):GetBool())
	SetGlobalInt("wntd_idle_limit", GetConVar("wntd_idle_limit"):GetInt())

	SetGlobalBool("wntd_voice_drain", GetConVar("wntd_voice_drain"):GetBool())
	SetGlobalFloat("wntd_voice_drain_normal", GetConVar("wntd_voice_drain_normal"):GetFloat())
	SetGlobalFloat("wntd_voice_drain_admin", GetConVar("wntd_voice_drain_admin"):GetFloat())
	SetGlobalFloat("wntd_voice_drain_recharge", GetConVar("wntd_voice_drain_recharge"):GetFloat())
end

function SendRoundState(state, ply)
	net.Start("WNTD_RoundState")
		net.WriteUInt(state, 3)
	return ply and net.Send(ply) or net.Broadcast()
end

function SendWonPlayers(players)
	net.Start("WNTD_WonPlayers")
		net.WriteTable(players)
	return ply and net.Send(ply) or net.Broadcast()
end

function SendWonScore(score)
	net.Start("WNTD_WonScore")
		net.WriteUInt(score, 3)
	return ply and net.Send(ply) or net.Broadcast()
end

-- Round state is encapsulated by set/get so that it can easily be changed to
-- eg. a networked var if this proves more convenient
function SetRoundState(state)
	GAMEMODE.round_state = state
	SendRoundState(state)
end

function GetRoundState()
	return GAMEMODE.round_state
end

local function EnoughPlayers()
	local ready = 0
	-- only count truly available players, ie. no forced specs
	for _, ply in pairs(player.GetAll()) do
		if IsValid(ply) and ply:ShouldSpawn() then
			ready = ready + 1
		end
	end
	return ready >= wntd_minply:GetInt()
end

-- Used to be in Think/Tick, now in a timer
function WaitingForPlayersChecker()
	if GetRoundState() == ROUND_WAIT then
		if EnoughPlayers() then
			timer.Create("wait2prep", 1, 1, PrepareRound)

			timer.Stop("waitingforply")
		end
	end
end

-- Start waiting for players
function WaitForPlayers()
	SetRoundState(ROUND_WAIT)

	if not timer.Start("waitingforply") then
		timer.Create("waitingforply", 2, 0, WaitingForPlayersChecker)
	end
end

-- When a player initially spawns after mapload, everything is a bit strange;
-- just making him spectator for some reason does not work right. Therefore,
-- we regularly check for these broken spectators while we wait for players
-- and immediately fix them.
function FixSpectators()
	for k, ply in pairs(player.GetAll()) do
		if ply:IsSpec() and not ply:GetRagdollSpec() and ply:GetMoveType() < MOVETYPE_NOCLIP then
			ply:Spectate(OBS_MODE_ROAMING)
		end
	end
end

-- Used to be in think, now a timer
local function WinChecker()
	if GetRoundState() == ROUND_ACTIVE then
		if CurTime() > GetGlobalFloat("wntd_round_end", 0) then
			EndRound(WIN_TIMELIMIT)
		end
	end
end

local function NameChangeKick()
	if not GetConVar("wntd_namechange_kick"):GetBool() then
		timer.Remove("namecheck")
		return
	end

	if GetRoundState() == ROUND_ACTIVE then
		for _, ply in pairs(player.GetHumans()) do
			if ply.spawn_nick then
				if ply.has_spawned and ply.spawn_nick != ply:Nick() then
					local t = GetConVar("wntd_namechange_bantime"):GetInt()
					local msg = "Changed name during a round"
					if t > 0 then
						ply:KickBan(t, msg)
					else
						ply:Kick(msg)
					end
				end
			else
				ply.spawn_nick = ply:Nick()
			end
		end
	end
end

function StartNameChangeChecks()
	if not GetConVar("wntd_namechange_kick"):GetBool() then return end

	-- bring nicks up to date, may have been changed during prep/post
	for _, ply in pairs(player.GetAll()) do
		ply.spawn_nick = ply:Nick()
	end

	if not timer.Exists("namecheck") then
		timer.Create("namecheck", 3, 0, NameChangeKick)
	end
end

function StartWinChecks()
	if not timer.Start("winchecker") then
		timer.Create("winchecker", 1, 0, WinChecker)
	end
end

function StopWinChecks()
	timer.Stop("winchecker")
end

local function CleanUp()
	local et = ents.WNTD
	-- if we are going to import entities, it's no use replacing HL2DM ones as
	-- soon as they spawn, because they'll be removed anyway
	et.SetReplaceChecking(not et.CanImportEntities(game.GetMap()))

	et.FixParentedPreCleanup()

	game.CleanUpMap()

	et.FixParentedPostCleanup()

	-- Strip players now, so that their weapons are not seen by ReplaceEntities
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) then
			v:StripWeapons()
		end
	end

	-- Set all player models to available
	ResetPlayerModels()

	-- a different kind of cleanup
	util.SafeRemoveHook("PlayerSay", "ULXMeCheck")
end

local function SpawnEntities()
	local et = ents.WNTD
	-- Spawn weapons from script if there is one
	local import = et.CanImportEntities(game.GetMap())

	if import then
		et.ProcessImportScript(game.GetMap())
	else
		-- Replace HL2DM/ZM ammo/weps with our own
		et.ReplaceEntities()

		-- Populate CS:S/TF2 maps with extra guns
		et.PlaceExtraWeapons()
	end

	-- Finally, get players in there
	SpawnWillingPlayers()
end


local function StopRoundTimers()
	-- remove all timers
	timer.Stop("wait2prep")
	timer.Stop("prep2begin")
	timer.Stop("end2begin")
	timer.Stop("winchecker")
end

-- Make sure we have the players to do a round, people can leave during our
-- preparations so we'll call this numerous times
local function CheckForAbort()
	if not EnoughPlayers() then
		LANG.Msg("round_minplayers")
		StopRoundTimers()

		WaitForPlayers()
		return true
	end

	return false
end

function GM:WNTDDelayRoundStartForVote()
	-- Can be used for custom voting systems
	--return true, 30
	return false
end

function ResetPlayerVars()
	for k, ply in pairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() then
			ply:SetFrags(0)
			ply:SetDeaths(0)
		end
	end
end

function PrepareRound()
	-- Check playercount
	if CheckForAbort() then return end

	local delay_round, delay_length = hook.Call("WNTDDelayRoundStartForVote", GAMEMODE)

	if delay_round then
		delay_length = delay_length or 30

		LANG.Msg("round_voting", {num = delay_length})

		timer.Create("delayedprep", delay_length, 1, PrepareRound)
		return
	end

	-- Cleanup
	CleanUp()

	GAMEMODE.MapWin = WIN_NONE
	GAMEMODE.AwardedCredits = false
	GAMEMODE.AwardedCreditsDead = 0
	GAMEMODE.AssignedPlayer = {}

	-- Set everyone's score/deaths to 0
	ResetPlayerVars()

	if CheckForAbort() then return end

	-- Schedule round start
	local ptime = GetConVar("wntd_preptime_seconds"):GetInt()
	if GAMEMODE.FirstRound then
		ptime = GetConVar("wntd_firstpreptime"):GetInt()
		GAMEMODE.FirstRound = false
	end

	-- Piggyback on "round end" time global var to show end of phase timer
	SetRoundEnd(CurTime() + ptime)

	timer.Create("prep2begin", ptime, 1, BeginRound)

	-- Mute for a second around traitor selection, to counter a dumb exploit
	-- related to traitor's mics cutting off for a second when they're selected.
	timer.Create("selectmute", ptime - 1, 1, function() MuteForRestart(true) end)

	LANG.Msg("round_begintime", {num = ptime})
	SetRoundState(ROUND_PREP)

	-- Delay spawning until next frame to avoid ent overload
	timer.Simple(0.01, SpawnEntities)

	-- Undo the roundrestart mute, though they will once again be muted for the
	-- selectmute timer.
	timer.Create("restartmute", 1, 1, function() MuteForRestart(false) end)

	net.Start("WNTD_ClearClientState") net.Broadcast()

	-- In case client's cleanup fails, make client set all players to innocent role
	timer.Simple(1, SendRoleReset)

	-- Tell hooks and map we started prep
	hook.Call("WNTDPrepareRound")

	ents.WNTD.TriggerRoundStateOutputs(ROUND_PREP)
end

function SetRoundEnd(endtime)
	SetGlobalFloat("wntd_round_end", endtime)
end

function IncRoundEnd(incr)
	SetRoundEnd(GetGlobalFloat("wntd_round_end", 0) + incr)
end

function SpawnWillingPlayers(dead_only)
	local plys = player.GetAll()
	local wave_delay = GetConVar("wntd_spawn_wave_interval"):GetFloat()

	-- simple method, should make this a case of the other method once that has
	-- been tested.
	if wave_delay <= 0 or dead_only then
		for k, ply in pairs(player.GetAll()) do
			if IsValid(ply) then
				ply:SpawnForRound(dead_only)
			end
		end
	else
		-- wave method
		local num_spawns = #GetSpawnEnts()

		local to_spawn = {}
		for _, ply in RandomPairs(plys) do
			if IsValid(ply) and ply:ShouldSpawn() then
				table.insert(to_spawn, ply)
				GAMEMODE:PlayerSpawnAsSpectator(ply)
			end
		end

		local sfn = function()
			local c = 0
			-- fill the available spawnpoints with players that need
			-- spawning
			while c < num_spawns and #to_spawn > 0 do
				for k, ply in pairs(to_spawn) do
					if IsValid(ply) and ply:SpawnForRound() then
						-- a spawn ent is now occupied
						c = c + 1
					end
					-- Few possible cases:
					-- 1) player has now been spawned
					-- 2) player should remain spectator after all
					-- 3) player has disconnected
					-- In all cases we don't need to spawn them again.
					table.remove(to_spawn, k)

					-- all spawn ents are occupied, so the rest will have
					-- to wait for next wave
					if c >= num_spawns then
						break
					end
				end
			end

			MsgN("Spawned " .. c .. " players in spawn wave.")

			if #to_spawn == 0 then
				timer.Remove("spawnwave")
				MsgN("Spawn waves ending, all players spawned.")
			end
		end

		MsgN("Spawn waves starting.")
		timer.Create("spawnwave", wave_delay, 0, sfn)

		-- already run one wave, which may stop the timer if everyone is spawned
		-- in one go
		sfn()
	end
end

local function InitRoundEndTime()
	-- Init round values
	local endtime = CurTime() + (GetConVar("wntd_roundtime_minutes"):GetInt() * 60)
	if HasteMode() then
		endtime = CurTime() + (GetConVar("wntd_haste_starting_minutes"):GetInt() * 60)
		-- this is a "fake" time shown to innocents, showing the end time if no
		-- one would have been killed, it has no gameplay effect
		SetGlobalFloat("wntd_haste_end", endtime)
	end

	SetRoundEnd(endtime)
end

function BeginRound()
	GAMEMODE:SyncGlobals()

	if CheckForAbort() then return end

	AnnounceVersion()

	InitRoundEndTime()

	if CheckForAbort() then return end

	-- Respawn dumb people who died during prep
	SpawnWillingPlayers(true)

	-- Remove their ragdolls
	ents.WNTD.RemoveRagdolls(true)

	if CheckForAbort() then return end

	-- Select roles
	SelectRoles()

	-- Assign a target to each player
	AssignRandomPlayer()

	SendFullStateUpdate()

	-- Give the StateUpdate messages ample time to arrive
	timer.Simple(2.5, ShowRoundStartPopup)

	-- Start the win condition check timer
	StartWinChecks()
	StartNameChangeChecks()
	timer.Create("selectmute", 1, 1, function() MuteForRestart(false) end)

	GAMEMODE.RoundStartTime = CurTime()

	-- Sound start alarm
	SetRoundState(ROUND_ACTIVE)
	LANG.Msg("round_started")
	ServerLog("Round proper has begun...\n")

	GAMEMODE:UpdatePlayerLoadouts() -- needs to happen when round_active

	hook.Call("WNTDBeginRound")

	ents.WNTD.TriggerRoundStateOutputs(ROUND_BEGIN)
end

function PrintResultMessage(type)
	ServerLog("Round ended.\n")
	local maxScore = 0
	local players = {}
	
	if type == WIN_TIMELIMIT then

		-- Get highest amount of kills
		for k, ply in pairs(player.GetAll()) do
			if IsValid(ply) and ply:Alive() and (not ply:IsSpec()) then
				if ply:Frags() > maxScore then
					maxScore = ply:Frags()
				end
			end
		end

		-- Get players with this amount of kills
		for k, ply in pairs(player.GetAll()) do
			if IsValid(ply) and ply:Alive() and (not ply:IsSpec()) then
				if ply:Frags() == maxScore then
					table.insert(players, ply:Name())
				end
			end
		end

		if maxScore > 0 then
			if #players > 1 then
				LANG.Msg("win_time_draw", { score = maxScore, names = table.concat(players, ", ") })
			else
				LANG.Msg("win_time", { score = maxScore, names = players[1] })
			end
		else
			LANG.Msg("win_time_noscore")
		end
		ServerLog("Result: timelimit reached.\n")
	else
		ServerLog("Result: unknown victory condition!\n")
	end

	SendWonPlayers(players)
	SendWonScore(maxScore)
end

function CheckForMapSwitch()
	-- Check for mapswitch
	local rounds_left = math.max(0, GetGlobalInt("wntd_rounds_left", 6) - 1)
	SetGlobalInt("wntd_rounds_left", rounds_left)

	local time_left = math.max(0, (GetConVar("wntd_time_limit_minutes"):GetInt() * 60) - CurTime())
	local switchmap = false
	local nextmap = string.upper(game.GetMapNext())

	if rounds_left <= 0 then
		LANG.Msg("limit_round", {mapname = nextmap})
		switchmap = true
	elseif time_left <= 0 then
		LANG.Msg("limit_time", {mapname = nextmap})
		switchmap = true
	end

	if switchmap then
		timer.Stop("end2prep")
		timer.Simple(15, game.LoadNextMap)
	else
		LANG.Msg("limit_left", {num = rounds_left,
								time = math.ceil(time_left / 60),
								mapname = nextmap})
	end
end

function EndRound(type)
	PrintResultMessage(type)

	-- first handle round end
	SetRoundState(ROUND_POST)

	local ptime = math.max(5, GetConVar("wntd_posttime_seconds"):GetInt())
	timer.Create("end2prep", ptime, 1, PrepareRound)

	-- Piggyback on "round end" time global var to show end of phase timer
	SetRoundEnd(CurTime() + ptime)

	timer.Create("restartmute", ptime - 1, 1, function() MuteForRestart(true) end)

	-- Stop checking for win
	StopWinChecks()

	-- We may need to start a timer for a mapswitch, or start a vote
	CheckForMapSwitch()

	-- server plugins might want to start a map vote here or something
	-- these hooks are not used by WNTD internally
	hook.Call("WNTDEndRound", GAMEMODE, type)

	ents.WNTD.TriggerRoundStateOutputs(ROUND_POST, type)
end

function GM:MapTriggeredEnd(wintype)
	self.MapWin = wintype
end

function SelectRoles()
	local prev_roles = {
		[ROLE_PLAYER] = {}
	};

	if not GAMEMODE.LastRole then GAMEMODE.LastRole = {} end

	for k,v in pairs(player.GetAll()) do
		-- everyone on the spec team is in specmode
		if IsValid(v) and (not v:IsSpec()) then
			-- save previous role and set player as standard player

			local r = GAMEMODE.LastRole[v:SteamID()] or v:GetRole() or ROLE_PLAYER

			table.insert(prev_roles[r], v)
		end

		v:SetRole(ROLE_PLAYER)
	end

	GAMEMODE.LastRole = {}

	for _, ply in pairs(player.GetAll()) do
		-- initialize credit count for everyone based on their role
		ply:SetDefaultCredits()

		-- store a steamid -> role map
		GAMEMODE.LastRole[ply:SteamID()] = ply:GetRole()
	end
end

function AssignRandomPlayer(playerToAssign)
	local allPlayers = player.GetAll()
	if not GAMEMODE.AssignedPlayer then GAMEMODE.AssignedPlayer = {} end

	-- End the round if there aren't enough players
	if GAMEMODE.round_state == ROUND_ACTIVE then
		if GetPlayerCount() <= GetConVar("wntd_minimum_players"):GetInt() then
			EndRound(WIN_TIMELIMIT)
			SetPlayersAsSpec()
			return
		end
	end

	-- if player has been passed in
	if not playerToAssign then
		-- announce to players
		for k, ply in pairs(player.GetAll()) do
			if IsValid(ply) and ply:Alive() and ply:IsActivePlayer() then
				local randomPlayer = GetRandomPlayer(allPlayers)
			
				-- make sure player isn't assigned themselves
				-- make sure selected player is active
				while (randomPlayer == ply) or (not randomPlayer:IsActivePlayer()) do
					randomPlayer = GetRandomPlayer(allPlayers)
				end

				-- store a steamid -> assignedplayer map
				GAMEMODE.AssignedPlayer[ply] = randomPlayer

				ply:PrintMessage(HUD_PRINTTALK, "You have been assigned a new target!")
				print(ply:Name() .. " > " .. randomPlayer:Name())
				table.RemoveByValue(allPlayers, randomPlayer)
			end
		end
	else
		local randomPlayer = GetRandomPlayer(allPlayers)
			
		-- make sure player isn't assigned themselves
		-- make sure selected player is active
		while randomPlayer == playerToAssign or (not randomPlayer:IsActivePlayer()) do
			randomPlayer = GetRandomPlayer(allPlayers)
		end

		-- store a steamid -> assignedplayer map
		GAMEMODE.AssignedPlayer[playerToAssign] = randomPlayer

		playerToAssign:PrintMessage(HUD_PRINTTALK, "You have been assigned a new target!")
		print(playerToAssign:Name() .. " > " .. randomPlayer:Name())
		table.RemoveByValue(allPlayers, randomPlayer)
	end
	SendAssignedPlayers(GAMEMODE.AssignedPlayer)
end

function SendAssignedPlayers(assigned, ply)
	net.Start("WNTD_AssignedPlayer")
	net.WriteTable(assigned)
	return ply and net.Send(ply) or net.Broadcast()
end

function GetRandomPlayer(players)
	return table.Random(players)
end

local function ForceRoundRestart(ply, command, args)
	-- ply is nil on dedicated server console
	if (not IsValid(ply)) or ply:IsAdmin() or ply:IsSuperAdmin() or cvars.Bool("sv_cheats", 0) then
		LANG.Msg("round_restart")

		StopRoundTimers()

		-- do prep
		PrepareRound()
	else
		ply:PrintMessage(HUD_PRINTCONSOLE, "You must be a GMod Admin or SuperAdmin on the server to use this command, or sv_cheats must be enabled.")
	end
end
concommand.Add("wntd_roundrestart", ForceRoundRestart)

-- Version announce also used in Initialize
function ShowVersion(ply)
	local text = Format("This is Wanted version %s\n", GAMEMODE.Version)
	if IsValid(ply) then
		ply:PrintMessage(HUD_PRINTNOTIFY, text)
	else
		Msg(text)
	end
end
concommand.Add("wntd_version", ShowVersion)

function AnnounceVersion()
	local text = Format("You are playing %s, version %s.\n", GAMEMODE.Name, GAMEMODE.Version)

	-- announce to players
	for k, ply in pairs(player.GetAll()) do
		if IsValid(ply) then
			ply:PrintMessage(HUD_PRINTTALK, text)
		end
	end
end
