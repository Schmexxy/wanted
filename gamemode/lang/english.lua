---- English language strings

local L = LANG.CreateLanguage("English")

--- General text used in various places
L.traitor    = "Traitor"
L.detective  = "Detective"
L.innocent   = "Innocent"
L.last_words = "Last Words"

L.players = "Players"
L.terrorists = "Terrorists"
L.spectators = "Spectators"

--- Round status messages
L.round_minplayers = "Not enough players to start a new round..."
L.round_voting     = "Vote in progress, delaying new round by {num} seconds..."
L.round_begintime  = "A new round begins in {num} seconds. Prepare yourself."
L.round_started    = "The round has begun!"
L.round_restart    = "The round has been forced to restart by an admin."

L.round_traitors_one  = "Traitor, you stand alone."
L.round_traitors_more = "Traitor, these are your allies: {names}"

L.win_time         = "{names} wins the round with {score} points!"
L.win_time_draw    = "{names} draw with {score} points!"
L.win_time_noscore = "No one wins this time!"

L.limit_round      = "Round limit reached. {mapname} will load soon."
L.limit_time       = "Time limit reached. {mapname} will load soon."
L.limit_left       = "{num} round(s) or {time} minutes remaining before the map changes to {mapname}."

--- Credit awards
L.credit_det_all   = "Detectives, you have been awarded {num} equipment credit(s) for your performance."
L.credit_tr_all    = "Traitors, you have been awarded {num} equipment credit(s) for your performance."

L.credit_kill      = "You have received {num} credit(s) for killing a {role}."

--- Body identification messages
L.body_found       = "{finder} found the body of {victim}. {role}"

-- The {role} in body_found will be replaced by one of the following:
L.body_found_t     = "They were a Traitor!"
L.body_found_d     = "They were a Detective."
L.body_found_i     = "They were Innocent."

L.body_confirm     = "{finder} confirmed the death of {victim}."

L.body_call        = "{player} called a Detective to the body of {victim}!"
L.body_call_error  = "You must confirm the death of this player before calling a Detective!"

L.body_burning     = "Ouch! This corpse is on fire!"
L.body_credits     = "You found {num} credit(s) on the body!"

--- Menus and windows
L.close = "Close"
L.cancel = "Cancel"

-- For navigation buttons
L.next = "Next"
L.prev = "Previous"

-- Equipment buying menu
L.equip_title     = "Equipment"
L.equip_tabtitle  = "Order Equipment"

L.equip_status    = "Ordering status"
L.equip_cost      = "You have {num} credit(s) remaining."
L.equip_help_cost = "Every piece of equipment you buy costs 1 credit."

L.equip_help_carry = "You can only buy things for which you have room."
L.equip_carry      = "You can carry this equipment."
L.equip_carry_own  = "You are already carrying this item."
L.equip_carry_slot = "You are already carrying a weapon in slot {slot}."

L.equip_help_stock = "Of certain items you can only buy one per round."
L.equip_stock_deny = "This item is no longer in stock."
L.equip_stock_ok   = "This item is in stock."

L.equip_custom     = "Custom item added by this server."

L.equip_spec_name  = "Name"
L.equip_spec_type  = "Type"
L.equip_spec_desc  = "Description"

L.equip_confirm    = "Buy equipment"

-- Transfer tab in equipment menu
L.xfer_name       = "Transfer"
L.xfer_menutitle  = "Transfer credits"
L.xfer_no_credits = "You have no credits to give!"
L.xfer_send       = "Send a credit"
L.xfer_help       = "You can only transfer credits to fellow {role} players."

L.xfer_no_recip   = "Recipient not valid, credit transfer aborted."
L.xfer_no_credits = "Insufficient credits for transfer."
L.xfer_success    = "Credit transfer to {player} completed."
L.xfer_received   = "{player} has given you {num} credit."

-- Radio tab in equipment menu
L.radio_name      = "Radio"
L.radio_help      = "Click a button to make your Radio play that sound."
L.radio_notplaced = "You must place the Radio to play sound on it."

-- Radio soundboard buttons
L.radio_button_scream  = "Scream"
L.radio_button_expl    = "Explosion"
L.radio_button_pistol  = "Pistol shots"
L.radio_button_m16     = "M16 shots"
L.radio_button_deagle  = "Deagle shots"
L.radio_button_mac10   = "MAC10 shots"
L.radio_button_shotgun = "Shotgun shots"
L.radio_button_rifle   = "Rifle shot"
L.radio_button_huge    = "H.U.G.E burst"
L.radio_button_c4      = "C4 beeping"
L.radio_button_burn    = "Burning"
L.radio_button_steps   = "Footsteps"


-- Intro screen shown after joining
L.intro_help     = "If you're new to the game, press F1 for instructions!"

-- Radiocommands/quickchat
L.quick_title   = "Quickchat keys"

L.quick_yes     = "Yes."
L.quick_no      = "No."
L.quick_help    = "Help!"
L.quick_imwith  = "I'm with {player}."
L.quick_see     = "I see {player}."
L.quick_suspect = "{player} acts suspicious."
L.quick_traitor = "{player} is a Traitor!"
L.quick_inno    = "{player} is innocent."
L.quick_check   = "Anyone still alive?"

-- {player} in the quickchat text normally becomes a player nickname, but can
-- also be one of the below.  Keep these lowercase.
L.quick_nobody    = "nobody"
L.quick_corpse    = "an unidentified body"
L.quick_corpse_id = "{player}'s corpse"


--- Body search window
L.search_title  = "Body Search Results"
L.search_info   = "Information"
L.search_confirm = "Confirm Death"
L.search_call   = "Call Detective"

-- Descriptions of pieces of information found
L.search_nick   = "This is the body of {player}."

L.search_role_t = "This person was a Traitor!"
L.search_role_d = "This person was a Detective."
L.search_role_i = "This person was an innocent terrorist."

L.search_words  = "Something tells you some of this person's last words were: '{lastwords}'"
L.search_armor  = "They were wearing nonstandard body armor."
L.search_c4     = "In a pocket you found a note. It states that cutting wire {num} will safely disarm the bomb."

L.search_dmg_crush  = "Many of their bones are broken. It seems the impact of a heavy object killed them."
L.search_dmg_bullet = "It is obvious they were shot to death."
L.search_dmg_fall   = "They fell to their death."
L.search_dmg_boom   = "Their wounds and singed clothes indicate an explosion caused their end."
L.search_dmg_club   = "The body is bruised and battered. Clearly they were clubbed to death."
L.search_dmg_drown  = "The body shows the telltale signs of drowning."
L.search_dmg_stab   = "They were stabbed and cut before quickly bleeding to death."
L.search_dmg_burn   = "Smells like roasted terrorist around here..."
L.search_dmg_tele   = "It looks like their DNA was scrambled by tachyon emissions!"
L.search_dmg_car    = "When this terrorist crossed the road, they were run over by a reckless driver."
L.search_dmg_other  = "You cannot find a specific cause of this terrorist's death."

L.search_weapon = "It appears a {weapon} was used to kill them."
L.search_head   = "The fatal wound was a headshot. No time to scream."
L.search_time   = "They died roughly {time} before you conducted the search."
L.search_dna    = "Retrieve a sample of the killer's DNA with a DNA Scanner. The DNA sample will decay roughly {time} from now."

L.search_kills1 = "You found a list of kills that confirms the death of {player}."
L.search_kills2 = "You found a list of kills with these names:"
L.search_eyes   = "Using your detective skills, you identified the last person they saw: {player}. The killer, or a coincidence?"


-- Scoreboard
L.sb_playing    = "You are playing on..."
L.sb_mapchange  = "Map changes in {num} rounds or in {time}"

L.sb_mia        = "Missing In Action"
L.sb_confirmed  = "Confirmed Dead"

L.sb_ping       = "Ping"
L.sb_deaths     = "Deaths"
L.sb_score      = "Score"

L.sb_info_help  = "Search this player's body, and you can review the results here."

L.sb_tag_friend = "FRIEND"
L.sb_tag_susp   = "SUSPECT"
L.sb_tag_avoid  = "AVOID"
L.sb_tag_kill   = "KILL"
L.sb_tag_miss   = "MISSING"

--- Help and settings menu (F1)

L.help_title = "Help and Settings"

-- Tabs
L.help_tut     = "Tutorial"
L.help_tut_tip = "How Wanted works"
L.help_settings = "Settings"
L.help_settings_tip = "Client-side settings"

-- Tutorial
L.set_title_tut = "How to play"
L.help_tut_text    = "Each player is assigned a target to hunt down, they must find this person by using the provided mugshot shown on screen. \n\nThe aim of the game is to get as many points as you can by discretely killing your assigned targets whilst defending yourself from your pursuer."

-- Tips
L.set_title_tips  = "Tips"
L.help_tips_text = "Over the course of the round, you may get obtain multiple pursuers. So be extra careful to watch your back whilst playing! \n\nTry to refrain from revealing yourself to your target. You don't want to get killed! \n\nYou lose points for killing someone you aren't supposed to, so be careful!"

-- Settings
L.set_title_gui = "Interface settings"

L.set_startpopup = "Start of round info popup duration"
L.set_startpopup_tip = "When the round starts, a small popup appears at the bottom of your screen for a few seconds. Change the time it displays for here."

L.set_cross_opacity   = "Ironsight crosshair opacity"
L.set_cross_disable   = "Disable crosshair completely"
L.set_healthlabel     = "Show health status label on health bar"
L.set_lowsights       = "Lower weapon when using ironsights"
L.set_lowsights_tip   = "Enable to position the weapon model lower on the screen while using ironsights. This will make it easier to see your target, but it will look less realistic."
L.set_fastsw          = "Fast weapon switch"
L.set_fastsw_tip      = "Enable to cycle through weapons without having to click again to use weapon. Enable show menu to show switcher menu."
L.set_fastsw_menu     = "Enable menu with fast weapon switch"
L.set_fastswmenu_tip  = "When fast weapons switch is enabled, the menu switcher menu will popup."
L.set_wswitch         = "Disable weapon switch menu auto-closing"
L.set_wswitch_tip     = "By default the weapon switcher automatically closes a few seconds after you last scroll. Enable this to make it stay up."
L.set_cues            = "Play sound cue when a round begins or ends"


L.set_title_play    = "Gameplay settings"

L.set_specmode      = "Always stay spectator"
L.set_specmode_tip  = "This will prevent you from respawning when a new round starts, instead you stay spectator."


L.set_title_lang    = "Language settings"

-- It may be best to leave this next one english, so english players can always
-- find the language setting even if it's set to a language they don't know.
L.set_lang          = "Select language:"


--- Weapons and equipment, HUD and messages

-- Equipment actions, like buying and dropping
L.buy_no_stock    = "This weapon is out of stock: you already bought it this round."
L.buy_pending     = "You already have an order pending, wait until you receive it."
L.buy_received    = "You have received your special equipment."

L.drop_no_room    = "You have no room here to drop your weapon!"

-- Equipment item descriptions
L.item_passive    = "Passive effect item"
L.item_active     = "Active use item"
L.item_weapon     = "Weapon"

L.item_armor      = "Body Armor"
L.item_armor_desc = [[
Reduces bullet damage by 30% when
you get hit.

Default equipment for Detectives.]]

-- C4
L.c4_hint         = "Press {usekey} to arm or disarm."
L.c4_no_disarm    = "You cannot disarm another Traitor's C4 unless they are dead."
L.c4_disarm_warn  = "A C4 explosive you planted has been disarmed."
L.c4_armed        = "You have successfully armed the bomb."
L.c4_disarmed     = "You have successfully disarmed the bomb."
L.c4_no_room      = "You cannot carry this C4."

L.c4_desc         = "Powerful timed explosive."

L.c4_arm          = "Arm C4"
L.c4_arm_timer    = "Timer"
L.c4_arm_seconds  = "Seconds until detonation:"
L.c4_arm_attempts = "In disarm attempts, {num} of the 6 wires will cause instant detonation when cut."

L.c4_remove_title    = "Removal"
L.c4_remove_pickup   = "Pick up C4"
L.c4_remove_destroy1 = "Destroy C4"
L.c4_remove_destroy2 = "Confirm: destroy"

L.c4_disarm       = "Disarm C4"
L.c4_disarm_cut   = "Click to cut wire {num}"

L.c4_disarm_t     = "Cut a wire to disarm the bomb. As you are Traitor, every wire is safe. Innocents don't have it so easy!"
L.c4_disarm_owned = "Cut a wire to disarm the bomb. It's your bomb, so every wire will disarm it."
L.c4_disarm_other = "Cut a safe wire to disarm the bomb. It will explode if you get it wrong!"

L.c4_status_armed    = "ARMED"
L.c4_status_disarmed = "DISARMED"

-- Visualizer
L.vis_name        = "Visualizer"
L.vis_hint        = "Press {usekey} to pick up (Detectives only)."

L.vis_help_pri    = "{primaryfire} drops the activated device."

L.vis_desc        = [[
Crime scene visualization device.

Analyzes a corpse to show how
the victim was killed, but only if
they died of gunshot wounds.]]

-- Decoy
L.decoy_name      = "Decoy"
L.decoy_no_room   = "You cannot carry this decoy."
L.decoy_broken    = "Your Decoy has been destroyed!"

L.decoy_help_pri  = "{primaryfire} plants the Decoy."

L.decoy_desc      = [[
Shows a fake radar sign to detectives,
and makes their DNA scanner show the
location of the Decoy if they scan for
your DNA.]]

-- Defuser
L.defuser_name    = "Defuser"
L.defuser_help    = "{primaryfire} defuses targeted C4."

L.defuser_desc    = [[
Instantly defuse a C4 explosive.

Unlimited uses. C4 will be easier to
notice if you carry this.]]

-- Flare gun
L.flare_name      = "Flare gun"
L.flare_desc      = [[
Can be used to burn corpses so that
they are never found. Limited ammo.

Burning a corpse makes a distinct
sound.]]

-- Health station
L.hstation_name   = "Health Station"
L.hstation_hint   = "Press {usekey} to receive health. Charge: {num}."
L.hstation_broken = "Your Health Station has been destroyed!"
L.hstation_help   = "{primaryfire} places the Health Station."

L.hstation_desc   = [[
Allows people to heal when placed.

Slow recharge. Anyone can use it, and
it can be damaged. Can be checked for
DNA samples of its users.]]

-- Knife
L.knife_name      = "Knife"
L.knife_thrown    = "Thrown knife"

L.knife_desc      = [[
Kills wounded targets instantly and
silently, but only has a single use.

Can be thrown using alternate fire.]]

-- Poltergeist
L.polter_desc     = [[
Plants thumpers on objects to shove
them around violently.

The energy bursts damage people in
close proximity.]]

-- Radio
L.radio_broken    = "Your Radio has been destroyed!"
L.radio_help_pri  = "{primaryfire} places the Radio."

L.radio_desc      = [[
Plays sounds to distract or deceive.

Place the radio somewhere, and then
play sounds on it using the Radio tab
in this menu.]]

-- Silenced pistol
L.sipistol_name   = "Silenced Pistol"

L.sipistol_desc   = [[
Low-noise handgun, uses normal pistol
ammo.

Victims will not scream when killed.]]

-- Newton launcher
L.newton_name     = "Newton launcher"

L.newton_desc     = [[
Push people from a safe distance.

Infinite ammo, but slow to fire.]]

-- Binoculars
L.binoc_name      = "Binoculars"
L.binoc_desc      = [[
Zoom in on corpses and identify them
from a long distance away.

Unlimited uses, but identification
takes a few seconds.]]

L.binoc_help_pri  = "{primaryfire} identifies a body."
L.binoc_help_sec  = "{secondaryfire} changes zoom level."

-- UMP
L.ump_desc        = [[
Experimental SMG that disorients
targets.

Uses standard SMG ammo.]]

-- DNA scanner
L.dna_name        = "DNA scanner"
L.dna_identify    = "Corpse must be identified to retrieve killer's DNA."
L.dna_notfound    = "No DNA sample found on target."
L.dna_limit       = "Storage limit reached. Remove old samples to add new ones."
L.dna_decayed     = "DNA sample of the killer has decayed."
L.dna_killer      = "Collected a sample of the killer's DNA from the corpse!"
L.dna_no_killer   = "The DNA could not be retrieved (killer disconnected?)."
L.dna_armed       = "This bomb is live! Disarm it first!"
L.dna_object      = "Collected {num} new DNA sample(s) from the object."
L.dna_gone        = "DNA not detected in area."

L.dna_desc        = [[
Collect DNA samples from things
and use them to find the DNA's owner.

Use on fresh corpses to get the killer's DNA
and track them down.]]

L.dna_menu_title  = "DNA scanning controls"
L.dna_menu_sample = "DNA sample found on {source}"
L.dna_menu_remove = "Remove selected"
L.dna_menu_help1  = "These are DNA samples you have collected."
L.dna_menu_help2  = [[
When charged, you can scan for the location of
the player the selected DNA sample belongs to.
Finding distant targets drains more energy.]]

L.dna_menu_scan   = "Scan"
L.dna_menu_repeat = "Auto-repeat"
L.dna_menu_ready  = "READY"
L.dna_menu_charge = "CHARGING"
L.dna_menu_select = "SELECT SAMPLE"

L.dna_help_primary   = "{primaryfire} to collect a DNA sample"
L.dna_help_secondary = "{secondaryfire} to open scan controls"

-- Magneto stick
L.magnet_name     = "Magneto-stick"
L.magnet_help     = "{primaryfire} to attach body to surface."

-- Grenades and misc
L.grenade_smoke   = "Smoke grenade"
L.grenade_fire    = "Incendiary grenade"

L.unarmed_name    = "Holstered"
L.crowbar_name    = "Crowbar"
L.pistol_name     = "Pistol"
L.rifle_name      = "Rifle"
L.shotgun_name    = "Shotgun"

-- Teleporter
L.tele_name       = "Teleporter"
L.tele_failed     = "Teleport failed."
L.tele_marked     = "Teleport location marked."

L.tele_no_ground  = "Cannot teleport unless standing on solid ground!"
L.tele_no_crouch  = "Cannot teleport while crouched!"
L.tele_no_mark    = "No location marked. Mark a destination before teleporting."

L.tele_no_mark_ground = "Cannot mark a teleport location unless standing on solid ground!"
L.tele_no_mark_crouch = "Cannot mark a teleport location while crouched!"

L.tele_help_pri   = "{primaryfire} teleports to marked location."
L.tele_help_sec   = "{secondaryfire} marks current location."

L.tele_desc       = [[
Teleport to a previously marked spot.

Teleporting makes noise, and the
number of uses is limited.]]

-- Ammo names, shown when picked up
L.ammo_pistol     = "9mm ammo"

L.ammo_smg1       = "SMG ammo"
L.ammo_buckshot   = "Shotgun ammo"
L.ammo_357        = "Rifle ammo"
L.ammo_alyxgun    = "Deagle ammo"
L.ammo_ar2altfire = "Flare ammo"
L.ammo_gravity    = "Poltergeist ammo"


--- HUD interface text

-- Round status
L.round_wait   = "Waiting..."
L.round_prep   = "Preparing..."
L.round_active = "In progress"
L.round_post   = "Round over"

-- Health, ammo and time area
L.overtime     = "OVERTIME"
L.hastemode    = "HASTE MODE"

-- TargetID health status
L.hp_healthy   = "Healthy"
L.hp_hurt      = "Hurt"
L.hp_wounded   = "Wounded"
L.hp_badwnd    = "Badly Wounded"
L.hp_death     = "Near Death"

-- TargetID misc
L.corpse       = "Corpse"
L.corpse_hint  = "Press {usekey} to search. {walkkey} + {usekey} to search covertly."

L.target_unid  = "Unidentified body"

L.target_traitor = "FELLOW TRAITOR"
L.target_detective = "DETECTIVE"

L.target_credits = "Search to receive unspent credits"

-- Traitor buttons (HUD buttons with hand icons that only traitors can see)
L.tbut_single  = "Single use"
L.tbut_reuse   = "Reusable"
L.tbut_retime  = "Reusable after {num} sec"
L.tbut_help    = "Press {key} to activate"

-- Spectator muting of living/dead
L.mute_living  = "Living players muted"
L.mute_specs   = "Spectators muted"
L.mute_all     = "All muted"
L.mute_off     = "None muted"

-- Spectators and prop possession
L.punch_title  = "PUNCH-O-METER"
L.punch_help   = "Move keys or jump: punch object. Crouch: leave object."
L.punch_bonus  = "Your bad score lowered your punch-o-meter limit by {num}"
L.punch_malus  = "Your good score increased your punch-o-meter limit by {num}!"

L.spec_help    = "Click to spectate players, or press {usekey} on a physics object to possess it."

--- Info popups shown when the round starts

-- These are spread over multiple lines, hence the square brackets instead of
-- quotes. That's a Lua thing. Every line break (enter) will show up in-game.
L.info_popup_player = [[Go and hunt down your target!]]

--- Various other text
L.name_kick = "A player was automatically kicked for changing their name during a round."

L.idle_popup = [[You were idle for {num} seconds and were moved into Spectator-only mode as a result. While you are in this mode, you will not spawn when a new round starts.

You can toggle Spectator-only mode at any time by pressing {helpkey} and unchecking the box in the Settings tab. You can also choose to disable it right now.]]

L.idle_popup_close = "Do nothing"
L.idle_popup_off   = "Disable Spectator-only mode now"

L.idle_warning = "Warning: you appear to be idle/AFK, and will be made to spectate unless you show activity!"

L.spec_mode_warning = "You are in Spectator Mode and will not spawn when a round starts. To disable this mode, press F1, go to Settings and uncheck 'Spectate-only mode'."

--- Round report
L.report_title = "Round report"

-- Tabs
L.report_tab_hilite = "Highlights"
L.report_tab_hilite_tip = "Round highlights"
L.report_tab_events = "Events"
L.report_tab_events_tip = "Log of the events that happened this round"
L.report_tab_scores = "Scores"
L.report_tab_scores_tip = "Points scored by each player in this round alone"

-- Event log saving
L.report_save     = "Save Log .txt"
L.report_save_tip = "Saves the Event Log to a text file"
L.report_save_error  = "No Event Log data to save."
L.report_save_result = "The Event Log has been saved to:"

-- Big title window
L.hilite_win_player = "THE INNOCENT WIN"

L.hilite_players1 = "{numplayers} players took part, {numtraitors} were traitors"
L.hilite_players2 = "{numplayers} players took part, one of them the traitor"

L.hilite_duration = "The round lasted {time}"

-- Columns
L.col_time   = "Time"
L.col_event  = "Event"
L.col_player = "Player"
L.col_role   = "Role"
L.col_kills1 = "Innocent kills"
L.col_kills2 = "Traitor kills"
L.col_points = "Points"
L.col_team   = "Team bonus"
L.col_total  = "Total points"

-- Name of a trap that killed us that has not been named by the mapper
L.something      = "something"

-- Kill events
L.ev_blowup      = "{victim} blew themselves up"
L.ev_blowup_trap = "{victim} was blown up by {trap}"

L.ev_tele_self   = "{victim} telefragged themselves"
L.ev_sui         = "{victim} couldn't take it and killed themselves"
L.ev_sui_using   = "{victim} killed themselves using {tool}"

L.ev_fall        = "{victim} fell to their death"
L.ev_fall_pushed = "{victim} fell to their death after {attacker} pushed them"
L.ev_fall_pushed_using = "{victim} fell to their death after {attacker} used {trap} to push them"

L.ev_shot        = "{victim} was shot by {attacker}"
L.ev_shot_using  = "{victim} was shot by {attacker} using a {weapon}"

L.ev_drown       = "{victim} was drowned by {attacker}"
L.ev_drown_using = "{victim} was drowned by {trap} triggered by {attacker}"

L.ev_boom        = "{victim} was exploded by {attacker}"
L.ev_boom_using  = "{victim} was blown up by {attacker} using {trap}"

L.ev_burn        = "{victim} was fried by {attacker}"
L.ev_burn_using  = "{victim} was burned by {trap} due to {attacker}"

L.ev_club        = "{victim} was beaten up by {attacker}"
L.ev_club_using  = "{victim} was pummeled to death by {attacker} using {trap}"

L.ev_slash       = "{victim} was stabbed by {attacker}"
L.ev_slash_using = "{victim} was cut up by {attacker} using {trap}"

L.ev_tele        = "{victim} was telefragged by {attacker}"
L.ev_tele_using  = "{victim} was atomized by {trap} set by {attacker}"

L.ev_goomba      = "{victim} was crushed by the massive bulk of {attacker}"

L.ev_crush       = "{victim} was crushed by {attacker}"
L.ev_crush_using = "{victim} was crushed by {trap} of {attacker}"

L.ev_other       = "{victim} was killed by {attacker}"
L.ev_other_using = "{victim} was killed by {attacker} using {trap}"

-- Other events
L.ev_body        = "{finder} found the corpse of {victim}"
L.ev_c4_plant    = "{player} planted C4"
L.ev_c4_boom     = "The C4 planted by {player} exploded"
L.ev_c4_disarm1  = "{player} disarmed C4 planted by {owner}"
L.ev_c4_disarm2  = "{player} failed to disarm C4 planted by {owner}"
L.ev_credit      = "{finder} found {num} credit(s) on the corpse of {player}"

L.ev_start       = "The round started"
L.ev_win_inno    = "The lovable innocent terrorists won the round!"
L.ev_win_time    = "The traitors ran out of time and lost!"

--- Awards/highlights

L.aw_sui1_title = "Suicide Cult Leader"
L.aw_sui1_text  = "showed the other suiciders how to do it by being the first to go."

L.aw_sui2_title = "Lonely and Depressed"
L.aw_sui2_text  = "was the only one who killed themselves."

L.aw_exp1_title = "Explosives Research Grant"
L.aw_exp1_text  = "was recognized for their research on explosions. {num} test subjects helped out."

L.aw_exp2_title = "Field Research"
L.aw_exp2_text  = "tested their own resistance to explosions. It was not high enough."

L.aw_fst1_title = "First Blood"
L.aw_fst1_text  = "delivered the first innocent death at a traitor's hands."

L.aw_fst2_title = "First Bloody Stupid Kill"
L.aw_fst2_text  = "scored the first kill by shooting a fellow traitor. Good job."

L.aw_fst3_title = "First Blooper"
L.aw_fst3_text  = "was the first to kill. Too bad it was an innocent comrade."

L.aw_fst4_title = "First Blow"
L.aw_fst4_text  = "struck the first blow for the innocent terrorists by making the first death a traitor's."

L.aw_all1_title = "Deadliest Among Equals"
L.aw_all1_text  = "was responsible for every kill made by the innocent this round."

L.aw_all2_title = "Lone Wolf"
L.aw_all2_text  = "was responsible for every kill made by a traitor this round."

L.aw_nkt1_title = "I Got One, Boss!"
L.aw_nkt1_text  = "managed to kill a single innocent. Sweet!"

L.aw_nkt2_title = "A Bullet For Two"
L.aw_nkt2_text  = "showed the first one was not a lucky shot by killing another."

L.aw_nkt3_title = "Serial Traitor"
L.aw_nkt3_text  = "ended three innocent lives of terrorism today."

L.aw_nkt4_title = "Wolf Among More Sheep-Like Wolves"
L.aw_nkt4_text  = "eats innocent terrorists for dinner. A dinner of {num} courses."

L.aw_nkt5_title = "Counter-Terrorism Operative"
L.aw_nkt5_text  = "gets paid per kill. Can now buy another luxury yacht."

L.aw_nki1_title = "Betray This"
L.aw_nki1_text  = "found a traitor. Shot a traitor. Easy."

L.aw_nki2_title = "Applied to the Justice Squad"
L.aw_nki2_text  = "escorted two traitors to the great beyond."

L.aw_nki3_title = "Do Traitors Dream Of Traitorous Sheep?"
L.aw_nki3_text  = "put three traitors to rest."

L.aw_nki4_title = "Internal Affairs Employee"
L.aw_nki4_text  = "gets paid per kill. Can now order their fifth swimming pool."

L.aw_fal1_title = "No Mr. Bond, I Expect You To Fall"
L.aw_fal1_text  = "pushed someone off a great height."

L.aw_fal2_title = "Floored"
L.aw_fal2_text  = "let their body hit the floor after falling from a significant altitude."

L.aw_fal3_title = "The Human Meteorite"
L.aw_fal3_text  = "crushed someone by falling on them from a great height."

L.aw_hed1_title = "Efficiency"
L.aw_hed1_text  = "discovered the joy of headshots and made {num}."

L.aw_hed2_title = "Neurology"
L.aw_hed2_text  = "removed the brains from {num} heads for a closer examination."

L.aw_hed3_title = "Videogames Made Me Do It"
L.aw_hed3_text  = "applied their murder simulation training and headshotted {num} foes."

L.aw_cbr1_title = "Thunk Thunk Thunk"
L.aw_cbr1_text  = "has a mean swing with the crowbar, as {num} victims found out."

L.aw_cbr2_title = "Freeman"
L.aw_cbr2_text  = "covered their crowbar in the brains of no less than {num} people."

L.aw_pst1_title = "Persistent Little Bugger"
L.aw_pst1_text  = "scored {num} kills using the pistol. Then they went on to hug someone to death."

L.aw_pst2_title = "Small Caliber Slaughter"
L.aw_pst2_text  = "killed a small army of {num} with a pistol. Presumably installed a tiny shotgun inside the barrel."

L.aw_sgn1_title = "Easy Mode"
L.aw_sgn1_text  = "applies the buckshot where it hurts, murdering {num} targets."

L.aw_sgn2_title = "A Thousand Little Pellets"
L.aw_sgn2_text  = "didn't really like their buckshot, so they gave it all away. {num} recipients did not live to enjoy it."

L.aw_rfl1_title = "Point and Click"
L.aw_rfl1_text  = "shows all you need for {num} kills is a rifle and a steady hand."

L.aw_rfl2_title = "I Can See Your Head From Here"
L.aw_rfl2_text  = "knows their rifle. Now {num} other people know the rifle too."

L.aw_dgl1_title = "It's Like A Tiny Rifle"
L.aw_dgl1_text  = "is getting the hang of the Desert Eagle and killed {num} people."

L.aw_dgl2_title = "Eagle Master"
L.aw_dgl2_text  = "blew away {num} people with the deagle."

L.aw_mac1_title = "Pray and Slay"
L.aw_mac1_text  = "killed {num} people with the MAC10, but won't say how much ammo they needed."

L.aw_mac2_title = "Mac and Cheese"
L.aw_mac2_text  = "wonders what would happen if they could wield two MAC10s. {num} times two?"

L.aw_sip1_title = "Be Quiet"
L.aw_sip1_text  = "shut {num} people up with the silenced pistol."

L.aw_sip2_title = "Silenced Assassin"
L.aw_sip2_text  = "killed {num} people who did not hear themselves die."

L.aw_knf1_title = "Knife Knowing You"
L.aw_knf1_text  = "stabbed someone in the face over the internet."

L.aw_knf2_title = "Where Did You Get That From?"
L.aw_knf2_text  = "was not a Traitor, but still killed someone with a knife."

L.aw_knf3_title = "Such A Knife Man"
L.aw_knf3_text  = "found {num} knives lying around, and made use of them."

L.aw_knf4_title = "World's Knifest Man"
L.aw_knf4_text  = "killed {num} people with a knife. Don't ask me how."

L.aw_flg1_title = "To The Rescue"
L.aw_flg1_text  = "used their flares to signal for {num} deaths."

L.aw_flg2_title = "Flare Indicates Fire"
L.aw_flg2_text  = "taught {num} men about the danger of wearing flammable clothing."

L.aw_hug1_title = "A H.U.G.E Spread"
L.aw_hug1_text  = "was in tune with their H.U.G.E, somehow managing to make their bullets hit {num} people."

L.aw_hug2_title = "A Patient Para"
L.aw_hug2_text  = "just kept firing, and saw their H.U.G.E patience rewarded with {num} kills."

L.aw_msx1_title = "Putt Putt Putt"
L.aw_msx1_text  = "picked off {num} people with the M16."

L.aw_msx2_title = "Mid-range Madness"
L.aw_msx2_text  = "knows how to take down targets with the M16, scoring {num} kills."

L.aw_tkl1_title = "Made An Oopsie"
L.aw_tkl1_text  = "had their finger slip just when they were aiming at a buddy."

L.aw_tkl2_title = "Double-Oops"
L.aw_tkl2_text  = "thought they got a Traitor twice, but was wrong both times."

L.aw_tkl4_title = "Teamkiller"
L.aw_tkl4_text  = "murdered the entirety of their team. OMGBANBANBAN."

L.aw_tkl5_title = "Roleplayer"
L.aw_tkl5_text  = "was roleplaying a madman, honest. That's why they killed most of their team."

L.aw_tkl6_title = "Moron"
L.aw_tkl6_text  = "couldn't figure out which side they were on, and killed over half of their comrades."

L.aw_tkl7_title = "Redneck"
L.aw_tkl7_text  = "protected their turf real good by killing over a quarter of their teammates."

L.aw_brn1_title = "Like Grandma Used To Make Them"
L.aw_brn1_text  = "fried several people to a nice crisp."

L.aw_brn2_title = "Pyroid"
L.aw_brn2_text  = "was heard cackling loudly after burning one of their many victims."

L.aw_brn3_title = "Pyrrhic Burnery"
L.aw_brn3_text  = "burned them all, but is now all out of incendiary grenades! How will they cope!?"

L.aw_fnd1_title = "Coroner"
L.aw_fnd1_text  = "found {num} bodies lying around."

L.aw_fnd2_title = "Gotta Catch Em All"
L.aw_fnd2_text  = "found {num} corpses for their collection."

L.aw_fnd3_title = "Death Scent"
L.aw_fnd3_text  = "keeps stumbling on random corpses, {num} times this round."

L.aw_crd1_title = "Recycler"
L.aw_crd1_text  = "scrounged up {num} leftover credits from corpses."

L.aw_tod1_title = "Pyrrhic Victory"
L.aw_tod1_text  = "died only seconds before their team won the round."

L.aw_tod2_title = "I Hate This Game"
L.aw_tod2_text  = "died right after the start of the round."


--- New and modified pieces of text are placed below this point, marked with the
--- version in which they were added, to make updating translations easier.


--- v23
L.set_avoid_det     = "Avoid being selected as Detective"
L.set_avoid_det_tip = "Enable this to ask the server not to select you as Detective if possible. Does not mean you are Traitor more often."

--- v24
L.drop_no_ammo = "Insufficient ammo in your weapon's clip to drop as an ammo box."

--- v31
L.set_cross_brightness = "Crosshair brightness"
L.set_cross_size = "Crosshair size"

--- 5-25-15
L.hat_retrieve = "You picked up a Detective's hat."
