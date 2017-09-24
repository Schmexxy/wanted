---- Communicating game state to players

local net = net
local string = string
local table = table
local pairs = pairs
local IsValid = IsValid

-- NOTE: most uses of the Msg functions here have been moved to the LANG
-- functions. These functions are essentially deprecated, though they won't be
-- removed and can safely be used by SWEPs and the like.

function GameMsg(msg)
   net.Start("WNTD_GameMsg")
      net.WriteString(msg)
      net.WriteBit(false)
   net.Broadcast()
end

function CustomMsg(ply_or_rf, msg, clr)
   clr = clr or COLOR_WHITE

   net.Start("WNTD_GameMsgColor")
      net.WriteString(msg)
      net.WriteUInt(clr.r, 8)
      net.WriteUInt(clr.g, 8)
      net.WriteUInt(clr.b, 8)
   if ply_or_rf then net.Send(ply_or_rf)
   else net.Broadcast() end
end

-- Basic status message to single player or a recipientfilter
function PlayerMsg(ply_or_rf, msg, traitor_only)
   net.Start("WNTD_GameMsg")
      net.WriteString(msg)
      net.WriteBit(traitor_only)
   if ply_or_rf then net.Send(ply_or_rf)
   else net.Broadcast() end
end

-- Round start info popup
function ShowRoundStartPopup()
   for k, v in pairs(player.GetAll()) do
      if IsValid(v) and v:Team() == TEAM_PLAYER and v:Alive() then
         v:ConCommand("wntd_cl_startpopup")
      end
   end
end

local function GetPlayerFilter(pred)
   local filter = {}
   for k, v in pairs(player.GetAll()) do
      if IsValid(v) and pred(v) then
         table.insert(filter, v)
      end
   end
   return filter
end

function GetInnocentFilter(alive_only)
   return GetPlayerFilter(function(p) return (not alive_only or p:IsActivePlayer()) end)
end

function GetRoleFilter(role, alive_only)
   return GetPlayerFilter(function(p) return p:IsRole(role) and (not alive_only or p:IsActivePlayer()) end)
end

---- Communication control
CreateConVar("wntd_limit_spectator_chat", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("wntd_limit_spectator_voice", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY)

function GM:PlayerCanSeePlayersChat(text, team_only, listener, speaker)
	if (not IsValid(listener)) then return false end
	if (not IsValid(speaker)) then
		if isentity(speaker) then
			return true
		else
			return false
		end
	end

	local sTeam = speaker:Team() == TEAM_SPEC
	local lTeam = listener:Team() == TEAM_SPEC

	if (GetRoundState() != ROUND_ACTIVE) or   -- Round isn't active
	(not GetConVar("wntd_limit_spectator_chat"):GetBool()) or   -- Spectators can chat freely
	(not DetectiveMode()) or   -- Mumbling
	(not sTeam and ((team_only and not speaker:IsSpecial()) or (not team_only))) or   -- If someone alive talks (and not a special role in teamchat's case)
	(not sTeam and team_only and speaker:GetRole() == listener:GetRole()) or
	(sTeam and lTeam) then   -- If the speaker and listener are spectators
	   return true
	end

	return false
end

local mumbles = {"mumble", "mm", "hmm", "hum", "mum", "mbm", "mble", "ham", "mammaries", "political situation", "mrmm", "hrm",
"uzbekistan", "mumu", "cheese export", "hmhm", "mmh", "mumble", "mphrrt", "mrh", "hmm", "mumble", "mbmm", "hmml", "mfrrm"}

-- While a round is active, spectators can only talk among themselves. When they
-- try to speak to all players they could divulge information about who killed
-- them. So we mumblify them. In detective mode, we shut them up entirely.
function GM:PlayerSay(ply, text, team_only)
   if not IsValid(ply) then return text or "" end

   if GetRoundState() == ROUND_ACTIVE then
      local team = ply:Team() == TEAM_SPEC
      if team and not DetectiveMode() then
         local filtered = {}
         for k, v in pairs(string.Explode(" ", text)) do
            -- grab word characters and whitelisted interpunction
            -- necessary or leetspeek will be used (by trolls especially)
            local word, interp = string.match(v, "(%a*)([%.,;!%?]*)")
            if word != "" then
               table.insert(filtered, mumbles[math.random(1, #mumbles)] .. interp)
            end
         end

         -- make sure we have something to say
         if table.Count(filtered) < 1 then
            table.insert(filtered, mumbles[math.random(1, #mumbles)])
         end

         table.insert(filtered, 1, "[MUMBLED]")
         return table.concat(filtered, " ")
      elseif team_only and not team and ply:IsSpecial() then
	     RoleChatMsg(ply, ply:GetRole(), text)
		 return ""
      end
   end

   return text or ""
end


-- Mute players when we are about to run map cleanup, because it might cause
-- net buffer overflows on clients.
local mute_all = false
function MuteForRestart(state)
   mute_all = state
end


local loc_voice = CreateConVar("wntd_locational_voice", "0")

-- Of course voice has to be limited as well
function GM:PlayerCanHearPlayersVoice(listener, speaker)
   -- Enforced silence
   if mute_all then
      return false, false
   end

   if (not IsValid(speaker)) or (not IsValid(listener)) or (listener == speaker) then
      return false, false
   end

   -- Spectators should not be heard by living players during round
   if speaker:IsSpec() and (not listener:IsSpec()) and GetRoundState() == ROUND_ACTIVE then
      return false, false
   end

   -- Specific mute
   if listener:IsSpec() and listener.mute_team == speaker:Team() or listener.mute_team == MUTE_ALL then
      return false, false
   end

   -- Specs should not hear each other locationally
   if speaker:IsSpec() and listener:IsSpec() then
      return true, false
   end

   return true, (loc_voice:GetBool() and GetRoundState() != ROUND_POST)
end

local function MuteTeam(ply, cmd, args)
   if not IsValid(ply) then return end
   if not #args == 1 and tonumber(args[1]) then return end
   if not ply:IsSpec() then
      ply.mute_team = -1
      return
   end

   local t = tonumber(args[1])
   ply.mute_team = t

   if t == MUTE_ALL then
      ply:ChatPrint("All muted.")
   elseif t == MUTE_NONE or t == TEAM_UNASSIGNED or not team.Valid(t) then
      ply:ChatPrint("None muted.")
   else
      ply:ChatPrint(team.GetName(t) .. " muted.")
   end
end
concommand.Add("wntd_mute_team", MuteTeam)