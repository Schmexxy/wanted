---- Corpse functions

-- namespaced because we have no ragdoll metatable
CORPSE = {}

include("corpse_shd.lua")

--- networked data abstraction layer
local dti = CORPSE.dti

local rag_collide = CreateConVar("wntd_ragdoll_collide", "0")

-- Creates client or server ragdoll depending on settings
function CORPSE.Create(ply, attacker, dmginfo)
   if not IsValid(ply) then return end

   local rag = ents.Create("prop_ragdoll")
   if not IsValid(rag) then return nil end

   rag:SetPos(ply:GetPos())
   rag:SetModel(ply:GetModel())
   rag:SetAngles(ply:GetAngles())
   rag:SetColor(ply:GetColor())

   rag:Spawn()
   rag:Activate()

   -- nonsolid to players, but can be picked up and shot
   rag:SetCollisionGroup(rag_collide:GetBool() and COLLISION_GROUP_WEAPON or COLLISION_GROUP_DEBRIS_TRIGGER)
   timer.Simple( 1, function() if IsValid( rag ) then rag:CollisionRulesChanged() end end )

   return rag -- we'll be speccing this
end
