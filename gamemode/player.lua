
---- Player spawning/dying

local math = math
local table = table
local player = player
local timer = timer
local pairs = pairs

CreateConVar("wntd_bots_are_spectators", "0", FCVAR_ARCHIVE)
CreateConVar("wntd_dyingshot", "0")

CreateConVar("wntd_killer_dna_range", "550")
CreateConVar("wntd_killer_dna_basetime", "100")

-- First spawn on the server
function GM:PlayerInitialSpawn( ply )
	if not GAMEMODE.cvar_init then
		GAMEMODE:InitCvars()
	end

	ply:InitialSpawn()

	local rstate = GetRoundState() or ROUND_WAIT
	-- Game has started, tell this guy where the round is at
	if rstate != ROUND_WAIT then
		SendRoundState(rstate, ply)
	end

	-- Handle spec bots
	if ply:IsBot() and GetConVar("wntd_bots_are_spectators"):GetBool() then
		ply:SetTeam(TEAM_SPEC)
		ply:SetForceSpec(true)
	end
end

function GM:PlayerSpawn(ply)
	-- Some spawns may be tilted
	ply:ResetViewRoll()

	-- Clear out stuff like whether we ordered guns or what bomb code we used
	ply:ResetRoundFlags()

	-- latejoiner, send him some info
	if GetRoundState() == ROUND_ACTIVE then
		SendRoundState(GetRoundState(), ply)
	end

	ply.spawn_nick = ply:Nick()
	ply.has_spawned = true

	-- let the client do things on spawn
	net.Start("WNTD_PlayerSpawned")
		net.WriteBit(ply:IsSpec())
	net.Send(ply)

	if ply:IsSpec() then
		ply:StripAll()
		ply:Spectate(OBS_MODE_ROAMING)
		return
	end

	ply:UnSpectate()

	-- ye olde hooks
	hook.Call("PlayerSetModel", GAMEMODE, ply)
	hook.Call("PlayerLoadout", GAMEMODE, ply)
	hook.Call("WNTDPlayerSetColor", GAMEMODE, ply)

	ply:SetupHands()
end

function GM:PlayerSetHandsModel( pl, ent )
	local simplemodel = player_manager.TranslateToPlayerModelName(pl:GetModel())
	local info = player_manager.TranslatePlayerHands(simplemodel)
	if info then
		ent:SetModel(info.model)
		ent:SetSkin(info.skin)
		ent:SetBodyGroups(info.body)
	end
end

function GM:IsSpawnpointSuitable(ply, spwn, force, rigged)
	if not IsValid(ply) or not ply:IsActivePlayer() then return true end
	if not rigged and (not IsValid(spwn) or not spwn:IsInWorld()) then return false end

	-- spwn is normally an ent, but we sometimes use a vector for jury rigged
	-- positions
	local pos = rigged and spwn or spwn:GetPos()

	if not util.IsInWorld(pos) then return false end

	local blocking = ents.FindInBox(pos + Vector( -16, -16, 0 ), pos + Vector( 16, 16, 64 ))

	for k, p in pairs(blocking) do
		if IsValid(p) and p:IsPlayer() and p:IsActivePlayer() and p:Alive() then
			if force then
				p:Kill()
			else
				return false
			end
		end
	end

	return true
end

local SpawnTypes = {"info_player_deathmatch", "info_player_combine",
"info_player_rebel", "info_player_counterterrorist", "info_player_terrorist",
"info_player_axis", "info_player_allies", "gmod_player_start",
"info_player_teamspawn"}

function GetSpawnEnts(shuffled, force_all)
	local tbl = {}
	for k, classname in pairs(SpawnTypes) do
		for _, e in pairs(ents.FindByClass(classname)) do
			if IsValid(e) and (not e.BeingRemoved) then
				table.insert(tbl, e)
			end
		end
	end


	-- Don't use info_player_start unless absolutely necessary, because eg. TF2
	-- uses it for observer starts that are in places where players cannot really
	-- spawn well. At all.
	if force_all or #tbl == 0 then
		for _, e in pairs(ents.FindByClass("info_player_start")) do
			if IsValid(e) and (not e.BeingRemoved) then
				table.insert(tbl, e)
			end
		end
	end

	if shuffled then
		table.Shuffle(tbl)
	end

	return tbl
end

-- Generate points next to and above the spawn that we can test for suitability
local function PointsAroundSpawn(spwn)
	if not IsValid(spwn) then return {} end
	local pos = spwn:GetPos()

	local w, h = 36, 72 -- bit roomier than player hull

	-- all rigged positions
	-- could be done without typing them out, but would take about as much time
	return {
		pos + Vector( w,  0,  0),
		pos + Vector( 0,  w,  0),
		pos + Vector( w,  w,  0),
		pos + Vector(-w,  0,  0),
		pos + Vector( 0, -w,  0),
		pos + Vector(-w, -w,  0),
		pos + Vector(-w,  w,  0),
		pos + Vector( w, -w,  0)
		--pos + Vector( 0,  0,  h) -- just in case we're outside
	};
end

function GM:PlayerSelectSpawn(ply)
	if (not self.SpawnPoints) or (table.Count(self.SpawnPoints) == 0) or (not IsTableOfEntitiesValid(self.SpawnPoints)) then

		self.SpawnPoints = GetSpawnEnts(true, false)

		-- One might think that we have to regenerate our spawnpoint
		-- cache. Otherwise, any rigged spawn entities would not get reused, and
		-- MORE new entities would be made instead. In reality, the map cleanup at
		-- round start will remove our rigged spawns, and we'll have to create new
		-- ones anyway.
	end

	local num = table.Count(self.SpawnPoints)
	if num == 0 then
		Error("No spawn entity found!\n")
		return
	end

	-- Just always shuffle, it's not that costly and should help spawn
	-- randomness.
	table.Shuffle(self.SpawnPoints)

	-- Optimistic attempt: assume there are sufficient spawns for all and one is
	-- free
	for k, spwn in pairs(self.SpawnPoints) do
		if self:IsSpawnpointSuitable(ply, spwn, false) then
			return spwn
		end
	end

	-- That did not work, so now look around spawns
	local picked = nil

	for k, spwn in pairs(self.SpawnPoints) do
		picked = spwn -- just to have something if all else fails

		-- See if we can jury rig a spawn near this one
		local rigged = PointsAroundSpawn(spwn)
		for _, rig in pairs(rigged) do
			if self:IsSpawnpointSuitable(ply, rig, false, true) then
				local rig_spwn = ents.Create("info_player_terrorist")
				if IsValid(rig_spwn) then
					rig_spwn:SetPos(rig)
					rig_spwn:Spawn()

					ErrorNoHalt("WNTD WARNING: Map has too few spawn points, using a rigged spawn for ".. tostring(ply) .. "\n")

					self.HaveRiggedSpawn = true
					return rig_spwn
				end
			end
		end
	end

	-- Last attempt, force one
	for k, spwn in pairs(self.SpawnPoints) do
		if self:IsSpawnpointSuitable(ply, spwn, true) then
			return spwn
		end
	end

	return picked
end

function GM:PlayerSetModel(ply)
	print('Setting model for ' .. ply:Name())
	local mdl = GetRandomPlayerModel()
	util.PrecacheModel(mdl)
	ply:SetModel(mdl)

	-- Always clear color state, may later be changed in WNTDPlayerSetColor
	ply:SetColor(COLOR_WHITE)
end

-- Only active players can use kill cmd
function GM:CanPlayerSuicide(ply)
	return ply:IsActivePlayer()
end

function GM:PlayerSwitchFlashlight(ply, on)
	if not IsValid(ply) then return false end

	-- add the flashlight "effect" here, and then deny the switch
	-- this prevents the sound from playing, fixing the exploit
	-- where weapon sound could be silenced using the flashlight sound
	if (not on) or ply:IsActivePlayer() then
		if on then
			ply:AddEffects(EF_DIMLIGHT)
		else
			ply:RemoveEffects(EF_DIMLIGHT)
		end
	end

	return false
end

function GM:PlayerUse(ply, ent)
	return ply:IsActivePlayer()
end

function GM:KeyPress(ply, key)
	if not IsValid(ply) then return end

	-- Spectator keys
	if ply:IsSpec() and not ply:GetRagdollSpec() then

		if ply.propspec then
			return PROPSPEC.Key(ply, key)
		end

		ply:ResetViewRoll()

		if key == IN_ATTACK then
			-- snap to random guy
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SetEyeAngles(angle_zero) -- After exiting propspec, this could be set to awkward values
			ply:SpectateEntity(nil)

			local alive = util.GetAlivePlayers()

			if #alive < 1 then return end

			local target = table.Random(alive)
			if IsValid(target) then
				ply:SetPos(target:EyePos())
				ply:SetEyeAngles(target:EyeAngles())
			end
		elseif key == IN_ATTACK2 then
			-- spectate either the next guy or a random guy in chase
			local target = util.GetNextAlivePlayer(ply:GetObserverTarget())

			if IsValid(target) then
				ply:Spectate(ply.spec_mode or OBS_MODE_CHASE)
				ply:SpectateEntity(target)
			end
		elseif key == IN_DUCK then
			local pos = ply:GetPos()
			local ang = ply:EyeAngles()

			local target = ply:GetObserverTarget()
			if IsValid(target) and target:IsPlayer() then
				pos = target:EyePos()
				ang = target:EyeAngles()
			end

			-- reset
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SpectateEntity(nil)

			ply:SetPos(pos)
			ply:SetEyeAngles(ang)
			return true
		elseif key == IN_JUMP then
			-- unfuck if you're on a ladder etc
			if not (ply:GetMoveType() == MOVETYPE_NOCLIP) then
				ply:SetMoveType(MOVETYPE_NOCLIP)
			end
		elseif key == IN_RELOAD then
			local tgt = ply:GetObserverTarget()
			if not IsValid(tgt) or not tgt:IsPlayer() then return end

			if not ply.spec_mode or ply.spec_mode == OBS_MODE_CHASE then
				ply.spec_mode = OBS_MODE_IN_EYE
			elseif ply.spec_mode == OBS_MODE_IN_EYE then
				ply.spec_mode = OBS_MODE_CHASE
			end
			-- roam stays roam

			ply:Spectate(ply.spec_mode)
		end
	end

end


function GM:KeyRelease(ply, key)
	if key == IN_USE and IsValid(ply) and ply:IsActivePlayer() then
		-- see if we need to do some custom usekey overriding
		local tr = util.TraceLine({
			start  = ply:GetShootPos(),
			endpos = ply:GetShootPos() + ply:GetAimVector() * 84,
			filter = ply,
			mask   = MASK_SHOT
		});

		if tr.Hit and IsValid(tr.Entity) then
			if tr.Entity.CanUseKey and tr.Entity.UseOverride then
				local phys = tr.Entity:GetPhysicsObject()
				if IsValid(phys) and not phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then
					tr.Entity:UseOverride(ply)
					return true
				else
					-- do nothing, can't +use held objects
					return true
				end
			elseif tr.Entity.player_ragdoll then
				CORPSE.ShowSearch(ply, tr.Entity, (ply:KeyDown(IN_WALK) or ply:KeyDownLast(IN_WALK)))
				return true
			end
		end
	end

end

-- On the client we override +use for specs and use this instead.
local function SpecUseKey(ply, cmd, arg)
	if IsValid(ply) and ply:IsSpec() then
		-- longer range than normal use
		local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 128, ply)
		if tr.Hit and IsValid(tr.Entity) then
			if tr.Entity:IsPlayer() and tr.Entity:IsActive() then
				ply:Spectate(ply.spec_mode or OBS_MODE_CHASE)
				ply:SpectateEntity(tr.Entity)
			else
				PROPSPEC.Target(ply, tr.Entity)
			end
		end
	end
end
concommand.Add("wntd_spec_use", SpecUseKey)

function GM:PlayerDisconnected(ply)
	-- Prevent the disconnecter from being in the resends
	if IsValid(ply) then
		if ply:GetRole() == ROLE_PLAYER and GAMEMODE.round_state == ROUND_ACTIVE then
			-- Reassign the players
			ReassignPlayers(ply, DISCONNECT)
		end

		ply:SetRole(ROLE_NONE)
	end
end

function GetPlayerCount()
	local count = 0
	for _, ply in pairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() and (not ply:IsSpec()) then
			count = count + 1
		end
	end
	return count
end

function SetPlayersAsSpec()
	for _, ply in pairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() and (not ply:IsSpec()) then
			-- Strip all weapons
			ply:StripAll()
			-- Set to specate mode
			ply:SetTeam(TEAM_SPEC)
			ply:Spectate(OBS_MODE_ROAMING)
		end
	end
end

---- Death affairs
local function CreateDeathEffect(ent, marked)
	local pos = ent:GetPos() + Vector(0, 0, 20)

	local jit = 35.0

	local jitter = Vector(math.Rand(-jit, jit), math.Rand(-jit, jit), 0)
	util.PaintDown(pos + jitter, "Blood", ent)

	if marked then
		util.PaintDown(pos, "Cross", ent)
	end
end

local deathsounds = {
	Sound("player/death1.wav"),
	Sound("player/death2.wav"),
	Sound("player/death3.wav"),
	Sound("player/death4.wav"),
	Sound("player/death5.wav"),
	Sound("player/death6.wav"),
	Sound("vo/npc/male01/pain07.wav"),
	Sound("vo/npc/male01/pain08.wav"),
	Sound("vo/npc/male01/pain09.wav"),
	Sound("vo/npc/male01/pain04.wav"),
	Sound("vo/npc/Barney/ba_pain06.wav"),
	Sound("vo/npc/Barney/ba_pain07.wav"),
	Sound("vo/npc/Barney/ba_pain09.wav"),
	Sound("vo/npc/Barney/ba_ohshit03.wav"), --heh
	Sound("vo/npc/Barney/ba_no01.wav"),
	Sound("vo/npc/male01/no02.wav"),
	Sound("hostage/hpain/hpain1.wav"),
	Sound("hostage/hpain/hpain2.wav"),
	Sound("hostage/hpain/hpain3.wav"),
	Sound("hostage/hpain/hpain4.wav"),
	Sound("hostage/hpain/hpain5.wav"),
	Sound("hostage/hpain/hpain6.wav")
};


local function PlayDeathSound(victim)
	if not IsValid(victim) then return end

	sound.Play(table.Random(deathsounds), victim:GetShootPos(), 90, 100)
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	if ply:IsSpec() then return end

	-- Experimental: Fire a last shot if ironsighting and not headshot
	if GetConVar("wntd_dyingshot"):GetBool() then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep.DyingShot and not ply.was_headshot and dmginfo:IsBulletDamage() then
			local fired = wep:DyingShot()
			if fired then
				return
			end
		end

		-- Note that funny things can happen here because we fire a gun while the
		-- player is dead. Specifically, this DoPlayerDeath is run twice for
		-- him. This is ugly, and we have to return the first one to prevent crazy
		-- shit.
	end

	-- Drop all weapons
	for k, wep in pairs(ply:GetWeapons()) do
		WEPS.DropNotifiedWeapon(ply, wep, true) -- with ammo in them
		wep:DampenDrop()
	end

	if IsValid(ply.hat) then
		ply.hat:Drop()
	end

	-- Create ragdoll and hook up marking effects
	local rag = CORPSE.Create(ply, attacker, dmginfo)
	ply.server_ragdoll = rag -- nil if clientside

	CreateDeathEffect(ply, false)

	util.StartBleeding(rag, dmginfo:GetDamage(), 15)

	-- Clear out any weapon or equipment we still have
	ply:StripAll()

	local killwep = util.WeaponFromDamage(dmginfo)

	-- headshots, knife damage, and weapons tagged as silent all prevent death
	-- sound from occurring
	if not (ply.was_headshot or
			  dmginfo:IsDamageType(DMG_SLASH) or
			  (IsValid(killwep) and killwep.IsSilent)) then
		PlayDeathSound(ply)
	end

	-- Only do scoring and assigning new players if round is active
	if not GAMEMODE.round_state == ROUND_ACTIVE then return end

	-- Add a death to the victim
	ply:AddDeaths(1)

	if IsValid(attacker) and attacker:IsPlayer() then
		-- Check if attacker was assigned this player
		if GAMEMODE.AssignedPlayer[attacker] == ply then
			attacker:PrintMessage(HUD_PRINTTALK, "You have successfully killed your target!")
			ply:PrintMessage(HUD_PRINTTALK, "You were killed by your pursuer!")

			-- Add a kill to the attacker
			attacker:AddFrags(1)

			-- Assign a new target
			AssignRandomPlayer(attacker)

		-- check if attacker killed their killer
		elseif GAMEMODE.AssignedPlayer[ply] == attacker then
			attacker:PrintMessage(HUD_PRINTTALK, "You have successfully killed your pursuer!")
			ply:PrintMessage(HUD_PRINTTALK, "You were killed by your target!")
		
			-- Add a kill to the attacker
			attacker:AddFrags(1)
			
		elseif ply == attacker then
			ply:PrintMessage(HUD_PRINTTALK, "You killed yourself!")
			
			-- Reassign other players which were assigned the player
			ReassignPlayers(ply, KILLED_SELF)
		else
			attacker:PrintMessage(HUD_PRINTTALK, "You weren't supposed to kill this person!")
			ply:PrintMessage(HUD_PRINTTALK, "This person wasn't supposed to kill you!")

			-- Remove a kill from the attacker
			attacker:AddFrags(-1)
			
			-- Reassign other players which were assigned the player
			ReassignPlayers(ply, KILLED)
		end
	end

	-- Change their player model
	print('Setting model for ' .. ply:Name())
	local mdl = GetRandomPlayerModel(ply)
	util.PrecacheModel(mdl)
	ply:SetModel(mdl)
end

function ReassignPlayers(ply, state_type)
	-- Edge case where there are no assigned players yet
	-- Typically if there's not enough players to start the round yet
	if not GAMEMODE.AssignedPlayer then return end

	local state = state_type or nil

	for k,v in pairs(GAMEMODE.AssignedPlayer) do
		if v == ply then
			-- Need to assign new player to killer
			timer.Simple(0.1, function()
				-- Alert killer as to why they have been
				-- assigned a new player
				if state_type == KILLED_SELF then
					k:PrintMessage(HUD_PRINTTALK, "Your target killed themselves!")
				elseif state_type == KILLED then
					k:PrintMessage(HUD_PRINTTALK, "Your target was killed!")
				elseif state_type == DISCONNECT then
					k:PrintMessage(HUD_PRINTTALK, "Your target left the game!")
				end

				AssignRandomPlayer(k)
			end)
		end
	end
end

function GM:PlayerDeath(victim, infl, attacker)
	-- Need to delay in order to get correct values :(
	timer.Simple(0.1, function()
		-- If player has been put into spectate mode
		-- then reset their score/deaths
		if victim:IsSpec() then
			victim:SetFrags(0)
			victim:SetDeaths(0)
		else
			-- spawn player
			victim:Extinguish()
			victim:StripAll()
			victim:SetTeam(TEAM_PLAYER)
			victim:Spawn()
		end
	end)
	
	-- tell no one
	self:PlayerSilentDeath(victim)

	net.Start("WNTD_PlayerDied") net.Send(victim)
end

-- kill hl2 beep
function GM:PlayerDeathSound() return true end

function GM:SpectatorThink(ply)
	-- when spectating a ragdoll after death
	if ply:GetRagdollSpec() then
		local to_switch, to_chase, to_roam = 2, 5, 8
		local elapsed = CurTime() - ply.spec_ragdoll_start
		local clicked = ply:KeyPressed(IN_ATTACK)

		-- After first click, go into chase cam, then after another click, to into
		-- roam. If no clicks made, go into chase after X secs, and roam after Y.
		-- Don't switch for a second in case the player was shooting when he died,
		-- this would make him accidentally switch out of ragdoll cam.

		local m = ply:GetObserverMode()
		if (m == OBS_MODE_CHASE and clicked) or elapsed > to_roam then
			-- free roam mode
			ply:SetRagdollSpec(false)
			ply:Spectate(OBS_MODE_ROAMING)

			-- move to spectator spawn if mapper defined any
			local spec_spawns = ents.FindByClass("wntd_spectator_spawn")
			if spec_spawns and #spec_spawns > 0 then
				local spawn = table.Random(spec_spawns)
				ply:SetPos(spawn:GetPos())
				ply:SetEyeAngles(spawn:GetAngles())
			end
		elseif (m == OBS_MODE_IN_EYE and clicked and elapsed > to_switch) or elapsed > to_chase then
			-- start following ragdoll
			ply:Spectate(OBS_MODE_CHASE)
		end

		if not IsValid(ply.server_ragdoll) then ply:SetRagdollSpec(false) end

	-- when roaming and messing with ladders
	elseif ply:GetMoveType() < MOVETYPE_NOCLIP and ply:GetMoveType() > 0 or ply:GetMoveType() == MOVETYPE_LADDER then
		ply:Spectate(OBS_MODE_ROAMING)
	end

	-- when speccing a player
	if ply:GetObserverMode() != OBS_MODE_ROAMING and (not ply.propspec) and (not ply:GetRagdollSpec()) then
		local tgt = ply:GetObserverTarget()
		if IsValid(tgt) and tgt:IsPlayer() then
			if (not tgt:IsActivePlayer()) or (not tgt:Alive()) then
				-- stop speccing as soon as target dies
				ply:Spectate(OBS_MODE_ROAMING)
				ply:SpectateEntity(nil)
			elseif GetRoundState() == ROUND_ACTIVE then
				-- Sync position to target. Uglier than parenting, but unlike
				-- parenting this is less sensitive to breakage: if we are
				-- no longer spectating, we will never sync to their position.
				ply:SetPos(tgt:GetPos())
			end
		end
	end
end

GM.PlayerDeathThink = GM.SpectatorThink

function GM:PlayerTraceAttack(ply, dmginfo, dir, trace)
	if IsValid(ply.hat) and trace.HitGroup == HITGROUP_HEAD then
		ply.hat:Drop(dir)
	end

	ply.hit_trace = trace

	return false
end

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
	ply.was_headshot = false
	-- actual damage scaling
	if hitgroup == HITGROUP_HEAD then
		-- headshot if it was dealt by a bullet
		ply.was_headshot = dmginfo:IsBulletDamage()

		local wep = util.WeaponFromDamage(dmginfo)

		if IsValid(wep) then
			local s = wep:GetHeadshotMultiplier(ply, dmginfo) or 2
			dmginfo:ScaleDamage(s)
		end
	elseif (hitgroup == HITGROUP_LEFTARM or
		hitgroup == HITGROUP_RIGHTARM or
		hitgroup == HITGROUP_LEFTLEG or
		hitgroup == HITGROUP_RIGHTLEG or
		hitgroup == HITGROUP_GEAR ) then
		dmginfo:ScaleDamage(0.55)
	end

	-- Keep ignite-burn damage etc on old levels
	if (dmginfo:IsDamageType(DMG_DIRECT) or
		dmginfo:IsExplosionDamage() or
		dmginfo:IsDamageType(DMG_FALL) or
		dmginfo:IsDamageType(DMG_PHYSGUN)) then
		dmginfo:ScaleDamage(2)
	end
end

-- The GetFallDamage hook does not get called until around 600 speed, which is a
-- rather high drop already. Hence we do our own fall damage handling in
-- OnPlayerHitGround.
function GM:GetFallDamage(ply, speed)
	return 1
end

local fallsounds = {
	Sound("player/damage1.wav"),
	Sound("player/damage2.wav"),
	Sound("player/damage3.wav")
};

function GM:OnPlayerHitGround(ply, in_water, on_floater, speed)
	if in_water or speed < 450 or not IsValid(ply) then return end

	-- Everything over a threshold hurts you, rising exponentially with speed
	local damage = math.pow(0.05 * (speed - 420), 1.75)

	-- I don't know exactly when on_floater is true, but it's probably when
	-- landing on something that is in water.
	if on_floater then damage = damage / 2 end

	-- if we fell on a dude, that hurts (him)
	local ground = ply:GetGroundEntity()
	if IsValid(ground) and ground:IsPlayer() then
		if math.floor(damage) > 0 then
			local att = ply

			-- if the faller was pushed, that person should get attrib
			local push = ply.was_pushed
			if push then
				-- TODO: move push time checking stuff into fn?
				if math.max(push.t or 0, push.hurt or 0) > CurTime() - 4 then
					att = push.att
				end
			end

			local dmg = DamageInfo()

			if att == ply then
				-- hijack physgun damage as a marker of this type of kill
				dmg:SetDamageType(DMG_CRUSH + DMG_PHYSGUN)
			else
				-- if attributing to pusher, show more generic crush msg for now
				dmg:SetDamageType(DMG_CRUSH)
			end

			dmg:SetAttacker(att)
			dmg:SetInflictor(att)
			dmg:SetDamageForce(Vector(0,0,-1))
			dmg:SetDamage(damage)

			ground:TakeDamageInfo(dmg)
		end

		-- our own falling damage is cushioned
		damage = damage / 3
	end

	if math.floor(damage) > 0 then
		local dmg = DamageInfo()
		dmg:SetDamageType(DMG_FALL)
		dmg:SetAttacker(game.GetWorld())
		dmg:SetInflictor(game.GetWorld())
		dmg:SetDamageForce(Vector(0,0,1))
		dmg:SetDamage(damage)

		ply:TakeDamageInfo(dmg)

		-- play CS:S fall sound if we got somewhat significant damage
		if damage > 5 then
			sound.Play(table.Random(fallsounds), ply:GetShootPos(), 55 + math.Clamp(damage, 0, 50), 100)
		end
	end
end

local wntd_postdm = CreateConVar("wntd_postround_dm", "0", FCVAR_NOTIFY)

function GM:AllowPVP()
	local rs = GetRoundState()
	return not (rs == ROUND_PREP or (rs == ROUND_POST and not wntd_postdm:GetBool()))
end

-- No damage during prep, etc
function GM:EntityTakeDamage(ent, dmginfo)
	if not IsValid(ent) then return end
	local att = dmginfo:GetAttacker()

	if not GAMEMODE:AllowPVP() then
		-- if player vs player damage, or if damage versus a prop, then zero
		if (ent:IsExplosive() or (ent:IsPlayer() and IsValid(att) and att:IsPlayer())) then
			dmginfo:ScaleDamage(0)
			dmginfo:SetDamage(0)
		end
	elseif ent:IsPlayer() then

		GAMEMODE:PlayerTakeDamage(ent, dmginfo:GetInflictor(), att, dmginfo:GetDamage(), dmginfo)

	elseif ent:IsExplosive() then
		-- When a barrel hits a player, that player damages the barrel because
		-- Source physics. This gives stupid results like a player who gets hit
		-- with a barrel being blamed for killing himself or even his attacker.
		if IsValid(att) and att:IsPlayer() and
			dmginfo:IsDamageType(DMG_CRUSH) and
			IsValid(ent:GetPhysicsAttacker()) then

			dmginfo:SetAttacker(ent:GetPhysicsAttacker())
			dmginfo:ScaleDamage(0)
			dmginfo:SetDamage(0)
		end
	elseif ent.is_pinned and ent.OnPinnedDamage then
		ent:OnPinnedDamage(dmginfo)

		dmginfo:SetDamage(0)
	end
end

function GM:PlayerTakeDamage(ent, infl, att, amount, dmginfo)
	-- Change damage attribution if necessary
	if infl or att then
		local hurter, owner, owner_time

		-- fall back to the attacker if there is no inflictor
		if IsValid(infl) then
			hurter = infl
		elseif IsValid(att) then
			hurter = att
		end

		-- have a damage owner?
		if hurter and IsValid(hurter:GetDamageOwner()) then
			owner, owner_time = hurter:GetDamageOwner()

			-- barrel bangs can hurt us even if we threw them, but that's our fault
		elseif hurter and ent == hurter:GetPhysicsAttacker() and dmginfo:IsDamageType(DMG_BLAST) then
			owner = ent
		elseif hurter and hurter:IsVehicle() and IsValid(hurter:GetDriver()) then
			owner = hurter:GetDriver()
		end


		-- if we were hurt by a trap OR by a non-ply ent, and we were pushed
		-- recently, then our pusher is the attacker
		if owner_time or (not IsValid(att)) or (not att:IsPlayer()) then
			local push = ent.was_pushed

			if push and IsValid(push.att) and push.t then
				-- push must be within the last 5 seconds, and must be done
				-- after the trap was enabled (if any)
				owner_time = owner_time or 0
				local t = math.max(push.t or 0, push.hurt or 0)
				if t > owner_time and t > CurTime() - 4 then
					owner = push.att

					-- pushed by a trap?
					if IsValid(push.infl) then
						dmginfo:SetInflictor(push.infl)
					end

					-- for slow-hurting traps we do leech-like damage timing
					push.hurt = CurTime()
				end
			end
		end

		-- if we are being hurt by a physics object, we will take damage from
		-- the world entity as well, which screws with damage attribution so we
		-- need to detect and work around that
		if IsValid(owner) and dmginfo:IsDamageType(DMG_CRUSH) then
			-- we should be able to use the push system for this, as the cases are
			-- similar: event causes future damage but should still be attributed
			-- physics traps can also push you to your death, for example
			local push = ent.was_pushed or {}

			-- if we already blamed this on a pusher, no need to do more
			-- else we override whatever was in was_pushed with info pointing
			-- at our damage owner
			if push.att != owner then
				owner_time = owner_time or CurTime()

				push.att = owner
				push.t = owner_time
				push.hurt = CurTime()

				-- store the current inflictor so that we can attribute it as the
				-- trap used by the player in the event
				if IsValid(infl) then
					push.infl = infl
				end

				-- make sure this is set, for if we created a new table
				ent.was_pushed = push
			end
		end

		-- make the owner of the damage the attacker
		att = IsValid(owner) and owner or att
		dmginfo:SetAttacker(att)
	end

	-- scale phys damage caused by props
	if dmginfo:IsDamageType(DMG_CRUSH) and IsValid(att) then

		-- player falling on player, or player hurt by prop?
		if not dmginfo:IsDamageType(DMG_PHYSGUN) then

			-- this is prop-based physics damage
			dmginfo:ScaleDamage(0.25)

			-- if the prop is held, no damage
			if IsValid(infl) and IsValid(infl:GetOwner()) and infl:GetOwner():IsPlayer() then
				dmginfo:ScaleDamage(0)
				dmginfo:SetDamage(0)
			end
		end
	end

	-- handle fire attacker
	if ent.ignite_info and dmginfo:IsDamageType(DMG_DIRECT) then
		local datt = dmginfo:GetAttacker()
		if (not IsValid(datt)) or (not datt:IsPlayer()) then
			local ignite = ent.ignite_info
			if IsValid(ignite.att) and IsValid(ignite.infl)then
				dmginfo:SetAttacker(ignite.att)
				dmginfo:SetInflictor(ignite.infl)
			end
		end
	end

	-- try to work out if this was push-induced leech-water damage (common on
	-- some popular maps like dm_island17)
	if ent.was_pushed and ent == att and dmginfo:GetDamageType() == DMG_GENERIC and util.BitSet(util.PointContents(dmginfo:GetDamagePosition()), CONTENTS_WATER) then
		local t = math.max(ent.was_pushed.t or 0, ent.was_pushed.hurt or 0)
		if t > CurTime() - 3 then
			dmginfo:SetAttacker(ent.was_pushed.att)
			ent.was_pushed.hurt = CurTime()
		end
	end

	-- start painting blood decals
	util.StartBleeding(ent, dmginfo:GetDamage(), 5)

	-- general actions for pvp damage
	if ent != att and IsValid(att) and att:IsPlayer() and GetRoundState() == ROUND_ACTIVE and math.floor(dmginfo:GetDamage()) > 0 then

		-- scale everything to karma damage factor except the knife, because it
		-- assumes a kill
		if not dmginfo:IsDamageType(DMG_SLASH) then
			dmginfo:ScaleDamage(att:GetDamageFactor())
		end
	end

end


function GM:OnNPCKilled() end

-- Drowning and such
local tm = nil
local ply = nil
local plys = nil
function GM:Tick()
	-- three cheers for micro-optimizations
	plys = player.GetAll()
	for i= 1, #plys do
		ply = plys[i]
		tm = ply:Team()
		if tm == TEAM_PLAYER and ply:Alive() then
			-- Drowning
			if ply:WaterLevel() == 3 then
				if ply:IsOnFire() then
					ply:Extinguish()
				end

				if ply.drowning then
					if ply.drowning < CurTime() then
						local dmginfo = DamageInfo()
						dmginfo:SetDamage(15)
						dmginfo:SetDamageType(DMG_DROWN)
						dmginfo:SetAttacker(game.GetWorld())
						dmginfo:SetInflictor(game.GetWorld())
						dmginfo:SetDamageForce(Vector(0,0,1))

						ply:TakeDamageInfo(dmginfo)

						-- have started drowning properly
						ply.drowning = CurTime() + 1
					end
				else
					-- will start drowning soon
					ply.drowning = CurTime() + 8
				end
			else
				ply.drowning = nil
			end

			-- Slow down ironsighters
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) and wep.GetIronsights and wep:GetIronsights() then
				ply:SetSpeed(true)
			else
				ply:SetSpeed(false)
			end

			-- Run DNA Scanner think also when it is not deployed
			if IsValid(ply.scanner_weapon) and wep != ply.scanner_weapon then
				ply.scanner_weapon:Think()
			end
		elseif tm == TEAM_SPEC then
			if ply.propspec then
				PROPSPEC.Recharge(ply)

				if IsValid(ply:GetObserverTarget()) then
					ply:SetPos(ply:GetObserverTarget():GetPos())
				end
			end

			-- if spectators are alive, ie. they picked spectator mode, then
			-- DeathThink doesn't run, so we have to SpecThink here
			if ply:Alive() then
				self:SpectatorThink(ply)
			end
		end
	end
end

function GM:ShowHelp(ply)
	if IsValid(ply) then
		ply:ConCommand("wntd_helpscreen")
	end
end

function GM:PlayerRequestTeam(ply, teamid)
end

-- Implementing stuff that should already be in gmod, chpt. 389
function GM:PlayerEnteredVehicle(ply, vehicle, role)
	if IsValid(vehicle) then
		vehicle:SetNWEntity("wntd_driver", ply)
	end
end

function GM:PlayerLeaveVehicle(ply, vehicle)
	if IsValid(vehicle) then
		-- setting nil will not do anything, so bogusify
		vehicle:SetNWEntity("wntd_driver", vehicle)
	end
end

function GM:AllowPlayerPickup(ply, obj)
	return false
end

function GM:PlayerShouldTaunt(ply, actid)
	-- Disable taunts, we don't have a system for them (camera freezing etc).
	-- Mods/plugins that add such a system should override this.
	return false
end