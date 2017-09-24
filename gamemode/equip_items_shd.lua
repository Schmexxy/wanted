
-- This table is used by the client to show items in the equipment menu, and by
-- the server to check if a certain role is allowed to buy a certain item.


-- If you have custom items you want to add, consider using a separate lua
-- script that uses table.insert to add an entry to this table. This method
-- means you won't have to add your code back in after every TTT update. Just
-- make sure the script is also run on the client.
--
-- For example:
--   table.insert(EquipmentItems[ROLE_DETECTIVE], { id = EQUIP_ARMOR, ... })
--
-- Note that for existing items you can just do:
--   table.insert(EquipmentItems[ROLE_DETECTIVE], GetEquipmentItem(ROLE_TRAITOR, EQUIP_ARMOR))


-- Special equipment bitflags. Every unique piece of equipment needs its own
-- id. The number should increase by a factor of two for every item (ie. ids
-- should be powers of two). So if you were to add five more pieces of
-- equipment, they should have the following ids: 8, 16, 32, 64, 128...
EQUIP_NONE     = 0
EQUIP_ARMOR    = 1

-- Icon doesn't have to be in this dir, but all default ones are in here
local mat_dir = "vgui/ttt/"


-- Stick to around 35 characters per description line, and add a "\n" where you
-- want a new line to start.

EquipmentItems = {};

-- Search if an item is in the equipment table of a given role, and return it if
-- it exists, else return nil.
function GetEquipmentItem(role, id)
   local tbl = EquipmentItems[role]
   if not tbl then return end

   for k, v in pairs(tbl) do
      if v and v.id == id then
         return v
      end
   end
end