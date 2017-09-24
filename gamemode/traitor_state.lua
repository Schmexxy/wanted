-- Send every player their role
local function SendPlayerRoles()
   for k, v in pairs(player.GetAll()) do
      net.Start("WNTD_Role")
         net.WriteUInt(v:GetRole(), 2)
      net.Send(v)
   end
end

local function SendRoleListMessage(role, role_ids, ply_or_rf)
   net.Start("WNTD_RoleList")
      net.WriteUInt(role, 2)

      -- list contents
      local num_ids = #role_ids
      net.WriteUInt(num_ids, 8)
      for i=1, num_ids do
         net.WriteUInt(role_ids[i] - 1, 7)
      end

   if ply_or_rf then net.Send(ply_or_rf)
   else net.Broadcast() end
end

local function SendRoleList(role, ply_or_rf, pred)
   local role_ids = {}
   for k, v in pairs(player.GetAll()) do
      if v:IsRole(role) then
         if not pred or (pred and pred(v)) then
            table.insert(role_ids, v:EntIndex())
         end
      end
   end

   SendRoleListMessage(role, role_ids, ply_or_rf)
end

function SendInnocentList(ply_or_rf)
   local inno_ids = {}
   for k, v in pairs(player.GetAll()) do
      if v:IsRole(ROLE_PLAYER) then
         table.insert(inno_ids, v:EntIndex())
      end
   end

   table.Add(inno_ids)
   table.Shuffle(inno_ids)
   SendRoleListMessage(ROLE_PLAYER, inno_ids, GetInnocentFilter())
end

function SendFullStateUpdate()
   SendPlayerRoles()
   SendInnocentList()
end

function SendRoleReset(ply_or_rf)
   local plys = player.GetAll()

   net.Start("WNTD_RoleList")
      net.WriteUInt(ROLE_PLAYER, 2)

      net.WriteUInt(#plys, 8)
      for k, v in pairs(plys) do
         net.WriteUInt(v:EntIndex() - 1, 7)
      end

   if ply_or_rf then net.Send(ply_or_rf)
   else net.Broadcast() end
end

---- Console commands

local function request_rolelist(ply)
   -- Client requested a state update. Note that the client can only use this
   -- information after entities have been initialised (e.g. in InitPostEntity).
   if GetRoundState() != ROUND_WAIT then
      SendRoleReset(ply)
   end
end
concommand.Add("wntd_request_rolelist", request_rolelist)

local function force_player(ply)
   if cvars.Bool("sv_cheats") then
      ply:SetRole(ROLE_PLAYER)
      ply:UnSpectate()

      ply:StripAll()

      ply:Spawn()
      ply:PrintMessage(HUD_PRINTTALK, "You are now on the players team.")

      SendFullStateUpdate()
   end
end
concommand.Add("wntd_force_player", force_player)


local function force_spectate(ply, cmd, arg)
   if IsValid(ply) then
      if #arg == 1 and tonumber(arg[1]) == 0 then
         ply:SetForceSpec(false)
      else
         if not ply:IsSpec() then
            ply:Kill()
         end

         GAMEMODE:PlayerSpawnAsSpectator(ply)
         ply:SetTeam(TEAM_SPEC)
         ply:SetForceSpec(true)
         ply:Spawn()

         ply:SetRagdollSpec(false) -- dying will enable this, we don't want it here
      end
   end
end
concommand.Add("wntd_spectate", force_spectate)


