
ENT.Type = "point"
ENT.Base = "base_point"

function ENT:AcceptInput(name, activator, caller)
   if name == "InnocentWin" then
      GAMEMODE:MapTriggeredEnd(WIN_PLAYER)
      return true
   end
end