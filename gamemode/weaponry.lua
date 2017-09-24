
include("weaponry_shd.lua") -- inits WEPS tbl

---- Weapon system, pickup limits, etc

local IsEquipment = WEPS.IsEquipment

-- Prevent players from picking up multiple weapons of the same type etc
function GM:PlayerCanPickupWeapon(ply, wep)
   if not IsValid(wep) or not IsValid(ply) then return end
   if ply:IsSpec() then return false end

   -- Disallow picking up for ammo
   if ply:HasWeapon(wep:GetClass()) then
      return false
   elseif not ply:CanCarryWeapon(wep) then
      return false
   elseif IsEquipment(wep) and wep.IsDropped and (not ply:KeyDown(IN_USE)) then
      return false
   end

   local tr = util.TraceEntity({start=wep:GetPos(), endpos=ply:GetShootPos(), mask=MASK_SOLID}, wep)
   if tr.Fraction == 1.0 or tr.Entity == ply then
      wep:SetPos(ply:GetShootPos())
   end

   return true
end

-- Note that this is called both when a player spawns and when a round starts
function GM:PlayerLoadout( ply )
   if IsValid(ply) and (not ply:IsSpec()) then
      -- clear out equipment flags
      ply:ResetEquipment()
   end
end

function GM:UpdatePlayerLoadouts()
   for k, v in pairs(player.GetAll()) do
      GAMEMODE:PlayerLoadout(v)
   end
end

---- Weapon switching
local function ForceWeaponSwitch(ply, cmd, args)
   if not ply:IsPlayer() or not args[1] then return end
   -- Turns out even SelectWeapon refuses to switch to empty guns, gah.
   -- Worked around it by giving every weapon a single Clip2 round.
   -- Works because no weapon uses those.
   local wepname = args[1]
   local wep = ply:GetWeapon(wepname)
   if IsValid(wep) then
      -- Weapons apparently not guaranteed to have this
      if wep.SetClip2 then
         wep:SetClip2(1)
      end
      ply:SelectWeapon(wepname)
   end
end
concommand.Add("wepswitch", ForceWeaponSwitch)

---- Weapon dropping
function WEPS.DropNotifiedWeapon(ply, wep, death_drop)
   if IsValid(ply) and IsValid(wep) then
      -- Hack to tell the weapon it's about to be dropped and should do what it
      -- must right now
      if wep.PreDrop then
         wep:PreDrop(death_drop)
      end

      -- PreDrop might destroy weapon
      if not IsValid(wep) then return end

      -- Tag this weapon as dropped
      wep.IsDropped = true

      ply:DropWeapon(wep)

      wep:PhysWake()

      -- After dropping a weapon, always switch to holstered, so that traitors
      -- will never accidentally pull out a traitor weapon
      ply:SelectWeapon("weapon_wntd_unarmed")
   end
end

local function DropActiveWeapon(ply)
   if not IsValid(ply) then return end

   local wep = ply:GetActiveWeapon()

   if not IsValid(wep) then return end

   if wep.AllowDrop == false then
      return
   end

   local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 32, ply)

   if tr.HitWorld then
      LANG.Msg(ply, "drop_no_room")
      return
   end

   ply:AnimPerformGesture(ACT_ITEM_PLACE)

   WEPS.DropNotifiedWeapon(ply, wep)
end
concommand.Add("wntd_dropweapon", DropActiveWeapon)

local function DropActiveAmmo(ply)
   if not IsValid(ply) then return end

   local wep = ply:GetActiveWeapon()
   if not IsValid(wep) then return end

   if not wep.AmmoEnt then return end

   local amt = wep:Clip1()
   if amt < 1 or amt <= (wep.Primary.ClipSize * 0.25) then
      LANG.Msg(ply, "drop_no_ammo")
      return
   end

   local pos, ang = ply:GetShootPos(), ply:EyeAngles()
   local dir = (ang:Forward() * 32) + (ang:Right() * 6) + (ang:Up() * -5)

   local tr = util.QuickTrace(pos, dir, ply)
   if tr.HitWorld then return end

   wep:SetClip1(0)

   ply:AnimPerformGesture(ACT_ITEM_GIVE)

   local box = ents.Create(wep.AmmoEnt)
   if not IsValid(box) then box:Remove() end

   box:SetPos(pos + dir)
   box:SetOwner(ply)
   box:Spawn()

   box:PhysWake()

   local phys = box:GetPhysicsObject()
   if IsValid(phys) then
      phys:ApplyForceCenter(ang:Forward() * 1000)
      phys:ApplyForceOffset(VectorRand(), vector_origin)
   end

   box.AmmoAmount = amt

   timer.Simple(2, function()
       if IsValid(box) then
          box:SetOwner(nil)
       end
    end)
end
concommand.Add("wntd_dropammo", DropActiveAmmo)

-- Give a weapon to a player. If the initial attempt fails due to heisenbugs in
-- the map, keep trying until the player has moved to a better spot where it
-- does work.
local function GiveEquipmentWeapon(sid, cls)
   -- Referring to players by SteamID because a player may disconnect while his
   -- unique timer still runs, in which case we want to be able to stop it. For
   -- that we need its name, and hence his SteamID.
   local ply = player.GetBySteamID(sid)
   local tmr = "give_equipment" .. sid

   if (not IsValid(ply)) or (not ply:IsActiveSpecial()) then
      timer.Remove(tmr)
      return
   end

   -- giving attempt, will fail if we're in a crazy spot in the map or perhaps
   -- other glitchy cases
   local w = ply:Give(cls)

   if (not IsValid(w)) or (not ply:HasWeapon(cls)) then
      if not timer.Exists(tmr) then
         timer.Create(tmr, 1, 0, function() GiveEquipmentWeapon(sid, cls) end)
      end

      -- we will be retrying
   else
      -- can stop retrying, if we were
      timer.Remove(tmr)

      if w.WasBought then
         -- some weapons give extra ammo after being bought, etc
         w:WasBought(ply)
      end
   end
end

-- Protect against non-WNTD weapons that may break the HUD
function GM:WeaponEquip(wep)
   if IsValid(wep) then
      -- only remove if they lack critical stuff
      if not wep.Kind then
         wep:Remove()
         ErrorNoHalt("Equipped weapon " .. wep:GetClass() .. " is not compatible with WNTD\n")
      end
   end
end

-- non-cheat developer commands can reveal precaching the first time equipment
-- is bought, so trigger it at the start of a round instead
function WEPS.ForcePrecache()
   for k, w in ipairs(weapons.GetList()) do
      if w.WorldModel then
         util.PrecacheModel(w.WorldModel)
      end
      if w.ViewModel then
         util.PrecacheModel(w.ViewModel)
      end
   end
end
