---- VGUI panel version of the scoreboard, based on TEAM GARRY's sandbox mode
---- scoreboard.

local surface = surface
local draw = draw
local math = math
local string = string
local vgui = vgui

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

include("sb_team.lua")

surface.CreateFont("cool_small", {
	font = "Roboto",
	size = 20,
	weight = 400
})
surface.CreateFont("cool_large", {
	font = "Roboto",
	size = 24,
	weight = 400
})
surface.CreateFont("treb_small", {
	font = "Roboto",
	size = 14,
	weight = 700
})

local PANEL = {}

local max = math.max
local floor = math.floor
local function UntilMapChange()
	local rounds_left = max(0, GetGlobalInt("wntd_rounds_left", 6))
	local time_left = floor(max(0, ((GetGlobalInt("wntd_time_limit_minutes") or 60) * 60) - CurTime()))

	local h = floor(time_left / 3600)
	time_left = time_left - floor(h * 3600)
	local m = floor(time_left / 60)
	time_left = time_left - floor(m * 60)
	local s = floor(time_left)

	return rounds_left, string.format("%02i:%02i:%02i", h, m, s)
end

GROUP_PLAYER = 1
GROUP_SPEC = 2
GROUP_COUNT = 2

function AddScoreGroup(name) -- Utility function to register a score group
	if _G["GROUP_"..name] then error("Group of name '"..name.."' already exists!") return end
	GROUP_COUNT = GROUP_COUNT + 1
	_G["GROUP_"..name] = GROUP_COUNT
end

function ScoreGroup(p)
	if not IsValid(p) then return -1 end -- will not match any group panel

	local group = hook.Call( "WNTDScoreGroup", nil, p )

	if group then -- If that hook gave us a group, use it
		return group
	end

	return p:IsActivePlayer() and GROUP_PLAYER or GROUP_SPEC
end

function PANEL:Init()

	self.hostname = vgui.Create( "DLabel", self )
	self.hostname:SetText( GetHostName() )
	self.hostname:SetContentAlignment(6)

	self.mapchange = vgui.Create("DLabel", self)
	self.mapchange:SetText("Map changes in 00 rounds or in 00:00:00")
	self.mapchange:SetContentAlignment(9)

	self.mapchange.Think = function (sf)
		local r, t = UntilMapChange()

		sf:SetText(GetPTranslation("sb_mapchange",
			{num = r, time = t}))
				sf:SizeToContents()
			end

	self.ply_frame = vgui.Create( "WNTDPlayerFrame", self )

	self.ply_groups = {}

	local t = vgui.Create("WNTDScoreGroup", self.ply_frame:GetCanvas())
	t:SetGroupInfo(GetTranslation("players"), Color(0,200,0,100), GROUP_PLAYER)
	self.ply_groups[GROUP_PLAYER] = t

	t = vgui.Create("WNTDScoreGroup", self.ply_frame:GetCanvas())
	t:SetGroupInfo(GetTranslation("spectators"), Color(200, 200, 0, 100), GROUP_SPEC)
	self.ply_groups[GROUP_SPEC] = t

	hook.Call( "WNTDScoreGroups", nil, self.ply_frame:GetCanvas(), self.ply_groups )

	-- the various score column headers
	self.cols = {}
	self:AddColumn( GetTranslation("sb_ping") )
	self:AddColumn( GetTranslation("sb_deaths") )
	self:AddColumn( GetTranslation("sb_score") )
	
	-- Let hooks add their column headers (via AddColumn())
	hook.Call( "WNTDScoreboardColumns", nil, self )

	self:UpdateScoreboard()
	self:StartUpdateTimer()
end

-- For headings only the label parameter is relevant, func is included for
-- parity with sb_row
function PANEL:AddColumn( label, func, width )
	local lbl = vgui.Create( "DLabel", self )
	lbl:SetText( label )
	lbl.IsHeading = true
	lbl.Width = width or 50 -- Retain compatibility with existing code

	table.insert( self.cols, lbl )
	return lbl
end

function PANEL:StartUpdateTimer()
	if not timer.Exists("WNTDScoreboardUpdater") then
		timer.Create( "WNTDScoreboardUpdater", 0.3, 0,
			function()
				local pnl = GAMEMODE:GetScoreboardPanel()
				if IsValid(pnl) then
					pnl:UpdateScoreboard()
				end
			end)
	end
end

local colors = {
	bg = Color(30,30,30, 235),
	bar = Color(204,0,0,255)
};

local blur = Material("pp/blurscreen")
function DrawBlurRect(x, y, width, height)
	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("$blur", (1 / 5) * (5))
		blur:Recompute()

		render.UpdateScreenEffectTexture()

		render.SetScissorRect(x, y, x + width, y + height, true)
		surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

function PANEL:Paint()
	local x, y = self:GetPos()

	DrawBlurRect(x, y, self:GetWide(), self:GetTall())
	draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), colors.bg)
	draw.RoundedBox(0, 0, 0, self:GetWide(), 32, colors.bar)
end

function PANEL:PerformLayout()
	-- position groups and find their total size
	local gy = 0
	-- can't just use pairs (undefined ordering) or ipairs (group 2 and 3 might not exist)
	for i=1, GROUP_COUNT do
		local group = self.ply_groups[i]
		if IsValid(group) then
			if group:HasRows() then
				group:SetVisible(true)
				group:SetPos(0, gy)
				group:SetSize(self.ply_frame:GetWide(), group:GetTall())
				group:InvalidateLayout()
				gy = gy + group:GetTall() + 5
			else
				group:SetVisible(false)
			end
		end
	end

	self.ply_frame:GetCanvas():SetSize(self.ply_frame:GetCanvas():GetWide(), gy)

	local h = 80 + self.ply_frame:GetCanvas():GetTall()

	-- if we will have to clamp our height, enable the mouse so player can scroll
	local scrolling = h > ScrH() * 0.95
--   gui.EnableScreenClicker(scrolling)
	self.ply_frame:SetScroll(scrolling)

	h = math.Clamp(h, 80, ScrH() * 0.95)

	local w = math.max(ScrW() * 0.6, 640)

	self:SetSize(w, h)
	self:SetPos( (ScrW() - w) / 2, math.min(72, (ScrH() - h) / 4))

	self.ply_frame:SetPos(8, 80)
	self.ply_frame:SetSize(self:GetWide() - 16, self:GetTall() - 80 - 5)

	-- server stuff

	local hw = w - 180 - 8
	self.hostname:SetSize(hw, 32)
	self.hostname:SetPos(w - self.hostname:GetWide() - 8, 0)

	surface.SetFont("cool_large")
	local hname = self.hostname:GetValue()
	local tw, _ = surface.GetTextSize(hname)
	while tw > hw do
		hname = string.sub(hname, 1, -6) .. "..."
		tw, th = surface.GetTextSize(hname)
	end

	self.hostname:SetText(hname)

	self.mapchange:SizeToContents()
	self.mapchange:SetPos(10, 48)

	-- score columns
	local cy = 85
	local cx = w - 8 -(scrolling and 16 or 0)
	for k,v in ipairs(self.cols) do
		v:SizeToContents()
		cx = cx - v.Width
		v:SetPos(cx - v:GetWide()/2, cy)
	end
end

function PANEL:ApplySchemeSettings()
	self.hostname:SetFont("cool_large")
	self.mapchange:SetFont("treb_small")

	self.hostname:SetTextColor(COLOR_WHITE)
	self.mapchange:SetTextColor(COLOR_WHITE)

	for k,v in pairs(self.cols) do
		v:SetFont("treb_small")
		v:SetTextColor(COLOR_WHITE)
	end
end

function PANEL:UpdateScoreboard( force )
	if not force and not self:IsVisible() then return end

	local layout = false

	-- Put players where they belong. Groups will dump them as soon as they don't
	-- anymore.
	for k, p in pairs(player.GetAll()) do
		if IsValid(p) then
			local group = ScoreGroup(p)
			if self.ply_groups[group] and not self.ply_groups[group]:HasPlayerRow(p) then
				self.ply_groups[group]:AddPlayerRow(p)
				layout = true
			end
		end
	end

	for k, group in pairs(self.ply_groups) do
		if IsValid(group) then
			group:SetVisible( group:HasRows() )
			group:UpdatePlayerData()
		end
	end

	if layout then
		self:PerformLayout()
	else
		self:InvalidateLayout()
	end
end

vgui.Register( "WNTDScoreboard", PANEL, "Panel" )

---- PlayerFrame is defined in sandbox and is basically a little scrolling
---- hack. Just putting it here (slightly modified) because it's tiny.

local PANEL = {}
function PANEL:Init()
	self.pnlCanvas  = vgui.Create( "Panel", self )
	self.YOffset = 0

	self.scroll = vgui.Create("DVScrollBar", self)
end

function PANEL:GetCanvas() return self.pnlCanvas end

function PANEL:OnMouseWheeled( dlta )
	self.scroll:AddScroll(dlta * -2)

	self:InvalidateLayout()
end

function PANEL:SetScroll(st)
	self.scroll:SetEnabled(st)
end

function PANEL:PerformLayout()
	self.pnlCanvas:SetVisible(self:IsVisible())

	-- scrollbar
	self.scroll:SetPos(self:GetWide() - 16, 0)
	self.scroll:SetSize(16, self:GetTall())

	local was_on = self.scroll.Enabled
	self.scroll:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
	self.scroll:SetEnabled(was_on) -- setup mangles enabled state

	self.YOffset = self.scroll:GetOffset()

	self.pnlCanvas:SetPos( 0, self.YOffset )
	self.pnlCanvas:SetSize( self:GetWide() - (self.scroll.Enabled and 16 or 0), self.pnlCanvas:GetTall() )
end
vgui.Register( "WNTDPlayerFrame", PANEL, "Panel" )
