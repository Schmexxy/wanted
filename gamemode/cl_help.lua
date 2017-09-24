---- Help screen

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

CreateConVar("wntd_spectator_mode", "0", FCVAR_ARCHIVE)
CreateConVar("wntd_mute_team_check", "0")

HELPSCRN = {}

function HELPSCRN:Show()
	local margin = 15

	local dframe = vgui.Create("DFrame")
	local w, h = 630, 470
	dframe:SetSize(w, h)
	dframe:Center()
	dframe:SetTitle(GetTranslation("help_title"))
	dframe:ShowCloseButton(false)

	local dbut = vgui.Create("DButton", dframe)
	local bw, bh = 50, 25
	dbut:SetSize(bw, bh)
	dbut:SetPos(w - bw - margin * 0.5, h - bh - margin/2)
	dbut:SetText(GetTranslation("close"))
	dbut.DoClick = function() dframe:Close() end

	local dtabs = vgui.Create("DPropertySheet", dframe)
	dtabs:SetPos(margin * 0.5, margin * 2)
	dtabs:SetSize(w - margin, h - margin*3 - bh)

	local padding = dtabs:GetPadding()

	padding = padding * 2

	-- Tutorial
	local tutparent = vgui.Create("DPanelList", dtabs)
	tutparent:StretchToParent(0,0,padding,0)
	tutparent:EnableVerticalScrollbar(true)
	tutparent:SetPadding(10)
	tutparent:SetSpacing(20)

	-- Settings
	local dsettings = vgui.Create("DPanelList", dtabs)
	dsettings:StretchToParent(0,0,padding,0)
	dsettings:EnableVerticalScrollbar(true)
	dsettings:SetPadding(10)
	dsettings:SetSpacing(20)

	-- Create pages
	self:CreateTutorial(tutparent, tutparent)
	self:CreateSettings(tutparent, dsettings)
	dtabs:AddSheet(GetTranslation("help_tut"), tutparent, "icon16/book_open.png", false, false, GetTranslation("help_tut_tip"))
	dtabs:AddSheet(GetTranslation("help_settings"), dsettings, "icon16/wrench.png", false, false, GetTranslation("help_settings_tip"))

	dframe:MakePopup()
end


local function ShowWNTDHelp(ply, cmd, args)
	HELPSCRN:Show()
end
concommand.Add("wntd_helpscreen", ShowWNTDHelp)

-- Some spectator mode bookkeeping

local function SpectateCallback(cv, old, new)
	local num = tonumber(new)
	if num and (num == 0 or num == 1) then
		RunConsoleCommand("wntd_spectate", num)
	end
end
cvars.AddChangeCallback("wntd_spectator_mode", SpectateCallback)

local function MuteTeamCallback(cv, old, new)
	local num = tonumber(new)
	if num and (num == 0 or num == 1) then
		RunConsoleCommand("wntd_mute_team", num)
	end
end
cvars.AddChangeCallback("wntd_mute_team_check", MuteTeamCallback)

--- Tutorial
function HELPSCRN:CreateTutorial(parent, page)
	-- Fonts
	surface.CreateFont("FontSml", {
		font = "Roboto",
		size = 20,
		weight = 400
	})
	
	--- How to area
	local dtut = vgui.Create("DForm", page)
	dtut:SetName(GetTranslation("set_title_tut"))
	dtut:Help(GetTranslation("help_tut_text"))

	--- Tips area
	local dtips = vgui.Create("DForm", page)
	dtips:SetName(GetTranslation("set_title_tips"))
	dtips:Help(GetTranslation("help_tips_text"))

	page:AddItem(dtut)
	page:AddItem(dtips)
end

--- Settings
function HELPSCRN:CreateSettings(parent, page)

	--- Interface area
	local dgui = vgui.Create("DForm", page)
	dgui:SetName(GetTranslation("set_title_gui"))

	local cb = nil

	cb = dgui:NumSlider(GetTranslation("set_startpopup"), "wntd_startpopup_duration", 0, 60, 0)
	if cb.Label then
		cb.Label:SetWrap(true)
	end
	cb:SetTooltip(GetTranslation("set_startpopup_tip"))

	cb = dgui:NumSlider(GetTranslation("set_cross_opacity"), "wntd_ironsights_crosshair_opacity", 0, 1, 1)
	if cb.Label then
		cb.Label:SetWrap(true)
	end
	cb:SetTooltip(GetTranslation("set_cross_opacity"))

	cb = dgui:NumSlider(GetTranslation("set_cross_brightness"), "wntd_crosshair_brightness", 0, 1, 1)
	if cb.Label then
		cb.Label:SetWrap(true)
	end

	cb = dgui:NumSlider(GetTranslation("set_cross_size"), "wntd_crosshair_size", 0.1, 3, 1)
	if cb.Label then
		cb.Label:SetWrap(true)
	end

	dgui:CheckBox(GetTranslation("set_cross_disable"), "wntd_disable_crosshair")

	cb = dgui:CheckBox(GetTranslation("set_lowsights"), "wntd_ironsights_lowered")
	cb:SetTooltip(GetTranslation("set_lowsights_tip"))

	cb = dgui:CheckBox(GetTranslation("set_fastsw"), "wntd_weaponswitcher_fast")
	cb:SetTooltip(GetTranslation("set_fastsw_tip"))
		
	cb = dgui:CheckBox(GetTranslation("set_fastsw_menu"), "wntd_weaponswitcher_displayfast")
	cb:SetTooltip(GetTranslation("set_fastswmenu_tip"))

	cb = dgui:CheckBox(GetTranslation("set_wswitch"), "wntd_weaponswitcher_stay")
	cb:SetTooltip(GetTranslation("set_wswitch_tip"))

	cb = dgui:CheckBox(GetTranslation("set_cues"), "wntd_cl_soundcues")

	page:AddItem(dgui)

	--- Gameplay area
	local dplay = vgui.Create("DForm", page)
	dplay:SetName(GetTranslation("set_title_play"))

	cb = dplay:CheckBox(GetTranslation("set_specmode"), "wntd_spectator_mode")
	cb:SetTooltip(GetTranslation("set_specmode_tip"))

	page:AddItem(dplay)

	--- Language area
	local dlanguage = vgui.Create("DForm", page)
	dlanguage:SetName(GetTranslation("set_title_lang"))

	local dlang = vgui.Create("DComboBox", dlanguage)
	dlang:SetConVar("wntd_language")

	dlang:AddChoice("Server default", "auto")
	for _, lang in pairs(LANG.GetLanguages()) do
		dlang:AddChoice(string.Capitalize(lang), lang)
	end
	-- Why is DComboBox not updating the cvar by default?
	dlang.OnSelect = function(idx, val, data)
		RunConsoleCommand("wntd_language", data)
	end
	dlang.Think = dlang.ConVarStringThink

	dlanguage:Help(GetTranslation("set_lang"))
	dlanguage:AddItem(dlang)

	page:AddItem(dlanguage)
end