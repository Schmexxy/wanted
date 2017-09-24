-- HUD HUD HUD

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation
local GetLang = LANG.GetUnsafeLanguageTable
local interp = string.Interp

-- Fonts
surface.CreateFont("FontSml", {
	font = "Roboto",
	size = 22,
	weight = 400
})
surface.CreateFont("TimeLeft", {
	font = "Roboto",
	size = 24,
	weight = 400
})
surface.CreateFont("HealthAmmo", {
	font = "Roboto",
	size = 18,
	weight = 400
})

-- Color presets
local bg_colors = {
	background_main = Color(0, 0, 10, 200)
};

local health_colors = {
	background = Color(100, 25, 25, 222),
	fill = Color(200, 50, 50, 250)
};

local ammo_colors = {
	background = Color(20, 20, 5, 222),
	fill = Color(205, 155, 0, 255)
};

-- Modified RoundedBox
local function RoundedMeter( bs, x, y, w, h, color)
	surface.SetDrawColor(clr(color))

	surface.DrawRect( x+bs, y, w-bs*2, h )
	surface.DrawRect( x, y+bs, bs, h-bs*2 )

	surface.DrawTexturedRectRotated( x + bs/2 , y + bs/2, bs, bs, 0 )
	surface.DrawTexturedRectRotated( x + bs/2 , y + h -bs/2, bs, bs, 90 )

	if w > 14 then
		surface.DrawRect( x+w-bs, y+bs, bs, h-bs*2 )
		surface.DrawTexturedRectRotated( x + w - bs/2 , y + bs/2, bs, bs, 270 )
		surface.DrawTexturedRectRotated( x + w - bs/2 , y + h - bs/2, bs, bs, 180 )
	else
		surface.DrawRect( x + math.max(w-bs, bs), y, bs/2, h )
	end
end

---- The bar painting is loosely based on:
---- http://wiki.garrysmod.com/?title=Creating_a_HUD

-- Paints a graphical meter bar
local function PaintBar(x, y, w, h, colors, value)
	-- Fill
	local width = w * math.Clamp(value, 0, 1)

	if width > 0 then
		RoundedMeter(0, x, y, width, h, colors.fill)
	end
end

local roundstate_string = {
	[ROUND_WAIT]   = "round_wait",
	[ROUND_PREP]   = "round_prep",
	[ROUND_ACTIVE] = "round_active",
	[ROUND_POST]   = "round_post"
};

-- Returns player's ammo information
local function GetAmmo(ply)
	local weap = ply:GetActiveWeapon()
	if not weap or not ply:Alive() then return -1 end

	local ammo_inv = weap:Ammo1() or 0
	local ammo_clip = weap:Clip1() or 0
	local ammo_max = weap.Primary.ClipSize or 0

	return ammo_clip, ammo_max, ammo_inv
end

local function DrawBg(x, y, width, height, client)
	-- main bg area, invariant
	-- encompasses entire area
	draw.RoundedBox(0, x, y, width, height, bg_colors.background_main)
end

local blur = Material("pp/blurscreen")
local function DrawBlurRect(x, y, width, height)
	local X, Y = 0, 0

	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("$blur", (1 / 5) * (5))
		blur:Recompute()

		render.UpdateScreenEffectTexture()

		render.SetScissorRect(x, y, x + width, y + height, true)
		surface.DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

local function ShadowedText(text, font, x, y, color, xalign, yalign)
	draw.SimpleText(text, font, x+2, y+2, Color(0, 0, 0, 180), xalign, yalign)
	draw.SimpleText(text, font, x, y, color, xalign, yalign)
end

local margin = 10

-- Paint punch-o-meter
local function PunchPaint(client)
	local L = GetLang()
	local punch = client:GetNWFloat("specpunches", 0)

	local width, height = 200, 25
	local x = ScrW() / 2 - width/2
	local y = margin/2 + height

	PaintBar(x, y, width, height, ammo_colors, punch)

	local color = bg_colors.background_main

	draw.SimpleText(L.punch_title, "HealthAmmo", ScrW() / 2, y, color, TEXT_ALIGN_CENTER)

	draw.SimpleText(L.punch_help, "TabLarge", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)

	local bonus = client:GetNWInt("bonuspunches", 0)
	if bonus != 0 then
		local text
		if bonus < 0 then
			text = interp(L.punch_bonus, {num = bonus})
		else
			text = interp(L.punch_malus, {num = bonus})
		end

		draw.SimpleText(text, "TabLarge", ScrW() / 2, y * 2, COLOR_WHITE, TEXT_ALIGN_CENTER)
	end
end

local key_params = { usekey = Key("+use", "USE") }

local function SpecHUDPaint(client)
	local L = GetLang() -- for fast direct table lookups

	local height  = 32
	local width   = 300

	local x       = margin
	local y = ScrH() - margin - height

	local time_x = x + 150
	local time_y = y + 4

	-- Draw blurred background
	DrawBlurRect(x, y, width, height)

	-- Draw colored background
	draw.RoundedBox(0, x, y, width, height, bg_colors.background_main)

	local text = L[ roundstate_string[GAMEMODE.round_state] ]
	ShadowedText(text, "FontSml", x + margin, y + 5, COLOR_WHITE)

	-- Draw round/prep/post time remaining
	local text = util.SimpleTime(math.max(0, GetGlobalFloat("wntd_round_end", 0) - CurTime()), "%02i:%02i")
	ShadowedText(text, "TimeLeft", time_x + margin, time_y, COLOR_WHITE)

	local tgt = client:GetObserverTarget()
	if IsValid(tgt) and tgt:IsPlayer() then
		ShadowedText(tgt:Nick(), "TimeLeft", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)

	elseif IsValid(tgt) and tgt:GetNWEntity("spec_owner", nil) == client then
		PunchPaint(client)
	else
		ShadowedText(interp(L.spec_help, key_params), "TabLarge", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
	end
end

local wntd_health_label = CreateClientConVar("wntd_health_label", "0", true)

local function InfoPaint(client)
	local L = GetLang()

	local width = 300
	local height = 110

	local x = margin
	local y = ScrH() - margin - height

	-- Draw blurred backgrounds
	DrawBlurRect(x, y, width, height)

	-- Draw colored backgrounds
	DrawBg(x, y, width, height, client)

	local bar_height = 25

	-- Draw health
	local health = math.max(0, client:Health())
	PaintBar(90, ScrH() - 80, 210, bar_height, health_colors, health/100)
	ShadowedText(tostring(health), "HealthAmmo", 100, ScrH() - 76, COLOR_WHITE, TEXT_ALIGN_LEFT)

	-- Draw ammo
	if client:GetActiveWeapon().Primary then
		local ammo_clip, ammo_max, ammo_inv = GetAmmo(client)
		if ammo_clip != -1 then
			PaintBar(90, ScrH() - 45, 210, bar_height, ammo_colors, ammo_clip/ammo_max)
			local text = string.format("%i + %02i", ammo_clip, ammo_inv)

			ShadowedText(text, "HealthAmmo", 100, ScrH() - 41, COLOR_WHITE, TEXT_ALIGN_LEFT)
		end
	end

	-- Draw round state
	local round_state = GAMEMODE.round_state
	local text = L[ roundstate_string[round_state] ]

	ShadowedText(text, "FontSml", 20, ScrH() - 112, COLOR_WHITE, TEXT_ALIGN_LEFT)

	-- Draw round time
	local endtime = GetGlobalFloat("wntd_round_end", 0) - CurTime()
	text = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
	ShadowedText(text, "TimeLeft", 250, ScrH() - 112, COLOR_WHITE, TEXT_ALIGN_LEFT)
end

local function TargetPaint(client)
	if GAMEMODE.round_state == ROUND_ACTIVE then
		local L = GetLang()

		local left = 300
		local width = 110
		local height = 110

		local x = margin*2 + left
		local y = ScrH() - margin - height

		-- Draw blurred background
		DrawBlurRect(x, y, width, height)

		-- Draw colored background
		DrawBg(x, y, width, height, client)

		-- Draw target's text
		ShadowedText('Target', "FontSml", 330, ScrH() - 112, COLOR_WHITE, TEXT_ALIGN_LEFT)
	end
end

-- Draws player model on screen
local function DrawPlayerModel(client, show)

	-- Display player's model
	if !DermaShown then
		PlayerIcon = vgui.Create("SpawnIcon")
		PlayerIcon:SetPos(20, ScrH() - 80)
		PlayerIcon:SetSize(60, 60)
		PlayerIcon:SetToolTip("")
		PlayerIcon:SetModel(client:GetModel())

		DermaShown = true

	end
	PlayerIcon:SetModel(LocalPlayer():GetModel())

	-- Only show player model if not spectating
	if show then
		PlayerIcon:Show()
	else
		PlayerIcon:Hide()
	end
end

-- Draws assigned player model on screen
local function DrawAssignedPlayerModel(client, show)
	
	-- Set assigned player's model if exists
	if GAMEMODE.AssignedPlayer[LocalPlayer()] and IsValid(GAMEMODE.AssignedPlayer[LocalPlayer()]) then
		-- Display assigned player's model
		if !AssignedDermaShown then
			AssignedPlayerIcon = vgui.Create("SpawnIcon")
			AssignedPlayerIcon:SetPos(330, ScrH() - 80)
			AssignedPlayerIcon:SetSize(60, 60)
			AssignedPlayerIcon:SetToolTip("")
			AssignedPlayerIcon:SetModel(GAMEMODE.AssignedPlayer[LocalPlayer()]:GetModel())

			AssignedDermaShown = true
		end
		AssignedPlayerIcon:SetModel(GAMEMODE.AssignedPlayer[LocalPlayer()]:GetModel())

		-- Only show if round is active
		if show and GAMEMODE.round_state == ROUND_ACTIVE then
			AssignedPlayerIcon:Show()
		else
			AssignedPlayerIcon:Hide()
		end
	elseif GAMEMODE.AssignedPlayer[LocalPlayer()] then
		AssignedPlayerIcon:Hide()
	end
end

-- Paints player status HUD element in the bottom left
function GM:HUDPaint()
	local client = LocalPlayer()

	if hook.Call( "HUDShouldDraw", GAMEMODE, "WNTDTargetID" ) then
		hook.Call( "HUDDrawTargetID", GAMEMODE )
	end
	
	if hook.Call( "HUDShouldDraw", GAMEMODE, "WNTDMStack" ) then
		MSTACK:Draw(client)
	end

	if (not client:Alive()) or client:Team() == TEAM_SPEC then
		if hook.Call( "HUDShouldDraw", GAMEMODE, "WNTDSpecHUD" ) then
			SpecHUDPaint(client, false)
			DrawPlayerModel(client, false)
			DrawAssignedPlayerModel(client)
		end
		return
	end
	
	if hook.Call( "HUDShouldDraw", GAMEMODE, "WNTDWSwitch" ) then
		WSWITCH:Draw(client)
	end

	if hook.Call( "HUDShouldDraw", GAMEMODE, "WNTDPickupHistory" ) then
		hook.Call( "HUDDrawPickupHistory", GAMEMODE )
	end

	-- Draw bottom left info panel
	if hook.Call( "HUDShouldDraw", GAMEMODE, "WNTDInfoPanel" ) then
		InfoPaint(client)
		TargetPaint(client)
		DrawPlayerModel(client, true)
		DrawAssignedPlayerModel(client, true)
	end
end

-- Hide the standard HUD stuff
local hud = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}
function GM:HUDShouldDraw(name)
	for k, v in pairs(hud) do
		if name == v then return false end
	end

	return self.BaseClass.HUDShouldDraw(self, name)
end