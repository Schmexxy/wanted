-- Some popup window stuff

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

---- Round start

local function GetTextForRole(role)
	local menukey = Key("+menu_context", "C")

	if role == ROLE_PLAYER then
		return GetTranslation("info_popup_player")
	end
end

local startshowtime = CreateConVar("wntd_startpopup_duration", "17", FCVAR_ARCHIVE)

-- shows info about goal
local function RoundStartPopup()
	-- based on Derma_Message

	if startshowtime:GetInt() <= 0 then return end

	if not LocalPlayer() then return end

	local dframe = vgui.Create( "Panel" )
	dframe:SetDrawOnTop( true )
	dframe:SetMouseInputEnabled(false)
	dframe:SetKeyboardInputEnabled(false)

	local color = Color(0,0,0, 200)
	dframe.Paint = function(s)
		draw.RoundedBox(0, 0, 0, s:GetWide(), s:GetTall(), color)
	end

	local text = GetTextForRole(LocalPlayer():GetRole())

	local dtext = vgui.Create( "DLabel", dframe )
	dtext:SetFont("TabLarge")
	dtext:SetText(text)
	dtext:SizeToContents()
	dtext:SetContentAlignment( 5 )
	dtext:SetTextColor( color_white )

	local w, h = dtext:GetSize()
	local m = 10

	dtext:SetPos(m,m)

	dframe:SetSize( w + m*2, h + m*2 )
	dframe:Center()

	dframe:AlignBottom( 10 )

	timer.Simple(startshowtime:GetInt(), function() dframe:Remove() end)
end
concommand.Add("wntd_cl_startpopup", RoundStartPopup)

--- Idle message

local function IdlePopup()
	local w, h = 300, 180

	local dframe = vgui.Create("DFrame")
	dframe:SetSize(w, h)
	dframe:Center()
	dframe:SetTitle("Idle")
	dframe:SetVisible(true)
	dframe:SetMouseInputEnabled(true)

	local inner = vgui.Create("DPanel", dframe)
	inner:StretchToParent(5, 25, 5, 45)

	local idle_limit = GetGlobalInt("wntd_idle_limit", 300) or 300

	local text = vgui.Create("DLabel", inner)
	text:SetWrap(true)
	text:SetText(GetPTranslation("idle_popup", {num = idle_limit, helpkey = Key("gm_showhelp", "F1")}))
	text:SetDark(true)
	text:StretchToParent(10,5,10,5)

	local bw, bh = 75, 25
	local cancel = vgui.Create("DButton", dframe)
	cancel:SetPos(10, h - 40)
	cancel:SetSize(bw, bh)
	cancel:SetText(GetTranslation("idle_popup_close"))
	cancel.DoClick = function() dframe:Close() end

	local disable = vgui.Create("DButton", dframe)
	disable:SetPos(w - 185, h - 40)
	disable:SetSize(175, bh)
	disable:SetText(GetTranslation("idle_popup_off"))
	disable.DoClick = function()
		RunConsoleCommand("wntd_spectator_mode", "0")
		dframe:Close()
	end

	dframe:MakePopup()

end
concommand.Add("wntd_cl_idlepopup", IdlePopup)

-- Popup which displays at the end of the round
function RoundEndPopup()
	-- font
	surface.CreateFont("PopupText", {
		font = "Roboto",
		size = 24,
		weight = 400
	})

	local w, h = 600, 120
	local wonPlayers = GAMEMODE.WonPlayers or {}
	local wonScore = GAMEMODE.WonScore or 0

	local panel = vgui.Create("DPanel")
	panel:SetSize(w, h)
	panel:Center()
	panel:SetVisible(true)
	panel:SetBackgroundColor(Color(0, 0, 10, 220))

	local text = vgui.Create("DLabel", panel)
	text:SetFont("PopupText")
	text:SetWrap(true)
	text:SetBright(true)
	text:StretchToParent(30,5,30,30)

	if wonScore > 0 then
		if #wonPlayers > 1 then
			text:SetText(GetPTranslation("win_time_draw", { score = wonScore, names = table.concat(wonPlayers, ", ") }))
		else
			text:SetText(GetPTranslation("win_time", { score = wonScore, names = wonPlayers[1] }))
		end
	else
		text:SetText(GetTranslation("win_time_noscore"))
	end

	local bw, bh = 50, 25
	local cancel = vgui.Create("DButton", panel)
	cancel:SetPos((w - bw) / 2, h - 33)
	cancel:SetSize(bw, bh)
	cancel:SetText(GetTranslation("close"))
	cancel.DoClick = function() panel:Remove() end

	panel:MakePopup()
end
hook.Add("WNTDEndRound", "Display round end popup", RoundEndPopup)