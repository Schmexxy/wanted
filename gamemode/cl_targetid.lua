
local util = util
local surface = surface
local draw = draw

local GetPTranslation = LANG.GetParamTranslation
local GetRaw = LANG.GetRawTranslation

local key_params = {usekey = Key("+use", "USE"), walkkey = Key("+walk", "WALK")}

-- Basic access for servers to add/modify hints. They override hints stored on
-- the entities themselves.
function GM:AddClassHint(cls, hint)
   ClassHint[cls] = table.Copy(hint)
end


---- "T" indicator above traitors

local indicator_mat = Material("vgui/wanted/sprite_traitor")
local indicator_col = Color(255, 255, 255, 130)

local client, plys, ply, pos, dir, tgt
local GetPlayers = player.GetAll

local propspec_outline = Material("models/props_combine/portalball001_sheet")

-- using this hook instead of pre/postplayerdraw because playerdraw seems to
-- happen before certain entities are drawn, which then clip over the sprite
function GM:PostDrawTranslucentRenderables()
   client = LocalPlayer()
   plys = GetPlayers()

   if client:Team() == TEAM_SPEC then
      cam.Start3D(EyePos(), EyeAngles())

      for i=1, #plys do
         ply = plys[i]
         tgt = ply:GetObserverTarget()
         if IsValid(tgt) and tgt:GetNWEntity("spec_owner", nil) == ply then
            render.MaterialOverride(propspec_outline)
            render.SuppressEngineLighting(true)
            render.SetColorModulation(1, 0.5, 0)

            tgt:SetModelScale(1.05, 0)
            tgt:DrawModel()

            render.SetColorModulation(1, 1, 1)
            render.SuppressEngineLighting(false)
            render.MaterialOverride(nil)
         end
      end

      cam.End3D()
   end
end

---- Spectator labels

local function DrawPropSpecLabels(client)
   if (not client:IsSpec()) and (GetRoundState() != ROUND_POST) then return end

   surface.SetFont("TabLarge")

   local tgt = nil
   local scrpos = nil
   local text = nil
   local w = 0
   for _, ply in pairs(player.GetAll()) do
      if ply:IsSpec() then
         surface.SetTextColor(220,200,0,120)

         tgt = ply:GetObserverTarget()

         if IsValid(tgt) and tgt:GetNWEntity("spec_owner", nil) == ply then

            scrpos = tgt:GetPos():ToScreen()
         else
            scrpos = nil
         end
      else
         local _, healthcolor = util.HealthToString(ply:Health())
         surface.SetTextColor(clr(healthcolor))

         scrpos = ply:EyePos()
         scrpos.z = scrpos.z + 20

         scrpos = scrpos:ToScreen()
      end

      if scrpos and (not IsOffScreen(scrpos)) then
         text = ply:Nick()
         w, _ = surface.GetTextSize(text)

         surface.SetTextPos(scrpos.x - w / 2, scrpos.y)
         surface.DrawText(text)
      end
   end
end


---- Crosshair affairs

surface.CreateFont("TargetIDSmall2", {font = "TargetID",
                                      size = 16,
                                      weight = 1000})

local magnifier_mat = Material("icon16/magnifier.png")
local ring_tex = surface.GetTextureID("effects/select_ring")

local rag_color = Color(200,200,200,255)

local GetLang = LANG.GetUnsafeLanguageTable

function GM:HUDDrawTargetID()
   local client = LocalPlayer()
   DrawPropSpecLabels(client)
end