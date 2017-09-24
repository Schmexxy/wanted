---- Dummy ent that just spawns a random WNTD ammo item and kills itself

ENT.Type = "point"
ENT.Base = "base_point"


function ENT:Initialize()
   local ammos = ents.WNTD.GetSpawnableAmmo()

   if ammos then
      local cls = table.Random(ammos)
      local ent = ents.Create(cls)
      if IsValid(ent) then
         ent:SetPos(self:GetPos())
         ent:SetAngles(self:GetAngles())
         ent:Spawn()
         ent:PhysWake()
      end

      self:Remove()
   end
end