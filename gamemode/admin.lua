--- Admin commands
local function GetPrintFn(ply)
	if IsValid(ply) then
		return function(...)
		local t = ""
		for _, a in ipairs({...}) do
			t = t .. "\t" .. a
		end
		ply:PrintMessage(HUD_PRINTCONSOLE, t)
	end
	else
		return print
	end
end

function PrintGroups(ply)
	local pr = GetPrintFn(ply)

	pr("User", "-", "Group")
	for _, p in pairs(player.GetAll()) do
		pr(p:Nick(), "-", p:GetNWString("UserGroup"))
	end
end
concommand.Add("wntd_print_usergroups", PrintGroups)

CreateConVar("wntd_highlight_admins", "1")
local function ApplyHighlightAdmins(cv, old, new)
	SetGlobalBool("wntd_highlight_admins", tobool(tonumber(new)))
end
cvars.AddChangeCallback("wntd_highlight_admins", ApplyHighlightAdmins)


local wntd_bantype = CreateConVar("wntd_ban_type", "autodetect")

local function DetectServerPlugin()
	if ULib and ULib.kickban then
		return "ulx"
	elseif evolve and evolve.Ban then
		return "evolve"
	elseif exsto and exsto.GetPlugin('administration') then
		return "exsto"
	else
		return "gmod"
	end
end

local function StandardBan(ply, length, reason)
	RunConsoleCommand("banid", length, ply:UserID())
	ply:Kick(reason)
end

local ban_functions = {
	ulx = ULib and ULib.kickban, -- has (ply, length, reason) signature

	evolve = function(p, l, r)
		evolve:Ban(p:UniqueID(), l * 60, r) -- time in seconds
	end,

	sm = function(p, l, r)
		game.ConsoleCommand(Format("sm_ban \"#%s\" %d \"%s\"\n", p:SteamID(), l, r))
	end,

	exsto = function(p, l, r)
		local adm = exsto.GetPlugin('administration')
		if adm and adm.Ban then
			adm:Ban(nil, p, l, r)
		end
	end,

	gmod = StandardBan
};

local function BanningFunction()
	local bantype = string.lower(wntd_bantype:GetString())
	if bantype == "autodetect" then
		bantype = DetectServerPlugin()
	end

	print("Banning using " .. bantype .. " method.")

	return ban_functions[bantype] or ban_functions["gmod"]
end

function PerformKickBan(ply, length, reason)
	local banfn = BanningFunction()

	banfn(ply, length, reason)
end
