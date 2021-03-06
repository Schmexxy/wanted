-- Key overrides for WNTD specific keyboard functions

local function SendWeaponDrop()
   RunConsoleCommand("wntd_dropweapon")

   -- Turn off weapon switch display if you had it open while dropping, to avoid
   -- inconsistencies.
   WSWITCH:Disable()
end

function GM:OnSpawnMenuOpen()
   SendWeaponDrop()
end

function GM:PlayerBindPress(ply, bind, pressed)
   if not IsValid(ply) then return end

   if bind == "invnext" and pressed then
      if not ply:IsSpec() then
         WSWITCH:SelectNext()
      end
      return true
   elseif bind == "invprev" and pressed then
      if not ply:IsSpec() then
         WSWITCH:SelectPrev()
      end
      return true
   elseif bind == "+attack" then
      if WSWITCH:PreventAttack() then
         if not pressed then
            WSWITCH:ConfirmSelection()
         end
         return true
      end
   elseif bind == "+sprint" then
      -- set voice type here just in case shift is no longer down when the
      -- PlayerStartVoice hook runs, which might be the case when switching to
      -- steam overlay
      RunConsoleCommand("tvog", "0")
      return true
   elseif bind == "+use" and pressed then
      if ply:IsSpec() then
         RunConsoleCommand("wntd_spec_use")
         return true
      end
   elseif string.sub(bind, 1, 4) == "slot" and pressed then
      local idx = tonumber(string.sub(bind, 5, -1)) or 1

      WSWITCH:SelectSlot(idx)
      return true
   elseif bind == "+duck" and pressed and ply:IsSpec() then
      if not IsValid(ply:GetObserverTarget()) then
         if GAMEMODE.ForcedMouse then
            gui.EnableScreenClicker(false)
            GAMEMODE.ForcedMouse = false
         else
            gui.EnableScreenClicker(true)
            GAMEMODE.ForcedMouse = true
         end
      end
   elseif bind == "noclip" and pressed then
      if not GetConVar("sv_cheats"):GetBool() then
         RunConsoleCommand("wntd_equipswitch")
         return true
      end
   elseif (bind == "gmod_undo" or bind == "undo") and pressed then
      RunConsoleCommand("wntd_dropammo")
      return true
   end
end