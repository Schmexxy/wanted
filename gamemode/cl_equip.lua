---- Traitor equipment menu

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

-- Buyable weapons are loaded automatically. Buyable items are defined in
-- equip_items_shd.lua

local Equipment = nil
function GetEquipmentForRole(role)
   -- need to build equipment cache?
   if not Equipment then
      -- start with all the non-weapon goodies
      local tbl = table.Copy(EquipmentItems)

      -- find buyable weapons to load info from
      for k, v in pairs(weapons.GetList()) do
         if v and v.CanBuy then
            local data = v.EquipMenuData or {}
            local base = {
               id       = WEPS.GetClass(v),
               name     = v.PrintName or "Unnamed",
               limited  = v.LimitedStock,
               kind     = v.Kind or WEAPON_NONE,
               slot     = (v.Slot or 0) + 1,
               material = v.Icon or "vgui/ttt/icon_id",
               -- the below should be specified in EquipMenuData, in which case
               -- these values are overwritten
               type     = "Type not specified",
               model    = "models/weapons/w_bugbait.mdl",
               desc     = "No description specified."
            };

            -- Force material to nil so that model key is used when we are
            -- explicitly told to do so (ie. material is false rather than nil).
            if data.modelicon then
               base.material = nil
            end

            table.Merge(base, data)

            -- add this buyable weapon to all relevant equipment tables
            for _, r in pairs(v.CanBuy) do
               table.insert(tbl[r], base)
            end
         end
      end

      -- mark custom items
      for r, is in pairs(tbl) do
         for _, i in pairs(is) do
            if i and i.id then
               i.custom = not table.HasValue(DefaultEquipment[r], i.id)
            end
         end
      end

      Equipment = tbl
   end

   return Equipment and Equipment[role] or {}
end

local function ReceiveEquipment()
   local ply = LocalPlayer()
   if not IsValid(ply) then return end

   ply.equipment_items = net.ReadUInt(16)
end
net.Receive("WNTD_Equipment", ReceiveEquipment)

local function ReceiveCredits()
   local ply = LocalPlayer()
   if not IsValid(ply) then return end

   ply.equipment_credits = net.ReadUInt(8)
end
net.Receive("WNTD_Credits", ReceiveCredits)

local r = 0
local function ReceiveBought()
   local ply = LocalPlayer()
   if not IsValid(ply) then return end

   ply.bought = {}
   local num = net.ReadUInt(8)
   for i=1,num do
      local s = net.ReadString()
      if s != "" then
         table.insert(ply.bought, s)
      end
   end

   -- This usermessage sometimes fails to contain the last weapon that was
   -- bought, even though resending then works perfectly. Possibly a bug in
   -- bf_read. Anyway, this hack is a workaround: we just request a new umsg.
   if num != #ply.bought and r < 10 then -- r is an infinite loop guard
      RunConsoleCommand("wntd_resend_bought")
      r = r + 1
   else
      r = 0
   end
end
net.Receive("WNTD_Bought", ReceiveBought)

-- Player received the item he has just bought, so run clientside init
local function ReceiveBoughtItem()
   local is_item = net.ReadBit() == 1
   local id = is_item and net.ReadUInt(16) or net.ReadString()

   -- I can imagine custom equipment wanting this, so making a hook
   hook.Run("WNTDBoughtItem", is_item, id)
end
net.Receive("WNTD_BoughtItem", ReceiveBoughtItem)
