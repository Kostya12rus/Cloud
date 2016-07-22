--<<Auto Chase + Spell/Item Combo, made by Moones>>

--[[ Moones's Combo Script ]]--
--[[ Protection removed by ensage-forum.ru]]--

local currentVersion = 0.45
local Beta = ""

require("libs.ScriptConfig")
require("libs.Utils")
require("libs.HeroInfo")
require("libs.Animations2")
require("libs.TargetFind")
require("libs.SkillShotBETA")
require("libs.AbilityDamage")
require("libs.DrawManager3D")
require("libs.EasyHUD")

local config = ScriptConfig.new()
config:SetParameter("Chase", "G", config.TYPE_HOTKEY)
config:SetParameter("Retreat", "Z", config.TYPE_HOTKEY)
config:SetParameter("Harras", "B", config.TYPE_HOTKEY)
config:SetParameter("BlinkToggle", "H", config.TYPE_HOTKEY)
config:SetParameter("StackKey", "J", config.TYPE_HOTKEY)
config:SetParameter("KillSteal", false, config.TYPE_BOOL)
config:SetParameter("TargetFindRange", 5000, config.TYPE_NUMBER)
config:SetParameter("TargetClosestToMouse", false, config.TYPE_BOOL)
config:SetParameter("TargetLowestHP", true, config.TYPE_BOOL)
config:SetParameter("MoveToEnemyWhenLocked", false, config.TYPE_BOOL)
config:SetParameter("AutoMoveToEnemy", false, config.TYPE_BOOL)
config:SetParameter("VersionInfoPosX", 630, config.TYPE_NUMBER)
config:SetParameter("VersionInfoPosY", 700, config.TYPE_NUMBER)
config:SetParameter("AutoLock", true, config.TYPE_BOOL)
config:SetParameter("ManualLock", true, config.TYPE_BOOL)
config:SetParameter("UseBlink", true, config.TYPE_BOOL)
config:SetParameter("UseEul", true, config.TYPE_BOOL)
config:SetParameter("EMBERUseUlti", true, config.TYPE_BOOL)
config:SetParameter("Combo1", 49, config.TYPE_HOTKEY) -- 49 is Key Code for 1
config:SetParameter("Combo2", 50, config.TYPE_HOTKEY) -- 50 is Key Code for 2 for all KeyCodes go to http://www.zynox.net/forum/threads/336-KeyCodes
config:SetParameter("Combo3", 51, config.TYPE_HOTKEY) -- 3
config:SetParameter("EnableComboKeys", false, config.TYPE_BOOL)
config:SetParameter("AutoStealRubick", true, config.TYPE_BOOL)
config:Load()
	
local chasekey = config.Chase local blinktoggle = config.BlinkToggle local killsteal = config.KillSteal
local reg = false local myhero = nil local victim = nil local myId = nil local attack = 0 local move = 0 local start = false local resettime = nil local type = nil local channelactive = false local mePosition local atr = nil
local useblink = config.UseBlink local xposition = nil local monitor = client.screenSize.x/1600 local F14 = drawMgr:CreateFont("F14","Tahoma",13*monitor,800*monitor) local statusText = drawMgr:CreateText(10*monitor,580*monitor,99333580,"",F14) statusText.visible = false
local targetlock = false local testX, tinfoHeroSize, tinfoHeroDown, txxB, txxG, rate, con, x_, y_ local click = {} local follow = 0 local indicate = {} local JungleCamps = {} local camp = nil local enemyHP = nil local trolltoggle = false local esstone = false
local campSigns = {} local damageTable = {} local comboTable = {} local retreat = false local statusText2 = drawMgr:CreateText(0,0,-54619000,"",F14) statusText2.visible = false local harras = false local lastPrediction = nil local F12 = drawMgr:CreateFont("F12","Tahoma",12*monitor,800*monitor)
local versionSign = drawMgr:CreateText(client.screenSize.x*config.VersionInfoPosX/1220,client.screenSize.y*config.VersionInfoPosY/1000,0x66FF33FF,"",F14) local infoSign = drawMgr:CreateText(client.screenSize.x*config.VersionInfoPosX/1220,(client.screenSize.y*config.VersionInfoPosY/1000)+20,-1,"",F12) 
local lastCastPrediction = nil local mySpells = nil local HUD = nil local sunstrikeButtonID, sunstrikeButton, coldsnapButtonID, coldsnapButton, chaosmeteorButtonID, chaosmeteorButton, tornadoButtonID, tornadoButton, empButton, empButtonID, forgespiritButtonID, forgespiritButton, icewallButton, icewallButtonID, alacrityButton, alacrityButtonID, ghostwalkButton, ghostwalkButtonID, blastButton, blastButtonID
local KSSS = true local DSS = true local EStoMouse = false local textFont = drawMgr:CreateFont("textFont","Arial",14,400) local tuskSnowBall = false local buttons = {} local combo = 0 local comboready = false local directiontable = {} local PuckPosition = nil local LastCastedTable = {}
local positionsTable = {} local stackTable = {} local lastChakram1 = nil local lastChakram2 = nil local lastTreeID = nil local checked = false local lastOrder = nil local stunAbility = nil local UseStones = true

local itemcomboTable = {
	{ "item_soul_ring", false, nil, false, false, true },
	{ "item_veil_of_discord", false, nil, false, false, true },
	{ "item_cyclone", true, nil, false, false, true },
	{ "item_rod_of_atos", true, nil, false, false, true },
	{ "item_sheepstick", true, nil, false, false, true }, 
	{ "item_orchid", true, nil, false, false, true }, 
	{ "item_diffusal_blade", true, nil, false, false, true }, 
	{ "item_diffusal_blade_2", true, nil, false, false, true }, 
	{ "item_shivas_guard", true, 1000, nil, false, false, true }, 
	{ "item_abyssal_blade", true, nil, false, true, true },
	{ "item_solar_crest" },
	{ "item_medallion_of_courage" },
	{ "item_ethereal_blade", false, nil, false, false, true },
	{ "item_dagon", false, nil, killsteal},
	{ "item_dagon_2", false, nil, killsteal },
	{ "item_dagon_3", false, nil, killsteal },
	{ "item_dagon_4", false, nil, killsteal },
	{ "item_dagon_5", false, nil, killsteal },
	{ "item_urn_of_shadows" },
	--{ "item_armlet", false, 500, false, true },
	{ "item_blade_mail", true, 500, false, true, true },
	{ "item_heavens_halberd", true, 500, false, false, true },
	{ "item_mjollnir", false, 500, false, true, true },
	{ "item_arcane_boots", false, nil, false, true, true },
	{ "item_phase_boots", true, nil, false, true, true },
	{ "item_refresher", false, nil, false, true },
	{ "item_dust", false, 1050, false, true, true }
	--{ "item_force_staff" }
}

local invokerCombo = {
	{ {"invoker_cold_snap"}, {"invoker_ice_wall", 590, true, 1} },
	{ {"invoker_tornado", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_emp", nil, false, 2.9} },
	{ {"invoker_forge_spirit", 700}, {"invoker_sun_strike", nil, false, 1.7}, {"invoker_chaos_meteor", nil, false, 1.3}, {"invoker_alacrity", nil, nil, nil, nil, nil, nil, nil, nil, nil, true} },
	{ {"invoker_deafening_blast", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_ghost_walk", nil, false} },
	{ {"invoker_tornado", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_emp", nil, false, 2.9}, {"invoker_chaos_meteor", nil, false, 1.3}, {"invoker_deafening_blast", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_cold_snap"}  },
	{ {"invoker_tornado", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_sun_strike", nil, false, 1.7}, {"invoker_chaos_meteor", nil, false, 1.3}, {"invoker_deafening_blast", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_cold_snap"}  },
	{ {"invoker_cold_snap"}, {"invoker_chaos_meteor", nil, false, 1.3}, {"invoker_deafening_blast", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_sun_strike", nil, false, 1.7}  }}

local RubickSpellSteals = {}
local RubickNoSpellSteals = {}
local RubickKeepSpellSteals = {}
RubickSpellSteals["batrider_firefly"] = 6
RubickSpellSteals["lone_druid_spirit_bear"] = 10
RubickSpellSteals["leshrac_split_earth"] = 6
RubickSpellSteals["sniper_assassinate"] = 6
RubickSpellSteals["windrunner_powershot"] = 3
RubickSpellSteals["juggernaut_blade_fury"] = 6
RubickSpellSteals["juggernaut_healing_ward"] = 4
RubickSpellSteals["gyrocopter_flak_cannon"] = 4
RubickSpellSteals["mirana_arrow"] = 10
RubickSpellSteals["pudge_meat_hook"] = 10
RubickSpellSteals["spirit_breaker_charge_of_darkness"] = 7
RubickSpellSteals["slark_pounce"] = 6
RubickSpellSteals["broodmother_spin_web"] = 5
RubickSpellSteals["ursa_overpower"] = 7
RubickNoSpellSteals["pudge_rot"] = true
RubickNoSpellSteals["lich_dark_ritual"] = true
RubickNoSpellSteals["bane_enfeeble"] = true
RubickNoSpellSteals["bloodseeker_bloodrage"] = true
RubickNoSpellSteals["drow_ranger_frost_arrows"] = true
RubickNoSpellSteals["earthshaker_enchant_totem"] = true
RubickNoSpellSteals["kunkka_x_marks_the_spot"] = true
RubickNoSpellSteals["viper_poison_attack"] = true
RubickKeepSpellSteals["pudge_meat_hook"] = true

local Trees = {  {position = Vector(-7186.0786132813,-5572.1362304688,261), cutted = false, cutTime = nil},
{position = Vector(-7185.8305664063,-5472.30078125,261), cutted = false, cutTime = nil},
{position = Vector(-7319.3305664063,-5559.0590820313,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7508.1982421875,-5542.0830078125,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7444.701171875,-5403.498046875,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7600.6000976563,-5594.302734375,261), cutted = false, cutTime = nil},
{position = Vector(-7625.7954101563,-5440.2846679688,261), cutted = false, cutTime = nil},
{position = Vector(-7610.3901367188,-5281.3149414063,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7601.3676757813,-5222.5302734375,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7142.66015625,-5210.7416992188,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7307.953125,-5069.0034179688,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7157.87109375,-5038.515625,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7463.7768554688,-5109.7495117188,261), cutted = false, cutTime = nil},
{position = Vector(-7618.7485351563,-5095.7841796875,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7435.7236328125,-4987.3193359375,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7609.2275390625,-4864.7915039063,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7311.498046875,-4872.06640625,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7174.0541992188,-4905.6103515625,260.99975585938), cutted = false, cutTime = nil},
{position = Vector(-7473.8876953125,-4821.5703125,260.99975585938), cutted = false, cutTime = nil},
{position = Vector(-7238.9711914063,-4752.5698242188,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7467.3774414063,-4699.1958007813,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7604.1162109375,-4611.5122070313,261), cutted = false, cutTime = nil},
{position = Vector(-7310.427734375,-4641.8833007813,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7622.0107421875,-4492.8544921875,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7402.435546875,-4513.0991210938,261), cutted = false, cutTime = nil},
{position = Vector(-7197.6215820313,-4521.4536132813,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7029.4677734375,-4394.0048828125,261), cutted = false, cutTime = nil},
{position = Vector(-7238.1586914063,-4375.408203125,261), cutted = false, cutTime = nil},
{position = Vector(-7439.798828125,-4383.8901367188,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7587.1801757813,-4385.5805664063,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7180.2973632813,-4262.5498046875,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7332.0732421875,-4161.1704101563,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7158.591796875,-4044.8137207031,261), cutted = false, cutTime = nil},
{position = Vector(-7326.2451171875,-4051.4797363281,261), cutted = false, cutTime = nil},
{position = Vector(-7498.4262695313,-4054.8012695313,261), cutted = false, cutTime = nil},
{position = Vector(-7621.2817382813,-4056.4592285156,261), cutted = false, cutTime = nil},
{position = Vector(-7154.7504882813,-3924.7761230469,261), cutted = false, cutTime = nil},
{position = Vector(-7477.0239257813,-3930.9587402344,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7636.8916015625,-3922.9614257813,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7338.8344726563,-3869.0302734375,261), cutted = false, cutTime = nil},
{position = Vector(-7552.8422851563,-3776.2392578125,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7171.0151367188,-3807.6772460938,261), cutted = false, cutTime = nil},
{position = Vector(-7344.1684570313,-3754.9592285156,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7479.2143554688,-3666.005859375,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7316.8188476563,-3625.765625,261), cutted = false, cutTime = nil},
{position = Vector(-7598.4965820313,-3598.7153320313,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7457.9140625,-3469.326171875,261), cutted = false, cutTime = nil},
{position = Vector(-7609.3930664063,-3504.0625,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7631.3657226563,-3367.1965332031,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7437.939453125,-3302.5788574219,261), cutted = false, cutTime = nil},
{position = Vector(-7186.7534179688,-3312.4621582031,261), cutted = false, cutTime = nil},
{position = Vector(-7322.3432617188,-3212.1928710938,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7464.9702148438,-3163.9057617188,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7614.0512695313,-3233.1567382813,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7307.748046875,-3038.7390136719,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7458.0205078125,-3037.0275878906,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7613.4072265625,-3023.2624511719,261), cutted = false, cutTime = nil},
{position = Vector(-5821.263671875,-3023.3530273438,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5651.6850585938,-2817.7561035156,128), cutted = false, cutTime = nil},
{position = Vector(-5211.3515625,-2959.9411621094,128), cutted = false, cutTime = nil},
{position = Vector(-4888.9853515625,-3058.9826660156,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5229.0361328125,-3291.2941894531,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5073.8017578125,-3369.6118164063,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4231.2866210938,-4700.8286132813,261), cutted = false, cutTime = nil},
{position = Vector(-4365.625,-4875.1865234375,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3726.3359375,-4818.4482421875,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3679.9814453125,-5059.4970703125,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6243.2807617188,-6537.107421875,267.18273925781), cutted = false, cutTime = nil},
{position = Vector(-5999.80859375,-6584.1743164063,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6238.3090820313,-6664.6708984375,267.19555664063), cutted = false, cutTime = nil},
{position = Vector(-6174.505859375,-6814.2670898438,265.35815429688), cutted = false, cutTime = nil},
{position = Vector(-6009.5180664063,-6731.9565429688,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5938.7001953125,-6882.4853515625,261), cutted = false, cutTime = nil},
{position = Vector(-5856.017578125,-6762.9658203125,261), cutted = false, cutTime = nil},
{position = Vector(-5802.0122070313,-6876.18359375,261), cutted = false, cutTime = nil},
{position = Vector(-6249.791015625,-6956.2456054688,268.11291503906), cutted = false, cutTime = nil},
{position = Vector(-6080.0400390625,-7004.4946289063,305.38171386719), cutted = false, cutTime = nil},
{position = Vector(-5958.0327148438,-7014.0751953125,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5837.19921875,-6996.1098632813,261), cutted = false, cutTime = nil},
{position = Vector(-6242.2563476563,-7127.6557617188,267.03662109375), cutted = false, cutTime = nil},
{position = Vector(-6068.0478515625,-7162.1235351563,261), cutted = false, cutTime = nil},
{position = Vector(-5941.2836914063,-7163.7294921875,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5802.5224609375,-7155.6811523438,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5649.0834960938,-7074.4018554688,261), cutted = false, cutTime = nil},
{position = Vector(-5706.9194335938,-6938.7309570313,261), cutted = false, cutTime = nil},
{position = Vector(-5806.572265625,-6699.130859375,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5632.5888671875,-6663.4555664063,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5656.685546875,-6555.8286132813,261), cutted = false, cutTime = nil},
{position = Vector(-5613.5151367188,-6846.9228515625,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5500.0854492188,-6777.556640625,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5495.2241210938,-6923.5278320313,261), cutted = false, cutTime = nil},
{position = Vector(-5599.142578125,-6957.10546875,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5563.8198242188,-7079.6020507813,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5434.3427734375,-7066.4262695313,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5374.7563476563,-6782.1860351563,261), cutted = false, cutTime = nil},
{position = Vector(-5311.5727539063,-6913.1674804688,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5300.40625,-7084.2680664063,261), cutted = false, cutTime = nil},
{position = Vector(-5259.6323242188,-6767.0151367188,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5112.8696289063,-6860.3227539063,261), cutted = false, cutTime = nil},
{position = Vector(-5175.6044921875,-7002.5317382813,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5134.78125,-7144.5556640625,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5016.609375,-7082.0874023438,261), cutted = false, cutTime = nil},
{position = Vector(-5011.251953125,-6930.3041992188,261), cutted = false, cutTime = nil},
{position = Vector(-4882.0678710938,-6927.2939453125,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4859.4296875,-7133.15234375,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4763.3515625,-7036.3271484375,261), cutted = false, cutTime = nil},
{position = Vector(-4743.8061523438,-6864.94921875,261), cutted = false, cutTime = nil},
{position = Vector(-4665.6279296875,-7154.005859375,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4624.86328125,-6789.5532226563,261), cutted = false, cutTime = nil},
{position = Vector(-4535.7426757813,-6933.4970703125,261), cutted = false, cutTime = nil},
{position = Vector(-4507.1049804688,-7121.412109375,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4431.3618164063,-6710.7436523438,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4392.36328125,-6876.4296875,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4276.7670898438,-6810.8969726563,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4288.138671875,-6975.8959960938,261), cutted = false, cutTime = nil},
{position = Vector(-4347.78515625,-7088.9838867188,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4172.2534179688,-6861.1713867188,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4139.2124023438,-7022.0595703125,261), cutted = false, cutTime = nil},
{position = Vector(-4034.275390625,-6871.3828125,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3876.2470703125,-6942.7124023438,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3903.9951171875,-6745.1650390625,260.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3928.7709960938,-7136.9970703125,261), cutted = false, cutTime = nil},
{position = Vector(-3811.8303222656,-7062.5424804688,261.00024414063), cutted = false, cutTime = nil},
{position = Vector(-3771.0827636719,-6945.0244140625,261), cutted = false, cutTime = nil},
{position = Vector(-3639.6735839844,-7003.2182617188,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3574.0788574219,-6886.373046875,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3560.6293945313,-7135.4194335938,261.00012207031), cutted = false, cutTime = nil},
{position = Vector(-2998.623046875,-6814.927734375,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3395.0029296875,-4904.0747070313,128), cutted = false, cutTime = nil},
{position = Vector(-3500.6184082031,-4748.9912109375,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3579.7075195313,-4581.025390625,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1801.0487060547,-6707.6123046875,128), cutted = false, cutTime = nil},
{position = Vector(-1789.9929199219,-6533.5795898438,128), cutted = false, cutTime = nil},
{position = Vector(-1724.4635009766,-5792.9331054688,127.72375488281), cutted = false, cutTime = nil},
{position = Vector(-1742.7385253906,-5564.49609375,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2014.9470214844,-5331.5434570313,128), cutted = false, cutTime = nil},
{position = Vector(-2286.4138183594,-5195.2504882813,128), cutted = false, cutTime = nil},
{position = Vector(-2089.7902832031,-5068.9702148438,128), cutted = false, cutTime = nil},
{position = Vector(-2248.8369140625,-5014.34765625,128), cutted = false, cutTime = nil},
{position = Vector(-2339.9536132813,-4870.984375,128), cutted = false, cutTime = nil},
{position = Vector(-2505.9331054688,-4780.724609375,128), cutted = false, cutTime = nil},
{position = Vector(-2302.6513671875,-4760.2421875,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2521.6376953125,-4717.8627929688,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-2227.1286621094,-4651.0517578125,128), cutted = false, cutTime = nil},
{position = Vector(-2047.5755615234,-4593.275390625,128.01989746094), cutted = false, cutTime = nil},
{position = Vector(-2505.6806640625,-4596.73046875,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-2377.6477050781,-4572.3354492188,128), cutted = false, cutTime = nil},
{position = Vector(-2159.2260742188,-4516.890625,128), cutted = false, cutTime = nil},
{position = Vector(-2569.4611816406,-4496.728515625,128), cutted = false, cutTime = nil},
{position = Vector(-2436.7719726563,-4485.6201171875,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2308.7580566406,-4372.0283203125,128), cutted = false, cutTime = nil},
{position = Vector(-2117.6936035156,-4388.74609375,128), cutted = false, cutTime = nil},
{position = Vector(-2672.7517089844,-4294.8041992188,128), cutted = false, cutTime = nil},
{position = Vector(-2452.6235351563,-4312.6455078125,128), cutted = false, cutTime = nil},
{position = Vector(-2749.3127441406,-4181.298828125,128), cutted = false, cutTime = nil},
{position = Vector(-3092.2243652344,-4127.05859375,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-2771.2341308594,-4084.9462890625,128), cutted = false, cutTime = nil},
{position = Vector(-3097.4428710938,-3709.3381347656,128), cutted = false, cutTime = nil},
{position = Vector(-2933.0358886719,-3762.3508300781,128), cutted = false, cutTime = nil},
{position = Vector(-2684.4968261719,-3809.5268554688,128), cutted = false, cutTime = nil},
{position = Vector(-2582.3234863281,-3900.6389160156,128), cutted = false, cutTime = nil},
{position = Vector(-2567.4240722656,-3709.1589355469,128), cutted = false, cutTime = nil},
{position = Vector(-2567.3474121094,-4179.421875,128), cutted = false, cutTime = nil},
{position = Vector(-2484.8146972656,-4077.7236328125,128), cutted = false, cutTime = nil},
{position = Vector(-2360.5476074219,-4075.8120117188,128), cutted = false, cutTime = nil},
{position = Vector(-2210.7788085938,-4213.0493164063,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-2035.1164550781,-4271.4155273438,128), cutted = false, cutTime = nil},
{position = Vector(-1975.1362304688,-4320.509765625,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1974.7061767578,-4197.5541992188,128), cutted = false, cutTime = nil},
{position = Vector(-4302.0537109375,-2779.3356933594,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3994.3540039063,-2557.0715332031,128), cutted = false, cutTime = nil},
{position = Vector(-4496.5629882813,-2692.9399414063,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4656.6938476563,-2581.1909179688,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3791.2587890625,-2487.0356445313,128), cutted = false, cutTime = nil},
{position = Vector(-3929.3637695313,-2434.9125976563,128), cutted = false, cutTime = nil},
{position = Vector(-3828.7619628906,-2297.8466796875,128), cutted = false, cutTime = nil},
{position = Vector(-3637.6010742188,-2354.5078125,128), cutted = false, cutTime = nil},
{position = Vector(-3449.5561523438,-2272.7241210938,128), cutted = false, cutTime = nil},
{position = Vector(-3392.705078125,-2141.0688476563,127.96887207031), cutted = false, cutTime = nil},
{position = Vector(-3522.201171875,-1477.4180908203,256), cutted = false, cutTime = nil},
{position = Vector(-3678.8461914063,-1408.0689697266,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3624.6298828125,-1276.7919921875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3493.9350585938,-1261.1296386719,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3464.7810058594,-1121.8997802734,255.98254394531), cutted = false, cutTime = nil},
{position = Vector(-3629.4313964844,-1104.8122558594,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3752.9538574219,-1116.7979736328,256), cutted = false, cutTime = nil},
{position = Vector(-3784.7863769531,-1218.3717041016,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3803.9858398438,-1382.5281982422,256), cutted = false, cutTime = nil},
{position = Vector(-3737.259765625,-1560.0659179688,255.55151367188), cutted = false, cutTime = nil},
{position = Vector(-3999.3684082031,-1342.9375,256), cutted = false, cutTime = nil},
{position = Vector(-3980.1684570313,-1499.8059082031,256), cutted = false, cutTime = nil},
{position = Vector(-3960.7673339844,-1647.8819580078,256), cutted = false, cutTime = nil},
{position = Vector(-4073.0090332031,-1680.3326416016,256), cutted = false, cutTime = nil},
{position = Vector(-4119.5395507813,-1513.9605712891,256), cutted = false, cutTime = nil},
{position = Vector(-4228.8203125,-1561.6994628906,256), cutted = false, cutTime = nil},
{position = Vector(-4444.6767578125,-1543.1534423828,256), cutted = false, cutTime = nil},
{position = Vector(-4554.9731445313,-1558.6051025391,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4563.2568359375,-1426.5749511719,256), cutted = false, cutTime = nil},
{position = Vector(-4879.564453125,-1440.0255126953,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4949.6674804688,-1325.5834960938,256), cutted = false, cutTime = nil},
{position = Vector(-4991.919921875,-1427.6143798828,256), cutted = false, cutTime = nil},
{position = Vector(-5959.6899414063,-1125.3034667969,256), cutted = false, cutTime = nil},
{position = Vector(-6982.2524414063,-1457.3972167969,256), cutted = false, cutTime = nil},
{position = Vector(-7169.9599609375,-1514.3082275391,256), cutted = false, cutTime = nil},
{position = Vector(-7327.5595703125,-1505.8244628906,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7446.353515625,-1527.0234375,300.70690917969), cutted = false, cutTime = nil},
{position = Vector(-7280.0053710938,-1373.4625244141,256), cutted = false, cutTime = nil},
{position = Vector(-7131.3486328125,-1373.4625244141,256), cutted = false, cutTime = nil},
{position = Vector(-7105.30859375,-1251.337890625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7417.6791992188,-1392.6851806641,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7272.9990234375,-1233.2893066406,256), cutted = false, cutTime = nil},
{position = Vector(-7169.4702148438,-1125.2032470703,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7148.166015625,-1140.1008300781,256), cutted = false, cutTime = nil},
{position = Vector(-6995.6342773438,-1130.185546875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6992.8969726563,-1000.4335327148,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7125.9350585938,-1027.4134521484,256), cutted = false, cutTime = nil},
{position = Vector(-7262.2514648438,-973.73034667969,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7030.3349609375,-879.8251953125,256), cutted = false, cutTime = nil},
{position = Vector(-7188.3793945313,-868.14483642578,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7396.4721679688,-794.35858154297,256), cutted = false, cutTime = nil},
{position = Vector(-7121.4370117188,-753.39379882813,256), cutted = false, cutTime = nil},
{position = Vector(-6983.5473632813,-746.15869140625,256), cutted = false, cutTime = nil},
{position = Vector(-6776.1879882813,-712.22979736328,256), cutted = false, cutTime = nil},
{position = Vector(-6923.3032226563,-626.61193847656,256), cutted = false, cutTime = nil},
{position = Vector(-6772.6127929688,-573.91644287109,256), cutted = false, cutTime = nil},
{position = Vector(-7037.4604492188,-579.26721191406,256), cutted = false, cutTime = nil},
{position = Vector(-7171.05859375,-633.50415039063,256), cutted = false, cutTime = nil},
{position = Vector(-7413.6811523438,-602.24353027344,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7375.0991210938,-485.89025878906,256), cutted = false, cutTime = nil},
{position = Vector(-7443.111328125,-328.3576965332,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7309.0844726563,-362.72421264648,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7163.123046875,-383.6083984375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7028.1396484375,-374.00598144531,256), cutted = false, cutTime = nil},
{position = Vector(-6886.7119140625,-378.81497192383,256), cutted = false, cutTime = nil},
{position = Vector(-6677.3774414063,-298.2629699707,256), cutted = false, cutTime = nil},
{position = Vector(-6621.94921875,-180.75323486328,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6841.5307617188,-182.57391357422,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6983.7885742188,-188.02301025391,256), cutted = false, cutTime = nil},
{position = Vector(-7106.1938476563,-230.94860839844,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7249.8134765625,-175.27896118164,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7400.677734375,-153.38180541992,256), cutted = false, cutTime = nil},
{position = Vector(-7303.62890625,-12.097503662109,256), cutted = false, cutTime = nil},
{position = Vector(-7163.20703125,21.743621826172,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7027.3046875,-43.492584228516,256), cutted = false, cutTime = nil},
{position = Vector(-6894.2094726563,7.4053955078125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6747.4555664063,23.545104980469,256), cutted = false, cutTime = nil},
{position = Vector(-6791.2822265625,151.44915771484,256), cutted = false, cutTime = nil},
{position = Vector(-6940.4584960938,161.46127319336,256), cutted = false, cutTime = nil},
{position = Vector(-7186.8403320313,214.26470947266,256), cutted = false, cutTime = nil},
{position = Vector(-7320.7250976563,113.67413330078,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7330.70703125,236.958984375,256), cutted = false, cutTime = nil},
{position = Vector(-7315.3115234375,345.49420166016,256), cutted = false, cutTime = nil},
{position = Vector(-7166.4916992188,328.36016845703,256), cutted = false, cutTime = nil},
{position = Vector(-7047.859375,331.7717590332,256), cutted = false, cutTime = nil},
{position = Vector(-6882.6616210938,274.79080200195,256), cutted = false, cutTime = nil},
{position = Vector(-6756.455078125,271.5048828125,256), cutted = false, cutTime = nil},
{position = Vector(-6845.25390625,382.10757446289,256), cutted = false, cutTime = nil},
{position = Vector(-6976.0791015625,441.43649291992,256), cutted = false, cutTime = nil},
{position = Vector(-7125.375,476.63229370117,256), cutted = false, cutTime = nil},
{position = Vector(-7275.2724609375,480.38259887695,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7319.6459960938,625.7587890625,256), cutted = false, cutTime = nil},
{position = Vector(-7196.9365234375,601.91265869141,256), cutted = false, cutTime = nil},
{position = Vector(-7056.9907226563,585.10534667969,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6879.375,585.10534667969,256), cutted = false, cutTime = nil},
{position = Vector(-6730.0703125,530.93365478516,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6684.908203125,668.62799072266,256), cutted = false, cutTime = nil},
{position = Vector(-6837.5673828125,714.59545898438,256), cutted = false, cutTime = nil},
{position = Vector(-7054.1049804688,783.79602050781,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7282.3017578125,722.66760253906,256), cutted = false, cutTime = nil},
{position = Vector(-7441.8359375,757.05633544922,256), cutted = false, cutTime = nil},
{position = Vector(-7420.1254882813,888.45178222656,256), cutted = false, cutTime = nil},
{position = Vector(-7179.8193359375,851.0107421875,256), cutted = false, cutTime = nil},
{position = Vector(-6902.9135742188,836.9814453125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6799.595703125,936.07897949219,256), cutted = false, cutTime = nil},
{position = Vector(-6859.55078125,1083.3212890625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7058.2319335938,1088.5095214844,256), cutted = false, cutTime = nil},
{position = Vector(-7179.025390625,1052.5572509766,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7416.5888671875,1019.0920410156,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7431.0444335938,1137.4609375,270.08923339844), cutted = false, cutTime = nil},
{position = Vector(-7482.455078125,1258.3818359375,372.91076660156), cutted = false, cutTime = nil},
{position = Vector(-7302.1259765625,1261.3994140625,256), cutted = false, cutTime = nil},
{position = Vector(-6746.4926757813,1237.2618408203,256), cutted = false, cutTime = nil},
{position = Vector(-6907.2631835938,1246.1389160156,256), cutted = false, cutTime = nil},
{position = Vector(-7068.8935546875,1302.1468505859,256), cutted = false, cutTime = nil},
{position = Vector(-7263.560546875,1357.2182617188,256), cutted = false, cutTime = nil},
{position = Vector(-7429.3676757813,1397.1928710938,266.48400878906), cutted = false, cutTime = nil},
{position = Vector(-6832.3828125,1358.6871337891,256), cutted = false, cutTime = nil},
{position = Vector(-7036.7426757813,1495.7045898438,256), cutted = false, cutTime = nil},
{position = Vector(-7203.5209960938,1567.7415771484,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6918.4970703125,1556.7882080078,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7402.1254882813,1628.1033935547,256.87829589844), cutted = false, cutTime = nil},
{position = Vector(-7243.9384765625,1685.5235595703,256), cutted = false, cutTime = nil},
{position = Vector(-7104.1528320313,1679.0482177734,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6939.8725585938,1675.8212890625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6829.2250976563,1685.5234375,256), cutted = false, cutTime = nil},
{position = Vector(-6900.986328125,1823.1202392578,256), cutted = false, cutTime = nil},
{position = Vector(-7050.5595703125,1811.1137695313,256), cutted = false, cutTime = nil},
{position = Vector(-7157.625,1835.0888671875,256), cutted = false, cutTime = nil},
{position = Vector(-7344.0673828125,1822.2529296875,256), cutted = false, cutTime = nil},
{position = Vector(-7456.1088867188,1803.09375,320.21801757813), cutted = false, cutTime = nil},
{position = Vector(-7457.4790039063,2009.9853515625,322.95764160156), cutted = false, cutTime = nil},
{position = Vector(-7300.072265625,2020.2044677734,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7103.4658203125,1936.8308105469,256), cutted = false, cutTime = nil},
{position = Vector(-6909.3608398438,1995.9484863281,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6990.5122070313,2135.8869628906,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-7110.0625,2137.5571289063,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7251.9809570313,2147.6174316406,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-7400.0385742188,2138.705078125,309.41040039063), cutted = false, cutTime = nil},
{position = Vector(-7483.5834960938,2310.7421875,488.89074707031), cutted = false, cutTime = nil},
{position = Vector(-7369.73046875,2390.5529785156,416.61572265625), cutted = false, cutTime = nil},
{position = Vector(-7247.3178710938,2389.744140625,384), cutted = false, cutTime = nil},
{position = Vector(-7081.8588867188,2391.3942871094,384), cutted = false, cutTime = nil},
{position = Vector(-6902.92578125,2339.3720703125,283.94128417969), cutted = false, cutTime = nil},
{position = Vector(-6936.3833007813,2550.0261230469,291.2578125), cutted = false, cutTime = nil},
{position = Vector(-7088.5180664063,2520.9013671875,384), cutted = false, cutTime = nil},
{position = Vector(-7267.056640625,2555.619140625,384), cutted = false, cutTime = nil},
{position = Vector(-7384.263671875,2589.357421875,325.28491210938), cutted = false, cutTime = nil},
{position = Vector(-5966.4052734375,2145.6088867188,256), cutted = false, cutTime = nil},
{position = Vector(-5801.4794921875,2372.2485351563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5827.322265625,2215.0971679688,256), cutted = false, cutTime = nil},
{position = Vector(-5677.4008789063,2371.3322753906,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5589.392578125,2232.7175292969,256), cutted = false, cutTime = nil},
{position = Vector(-5505.6313476563,2387.3732910156,256), cutted = false, cutTime = nil},
{position = Vector(-5454.1489257813,2226.44140625,256), cutted = false, cutTime = nil},
{position = Vector(-5665.443359375,2110.9958496094,256), cutted = false, cutTime = nil},
{position = Vector(-5734.9731445313,1969.9041748047,256), cutted = false, cutTime = nil},
{position = Vector(-5524.6079101563,2050.4125976563,256), cutted = false, cutTime = nil},
{position = Vector(-5380.7426757813,2068.3083496094,256), cutted = false, cutTime = nil},
{position = Vector(-5409.4536132813,1975.3688964844,256), cutted = false, cutTime = nil},
{position = Vector(-5556.0703125,1967.1146240234,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5770.9228515625,1696.09765625,256), cutted = false, cutTime = nil},
{position = Vector(-5603.4018554688,1689.22265625,256), cutted = false, cutTime = nil},
{position = Vector(-5268.8422851563,1788.5073242188,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5194.6313476563,1848.1462402344,256), cutted = false, cutTime = nil},
{position = Vector(-5274.2880859375,1667.6865234375,256), cutted = false, cutTime = nil},
{position = Vector(-5520.1259765625,1548.5190429688,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5700.9765625,1515.5666503906,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5604.19921875,1443.8142089844,256), cutted = false, cutTime = nil},
{position = Vector(-5478.5712890625,1455.4982910156,256), cutted = false, cutTime = nil},
{position = Vector(-5563.0532226563,1309.2218017578,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5440.6962890625,1328.4172363281,256), cutted = false, cutTime = nil},
{position = Vector(-5376.3046875,1400.1430664063,256), cutted = false, cutTime = nil},
{position = Vector(-5298.8916015625,1277.3448486328,256), cutted = false, cutTime = nil},
{position = Vector(-5104.861328125,1491.4686279297,256), cutted = false, cutTime = nil},
{position = Vector(-5020.8881835938,1580.5225830078,256), cutted = false, cutTime = nil},
{position = Vector(-5056.5561523438,1688.5775146484,256), cutted = false, cutTime = nil},
{position = Vector(-5003.93359375,1855.9952392578,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5085.0224609375,1950.5157470703,256), cutted = false, cutTime = nil},
{position = Vector(-4967.9272460938,1996.3070068359,256), cutted = false, cutTime = nil},
{position = Vector(-5100.2739257813,2077.2172851563,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4905.0375976563,2027.5522460938,256), cutted = false, cutTime = nil},
{position = Vector(-5110.556640625,2271.4982910156,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4979.19921875,2250.1811523438,256), cutted = false, cutTime = nil},
{position = Vector(-5144.6787109375,2410.0864257813,256), cutted = false, cutTime = nil},
{position = Vector(-4973.2475585938,2392.03125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4883.255859375,2519.0773925781,-16), cutted = false, cutTime = nil},
{position = Vector(-4781.9536132813,2407.7219238281,-16), cutted = false, cutTime = nil},
{position = Vector(-4653.4833984375,2369.4736328125,-16), cutted = false, cutTime = nil},
{position = Vector(-4661.9868164063,2214.7387695313,256), cutted = false, cutTime = nil},
{position = Vector(-4635.0883789063,2110.0932617188,256), cutted = false, cutTime = nil},
{position = Vector(-4748.013671875,2047.0296630859,256), cutted = false, cutTime = nil},
{position = Vector(-4863.9716796875,1858.6691894531,256), cutted = false, cutTime = nil},
{position = Vector(-4964.669921875,1454.1960449219,256), cutted = false, cutTime = nil},
{position = Vector(-4957.2822265625,1278.1313476563,256), cutted = false, cutTime = nil},
{position = Vector(-4765.533203125,1197.1109619141,256), cutted = false, cutTime = nil},
{position = Vector(-5176.8950195313,1129.6060791016,256), cutted = false, cutTime = nil},
{position = Vector(-5346.3017578125,1143.2635498047,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5522.8461914063,1200.9729003906,256), cutted = false, cutTime = nil},
{position = Vector(-5683.0278320313,1208.1219482422,256), cutted = false, cutTime = nil},
{position = Vector(-5627.8764648438,992.26928710938,256), cutted = false, cutTime = nil},
{position = Vector(-5480.8579101563,1005.7974853516,256), cutted = false, cutTime = nil},
{position = Vector(-5382.2543945313,968.892578125,256), cutted = false, cutTime = nil},
{position = Vector(-5474.16796875,879.00915527344,256), cutted = false, cutTime = nil},
{position = Vector(-5135.81640625,941.00433349609,256), cutted = false, cutTime = nil},
{position = Vector(-5195.3139648438,787.21557617188,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5084.1455078125,847.81799316406,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5075.3188476563,730.63958740234,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4948.564453125,682.494140625,256), cutted = false, cutTime = nil},
{position = Vector(-4917.0419921875,775.38732910156,256), cutted = false, cutTime = nil},
{position = Vector(-4797.5693359375,863.806640625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4828.1103515625,740.25830078125,256), cutted = false, cutTime = nil},
{position = Vector(-4696.74609375,726.62561035156,256), cutted = false, cutTime = nil},
{position = Vector(-4507.3979492188,701.39923095703,256), cutted = false, cutTime = nil},
{position = Vector(-4769.6650390625,560.20434570313,256), cutted = false, cutTime = nil},
{position = Vector(-4603.9267578125,529.07781982422,256), cutted = false, cutTime = nil},
{position = Vector(-4889.7265625,175.36334228516,256), cutted = false, cutTime = nil},
{position = Vector(-4686.7626953125,37.754119873047,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4339.8193359375,-57.018920898438,256), cutted = false, cutTime = nil},
{position = Vector(-4267.4321289063,-153.86892700195,256), cutted = false, cutTime = nil},
{position = Vector(-4368.2060546875,-363.72283935547,256), cutted = false, cutTime = nil},
{position = Vector(-4372.4096679688,-511.29858398438,256), cutted = false, cutTime = nil},
{position = Vector(-4151.9252929688,-479.30920410156,256), cutted = false, cutTime = nil},
{position = Vector(-4251.7534179688,-616.51635742188,256), cutted = false, cutTime = nil},
{position = Vector(-4175.7768554688,-722.25329589844,256), cutted = false, cutTime = nil},
{position = Vector(-4323.5971679688,-746.37548828125,256), cutted = false, cutTime = nil},
{position = Vector(-4240.5258789063,-845.79125976563,256), cutted = false, cutTime = nil},
{position = Vector(-4433.5610351563,-784.47277832031,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5549.6962890625,-597.56359863281,256), cutted = false, cutTime = nil},
{position = Vector(-5383.3461914063,-421.36370849609,256), cutted = false, cutTime = nil},
{position = Vector(-5529.9858398438,-199.9990234375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3730.6721191406,-177.15447998047,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3837.6081542969,-53.760864257813,256), cutted = false, cutTime = nil},
{position = Vector(-3881.9655761719,118.00192260742,256), cutted = false, cutTime = nil},
{position = Vector(-3944.22265625,244.32531738281,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4125.8549804688,331.44485473633,256), cutted = false, cutTime = nil},
{position = Vector(-3756.8557128906,317.82879638672,254.03588867188), cutted = false, cutTime = nil},
{position = Vector(-3857.1049804688,417.98779296875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4088.8393554688,404.77291870117,256), cutted = false, cutTime = nil},
{position = Vector(-3845.7297363281,548.87707519531,256), cutted = false, cutTime = nil},
{position = Vector(-4120.302734375,662.44940185547,256), cutted = false, cutTime = nil},
{position = Vector(-3972.0473632813,684.06030273438,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3979.3627929688,806.88818359375,256), cutted = false, cutTime = nil},
{position = Vector(-3834.5217285156,764.60247802734,255.97021484375), cutted = false, cutTime = nil},
{position = Vector(-3389.5227050781,-576.20434570313,256), cutted = false, cutTime = nil},
{position = Vector(-3262.1882324219,-836.68499755859,256), cutted = false, cutTime = nil},
{position = Vector(-3207.8010253906,-697.65356445313,256), cutted = false, cutTime = nil},
{position = Vector(-3082.4226074219,-665.67443847656,256), cutted = false, cutTime = nil},
{position = Vector(-3295.302734375,-458.40512084961,252.0791015625), cutted = false, cutTime = nil},
{position = Vector(-3078.9462890625,-522.12841796875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3167.1228027344,-376.54455566406,256), cutted = false, cutTime = nil},
{position = Vector(-3011.5288085938,-560.11828613281,256), cutted = false, cutTime = nil},
{position = Vector(-2916.8005371094,-461.9841003418,256), cutted = false, cutTime = nil},
{position = Vector(-3028.8256835938,-364.86962890625,256), cutted = false, cutTime = nil},
{position = Vector(-3144.8994140625,-231.76916503906,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3002.8640136719,-194.69036865234,256), cutted = false, cutTime = nil},
{position = Vector(-2871.107421875,-287.50646972656,256), cutted = false, cutTime = nil},
{position = Vector(-3040.1081542969,-118.93112182617,256), cutted = false, cutTime = nil},
{position = Vector(-2972.0500488281,-1668.7192382813,128.00061035156), cutted = false, cutTime = nil},
{position = Vector(-2784.3022460938,-1784.0401611328,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-2883.2104492188,-1430.4772949219,127.94982910156), cutted = false, cutTime = nil},
{position = Vector(-2667.9362792969,-1469.6142578125,129.29858398438), cutted = false, cutTime = nil},
{position = Vector(-2764.4409179688,-1253.0886230469,128), cutted = false, cutTime = nil},
{position = Vector(-2755.6384277344,-1392.5455322266,128), cutted = false, cutTime = nil},
{position = Vector(-2551.9130859375,-1417.9437255859,128), cutted = false, cutTime = nil},
{position = Vector(-2638.05859375,-1271.2635498047,128), cutted = false, cutTime = nil},
{position = Vector(-2634.4311523438,-1152.3439941406,128), cutted = false, cutTime = nil},
{position = Vector(-2497.2526855469,-1233.8220214844,128), cutted = false, cutTime = nil},
{position = Vector(-2374.2651367188,-1380.0189208984,128), cutted = false, cutTime = nil},
{position = Vector(-2364.3879394531,-1206.5157470703,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2504.7839355469,-1121.6491699219,128), cutted = false, cutTime = nil},
{position = Vector(-2251.4482421875,-1316.3917236328,128), cutted = false, cutTime = nil},
{position = Vector(-2127.01953125,-1224.2327880859,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2404.2348632813,-1066.1149902344,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2274.7897949219,-1088.6430664063,128), cutted = false, cutTime = nil},
{position = Vector(-2289.5251464844,-879.05535888672,134.88305664063), cutted = false, cutTime = nil},
{position = Vector(-2118.2302246094,-1084.9270019531,128.0478515625), cutted = false, cutTime = nil},
{position = Vector(-1964.7847900391,-1191.4379882813,128), cutted = false, cutTime = nil},
{position = Vector(-2002.0993652344,-1103.4855957031,128), cutted = false, cutTime = nil},
{position = Vector(-2203.5268554688,-796.87908935547,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1992.1422119141,-832.59423828125,128), cutted = false, cutTime = nil},
{position = Vector(-1845.0183105469,-1046.9489746094,128), cutted = false, cutTime = nil},
{position = Vector(-1837.5568847656,-762.41442871094,128), cutted = false, cutTime = nil},
{position = Vector(-1958.3435058594,-699.78448486328,128), cutted = false, cutTime = nil},
{position = Vector(-2365.7387695313,-605.23400878906,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2524.4069824219,-511.03503417969,256), cutted = false, cutTime = nil},
{position = Vector(-2160.1701660156,-324.47387695313,255.76428222656), cutted = false, cutTime = nil},
{position = Vector(-2338.1508789063,-255.34906005859,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-2320.6047363281,-134.30126953125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2215.9526367188,-31.505493164063,256), cutted = false, cutTime = nil},
{position = Vector(-2718.9321289063,-2545.8479003906,127.85546875), cutted = false, cutTime = nil},
{position = Vector(-2564.7353515625,-2498.9294433594,128), cutted = false, cutTime = nil},
{position = Vector(-2331.1838378906,-2182.134765625,127.59326171875), cutted = false, cutTime = nil},
{position = Vector(-2182.8747558594,-2229.4719238281,128), cutted = false, cutTime = nil},
{position = Vector(-2029.8176269531,-2141.5500488281,128), cutted = false, cutTime = nil},
{position = Vector(-1873.5673828125,-2113.7966308594,128), cutted = false, cutTime = nil},
{position = Vector(-1838.0935058594,-2300.3161621094,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1993.2279052734,-2312.6916503906,128), cutted = false, cutTime = nil},
{position = Vector(-1978.806640625,-2286.0480957031,128), cutted = false, cutTime = nil},
{position = Vector(-2298.4985351563,-2409.8354492188,128), cutted = false, cutTime = nil},
{position = Vector(-2389.3869628906,-2600.1076660156,128), cutted = false, cutTime = nil},
{position = Vector(-2333.7885742188,-2546.7377929688,128), cutted = false, cutTime = nil},
{position = Vector(-2617.4777832031,-2684.3576660156,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2686.8955078125,-2859.7409667969,128), cutted = false, cutTime = nil},
{position = Vector(-2521.6213378906,-2799.3979492188,128), cutted = false, cutTime = nil},
{position = Vector(-2567.453125,-2949.8510742188,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-2376.2941894531,-2858.0502929688,128), cutted = false, cutTime = nil},
{position = Vector(-2172.3771972656,-2754.7702636719,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2004.0024414063,-2638.1982421875,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1925.4125976563,-2576.498046875,128), cutted = false, cutTime = nil},
{position = Vector(-2220.716796875,-2599.5231933594,128), cutted = false, cutTime = nil},
{position = Vector(-1787.0360107422,-2450.0791015625,127.94921875), cutted = false, cutTime = nil},
{position = Vector(-1638.9957275391,-2424.5590820313,127.60168457031), cutted = false, cutTime = nil},
{position = Vector(-1896.2224121094,-2547.6728515625,128), cutted = false, cutTime = nil},
{position = Vector(-1695.4565429688,-2585.2883300781,127.66784667969), cutted = false, cutTime = nil},
{position = Vector(-1824.3067626953,-2760.5832519531,128), cutted = false, cutTime = nil},
{position = Vector(-1961.7381591797,-2796.0197753906,128), cutted = false, cutTime = nil},
{position = Vector(-2073.8806152344,-3052.7365722656,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2232.7590332031,-3016.1911621094,128), cutted = false, cutTime = nil},
{position = Vector(-2421.5393066406,-3000.2534179688,128), cutted = false, cutTime = nil},
{position = Vector(-2381.5302734375,-3026.7238769531,128), cutted = false, cutTime = nil},
{position = Vector(-2162.046875,-3116.6655273438,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2182.3273925781,-3219.3376464844,128), cutted = false, cutTime = nil},
{position = Vector(-2315.2062988281,-3178.2690429688,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2373.2512207031,-3308.2463378906,128), cutted = false, cutTime = nil},
{position = Vector(-2230.2814941406,-3349.1533203125,128), cutted = false, cutTime = nil},
{position = Vector(-1683.3084716797,-3365.1982421875,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1717.1994628906,-3201.0161132813,128), cutted = false, cutTime = nil},
{position = Vector(-1605.6831054688,-3104.4682617188,128), cutted = false, cutTime = nil},
{position = Vector(-1551.0161132813,-3301.5236816406,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1460.5812988281,-3199.1623535156,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-2024.0073242188,-4028.7509765625,128), cutted = false, cutTime = nil},
{position = Vector(-1859.3522949219,-4068.8708496094,128), cutted = false, cutTime = nil},
{position = Vector(-1775.4858398438,-3892.10546875,128), cutted = false, cutTime = nil},
{position = Vector(-1721.7619628906,-4077.4536132813,128), cutted = false, cutTime = nil},
{position = Vector(-1583.3880615234,-4092.7800292969,128), cutted = false, cutTime = nil},
{position = Vector(-1592.2784423828,-3915.0883789063,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1461.763671875,-4025.2119140625,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1075.5782470703,-4329.4604492188,128), cutted = false, cutTime = nil},
{position = Vector(-898.27136230469,-4344.4306640625,128), cutted = false, cutTime = nil},
{position = Vector(-906.21575927734,-3809.5947265625,128), cutted = false, cutTime = nil},
{position = Vector(-1097.5111083984,-3707.890625,128), cutted = false, cutTime = nil},
{position = Vector(-722.28894042969,-3837.1013183594,128), cutted = false, cutTime = nil},
{position = Vector(-1138.0697021484,-3578.1328125,128), cutted = false, cutTime = nil},
{position = Vector(-888.36383056641,-3671.1625976563,128), cutted = false, cutTime = nil},
{position = Vector(-1004.6013183594,-3513.3278808594,128), cutted = false, cutTime = nil},
{position = Vector(-734.43231201172,-3656.0981445313,128), cutted = false, cutTime = nil},
{position = Vector(-811.20666503906,-3529.8605957031,128), cutted = false, cutTime = nil},
{position = Vector(-615.65631103516,-3515.1733398438,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-756.8681640625,-3450.2358398438,128), cutted = false, cutTime = nil},
{position = Vector(-981.85632324219,-3400.8022460938,128), cutted = false, cutTime = nil},
{position = Vector(-1107.5373535156,-3273.0512695313,128), cutted = false, cutTime = nil},
{position = Vector(-932.05419921875,-3277.0747070313,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1106.8936767578,-3093.6547851563,128), cutted = false, cutTime = nil},
{position = Vector(-984.67199707031,-3077.2255859375,128), cutted = false, cutTime = nil},
{position = Vector(-848.12872314453,-3095.6970214844,128), cutted = false, cutTime = nil},
{position = Vector(-783.21105957031,-3196.5920410156,128), cutted = false, cutTime = nil},
{position = Vector(-642.50390625,-3264.1657714844,128), cutted = false, cutTime = nil},
{position = Vector(-511.27935791016,-3362.0478515625,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-330.09503173828,-3245.8354492188,128), cutted = false, cutTime = nil},
{position = Vector(-655.82177734375,-3194.4431152344,128), cutted = false, cutTime = nil},
{position = Vector(-568.44689941406,-3007.6120605469,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-717.36645507813,-3034.3835449219,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-757.83715820313,-2896.1921386719,128), cutted = false, cutTime = nil},
{position = Vector(-610.68890380859,-2874.0678710938,128), cutted = false, cutTime = nil},
{position = Vector(-900.44573974609,-2905.318359375,128), cutted = false, cutTime = nil},
{position = Vector(-1094.3210449219,-2821.7529296875,128), cutted = false, cutTime = nil},
{position = Vector(-990.22290039063,-2698.0541992188,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-962.37182617188,-2549.4841308594,128), cutted = false, cutTime = nil},
{position = Vector(-822.1142578125,-2644.9086914063,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-918.27062988281,-2452.5151367188,128), cutted = false, cutTime = nil},
{position = Vector(-771.19146728516,-2518.4809570313,128), cutted = false, cutTime = nil},
{position = Vector(-642.93420410156,-2512.2097167969,128), cutted = false, cutTime = nil},
{position = Vector(-799.91174316406,-2312.3779296875,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-926.74212646484,-2305.3017578125,128), cutted = false, cutTime = nil},
{position = Vector(-1069.9835205078,-2363.4147949219,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-76.841125488281,-2992.4777832031,128), cutted = false, cutTime = nil},
{position = Vector(-1362.1395263672,-2124.7053222656,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1478.029296875,-2135.3764648438,128), cutted = false, cutTime = nil},
{position = Vector(-1586.2734375,-1895.4633789063,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1388.9436035156,-1916.1867675781,128), cutted = false, cutTime = nil},
{position = Vector(-1151.3430175781,-1999.9559326172,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-977.00640869141,-1949.5122070313,128), cutted = false, cutTime = nil},
{position = Vector(-1071.8168945313,-1783.4992675781,128), cutted = false, cutTime = nil},
{position = Vector(-1590.6811523438,-1783.4991455078,128), cutted = false, cutTime = nil},
{position = Vector(-1465.1049804688,-1744.2602539063,128), cutted = false, cutTime = nil},
{position = Vector(-1343.7010498047,-1784.5677490234,128), cutted = false, cutTime = nil},
{position = Vector(-1360.5789794922,-1635.7030029297,128), cutted = false, cutTime = nil},
{position = Vector(-1558.4282226563,-1702.8486328125,128), cutted = false, cutTime = nil},
{position = Vector(-956.3232421875,-1833.8837890625,128), cutted = false, cutTime = nil},
{position = Vector(-823.09332275391,-1754.22265625,126.91772460938), cutted = false, cutTime = nil},
{position = Vector(-862.01617431641,-1595.9555664063,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-696.91076660156,-1495.2563476563,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-850.22229003906,-1300.9831542969,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-992.15344238281,-1231.3443603516,128), cutted = false, cutTime = nil},
{position = Vector(-1141.107421875,-1300.9831542969,128), cutted = false, cutTime = nil},
{position = Vector(-1175.0340576172,-1536.7028808594,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(-82.474159240723,-1437.6442871094,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(10.016674041748,-1583.6276855469,128), cutted = false, cutTime = nil},
{position = Vector(136.85687255859,-1544.1176757813,128), cutted = false, cutTime = nil},
{position = Vector(209.94931030273,-1652.0102539063,128), cutted = false, cutTime = nil},
{position = Vector(-198.75,-1681.2720947266,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(40.06392288208,-1784.109375,128), cutted = false, cutTime = nil},
{position = Vector(-103.44045257568,-1723.2286376953,128), cutted = false, cutTime = nil},
{position = Vector(-138.18545532227,-1847.8623046875,128), cutted = false, cutTime = nil},
{position = Vector(-273.52346801758,-1837.4227294922,128), cutted = false, cutTime = nil},
{position = Vector(-374.44134521484,-1962.8889160156,128), cutted = false, cutTime = nil},
{position = Vector(-191.10469055176,-2147.7775878906,127.98913574219), cutted = false, cutTime = nil},
{position = Vector(-17.688247680664,-2173.0246582031,128), cutted = false, cutTime = nil},
{position = Vector(-54.321166992188,-2332.2145996094,127.13671875), cutted = false, cutTime = nil},
{position = Vector(364.66510009766,-2033.2602539063,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(357.51342773438,-2166.4743652344,256), cutted = false, cutTime = nil},
{position = Vector(356.25924682617,-2321.80078125,256), cutted = false, cutTime = nil},
{position = Vector(533.18725585938,-2334.8237304688,256), cutted = false, cutTime = nil},
{position = Vector(625.70971679688,-2174.5161132813,240.44274902344), cutted = false, cutTime = nil},
{position = Vector(260.89431762695,-2911.591796875,256), cutted = false, cutTime = nil},
{position = Vector(132.435546875,-2876.595703125,255.57458496094), cutted = false, cutTime = nil},
{position = Vector(214.19253540039,-3030.9780273438,256), cutted = false, cutTime = nil},
{position = Vector(339.99493408203,-3057.2199707031,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(450.98983764648,-2975.2216796875,256), cutted = false, cutTime = nil},
{position = Vector(502.31890869141,-3181.7175292969,256), cutted = false, cutTime = nil},
{position = Vector(613.41027832031,-3340.3798828125,256), cutted = false, cutTime = nil},
{position = Vector(444.93392944336,-3376.0751953125,256), cutted = false, cutTime = nil},
{position = Vector(336.52151489258,-3266.2683105469,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(192.32110595703,-3167.1948242188,256), cutted = false, cutTime = nil},
{position = Vector(233.83880615234,-3413.4306640625,256), cutted = false, cutTime = nil},
{position = Vector(218.37445068359,-3308.6767578125,256), cutted = false, cutTime = nil},
{position = Vector(105.17172241211,-3244.8278808594,256), cutted = false, cutTime = nil},
{position = Vector(-31.053756713867,-3201.9020996094,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(130.66516113281,-3399.92578125,256), cutted = false, cutTime = nil},
{position = Vector(-44.030982971191,-3331.7485351563,256), cutted = false, cutTime = nil},
{position = Vector(47.205688476563,-3529.4694824219,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(488.72332763672,-3650.1376953125,256), cutted = false, cutTime = nil},
{position = Vector(334.18127441406,-3672.1513671875,256), cutted = false, cutTime = nil},
{position = Vector(201.11961364746,-3665.8972167969,256), cutted = false, cutTime = nil},
{position = Vector(37.554580688477,-3696.8901367188,256), cutted = false, cutTime = nil},
{position = Vector(-191.27545166016,-3553.4091796875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-287.49865722656,-3584.4914550781,256), cutted = false, cutTime = nil},
{position = Vector(-289.60696411133,-3580.8413085938,256), cutted = false, cutTime = nil},
{position = Vector(-114.13882446289,-3686.6313476563,256), cutted = false, cutTime = nil},
{position = Vector(-24.083435058594,-3865.4768066406,256), cutted = false, cutTime = nil},
{position = Vector(-220.4701385498,-3882.1186523438,256), cutted = false, cutTime = nil},
{position = Vector(-408.76766967773,-3858.9133300781,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-450.86828613281,-3964.5600585938,256), cutted = false, cutTime = nil},
{position = Vector(-549.58508300781,-3998.1530761719,256), cutted = false, cutTime = nil},
{position = Vector(-612.77410888672,-4244.21484375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-635.55157470703,-4411.8686523438,256), cutted = false, cutTime = nil},
{position = Vector(-691.56732177734,-4534.6118164063,256), cutted = false, cutTime = nil},
{position = Vector(-829.98016357422,-4553.3715820313,256), cutted = false, cutTime = nil},
{position = Vector(-975.62268066406,-4532.5595703125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1103.1921386719,-4630.3237304688,256), cutted = false, cutTime = nil},
{position = Vector(-1096.0889892578,-4790.927734375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1182.8547363281,-4756.6767578125,256), cutted = false, cutTime = nil},
{position = Vector(-916.54040527344,-4711.6704101563,256), cutted = false, cutTime = nil},
{position = Vector(-1293.6904296875,-4682.1455078125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1352.8190917969,-4800.3627929688,256), cutted = false, cutTime = nil},
{position = Vector(-1493.2489013672,-4769.904296875,297.52233886719), cutted = false, cutTime = nil},
{position = Vector(-1181.3641357422,-4928.7861328125,256), cutted = false, cutTime = nil},
{position = Vector(-1340.1745605469,-4949.3657226563,256), cutted = false, cutTime = nil},
{position = Vector(-1500.0144042969,-4907.1181640625,256), cutted = false, cutTime = nil},
{position = Vector(-1452.2155761719,-5120.939453125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1328.8973388672,-5221.75390625,256), cutted = false, cutTime = nil},
{position = Vector(-1032.3063964844,-5906.9248046875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-827.13916015625,-5878.2749023438,256), cutted = false, cutTime = nil},
{position = Vector(-923.8388671875,-5738.3134765625,256), cutted = false, cutTime = nil},
{position = Vector(-835.60473632813,-5604.236328125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-671.59753417969,-5710.3642578125,256), cutted = false, cutTime = nil},
{position = Vector(-485.70526123047,-5756.951171875,256), cutted = false, cutTime = nil},
{position = Vector(-666.59381103516,-5604.5834960938,256), cutted = false, cutTime = nil},
{position = Vector(-836.26623535156,-5504.6259765625,256), cutted = false, cutTime = nil},
{position = Vector(-402.25036621094,-5599.3940429688,256), cutted = false, cutTime = nil},
{position = Vector(-755.74676513672,-5352.0673828125,256), cutted = false, cutTime = nil},
{position = Vector(-576.38891601563,-5452.2529296875,256), cutted = false, cutTime = nil},
{position = Vector(-438.26031494141,-5457.2548828125,256), cutted = false, cutTime = nil},
{position = Vector(-588.84759521484,-5278.8837890625,256), cutted = false, cutTime = nil},
{position = Vector(-422.37673950195,-5339.5107421875,256), cutted = false, cutTime = nil},
{position = Vector(-300.17004394531,-5366.2919921875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-531.24700927734,-5123.552734375,256), cutted = false, cutTime = nil},
{position = Vector(-369.93707275391,-5212.4853515625,256), cutted = false, cutTime = nil},
{position = Vector(-459.11303710938,-5024.0434570313,256), cutted = false, cutTime = nil},
{position = Vector(-284.35757446289,-5164.17578125,256), cutted = false, cutTime = nil},
{position = Vector(-110.91970825195,-5259.2158203125,256), cutted = false, cutTime = nil},
{position = Vector(34.482299804688,-5200.9624023438,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-187.43408203125,-5035.1528320313,256), cutted = false, cutTime = nil},
{position = Vector(-397.1667175293,-4953.7216796875,256), cutted = false, cutTime = nil},
{position = Vector(-281.82229614258,-4830.513671875,256), cutted = false, cutTime = nil},
{position = Vector(-59.652858734131,-4921.4067382813,256), cutted = false, cutTime = nil},
{position = Vector(187.10214233398,-5045.404296875,256), cutted = false, cutTime = nil},
{position = Vector(110.85439300537,-4937.2666015625,256), cutted = false, cutTime = nil},
{position = Vector(-142.53042602539,-4766.9853515625,256), cutted = false, cutTime = nil},
{position = Vector(-187.798828125,-4626.6337890625,256), cutted = false, cutTime = nil},
{position = Vector(81.629486083984,-4800.13671875,256), cutted = false, cutTime = nil},
{position = Vector(193.75354003906,-4835.9365234375,256), cutted = false, cutTime = nil},
{position = Vector(270.4670715332,-4947.7192382813,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(367.453125,-4854.3461914063,256), cutted = false, cutTime = nil},
{position = Vector(142.50152587891,-4616.6420898438,256), cutted = false, cutTime = nil},
{position = Vector(358.07678222656,-4637.1630859375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(506.1598815918,-4805.3041992188,256), cutted = false, cutTime = nil},
{position = Vector(338.74658203125,-4499.8247070313,256), cutted = false, cutTime = nil},
{position = Vector(467.4228515625,-4480.5502929688,256), cutted = false, cutTime = nil},
{position = Vector(508.87640380859,-4628.1235351563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(687.68389892578,-4597.5004882813,256), cutted = false, cutTime = nil},
{position = Vector(502.72714233398,-4377.1201171875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(616.68792724609,-4305.7524414063,256), cutted = false, cutTime = nil},
{position = Vector(742.54150390625,-4440.3237304688,256), cutted = false, cutTime = nil},
{position = Vector(833.71044921875,-4382.2099609375,256), cutted = false, cutTime = nil},
{position = Vector(779.8193359375,-4243.8520507813,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(816.24890136719,-4120.0947265625,256), cutted = false, cutTime = nil},
{position = Vector(953.22766113281,-4269.0874023438,256), cutted = false, cutTime = nil},
{position = Vector(1018.4309082031,-4368.9731445313,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(1151.1384277344,-4259.044921875,256), cutted = false, cutTime = nil},
{position = Vector(1118.8383789063,-5312.4423828125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(936.90423583984,-5150.5766601563,256), cutted = false, cutTime = nil},
{position = Vector(1079.0373535156,-5114.4204101563,256), cutted = false, cutTime = nil},
{position = Vector(1644.3024902344,-5681.4350585938,256), cutted = false, cutTime = nil},
{position = Vector(985.86102294922,-6027.576171875,256), cutted = false, cutTime = nil},
{position = Vector(844.13244628906,-6051.5043945313,256), cutted = false, cutTime = nil},
{position = Vector(684.12780761719,-6007.7416992188,256), cutted = false, cutTime = nil},
{position = Vector(515.84204101563,-5994.388671875,256), cutted = false, cutTime = nil},
{position = Vector(373.53350830078,-6131.61328125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1355.6146240234,-6677.5727539063,256), cutted = false, cutTime = nil},
{position = Vector(-1381.3149414063,-6865.185546875,255.93615722656), cutted = false, cutTime = nil},
{position = Vector(-1509.1556396484,-6798.7138671875,255.98266601563), cutted = false, cutTime = nil},
{position = Vector(-1486.0686035156,-6977.6723632813,256), cutted = false, cutTime = nil},
{position = Vector(-1166.6223144531,-6884.0786132813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1091.7518310547,-6742.8603515625,256), cutted = false, cutTime = nil},
{position = Vector(-1040.8530273438,-6916.5043945313,256), cutted = false, cutTime = nil},
{position = Vector(-1016.7479248047,-6792.5122070313,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-954.37115478516,-6668.2026367188,256), cutted = false, cutTime = nil},
{position = Vector(-982.91015625,-6917.5986328125,256), cutted = false, cutTime = nil},
{position = Vector(-853.84625244141,-6842.8208007813,256), cutted = false, cutTime = nil},
{position = Vector(-837.80181884766,-6692.677734375,256), cutted = false, cutTime = nil},
{position = Vector(-772.02355957031,-7005.9565429688,256), cutted = false, cutTime = nil},
{position = Vector(-702.79223632813,-6842.8208007813,256), cutted = false, cutTime = nil},
{position = Vector(-726.11871337891,-6707.98828125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-671.17712402344,-7015.439453125,256), cutted = false, cutTime = nil},
{position = Vector(-590.03564453125,-6857.7016601563,256), cutted = false, cutTime = nil},
{position = Vector(-608.23199462891,-6724.359375,256), cutted = false, cutTime = nil},
{position = Vector(-483.21710205078,-7039.9116210938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-416.62731933594,-6923.8334960938,256), cutted = false, cutTime = nil},
{position = Vector(-444.30828857422,-6782.8857421875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-444.30267333984,-6659.505859375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-358.92266845703,-7050.171875,256), cutted = false, cutTime = nil},
{position = Vector(-227.79067993164,-6907.578125,256), cutted = false, cutTime = nil},
{position = Vector(-273.46603393555,-6742.3793945313,256), cutted = false, cutTime = nil},
{position = Vector(-248.94021606445,-6579.1962890625,256), cutted = false, cutTime = nil},
{position = Vector(-127.38027954102,-6721.4150390625,256), cutted = false, cutTime = nil},
{position = Vector(-61.629302978516,-6857.376953125,256), cutted = false, cutTime = nil},
{position = Vector(-53.993743896484,-7030.1352539063,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(15.923156738281,-6994.8012695313,256), cutted = false, cutTime = nil},
{position = Vector(25.975395202637,-6828.0400390625,256), cutted = false, cutTime = nil},
{position = Vector(87.696670532227,-6689.333984375,256), cutted = false, cutTime = nil},
{position = Vector(235.92297363281,-6784.3920898438,256), cutted = false, cutTime = nil},
{position = Vector(217.87738037109,-7021.4624023438,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(210.87200927734,-6757.2333984375,256), cutted = false, cutTime = nil},
{position = Vector(344.65670776367,-6886.8408203125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(445.92794799805,-7037.3491210938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(536.09295654297,-6821.828125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(585.99700927734,-7034.8305664063,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(757.86938476563,-6876.6416015625,256), cutted = false, cutTime = nil},
{position = Vector(769.11010742188,-6755.6674804688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(941.64337158203,-6843.2763671875,256), cutted = false, cutTime = nil},
{position = Vector(977.75927734375,-7017.6196289063,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(1041.7009277344,-6822.2250976563,256), cutted = false, cutTime = nil},
{position = Vector(1024.5831298828,-6649.7626953125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(1085.6889648438,-7006.1142578125,256), cutted = false, cutTime = nil},
{position = Vector(1105.4945068359,-6857.8120117188,256), cutted = false, cutTime = nil},
{position = Vector(1212.6385498047,-7002.8203125,256), cutted = false, cutTime = nil},
{position = Vector(1279.4250488281,-6902.1323242188,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(1265.3088378906,-6873.3002929688,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(1216.7415771484,-6695.7338867188,256), cutted = false, cutTime = nil},
{position = Vector(1358.0834960938,-6722.3559570313,256), cutted = false, cutTime = nil},
{position = Vector(1516.7452392578,-6656.6313476563,256), cutted = false, cutTime = nil},
{position = Vector(1547.3876953125,-6842.6845703125,256), cutted = false, cutTime = nil},
{position = Vector(1672.5810546875,-6832.0112304688,256), cutted = false, cutTime = nil},
{position = Vector(1653.1284179688,-6628.5004882813,256), cutted = false, cutTime = nil},
{position = Vector(1805.103515625,-6642.6259765625,256), cutted = false, cutTime = nil},
{position = Vector(1820.5874023438,-6874.2690429688,256), cutted = false, cutTime = nil},
{position = Vector(1885.7883300781,-6562.603515625,256), cutted = false, cutTime = nil},
{position = Vector(1931.6616210938,-6646.498046875,256), cutted = false, cutTime = nil},
{position = Vector(1972.5904541016,-6554.7553710938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(2111.9465332031,-6591.6997070313,256), cutted = false, cutTime = nil},
{position = Vector(1989.2600097656,-6774.8041992188,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(1944.8129882813,-6916.5966796875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(2048.482421875,-6996.6586914063,256), cutted = false, cutTime = nil},
{position = Vector(2120.7927246094,-6883.5986328125,256), cutted = false, cutTime = nil},
{position = Vector(2167.2316894531,-6773.09375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(2287.5920410156,-6532.9760742188,256), cutted = false, cutTime = nil},
{position = Vector(2363.197265625,-6660.2368164063,256), cutted = false, cutTime = nil},
{position = Vector(2303.2160644531,-6857.798828125,256), cutted = false, cutTime = nil},
{position = Vector(2148.4997558594,-6929.4594726563,256), cutted = false, cutTime = nil},
{position = Vector(2296.9311523438,-6987.1484375,256), cutted = false, cutTime = nil},
{position = Vector(2419.8708496094,-6955.3803710938,256), cutted = false, cutTime = nil},
{position = Vector(2504.1459960938,-6841.9458007813,256), cutted = false, cutTime = nil},
{position = Vector(2513.1220703125,-6713.7143554688,256), cutted = false, cutTime = nil},
{position = Vector(2416.1401367188,-6568.0073242188,256), cutted = false, cutTime = nil},
{position = Vector(2588.4284667969,-6561.8168945313,256), cutted = false, cutTime = nil},
{position = Vector(2591.1962890625,-7010.1909179688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(2565.5424804688,-6842.9340820313,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2790.0808105469,-7024.8076171875,256), cutted = false, cutTime = nil},
{position = Vector(2845.1027832031,-6850.2036132813,256), cutted = false, cutTime = nil},
{position = Vector(2722.6943359375,-6728.5986328125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(2826.1052246094,-6633.1567382813,256), cutted = false, cutTime = nil},
{position = Vector(2886.1799316406,-6508.705078125,256), cutted = false, cutTime = nil},
{position = Vector(2960.1335449219,-6648.90625,256), cutted = false, cutTime = nil},
{position = Vector(2606.1381835938,-6709.0649414063,256), cutted = false, cutTime = nil},
{position = Vector(2870.9782714844,-6716.5717773438,256), cutted = false, cutTime = nil},
{position = Vector(2924.0903320313,-6866.3701171875,256), cutted = false, cutTime = nil},
{position = Vector(2865.0595703125,-7019.5180664063,256), cutted = false, cutTime = nil},
{position = Vector(3016.1408691406,-7016.455078125,256), cutted = false, cutTime = nil},
{position = Vector(3094.6704101563,-6876.52734375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3037.6904296875,-6727.7651367188,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3131.3117675781,-6718.4423828125,256), cutted = false, cutTime = nil},
{position = Vector(3000.2412109375,-6502.6650390625,256), cutted = false, cutTime = nil},
{position = Vector(3160.5302734375,-6544.8237304688,256), cutted = false, cutTime = nil},
{position = Vector(3104.8288574219,-7011.2392578125,256), cutted = false, cutTime = nil},
{position = Vector(3217.9204101563,-6870.0415039063,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(3275.0747070313,-6772.58984375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(3266.5241699219,-7003.0991210938,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3408.0952148438,-7020.9482421875,256), cutted = false, cutTime = nil},
{position = Vector(3331.8522949219,-6905.2861328125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(3235.3872070313,-6485.517578125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3335.9111328125,-6634.5971679688,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3403.9194335938,-6769.0375976563,256), cutted = false, cutTime = nil},
{position = Vector(3422.8125,-6608.8461914063,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(3494.564453125,-6463.3432617188,256), cutted = false, cutTime = nil},
{position = Vector(3431.9040527344,-6890.5708007813,256), cutted = false, cutTime = nil},
{position = Vector(3527.0793457031,-6724.953125,256), cutted = false, cutTime = nil},
{position = Vector(3612.458984375,-6890.5708007813,256), cutted = false, cutTime = nil},
{position = Vector(3625.068359375,-6626.2143554688,256), cutted = false, cutTime = nil},
{position = Vector(3645.2570800781,-6772.091796875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3725.2109375,-6893.8696289063,256), cutted = false, cutTime = nil},
{position = Vector(3758.6633300781,-6770.3500976563,256), cutted = false, cutTime = nil},
{position = Vector(3864.7814941406,-6874.6806640625,256), cutted = false, cutTime = nil},
{position = Vector(3775.1296386719,-6598.3671875,256), cutted = false, cutTime = nil},
{position = Vector(3953.9699707031,-6574.0561523438,256), cutted = false, cutTime = nil},
{position = Vector(3977.9426269531,-6749.2055664063,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3972.7800292969,-6734.5576171875,256), cutted = false, cutTime = nil},
{position = Vector(4109.3979492188,-6749.2055664063,256), cutted = false, cutTime = nil},
{position = Vector(4158.9658203125,-6939.1796875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4144.4619140625,-6564.0952148438,256), cutted = false, cutTime = nil},
{position = Vector(4232.1157226563,-6674.1918945313,256), cutted = false, cutTime = nil},
{position = Vector(4283.6811523438,-6811.9555664063,256), cutted = false, cutTime = nil},
{position = Vector(4292.0229492188,-6951.884765625,256), cutted = false, cutTime = nil},
{position = Vector(4162.259765625,-6414.8466796875,256), cutted = false, cutTime = nil},
{position = Vector(4335.7651367188,-6470.0581054688,256), cutted = false, cutTime = nil},
{position = Vector(4359.41796875,-6601.326171875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4393.677734375,-6389.7065429688,256), cutted = false, cutTime = nil},
{position = Vector(4505.4951171875,-6802.53125,256), cutted = false, cutTime = nil},
{position = Vector(4675.689453125,-6872.85546875,256), cutted = false, cutTime = nil},
{position = Vector(4479.3740234375,-6768.8627929688,256), cutted = false, cutTime = nil},
{position = Vector(4573.796875,-6479.8334960938,256), cutted = false, cutTime = nil},
{position = Vector(4648.8139648438,-6346.4672851563,256), cutted = false, cutTime = nil},
{position = Vector(4685.4912109375,-6352.86328125,256), cutted = false, cutTime = nil},
{position = Vector(4736.7333984375,-6534.0927734375,256), cutted = false, cutTime = nil},
{position = Vector(4757.4838867188,-6791.1083984375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4857.1860351563,-6947.1342773438,256), cutted = false, cutTime = nil},
{position = Vector(4939.1186523438,-6809.4501953125,256), cutted = false, cutTime = nil},
{position = Vector(4849.7978515625,-6592.1171875,256), cutted = false, cutTime = nil},
{position = Vector(4783.7192382813,-6366.8173828125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4866.8461914063,-6507.6665039063,256), cutted = false, cutTime = nil},
{position = Vector(4928.7973632813,-6339.2856445313,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(5010.3354492188,-6575.5849609375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4989.4252929688,-6452.97265625,256), cutted = false, cutTime = nil},
{position = Vector(5111.095703125,-6525.1889648438,256), cutted = false, cutTime = nil},
{position = Vector(5124.9243164063,-6439.3046875,256), cutted = false, cutTime = nil},
{position = Vector(5107.18359375,-6295.9287109375,256), cutted = false, cutTime = nil},
{position = Vector(5256.138671875,-6300.2021484375,256), cutted = false, cutTime = nil},
{position = Vector(5261.99609375,-6466.5244140625,256), cutted = false, cutTime = nil},
{position = Vector(5104.3549804688,-6767.4409179688,256), cutted = false, cutTime = nil},
{position = Vector(5050.1196289063,-6959.0981445313,256), cutted = false, cutTime = nil},
{position = Vector(5260.0795898438,-6998.2221679688,256), cutted = false, cutTime = nil},
{position = Vector(5283.32421875,-6846.486328125,256), cutted = false, cutTime = nil},
{position = Vector(5369.5737304688,-6999.9497070313,256), cutted = false, cutTime = nil},
{position = Vector(5319.0419921875,-6723.6484375,256), cutted = false, cutTime = nil},
{position = Vector(5464.7998046875,-6868.646484375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5488.548828125,-6744.6533203125,256), cutted = false, cutTime = nil},
{position = Vector(5413.5830078125,-6472.9487304688,256), cutted = false, cutTime = nil},
{position = Vector(5559.1645507813,-6587.4111328125,256), cutted = false, cutTime = nil},
{position = Vector(5468.9365234375,-7057.7895507813,256), cutted = false, cutTime = nil},
{position = Vector(5499.41796875,-6997.9208984375,256), cutted = false, cutTime = nil},
{position = Vector(5567.8784179688,-6842.1293945313,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5455.4931640625,-6368.5083007813,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(5579.8955078125,-6418.2104492188,256), cutted = false, cutTime = nil},
{position = Vector(5728.2109375,-6538.150390625,256), cutted = false, cutTime = nil},
{position = Vector(5631.71875,-6822.2802734375,256), cutted = false, cutTime = nil},
{position = Vector(5590.0673828125,-7100.5400390625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5751.9887695313,-6988.9555664063,256), cutted = false, cutTime = nil},
{position = Vector(5546.2416992188,-6201.7163085938,256), cutted = false, cutTime = nil},
{position = Vector(5750.4399414063,-6245.2158203125,256), cutted = false, cutTime = nil},
{position = Vector(5755.0913085938,-5997.6513671875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5875.0141601563,-6396.1875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5901.435546875,-6613.7924804688,256), cutted = false, cutTime = nil},
{position = Vector(5911.9267578125,-6791.8559570313,256), cutted = false, cutTime = nil},
{position = Vector(5843.4033203125,-6877.177734375,256), cutted = false, cutTime = nil},
{position = Vector(5852.0385742188,-7106.8115234375,256), cutted = false, cutTime = nil},
{position = Vector(6052.7934570313,-7078.1489257813,256), cutted = false, cutTime = nil},
{position = Vector(6046.9267578125,-6884.5,256), cutted = false, cutTime = nil},
{position = Vector(6045.890625,-6725.2241210938,256), cutted = false, cutTime = nil},
{position = Vector(6085.189453125,-6658.3603515625,256), cutted = false, cutTime = nil},
{position = Vector(6107.341796875,-6541.9716796875,256), cutted = false, cutTime = nil},
{position = Vector(6051.8168945313,-6415.958984375,256), cutted = false, cutTime = nil},
{position = Vector(5952.6557617188,-6258.5546875,256), cutted = false, cutTime = nil},
{position = Vector(5867.4067382813,-6052.421875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6003.2353515625,-6116.4418945313,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6125.6103515625,-6254.4189453125,256), cutted = false, cutTime = nil},
{position = Vector(6167.298828125,-6434.5947265625,256), cutted = false, cutTime = nil},
{position = Vector(6211.986328125,-6619.470703125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6156.2275390625,-6763.7314453125,256), cutted = false, cutTime = nil},
{position = Vector(6154.744140625,-6930.6416015625,256), cutted = false, cutTime = nil},
{position = Vector(6170.1381835938,-7071.7065429688,256), cutted = false, cutTime = nil},
{position = Vector(6352.1875,-6978.60546875,261.20666503906), cutted = false, cutTime = nil},
{position = Vector(6262.0537109375,-6856.4086914063,256), cutted = false, cutTime = nil},
{position = Vector(6285.1889648438,-6690.4204101563,256), cutted = false, cutTime = nil},
{position = Vector(6279.9848632813,-6492.9140625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6125.6733398438,-6093.0419921875,256), cutted = false, cutTime = nil},
{position = Vector(6034.6391601563,-5894.1518554688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6219.2036132813,-5920.6166992188,256), cutted = false, cutTime = nil},
{position = Vector(6336.1767578125,-5938.0336914063,256), cutted = false, cutTime = nil},
{position = Vector(6331.54296875,-6093.0419921875,256), cutted = false, cutTime = nil},
{position = Vector(6345.84375,-6291.1127929688,256), cutted = false, cutTime = nil},
{position = Vector(6357.994140625,-6367.0366210938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6351.6596679688,-6655.0942382813,256), cutted = false, cutTime = nil},
{position = Vector(6406.7426757813,-6856.5903320313,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6560.140625,-6845.5615234375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6536.1650390625,-6655.09375,256), cutted = false, cutTime = nil},
{position = Vector(6504.93359375,-6494.453125,256), cutted = false, cutTime = nil},
{position = Vector(6553.9897460938,-6391.9331054688,256), cutted = false, cutTime = nil},
{position = Vector(6400.435546875,-6237.4462890625,256), cutted = false, cutTime = nil},
{position = Vector(6391.7329101563,-6036.4545898438,256), cutted = false, cutTime = nil},
{position = Vector(6179.8232421875,-5834.9946289063,256), cutted = false, cutTime = nil},
{position = Vector(6377.509765625,-5847.2138671875,256), cutted = false, cutTime = nil},
{position = Vector(6545.822265625,-6140.8442382813,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6528.9150390625,-6290.853515625,256), cutted = false, cutTime = nil},
{position = Vector(6649.7192382813,-6420.2260742188,256), cutted = false, cutTime = nil},
{position = Vector(6332.3745117188,-6549.6435546875,256), cutted = false, cutTime = nil},
{position = Vector(6657.6083984375,-6678.0595703125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6703.5595703125,-6549.6435546875,256), cutted = false, cutTime = nil},
{position = Vector(6834.525390625,-6638.8266601563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6773.9326171875,-6416.2412109375,256), cutted = false, cutTime = nil},
{position = Vector(7006.662109375,-6578.05859375,256), cutted = false, cutTime = nil},
{position = Vector(6776.46484375,-6335.228515625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6921.4936523438,-6353.2236328125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6917.4135742188,-6521.1557617188,256), cutted = false, cutTime = nil},
{position = Vector(6675.4780273438,-6294.5244140625,256), cutted = false, cutTime = nil},
{position = Vector(7087.162109375,-6462.7900390625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7191.9926757813,-6391.005859375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7053.365234375,-6351.9985351563,256), cutted = false, cutTime = nil},
{position = Vector(6901.732421875,-6233.0302734375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6765.6831054688,-6216.7690429688,256), cutted = false, cutTime = nil},
{position = Vector(6544.2397460938,-6023.2265625,256), cutted = false, cutTime = nil},
{position = Vector(6417.0483398438,-5920.095703125,256), cutted = false, cutTime = nil},
{position = Vector(6270.3022460938,-5761.0141601563,256), cutted = false, cutTime = nil},
{position = Vector(6771.5830078125,-6125.7641601563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6946.4731445313,-6146.0771484375,256), cutted = false, cutTime = nil},
{position = Vector(7058.4643554688,-6253.0541992188,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7180.44140625,-6284.5434570313,256), cutted = false, cutTime = nil},
{position = Vector(7322.89453125,-6166.2724609375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7181.3637695313,-6080.1215820313,256), cutted = false, cutTime = nil},
{position = Vector(7026.0546875,-6083.806640625,256), cutted = false, cutTime = nil},
{position = Vector(6890.626953125,-5998.681640625,256), cutted = false, cutTime = nil},
{position = Vector(6717.1352539063,-5993.4848632813,256), cutted = false, cutTime = nil},
{position = Vector(6568.6435546875,-5884.6689453125,256), cutted = false, cutTime = nil},
{position = Vector(6417.2861328125,-5791.576171875,256), cutted = false, cutTime = nil},
{position = Vector(6231.548828125,-5616.2172851563,256), cutted = false, cutTime = nil},
{position = Vector(6382.236328125,-5515.5913085938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6469.3735351563,-5649.0600585938,256), cutted = false, cutTime = nil},
{position = Vector(6587.8583984375,-5720.1137695313,256), cutted = false, cutTime = nil},
{position = Vector(6777.2978515625,-5891.21875,256), cutted = false, cutTime = nil},
{position = Vector(6883.5776367188,-5889.5834960938,256), cutted = false, cutTime = nil},
{position = Vector(6994.3334960938,-5986.6674804688,256), cutted = false, cutTime = nil},
{position = Vector(7214.3286132813,-6024.4819335938,256), cutted = false, cutTime = nil},
{position = Vector(7308.5454101563,-6044.7143554688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7483.6850585938,-6092.50390625,256), cutted = false, cutTime = nil},
{position = Vector(7471.1875,-5984.9262695313,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7325.984375,-5895.2392578125,256), cutted = false, cutTime = nil},
{position = Vector(7138.38671875,-5821.53125,256), cutted = false, cutTime = nil},
{position = Vector(7008.1235351563,-5792.2509765625,256), cutted = false, cutTime = nil},
{position = Vector(6945.9516601563,-5705.2734375,256), cutted = false, cutTime = nil},
{position = Vector(6826.2280273438,-5707.6215820313,256), cutted = false, cutTime = nil},
{position = Vector(6674.8896484375,-5617.021484375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6555.8754882813,-5497.763671875,256), cutted = false, cutTime = nil},
{position = Vector(6269.1508789063,-5356.1088867188,256), cutted = false, cutTime = nil},
{position = Vector(6168.9497070313,-5205.5966796875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6393.0048828125,-5283.583984375,256), cutted = false, cutTime = nil},
{position = Vector(6312.1752929688,-5093.8911132813,256), cutted = false, cutTime = nil},
{position = Vector(6511.9775390625,-5160.3173828125,256), cutted = false, cutTime = nil},
{position = Vector(6560.9252929688,-5344.2607421875,256), cutted = false, cutTime = nil},
{position = Vector(6711.0126953125,-5330.6044921875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6682.7924804688,-5250.7646484375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6809.4731445313,-5315.1157226563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6852.7451171875,-5517.9755859375,256), cutted = false, cutTime = nil},
{position = Vector(6988.5991210938,-5573.6313476563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7049.5561523438,-5610.9399414063,256), cutted = false, cutTime = nil},
{position = Vector(6856.3779296875,-5636.458984375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7205.7451171875,-5712.7822265625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7368.2241210938,-5740.8725585938,256), cutted = false, cutTime = nil},
{position = Vector(7428.1528320313,-5876.3017578125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7460.9990234375,-5564.6147460938,256), cutted = false, cutTime = nil},
{position = Vector(7233.69140625,-5575.9868164063,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7058.751953125,-5472.666015625,256), cutted = false, cutTime = nil},
{position = Vector(6923.3564453125,-5323.2211914063,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6819.6665039063,-5242.71484375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6376.4145507813,-4955.9243164063,256), cutted = false, cutTime = nil},
{position = Vector(6530.6469726563,-5002.869140625,256), cutted = false, cutTime = nil},
{position = Vector(6486.154296875,-4783.1411132813,256), cutted = false, cutTime = nil},
{position = Vector(6446.158203125,-4653.3569335938,256), cutted = false, cutTime = nil},
{position = Vector(6660.8129882813,-5092.73046875,256), cutted = false, cutTime = nil},
{position = Vector(6823.234375,-5108.3623046875,256), cutted = false, cutTime = nil},
{position = Vector(6978.3603515625,-5215.0810546875,256), cutted = false, cutTime = nil},
{position = Vector(7159.0356445313,-5333.1396484375,256), cutted = false, cutTime = nil},
{position = Vector(7205.9389648438,-5463.1748046875,256), cutted = false, cutTime = nil},
{position = Vector(7361.9438476563,-5511.1669921875,256), cutted = false, cutTime = nil},
{position = Vector(7452.9306640625,-5348.1811523438,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7270.3701171875,-5318.390625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7059.8530273438,-5198.9506835938,256), cutted = false, cutTime = nil},
{position = Vector(7435.5478515625,-5221.689453125,256), cutted = false, cutTime = nil},
{position = Vector(7206.5615234375,-5193.2158203125,256), cutted = false, cutTime = nil},
{position = Vector(7127.5913085938,-5038.6860351563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7298.5415039063,-5078.4365234375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7472.7705078125,-5107.1025390625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6966.017578125,-5023.2387695313,256), cutted = false, cutTime = nil},
{position = Vector(6819.8520507813,-4957.5991210938,256), cutted = false, cutTime = nil},
{position = Vector(6636.5444335938,-4783.8212890625,256), cutted = false, cutTime = nil},
{position = Vector(6852.986328125,-4859.3330078125,256), cutted = false, cutTime = nil},
{position = Vector(6987.8530273438,-4823.908203125,256), cutted = false, cutTime = nil},
{position = Vector(7253.2724609375,-4957.5991210938,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7154.1982421875,-4814.4536132813,256), cutted = false, cutTime = nil},
{position = Vector(7387.6123046875,-4899.384765625,256), cutted = false, cutTime = nil},
{position = Vector(7577.7133789063,-4961.0581054688,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7638.5224609375,-4851.1547851563,256), cutted = false, cutTime = nil},
{position = Vector(7761.4936523438,-4693.1508789063,256.8671875), cutted = false, cutTime = nil},
{position = Vector(7547.4462890625,-4723.1743164063,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7325.8154296875,-4762.1284179688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7168,-4696.6645507813,256), cutted = false, cutTime = nil},
{position = Vector(6985.1547851563,-4700.4790039063,256), cutted = false, cutTime = nil},
{position = Vector(6649.9033203125,-4673.5893554688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6680.224609375,-4485.0346679688,256), cutted = false, cutTime = nil},
{position = Vector(6869.791015625,-4575.8237304688,256), cutted = false, cutTime = nil},
{position = Vector(6816.2250976563,-4590.150390625,256), cutted = false, cutTime = nil},
{position = Vector(6936.7456054688,-4469.7856445313,256), cutted = false, cutTime = nil},
{position = Vector(7038.7241210938,-4418.7114257813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7085.9711914063,-4561.3735351563,256), cutted = false, cutTime = nil},
{position = Vector(7250.5068359375,-4618.4370117188,256), cutted = false, cutTime = nil},
{position = Vector(7220.4140625,-4502.2983398438,256), cutted = false, cutTime = nil},
{position = Vector(7246.5791015625,-4373.0502929688,256), cutted = false, cutTime = nil},
{position = Vector(7373.2353515625,-4430.359375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7587.7470703125,-4576.5747070313,256), cutted = false, cutTime = nil},
{position = Vector(7770.52734375,-4580.3325195313,256.10815429688), cutted = false, cutTime = nil},
{position = Vector(7620.830078125,-4426.2768554688,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7754.5927734375,-4444.5703125,256), cutted = false, cutTime = nil},
{position = Vector(7715.8037109375,-4294.5654296875,256), cutted = false, cutTime = nil},
{position = Vector(7553.9135742188,-4327.3740234375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7441.4995117188,-4312.1411132813,256), cutted = false, cutTime = nil},
{position = Vector(6751.49609375,-4159.2065429688,256), cutted = false, cutTime = nil},
{position = Vector(6866.6259765625,-4136.2426757813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6775.5766601563,-3961.4426269531,256), cutted = false, cutTime = nil},
{position = Vector(6931.2338867188,-3946.3723144531,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7027.7900390625,-4095.2482910156,256), cutted = false, cutTime = nil},
{position = Vector(7344.708984375,-3854.8674316406,256), cutted = false, cutTime = nil},
{position = Vector(7195.1625976563,-3745.8425292969,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7131.6704101563,-4026.0051269531,256), cutted = false, cutTime = nil},
{position = Vector(7505.1928710938,-3759.3110351563,256), cutted = false, cutTime = nil},
{position = Vector(7663.2670898438,-3751.62890625,256), cutted = false, cutTime = nil},
{position = Vector(7600.1586914063,-3669.1984863281,256), cutted = false, cutTime = nil},
{position = Vector(7237.5361328125,-3635.7065429688,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7475.6040039063,-3570.4274902344,256), cutted = false, cutTime = nil},
{position = Vector(7611.5708007813,-3574.3427734375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7682.71484375,-3431.3500976563,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7447.4560546875,-3393.4697265625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7700.302734375,-3275.3803710938,256), cutted = false, cutTime = nil},
{position = Vector(7638.6376953125,-3155.99609375,256), cutted = false, cutTime = nil},
{position = Vector(7441.462890625,-3242.4497070313,256), cutted = false, cutTime = nil},
{position = Vector(7311.6000976563,-3230.662109375,256), cutted = false, cutTime = nil},
{position = Vector(7180.9560546875,-3172.4345703125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7234.60546875,-3344.7482910156,256), cutted = false, cutTime = nil},
{position = Vector(7105.421875,-3370.2053222656,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6987.1831054688,-3182.6245117188,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7116.4633789063,-3301.9924316406,256), cutted = false, cutTime = nil},
{position = Vector(6803.2783203125,-3014.6552734375,169.2470703125), cutted = false, cutTime = nil},
{position = Vector(7035.8076171875,-3521.0561523438,256), cutted = false, cutTime = nil},
{position = Vector(6970.2626953125,-3294.4348144531,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6905.4541015625,-3409.369140625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6767.8540039063,-3228.6889648438,256), cutted = false, cutTime = nil},
{position = Vector(6900.9638671875,-3564.9362792969,256), cutted = false, cutTime = nil},
{position = Vector(6907.4545898438,-3672.9052734375,256), cutted = false, cutTime = nil},
{position = Vector(6789.0063476563,-3698.6948242188,256), cutted = false, cutTime = nil},
{position = Vector(6722.6318359375,-3577.1362304688,256), cutted = false, cutTime = nil},
{position = Vector(6771.2045898438,-3392.859375,256), cutted = false, cutTime = nil},
{position = Vector(6643.0791015625,-3291.9309082031,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5746.3813476563,-3794.9736328125,256), cutted = false, cutTime = nil},
{position = Vector(5628.1850585938,-3744.9458007813,256), cutted = false, cutTime = nil},
{position = Vector(5476.9404296875,-3363.1166992188,256), cutted = false, cutTime = nil},
{position = Vector(5346.3813476563,-3357.0012207031,256), cutted = false, cutTime = nil},
{position = Vector(5414.2416992188,-3521.7365722656,256), cutted = false, cutTime = nil},
{position = Vector(5127.6088867188,-3317.7221679688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(5226.9301757813,-3554.484375,256), cutted = false, cutTime = nil},
{position = Vector(5126.693359375,-3541.8327636719,256), cutted = false, cutTime = nil},
{position = Vector(5011.5327148438,-3520.8842773438,256), cutted = false, cutTime = nil},
{position = Vector(5044.4541015625,-3382.7470703125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5192.3974609375,-3469.1774902344,256), cutted = false, cutTime = nil},
{position = Vector(5447.0732421875,-3864.5827636719,256), cutted = false, cutTime = nil},
{position = Vector(5572.9091796875,-3976.8803710938,256), cutted = false, cutTime = nil},
{position = Vector(5714.6162109375,-4082.5544433594,256), cutted = false, cutTime = nil},
{position = Vector(5487.7265625,-4183.7290039063,256), cutted = false, cutTime = nil},
{position = Vector(5326.5463867188,-4148.8002929688,256), cutted = false, cutTime = nil},
{position = Vector(5256.5122070313,-4045.9750976563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5017.95703125,-4034.0009765625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(5009.6479492188,-4203.4970703125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5159.091796875,-4256.0234375,256), cutted = false, cutTime = nil},
{position = Vector(5362.2973632813,-4376.4458007813,256), cutted = false, cutTime = nil},
{position = Vector(5512.404296875,-4394.0771484375,256), cutted = false, cutTime = nil},
{position = Vector(5496.9077148438,-4542.6323242188,256), cutted = false, cutTime = nil},
{position = Vector(5243.626953125,-4453.7416992188,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4954.2739257813,-3645.328125,256), cutted = false, cutTime = nil},
{position = Vector(4616.5727539063,-3274.6672363281,256), cutted = false, cutTime = nil},
{position = Vector(4449.3315429688,-3323.302734375,256), cutted = false, cutTime = nil},
{position = Vector(5470.9501953125,-5015.748046875,256), cutted = false, cutTime = nil},
{position = Vector(5320.509765625,-5027.5390625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5121.041015625,-4832.2436523438,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5018.2998046875,-4611.896484375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4802.8481445313,-4644.1787109375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4879.818359375,-4816.224609375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(5186.1547851563,-5074.7260742188,256), cutted = false, cutTime = nil},
{position = Vector(5052.1889648438,-5172.7075195313,256), cutted = false, cutTime = nil},
{position = Vector(4931.5009765625,-5034.7006835938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4873.9140625,-5148.2153320313,256), cutted = false, cutTime = nil},
{position = Vector(4838.0385742188,-5257.6948242188,256), cutted = false, cutTime = nil},
{position = Vector(5012.1728515625,-5361.4990234375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4851.4184570313,-5414.017578125,256), cutted = false, cutTime = nil},
{position = Vector(4734.2260742188,-5180.5595703125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4610.4423828125,-5134.7016601563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4591.8940429688,-5241.4887695313,256), cutted = false, cutTime = nil},
{position = Vector(4715.5043945313,-5303.3779296875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4750.0913085938,-5428.017578125,256), cutted = false, cutTime = nil},
{position = Vector(4762.015625,-5595.2041015625,256), cutted = false, cutTime = nil},
{position = Vector(4637.5590820313,-5629.8901367188,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4519.1372070313,-5524.9018554688,256), cutted = false, cutTime = nil},
{position = Vector(4544.57421875,-5384.5146484375,256), cutted = false, cutTime = nil},
{position = Vector(4402.4594726563,-5242.18359375,256), cutted = false, cutTime = nil},
{position = Vector(4422.1416015625,-5404.6069335938,256), cutted = false, cutTime = nil},
{position = Vector(4255.8999023438,-5335.9604492188,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4526.7963867188,-5653.6948242188,256), cutted = false, cutTime = nil},
{position = Vector(4341.1088867188,-5681.6430664063,256), cutted = false, cutTime = nil},
{position = Vector(4245.2509765625,-5514.60546875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4150.3100585938,-5720.203125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4068.3798828125,-5578.7958984375,256), cutted = false, cutTime = nil},
{position = Vector(4080.65234375,-5468.3911132813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4095.6755371094,-5365.662109375,256), cutted = false, cutTime = nil},
{position = Vector(4068.4860839844,-5715.9633789063,256), cutted = false, cutTime = nil},
{position = Vector(3930.9140625,-5589.7802734375,256), cutted = false, cutTime = nil},
{position = Vector(3839.3100585938,-5479.0400390625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(3971.1711425781,-5365.0126953125,256), cutted = false, cutTime = nil},
{position = Vector(3809.6979980469,-5309.5615234375,256), cutted = false, cutTime = nil},
{position = Vector(3624.1176757813,-5480.783203125,256), cutted = false, cutTime = nil},
{position = Vector(3468.8037109375,-5594.8706054688,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3454.8251953125,-5488.2138671875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(3305.8818359375,-5637.890625,256), cutted = false, cutTime = nil},
{position = Vector(3268.6779785156,-5508.6694335938,256), cutted = false, cutTime = nil},
{position = Vector(3167.8522949219,-5519.7143554688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(3163.9580078125,-5649.7163085938,256), cutted = false, cutTime = nil},
{position = Vector(3063.44921875,-5525.20703125,256), cutted = false, cutTime = nil},
{position = Vector(3026.2490234375,-5662.9580078125,256), cutted = false, cutTime = nil},
{position = Vector(2858.8041992188,-5747.8540039063,256), cutted = false, cutTime = nil},
{position = Vector(2837.5603027344,-5534.068359375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(2804.609375,-5721.8100585938,256), cutted = false, cutTime = nil},
{position = Vector(2784.8015136719,-5575.408203125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2741.9965820313,-5454.8959960938,256), cutted = false, cutTime = nil},
{position = Vector(2622.0778808594,-5318.1596679688,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2535.0056152344,-5477.3950195313,256), cutted = false, cutTime = nil},
{position = Vector(2621.1057128906,-5617.689453125,256), cutted = false, cutTime = nil},
{position = Vector(2632.1650390625,-5795.1020507813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2495.5549316406,-5752.7421875,256), cutted = false, cutTime = nil},
{position = Vector(2456.2592773438,-5603.6577148438,256), cutted = false, cutTime = nil},
{position = Vector(2399.580078125,-5414.376953125,256), cutted = false, cutTime = nil},
{position = Vector(2318,-5344.7133789063,256), cutted = false, cutTime = nil},
{position = Vector(2332.5249023438,-5539.84375,256), cutted = false, cutTime = nil},
{position = Vector(2382.4245605469,-5713.0747070313,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2383.33984375,-5853.8540039063,256), cutted = false, cutTime = nil},
{position = Vector(2264.8493652344,-5635.5366210938,256), cutted = false, cutTime = nil},
{position = Vector(2126.4260253906,-5550.7153320313,256), cutted = false, cutTime = nil},
{position = Vector(2127.7749023438,-5437.6362304688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(2162.4719238281,-5275.4501953125,256), cutted = false, cutTime = nil},
{position = Vector(1954.3927001953,-5335.2983398438,256), cutted = false, cutTime = nil},
{position = Vector(1948.5379638672,-5417.3266601563,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(1918.7135009766,-5592.6635742188,256), cutted = false, cutTime = nil},
{position = Vector(2103.3793945313,-5725.3154296875,256), cutted = false, cutTime = nil},
{position = Vector(2155.5100097656,-4685.8540039063,256), cutted = false, cutTime = nil},
{position = Vector(2165.650390625,-4527.1787109375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2288.3759765625,-4647.6762695313,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2433.4855957031,-4731.8325195313,256), cutted = false, cutTime = nil},
{position = Vector(2524.7980957031,-4617.4990234375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(2471.1372070313,-4492.2524414063,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(2605.7082519531,-4674.3813476563,256), cutted = false, cutTime = nil},
{position = Vector(2698.66796875,-4853.5024414063,256), cutted = false, cutTime = nil},
{position = Vector(2685.0153808594,-4574.1796875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(2559.0495605469,-4367.1396484375,256), cutted = false, cutTime = nil},
{position = Vector(2579.5173339844,-4218.1083984375,256), cutted = false, cutTime = nil},
{position = Vector(2771.3952636719,-4347.2270507813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2783.7587890625,-4206.1918945313,256), cutted = false, cutTime = nil},
{position = Vector(2929.3693847656,-4190.1640625,256), cutted = false, cutTime = nil},
{position = Vector(3061.4338378906,-4176.0078125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3137.251953125,-4240.0424804688,256), cutted = false, cutTime = nil},
{position = Vector(3279.4260253906,-4265.3842773438,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(3301.0100097656,-4384.4658203125,256), cutted = false, cutTime = nil},
{position = Vector(3319.8989257813,-4485.1171875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3318.6970214844,-4684.1762695313,256), cutted = false, cutTime = nil},
{position = Vector(3498.6091308594,-4583.1069335938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(3456.9685058594,-4421.9545898438,256), cutted = false, cutTime = nil},
{position = Vector(3550.8264160156,-4701.4423828125,256), cutted = false, cutTime = nil},
{position = Vector(3598.0817871094,-4573.33203125,256), cutted = false, cutTime = nil},
{position = Vector(3600.3688964844,-4445.306640625,256), cutted = false, cutTime = nil},
{position = Vector(3583.69921875,-4319.029296875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3692.7883300781,-4320.962890625,256), cutted = false, cutTime = nil},
{position = Vector(3748.8469238281,-4477.0546875,256), cutted = false, cutTime = nil},
{position = Vector(3750.3071289063,-4643.513671875,256), cutted = false, cutTime = nil},
{position = Vector(3886.0759277344,-4720.7993164063,256), cutted = false, cutTime = nil},
{position = Vector(3966.8264160156,-4585.1318359375,256), cutted = false, cutTime = nil},
{position = Vector(3939.1713867188,-4482.7358398438,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3913.275390625,-4284.7534179688,256), cutted = false, cutTime = nil},
{position = Vector(3778.3706054688,-4279.1748046875,256), cutted = false, cutTime = nil},
{position = Vector(3856.6928710938,-4118.4741210938,256), cutted = false, cutTime = nil},
{position = Vector(4034.0122070313,-4177.1860351563,256), cutted = false, cutTime = nil},
{position = Vector(4004.1599121094,-3962.9057617188,256), cutted = false, cutTime = nil},
{position = Vector(4231.9399414063,-4254.767578125,256), cutted = false, cutTime = nil},
{position = Vector(4048.9594726563,-4376.5869140625,256), cutted = false, cutTime = nil},
{position = Vector(4214.5004882813,-4444.8686523438,256), cutted = false, cutTime = nil},
{position = Vector(4552.6982421875,-4369.1235351563,256), cutted = false, cutTime = nil},
{position = Vector(3730.4931640625,-3654.873046875,256), cutted = false, cutTime = nil},
{position = Vector(3714.9265136719,-3442.2817382813,256), cutted = false, cutTime = nil},
{position = Vector(3838.1896972656,-3224.4040527344,38.9091796875), cutted = false, cutTime = nil},
{position = Vector(3644.1884765625,-3375.8376464844,256), cutted = false, cutTime = nil},
{position = Vector(3591.8168945313,-3236.6254882813,269.92944335938), cutted = false, cutTime = nil},
{position = Vector(3501.19140625,-3422.5727539063,256), cutted = false, cutTime = nil},
{position = Vector(3578.9899902344,-3625.3071289063,256), cutted = false, cutTime = nil},
{position = Vector(3354.2043457031,-3348.5505371094,256), cutted = false, cutTime = nil},
{position = Vector(3348.5627441406,-3168.87890625,256), cutted = false, cutTime = nil},
{position = Vector(3328.2670898438,-2913.6787109375,-16.000122070313), cutted = false, cutTime = nil},
{position = Vector(2887.4606933594,-3560.2880859375,256), cutted = false, cutTime = nil},
{position = Vector(2843.8681640625,-3630.6176757813,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(2660.4541015625,-3593.7648925781,256), cutted = false, cutTime = nil},
{position = Vector(2741.2172851563,-3406.5153808594,256), cutted = false, cutTime = nil},
{position = Vector(2628.1987304688,-3291.8488769531,256), cutted = false, cutTime = nil},
{position = Vector(2774.5153808594,-3281.7690429688,256), cutted = false, cutTime = nil},
{position = Vector(2916.9760742188,-3256.2546386719,256), cutted = false, cutTime = nil},
{position = Vector(2645.3713378906,-3149.1875,256), cutted = false, cutTime = nil},
{position = Vector(2797.5290527344,-3088.1838378906,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2918.1374511719,-3012.0546875,256), cutted = false, cutTime = nil},
{position = Vector(2694.0639648438,-2948.5151367188,256), cutted = false, cutTime = nil},
{position = Vector(2828.1850585938,-2866.5524902344,256), cutted = false, cutTime = nil},
{position = Vector(2979.1479492188,-2882.9763183594,257.64758300781), cutted = false, cutTime = nil},
{position = Vector(2211.5471191406,-3552.2524414063,256), cutted = false, cutTime = nil},
{position = Vector(2156.74609375,-3449.7260742188,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2085.8425292969,-3710.8208007813,256), cutted = false, cutTime = nil},
{position = Vector(1991.5001220703,-3859.0495605469,256), cutted = false, cutTime = nil},
{position = Vector(1960.5471191406,-3636.2744140625,256), cutted = false, cutTime = nil},
{position = Vector(1871.4102783203,-3615.2729492188,256), cutted = false, cutTime = nil},
{position = Vector(1904.603515625,-3491.7104492188,256), cutted = false, cutTime = nil},
{position = Vector(2013.0842285156,-3470.3579101563,256), cutted = false, cutTime = nil},
{position = Vector(1995.3725585938,-3311.7736816406,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(1959.7873535156,-3166.2487792969,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(1865.7056884766,-3322.9758300781,256), cutted = false, cutTime = nil},
{position = Vector(1814.5352783203,-3232.0209960938,256), cutted = false, cutTime = nil},
{position = Vector(1716.3431396484,-3214.5322265625,256), cutted = false, cutTime = nil},
{position = Vector(1900.8732910156,-3054.4360351563,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(1728.0767822266,-3059.6916503906,256), cutted = false, cutTime = nil},
{position = Vector(1559.7175292969,-3209.0158691406,256), cutted = false, cutTime = nil},
{position = Vector(1440.197265625,-3178.7788085938,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(1590.3956298828,-3061.439453125,256), cutted = false, cutTime = nil},
{position = Vector(1711.9162597656,-2891.3818359375,256), cutted = false, cutTime = nil},
{position = Vector(1598.4390869141,-2835.6164550781,256), cutted = false, cutTime = nil},
{position = Vector(1541.4040527344,-2881.056640625,256), cutted = false, cutTime = nil},
{position = Vector(1424.8055419922,-2975.8527832031,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(1401.3791503906,-2772.1364746094,256), cutted = false, cutTime = nil},
{position = Vector(1241.3483886719,-2790.8527832031,256), cutted = false, cutTime = nil},
{position = Vector(1154.8132324219,-2917.3444824219,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(1289.9733886719,-3041.4301757813,256), cutted = false, cutTime = nil},
{position = Vector(1333.3751220703,-3158.5202636719,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(1152.9299316406,-3118.7587890625,256), cutted = false, cutTime = nil},
{position = Vector(1254.4916992188,-3259.3127441406,256), cutted = false, cutTime = nil},
{position = Vector(1055.6962890625,-3248.6428222656,256), cutted = false, cutTime = nil},
{position = Vector(1128.1057128906,-3406.4318847656,256), cutted = false, cutTime = nil},
{position = Vector(1344.2697753906,-3401.42578125,256), cutted = false, cutTime = nil},
{position = Vector(1364.3863525391,-3650.2102050781,256), cutted = false, cutTime = nil},
{position = Vector(1116.9617919922,-3622.0373535156,256), cutted = false, cutTime = nil},
{position = Vector(1026.6317138672,-3468.3579101563,256), cutted = false, cutTime = nil},
{position = Vector(1345.1087646484,-3764.7468261719,256), cutted = false, cutTime = nil},
{position = Vector(1149.5699462891,-3758.0749511719,256), cutted = false, cutTime = nil},
{position = Vector(1542.9661865234,-2112.1359863281,128.03125), cutted = false, cutTime = nil},
{position = Vector(1294.4046630859,-1969.7880859375,128.03125), cutted = false, cutTime = nil},
{position = Vector(-3375.1186523438,19.783508300781,256), cutted = false, cutTime = nil},
{position = Vector(-3409.2412109375,169.56994628906,256), cutted = false, cutTime = nil},
{position = Vector(-2824.6711425781,478.42950439453,256), cutted = false, cutTime = nil},
{position = Vector(-3031.5571289063,555.18603515625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3228.3527832031,729.62286376953,198.76843261719), cutted = false, cutTime = nil},
{position = Vector(-2734.6455078125,636.99627685547,256), cutted = false, cutTime = nil},
{position = Vector(-2788.4748535156,716.09582519531,256), cutted = false, cutTime = nil},
{position = Vector(-2876.9353027344,738.35137939453,256), cutted = false, cutTime = nil},
{position = Vector(-3002.5036621094,769.13208007813,256), cutted = false, cutTime = nil},
{position = Vector(-3107.4504394531,814.05578613281,256), cutted = false, cutTime = nil},
{position = Vector(-2921.4401855469,867.42602539063,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2782.392578125,839.63507080078,256), cutted = false, cutTime = nil},
{position = Vector(-2857.4567871094,1090.3400878906,226.5986328125), cutted = false, cutTime = nil},
{position = Vector(-3013,1025.4073486328,256), cutted = false, cutTime = nil},
{position = Vector(-3201.1110839844,1032.6748046875,256), cutted = false, cutTime = nil},
{position = Vector(-3157.6843261719,1101.6259765625,256), cutted = false, cutTime = nil},
{position = Vector(-3053.6025390625,1134.3903808594,256), cutted = false, cutTime = nil},
{position = Vector(-3200.0959472656,1204.1188964844,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-2861.4924316406,627.22229003906,256), cutted = false, cutTime = nil},
{position = Vector(-3348.9174804688,967.68298339844,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3404.6530761719,1166.751953125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3262.5803222656,1305.6782226563,134.30603027344), cutted = false, cutTime = nil},
{position = Vector(-3552.4645996094,1250.5930175781,256), cutted = false, cutTime = nil},
{position = Vector(-3631.6291503906,1325.3049316406,256), cutted = false, cutTime = nil},
{position = Vector(-3511.4033203125,920.25048828125,253.76318359375), cutted = false, cutTime = nil},
{position = Vector(-3681.1059570313,1095.4063720703,256), cutted = false, cutTime = nil},
{position = Vector(-3683.6145019531,949.35009765625,256), cutted = false, cutTime = nil},
{position = Vector(-3877.658203125,1078.0399169922,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3846.2797851563,957.25646972656,256), cutted = false, cutTime = nil},
{position = Vector(-4072.4125976563,1267.5432128906,256), cutted = false, cutTime = nil},
{position = Vector(-3884.9887695313,1330.8957519531,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3902.4287109375,1526.7142333984,256), cutted = false, cutTime = nil},
{position = Vector(-4046.8708496094,1560.4489746094,256), cutted = false, cutTime = nil},
{position = Vector(-4227.7861328125,1495.5327148438,256), cutted = false, cutTime = nil},
{position = Vector(-3731.3566894531,1558.5549316406,256), cutted = false, cutTime = nil},
{position = Vector(-3477.0993652344,1599.9368896484,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3514.8972167969,1757.3377685547,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3653.3715820313,1848.7249755859,256), cutted = false, cutTime = nil},
{position = Vector(-3828.4760742188,1741.3569335938,256), cutted = false, cutTime = nil},
{position = Vector(-3989.6765136719,1702.3605957031,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-4180.994140625,1659.7574462891,256), cutted = false, cutTime = nil},
{position = Vector(-4195.732421875,1685.2623291016,256), cutted = false, cutTime = nil},
{position = Vector(-4058.5092773438,1377.4984130859,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3712.3051757813,1822.3647460938,256), cutted = false, cutTime = nil},
{position = Vector(-4129.4750976563,1862.4682617188,293.369140625), cutted = false, cutTime = nil},
{position = Vector(-4314.5390625,1834.2058105469,256), cutted = false, cutTime = nil},
{position = Vector(-4486.3505859375,1802.3107910156,256), cutted = false, cutTime = nil},
{position = Vector(-4588.708984375,1868.0853271484,256), cutted = false, cutTime = nil},
{position = Vector(-4417.55078125,1992.9222412109,256), cutted = false, cutTime = nil},
{position = Vector(-4245.3891601563,2080.4560546875,255.50708007813), cutted = false, cutTime = nil},
{position = Vector(-4456.3911132813,2150.5021972656,256), cutted = false, cutTime = nil},
{position = Vector(-2851.0007324219,1544.1079101563,128.38000488281), cutted = false, cutTime = nil},
{position = Vector(-2925.7543945313,1583.4708251953,127.4853515625), cutted = false, cutTime = nil},
{position = Vector(-2493.951171875,1426.2814941406,128.03125), cutted = false, cutTime = nil},
{position = Vector(1486.8110351563,-5857.6538085938,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5394.181640625,2336.9243164063,256), cutted = false, cutTime = nil},
{position = Vector(6174.3779296875,6607.4169921875,256), cutted = false, cutTime = nil},
{position = Vector(6200.4428710938,6821.263671875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6269.5029296875,7037.1762695313,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5962.0903320313,6630.2075195313,256), cutted = false, cutTime = nil},
{position = Vector(5991.5551757813,6798.69140625,256), cutted = false, cutTime = nil},
{position = Vector(5991.2045898438,6864.6059570313,256), cutted = false, cutTime = nil},
{position = Vector(6006.4365234375,6961.4482421875,256), cutted = false, cutTime = nil},
{position = Vector(6082.486328125,6973.4663085938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5854.4775390625,6852.05859375,256), cutted = false, cutTime = nil},
{position = Vector(5843.982421875,7022.7368164063,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5759.1723632813,6759.1479492188,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5636.876953125,6631.48828125,256), cutted = false, cutTime = nil},
{position = Vector(5519.7236328125,6637.9140625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5577.5649414063,6762.0302734375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5716.5141601563,6845.8344726563,256), cutted = false, cutTime = nil},
{position = Vector(5554.3056640625,6872.5166015625,256), cutted = false, cutTime = nil},
{position = Vector(5710.4775390625,6997.8588867188,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5837.544921875,7104.25390625,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5577.3647460938,6987.3466796875,256), cutted = false, cutTime = nil},
{position = Vector(5387.169921875,6805.7348632813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5450.6181640625,6891.5844726563,256), cutted = false, cutTime = nil},
{position = Vector(5467.0498046875,7006.8408203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5572.466796875,7047.8349609375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5425.1220703125,7143.8266601563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5303.8549804688,6882.0737304688,256), cutted = false, cutTime = nil},
{position = Vector(5239.537109375,6697.5205078125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5234.2744140625,6563.3798828125,256), cutted = false, cutTime = nil},
{position = Vector(5037.935546875,6618.9262695313,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5119.72265625,6753.8081054688,256), cutted = false, cutTime = nil},
{position = Vector(5316.1909179688,7017.404296875,256), cutted = false, cutTime = nil},
{position = Vector(5166.3149414063,7073.4677734375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4980.3798828125,7097.7475585938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4976.09375,6923.8588867188,256), cutted = false, cutTime = nil},
{position = Vector(4853.287109375,6925.49609375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4838.1396484375,6667.19140625,256), cutted = false, cutTime = nil},
{position = Vector(4605.4262695313,6647.6752929688,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4600.8779296875,6828.1010742188,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4752.9340820313,6867.7944335938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4871.470703125,7064.6713867188,256), cutted = false, cutTime = nil},
{position = Vector(4748.1782226563,7022.935546875,256), cutted = false, cutTime = nil},
{position = Vector(4586.94140625,7052.3500976563,256), cutted = false, cutTime = nil},
{position = Vector(4463.1904296875,6878.3188476563,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4484.0576171875,7075.33203125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4395.4487304688,6750.0708007813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4220.3540039063,6797.2080078125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4243.7758789063,6987.5732421875,256), cutted = false, cutTime = nil},
{position = Vector(4254.1811523438,6999.3876953125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4010.4523925781,6903.2719726563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4006.2255859375,7002.7841796875,256), cutted = false, cutTime = nil},
{position = Vector(4122.7734375,7058.44921875,256), cutted = false, cutTime = nil},
{position = Vector(4014.3681640625,6755.2275390625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4058.6618652344,6603.1713867188,256), cutted = false, cutTime = nil},
{position = Vector(3981.1062011719,6728.1069335938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3745.5935058594,6811.5610351563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3660.017578125,6755.2280273438,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3524.8259277344,6668.205078125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3519.3715820313,6790.099609375,256), cutted = false, cutTime = nil},
{position = Vector(3709.5754394531,6990.9370117188,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3821.6467285156,7051.3530273438,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3580.2990722656,7042.5385742188,256), cutted = false, cutTime = nil},
{position = Vector(3452.2658691406,7030.302734375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3327.6540527344,7035.5317382813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3189.6257324219,6997.6928710938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3279.3232421875,6745.658203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3180.734375,6742.939453125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(6969.4956054688,5649.56640625,256), cutted = false, cutTime = nil},
{position = Vector(6994.8793945313,5511.0771484375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7098.98828125,5587.2421875,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7204.1733398438,5688.234375,256), cutted = false, cutTime = nil},
{position = Vector(7351.9926757813,5582.3134765625,256), cutted = false, cutTime = nil},
{position = Vector(7461.05078125,5589.7153320313,256), cutted = false, cutTime = nil},
{position = Vector(7449.9897460938,5470.6245117188,256), cutted = false, cutTime = nil},
{position = Vector(7175.890625,5477.2529296875,256), cutted = false, cutTime = nil},
{position = Vector(7322.1147460938,5403.6098632813,256), cutted = false, cutTime = nil},
{position = Vector(7308.4755859375,5277.2846679688,256), cutted = false, cutTime = nil},
{position = Vector(7437.0668945313,5366.5703125,256), cutted = false, cutTime = nil},
{position = Vector(7447.8286132813,5207.8461914063,256), cutted = false, cutTime = nil},
{position = Vector(7559.2333984375,5219.6958007813,256), cutted = false, cutTime = nil},
{position = Vector(7614.0834960938,5357.03125,256), cutted = false, cutTime = nil},
{position = Vector(7592.9760742188,5545.6625976563,256), cutted = false, cutTime = nil},
{position = Vector(7370.6440429688,5116.5458984375,256), cutted = false, cutTime = nil},
{position = Vector(7267.025390625,5036.5952148438,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7370.6791992188,4916.748046875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7504.6040039063,4909.3837890625,256), cutted = false, cutTime = nil},
{position = Vector(7250.4282226563,4756.6879882813,256), cutted = false, cutTime = nil},
{position = Vector(7431.3168945313,4679.529296875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7567.5034179688,4755.0283203125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7567.2280273438,4770.0458984375,256), cutted = false, cutTime = nil},
{position = Vector(7227.7358398438,4529.5439453125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7356.4077148438,4373.8706054688,256), cutted = false, cutTime = nil},
{position = Vector(7584.1157226563,4373.8706054688,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7239.1860351563,4087.1735839844,256), cutted = false, cutTime = nil},
{position = Vector(7236.5004882813,4176.9501953125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7377.6513671875,4136.9897460938,256), cutted = false, cutTime = nil},
{position = Vector(7491.2744140625,4159.8071289063,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7449.7568359375,3960.1552734375,256), cutted = false, cutTime = nil},
{position = Vector(7304.6665039063,3814.310546875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7253.4375,3594.203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7547.447265625,3732.8669433594,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7534.0209960938,3586.2587890625,256), cutted = false, cutTime = nil},
{position = Vector(7231.4658203125,3679.8933105469,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7453.2456054688,3415.1569824219,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7307.3041992188,3361.9404296875,256), cutted = false, cutTime = nil},
{position = Vector(7546.00390625,3259.6899414063,256), cutted = false, cutTime = nil},
{position = Vector(7405.4555664063,3164.7893066406,256), cutted = false, cutTime = nil},
{position = Vector(7109.0297851563,3197.9846191406,256), cutted = false, cutTime = nil},
{position = Vector(7515.0849609375,3041.2495117188,256), cutted = false, cutTime = nil},
{position = Vector(7516.2436523438,2900.4892578125,256), cutted = false, cutTime = nil},
{position = Vector(7161.7670898438,2808.515625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7353.3637695313,2760.9194335938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7361.884765625,2774.3059082031,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7527.81640625,2725.5930175781,256), cutted = false, cutTime = nil},
{position = Vector(5717.1088867188,2701.3969726563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5591.8999023438,2699.0588378906,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5425.509765625,2720.3059082031,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5290.68359375,2770.4638671875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4822.5034179688,2861.4467773438,256), cutted = false, cutTime = nil},
{position = Vector(4616.9467773438,2979.1188964844,256), cutted = false, cutTime = nil},
{position = Vector(3515.4086914063,4053.2592773438,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3832.7875976563,4386.6625976563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3990.7211914063,4603.33984375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3220.8098144531,4522.642578125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3215.5671386719,4653.7524414063,256), cutted = false, cutTime = nil},
{position = Vector(6174.3779296875,6607.4169921875,256), cutted = false, cutTime = nil},
{position = Vector(6200.4428710938,6821.263671875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6269.5029296875,7037.1762695313,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5962.0903320313,6630.2075195313,256), cutted = false, cutTime = nil},
{position = Vector(5991.5551757813,6798.69140625,256), cutted = false, cutTime = nil},
{position = Vector(5991.2045898438,6864.6059570313,256), cutted = false, cutTime = nil},
{position = Vector(6006.4365234375,6961.4482421875,256), cutted = false, cutTime = nil},
{position = Vector(6082.486328125,6973.4663085938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5854.4775390625,6852.05859375,256), cutted = false, cutTime = nil},
{position = Vector(5843.982421875,7022.7368164063,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5759.1723632813,6759.1479492188,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5636.876953125,6631.48828125,256), cutted = false, cutTime = nil},
{position = Vector(5519.7236328125,6637.9140625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5577.5649414063,6762.0302734375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5716.5141601563,6845.8344726563,256), cutted = false, cutTime = nil},
{position = Vector(5554.3056640625,6872.5166015625,256), cutted = false, cutTime = nil},
{position = Vector(5710.4775390625,6997.8588867188,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5837.544921875,7104.25390625,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5577.3647460938,6987.3466796875,256), cutted = false, cutTime = nil},
{position = Vector(5387.169921875,6805.7348632813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5450.6181640625,6891.5844726563,256), cutted = false, cutTime = nil},
{position = Vector(5467.0498046875,7006.8408203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5572.466796875,7047.8349609375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5425.1220703125,7143.8266601563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5303.8549804688,6882.0737304688,256), cutted = false, cutTime = nil},
{position = Vector(5239.537109375,6697.5205078125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5234.2744140625,6563.3798828125,256), cutted = false, cutTime = nil},
{position = Vector(5037.935546875,6618.9262695313,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5119.72265625,6753.8081054688,256), cutted = false, cutTime = nil},
{position = Vector(5316.1909179688,7017.404296875,256), cutted = false, cutTime = nil},
{position = Vector(5166.3149414063,7073.4677734375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4980.3798828125,7097.7475585938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4976.09375,6923.8588867188,256), cutted = false, cutTime = nil},
{position = Vector(4853.287109375,6925.49609375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4838.1396484375,6667.19140625,256), cutted = false, cutTime = nil},
{position = Vector(4605.4262695313,6647.6752929688,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4600.8779296875,6828.1010742188,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4752.9340820313,6867.7944335938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4871.470703125,7064.6713867188,256), cutted = false, cutTime = nil},
{position = Vector(4748.1782226563,7022.935546875,256), cutted = false, cutTime = nil},
{position = Vector(4586.94140625,7052.3500976563,256), cutted = false, cutTime = nil},
{position = Vector(4463.1904296875,6878.3188476563,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4484.0576171875,7075.33203125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4395.4487304688,6750.0708007813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4220.3540039063,6797.2080078125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4243.7758789063,6987.5732421875,256), cutted = false, cutTime = nil},
{position = Vector(4254.1811523438,6999.3876953125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4010.4523925781,6903.2719726563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4006.2255859375,7002.7841796875,256), cutted = false, cutTime = nil},
{position = Vector(4122.7734375,7058.44921875,256), cutted = false, cutTime = nil},
{position = Vector(4014.3681640625,6755.2275390625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4058.6618652344,6603.1713867188,256), cutted = false, cutTime = nil},
{position = Vector(3981.1062011719,6728.1069335938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3745.5935058594,6811.5610351563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3660.017578125,6755.2280273438,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3524.8259277344,6668.205078125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3519.3715820313,6790.099609375,256), cutted = false, cutTime = nil},
{position = Vector(3709.5754394531,6990.9370117188,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3821.6467285156,7051.3530273438,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3580.2990722656,7042.5385742188,256), cutted = false, cutTime = nil},
{position = Vector(3452.2658691406,7030.302734375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3327.6540527344,7035.5317382813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3189.6257324219,6997.6928710938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3279.3232421875,6745.658203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3180.734375,6742.939453125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(6969.4956054688,5649.56640625,256), cutted = false, cutTime = nil},
{position = Vector(6994.8793945313,5511.0771484375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7098.98828125,5587.2421875,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7204.1733398438,5688.234375,256), cutted = false, cutTime = nil},
{position = Vector(7351.9926757813,5582.3134765625,256), cutted = false, cutTime = nil},
{position = Vector(7461.05078125,5589.7153320313,256), cutted = false, cutTime = nil},
{position = Vector(7449.9897460938,5470.6245117188,256), cutted = false, cutTime = nil},
{position = Vector(7175.890625,5477.2529296875,256), cutted = false, cutTime = nil},
{position = Vector(7322.1147460938,5403.6098632813,256), cutted = false, cutTime = nil},
{position = Vector(7308.4755859375,5277.2846679688,256), cutted = false, cutTime = nil},
{position = Vector(7437.0668945313,5366.5703125,256), cutted = false, cutTime = nil},
{position = Vector(7447.8286132813,5207.8461914063,256), cutted = false, cutTime = nil},
{position = Vector(7559.2333984375,5219.6958007813,256), cutted = false, cutTime = nil},
{position = Vector(7614.0834960938,5357.03125,256), cutted = false, cutTime = nil},
{position = Vector(7592.9760742188,5545.6625976563,256), cutted = false, cutTime = nil},
{position = Vector(7370.6440429688,5116.5458984375,256), cutted = false, cutTime = nil},
{position = Vector(7267.025390625,5036.5952148438,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7370.6791992188,4916.748046875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7504.6040039063,4909.3837890625,256), cutted = false, cutTime = nil},
{position = Vector(7250.4282226563,4756.6879882813,256), cutted = false, cutTime = nil},
{position = Vector(7431.3168945313,4679.529296875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7567.5034179688,4755.0283203125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7567.2280273438,4770.0458984375,256), cutted = false, cutTime = nil},
{position = Vector(7227.7358398438,4529.5439453125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7356.4077148438,4373.8706054688,256), cutted = false, cutTime = nil},
{position = Vector(7584.1157226563,4373.8706054688,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7239.1860351563,4087.1735839844,256), cutted = false, cutTime = nil},
{position = Vector(7236.5004882813,4176.9501953125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7377.6513671875,4136.9897460938,256), cutted = false, cutTime = nil},
{position = Vector(7491.2744140625,4159.8071289063,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7449.7568359375,3960.1552734375,256), cutted = false, cutTime = nil},
{position = Vector(7304.6665039063,3814.310546875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7253.4375,3594.203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7547.447265625,3732.8669433594,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7534.0209960938,3586.2587890625,256), cutted = false, cutTime = nil},
{position = Vector(7231.4658203125,3679.8933105469,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7453.2456054688,3415.1569824219,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7307.3041992188,3361.9404296875,256), cutted = false, cutTime = nil},
{position = Vector(7546.00390625,3259.6899414063,256), cutted = false, cutTime = nil},
{position = Vector(7405.4555664063,3164.7893066406,256), cutted = false, cutTime = nil},
{position = Vector(7109.0297851563,3197.9846191406,256), cutted = false, cutTime = nil},
{position = Vector(7515.0849609375,3041.2495117188,256), cutted = false, cutTime = nil},
{position = Vector(7516.2436523438,2900.4892578125,256), cutted = false, cutTime = nil},
{position = Vector(7161.7670898438,2808.515625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7353.3637695313,2760.9194335938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7361.884765625,2774.3059082031,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7527.81640625,2725.5930175781,256), cutted = false, cutTime = nil},
{position = Vector(5717.1088867188,2701.3969726563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5591.8999023438,2699.0588378906,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5425.509765625,2720.3059082031,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5290.68359375,2770.4638671875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4822.5034179688,2861.4467773438,256), cutted = false, cutTime = nil},
{position = Vector(4616.9467773438,2979.1188964844,256), cutted = false, cutTime = nil},
{position = Vector(3515.4086914063,4053.2592773438,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3832.7875976563,4386.6625976563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3990.7211914063,4603.33984375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3220.8098144531,4522.642578125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3215.5671386719,4653.7524414063,256), cutted = false, cutTime = nil},
{position = Vector(1582.3438720703,6578.3481445313,128), cutted = false, cutTime = nil},
{position = Vector(1598.6154785156,6680.6806640625,128), cutted = false, cutTime = nil},
{position = Vector(1707.3951416016,6734.9375,128), cutted = false, cutTime = nil},
{position = Vector(1843.2747802734,6815.0727539063,128), cutted = false, cutTime = nil},
{position = Vector(1688.9362792969,6923.3510742188,128), cutted = false, cutTime = nil},
{position = Vector(1980.3260498047,6883.4770507813,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(2136.5283203125,6867.228515625,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(2223.5998535156,6870.4619140625,128), cutted = false, cutTime = nil},
{position = Vector(2406.64453125,6904.9189453125,128), cutted = false, cutTime = nil},
{position = Vector(2538.1098632813,6763.5717773438,128), cutted = false, cutTime = nil},
{position = Vector(1148.5532226563,6663.669921875,256), cutted = false, cutTime = nil},
{position = Vector(1032.9738769531,6667.0727539063,256), cutted = false, cutTime = nil},
{position = Vector(882.68658447266,6651.7485351563,256), cutted = false, cutTime = nil},
{position = Vector(755.3408203125,6669.134765625,256), cutted = false, cutTime = nil},
{position = Vector(762.71374511719,6771.4116210938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(897.36889648438,6792.2724609375,256), cutted = false, cutTime = nil},
{position = Vector(1011.8165893555,6805.2373046875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1070.2056884766,6931.2329101563,256), cutted = false, cutTime = nil},
{position = Vector(974.59405517578,6932.572265625,256), cutted = false, cutTime = nil},
{position = Vector(826.20452880859,6920.5791015625,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(831.43475341797,7064.841796875,256), cutted = false, cutTime = nil},
{position = Vector(949.50494384766,7073.935546875,256), cutted = false, cutTime = nil},
{position = Vector(1083.6857910156,7054.3232421875,256), cutted = false, cutTime = nil},
{position = Vector(1209.5025634766,7073.935546875,256), cutted = false, cutTime = nil},
{position = Vector(1225.6392822266,6943.3452148438,256), cutted = false, cutTime = nil},
{position = Vector(1073.6520996094,7164.076171875,256), cutted = false, cutTime = nil},
{position = Vector(950.60034179688,7187.3095703125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(729.1298828125,7270.521484375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(693.97180175781,7375.17578125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(837.91491699219,7386.912109375,256), cutted = false, cutTime = nil},
{position = Vector(974.36193847656,7392.8203125,256), cutted = false, cutTime = nil},
{position = Vector(1156.1237792969,7333.0297851563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(1280.8116455078,7329.2666015625,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(1430.6571044922,7312.4658203125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1374.7932128906,7078.509765625,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1270.9592285156,7521.2114257813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(951.47473144531,7503.9404296875,256), cutted = false, cutTime = nil},
{position = Vector(827.70123291016,7499.6567382813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1504.7760009766,7073.935546875,256), cutted = false, cutTime = nil},
{position = Vector(1417.2287597656,7441.0673828125,256), cutted = false, cutTime = nil},
{position = Vector(1556.5831298828,7394.7958984375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1642.4958496094,7147.7529296875,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(1780.9072265625,7159.1552734375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1702.4733886719,7377.1240234375,256), cutted = false, cutTime = nil},
{position = Vector(1794.5397949219,7348.1962890625,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(1814.2756347656,7261.5864257813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1861.4801025391,7120.0356445313,256), cutted = false, cutTime = nil},
{position = Vector(1915.5799560547,7274.6821289063,256), cutted = false, cutTime = nil},
{position = Vector(1977.9748535156,7387.126953125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2078.4304199219,7092.2685546875,256), cutted = false, cutTime = nil},
{position = Vector(2126.2502441406,7383.619140625,256), cutted = false, cutTime = nil},
{position = Vector(2186.3442382813,7107.4555664063,256), cutted = false, cutTime = nil},
{position = Vector(2234.7702636719,7376.6333007813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2321.494140625,7115.8266601563,256), cutted = false, cutTime = nil},
{position = Vector(2401.9291992188,7241.4638671875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2432.1318359375,7104.6791992188,256), cutted = false, cutTime = nil},
{position = Vector(2558.7744140625,7243.025390625,256), cutted = false, cutTime = nil},
{position = Vector(2518.2863769531,7355.9047851563,256), cutted = false, cutTime = nil},
{position = Vector(2757.0991210938,7238.34765625,256), cutted = false, cutTime = nil},
{position = Vector(2626.3110351563,7364.5004882813,256), cutted = false, cutTime = nil},
{position = Vector(2760.9506835938,7361.0551757813,256), cutted = false, cutTime = nil},
{position = Vector(2589.5278320313,7067.853515625,256), cutted = false, cutTime = nil},
{position = Vector(2761.4802246094,7097.767578125,256), cutted = false, cutTime = nil},
{position = Vector(2708.8779296875,6982.7094726563,256), cutted = false, cutTime = nil},
{position = Vector(2699.8637695313,6837.3461914063,256), cutted = false, cutTime = nil},
{position = Vector(521.18621826172,6547.7451171875,256), cutted = false, cutTime = nil},
{position = Vector(586.47747802734,6682.9731445313,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(652.76586914063,6835.5532226563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(701.60961914063,6946.1625976563,256), cutted = false, cutTime = nil},
{position = Vector(721.12683105469,7043.5185546875,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(402.66818237305,6540.5854492188,256), cutted = false, cutTime = nil},
{position = Vector(450.86624145508,6684.3330078125,256), cutted = false, cutTime = nil},
{position = Vector(528.01428222656,6824.7270507813,256), cutted = false, cutTime = nil},
{position = Vector(579.37634277344,6946.1625976563,256), cutted = false, cutTime = nil},
{position = Vector(529.65777587891,7082.7475585938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(523.13604736328,7177.0830078125,256), cutted = false, cutTime = nil},
{position = Vector(512.91461181641,7280.7036132813,256), cutted = false, cutTime = nil},
{position = Vector(421.61578369141,7102.7548828125,256), cutted = false, cutTime = nil},
{position = Vector(391.46099853516,7192.0805664063,256), cutted = false, cutTime = nil},
{position = Vector(385.06573486328,7379.0234375,256), cutted = false, cutTime = nil},
{position = Vector(509.98419189453,7379.0234375,256), cutted = false, cutTime = nil},
{position = Vector(247.51196289063,7244.939453125,256), cutted = false, cutTime = nil},
{position = Vector(258.4853515625,7260.93359375,256), cutted = false, cutTime = nil},
{position = Vector(255.57649230957,7393.244140625,256), cutted = false, cutTime = nil},
{position = Vector(237.52966308594,6941.4877929688,256), cutted = false, cutTime = nil},
{position = Vector(119.79476928711,6932.9858398438,256), cutted = false, cutTime = nil},
{position = Vector(0.018096923828125,6956.2211914063,256), cutted = false, cutTime = nil},
{position = Vector(3.3457946777344,7068.0419921875,256), cutted = false, cutTime = nil},
{position = Vector(23.396179199219,7131.298828125,256), cutted = false, cutTime = nil},
{position = Vector(89.057983398438,7240.1821289063,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-97.071685791016,7265.7724609375,256), cutted = false, cutTime = nil},
{position = Vector(-7.5255126953125,7380.7924804688,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-152.63580322266,7413.0556640625,256), cutted = false, cutTime = nil},
{position = Vector(-157.2939453125,7131.2983398438,256), cutted = false, cutTime = nil},
{position = Vector(-196.86791992188,7280.4038085938,256), cutted = false, cutTime = nil},
{position = Vector(46.906967163086,6817.759765625,256), cutted = false, cutTime = nil},
{position = Vector(241.37405395508,6814.7744140625,256), cutted = false, cutTime = nil},
{position = Vector(253.62203979492,6819.2553710938,256), cutted = false, cutTime = nil},
{position = Vector(392.85192871094,6778.0751953125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(81.565979003906,6479.48828125,256), cutted = false, cutTime = nil},
{position = Vector(-3.8145599365234,6683.5532226563,256), cutted = false, cutTime = nil},
{position = Vector(-122.51909637451,6820.9829101563,256), cutted = false, cutTime = nil},
{position = Vector(-196.80073547363,6948.1635742188,256), cutted = false, cutTime = nil},
{position = Vector(-173.08923339844,6975.6518554688,256), cutted = false, cutTime = nil},
{position = Vector(-246.97470092773,7123.0966796875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-325.17864990234,6943.3774414063,256), cutted = false, cutTime = nil},
{position = Vector(-317.64086914063,7242.4497070313,256), cutted = false, cutTime = nil},
{position = Vector(-254.84980773926,7362.2734375,256), cutted = false, cutTime = nil},
{position = Vector(-318.31604003906,6521.1801757813,256), cutted = false, cutTime = nil},
{position = Vector(-519.58758544922,6543.6157226563,256), cutted = false, cutTime = nil},
{position = Vector(-317.38079833984,6658.0883789063,256), cutted = false, cutTime = nil},
{position = Vector(-443.41558837891,6687.6440429688,256), cutted = false, cutTime = nil},
{position = Vector(-382.17474365234,6776.7802734375,256), cutted = false, cutTime = nil},
{position = Vector(-517.68194580078,6797.55078125,256), cutted = false, cutTime = nil},
{position = Vector(-657.74438476563,6794.560546875,256), cutted = false, cutTime = nil},
{position = Vector(-439.17413330078,6909.8491210938,256), cutted = false, cutTime = nil},
{position = Vector(-580.46997070313,6935.1430664063,256), cutted = false, cutTime = nil},
{position = Vector(-769.09283447266,6946.716796875,256), cutted = false, cutTime = nil},
{position = Vector(-378.73623657227,7035.4301757813,256), cutted = false, cutTime = nil},
{position = Vector(-618.38702392578,7059.4360351563,256), cutted = false, cutTime = nil},
{position = Vector(-510.78540039063,7053.7426757813,256), cutted = false, cutTime = nil},
{position = Vector(-790.65753173828,7065.1567382813,256), cutted = false, cutTime = nil},
{position = Vector(-581.7373046875,7240.8330078125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-425.41744995117,7300.1684570313,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-551.94848632813,7331.783203125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-708.08184814453,7324.6909179688,256), cutted = false, cutTime = nil},
{position = Vector(-700.57360839844,7337.0361328125,266.84167480469), cutted = false, cutTime = nil},
{position = Vector(-830.14007568359,7217.8549804688,256), cutted = false, cutTime = nil},
{position = Vector(-900.43676757813,7351.48828125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-937.61163330078,7173.1328125,256), cutted = false, cutTime = nil},
{position = Vector(-963.98693847656,7206.5224609375,256), cutted = false, cutTime = nil},
{position = Vector(-797.34063720703,6840.79296875,256), cutted = false, cutTime = nil},
{position = Vector(-853.01916503906,6958.5913085938,256), cutted = false, cutTime = nil},
{position = Vector(-921.10498046875,6760.7866210938,256), cutted = false, cutTime = nil},
{position = Vector(-927.96862792969,6810.9086914063,256), cutted = false, cutTime = nil},
{position = Vector(-1038.9002685547,6890.5952148438,256), cutted = false, cutTime = nil},
{position = Vector(-1142.7419433594,6738.9638671875,256), cutted = false, cutTime = nil},
{position = Vector(-1284.8645019531,6755.8989257813,256), cutted = false, cutTime = nil},
{position = Vector(-1076.3127441406,7027.6430664063,256), cutted = false, cutTime = nil},
{position = Vector(-1224.5571289063,7023.0170898438,256), cutted = false, cutTime = nil},
{position = Vector(-1346.1818847656,7107.4228515625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1221.6573486328,7140.8188476563,256), cutted = false, cutTime = nil},
{position = Vector(-980.58666992188,7443.1489257813,256), cutted = false, cutTime = nil},
{position = Vector(-894.36389160156,7437.5502929688,256), cutted = false, cutTime = nil},
{position = Vector(-1196.8433837891,7326.8686523438,256), cutted = false, cutTime = nil},
{position = Vector(-1341.8244628906,7372.1474609375,256), cutted = false, cutTime = nil},
{position = Vector(-1352.2913818359,7126.5307617188,256), cutted = false, cutTime = nil},
{position = Vector(-1155.7963867188,7448.7709960938,256), cutted = false, cutTime = nil},
{position = Vector(-1286.8138427734,7431.9750976563,256), cutted = false, cutTime = nil},
{position = Vector(-1428.5975341797,7439.4135742188,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1538.9888916016,7321.7451171875,256), cutted = false, cutTime = nil},
{position = Vector(-1549.7969970703,7446.89453125,256), cutted = false, cutTime = nil},
{position = Vector(-1707.6561279297,7359.80078125,256), cutted = false, cutTime = nil},
{position = Vector(-1670.1142578125,7445.0205078125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1527.8736572266,6792.4956054688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1528.8201904297,6885.2719726563,256), cutted = false, cutTime = nil},
{position = Vector(-1590.6606445313,7002.8525390625,256), cutted = false, cutTime = nil},
{position = Vector(-1789.5031738281,7121.7529296875,256), cutted = false, cutTime = nil},
{position = Vector(-1778.9320068359,7327.2529296875,256), cutted = false, cutTime = nil},
{position = Vector(-1784.5681152344,7422.412109375,256), cutted = false, cutTime = nil},
{position = Vector(-1923.5981445313,7137.1108398438,256), cutted = false, cutTime = nil},
{position = Vector(-1902.3666992188,7312.93359375,256), cutted = false, cutTime = nil},
{position = Vector(-1903.6506347656,7451.7436523438,256), cutted = false, cutTime = nil},
{position = Vector(-2055.5676269531,7220.2651367188,256), cutted = false, cutTime = nil},
{position = Vector(-2054.3330078125,7334.4721679688,256), cutted = false, cutTime = nil},
{position = Vector(-2051.9956054688,7465.6513671875,256), cutted = false, cutTime = nil},
{position = Vector(-2203.1733398438,7358.2153320313,256), cutted = false, cutTime = nil},
{position = Vector(-2183.4494628906,7428.2275390625,256), cutted = false, cutTime = nil},
{position = Vector(-2175.8471679688,7174.7880859375,256), cutted = false, cutTime = nil},
{position = Vector(-2370.6960449219,7170.013671875,256), cutted = false, cutTime = nil},
{position = Vector(-2324.9404296875,7262.3256835938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2514.05078125,7171.6030273438,256), cutted = false, cutTime = nil},
{position = Vector(-2318.5007324219,7245.33203125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2491.4191894531,7276.0869140625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1717.0268554688,6934.693359375,256), cutted = false, cutTime = nil},
{position = Vector(-1649.3201904297,6825.06640625,256), cutted = false, cutTime = nil},
{position = Vector(-1903.5249023438,6858.3598632813,256), cutted = false, cutTime = nil},
{position = Vector(-1819.7852783203,6750.5693359375,256), cutted = false, cutTime = nil},
{position = Vector(-1690.1033935547,6644.794921875,256), cutted = false, cutTime = nil},
{position = Vector(-1934.4638671875,6770.8491210938,256), cutted = false, cutTime = nil},
{position = Vector(-2063.1110839844,6876.0942382813,256), cutted = false, cutTime = nil},
{position = Vector(-2096.4191894531,6793.0883789063,256), cutted = false, cutTime = nil},
{position = Vector(-2140.5158691406,6861.7583007813,256), cutted = false, cutTime = nil},
{position = Vector(-2304.251953125,6937.7651367188,256), cutted = false, cutTime = nil},
{position = Vector(-2412.1853027344,6933.158203125,256), cutted = false, cutTime = nil},
{position = Vector(-2421.6030273438,6937.7651367188,256), cutted = false, cutTime = nil},
{position = Vector(-2384.681640625,6719.365234375,256), cutted = false, cutTime = nil},
{position = Vector(-2278.2365722656,6685.4970703125,256), cutted = false, cutTime = nil},
{position = Vector(-2503.0610351563,6702.927734375,256), cutted = false, cutTime = nil},
{position = Vector(-2642.6767578125,6786.3061523438,256), cutted = false, cutTime = nil},
{position = Vector(-2625.1010742188,6801.2802734375,256), cutted = false, cutTime = nil},
{position = Vector(-2623.5649414063,6908.880859375,256), cutted = false, cutTime = nil},
{position = Vector(-2757.689453125,6868.9985351563,256), cutted = false, cutTime = nil},
{position = Vector(-2674.2966308594,7100.2900390625,256), cutted = false, cutTime = nil},
{position = Vector(-2888.8610839844,6603.2265625,256), cutted = false, cutTime = nil},
{position = Vector(-2806.5070800781,6747.970703125,256), cutted = false, cutTime = nil},
{position = Vector(-2935.1596679688,6733.7504882813,256), cutted = false, cutTime = nil},
{position = Vector(-3081.2468261719,6622.7387695313,256), cutted = false, cutTime = nil},
{position = Vector(-3213.2629394531,6596.9931640625,256), cutted = false, cutTime = nil},
{position = Vector(-3078.130859375,6836.0561523438,256), cutted = false, cutTime = nil},
{position = Vector(-3001.9072265625,6918.9497070313,256), cutted = false, cutTime = nil},
{position = Vector(-3266.2153320313,6840.275390625,256), cutted = false, cutTime = nil},
{position = Vector(-3101.34375,6926.505859375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3296.9426269531,6918.9497070313,256), cutted = false, cutTime = nil},
{position = Vector(-3454.2749023438,6932.5859375,256), cutted = false, cutTime = nil},
{position = Vector(-3483.1262207031,7042.5424804688,256), cutted = false, cutTime = nil},
{position = Vector(-3336.8149414063,7050.9028320313,256), cutted = false, cutTime = nil},
{position = Vector(-3193.5715332031,7030.9306640625,256), cutted = false, cutTime = nil},
{position = Vector(-3072.6850585938,7039.2138671875,256), cutted = false, cutTime = nil},
{position = Vector(-2942.3315429688,7049.2260742188,256), cutted = false, cutTime = nil},
{position = Vector(-2906.5500488281,7185.4970703125,256), cutted = false, cutTime = nil},
{position = Vector(-3086.2897949219,7187.0126953125,256), cutted = false, cutTime = nil},
{position = Vector(-3207.8520507813,7171.9453125,256), cutted = false, cutTime = nil},
{position = Vector(-3332.3188476563,7182.4721679688,256), cutted = false, cutTime = nil},
{position = Vector(-3450.2155761719,7196.14453125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3622.0881347656,7133.64453125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2880.3171386719,7318.1591796875,256), cutted = false, cutTime = nil},
{position = Vector(-2753.4765625,7321.5380859375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3006.8669433594,7311.4296875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3141.3198242188,7304.7353515625,256), cutted = false, cutTime = nil},
{position = Vector(-3262.11328125,7313.1083984375,256), cutted = false, cutTime = nil},
{position = Vector(-3393.6389160156,7373.3232421875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3544.0043945313,7247.1982421875,256), cutted = false, cutTime = nil},
{position = Vector(-2982.0954589844,7453.9833984375,256), cutted = false, cutTime = nil},
{position = Vector(-3319.0185546875,7486.8579101563,256), cutted = false, cutTime = nil},
{position = Vector(-3427.0041503906,7528.568359375,256), cutted = false, cutTime = nil},
{position = Vector(-3426.2219238281,7544.7885742188,256), cutted = false, cutTime = nil},
{position = Vector(-3705.3774414063,7435.0053710938,256), cutted = false, cutTime = nil},
{position = Vector(-3629.3125,7534.62890625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3765.8630371094,7496.6772460938,256), cutted = false, cutTime = nil},
{position = Vector(-3756.9089355469,7528.568359375,256), cutted = false, cutTime = nil},
{position = Vector(-3891.890625,7516.5239257813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3770.0710449219,7152.7602539063,256), cutted = false, cutTime = nil},
{position = Vector(-3979.8793945313,7297.19921875,256), cutted = false, cutTime = nil},
{position = Vector(-4022.8603515625,7388.6865234375,256), cutted = false, cutTime = nil},
{position = Vector(-4032.9047851563,7516.5239257813,256), cutted = false, cutTime = nil},
{position = Vector(-4143.8969726563,7520.52734375,256), cutted = false, cutTime = nil},
{position = Vector(-4146.4560546875,7372.3930664063,256), cutted = false, cutTime = nil},
{position = Vector(-4290.4658203125,7425.6142578125,256), cutted = false, cutTime = nil},
{position = Vector(-4370.2685546875,7276.9653320313,256), cutted = false, cutTime = nil},
{position = Vector(-4300.3579101563,7401.4965820313,256), cutted = false, cutTime = nil},
{position = Vector(-4438.66796875,7473.2265625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4573.2866210938,7536.6547851563,256), cutted = false, cutTime = nil},
{position = Vector(-4493.9072265625,7326.4155273438,256), cutted = false, cutTime = nil},
{position = Vector(-4163.8588867188,7092.158203125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4186.376953125,7087.8413085938,256), cutted = false, cutTime = nil},
{position = Vector(-4092.6638183594,7183.451171875,256), cutted = false, cutTime = nil},
{position = Vector(-3896.1833496094,7048.2900390625,256), cutted = false, cutTime = nil},
{position = Vector(-3922.4978027344,7163.4150390625,256), cutted = false, cutTime = nil},
{position = Vector(-3760.3010253906,7001.9912109375,256), cutted = false, cutTime = nil},
{position = Vector(-3716.7712402344,6866.763671875,256), cutted = false, cutTime = nil},
{position = Vector(-3837.4763183594,6862.6533203125,256), cutted = false, cutTime = nil},
{position = Vector(-3954.6896972656,6877.796875,256), cutted = false, cutTime = nil},
{position = Vector(-4077.0107421875,6875.0288085938,256), cutted = false, cutTime = nil},
{position = Vector(-4295.556640625,6911.5322265625,256), cutted = false, cutTime = nil},
{position = Vector(-4181.8198242188,6766.9140625,256), cutted = false, cutTime = nil},
{position = Vector(-4033.9155273438,6729.8159179688,256), cutted = false, cutTime = nil},
{position = Vector(-3899.0676269531,6728.6010742188,256), cutted = false, cutTime = nil},
{position = Vector(-3782.8999023438,6690.4091796875,256), cutted = false, cutTime = nil},
{position = Vector(-3640.1311035156,6722.5444335938,256), cutted = false, cutTime = nil},
{position = Vector(-3511.564453125,6733.4702148438,256), cutted = false, cutTime = nil},
{position = Vector(-3858.3806152344,6565.6665039063,256), cutted = false, cutTime = nil},
{position = Vector(-4101.5346679688,6553.9340820313,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3724.53515625,6548.1108398438,256), cutted = false, cutTime = nil},
{position = Vector(-3601.8518066406,6598.537109375,256), cutted = false, cutTime = nil},
{position = Vector(-3465.2602539063,6629.216796875,256), cutted = false, cutTime = nil},
{position = Vector(-3316.1611328125,6561.2529296875,256), cutted = false, cutTime = nil},
{position = Vector(-4311.2763671875,6651.2216796875,256), cutted = false, cutTime = nil},
{position = Vector(-4461.6640625,6629.5756835938,256), cutted = false, cutTime = nil},
{position = Vector(-4596.1420898438,6687.10546875,256), cutted = false, cutTime = nil},
{position = Vector(-4412.0029296875,6828.2045898438,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4504.6137695313,6824.7373046875,256), cutted = false, cutTime = nil},
{position = Vector(-4642.9370117188,6809.25,256), cutted = false, cutTime = nil},
{position = Vector(-4801.3310546875,6812.6752929688,256), cutted = false, cutTime = nil},
{position = Vector(-4924.2993164063,6799.0283203125,256), cutted = false, cutTime = nil},
{position = Vector(-4941.8120117188,6826.4697265625,256), cutted = false, cutTime = nil},
{position = Vector(-4829.796875,6590.3266601563,256), cutted = false, cutTime = nil},
{position = Vector(-4379.6616210938,6923.6235351563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4608.345703125,6996.2260742188,256), cutted = false, cutTime = nil},
{position = Vector(-4609.1069335938,7105.2377929688,256), cutted = false, cutTime = nil},
{position = Vector(-4801.353515625,7063.2412109375,256), cutted = false, cutTime = nil},
{position = Vector(-4792.6010742188,7219.8955078125,256), cutted = false, cutTime = nil},
{position = Vector(-4746.2631835938,7333.4477539063,256), cutted = false, cutTime = nil},
{position = Vector(-4791.1000976563,7503.7099609375,256), cutted = false, cutTime = nil},
{position = Vector(-4260.7778320313,7513.3247070313,256), cutted = false, cutTime = nil},
{position = Vector(-4843.8935546875,7302,256), cutted = false, cutTime = nil},
{position = Vector(-5000.4194335938,7333.447265625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4988.7426757813,7517.1904296875,256), cutted = false, cutTime = nil},
{position = Vector(-5095.0327148438,7017.6801757813,256), cutted = false, cutTime = nil},
{position = Vector(-5278.13671875,7249.2451171875,256), cutted = false, cutTime = nil},
{position = Vector(-5199.1015625,7390.0419921875,256), cutted = false, cutTime = nil},
{position = Vector(-5170.416015625,6967.5063476563,256), cutted = false, cutTime = nil},
{position = Vector(-5152.623046875,7073.4926757813,256), cutted = false, cutTime = nil},
{position = Vector(-5318.7348632813,7011.3369140625,256), cutted = false, cutTime = nil},
{position = Vector(-5378.0922851563,7136.25390625,256), cutted = false, cutTime = nil},
{position = Vector(-5380.8569335938,7254.7158203125,256), cutted = false, cutTime = nil},
{position = Vector(-5309.6450195313,7434.87890625,256), cutted = false, cutTime = nil},
{position = Vector(-5308.5278320313,7513.2861328125,256), cutted = false, cutTime = nil},
{position = Vector(-5501.810546875,7553.994140625,259.98779296875), cutted = false, cutTime = nil},
{position = Vector(-5581.0791015625,7348.58984375,256), cutted = false, cutTime = nil},
{position = Vector(-5738.0400390625,7557.0390625,266.07800292969), cutted = false, cutTime = nil},
{position = Vector(-5715.9399414063,7557.0390625,266.07788085938), cutted = false, cutTime = nil},
{position = Vector(-5852.4526367188,7466.83984375,256), cutted = false, cutTime = nil},
{position = Vector(-5961.3857421875,7523.1650390625,256), cutted = false, cutTime = nil},
{position = Vector(-5981.20703125,7423.7788085938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6159.1684570313,7455.4248046875,256), cutted = false, cutTime = nil},
{position = Vector(-6300.3334960938,7451.6206054688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6277.5327148438,7290.7309570313,256), cutted = false, cutTime = nil},
{position = Vector(-6153.8823242188,7260.8022460938,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6179.67578125,7292.4145507813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6017.6743164063,7246.09765625,256), cutted = false, cutTime = nil},
{position = Vector(-5907.1860351563,7175.0576171875,256), cutted = false, cutTime = nil},
{position = Vector(-5894.2700195313,7187.3935546875,256), cutted = false, cutTime = nil},
{position = Vector(-6130.4047851563,7092.046875,256), cutted = false, cutTime = nil},
{position = Vector(-6023.4243164063,7026.5927734375,256), cutted = false, cutTime = nil},
{position = Vector(-5742.9077148438,7065.1440429688,256), cutted = false, cutTime = nil},
{position = Vector(-5850.6147460938,6965.9389648438,256), cutted = false, cutTime = nil},
{position = Vector(-5751.8452148438,6943.064453125,256), cutted = false, cutTime = nil},
{position = Vector(-5548.0634765625,7016.3002929688,256), cutted = false, cutTime = nil},
{position = Vector(-5461.087890625,6939.68359375,256), cutted = false, cutTime = nil},
{position = Vector(-5441.4799804688,7008.2680664063,256), cutted = false, cutTime = nil},
{position = Vector(-5361.1552734375,6889.3828125,256), cutted = false, cutTime = nil},
{position = Vector(-5648.7158203125,6844.7553710938,256), cutted = false, cutTime = nil},
{position = Vector(-5722.8305664063,6800.2309570313,256), cutted = false, cutTime = nil},
{position = Vector(-5633.1333007813,6612.1752929688,256), cutted = false, cutTime = nil},
{position = Vector(-5691.3662109375,6496.0571289063,256), cutted = false, cutTime = nil},
{position = Vector(-5509.4477539063,6607.8247070313,256), cutted = false, cutTime = nil},
{position = Vector(-5570.3095703125,6731.1376953125,256), cutted = false, cutTime = nil},
{position = Vector(-5427.119140625,6716.810546875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5361.8408203125,6615.0844726563,256), cutted = false, cutTime = nil},
{position = Vector(-5302.3896484375,6735.9501953125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5257.5473632813,6619.4619140625,256), cutted = false, cutTime = nil},
{position = Vector(-5130.177734375,6766.861328125,256), cutted = false, cutTime = nil},
{position = Vector(-5119.0952148438,6628.2646484375,256), cutted = false, cutTime = nil},
{position = Vector(-4990.8081054688,6727.9399414063,256), cutted = false, cutTime = nil},
{position = Vector(-4920.669921875,6590.5786132813,256), cutted = false, cutTime = nil},
{position = Vector(-5892.2172851563,6693.2924804688,256), cutted = false, cutTime = nil},
{position = Vector(-6002.5249023438,6668.6899414063,256), cutted = false, cutTime = nil},
{position = Vector(-6020.1313476563,6824.1147460938,256), cutted = false, cutTime = nil},
{position = Vector(-6196.978515625,6677.8583984375,256), cutted = false, cutTime = nil},
{position = Vector(-6154.52734375,6807.009765625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6251.7104492188,6977.2504882813,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6367.63671875,7030.3720703125,256), cutted = false, cutTime = nil},
{position = Vector(-6336.7543945313,6860.78125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6428.7817382813,6702.646484375,256), cutted = false, cutTime = nil},
{position = Vector(-6382.7065429688,6761.9301757813,256), cutted = false, cutTime = nil},
{position = Vector(-6219.6865234375,6556.8237304688,256), cutted = false, cutTime = nil},
{position = Vector(-6212.1767578125,6453.271484375,256), cutted = false, cutTime = nil},
{position = Vector(-6014.7309570313,6428.8647460938,256), cutted = false, cutTime = nil},
{position = Vector(-5996.2299804688,6414.4521484375,256), cutted = false, cutTime = nil},
{position = Vector(-5949.7045898438,6515.6201171875,256), cutted = false, cutTime = nil},
{position = Vector(-6267.9096679688,6338.8823242188,256), cutted = false, cutTime = nil},
{position = Vector(-6354.4194335938,6469.4809570313,256), cutted = false, cutTime = nil},
{position = Vector(-6466.158203125,6527.7153320313,256), cutted = false, cutTime = nil},
{position = Vector(-6484.8071289063,6663.4389648438,256), cutted = false, cutTime = nil},
{position = Vector(-6455.9174804688,6910.1059570313,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6557.642578125,6765.0405273438,256), cutted = false, cutTime = nil},
{position = Vector(-6662.5932617188,6720.7045898438,256), cutted = false, cutTime = nil},
{position = Vector(-6661.611328125,6841.9731445313,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6665.8432617188,6563.8569335938,256), cutted = false, cutTime = nil},
{position = Vector(-6663.994140625,6559.458984375,256), cutted = false, cutTime = nil},
{position = Vector(-6769.4135742188,6677.9086914063,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6777.9487304688,6679.52734375,255.99975585938), cutted = false, cutTime = nil},
{position = Vector(-6917.439453125,6566.7978515625,256), cutted = false, cutTime = nil},
{position = Vector(-6929.703125,6574.18359375,256), cutted = false, cutTime = nil},
{position = Vector(-6549.4829101563,6296.3813476563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6915.1484375,6432.1391601563,256), cutted = false, cutTime = nil},
{position = Vector(-7010.59765625,6380.236328125,256), cutted = false, cutTime = nil},
{position = Vector(-6856.3969726563,6296.1762695313,256), cutted = false, cutTime = nil},
{position = Vector(-6690.1611328125,6287.0390625,256), cutted = false, cutTime = nil},
{position = Vector(-6503.23828125,6189.056640625,256), cutted = false, cutTime = nil},
{position = Vector(-6681.3466796875,6202.5073242188,256), cutted = false, cutTime = nil},
{position = Vector(-6641.873046875,6203.861328125,256), cutted = false, cutTime = nil},
{position = Vector(-6801.298828125,6181.0639648438,256), cutted = false, cutTime = nil},
{position = Vector(-6934.943359375,6232.6791992188,256), cutted = false, cutTime = nil},
{position = Vector(-7052.8940429688,6236.8569335938,256), cutted = false, cutTime = nil},
{position = Vector(-7200.9584960938,6182.392578125,256), cutted = false, cutTime = nil},
{position = Vector(-7068.4033203125,6135.5625,256), cutted = false, cutTime = nil},
{position = Vector(-7144.2163085938,6072.5126953125,256), cutted = false, cutTime = nil},
{position = Vector(-6973.85546875,5979.5810546875,256), cutted = false, cutTime = nil},
{position = Vector(-6810.5170898438,5942.9736328125,256), cutted = false, cutTime = nil},
{position = Vector(-6688.2744140625,5914.8388671875,256), cutted = false, cutTime = nil},
{position = Vector(-7192.548828125,5964.0263671875,256), cutted = false, cutTime = nil},
{position = Vector(-7144.1977539063,5817.0776367188,256), cutted = false, cutTime = nil},
{position = Vector(-7231.8198242188,5797.4526367188,256), cutted = false, cutTime = nil},
{position = Vector(-7014.9028320313,5792.96875,256), cutted = false, cutTime = nil},
{position = Vector(-6864.3481445313,5795.9560546875,256), cutted = false, cutTime = nil},
{position = Vector(-6910.263671875,5669.8862304688,256), cutted = false, cutTime = nil},
{position = Vector(-7187.5268554688,6065.5625,256), cutted = false, cutTime = nil},
{position = Vector(-7239.0551757813,5665.8681640625,256), cutted = false, cutTime = nil},
{position = Vector(-7031.3374023438,5669.8862304688,256), cutted = false, cutTime = nil},
{position = Vector(-6808.7451171875,5675.2661132813,256), cutted = false, cutTime = nil},
{position = Vector(-6603.4624023438,5675.2661132813,256), cutted = false, cutTime = nil},
{position = Vector(-7064.8271484375,5499.4780273438,256), cutted = false, cutTime = nil},
{position = Vector(-6964.126953125,5421.8793945313,256), cutted = false, cutTime = nil},
{position = Vector(-7036.828125,5553.6791992188,256), cutted = false, cutTime = nil},
{position = Vector(-7152.7553710938,5536.3784179688,256), cutted = false, cutTime = nil},
{position = Vector(-6843.6440429688,5539.5053710938,256), cutted = false, cutTime = nil},
{position = Vector(-6826.2763671875,5421.8793945313,256), cutted = false, cutTime = nil},
{position = Vector(-6701.0180664063,5338.6489257813,256), cutted = false, cutTime = nil},
{position = Vector(-6672.4892578125,5423.2963867188,256), cutted = false, cutTime = nil},
{position = Vector(-6781.48828125,5446.2080078125,256), cutted = false, cutTime = nil},
{position = Vector(-6586.0063476563,5536.3784179688,256), cutted = false, cutTime = nil},
{position = Vector(-6473.8383789063,5484.4360351563,256), cutted = false, cutTime = nil},
{position = Vector(-6995.5361328125,5214.5864257813,256), cutted = false, cutTime = nil},
{position = Vector(-7147.8754882813,5180.0493164063,256), cutted = false, cutTime = nil},
{position = Vector(-7091.5766601563,5114.7055664063,256), cutted = false, cutTime = nil},
{position = Vector(-6933.7622070313,5043.7543945313,256), cutted = false, cutTime = nil},
{position = Vector(-6912.4467773438,5058.9912109375,256), cutted = false, cutTime = nil},
{position = Vector(-6757.3920898438,5054.8159179688,256), cutted = false, cutTime = nil},
{position = Vector(-6474.115234375,5073.0224609375,256), cutted = false, cutTime = nil},
{position = Vector(-6767.6025390625,5082.947265625,256), cutted = false, cutTime = nil},
{position = Vector(-7247.099609375,4964.0986328125,256), cutted = false, cutTime = nil},
{position = Vector(-7077.482421875,5285.9033203125,256), cutted = false, cutTime = nil},
{position = Vector(-7196.9604492188,5428.4169921875,256), cutted = false, cutTime = nil},
{position = Vector(-6717.7763671875,4903.6704101563,256), cutted = false, cutTime = nil},
{position = Vector(-6703.9145507813,5000.6987304688,256), cutted = false, cutTime = nil},
{position = Vector(-6898.7358398438,4838.6459960938,256), cutted = false, cutTime = nil},
{position = Vector(-7130.333984375,4784.0463867188,256), cutted = false, cutTime = nil},
{position = Vector(-7250.6235351563,4763.1904296875,256), cutted = false, cutTime = nil},
{position = Vector(-6701.1782226563,4546.572265625,256), cutted = false, cutTime = nil},
{position = Vector(-6885.6943359375,4381.5952148438,256), cutted = false, cutTime = nil},
{position = Vector(-6792.9077148438,4256.744140625,256), cutted = false, cutTime = nil},
{position = Vector(-6664.1337890625,4284.1958007813,256), cutted = false, cutTime = nil},
{position = Vector(-6588.8984375,4492.767578125,256), cutted = false, cutTime = nil},
{position = Vector(-6718.0908203125,4541.94921875,256), cutted = false, cutTime = nil},
{position = Vector(-7277.3598632813,4138.0317382813,256), cutted = false, cutTime = nil},
{position = Vector(-7369.7041015625,4194.806640625,256), cutted = false, cutTime = nil},
{position = Vector(-7234.7163085938,4185.447265625,256), cutted = false, cutTime = nil},
{position = Vector(-7101.4545898438,4188.5590820313,256), cutted = false, cutTime = nil},
{position = Vector(-7092.9326171875,4194.806640625,256), cutted = false, cutTime = nil},
{position = Vector(-6920.3803710938,4034.0966796875,256), cutted = false, cutTime = nil},
{position = Vector(-7224.7280273438,3928.8950195313,256), cutted = false, cutTime = nil},
{position = Vector(-7039.45703125,3887.6313476563,256), cutted = false, cutTime = nil},
{position = Vector(-7071.4521484375,3936.3469238281,256), cutted = false, cutTime = nil},
{position = Vector(-6821.8173828125,3875.8623046875,255.75048828125), cutted = false, cutTime = nil},
{position = Vector(-7284.93359375,3814.091796875,255.26440429688), cutted = false, cutTime = nil},
{position = Vector(-7156.8286132813,3806.5314941406,255.50708007813), cutted = false, cutTime = nil},
{position = Vector(-7278.263671875,3811.1811523438,255.13122558594), cutted = false, cutTime = nil},
{position = Vector(-7457.7182617188,3693.5512695313,256), cutted = false, cutTime = nil},
{position = Vector(-7427.4184570313,3942.7353515625,256), cutted = false, cutTime = nil},
{position = Vector(-7072.83984375,3692.2114257813,256), cutted = false, cutTime = nil},
{position = Vector(-6842.4135742188,3744.2333984375,253.03771972656), cutted = false, cutTime = nil},
{position = Vector(-6733.6025390625,3794.5361328125,255.90563964844), cutted = false, cutTime = nil},
{position = Vector(-6755.2514648438,3594.9541015625,256), cutted = false, cutTime = nil},
{position = Vector(-6916.412109375,3598.6301269531,256), cutted = false, cutTime = nil},
{position = Vector(-7077.8486328125,3511.5517578125,256), cutted = false, cutTime = nil},
{position = Vector(-7264.3188476563,3518.3432617188,256), cutted = false, cutTime = nil},
{position = Vector(-7397.68359375,3470.6560058594,256), cutted = false, cutTime = nil},
{position = Vector(-7252.6625976563,3460.6354980469,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-7017.30859375,3322.8000488281,256), cutted = false, cutTime = nil},
{position = Vector(-6856.6899414063,3339.5947265625,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-6905.8989257813,3456.2849121094,256), cutted = false, cutTime = nil},
{position = Vector(-6801.69921875,3482.6418457031,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5730.7866210938,3489.1342773438,255.83056640625), cutted = false, cutTime = nil},
{position = Vector(-5728.7646484375,3454.9514160156,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5582.8447265625,3499.9345703125,256), cutted = false, cutTime = nil},
{position = Vector(-5432.4594726563,3517.2370605469,256.09643554688), cutted = false, cutTime = nil},
{position = Vector(-5576.9165039063,3838,256), cutted = false, cutTime = nil},
{position = Vector(-5731.4248046875,3884.6457519531,256), cutted = false, cutTime = nil},
{position = Vector(-5897.9052734375,3967.1323242188,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-6030.15234375,4038.6865234375,256), cutted = false, cutTime = nil},
{position = Vector(-5657.0903320313,4174.7124023438,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5451.7084960938,4098.6049804688,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5349.4223632813,3991.1530761719,256), cutted = false, cutTime = nil},
{position = Vector(-5285.9296875,4136.0561523438,256), cutted = false, cutTime = nil},
{position = Vector(-5515.5571289063,4225.7939453125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5669.751953125,4246.8427734375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-5768.1000976563,4311.2055664063,256), cutted = false, cutTime = nil},
{position = Vector(-5708.7236328125,4428.7314453125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-5808.8627929688,4374.8227539063,256), cutted = false, cutTime = nil},
{position = Vector(-5692.775390625,4579.1455078125,256), cutted = false, cutTime = nil},
{position = Vector(-5806.462890625,4677.0546875,256), cutted = false, cutTime = nil},
{position = Vector(-5308.3330078125,4776.3872070313,256), cutted = false, cutTime = nil},
{position = Vector(-5360.4658203125,4879.0170898438,256), cutted = false, cutTime = nil},
{position = Vector(-5429.0083007813,5006.0366210938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5565.4204101563,5026.4614257813,256), cutted = false, cutTime = nil},
{position = Vector(-5315.7631835938,5051.2421875,256), cutted = false, cutTime = nil},
{position = Vector(-5358.9243164063,5120.7392578125,256), cutted = false, cutTime = nil},
{position = Vector(-5486.626953125,5119.3330078125,256), cutted = false, cutTime = nil},
{position = Vector(-5220.3017578125,5159.4013671875,256), cutted = false, cutTime = nil},
{position = Vector(-5309.7504882813,5261.4814453125,256), cutted = false, cutTime = nil},
{position = Vector(-5179.1616210938,4990.9765625,256), cutted = false, cutTime = nil},
{position = Vector(-5127.6630859375,4956.6684570313,256), cutted = false, cutTime = nil},
{position = Vector(-5132.3325195313,5012.3764648438,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5036.5727539063,4995.9721679688,256), cutted = false, cutTime = nil},
{position = Vector(-5071.37109375,5130.6337890625,256), cutted = false, cutTime = nil},
{position = Vector(-4889.5991210938,5084.751953125,256), cutted = false, cutTime = nil},
{position = Vector(-4912.9423828125,5223.8618164063,256), cutted = false, cutTime = nil},
{position = Vector(-4806.9638671875,5318.6025390625,256), cutted = false, cutTime = nil},
{position = Vector(-4727.6489257813,5315.2631835938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4692.8510742188,5210.064453125,256), cutted = false, cutTime = nil},
{position = Vector(-4734.4013671875,5056.5336914063,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-5226.2631835938,4763.3969726563,256), cutted = false, cutTime = nil},
{position = Vector(-4995.1274414063,4784.0830078125,256), cutted = false, cutTime = nil},
{position = Vector(-5000.4501953125,4650.7158203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-4932.9448242188,4908.4770507813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-4862.3500976563,4712.1850585938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-4799.5717773438,4976.3081054688,256), cutted = false, cutTime = nil},
{position = Vector(-4731.9296875,4813.201171875,256), cutted = false, cutTime = nil},
{position = Vector(-4612.369140625,4956.294921875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4548.9887695313,4801.1928710938,256), cutted = false, cutTime = nil},
{position = Vector(-4516.2524414063,4834.884765625,256), cutted = false, cutTime = nil},
{position = Vector(-4616.1440429688,5068.341796875,256), cutted = false, cutTime = nil},
{position = Vector(-4451.6176757813,5098.9453125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4537.0810546875,5294.224609375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4432.794921875,5451.7763671875,256), cutted = false, cutTime = nil},
{position = Vector(-4363.4116210938,5264.4331054688,256), cutted = false, cutTime = nil},
{position = Vector(-4321.7934570313,5073.3891601563,256), cutted = false, cutTime = nil},
{position = Vector(-4330.3452148438,5095.5068359375,256), cutted = false, cutTime = nil},
{position = Vector(-4380.9658203125,4776.2783203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-4186.4653320313,4895.3852539063,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4174.890625,4998.2543945313,256), cutted = false, cutTime = nil},
{position = Vector(-4103.3637695313,4993.5166015625,256), cutted = false, cutTime = nil},
{position = Vector(-4233.8452148438,5093.791015625,256), cutted = false, cutTime = nil},
{position = Vector(-4215.5576171875,5197.474609375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4098.0341796875,5158.9282226563,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-3913.9438476563,5171.6459960938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4170.6259765625,5348.5561523438,256), cutted = false, cutTime = nil},
{position = Vector(-4036.6865234375,5378.1982421875,256), cutted = false, cutTime = nil},
{position = Vector(-4088.6154785156,5514.67578125,256), cutted = false, cutTime = nil},
{position = Vector(-3974.0236816406,5528.6484375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-3886.4653320313,5428.5146484375,256), cutted = false, cutTime = nil},
{position = Vector(-3809.15625,5568.3647460938,256), cutted = false, cutTime = nil},
{position = Vector(-3682.8249511719,5531.7768554688,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-3690.3129882813,5534.9130859375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-3652.6394042969,5412.89453125,256), cutted = false, cutTime = nil},
{position = Vector(-4303.9306640625,4696.578125,256), cutted = false, cutTime = nil},
{position = Vector(-3002.3630371094,5581.51953125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-2976.5886230469,5560.02734375,256), cutted = false, cutTime = nil},
{position = Vector(-3003.4599609375,5660.9252929688,256), cutted = false, cutTime = nil},
{position = Vector(-2867.8264160156,5654.736328125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-2986.60546875,5370.5795898438,256), cutted = false, cutTime = nil},
{position = Vector(-2827.951171875,5314.0654296875,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-2885.3950195313,5414.2143554688,256), cutted = false, cutTime = nil},
{position = Vector(-2873.0346679688,5674.9731445313,256), cutted = false, cutTime = nil},
{position = Vector(-2755.6787109375,5639.4072265625,256), cutted = false, cutTime = nil},
{position = Vector(-2728.88671875,5650.1157226563,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-2621.7314453125,5647.0458984375,256), cutted = false, cutTime = nil},
{position = Vector(-2715.1821289063,5454.6118164063,256), cutted = false, cutTime = nil},
{position = Vector(-2683.0336914063,5253.2236328125,256), cutted = false, cutTime = nil},
{position = Vector(-2605.8068847656,5401.9057617188,256), cutted = false, cutTime = nil},
{position = Vector(-2560.9497070313,5525.1098632813,256), cutted = false, cutTime = nil},
{position = Vector(-2402.5573730469,5523.736328125,256), cutted = false, cutTime = nil},
{position = Vector(-2436.6115722656,5347.1245117188,256), cutted = false, cutTime = nil},
{position = Vector(-2422.6494140625,5378.9189453125,256), cutted = false, cutTime = nil},
{position = Vector(-2320.091796875,5536.1630859375,256), cutted = false, cutTime = nil},
{position = Vector(-2318.5520019531,5344.8090820313,256), cutted = false, cutTime = nil},
{position = Vector(-2460.9216308594,5270.2197265625,256), cutted = false, cutTime = nil},
{position = Vector(-2171.5888671875,5271.6845703125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-2016.4322509766,5604.7880859375,256), cutted = false, cutTime = nil},
{position = Vector(-1981.7551269531,5322.4243164063,256), cutted = false, cutTime = nil},
{position = Vector(-1920.3333740234,5215.2578125,256), cutted = false, cutTime = nil},
{position = Vector(-1870.1096191406,5538.6806640625,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-1859.1058349609,5643.94921875,256), cutted = false, cutTime = nil},
{position = Vector(-1726.2258300781,5467.158203125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-1667.6950683594,5593.0063476563,256), cutted = false, cutTime = nil},
{position = Vector(-1494.5493164063,5665.6040039063,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-1374.9790039063,5659.375,256), cutted = false, cutTime = nil},
{position = Vector(-1453.6020507813,5697.2578125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-1369.6259765625,5668.7309570313,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-1540.9798583984,5350.0004882813,256), cutted = false, cutTime = nil},
{position = Vector(-1555.6672363281,5158.71875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-1419.2451171875,5257.1274414063,256), cutted = false, cutTime = nil},
{position = Vector(-1556.8123779297,5303.6528320313,256), cutted = false, cutTime = nil},
{position = Vector(-1374.3771972656,5398.447265625,256), cutted = false, cutTime = nil},
{position = Vector(-1315.9803466797,5561.4091796875,256), cutted = false, cutTime = nil},
{position = Vector(-1307.4821777344,5437.3725585938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-1159.2015380859,5482.2885742188,256), cutted = false, cutTime = nil},
{position = Vector(-1214.9249267578,5589.9692382813,256), cutted = false, cutTime = nil},
{position = Vector(-1103.1378173828,5598.935546875,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-1131.1553955078,5659.7744140625,256), cutted = false, cutTime = nil},
{position = Vector(-959.85919189453,5657.8876953125,256), cutted = false, cutTime = nil},
{position = Vector(-1115.2803955078,5243.9892578125,256), cutted = false, cutTime = nil},
{position = Vector(-1216.1376953125,5278.9594726563,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-931.60552978516,5373.0966796875,256), cutted = false, cutTime = nil},
{position = Vector(-876.60211181641,5507.0708007813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-841.75122070313,5602.5400390625,256), cutted = false, cutTime = nil},
{position = Vector(-378.85125732422,5215.3276367188,256), cutted = false, cutTime = nil},
{position = Vector(-273.49380493164,5095.1142578125,256), cutted = false, cutTime = nil},
{position = Vector(-232.5638885498,5193.7114257813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-338.32293701172,5306.7993164063,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-113.75396728516,5447.0458984375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-92.567260742188,5479.224609375,256), cutted = false, cutTime = nil},
{position = Vector(-45.346282958984,5319.4951171875,256), cutted = false, cutTime = nil},
{position = Vector(-38.328033447266,5355.54296875,256), cutted = false, cutTime = nil},
{position = Vector(66.607879638672,5313.8344726563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(74.556365966797,5340.9838867188,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(188.98690795898,5250.759765625,256), cutted = false, cutTime = nil},
{position = Vector(-42.265350341797,5102.01171875,256), cutted = false, cutTime = nil},
{position = Vector(-65.08943939209,4946.7270507813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(55.218933105469,4875.2875976563,256), cutted = false, cutTime = nil},
{position = Vector(-308.78991699219,4860.056640625,256), cutted = false, cutTime = nil},
{position = Vector(218.79699707031,4870.185546875,256), cutted = false, cutTime = nil},
{position = Vector(273.40777587891,5005.6303710938,256), cutted = false, cutTime = nil},
{position = Vector(1190.4722900391,5094.84375,256), cutted = false, cutTime = nil},
{position = Vector(1305.271484375,5077.498046875,256), cutted = false, cutTime = nil},
{position = Vector(1647.9195556641,5048.458984375,128), cutted = false, cutTime = nil},
{position = Vector(1594.2918701172,4935.3349609375,128), cutted = false, cutTime = nil},
{position = Vector(1907.2092285156,4703.3720703125,128), cutted = false, cutTime = nil},
{position = Vector(2422.6467285156,5137.283203125,128), cutted = false, cutTime = nil},
{position = Vector(2317.2290039063,5245.2719726563,128), cutted = false, cutTime = nil},
{position = Vector(2754.9113769531,4542.828125,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(2878.4626464844,4502.4389648438,141.86926269531), cutted = false, cutTime = nil},
{position = Vector(6174.3779296875,6607.4169921875,256), cutted = false, cutTime = nil},
{position = Vector(6200.4428710938,6821.263671875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6269.5029296875,7037.1762695313,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5962.0903320313,6630.2075195313,256), cutted = false, cutTime = nil},
{position = Vector(5991.5551757813,6798.69140625,256), cutted = false, cutTime = nil},
{position = Vector(5991.2045898438,6864.6059570313,256), cutted = false, cutTime = nil},
{position = Vector(6006.4365234375,6961.4482421875,256), cutted = false, cutTime = nil},
{position = Vector(6082.486328125,6973.4663085938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5854.4775390625,6852.05859375,256), cutted = false, cutTime = nil},
{position = Vector(5843.982421875,7022.7368164063,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5759.1723632813,6759.1479492188,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5636.876953125,6631.48828125,256), cutted = false, cutTime = nil},
{position = Vector(5519.7236328125,6637.9140625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5577.5649414063,6762.0302734375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5716.5141601563,6845.8344726563,256), cutted = false, cutTime = nil},
{position = Vector(5554.3056640625,6872.5166015625,256), cutted = false, cutTime = nil},
{position = Vector(5710.4775390625,6997.8588867188,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5837.544921875,7104.25390625,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5577.3647460938,6987.3466796875,256), cutted = false, cutTime = nil},
{position = Vector(5387.169921875,6805.7348632813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5450.6181640625,6891.5844726563,256), cutted = false, cutTime = nil},
{position = Vector(5467.0498046875,7006.8408203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5572.466796875,7047.8349609375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5425.1220703125,7143.8266601563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5303.8549804688,6882.0737304688,256), cutted = false, cutTime = nil},
{position = Vector(5239.537109375,6697.5205078125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5234.2744140625,6563.3798828125,256), cutted = false, cutTime = nil},
{position = Vector(5037.935546875,6618.9262695313,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(5119.72265625,6753.8081054688,256), cutted = false, cutTime = nil},
{position = Vector(5316.1909179688,7017.404296875,256), cutted = false, cutTime = nil},
{position = Vector(5166.3149414063,7073.4677734375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4980.3798828125,7097.7475585938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4976.09375,6923.8588867188,256), cutted = false, cutTime = nil},
{position = Vector(4853.287109375,6925.49609375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4838.1396484375,6667.19140625,256), cutted = false, cutTime = nil},
{position = Vector(4605.4262695313,6647.6752929688,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4600.8779296875,6828.1010742188,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4752.9340820313,6867.7944335938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4871.470703125,7064.6713867188,256), cutted = false, cutTime = nil},
{position = Vector(4748.1782226563,7022.935546875,256), cutted = false, cutTime = nil},
{position = Vector(4586.94140625,7052.3500976563,256), cutted = false, cutTime = nil},
{position = Vector(4463.1904296875,6878.3188476563,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4484.0576171875,7075.33203125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4395.4487304688,6750.0708007813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4220.3540039063,6797.2080078125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4243.7758789063,6987.5732421875,256), cutted = false, cutTime = nil},
{position = Vector(4254.1811523438,6999.3876953125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4010.4523925781,6903.2719726563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(4006.2255859375,7002.7841796875,256), cutted = false, cutTime = nil},
{position = Vector(4122.7734375,7058.44921875,256), cutted = false, cutTime = nil},
{position = Vector(4014.3681640625,6755.2275390625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4058.6618652344,6603.1713867188,256), cutted = false, cutTime = nil},
{position = Vector(3981.1062011719,6728.1069335938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3745.5935058594,6811.5610351563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3660.017578125,6755.2280273438,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3524.8259277344,6668.205078125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3519.3715820313,6790.099609375,256), cutted = false, cutTime = nil},
{position = Vector(3709.5754394531,6990.9370117188,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3821.6467285156,7051.3530273438,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3580.2990722656,7042.5385742188,256), cutted = false, cutTime = nil},
{position = Vector(3452.2658691406,7030.302734375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3327.6540527344,7035.5317382813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3189.6257324219,6997.6928710938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3279.3232421875,6745.658203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3180.734375,6742.939453125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(6969.4956054688,5649.56640625,256), cutted = false, cutTime = nil},
{position = Vector(6994.8793945313,5511.0771484375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7098.98828125,5587.2421875,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7204.1733398438,5688.234375,256), cutted = false, cutTime = nil},
{position = Vector(7351.9926757813,5582.3134765625,256), cutted = false, cutTime = nil},
{position = Vector(7461.05078125,5589.7153320313,256), cutted = false, cutTime = nil},
{position = Vector(7449.9897460938,5470.6245117188,256), cutted = false, cutTime = nil},
{position = Vector(7175.890625,5477.2529296875,256), cutted = false, cutTime = nil},
{position = Vector(7322.1147460938,5403.6098632813,256), cutted = false, cutTime = nil},
{position = Vector(7308.4755859375,5277.2846679688,256), cutted = false, cutTime = nil},
{position = Vector(7437.0668945313,5366.5703125,256), cutted = false, cutTime = nil},
{position = Vector(7447.8286132813,5207.8461914063,256), cutted = false, cutTime = nil},
{position = Vector(7559.2333984375,5219.6958007813,256), cutted = false, cutTime = nil},
{position = Vector(7614.0834960938,5357.03125,256), cutted = false, cutTime = nil},
{position = Vector(7592.9760742188,5545.6625976563,256), cutted = false, cutTime = nil},
{position = Vector(7370.6440429688,5116.5458984375,256), cutted = false, cutTime = nil},
{position = Vector(7267.025390625,5036.5952148438,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7370.6791992188,4916.748046875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7504.6040039063,4909.3837890625,256), cutted = false, cutTime = nil},
{position = Vector(7250.4282226563,4756.6879882813,256), cutted = false, cutTime = nil},
{position = Vector(7431.3168945313,4679.529296875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7567.5034179688,4755.0283203125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7567.2280273438,4770.0458984375,256), cutted = false, cutTime = nil},
{position = Vector(7227.7358398438,4529.5439453125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7356.4077148438,4373.8706054688,256), cutted = false, cutTime = nil},
{position = Vector(7584.1157226563,4373.8706054688,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7239.1860351563,4087.1735839844,256), cutted = false, cutTime = nil},
{position = Vector(7236.5004882813,4176.9501953125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7377.6513671875,4136.9897460938,256), cutted = false, cutTime = nil},
{position = Vector(7491.2744140625,4159.8071289063,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7449.7568359375,3960.1552734375,256), cutted = false, cutTime = nil},
{position = Vector(7304.6665039063,3814.310546875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7253.4375,3594.203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7547.447265625,3732.8669433594,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7534.0209960938,3586.2587890625,256), cutted = false, cutTime = nil},
{position = Vector(7231.4658203125,3679.8933105469,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(7453.2456054688,3415.1569824219,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7307.3041992188,3361.9404296875,256), cutted = false, cutTime = nil},
{position = Vector(7546.00390625,3259.6899414063,256), cutted = false, cutTime = nil},
{position = Vector(7405.4555664063,3164.7893066406,256), cutted = false, cutTime = nil},
{position = Vector(7109.0297851563,3197.9846191406,256), cutted = false, cutTime = nil},
{position = Vector(7515.0849609375,3041.2495117188,256), cutted = false, cutTime = nil},
{position = Vector(7516.2436523438,2900.4892578125,256), cutted = false, cutTime = nil},
{position = Vector(7161.7670898438,2808.515625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7353.3637695313,2760.9194335938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7361.884765625,2774.3059082031,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(7527.81640625,2725.5930175781,256), cutted = false, cutTime = nil},
{position = Vector(5717.1088867188,2701.3969726563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5591.8999023438,2699.0588378906,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5425.509765625,2720.3059082031,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(5290.68359375,2770.4638671875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(4822.5034179688,2861.4467773438,256), cutted = false, cutTime = nil},
{position = Vector(4616.9467773438,2979.1188964844,256), cutted = false, cutTime = nil},
{position = Vector(3515.4086914063,4053.2592773438,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3832.7875976563,4386.6625976563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(3990.7211914063,4603.33984375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(3220.8098144531,4522.642578125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(3215.5671386719,4653.7524414063,256), cutted = false, cutTime = nil},
{position = Vector(1582.3438720703,6578.3481445313,128), cutted = false, cutTime = nil},
{position = Vector(1598.6154785156,6680.6806640625,128), cutted = false, cutTime = nil},
{position = Vector(1707.3951416016,6734.9375,128), cutted = false, cutTime = nil},
{position = Vector(1843.2747802734,6815.0727539063,128), cutted = false, cutTime = nil},
{position = Vector(1688.9362792969,6923.3510742188,128), cutted = false, cutTime = nil},
{position = Vector(1980.3260498047,6883.4770507813,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(2136.5283203125,6867.228515625,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(2223.5998535156,6870.4619140625,128), cutted = false, cutTime = nil},
{position = Vector(2406.64453125,6904.9189453125,128), cutted = false, cutTime = nil},
{position = Vector(2538.1098632813,6763.5717773438,128), cutted = false, cutTime = nil},
{position = Vector(1148.5532226563,6663.669921875,256), cutted = false, cutTime = nil},
{position = Vector(1032.9738769531,6667.0727539063,256), cutted = false, cutTime = nil},
{position = Vector(882.68658447266,6651.7485351563,256), cutted = false, cutTime = nil},
{position = Vector(755.3408203125,6669.134765625,256), cutted = false, cutTime = nil},
{position = Vector(762.71374511719,6771.4116210938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(897.36889648438,6792.2724609375,256), cutted = false, cutTime = nil},
{position = Vector(1011.8165893555,6805.2373046875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1070.2056884766,6931.2329101563,256), cutted = false, cutTime = nil},
{position = Vector(974.59405517578,6932.572265625,256), cutted = false, cutTime = nil},
{position = Vector(826.20452880859,6920.5791015625,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(831.43475341797,7064.841796875,256), cutted = false, cutTime = nil},
{position = Vector(949.50494384766,7073.935546875,256), cutted = false, cutTime = nil},
{position = Vector(1083.6857910156,7054.3232421875,256), cutted = false, cutTime = nil},
{position = Vector(1209.5025634766,7073.935546875,256), cutted = false, cutTime = nil},
{position = Vector(1225.6392822266,6943.3452148438,256), cutted = false, cutTime = nil},
{position = Vector(1073.6520996094,7164.076171875,256), cutted = false, cutTime = nil},
{position = Vector(950.60034179688,7187.3095703125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(729.1298828125,7270.521484375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(693.97180175781,7375.17578125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(837.91491699219,7386.912109375,256), cutted = false, cutTime = nil},
{position = Vector(974.36193847656,7392.8203125,256), cutted = false, cutTime = nil},
{position = Vector(1156.1237792969,7333.0297851563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(1280.8116455078,7329.2666015625,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(1430.6571044922,7312.4658203125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1374.7932128906,7078.509765625,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1270.9592285156,7521.2114257813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(951.47473144531,7503.9404296875,256), cutted = false, cutTime = nil},
{position = Vector(827.70123291016,7499.6567382813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1504.7760009766,7073.935546875,256), cutted = false, cutTime = nil},
{position = Vector(1417.2287597656,7441.0673828125,256), cutted = false, cutTime = nil},
{position = Vector(1556.5831298828,7394.7958984375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1642.4958496094,7147.7529296875,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(1780.9072265625,7159.1552734375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1702.4733886719,7377.1240234375,256), cutted = false, cutTime = nil},
{position = Vector(1794.5397949219,7348.1962890625,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(1814.2756347656,7261.5864257813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1861.4801025391,7120.0356445313,256), cutted = false, cutTime = nil},
{position = Vector(1915.5799560547,7274.6821289063,256), cutted = false, cutTime = nil},
{position = Vector(1977.9748535156,7387.126953125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2078.4304199219,7092.2685546875,256), cutted = false, cutTime = nil},
{position = Vector(2126.2502441406,7383.619140625,256), cutted = false, cutTime = nil},
{position = Vector(2186.3442382813,7107.4555664063,256), cutted = false, cutTime = nil},
{position = Vector(2234.7702636719,7376.6333007813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2321.494140625,7115.8266601563,256), cutted = false, cutTime = nil},
{position = Vector(2401.9291992188,7241.4638671875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(2432.1318359375,7104.6791992188,256), cutted = false, cutTime = nil},
{position = Vector(2558.7744140625,7243.025390625,256), cutted = false, cutTime = nil},
{position = Vector(2518.2863769531,7355.9047851563,256), cutted = false, cutTime = nil},
{position = Vector(2757.0991210938,7238.34765625,256), cutted = false, cutTime = nil},
{position = Vector(2626.3110351563,7364.5004882813,256), cutted = false, cutTime = nil},
{position = Vector(2760.9506835938,7361.0551757813,256), cutted = false, cutTime = nil},
{position = Vector(2589.5278320313,7067.853515625,256), cutted = false, cutTime = nil},
{position = Vector(2761.4802246094,7097.767578125,256), cutted = false, cutTime = nil},
{position = Vector(2708.8779296875,6982.7094726563,256), cutted = false, cutTime = nil},
{position = Vector(2699.8637695313,6837.3461914063,256), cutted = false, cutTime = nil},
{position = Vector(521.18621826172,6547.7451171875,256), cutted = false, cutTime = nil},
{position = Vector(586.47747802734,6682.9731445313,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(652.76586914063,6835.5532226563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(701.60961914063,6946.1625976563,256), cutted = false, cutTime = nil},
{position = Vector(721.12683105469,7043.5185546875,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(402.66818237305,6540.5854492188,256), cutted = false, cutTime = nil},
{position = Vector(450.86624145508,6684.3330078125,256), cutted = false, cutTime = nil},
{position = Vector(528.01428222656,6824.7270507813,256), cutted = false, cutTime = nil},
{position = Vector(579.37634277344,6946.1625976563,256), cutted = false, cutTime = nil},
{position = Vector(529.65777587891,7082.7475585938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(523.13604736328,7177.0830078125,256), cutted = false, cutTime = nil},
{position = Vector(512.91461181641,7280.7036132813,256), cutted = false, cutTime = nil},
{position = Vector(421.61578369141,7102.7548828125,256), cutted = false, cutTime = nil},
{position = Vector(391.46099853516,7192.0805664063,256), cutted = false, cutTime = nil},
{position = Vector(385.06573486328,7379.0234375,256), cutted = false, cutTime = nil},
{position = Vector(509.98419189453,7379.0234375,256), cutted = false, cutTime = nil},
{position = Vector(247.51196289063,7244.939453125,256), cutted = false, cutTime = nil},
{position = Vector(258.4853515625,7260.93359375,256), cutted = false, cutTime = nil},
{position = Vector(255.57649230957,7393.244140625,256), cutted = false, cutTime = nil},
{position = Vector(237.52966308594,6941.4877929688,256), cutted = false, cutTime = nil},
{position = Vector(119.79476928711,6932.9858398438,256), cutted = false, cutTime = nil},
{position = Vector(0.018096923828125,6956.2211914063,256), cutted = false, cutTime = nil},
{position = Vector(3.3457946777344,7068.0419921875,256), cutted = false, cutTime = nil},
{position = Vector(23.396179199219,7131.298828125,256), cutted = false, cutTime = nil},
{position = Vector(89.057983398438,7240.1821289063,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-97.071685791016,7265.7724609375,256), cutted = false, cutTime = nil},
{position = Vector(-7.5255126953125,7380.7924804688,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-152.63580322266,7413.0556640625,256), cutted = false, cutTime = nil},
{position = Vector(-157.2939453125,7131.2983398438,256), cutted = false, cutTime = nil},
{position = Vector(-196.86791992188,7280.4038085938,256), cutted = false, cutTime = nil},
{position = Vector(46.906967163086,6817.759765625,256), cutted = false, cutTime = nil},
{position = Vector(241.37405395508,6814.7744140625,256), cutted = false, cutTime = nil},
{position = Vector(253.62203979492,6819.2553710938,256), cutted = false, cutTime = nil},
{position = Vector(392.85192871094,6778.0751953125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(81.565979003906,6479.48828125,256), cutted = false, cutTime = nil},
{position = Vector(-3.8145599365234,6683.5532226563,256), cutted = false, cutTime = nil},
{position = Vector(-122.51909637451,6820.9829101563,256), cutted = false, cutTime = nil},
{position = Vector(-196.80073547363,6948.1635742188,256), cutted = false, cutTime = nil},
{position = Vector(-173.08923339844,6975.6518554688,256), cutted = false, cutTime = nil},
{position = Vector(-246.97470092773,7123.0966796875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-325.17864990234,6943.3774414063,256), cutted = false, cutTime = nil},
{position = Vector(-317.64086914063,7242.4497070313,256), cutted = false, cutTime = nil},
{position = Vector(-254.84980773926,7362.2734375,256), cutted = false, cutTime = nil},
{position = Vector(-318.31604003906,6521.1801757813,256), cutted = false, cutTime = nil},
{position = Vector(-519.58758544922,6543.6157226563,256), cutted = false, cutTime = nil},
{position = Vector(-317.38079833984,6658.0883789063,256), cutted = false, cutTime = nil},
{position = Vector(-443.41558837891,6687.6440429688,256), cutted = false, cutTime = nil},
{position = Vector(-382.17474365234,6776.7802734375,256), cutted = false, cutTime = nil},
{position = Vector(-517.68194580078,6797.55078125,256), cutted = false, cutTime = nil},
{position = Vector(-657.74438476563,6794.560546875,256), cutted = false, cutTime = nil},
{position = Vector(-439.17413330078,6909.8491210938,256), cutted = false, cutTime = nil},
{position = Vector(-580.46997070313,6935.1430664063,256), cutted = false, cutTime = nil},
{position = Vector(-769.09283447266,6946.716796875,256), cutted = false, cutTime = nil},
{position = Vector(-378.73623657227,7035.4301757813,256), cutted = false, cutTime = nil},
{position = Vector(-618.38702392578,7059.4360351563,256), cutted = false, cutTime = nil},
{position = Vector(-510.78540039063,7053.7426757813,256), cutted = false, cutTime = nil},
{position = Vector(-790.65753173828,7065.1567382813,256), cutted = false, cutTime = nil},
{position = Vector(-581.7373046875,7240.8330078125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-425.41744995117,7300.1684570313,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-551.94848632813,7331.783203125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-708.08184814453,7324.6909179688,256), cutted = false, cutTime = nil},
{position = Vector(-700.57360839844,7337.0361328125,266.84167480469), cutted = false, cutTime = nil},
{position = Vector(-830.14007568359,7217.8549804688,256), cutted = false, cutTime = nil},
{position = Vector(-900.43676757813,7351.48828125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-937.61163330078,7173.1328125,256), cutted = false, cutTime = nil},
{position = Vector(-963.98693847656,7206.5224609375,256), cutted = false, cutTime = nil},
{position = Vector(-797.34063720703,6840.79296875,256), cutted = false, cutTime = nil},
{position = Vector(-853.01916503906,6958.5913085938,256), cutted = false, cutTime = nil},
{position = Vector(-921.10498046875,6760.7866210938,256), cutted = false, cutTime = nil},
{position = Vector(-927.96862792969,6810.9086914063,256), cutted = false, cutTime = nil},
{position = Vector(-1038.9002685547,6890.5952148438,256), cutted = false, cutTime = nil},
{position = Vector(-1142.7419433594,6738.9638671875,256), cutted = false, cutTime = nil},
{position = Vector(-1284.8645019531,6755.8989257813,256), cutted = false, cutTime = nil},
{position = Vector(-1076.3127441406,7027.6430664063,256), cutted = false, cutTime = nil},
{position = Vector(-1224.5571289063,7023.0170898438,256), cutted = false, cutTime = nil},
{position = Vector(-1346.1818847656,7107.4228515625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1221.6573486328,7140.8188476563,256), cutted = false, cutTime = nil},
{position = Vector(-980.58666992188,7443.1489257813,256), cutted = false, cutTime = nil},
{position = Vector(-894.36389160156,7437.5502929688,256), cutted = false, cutTime = nil},
{position = Vector(-1196.8433837891,7326.8686523438,256), cutted = false, cutTime = nil},
{position = Vector(-1341.8244628906,7372.1474609375,256), cutted = false, cutTime = nil},
{position = Vector(-1352.2913818359,7126.5307617188,256), cutted = false, cutTime = nil},
{position = Vector(-1155.7963867188,7448.7709960938,256), cutted = false, cutTime = nil},
{position = Vector(-1286.8138427734,7431.9750976563,256), cutted = false, cutTime = nil},
{position = Vector(-1428.5975341797,7439.4135742188,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1538.9888916016,7321.7451171875,256), cutted = false, cutTime = nil},
{position = Vector(-1549.7969970703,7446.89453125,256), cutted = false, cutTime = nil},
{position = Vector(-1707.6561279297,7359.80078125,256), cutted = false, cutTime = nil},
{position = Vector(-1670.1142578125,7445.0205078125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1527.8736572266,6792.4956054688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1528.8201904297,6885.2719726563,256), cutted = false, cutTime = nil},
{position = Vector(-1590.6606445313,7002.8525390625,256), cutted = false, cutTime = nil},
{position = Vector(-1789.5031738281,7121.7529296875,256), cutted = false, cutTime = nil},
{position = Vector(-1778.9320068359,7327.2529296875,256), cutted = false, cutTime = nil},
{position = Vector(-1784.5681152344,7422.412109375,256), cutted = false, cutTime = nil},
{position = Vector(-1923.5981445313,7137.1108398438,256), cutted = false, cutTime = nil},
{position = Vector(-1902.3666992188,7312.93359375,256), cutted = false, cutTime = nil},
{position = Vector(-1903.6506347656,7451.7436523438,256), cutted = false, cutTime = nil},
{position = Vector(-2055.5676269531,7220.2651367188,256), cutted = false, cutTime = nil},
{position = Vector(-2054.3330078125,7334.4721679688,256), cutted = false, cutTime = nil},
{position = Vector(-2051.9956054688,7465.6513671875,256), cutted = false, cutTime = nil},
{position = Vector(-2203.1733398438,7358.2153320313,256), cutted = false, cutTime = nil},
{position = Vector(-2183.4494628906,7428.2275390625,256), cutted = false, cutTime = nil},
{position = Vector(-2175.8471679688,7174.7880859375,256), cutted = false, cutTime = nil},
{position = Vector(-2370.6960449219,7170.013671875,256), cutted = false, cutTime = nil},
{position = Vector(-2324.9404296875,7262.3256835938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2514.05078125,7171.6030273438,256), cutted = false, cutTime = nil},
{position = Vector(-2318.5007324219,7245.33203125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2491.4191894531,7276.0869140625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1717.0268554688,6934.693359375,256), cutted = false, cutTime = nil},
{position = Vector(-1649.3201904297,6825.06640625,256), cutted = false, cutTime = nil},
{position = Vector(-1903.5249023438,6858.3598632813,256), cutted = false, cutTime = nil},
{position = Vector(-1819.7852783203,6750.5693359375,256), cutted = false, cutTime = nil},
{position = Vector(-1690.1033935547,6644.794921875,256), cutted = false, cutTime = nil},
{position = Vector(-1934.4638671875,6770.8491210938,256), cutted = false, cutTime = nil},
{position = Vector(-2063.1110839844,6876.0942382813,256), cutted = false, cutTime = nil},
{position = Vector(-2096.4191894531,6793.0883789063,256), cutted = false, cutTime = nil},
{position = Vector(-2140.5158691406,6861.7583007813,256), cutted = false, cutTime = nil},
{position = Vector(-2304.251953125,6937.7651367188,256), cutted = false, cutTime = nil},
{position = Vector(-2412.1853027344,6933.158203125,256), cutted = false, cutTime = nil},
{position = Vector(-2421.6030273438,6937.7651367188,256), cutted = false, cutTime = nil},
{position = Vector(-2384.681640625,6719.365234375,256), cutted = false, cutTime = nil},
{position = Vector(-2278.2365722656,6685.4970703125,256), cutted = false, cutTime = nil},
{position = Vector(-2503.0610351563,6702.927734375,256), cutted = false, cutTime = nil},
{position = Vector(-2642.6767578125,6786.3061523438,256), cutted = false, cutTime = nil},
{position = Vector(-2625.1010742188,6801.2802734375,256), cutted = false, cutTime = nil},
{position = Vector(-2623.5649414063,6908.880859375,256), cutted = false, cutTime = nil},
{position = Vector(-2757.689453125,6868.9985351563,256), cutted = false, cutTime = nil},
{position = Vector(-2674.2966308594,7100.2900390625,256), cutted = false, cutTime = nil},
{position = Vector(-2888.8610839844,6603.2265625,256), cutted = false, cutTime = nil},
{position = Vector(-2806.5070800781,6747.970703125,256), cutted = false, cutTime = nil},
{position = Vector(-2935.1596679688,6733.7504882813,256), cutted = false, cutTime = nil},
{position = Vector(-3081.2468261719,6622.7387695313,256), cutted = false, cutTime = nil},
{position = Vector(-3213.2629394531,6596.9931640625,256), cutted = false, cutTime = nil},
{position = Vector(-3078.130859375,6836.0561523438,256), cutted = false, cutTime = nil},
{position = Vector(-3001.9072265625,6918.9497070313,256), cutted = false, cutTime = nil},
{position = Vector(-3266.2153320313,6840.275390625,256), cutted = false, cutTime = nil},
{position = Vector(-3101.34375,6926.505859375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3296.9426269531,6918.9497070313,256), cutted = false, cutTime = nil},
{position = Vector(-3454.2749023438,6932.5859375,256), cutted = false, cutTime = nil},
{position = Vector(-3483.1262207031,7042.5424804688,256), cutted = false, cutTime = nil},
{position = Vector(-3336.8149414063,7050.9028320313,256), cutted = false, cutTime = nil},
{position = Vector(-3193.5715332031,7030.9306640625,256), cutted = false, cutTime = nil},
{position = Vector(-3072.6850585938,7039.2138671875,256), cutted = false, cutTime = nil},
{position = Vector(-2942.3315429688,7049.2260742188,256), cutted = false, cutTime = nil},
{position = Vector(-2906.5500488281,7185.4970703125,256), cutted = false, cutTime = nil},
{position = Vector(-3086.2897949219,7187.0126953125,256), cutted = false, cutTime = nil},
{position = Vector(-3207.8520507813,7171.9453125,256), cutted = false, cutTime = nil},
{position = Vector(-3332.3188476563,7182.4721679688,256), cutted = false, cutTime = nil},
{position = Vector(-3450.2155761719,7196.14453125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3622.0881347656,7133.64453125,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-2880.3171386719,7318.1591796875,256), cutted = false, cutTime = nil},
{position = Vector(-2753.4765625,7321.5380859375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3006.8669433594,7311.4296875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3141.3198242188,7304.7353515625,256), cutted = false, cutTime = nil},
{position = Vector(-3262.11328125,7313.1083984375,256), cutted = false, cutTime = nil},
{position = Vector(-3393.6389160156,7373.3232421875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3544.0043945313,7247.1982421875,256), cutted = false, cutTime = nil},
{position = Vector(-2982.0954589844,7453.9833984375,256), cutted = false, cutTime = nil},
{position = Vector(-3319.0185546875,7486.8579101563,256), cutted = false, cutTime = nil},
{position = Vector(-3427.0041503906,7528.568359375,256), cutted = false, cutTime = nil},
{position = Vector(-3426.2219238281,7544.7885742188,256), cutted = false, cutTime = nil},
{position = Vector(-3705.3774414063,7435.0053710938,256), cutted = false, cutTime = nil},
{position = Vector(-3629.3125,7534.62890625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3765.8630371094,7496.6772460938,256), cutted = false, cutTime = nil},
{position = Vector(-3756.9089355469,7528.568359375,256), cutted = false, cutTime = nil},
{position = Vector(-3891.890625,7516.5239257813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-3770.0710449219,7152.7602539063,256), cutted = false, cutTime = nil},
{position = Vector(-3979.8793945313,7297.19921875,256), cutted = false, cutTime = nil},
{position = Vector(-4022.8603515625,7388.6865234375,256), cutted = false, cutTime = nil},
{position = Vector(-4032.9047851563,7516.5239257813,256), cutted = false, cutTime = nil},
{position = Vector(-4143.8969726563,7520.52734375,256), cutted = false, cutTime = nil},
{position = Vector(-4146.4560546875,7372.3930664063,256), cutted = false, cutTime = nil},
{position = Vector(-4290.4658203125,7425.6142578125,256), cutted = false, cutTime = nil},
{position = Vector(-4370.2685546875,7276.9653320313,256), cutted = false, cutTime = nil},
{position = Vector(-4300.3579101563,7401.4965820313,256), cutted = false, cutTime = nil},
{position = Vector(-4438.66796875,7473.2265625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4573.2866210938,7536.6547851563,256), cutted = false, cutTime = nil},
{position = Vector(-4493.9072265625,7326.4155273438,256), cutted = false, cutTime = nil},
{position = Vector(-4163.8588867188,7092.158203125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4186.376953125,7087.8413085938,256), cutted = false, cutTime = nil},
{position = Vector(-4092.6638183594,7183.451171875,256), cutted = false, cutTime = nil},
{position = Vector(-3896.1833496094,7048.2900390625,256), cutted = false, cutTime = nil},
{position = Vector(-3922.4978027344,7163.4150390625,256), cutted = false, cutTime = nil},
{position = Vector(-3760.3010253906,7001.9912109375,256), cutted = false, cutTime = nil},
{position = Vector(-3716.7712402344,6866.763671875,256), cutted = false, cutTime = nil},
{position = Vector(-3837.4763183594,6862.6533203125,256), cutted = false, cutTime = nil},
{position = Vector(-3954.6896972656,6877.796875,256), cutted = false, cutTime = nil},
{position = Vector(-4077.0107421875,6875.0288085938,256), cutted = false, cutTime = nil},
{position = Vector(-4295.556640625,6911.5322265625,256), cutted = false, cutTime = nil},
{position = Vector(-4181.8198242188,6766.9140625,256), cutted = false, cutTime = nil},
{position = Vector(-4033.9155273438,6729.8159179688,256), cutted = false, cutTime = nil},
{position = Vector(-3899.0676269531,6728.6010742188,256), cutted = false, cutTime = nil},
{position = Vector(-3782.8999023438,6690.4091796875,256), cutted = false, cutTime = nil},
{position = Vector(-3640.1311035156,6722.5444335938,256), cutted = false, cutTime = nil},
{position = Vector(-3511.564453125,6733.4702148438,256), cutted = false, cutTime = nil},
{position = Vector(-3858.3806152344,6565.6665039063,256), cutted = false, cutTime = nil},
{position = Vector(-4101.5346679688,6553.9340820313,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-3724.53515625,6548.1108398438,256), cutted = false, cutTime = nil},
{position = Vector(-3601.8518066406,6598.537109375,256), cutted = false, cutTime = nil},
{position = Vector(-3465.2602539063,6629.216796875,256), cutted = false, cutTime = nil},
{position = Vector(-3316.1611328125,6561.2529296875,256), cutted = false, cutTime = nil},
{position = Vector(-4311.2763671875,6651.2216796875,256), cutted = false, cutTime = nil},
{position = Vector(-4461.6640625,6629.5756835938,256), cutted = false, cutTime = nil},
{position = Vector(-4596.1420898438,6687.10546875,256), cutted = false, cutTime = nil},
{position = Vector(-4412.0029296875,6828.2045898438,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4504.6137695313,6824.7373046875,256), cutted = false, cutTime = nil},
{position = Vector(-4642.9370117188,6809.25,256), cutted = false, cutTime = nil},
{position = Vector(-4801.3310546875,6812.6752929688,256), cutted = false, cutTime = nil},
{position = Vector(-4924.2993164063,6799.0283203125,256), cutted = false, cutTime = nil},
{position = Vector(-4941.8120117188,6826.4697265625,256), cutted = false, cutTime = nil},
{position = Vector(-4829.796875,6590.3266601563,256), cutted = false, cutTime = nil},
{position = Vector(-4379.6616210938,6923.6235351563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4608.345703125,6996.2260742188,256), cutted = false, cutTime = nil},
{position = Vector(-4609.1069335938,7105.2377929688,256), cutted = false, cutTime = nil},
{position = Vector(-4801.353515625,7063.2412109375,256), cutted = false, cutTime = nil},
{position = Vector(-4792.6010742188,7219.8955078125,256), cutted = false, cutTime = nil},
{position = Vector(-4746.2631835938,7333.4477539063,256), cutted = false, cutTime = nil},
{position = Vector(-4791.1000976563,7503.7099609375,256), cutted = false, cutTime = nil},
{position = Vector(-4260.7778320313,7513.3247070313,256), cutted = false, cutTime = nil},
{position = Vector(-4843.8935546875,7302,256), cutted = false, cutTime = nil},
{position = Vector(-5000.4194335938,7333.447265625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4988.7426757813,7517.1904296875,256), cutted = false, cutTime = nil},
{position = Vector(-5095.0327148438,7017.6801757813,256), cutted = false, cutTime = nil},
{position = Vector(-5278.13671875,7249.2451171875,256), cutted = false, cutTime = nil},
{position = Vector(-5199.1015625,7390.0419921875,256), cutted = false, cutTime = nil},
{position = Vector(-5170.416015625,6967.5063476563,256), cutted = false, cutTime = nil},
{position = Vector(-5152.623046875,7073.4926757813,256), cutted = false, cutTime = nil},
{position = Vector(-5318.7348632813,7011.3369140625,256), cutted = false, cutTime = nil},
{position = Vector(-5378.0922851563,7136.25390625,256), cutted = false, cutTime = nil},
{position = Vector(-5380.8569335938,7254.7158203125,256), cutted = false, cutTime = nil},
{position = Vector(-5309.6450195313,7434.87890625,256), cutted = false, cutTime = nil},
{position = Vector(-5308.5278320313,7513.2861328125,256), cutted = false, cutTime = nil},
{position = Vector(-5501.810546875,7553.994140625,259.98779296875), cutted = false, cutTime = nil},
{position = Vector(-5581.0791015625,7348.58984375,256), cutted = false, cutTime = nil},
{position = Vector(-5738.0400390625,7557.0390625,266.07800292969), cutted = false, cutTime = nil},
{position = Vector(-5715.9399414063,7557.0390625,266.07788085938), cutted = false, cutTime = nil},
{position = Vector(-5852.4526367188,7466.83984375,256), cutted = false, cutTime = nil},
{position = Vector(-5961.3857421875,7523.1650390625,256), cutted = false, cutTime = nil},
{position = Vector(-5981.20703125,7423.7788085938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6159.1684570313,7455.4248046875,256), cutted = false, cutTime = nil},
{position = Vector(-6300.3334960938,7451.6206054688,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6277.5327148438,7290.7309570313,256), cutted = false, cutTime = nil},
{position = Vector(-6153.8823242188,7260.8022460938,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6179.67578125,7292.4145507813,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6017.6743164063,7246.09765625,256), cutted = false, cutTime = nil},
{position = Vector(-5907.1860351563,7175.0576171875,256), cutted = false, cutTime = nil},
{position = Vector(-5894.2700195313,7187.3935546875,256), cutted = false, cutTime = nil},
{position = Vector(-6130.4047851563,7092.046875,256), cutted = false, cutTime = nil},
{position = Vector(-6023.4243164063,7026.5927734375,256), cutted = false, cutTime = nil},
{position = Vector(-5742.9077148438,7065.1440429688,256), cutted = false, cutTime = nil},
{position = Vector(-5850.6147460938,6965.9389648438,256), cutted = false, cutTime = nil},
{position = Vector(-5751.8452148438,6943.064453125,256), cutted = false, cutTime = nil},
{position = Vector(-5548.0634765625,7016.3002929688,256), cutted = false, cutTime = nil},
{position = Vector(-5461.087890625,6939.68359375,256), cutted = false, cutTime = nil},
{position = Vector(-5441.4799804688,7008.2680664063,256), cutted = false, cutTime = nil},
{position = Vector(-5361.1552734375,6889.3828125,256), cutted = false, cutTime = nil},
{position = Vector(-5648.7158203125,6844.7553710938,256), cutted = false, cutTime = nil},
{position = Vector(-5722.8305664063,6800.2309570313,256), cutted = false, cutTime = nil},
{position = Vector(-5633.1333007813,6612.1752929688,256), cutted = false, cutTime = nil},
{position = Vector(-5691.3662109375,6496.0571289063,256), cutted = false, cutTime = nil},
{position = Vector(-5509.4477539063,6607.8247070313,256), cutted = false, cutTime = nil},
{position = Vector(-5570.3095703125,6731.1376953125,256), cutted = false, cutTime = nil},
{position = Vector(-5427.119140625,6716.810546875,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-5361.8408203125,6615.0844726563,256), cutted = false, cutTime = nil},
{position = Vector(-5302.3896484375,6735.9501953125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-5257.5473632813,6619.4619140625,256), cutted = false, cutTime = nil},
{position = Vector(-5130.177734375,6766.861328125,256), cutted = false, cutTime = nil},
{position = Vector(-5119.0952148438,6628.2646484375,256), cutted = false, cutTime = nil},
{position = Vector(-4990.8081054688,6727.9399414063,256), cutted = false, cutTime = nil},
{position = Vector(-4920.669921875,6590.5786132813,256), cutted = false, cutTime = nil},
{position = Vector(-5892.2172851563,6693.2924804688,256), cutted = false, cutTime = nil},
{position = Vector(-6002.5249023438,6668.6899414063,256), cutted = false, cutTime = nil},
{position = Vector(-6020.1313476563,6824.1147460938,256), cutted = false, cutTime = nil},
{position = Vector(-6196.978515625,6677.8583984375,256), cutted = false, cutTime = nil},
{position = Vector(-6154.52734375,6807.009765625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6251.7104492188,6977.2504882813,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6367.63671875,7030.3720703125,256), cutted = false, cutTime = nil},
{position = Vector(-6336.7543945313,6860.78125,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6428.7817382813,6702.646484375,256), cutted = false, cutTime = nil},
{position = Vector(-6382.7065429688,6761.9301757813,256), cutted = false, cutTime = nil},
{position = Vector(-6219.6865234375,6556.8237304688,256), cutted = false, cutTime = nil},
{position = Vector(-6212.1767578125,6453.271484375,256), cutted = false, cutTime = nil},
{position = Vector(-6014.7309570313,6428.8647460938,256), cutted = false, cutTime = nil},
{position = Vector(-5996.2299804688,6414.4521484375,256), cutted = false, cutTime = nil},
{position = Vector(-5949.7045898438,6515.6201171875,256), cutted = false, cutTime = nil},
{position = Vector(-6267.9096679688,6338.8823242188,256), cutted = false, cutTime = nil},
{position = Vector(-6354.4194335938,6469.4809570313,256), cutted = false, cutTime = nil},
{position = Vector(-6466.158203125,6527.7153320313,256), cutted = false, cutTime = nil},
{position = Vector(-6484.8071289063,6663.4389648438,256), cutted = false, cutTime = nil},
{position = Vector(-6455.9174804688,6910.1059570313,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6557.642578125,6765.0405273438,256), cutted = false, cutTime = nil},
{position = Vector(-6662.5932617188,6720.7045898438,256), cutted = false, cutTime = nil},
{position = Vector(-6661.611328125,6841.9731445313,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6665.8432617188,6563.8569335938,256), cutted = false, cutTime = nil},
{position = Vector(-6663.994140625,6559.458984375,256), cutted = false, cutTime = nil},
{position = Vector(-6769.4135742188,6677.9086914063,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(-6777.9487304688,6679.52734375,255.99975585938), cutted = false, cutTime = nil},
{position = Vector(-6917.439453125,6566.7978515625,256), cutted = false, cutTime = nil},
{position = Vector(-6929.703125,6574.18359375,256), cutted = false, cutTime = nil},
{position = Vector(-6549.4829101563,6296.3813476563,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-6915.1484375,6432.1391601563,256), cutted = false, cutTime = nil},
{position = Vector(-7010.59765625,6380.236328125,256), cutted = false, cutTime = nil},
{position = Vector(-6856.3969726563,6296.1762695313,256), cutted = false, cutTime = nil},
{position = Vector(-6690.1611328125,6287.0390625,256), cutted = false, cutTime = nil},
{position = Vector(-6503.23828125,6189.056640625,256), cutted = false, cutTime = nil},
{position = Vector(-6681.3466796875,6202.5073242188,256), cutted = false, cutTime = nil},
{position = Vector(-6641.873046875,6203.861328125,256), cutted = false, cutTime = nil},
{position = Vector(-6801.298828125,6181.0639648438,256), cutted = false, cutTime = nil},
{position = Vector(-6934.943359375,6232.6791992188,256), cutted = false, cutTime = nil},
{position = Vector(-7052.8940429688,6236.8569335938,256), cutted = false, cutTime = nil},
{position = Vector(-7200.9584960938,6182.392578125,256), cutted = false, cutTime = nil},
{position = Vector(-7068.4033203125,6135.5625,256), cutted = false, cutTime = nil},
{position = Vector(-7144.2163085938,6072.5126953125,256), cutted = false, cutTime = nil},
{position = Vector(-6973.85546875,5979.5810546875,256), cutted = false, cutTime = nil},
{position = Vector(-6810.5170898438,5942.9736328125,256), cutted = false, cutTime = nil},
{position = Vector(-6688.2744140625,5914.8388671875,256), cutted = false, cutTime = nil},
{position = Vector(-7192.548828125,5964.0263671875,256), cutted = false, cutTime = nil},
{position = Vector(-7144.1977539063,5817.0776367188,256), cutted = false, cutTime = nil},
{position = Vector(-7231.8198242188,5797.4526367188,256), cutted = false, cutTime = nil},
{position = Vector(-7014.9028320313,5792.96875,256), cutted = false, cutTime = nil},
{position = Vector(-6864.3481445313,5795.9560546875,256), cutted = false, cutTime = nil},
{position = Vector(-6910.263671875,5669.8862304688,256), cutted = false, cutTime = nil},
{position = Vector(-7187.5268554688,6065.5625,256), cutted = false, cutTime = nil},
{position = Vector(-7239.0551757813,5665.8681640625,256), cutted = false, cutTime = nil},
{position = Vector(-7031.3374023438,5669.8862304688,256), cutted = false, cutTime = nil},
{position = Vector(-6808.7451171875,5675.2661132813,256), cutted = false, cutTime = nil},
{position = Vector(-6603.4624023438,5675.2661132813,256), cutted = false, cutTime = nil},
{position = Vector(-7064.8271484375,5499.4780273438,256), cutted = false, cutTime = nil},
{position = Vector(-6964.126953125,5421.8793945313,256), cutted = false, cutTime = nil},
{position = Vector(-7036.828125,5553.6791992188,256), cutted = false, cutTime = nil},
{position = Vector(-7152.7553710938,5536.3784179688,256), cutted = false, cutTime = nil},
{position = Vector(-6843.6440429688,5539.5053710938,256), cutted = false, cutTime = nil},
{position = Vector(-6826.2763671875,5421.8793945313,256), cutted = false, cutTime = nil},
{position = Vector(-6701.0180664063,5338.6489257813,256), cutted = false, cutTime = nil},
{position = Vector(-6672.4892578125,5423.2963867188,256), cutted = false, cutTime = nil},
{position = Vector(-6781.48828125,5446.2080078125,256), cutted = false, cutTime = nil},
{position = Vector(-6586.0063476563,5536.3784179688,256), cutted = false, cutTime = nil},
{position = Vector(-6473.8383789063,5484.4360351563,256), cutted = false, cutTime = nil},
{position = Vector(-6995.5361328125,5214.5864257813,256), cutted = false, cutTime = nil},
{position = Vector(-7147.8754882813,5180.0493164063,256), cutted = false, cutTime = nil},
{position = Vector(-7091.5766601563,5114.7055664063,256), cutted = false, cutTime = nil},
{position = Vector(-6933.7622070313,5043.7543945313,256), cutted = false, cutTime = nil},
{position = Vector(-6912.4467773438,5058.9912109375,256), cutted = false, cutTime = nil},
{position = Vector(-6757.3920898438,5054.8159179688,256), cutted = false, cutTime = nil},
{position = Vector(-6474.115234375,5073.0224609375,256), cutted = false, cutTime = nil},
{position = Vector(-6767.6025390625,5082.947265625,256), cutted = false, cutTime = nil},
{position = Vector(-7247.099609375,4964.0986328125,256), cutted = false, cutTime = nil},
{position = Vector(-7077.482421875,5285.9033203125,256), cutted = false, cutTime = nil},
{position = Vector(-7196.9604492188,5428.4169921875,256), cutted = false, cutTime = nil},
{position = Vector(-6717.7763671875,4903.6704101563,256), cutted = false, cutTime = nil},
{position = Vector(-6703.9145507813,5000.6987304688,256), cutted = false, cutTime = nil},
{position = Vector(-6898.7358398438,4838.6459960938,256), cutted = false, cutTime = nil},
{position = Vector(-7130.333984375,4784.0463867188,256), cutted = false, cutTime = nil},
{position = Vector(-7250.6235351563,4763.1904296875,256), cutted = false, cutTime = nil},
{position = Vector(-6701.1782226563,4546.572265625,256), cutted = false, cutTime = nil},
{position = Vector(-6885.6943359375,4381.5952148438,256), cutted = false, cutTime = nil},
{position = Vector(-6792.9077148438,4256.744140625,256), cutted = false, cutTime = nil},
{position = Vector(-6664.1337890625,4284.1958007813,256), cutted = false, cutTime = nil},
{position = Vector(-6588.8984375,4492.767578125,256), cutted = false, cutTime = nil},
{position = Vector(-6718.0908203125,4541.94921875,256), cutted = false, cutTime = nil},
{position = Vector(-7277.3598632813,4138.0317382813,256), cutted = false, cutTime = nil},
{position = Vector(-7369.7041015625,4194.806640625,256), cutted = false, cutTime = nil},
{position = Vector(-7234.7163085938,4185.447265625,256), cutted = false, cutTime = nil},
{position = Vector(-7101.4545898438,4188.5590820313,256), cutted = false, cutTime = nil},
{position = Vector(-7092.9326171875,4194.806640625,256), cutted = false, cutTime = nil},
{position = Vector(-6920.3803710938,4034.0966796875,256), cutted = false, cutTime = nil},
{position = Vector(-7224.7280273438,3928.8950195313,256), cutted = false, cutTime = nil},
{position = Vector(-7039.45703125,3887.6313476563,256), cutted = false, cutTime = nil},
{position = Vector(-7071.4521484375,3936.3469238281,256), cutted = false, cutTime = nil},
{position = Vector(-6821.8173828125,3875.8623046875,255.75048828125), cutted = false, cutTime = nil},
{position = Vector(-7284.93359375,3814.091796875,255.26440429688), cutted = false, cutTime = nil},
{position = Vector(-7156.8286132813,3806.5314941406,255.50708007813), cutted = false, cutTime = nil},
{position = Vector(-7278.263671875,3811.1811523438,255.13122558594), cutted = false, cutTime = nil},
{position = Vector(-7457.7182617188,3693.5512695313,256), cutted = false, cutTime = nil},
{position = Vector(-7427.4184570313,3942.7353515625,256), cutted = false, cutTime = nil},
{position = Vector(-7072.83984375,3692.2114257813,256), cutted = false, cutTime = nil},
{position = Vector(-6842.4135742188,3744.2333984375,253.03771972656), cutted = false, cutTime = nil},
{position = Vector(-6733.6025390625,3794.5361328125,255.90563964844), cutted = false, cutTime = nil},
{position = Vector(-6755.2514648438,3594.9541015625,256), cutted = false, cutTime = nil},
{position = Vector(-6916.412109375,3598.6301269531,256), cutted = false, cutTime = nil},
{position = Vector(-7077.8486328125,3511.5517578125,256), cutted = false, cutTime = nil},
{position = Vector(-7264.3188476563,3518.3432617188,256), cutted = false, cutTime = nil},
{position = Vector(-7397.68359375,3470.6560058594,256), cutted = false, cutTime = nil},
{position = Vector(-7252.6625976563,3460.6354980469,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-7017.30859375,3322.8000488281,256), cutted = false, cutTime = nil},
{position = Vector(-6856.6899414063,3339.5947265625,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-6905.8989257813,3456.2849121094,256), cutted = false, cutTime = nil},
{position = Vector(-6801.69921875,3482.6418457031,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5730.7866210938,3489.1342773438,255.83056640625), cutted = false, cutTime = nil},
{position = Vector(-5728.7646484375,3454.9514160156,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5582.8447265625,3499.9345703125,256), cutted = false, cutTime = nil},
{position = Vector(-5432.4594726563,3517.2370605469,256.09643554688), cutted = false, cutTime = nil},
{position = Vector(-5576.9165039063,3838,256), cutted = false, cutTime = nil},
{position = Vector(-5731.4248046875,3884.6457519531,256), cutted = false, cutTime = nil},
{position = Vector(-5897.9052734375,3967.1323242188,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-6030.15234375,4038.6865234375,256), cutted = false, cutTime = nil},
{position = Vector(-5657.0903320313,4174.7124023438,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5451.7084960938,4098.6049804688,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5349.4223632813,3991.1530761719,256), cutted = false, cutTime = nil},
{position = Vector(-5285.9296875,4136.0561523438,256), cutted = false, cutTime = nil},
{position = Vector(-5515.5571289063,4225.7939453125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5669.751953125,4246.8427734375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-5768.1000976563,4311.2055664063,256), cutted = false, cutTime = nil},
{position = Vector(-5708.7236328125,4428.7314453125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-5808.8627929688,4374.8227539063,256), cutted = false, cutTime = nil},
{position = Vector(-5692.775390625,4579.1455078125,256), cutted = false, cutTime = nil},
{position = Vector(-5806.462890625,4677.0546875,256), cutted = false, cutTime = nil},
{position = Vector(-5308.3330078125,4776.3872070313,256), cutted = false, cutTime = nil},
{position = Vector(-5360.4658203125,4879.0170898438,256), cutted = false, cutTime = nil},
{position = Vector(-5429.0083007813,5006.0366210938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5565.4204101563,5026.4614257813,256), cutted = false, cutTime = nil},
{position = Vector(-5315.7631835938,5051.2421875,256), cutted = false, cutTime = nil},
{position = Vector(-5358.9243164063,5120.7392578125,256), cutted = false, cutTime = nil},
{position = Vector(-5486.626953125,5119.3330078125,256), cutted = false, cutTime = nil},
{position = Vector(-5220.3017578125,5159.4013671875,256), cutted = false, cutTime = nil},
{position = Vector(-5309.7504882813,5261.4814453125,256), cutted = false, cutTime = nil},
{position = Vector(-5179.1616210938,4990.9765625,256), cutted = false, cutTime = nil},
{position = Vector(-5127.6630859375,4956.6684570313,256), cutted = false, cutTime = nil},
{position = Vector(-5132.3325195313,5012.3764648438,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-5036.5727539063,4995.9721679688,256), cutted = false, cutTime = nil},
{position = Vector(-5071.37109375,5130.6337890625,256), cutted = false, cutTime = nil},
{position = Vector(-4889.5991210938,5084.751953125,256), cutted = false, cutTime = nil},
{position = Vector(-4912.9423828125,5223.8618164063,256), cutted = false, cutTime = nil},
{position = Vector(-4806.9638671875,5318.6025390625,256), cutted = false, cutTime = nil},
{position = Vector(-4727.6489257813,5315.2631835938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4692.8510742188,5210.064453125,256), cutted = false, cutTime = nil},
{position = Vector(-4734.4013671875,5056.5336914063,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-5226.2631835938,4763.3969726563,256), cutted = false, cutTime = nil},
{position = Vector(-4995.1274414063,4784.0830078125,256), cutted = false, cutTime = nil},
{position = Vector(-5000.4501953125,4650.7158203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-4932.9448242188,4908.4770507813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-4862.3500976563,4712.1850585938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-4799.5717773438,4976.3081054688,256), cutted = false, cutTime = nil},
{position = Vector(-4731.9296875,4813.201171875,256), cutted = false, cutTime = nil},
{position = Vector(-4612.369140625,4956.294921875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4548.9887695313,4801.1928710938,256), cutted = false, cutTime = nil},
{position = Vector(-4516.2524414063,4834.884765625,256), cutted = false, cutTime = nil},
{position = Vector(-4616.1440429688,5068.341796875,256), cutted = false, cutTime = nil},
{position = Vector(-4451.6176757813,5098.9453125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4537.0810546875,5294.224609375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4432.794921875,5451.7763671875,256), cutted = false, cutTime = nil},
{position = Vector(-4363.4116210938,5264.4331054688,256), cutted = false, cutTime = nil},
{position = Vector(-4321.7934570313,5073.3891601563,256), cutted = false, cutTime = nil},
{position = Vector(-4330.3452148438,5095.5068359375,256), cutted = false, cutTime = nil},
{position = Vector(-4380.9658203125,4776.2783203125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-4186.4653320313,4895.3852539063,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-4174.890625,4998.2543945313,256), cutted = false, cutTime = nil},
{position = Vector(-4103.3637695313,4993.5166015625,256), cutted = false, cutTime = nil},
{position = Vector(-4233.8452148438,5093.791015625,256), cutted = false, cutTime = nil},
{position = Vector(-4215.5576171875,5197.474609375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4098.0341796875,5158.9282226563,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-3913.9438476563,5171.6459960938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4170.6259765625,5348.5561523438,256), cutted = false, cutTime = nil},
{position = Vector(-4036.6865234375,5378.1982421875,256), cutted = false, cutTime = nil},
{position = Vector(-4088.6154785156,5514.67578125,256), cutted = false, cutTime = nil},
{position = Vector(-3974.0236816406,5528.6484375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-3886.4653320313,5428.5146484375,256), cutted = false, cutTime = nil},
{position = Vector(-3809.15625,5568.3647460938,256), cutted = false, cutTime = nil},
{position = Vector(-3682.8249511719,5531.7768554688,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-3690.3129882813,5534.9130859375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-3652.6394042969,5412.89453125,256), cutted = false, cutTime = nil},
{position = Vector(-4303.9306640625,4696.578125,256), cutted = false, cutTime = nil},
{position = Vector(-3002.3630371094,5581.51953125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-2976.5886230469,5560.02734375,256), cutted = false, cutTime = nil},
{position = Vector(-3003.4599609375,5660.9252929688,256), cutted = false, cutTime = nil},
{position = Vector(-2867.8264160156,5654.736328125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-2986.60546875,5370.5795898438,256), cutted = false, cutTime = nil},
{position = Vector(-2827.951171875,5314.0654296875,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-2885.3950195313,5414.2143554688,256), cutted = false, cutTime = nil},
{position = Vector(-2873.0346679688,5674.9731445313,256), cutted = false, cutTime = nil},
{position = Vector(-2755.6787109375,5639.4072265625,256), cutted = false, cutTime = nil},
{position = Vector(-2728.88671875,5650.1157226563,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-2621.7314453125,5647.0458984375,256), cutted = false, cutTime = nil},
{position = Vector(-2715.1821289063,5454.6118164063,256), cutted = false, cutTime = nil},
{position = Vector(-2683.0336914063,5253.2236328125,256), cutted = false, cutTime = nil},
{position = Vector(-2605.8068847656,5401.9057617188,256), cutted = false, cutTime = nil},
{position = Vector(-2560.9497070313,5525.1098632813,256), cutted = false, cutTime = nil},
{position = Vector(-2402.5573730469,5523.736328125,256), cutted = false, cutTime = nil},
{position = Vector(-2436.6115722656,5347.1245117188,256), cutted = false, cutTime = nil},
{position = Vector(-2422.6494140625,5378.9189453125,256), cutted = false, cutTime = nil},
{position = Vector(-2320.091796875,5536.1630859375,256), cutted = false, cutTime = nil},
{position = Vector(-2318.5520019531,5344.8090820313,256), cutted = false, cutTime = nil},
{position = Vector(-2460.9216308594,5270.2197265625,256), cutted = false, cutTime = nil},
{position = Vector(-2171.5888671875,5271.6845703125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-2016.4322509766,5604.7880859375,256), cutted = false, cutTime = nil},
{position = Vector(-1981.7551269531,5322.4243164063,256), cutted = false, cutTime = nil},
{position = Vector(-1920.3333740234,5215.2578125,256), cutted = false, cutTime = nil},
{position = Vector(-1870.1096191406,5538.6806640625,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-1859.1058349609,5643.94921875,256), cutted = false, cutTime = nil},
{position = Vector(-1726.2258300781,5467.158203125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-1667.6950683594,5593.0063476563,256), cutted = false, cutTime = nil},
{position = Vector(-1494.5493164063,5665.6040039063,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-1374.9790039063,5659.375,256), cutted = false, cutTime = nil},
{position = Vector(-1453.6020507813,5697.2578125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-1369.6259765625,5668.7309570313,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-1540.9798583984,5350.0004882813,256), cutted = false, cutTime = nil},
{position = Vector(-1555.6672363281,5158.71875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-1419.2451171875,5257.1274414063,256), cutted = false, cutTime = nil},
{position = Vector(-1556.8123779297,5303.6528320313,256), cutted = false, cutTime = nil},
{position = Vector(-1374.3771972656,5398.447265625,256), cutted = false, cutTime = nil},
{position = Vector(-1315.9803466797,5561.4091796875,256), cutted = false, cutTime = nil},
{position = Vector(-1307.4821777344,5437.3725585938,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-1159.2015380859,5482.2885742188,256), cutted = false, cutTime = nil},
{position = Vector(-1214.9249267578,5589.9692382813,256), cutted = false, cutTime = nil},
{position = Vector(-1103.1378173828,5598.935546875,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-1131.1553955078,5659.7744140625,256), cutted = false, cutTime = nil},
{position = Vector(-959.85919189453,5657.8876953125,256), cutted = false, cutTime = nil},
{position = Vector(-1115.2803955078,5243.9892578125,256), cutted = false, cutTime = nil},
{position = Vector(-1216.1376953125,5278.9594726563,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-931.60552978516,5373.0966796875,256), cutted = false, cutTime = nil},
{position = Vector(-876.60211181641,5507.0708007813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-841.75122070313,5602.5400390625,256), cutted = false, cutTime = nil},
{position = Vector(-378.85125732422,5215.3276367188,256), cutted = false, cutTime = nil},
{position = Vector(-273.49380493164,5095.1142578125,256), cutted = false, cutTime = nil},
{position = Vector(-232.5638885498,5193.7114257813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-338.32293701172,5306.7993164063,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-113.75396728516,5447.0458984375,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-92.567260742188,5479.224609375,256), cutted = false, cutTime = nil},
{position = Vector(-45.346282958984,5319.4951171875,256), cutted = false, cutTime = nil},
{position = Vector(-38.328033447266,5355.54296875,256), cutted = false, cutTime = nil},
{position = Vector(66.607879638672,5313.8344726563,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(74.556365966797,5340.9838867188,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(188.98690795898,5250.759765625,256), cutted = false, cutTime = nil},
{position = Vector(-42.265350341797,5102.01171875,256), cutted = false, cutTime = nil},
{position = Vector(-65.08943939209,4946.7270507813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(55.218933105469,4875.2875976563,256), cutted = false, cutTime = nil},
{position = Vector(-308.78991699219,4860.056640625,256), cutted = false, cutTime = nil},
{position = Vector(218.79699707031,4870.185546875,256), cutted = false, cutTime = nil},
{position = Vector(273.40777587891,5005.6303710938,256), cutted = false, cutTime = nil},
{position = Vector(1190.4722900391,5094.84375,256), cutted = false, cutTime = nil},
{position = Vector(1305.271484375,5077.498046875,256), cutted = false, cutTime = nil},
{position = Vector(1647.9195556641,5048.458984375,128), cutted = false, cutTime = nil},
{position = Vector(1594.2918701172,4935.3349609375,128), cutted = false, cutTime = nil},
{position = Vector(1907.2092285156,4703.3720703125,128), cutted = false, cutTime = nil},
{position = Vector(2422.6467285156,5137.283203125,128), cutted = false, cutTime = nil},
{position = Vector(2317.2290039063,5245.2719726563,128), cutted = false, cutTime = nil},
{position = Vector(2754.9113769531,4542.828125,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(2878.4626464844,4502.4389648438,141.86926269531), cutted = false, cutTime = nil},
{position = Vector(2808.0290527344,3343.3627929688,128), cutted = false, cutTime = nil},
{position = Vector(2663.7592773438,3357.9853515625,128), cutted = false, cutTime = nil},
{position = Vector(2676.0942382813,3418.5070800781,128), cutted = false, cutTime = nil},
{position = Vector(2570.7067871094,3514.3286132813,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2330.0466308594,3512.7922363281,128), cutted = false, cutTime = nil},
{position = Vector(2316.9973144531,3617.0390625,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2312.8295898438,3610.3557128906,128), cutted = false, cutTime = nil},
{position = Vector(1828.8916015625,3930.9709472656,128), cutted = false, cutTime = nil},
{position = Vector(2300.6293945313,3044.6635742188,128), cutted = false, cutTime = nil},
{position = Vector(2444.8310546875,2859.5419921875,128), cutted = false, cutTime = nil},
{position = Vector(2168.1015625,2878.521484375,128), cutted = false, cutTime = nil},
{position = Vector(1959.2713623047,2895.0534667969,128), cutted = false, cutTime = nil},
{position = Vector(2288.0046386719,2836.9294433594,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2430.1237792969,2775.5317382813,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(2552.7905273438,2810.9172363281,128), cutted = false, cutTime = nil},
{position = Vector(2424.33203125,2873.0651855469,128), cutted = false, cutTime = nil},
{position = Vector(2370.8759765625,2639.5083007813,128), cutted = false, cutTime = nil},
{position = Vector(2207.7282714844,2543.4321289063,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(2036.0461425781,2532.6433105469,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2028.6733398438,2534.4350585938,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2188.5122070313,2583.7934570313,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(1835.9305419922,2441.1938476563,128), cutted = false, cutTime = nil},
{position = Vector(1806.5533447266,2469.794921875,128), cutted = false, cutTime = nil},
{position = Vector(1748.8332519531,2115.7604980469,128), cutted = false, cutTime = nil},
{position = Vector(1114.4099121094,1760.9777832031,132.12652587891), cutted = false, cutTime = nil},
{position = Vector(1218.5593261719,1561.4754638672,128), cutted = false, cutTime = nil},
{position = Vector(1079.3676757813,1560.2672119141,128), cutted = false, cutTime = nil},
{position = Vector(897.10784912109,1709.1103515625,128), cutted = false, cutTime = nil},
{position = Vector(891.03002929688,1744.3432617188,128), cutted = false, cutTime = nil},
{position = Vector(842.80883789063,1630.1701660156,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(1244.4556884766,1433.3154296875,128), cutted = false, cutTime = nil},
{position = Vector(1142.3382568359,1365.0402832031,128), cutted = false, cutTime = nil},
{position = Vector(1009.8318481445,1381.7208251953,128), cutted = false, cutTime = nil},
{position = Vector(1132.2757568359,1189.6525878906,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(1001.5952758789,1169.9416503906,128), cutted = false, cutTime = nil},
{position = Vector(835.72595214844,1327.0678710938,128), cutted = false, cutTime = nil},
{position = Vector(901.94342041016,1161.9353027344,128), cutted = false, cutTime = nil},
{position = Vector(999.15185546875,1042.9228515625,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(672.19659423828,1311.1879882813,128), cutted = false, cutTime = nil},
{position = Vector(688.84411621094,1302.0307617188,128), cutted = false, cutTime = nil},
{position = Vector(619.66223144531,1427.4506835938,128), cutted = false, cutTime = nil},
{position = Vector(616.18109130859,1550.3786621094,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(757.50347900391,1445.0842285156,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(891.17492675781,1420.1828613281,128), cutted = false, cutTime = nil},
{position = Vector(951.56030273438,1087.2424316406,128), cutted = false, cutTime = nil},
{position = Vector(943.73693847656,1087.2425537109,128), cutted = false, cutTime = nil},
{position = Vector(678.82568359375,910.55987548828,128), cutted = false, cutTime = nil},
{position = Vector(714.06451416016,1058.1624755859,128), cutted = false, cutTime = nil},
{position = Vector(667.93029785156,1198.4239501953,128), cutted = false, cutTime = nil},
{position = Vector(576.69494628906,1315.595703125,128), cutted = false, cutTime = nil},
{position = Vector(365.98846435547,1346.2409667969,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(434.59649658203,1536.8623046875,129.72412109375), cutted = false, cutTime = nil},
{position = Vector(295.93829345703,1519.6767578125,128), cutted = false, cutTime = nil},
{position = Vector(234.75280761719,1434.9816894531,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(369.93566894531,1155.4885253906,128), cutted = false, cutTime = nil},
{position = Vector(495.82833862305,1132.2923583984,128), cutted = false, cutTime = nil},
{position = Vector(548.56860351563,976.52319335938,128), cutted = false, cutTime = nil},
{position = Vector(511.22241210938,861.55285644531,128), cutted = false, cutTime = nil},
{position = Vector(362.51913452148,877.22900390625,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(767.67352294922,923.17736816406,128), cutted = false, cutTime = nil},
{position = Vector(167.58242797852,1529.7346191406,134.90295410156), cutted = false, cutTime = nil},
{position = Vector(-613.73034667969,1526.4348144531,128.26092529297), cutted = false, cutTime = nil},
{position = Vector(-612.30493164063,1664.2957763672,128), cutted = false, cutTime = nil},
{position = Vector(-761.33654785156,1792.9459228516,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-899.21929931641,1661.2512207031,127.87109375), cutted = false, cutTime = nil},
{position = Vector(-1024.5451660156,1639.0812988281,128.78729248047), cutted = false, cutTime = nil},
{position = Vector(1382.1633300781,55.775787353516,128), cutted = false, cutTime = nil},
{position = Vector(1342.7348632813,42.007934570313,128), cutted = false, cutTime = nil},
{position = Vector(1452.0069580078,34.748291015625,128), cutted = false, cutTime = nil},
{position = Vector(1458.6768798828,62.586853027344,128), cutted = false, cutTime = nil},
{position = Vector(1376.5825195313,164.89526367188,128), cutted = false, cutTime = nil},
{position = Vector(1375.0936279297,-237.41600036621,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(1515.3580322266,-227.30587768555,128), cutted = false, cutTime = nil},
{position = Vector(1589.5042724609,-44.820892333984,128), cutted = false, cutTime = nil},
{position = Vector(1788.5979003906,-39.421569824219,128), cutted = false, cutTime = nil},
{position = Vector(1661.5830078125,-254.03904724121,128), cutted = false, cutTime = nil},
{position = Vector(1868.943359375,-291.75769042969,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2215.1904296875,-609.1484375,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(2124.5676269531,-703.46600341797,128), cutted = false, cutTime = nil},
{position = Vector(2303.3579101563,-538.71600341797,128), cutted = false, cutTime = nil},
{position = Vector(2471.3244628906,-609.98468017578,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2570.1936035156,-657.68988037109,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2559.3874511719,-516.97631835938,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2828.5712890625,-584.59948730469,128), cutted = false, cutTime = nil},
{position = Vector(2819.9189453125,-501.17855834961,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(1981.5321044922,137.62200927734,128), cutted = false, cutTime = nil},
{position = Vector(1673.3615722656,224.1865234375,128), cutted = false, cutTime = nil},
{position = Vector(1856.103515625,395.68173217773,128), cutted = false, cutTime = nil},
{position = Vector(1521.9155273438,352.34664916992,128), cutted = false, cutTime = nil},
{position = Vector(1374.7072753906,450.86251831055,128), cutted = false, cutTime = nil},
{position = Vector(1343.6363525391,452.57431030273,128), cutted = false, cutTime = nil},
{position = Vector(1585.2626953125,468.08883666992,128), cutted = false, cutTime = nil},
{position = Vector(1782.8773193359,644.66577148438,128), cutted = false, cutTime = nil},
{position = Vector(1930.6564941406,526.69262695313,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2205.5842285156,487.31942749023,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(2404.0893554688,330.4875793457,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(2191.591796875,591.96459960938,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(2303.0595703125,654.6611328125,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(2377.5637207031,515.83154296875,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2488.9592285156,593.87915039063,128), cutted = false, cutTime = nil},
{position = Vector(2528.9877929688,418.7858581543,128), cutted = false, cutTime = nil},
{position = Vector(2661.3603515625,537.64807128906,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(2628.4577636719,605.42541503906,128), cutted = false, cutTime = nil},
{position = Vector(2488.140625,650.65405273438,128), cutted = false, cutTime = nil},
{position = Vector(2498.4697265625,789.60595703125,128), cutted = false, cutTime = nil},
{position = Vector(2320.4897460938,780.77160644531,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(2190.6796875,832.34631347656,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2367.6943359375,976.86553955078,128), cutted = false, cutTime = nil},
{position = Vector(2497.5183105469,939.22662353516,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2597.7817382813,942.60107421875,128), cutted = false, cutTime = nil},
{position = Vector(2706.05859375,774.32202148438,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(2762.3061523438,864.12078857422,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(2607.6208496094,1089.4940185547,128), cutted = false, cutTime = nil},
{position = Vector(2765.9213867188,1013.8969116211,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2695.1547851563,1130.0083007813,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2886.9326171875,1068.7678222656,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2729.810546875,1235.1477050781,128), cutted = false, cutTime = nil},
{position = Vector(2875.9460449219,1177.8640136719,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(2876.0090332031,1315.28125,128), cutted = false, cutTime = nil},
{position = Vector(2932.9304199219,1431.3642578125,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(2807.439453125,1490.2637939453,128), cutted = false, cutTime = nil},
{position = Vector(3095.3623046875,1315.28125,128), cutted = false, cutTime = nil},
{position = Vector(3157.5134277344,1191.5673828125,128), cutted = false, cutTime = nil},
{position = Vector(3324.9733886719,1245.2257080078,128), cutted = false, cutTime = nil},
{position = Vector(3380.1413574219,2015.1173095703,128), cutted = false, cutTime = nil},
{position = Vector(3614.3742675781,2027.1228027344,128), cutted = false, cutTime = nil},
{position = Vector(3854.4399414063,1917.0399169922,128), cutted = false, cutTime = nil},
{position = Vector(4102.6313476563,2003.93359375,128), cutted = false, cutTime = nil},
{position = Vector(4002.8474121094,1716.7232666016,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(4077.2060546875,1555.6647949219,128), cutted = false, cutTime = nil},
{position = Vector(4253.0258789063,1739.9072265625,128), cutted = false, cutTime = nil},
{position = Vector(4365.3701171875,1746.033203125,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(4671.2021484375,1764.6063232422,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(4791.712890625,1958.2530517578,128), cutted = false, cutTime = nil},
{position = Vector(4741.1943359375,2177.7626953125,128), cutted = false, cutTime = nil},
{position = Vector(4754.5493164063,2233.1401367188,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(4624.7416992188,2261.7443847656,128), cutted = false, cutTime = nil},
{position = Vector(4470.517578125,2147.4184570313,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(4488.3237304688,2254.0551757813,127.99993896484), cutted = false, cutTime = nil},
{position = Vector(4801.1586914063,2158.044921875,128), cutted = false, cutTime = nil},
{position = Vector(4783.6420898438,1924.0834960938,128), cutted = false, cutTime = nil},
{position = Vector(4422.7373046875,2210.7021484375,128.00006103516), cutted = false, cutTime = nil},
{position = Vector(4900.1528320313,2203.30859375,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(5215.8876953125,2078.80078125,128), cutted = false, cutTime = nil},
{position = Vector(-3929.1862792969,3403.4404296875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4083.8640136719,3353.5161132813,256), cutted = false, cutTime = nil},
{position = Vector(-4289.5185546875,3353.5161132813,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4420.2231445313,3393.783203125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-4606.849609375,3354.7905273438,256), cutted = false, cutTime = nil},
{position = Vector(-4797.0122070313,3469.291015625,255.97613525391), cutted = false, cutTime = nil},
{position = Vector(-4758.0356445313,3545.869140625,256), cutted = false, cutTime = nil},
{position = Vector(-4769.4873046875,3671.8815917969,255.56243896484), cutted = false, cutTime = nil},
{position = Vector(-4636.7114257813,3823.2770996094,254.43212890625), cutted = false, cutTime = nil},
{position = Vector(-4777.9345703125,3889.2727050781,255.71893310547), cutted = false, cutTime = nil},
{position = Vector(-4598.2475585938,3955.6276855469,255.99090576172), cutted = false, cutTime = nil},
{position = Vector(-4473.6669921875,4014.5830078125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-5077.4326171875,3613.6625976563,255.37408447266), cutted = false, cutTime = nil},
{position = Vector(-4846.1650390625,4370.341796875,256), cutted = false, cutTime = nil},
{position = Vector(-3954.2072753906,4299.9526367188,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-3510.7556152344,4272.8969726563,256), cutted = false, cutTime = nil},
{position = Vector(-3532.5871582031,4363.90625,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-3598.4338378906,4510.4213867188,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-3465.146484375,4615.091796875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-3354.8623046875,4520.970703125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-3342.4221191406,4571.1674804688,256), cutted = false, cutTime = nil},
{position = Vector(-3334.8220214844,4682.11328125,256), cutted = false, cutTime = nil},
{position = Vector(-3237.2424316406,4289.5756835938,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-3367.0998535156,4204.22265625,256), cutted = false, cutTime = nil},
{position = Vector(-3236.4138183594,4228.1181640625,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-3374.9453125,4267.328125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-3128.3229980469,4226.7436523438,256), cutted = false, cutTime = nil},
{position = Vector(-2987.8957519531,4228.1181640625,256), cutted = false, cutTime = nil},
{position = Vector(-3075.3012695313,4294.7553710938,256), cutted = false, cutTime = nil},
{position = Vector(-2926.2939453125,4297.6826171875,256), cutted = false, cutTime = nil},
{position = Vector(-2820.4438476563,4237.7890625,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-2733.2734375,4224,256), cutted = false, cutTime = nil},
{position = Vector(-2753.0927734375,4330.3935546875,256), cutted = false, cutTime = nil},
{position = Vector(-2757.3603515625,4413.28125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-2565.0634765625,4401.9873046875,256), cutted = false, cutTime = nil},
{position = Vector(-2797.3427734375,4525.1142578125,256), cutted = false, cutTime = nil},
{position = Vector(-2675.9169921875,4579.5942382813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-2528.6215820313,4572.7983398438,256), cutted = false, cutTime = nil},
{position = Vector(-2449.2822265625,4440.6328125,256), cutted = false, cutTime = nil},
{position = Vector(-1756.1711425781,4415.5893554688,256), cutted = false, cutTime = nil},
{position = Vector(-1872.5981445313,4557.3364257813,256), cutted = false, cutTime = nil},
{position = Vector(-1749.2662353516,4556.0073242188,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-1684.1157226563,4431.078125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-1404.2591552734,4480.4580078125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-1635.5025634766,4095.4597167969,256), cutted = false, cutTime = nil},
{position = Vector(-1624.5909423828,4191.4223632813,256), cutted = false, cutTime = nil},
{position = Vector(-1768.6229248047,4192.595703125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-744.82208251953,4597.2216796875,256), cutted = false, cutTime = nil},
{position = Vector(-785.72399902344,4734.2368164063,256), cutted = false, cutTime = nil},
{position = Vector(-212.22299194336,4573.2333984375,256), cutted = false, cutTime = nil},
{position = Vector(-64.769866943359,4150.958984375,256), cutted = false, cutTime = nil},
{position = Vector(61.087051391602,4848.8720703125,256), cutted = false, cutTime = nil},
{position = Vector(39.734786987305,4052.9716796875,256), cutted = false, cutTime = nil},
{position = Vector(-141.40995788574,3873.7111816406,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(20.702896118164,3861.9348144531,256), cutted = false, cutTime = nil},
{position = Vector(128.76770019531,3858.4287109375,256), cutted = false, cutTime = nil},
{position = Vector(-54.561614990234,3776.7331542969,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(99.816223144531,3725.5317382813,256), cutted = false, cutTime = nil},
{position = Vector(137.4739074707,3652.4311523438,256), cutted = false, cutTime = nil},
{position = Vector(-67.682907104492,3553.2341308594,256), cutted = false, cutTime = nil},
{position = Vector(93.918212890625,3486.62109375,256), cutted = false, cutTime = nil},
{position = Vector(184.67053222656,3364.19140625,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-35.517135620117,3402.5910644531,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(-197.38264465332,3422.9438476563,256), cutted = false, cutTime = nil},
{position = Vector(6.7699279785156,3253.0895996094,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(19.363525390625,3284.3103027344,256), cutted = false, cutTime = nil},
{position = Vector(-195.01454162598,3231.8959960938,256), cutted = false, cutTime = nil},
{position = Vector(-86.662994384766,3346.6516113281,256), cutted = false, cutTime = nil},
{position = Vector(14.549545288086,3285.6884765625,256), cutted = false, cutTime = nil},
{position = Vector(-274.98486328125,3326.4304199219,256), cutted = false, cutTime = nil},
{position = Vector(-344.09906005859,3183.2072753906,256), cutted = false, cutTime = nil},
{position = Vector(-490.71551513672,3164.5991210938,256), cutted = false, cutTime = nil},
{position = Vector(-410.48944091797,3310.7978515625,256), cutted = false, cutTime = nil},
{position = Vector(-365.64715576172,3453.5737304688,256), cutted = false, cutTime = nil},
{position = Vector(-635.41436767578,3379.1862792969,256), cutted = false, cutTime = nil},
{position = Vector(-604.81799316406,3180.7065429688,256), cutted = false, cutTime = nil},
{position = Vector(-857.61218261719,3356.0773925781,128), cutted = false, cutTime = nil},
{position = Vector(-690.33026123047,3528.4868164063,155.33947753906), cutted = false, cutTime = nil},
{position = Vector(-612.30749511719,3553.7299804688,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(633.41131591797,3925.162109375,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(692.85211181641,4039.3232421875,256), cutted = false, cutTime = nil},
{position = Vector(878.31829833984,3067.5390625,256), cutted = false, cutTime = nil},
{position = Vector(984.57592773438,3071.8120117188,256), cutted = false, cutTime = nil},
{position = Vector(1117.8294677734,3025.484375,256), cutted = false, cutTime = nil},
{position = Vector(1375.83203125,3047.1606445313,256), cutted = false, cutTime = nil},
{position = Vector(1522.0708007813,3122.4099121094,256), cutted = false, cutTime = nil},
{position = Vector(1537.6876220703,3161.7817382813,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(1631.1301269531,3171.8486328125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1619.1510009766,3235.7583007813,256), cutted = false, cutTime = nil},
{position = Vector(1618.5491943359,3389.13671875,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1809.2502441406,3332.9992675781,256), cutted = false, cutTime = nil},
{position = Vector(1797.0205078125,3504.0014648438,256), cutted = false, cutTime = nil},
{position = Vector(1557.3095703125,3552.6394042969,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(1676.9792480469,3662.9797363281,256), cutted = false, cutTime = nil},
{position = Vector(1784.8021240234,3661.5244140625,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(1884.8295898438,3587.0524902344,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(1944.1666259766,3890.5317382813,128), cutted = false, cutTime = nil},
{position = Vector(591.30932617188,2828.7260742188,256), cutted = false, cutTime = nil},
{position = Vector(506.67175292969,2638.6555175781,256), cutted = false, cutTime = nil},
{position = Vector(494.49624633789,2651.8828125,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(646.56951904297,2516.6467285156,256), cutted = false, cutTime = nil},
{position = Vector(791.9130859375,2562.9372558594,256), cutted = false, cutTime = nil},
{position = Vector(322.75875854492,2554.890625,256), cutted = false, cutTime = nil},
{position = Vector(974.65789794922,2632.109375,256), cutted = false, cutTime = nil},
{position = Vector(1129.2121582031,2578.2160644531,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-19.778076171875,2688.2939453125,255.99993896484), cutted = false, cutTime = nil},
{position = Vector(85.656242370605,2831.5727539063,256.00006103516), cutted = false, cutTime = nil},
{position = Vector(-123.30104064941,2667.5180664063,256), cutted = false, cutTime = nil},
{position = Vector(-875.16754150391,3248.5170898438,128), cutted = false, cutTime = nil},
{position = Vector(-1358.1684570313,2615.7370605469,128), cutted = false, cutTime = nil},
{position = Vector(-1834.9206542969,2452.7299804688,127.02288818359), cutted = false, cutTime = nil},
{position = Vector(-1184.8061523438,2643.9353027344,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-1039.9254150391,2752.162109375,128), cutted = false, cutTime = nil},
{position = Vector(-673.05804443359,2462.5805664063,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-473.16943359375,2135.5952148438,256), cutted = false, cutTime = nil},
{position = Vector(-704.8916015625,2110.7026367188,256), cutted = false, cutTime = nil},
{position = Vector(-744.72790527344,2264.6462402344,256), cutted = false, cutTime = nil},
{position = Vector(-843.70611572266,2277.6745605469,256), cutted = false, cutTime = nil},
{position = Vector(-829.30749511719,2381.57421875,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-957.17224121094,2433.1369628906,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-570.62829589844,2342.1853027344,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-567.18566894531,2030.7253417969,256), cutted = false, cutTime = nil},
{position = Vector(-632.34753417969,1905.9895019531,249.64208984375), cutted = false, cutTime = nil},
{position = Vector(-854.70764160156,2012.2709960938,256.55834960938), cutted = false, cutTime = nil},
{position = Vector(-977.34918212891,2244.81640625,256), cutted = false, cutTime = nil},
{position = Vector(-1105.9616699219,2390.7104492188,256), cutted = false, cutTime = nil},
{position = Vector(-1235.8841552734,2383.8994140625,256), cutted = false, cutTime = nil},
{position = Vector(-1096.5869140625,2243.2775878906,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-892.95721435547,2123.150390625,256), cutted = false, cutTime = nil},
{position = Vector(-937.66516113281,1980.5932617188,256.05310058594), cutted = false, cutTime = nil},
{position = Vector(-720.06689453125,1847.7591552734,128), cutted = false, cutTime = nil},
{position = Vector(-916.43127441406,1748.5551757813,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(-880.47839355469,1613.2799072266,128), cutted = false, cutTime = nil},
{position = Vector(-1098.6557617188,2156.1359863281,256), cutted = false, cutTime = nil},
{position = Vector(-1095.8464355469,2002.6228027344,256), cutted = false, cutTime = nil},
{position = Vector(-1215.5593261719,2031.1053466797,256), cutted = false, cutTime = nil},
{position = Vector(-1222.0263671875,2169.5036621094,256), cutted = false, cutTime = nil},
{position = Vector(-1350.4000244141,2251.0053710938,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1336.0092773438,2121.271484375,256), cutted = false, cutTime = nil},
{position = Vector(-1357.6772460938,2001.9372558594,256), cutted = false, cutTime = nil},
{position = Vector(-1477.9808349609,2164.1020507813,256), cutted = false, cutTime = nil},
{position = Vector(-1602.3563232422,2147.5288085938,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(-1737.4948730469,2155.560546875,235.24096679688), cutted = false, cutTime = nil},
{position = Vector(-1882.9272460938,2223.0607910156,255.71020507813), cutted = false, cutTime = nil},
{position = Vector(281.05334472656,1760.2739257813,256), cutted = false, cutTime = nil},
{position = Vector(439.33660888672,1749.6311035156,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(434.15478515625,1886.169921875,256), cutted = false, cutTime = nil},
{position = Vector(507.12734985352,1987.1142578125,256), cutted = false, cutTime = nil},
{position = Vector(565.05908203125,1864.8402099609,256), cutted = false, cutTime = nil},
{position = Vector(798.94409179688,1912.8627929688,256), cutted = false, cutTime = nil},
{position = Vector(932.9248046875,1936.6281738281,256), cutted = false, cutTime = nil},
{position = Vector(1981.0523681641,2264.3747558594,128), cutted = false, cutTime = nil},
{position = Vector(2137.9558105469,2285.3356933594,128), cutted = false, cutTime = nil},
{position = Vector(2223.5720214844,2445.0874023438,128), cutted = false, cutTime = nil},
{position = Vector(2785.2260742188,-1064.3969726563,128), cutted = false, cutTime = nil},
{position = Vector(3190.3569335938,-1037.3312988281,128), cutted = false, cutTime = nil},
{position = Vector(3331.2478027344,-1172.2891845703,128), cutted = false, cutTime = nil},
{position = Vector(3471.00390625,-1126.6221923828,128), cutted = false, cutTime = nil},
{position = Vector(3440.8415527344,-992.51684570313,128), cutted = false, cutTime = nil},
{position = Vector(3586.8012695313,-1085.5378417969,128), cutted = false, cutTime = nil},
{position = Vector(3306.9658203125,-1057.5131835938,128), cutted = false, cutTime = nil},
{position = Vector(3836.4938964844,-922.265625,128), cutted = false, cutTime = nil},
{position = Vector(4538.568359375,-827.12438964844,128), cutted = false, cutTime = nil},
{position = Vector(4522.1518554688,-688.35729980469,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(4483.6689453125,-572.62994384766,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(4417.62109375,-372.32806396484,128), cutted = false, cutTime = nil},
{position = Vector(4156.9409179688,-395.80169677734,128), cutted = false, cutTime = nil},
{position = Vector(3920.4289550781,-295.44049072266,128), cutted = false, cutTime = nil},
{position = Vector(4189.830078125,-126.62420654297,130.75170898438), cutted = false, cutTime = nil},
{position = Vector(4315.947265625,-177.71960449219,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(3700.6430664063,-72.685180664063,256), cutted = false, cutTime = nil},
{position = Vector(3956.263671875,204.98620605469,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4110.3525390625,296.31640625,256), cutted = false, cutTime = nil},
{position = Vector(3977.6027832031,591.03210449219,256), cutted = false, cutTime = nil},
{position = Vector(4100.720703125,599.83020019531,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4085.0485839844,748.99285888672,256), cutted = false, cutTime = nil},
{position = Vector(4260.3852539063,855.33612060547,256), cutted = false, cutTime = nil},
{position = Vector(4293.89453125,658.92315673828,256), cutted = false, cutTime = nil},
{position = Vector(4216.34765625,281.67050170898,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4329.9477539063,294.134765625,256), cutted = false, cutTime = nil},
{position = Vector(4471.9448242188,257.05035400391,256), cutted = false, cutTime = nil},
{position = Vector(4412.912109375,665.95159912109,256), cutted = false, cutTime = nil},
{position = Vector(4259.7197265625,916.07702636719,256), cutted = false, cutTime = nil},
{position = Vector(4341.1875,1031.060546875,256), cutted = false, cutTime = nil},
{position = Vector(4421.0258789063,905.92358398438,256), cutted = false, cutTime = nil},
{position = Vector(4449.8588867188,1038.2341308594,256), cutted = false, cutTime = nil},
{position = Vector(4403.580078125,1252.0235595703,256), cutted = false, cutTime = nil},
{position = Vector(4538.7553710938,1233.5590820313,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4679.6083984375,1215.3056640625,256), cutted = false, cutTime = nil},
{position = Vector(4545.0190429688,1405.130859375,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4671.787109375,1407.0178222656,256), cutted = false, cutTime = nil},
{position = Vector(4899.6557617188,1421.9956054688,256), cutted = false, cutTime = nil},
{position = Vector(5060.609375,1321.6990966797,256), cutted = false, cutTime = nil},
{position = Vector(4866.8515625,1218.1512451172,256), cutted = false, cutTime = nil},
{position = Vector(4874.7080078125,1077.3580322266,256), cutted = false, cutTime = nil},
{position = Vector(5054.0493164063,1158.2409667969,256), cutted = false, cutTime = nil},
{position = Vector(4808.6831054688,1014.486328125,256), cutted = false, cutTime = nil},
{position = Vector(4648.3969726563,930.42700195313,256), cutted = false, cutTime = nil},
{position = Vector(4506.6259765625,957.34448242188,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4616.392578125,780.36169433594,256), cutted = false, cutTime = nil},
{position = Vector(4572.8129882813,774.45751953125,256), cutted = false, cutTime = nil},
{position = Vector(4444.2309570313,763.54016113281,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4860.0444335938,863.32189941406,256), cutted = false, cutTime = nil},
{position = Vector(4847.2490234375,697.74127197266,256), cutted = false, cutTime = nil},
{position = Vector(4979.984375,733.35339355469,256), cutted = false, cutTime = nil},
{position = Vector(5106.3461914063,717.98431396484,256), cutted = false, cutTime = nil},
{position = Vector(5435.6044921875,1337.759765625,256), cutted = false, cutTime = nil},
{position = Vector(5570.6059570313,1331.0115966797,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5627.06640625,1167.1982421875,256), cutted = false, cutTime = nil},
{position = Vector(5438.5126953125,1145.4475097656,256), cutted = false, cutTime = nil},
{position = Vector(5513.9809570313,886.1015625,256), cutted = false, cutTime = nil},
{position = Vector(5628.82421875,714.41259765625,256), cutted = false, cutTime = nil},
{position = Vector(5701.123046875,840.63592529297,256), cutted = false, cutTime = nil},
{position = Vector(5662.1245117188,602.00872802734,256), cutted = false, cutTime = nil},
{position = Vector(5837.6997070313,758.93225097656,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5137.7211914063,258.84350585938,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4995.0078125,238.87841796875,256), cutted = false, cutTime = nil},
{position = Vector(4984.375,67.601440429688,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(4863.0004882813,118.15979003906,256), cutted = false, cutTime = nil},
{position = Vector(5014.7587890625,-267.81286621094,256), cutted = false, cutTime = nil},
{position = Vector(5171.15625,-202.90057373047,256), cutted = false, cutTime = nil},
{position = Vector(5351.3984375,-86.917541503906,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(5444.8935546875,-223.31271362305,256), cutted = false, cutTime = nil},
{position = Vector(5553.158203125,-270.07583618164,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(5453.5297851563,-420.57073974609,256), cutted = false, cutTime = nil},
{position = Vector(5305.9243164063,-302.11978149414,256), cutted = false, cutTime = nil},
{position = Vector(5159.2578125,-389.51348876953,256), cutted = false, cutTime = nil},
{position = Vector(5301.5458984375,-497.07028198242,256), cutted = false, cutTime = nil},
{position = Vector(5162.1513671875,-465.73287963867,256), cutted = false, cutTime = nil},
{position = Vector(5045.5639648438,-570.99157714844,256), cutted = false, cutTime = nil},
{position = Vector(5179.1030273438,-616.15002441406,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5331.2094726563,-433.72833251953,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5309.42578125,-699.38775634766,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(5167.0263671875,-747.17028808594,256), cutted = false, cutTime = nil},
{position = Vector(5032.4267578125,-690.2861328125,256), cutted = false, cutTime = nil},
{position = Vector(4647.3754882813,-214.31109619141,256), cutted = false, cutTime = nil},
{position = Vector(4632.8583984375,-389.54583740234,256), cutted = false, cutTime = nil},
{position = Vector(4768.0634765625,-571.12854003906,256), cutted = false, cutTime = nil},
{position = Vector(4749.5595703125,-686.09362792969,256), cutted = false, cutTime = nil},
{position = Vector(4710.5888671875,-757.5185546875,256), cutted = false, cutTime = nil},
{position = Vector(4750.837890625,-958.61102294922,256), cutted = false, cutTime = nil},
{position = Vector(5076.9580078125,-827.80932617188,256), cutted = false, cutTime = nil},
{position = Vector(5124.66796875,-1091.7355957031,256), cutted = false, cutTime = nil},
{position = Vector(5384.98828125,-1188.1971435547,256), cutted = false, cutTime = nil},
{position = Vector(5308.4985351563,-1340.2346191406,256), cutted = false, cutTime = nil},
{position = Vector(5468.3618164063,-1338.5922851563,256), cutted = false, cutTime = nil},
{position = Vector(5486.1870117188,-1042.6638183594,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5577.521484375,-1194.1843261719,256), cutted = false, cutTime = nil},
{position = Vector(5561.9497070313,-949.56750488281,256), cutted = false, cutTime = nil},
{position = Vector(5614.5981445313,-791.66851806641,256), cutted = false, cutTime = nil},
{position = Vector(5700.37109375,-929.28900146484,256), cutted = false, cutTime = nil},
{position = Vector(5753.5615234375,-756.87866210938,256), cutted = false, cutTime = nil},
{position = Vector(5629.767578125,-1087.8967285156,256), cutted = false, cutTime = nil},
{position = Vector(5750.8857421875,-1085.880859375,256), cutted = false, cutTime = nil},
{position = Vector(5828.3139648438,-1305.8095703125,256), cutted = false, cutTime = nil},
{position = Vector(5605.703125,-1360.8344726563,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(5685.1279296875,-1518.0139160156,256), cutted = false, cutTime = nil},
{position = Vector(5566.287109375,-1564.607421875,256), cutted = false, cutTime = nil},
{position = Vector(5406.1889648438,-1567.8792724609,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(5286.4736328125,-1620.1258544922,256), cutted = false, cutTime = nil},
{position = Vector(5219.2451171875,-1443.3076171875,256), cutted = false, cutTime = nil},
{position = Vector(4815.0498046875,-1178.5390625,256), cutted = false, cutTime = nil},
{position = Vector(4759.044921875,-1035.6010742188,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(4662.51953125,-1074.5107421875,256), cutted = false, cutTime = nil},
{position = Vector(5173.2900390625,-1917.8204345703,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5112.1889648438,-2211.9311523438,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5115.4790039063,-2211.9311523438,256), cutted = false, cutTime = nil},
{position = Vector(5425.412109375,-1880.1501464844,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(5558.6450195313,-1896.4158935547,256), cutted = false, cutTime = nil},
{position = Vector(5609.3129882813,-2106.8654785156,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(5686.6684570313,-1948.2250976563,256), cutted = false, cutTime = nil},
{position = Vector(5727.2109375,-2173.6735839844,256), cutted = false, cutTime = nil},
{position = Vector(7078.3764648438,-2385.431640625,256), cutted = false, cutTime = nil},
{position = Vector(7208.7709960938,-2369.6640625,256), cutted = false, cutTime = nil},
{position = Vector(7359.6513671875,-2426.3486328125,256), cutted = false, cutTime = nil},
{position = Vector(7536.3041992188,-2426.3486328125,256), cutted = false, cutTime = nil},
{position = Vector(7486.142578125,-2283.1813964844,256), cutted = false, cutTime = nil},
{position = Vector(7078.2001953125,-2290.4968261719,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6938.8994140625,-2221.0390625,256), cutted = false, cutTime = nil},
{position = Vector(7118.8525390625,-2181.5578613281,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7241.3022460938,-2164.0590820313,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7450.6489257813,-2167.5751953125,256), cutted = false, cutTime = nil},
{position = Vector(7585.162109375,-2167.5751953125,256), cutted = false, cutTime = nil},
{position = Vector(7516.96875,-2019.8828125,256), cutted = false, cutTime = nil},
{position = Vector(7359.1430664063,-2026.9024658203,256), cutted = false, cutTime = nil},
{position = Vector(7218.6079101563,-2061.5148925781,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7122.400390625,-2058.0893554688,256), cutted = false, cutTime = nil},
{position = Vector(7364.8374023438,-2323.4936523438,256), cutted = false, cutTime = nil},
{position = Vector(6983.7900390625,-2068.68359375,256), cutted = false, cutTime = nil},
{position = Vector(6847.791015625,-2074.0454101563,256), cutted = false, cutTime = nil},
{position = Vector(7113.4760742188,-1941.0723876953,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7231.248046875,-1923.3802490234,256), cutted = false, cutTime = nil},
{position = Vector(7372.2299804688,-1914.4562988281,256), cutted = false, cutTime = nil},
{position = Vector(7303.5146484375,-1792.8552246094,256), cutted = false, cutTime = nil},
{position = Vector(7223.6235351563,-1650.1395263672,256), cutted = false, cutTime = nil},
{position = Vector(7024.8129882813,-1711.8024902344,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6923.5229492188,-1796.5219726563,256), cutted = false, cutTime = nil},
{position = Vector(6769.935546875,-1879.8790283203,256), cutted = false, cutTime = nil},
{position = Vector(6571.1611328125,-1734.7435302734,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6781,-1729.4798583984,256), cutted = false, cutTime = nil},
{position = Vector(6923.9228515625,-1661.2001953125,256), cutted = false, cutTime = nil},
{position = Vector(6875.064453125,-1552.9276123047,256), cutted = false, cutTime = nil},
{position = Vector(6980.3208007813,-1541.2315673828,256), cutted = false, cutTime = nil},
{position = Vector(6805.6655273438,-1422.6535644531,256), cutted = false, cutTime = nil},
{position = Vector(6639.537109375,-1515.8571777344,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6908.12890625,-1409.9119873047,256), cutted = false, cutTime = nil},
{position = Vector(7195.95703125,-1414.3762207031,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7295.9267578125,-1419.1070556641,256), cutted = false, cutTime = nil},
{position = Vector(7110.3408203125,-1285.0700683594,256), cutted = false, cutTime = nil},
{position = Vector(7249.0629882813,-1258.7213134766,256), cutted = false, cutTime = nil},
{position = Vector(7383.2885742188,-1202.8077392578,256), cutted = false, cutTime = nil},
{position = Vector(7503.5258789063,-1219.2478027344,256), cutted = false, cutTime = nil},
{position = Vector(7425.7958984375,-1072.7921142578,256), cutted = false, cutTime = nil},
{position = Vector(7401.7407226563,-1076.1220703125,256), cutted = false, cutTime = nil},
{position = Vector(7113.0932617188,-1081.1032714844,256), cutted = false, cutTime = nil},
{position = Vector(6987.8364257813,-1081.1032714844,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6840.1069335938,-1088.5971679688,256), cutted = false, cutTime = nil},
{position = Vector(6711.125,-1086.7708740234,256), cutted = false, cutTime = nil},
{position = Vector(6718.1357421875,-898.57775878906,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6855.26953125,-962.93896484375,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7045.1401367188,-971.92041015625,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7195.345703125,-941.16918945313,256), cutted = false, cutTime = nil},
{position = Vector(7228.400390625,-1149.1622314453,256), cutted = false, cutTime = nil},
{position = Vector(7356.7939453125,-984.25024414063,256), cutted = false, cutTime = nil},
{position = Vector(7417.7846679688,-745.36340332031,256), cutted = false, cutTime = nil},
{position = Vector(7292.744140625,-749.19219970703,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7105.6435546875,-842.04382324219,256), cutted = false, cutTime = nil},
{position = Vector(6957.890625,-843.84637451172,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6829.0791015625,-854.61773681641,256), cutted = false, cutTime = nil},
{position = Vector(6559.7978515625,-829.36791992188,256), cutted = false, cutTime = nil},
{position = Vector(6606.8334960938,-676.22534179688,256), cutted = false, cutTime = nil},
{position = Vector(6756.6728515625,-650.0966796875,256), cutted = false, cutTime = nil},
{position = Vector(6875.9814453125,-590.68548583984,256), cutted = false, cutTime = nil},
{position = Vector(6996.7963867188,-582.85888671875,256), cutted = false, cutTime = nil},
{position = Vector(7116.1098632813,-584.81909179688,256), cutted = false, cutTime = nil},
{position = Vector(7381.7841796875,-646.32904052734,256), cutted = false, cutTime = nil},
{position = Vector(7167.6157226563,-456.10702514648,256), cutted = false, cutTime = nil},
{position = Vector(6900.6171875,-421.21826171875,256), cutted = false, cutTime = nil},
{position = Vector(6646.9497070313,-385.90539550781,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6722.6181640625,-226.75799560547,256), cutted = false, cutTime = nil},
{position = Vector(6854.5068359375,-297.24746704102,256), cutted = false, cutTime = nil},
{position = Vector(6972.1811523438,-190.28329467773,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6672.525390625,-499.59539794922,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7046.8120117188,-367.36022949219,256), cutted = false, cutTime = nil},
{position = Vector(7216.3188476563,-314.46368408203,256), cutted = false, cutTime = nil},
{position = Vector(7103.49609375,-198.35809326172,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7255.3188476563,-110.20501708984,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6952.6235351563,-115.12130737305,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6775.07421875,-142.67916870117,256), cutted = false, cutTime = nil},
{position = Vector(7024.2978515625,-1.3510131835938,256), cutted = false, cutTime = nil},
{position = Vector(7210.6748046875,5.7145690917969,256), cutted = false, cutTime = nil},
{position = Vector(7124.3203125,142.38562011719,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6963.5336914063,196.46649169922,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6721.9799804688,182.32849121094,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6772.9174804688,316.28674316406,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(6933.48828125,291.59289550781,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7099.5419921875,237.83874511719,256), cutted = false, cutTime = nil},
{position = Vector(7338.9848632813,178.27017211914,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7431.2880859375,323.57626342773,256), cutted = false, cutTime = nil},
{position = Vector(7214.3037109375,409.19985961914,256), cutted = false, cutTime = nil},
{position = Vector(7358.05078125,460.32653808594,256), cutted = false, cutTime = nil},
{position = Vector(7088.1264648438,469.63269042969,256), cutted = false, cutTime = nil},
{position = Vector(6956.2729492188,432.73123168945,256), cutted = false, cutTime = nil},
{position = Vector(6836.8212890625,425.45318603516,256), cutted = false, cutTime = nil},
{position = Vector(6793.4926757813,569.41491699219,256), cutted = false, cutTime = nil},
{position = Vector(7033.76171875,583.54797363281,256), cutted = false, cutTime = nil},
{position = Vector(7175.0771484375,588.88134765625,256), cutted = false, cutTime = nil},
{position = Vector(7306.2456054688,594.23303222656,256), cutted = false, cutTime = nil},
{position = Vector(7431.3701171875,606.79223632813,256), cutted = false, cutTime = nil},
{position = Vector(7286.6831054688,688.31884765625,256), cutted = false, cutTime = nil},
{position = Vector(7091.7421875,691.91558837891,256), cutted = false, cutTime = nil},
{position = Vector(6971.7163085938,682.93939208984,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(6841.6884765625,691.91552734375,256), cutted = false, cutTime = nil},
{position = Vector(6726.6821289063,677.57849121094,256), cutted = false, cutTime = nil},
{position = Vector(6930.021484375,817.49066162109,256), cutted = false, cutTime = nil},
{position = Vector(6780.2626953125,887.21264648438,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7488.1455078125,770.80139160156,256), cutted = false, cutTime = nil},
{position = Vector(7335.6684570313,825.38690185547,256), cutted = false, cutTime = nil},
{position = Vector(7265.857421875,950.85534667969,256), cutted = false, cutTime = nil},
{position = Vector(7147.7036132813,1008.7587890625,255.99987792969), cutted = false, cutTime = nil},
{position = Vector(7421.5532226563,948.96087646484,256), cutted = false, cutTime = nil},
{position = Vector(7541.8154296875,924.53582763672,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7497.1884765625,1110.0920410156,256.00012207031), cutted = false, cutTime = nil},
{position = Vector(7374.546875,1209.8840332031,148.66296386719), cutted = false, cutTime = nil},
{position = Vector(7204.859375,1535.2360839844,128), cutted = false, cutTime = nil},
{position = Vector(7057.8481445313,1660.5217285156,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(7294.6982421875,1685.0111083984,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(7478.0244140625,1573.9239501953,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(7583.0693359375,1714.0428466797,128), cutted = false, cutTime = nil},
{position = Vector(7511.1059570313,1883.2253417969,128), cutted = false, cutTime = nil},
{position = Vector(7342.32421875,1881.2250976563,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(7283.7705078125,1995.3288574219,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(7437.2104492188,2022.2419433594,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(7581.146484375,1999.1467285156,128), cutted = false, cutTime = nil},
{position = Vector(7494.9350585938,2119.1083984375,128.00012207031), cutted = false, cutTime = nil},
{position = Vector(7404.8828125,2239.0686035156,128), cutted = false, cutTime = nil},
{position = Vector(7190.8354492188,2198.7770996094,128), cutted = false, cutTime = nil},
{position = Vector(7489.068359375,2295.0283203125,128), cutted = false, cutTime = nil},
{position = Vector(7351.8017578125,2290.8198242188,127.99987792969), cutted = false, cutTime = nil},
{position = Vector(7236.4370117188,2290.8198242188,128), cutted = false, cutTime = nil},
{position = Vector(7115.5678710938,2291.2890625,141.86938476563), cutted = false, cutTime = nil},

}


function Key(msg, code)
	if client.chat or client.console or not PlayingGame() or client.paused then return end
	if msg == LBUTTON_DOWN and client.mouseScreenPosition.x > 300 then
		local me = entityList:GetMyHero()
		if not me then return end
		local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO, team=me:GetEnemyTeam()})
		for i = 1, #enemies do 
			local v = enemies[i]
			local id = v.playerId
			local x,y,h,w
			local button = indicate[id]
			if button then
				x,y,h,w = button.x,button.y,button.h,button.w
			else
				local xx = GetXX(v)
				x,y,h,w = xx-20+x_*id,0,x_,35*monitor
				indicate[id] = drawMgr:CreateRect(x,y,h,w,9911861800) 
				indicate[id].visible = false
			end
			if IsMouseOnButton(x,y,h,w) then
				if victim and victim == v then
					victim = nil
					targetlock = false
					indicate[id].visible = false
					return true
				else
					victim = v
					targetlock = true
					enemyHP = victim.health
					indicate[id].visible = true
					for z = 1, 9 do	
						local k = indicate[z]
						if k and k.visible and z ~= id then
							indicate[z].visible = false
						end
					end
					return true
				end
			end
		end
		if config.ManualLock then
			local targetFind = targetFind
			local mOver = targetFind:GetClosestToMouse(me,999999)
			if mOver and GetDistance2D(mOver, client.mousePosition) < 300 then 
				if victim and victim == mOver then
					indicate[victim.playerId].visible = false
					victim = nil
					targetlock = false
					return false
				else
					victim = mOver 
					indicate[victim.playerId].visible = false
					targetlock = true 
					enemyHP = victim.health
					return false
				end
			elseif victim then
				indicate[victim.playerId].visible = false
				victim = nil
				targetlock = false
				return false
			end
		end
	elseif msg == KEY_UP then
		if code == blinktoggle then
			useblink = not useblink
			return true
		elseif code == config.Retreat then
			retreat = not retreat
			return true
		elseif code == config.Harras then
			harras = not harras
			return true
		elseif config.EnableComboKeys and buttons[1] then
			if code == config.Combo1 or code == config.Combo2 or code == config.Combo3 then
				local me = entityList:GetMyHero()
				local invoke, refresher = me:GetAbility(6), me:FindItem("item_refresher")
				if invoke.level < 4 then
					buttons[1].txt.text = "Need Invoke lvl 4!" Sleep(1000,"refbutton")
				elseif not me:AghanimState() then
					buttons[1].txt.text = "Need Aghanims!" Sleep(1000,"refbutton")
				elseif not refresher then
					buttons[1].txt.text = "Need Refresher!" Sleep(1000,"refbutton")
				elseif not refresher:CanBeCasted() and refresher.cd > 10 then
					buttons[1].txt.text = "Refresher is on cd!" Sleep(1000,"refbutton")
				elseif code == config.Combo1 then
					combo = 1
					comboready = false
				elseif code == config.Combo2 then
					combo = 2
					comboready = false
				elseif code == config.Combo3 then
					combo = 3
					comboready = false
				end
			end
		end
	end
end

function buttonClick(b1,b2,t)
	if not t.visible and t.text ~= "Cancel" then return end
	if buttons[1] and t.text == buttons[1].txt.text then
		if buttons[5] and buttons[5].obj then
			buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false 
			--HUD:RemoveElement(buttons[5].id+1)
			--buttons[5] = nil
		end
		local me = entityList:GetMyHero()
		local invoke, refresher = me:GetAbility(6), me:FindItem("item_refresher")
		if invoke.level < 4 then
			buttons[1].txt.text = "Need Invoke lvl 4!" Sleep(1000,"refbutton")
		elseif not me:AghanimState() then
			buttons[1].txt.text = "Need Aghanims!" Sleep(1000,"refbutton")
		elseif not refresher then
			buttons[1].txt.text = "Need Refresher!" Sleep(1000,"refbutton")
		elseif not refresher:CanBeCasted() and refresher.cd > 10 then
			buttons[1].txt.text = "Refresher is on cd!" Sleep(1000,"refbutton")
		else
			if buttons[2].obj.visible then
				buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
				buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
				buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
				--buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
				--buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
			else
				buttons[2].obj.visible = true buttons[2].out.visible = true buttons[2].txt.visible = true
				buttons[3].obj.visible = true buttons[3].out.visible = true buttons[3].txt.visible = true
				buttons[4].obj.visible = true buttons[4].out.visible = true buttons[4].txt.visible = true
				--buttons[5].obj.visible = true buttons[5].out.visible = true buttons[5].txt.visible = true
				--buttons[6].obj.visible = true buttons[6].out.visible = true buttons[6].txt.visible = true
			end
		end
	elseif t.text == "Combo 1" then
		buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
		buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
		buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
		--buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
		--buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
		comboready = false
		combo = 1
	elseif t.text == "Combo 2" then
		buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
		buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
		buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
		--buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
		--buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
		comboready = false
		combo = 2
	elseif t.text == "Combo 3" then
		buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
		buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
		buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
		--buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
		--buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
		comboready = false
		combo = 3
	elseif t.text == "Cancel" then
		if buttons[2].obj.visible then
			buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
			buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
			buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
			--buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
			--buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
			comboready = false
			combo = 1
		else
			comboready = false
			combo = 0
		end
	end
end

function Main(tick)
	--VersionInfo
	if client.gameTime > 1 then
		versionSign.visible = false
		infoSign.visible = false
		local up,ver,beta,info = Version()
		if up then
			if beta ~= "" then
				versionSign.text = "Your version of MCScript by ensage-forum.ru is up-to-date! (v"..currentVersion.." "..Beta..")"
			else
				versionSign.text = "Your version of MCScript by ensage-forum.ru is up-to-date! (v"..currentVersion..")"
			end
			versionSign.color = 0x007ACCFF
			if info then
				infoSign.text = info
				infoSign.visible = true
			end
		end
		if outdated then
			if beta ~= "" then
				versionSign.text = "Your version of MCScript by ensage-forum.ru is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.." "..beta..")"
			else
				versionSign.text = "Your version of MCScript by ensage-forum.ru is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver..")"
			end
			versionSign.color = 0xA40062FF
			if info then
				infoSign.text = info
				infoSign.visible = true
			end
		end
		versionSign.visible = true
	end
	
	local client, PlayingGame = client, PlayingGame
	if not PlayingGame() or client.paused then return end
	local GetDistance2D = GetDistance2D
	local mathmax, tablesort, AbilityDamageGetDamage, AbilityDamageGetDmgType, Sleep, SleepCheck, SkillShotPredictedXYZ, SkillShotSkillShotXYZ = math.max, table.sort, AbilityDamage.GetDamage, AbilityDamage.GetDmgType, Sleep, SleepCheck, SkillShot.PredictedXYZ, SkillShot.SkillShotXYZ
	local tempmyhero, IsKeyDown, targetFind, entityList, SkillShotBlockableSkillShotXYZ, chainStun = myhero, IsKeyDown, targetFind, entityList, SkillShot.BlockableSkillShotXYZ, chainStun
	local me, player = entityList:GetMyHero(), entityList:GetMyPlayer()
	local mathfloor, mathceil, mathmin, mathsqrt, mathrad, mathabs, mathcos, mathsin = math.floor, math.ceil, math.min, math.sqrt, math.rad, math.abs, math.cos, math.sin
	local LuaEntity, LuaEntityAbility, LuaEntityHero, LuaEntityNPC = LuaEntity, LuaEntityAbility, LuaEntityHero, LuaEntityNPC
	local drawMgr, Animations, SkillShot = drawMgr, Animations, SkillShot
	local config, tostring, myId, gameTime = config, tostring, myId, client.gameTime
	local tempvictim, comboTable, tempattack, tempmove, temptype, itemcomboTable, tempdamageTable, invokerCombo = victim, comboTable, attack, move, type, itemcomboTable, damageTable, invokerCombo
	local abilities = me.abilities	
	
	local ID = me.classId if ID ~= myId then Close() end
	Animations.entities = {}
	local anientiCount = 0
	if me.alive then
		anientiCount = 0
		Animations.entities[1] = me
	end
		
	if not mySpells then	
		local l = #comboTable
		for i = 1, l do
			local table = comboTable[i]
			if table[1] == ID then
				mySpells = table
			end
		end
	end
	
	function DoesHaveModifier(name) return(me:DoesHaveModifier(name)) end
	local KeyPressed = (IsKeyDown(chasekey) or IsKeyDown(config.Retreat) or IsKeyDown(config.Harras)) and not client.chat

	--Target Indicator
	if tempvictim then        
		if KeyPressed then
			local name = tempvictim.name
			if retreat then
				if targetlock then
					statusText.text = "Retreating from "..client:Localize(name).." (LOCKED)"
				else
					statusText.text = "Retreating from "..client:Localize(name)
				end
			elseif harras then
				if targetlock then
					statusText.text = "Harrassing: "..client:Localize(name).." (LOCKED)"
				else
					statusText.text = "Harrassing: "..client:Localize(name)
				end
			else
				if targetlock then
					statusText.text = "Chasing: "..client:Localize(name).." (LOCKED)"
				else
					statusText.text = "Chasing: "..client:Localize(name)
				end
			end
		elseif resettime then
			local name = tempvictim.name
			if targetlock then
				statusText.text = "Locked on "..client:Localize(name).." ("..tostring(mathfloor(-(gameTime-resettime-6)))..")"
			else
				statusText.text = "AutoLocked on "..client:Localize(name).." ("..tostring(mathfloor(-(gameTime-resettime-6)))..")"
			end
		end
		statusText.visible = true
		local sizeX = (F14:GetTextSize(statusText.text).x)/2.5
		statusText.x = client.mouseScreenPosition.x-sizeX
		statusText.y = client.mouseScreenPosition.y-client.screenSize.x*0.01
	else
		retreat = nil
		resettime = nil
		if KeyPressed then
			statusText.visible = true
			if config.TargetLowestHP and not config.TargetClosestToMouse then
				statusText.text = "Looking for a lowest HP target in "..tostring(config.TargetFindRange).." range!"
			elseif not config.TargetLowestHP and config.TargetClosestToMouse then
				statusText.text = "Looking for a closest to mouse target in "..tostring(config.TargetFindRange).." range!"
			else
				statusText.text = "Looking for a target in "..tostring(config.TargetFindRange).." range!"
			end
			local sizeX = (F14:GetTextSize(statusText.text).x)/2.5
			statusText.x = client.mouseScreenPosition.x-sizeX
			statusText.y = client.mouseScreenPosition.y-client.screenSize.x*0.01
		else
			statusText.visible = false
		end
	end
	local enemies = nil
	local disruptor = entityList:GetEntities({classId=CDOTA_Unit_Hero_Disruptor,alive=true,visible=true})[1]
	if ID == CDOTA_Unit_Hero_Disruptor or disruptor then
		enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,team=me:GetEnemyTeam()})
		for i = 1, #enemies do
			local v = enemies[i]
			if not positionsTable[v.handle] then positionsTable[v.handle] = {} end
			local time = gameTime
			if not positionsTable[v.handle][time] then
				positionsTable[v.handle][time] = v.position
			end
			for lasttime,pos in pairs(positionsTable[v.handle]) do
				if (time-lasttime) > 5 then positionsTable[v.handle][lasttime] = nil end
			end
		end
	end
	if ID == CDOTA_Unit_Hero_Rubick and SleepCheck("rubiiick") then
		enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,team=me:GetEnemyTeam()})
		local a5 = me:GetAbility(5)
		local steal = me:FindSpell("rubick_spell_steal")
		local possibleSteal = nil
		local possibleStealfrom = nil
		local glimpse = me:FindSpell("disruptor_glimpse")
		for i = 1, #enemies do
			local v = enemies[i]
			if glimpse and not disruptor then
				if not positionsTable[v.handle] then positionsTable[v.handle] = {} end
				local time = gameTime
				if not positionsTable[v.handle][time] then
					positionsTable[v.handle][time] = v.position
				end
				for lasttime,pos in pairs(positionsTable[v.handle]) do
					if (time-lasttime) > 5 then positionsTable[v.handle][lasttime] = nil end
				end
			end
			anientiCount = anientiCount + 1
			Animations.entities[anientiCount] = v
			local abis = v.abilities
			for z = 1, #abis do
				local spell = abis[z]
				if not spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_PASSIVE) and spell.level > 0 and LastCastedTable[v.handle] ~= spell.name then
					local octa = v:FindItem("item_octarine_core")
					local spellcd = spell:GetCooldown(spell.level)
					if octa then
						spellcd = spellcd*0.75
					end
					spellcd = spellcd-math.max(client.latency/1000,0.1)
					--print(spell.name, spell.cd, spellcd)
					-- if spell.abilityPhase then
						-- print((spell:FindCastPoint() - Animations.getDuration(spell)/1000), 0.1+client.latency/1000) end
					if spell.cd > spellcd and spell.cd > 0 then
						--print("aaaaaaaaa")
						LastCastedTable[v.handle] = spell.name
					elseif spell.abilityPhase and (spell:FindCastPoint() - Animations.getDuration(spell)/1000) < (0.1+client.latency/1000+me:GetTurnTime(v)) then
						LastCastedTable[v.handle] = spell.name
					elseif spell.toggled then
						LastCastedTable[v.handle] = spell.name
					end
				end
			end
			if steal:CanBeCasted() and (a5.cd > 3 or a5.manacost > me.mana or a5.name == "rubick_empty1") then
				if LastCastedTable[v.handle] and a5.name ~= LastCastedTable[v.handle] and LastCastedTable[v.handle] ~= "invoker_invoke" then
					local stolenspell = v:FindSpell(LastCastedTable[v.handle])
					--print(stolenspell.name)
					if not RubickNoSpellSteals[stolenspell.name] then
						if possibleSteal then
							local p1 = RubickSpellSteals[possibleSteal.name] or 0
							local p2 = RubickSpellSteals[stolenspell.name] or 0
							local isUlti = stolenspell.abilityType == LuaEntityAbility.TYPE_ULTIMATE
							if p2 > p1 then
								possibleSteal = stolenspell
								possibleStealfrom = v
							elseif p1 == 0 and isUlti then
								possibleSteal = stolenspell
								possibleStealfrom = v
							elseif p1 == 0 and possibleSteal.manacost < stolenspell.manacost and possibleSteal:GetCooldown(possibleSteal.level) < stolenspell:GetCooldown(stolenspell.level) then
								possibleSteal = stolenspell
								possibleStealfrom = v
							end
						else
							possibleSteal = stolenspell
							possibleStealfrom = v
						end
					end
				end
			end					
		end
		if possibleStealfrom and (not RubickKeepSpellSteals[a5.name] or IsKeyDown(chasekey)) then
			local p1 = RubickSpellSteals[a5.name] or 0
			local p2 = RubickSpellSteals[possibleSteal.name] or 0
			local isUlti = possibleSteal.abilityType == LuaEntityAbility.TYPE_ULTIMATE
			if ((p2 > p1) or (p1 == 0 and isUlti) or (p1 == 0 and a5 and a5.manacost and a5.manacost < possibleSteal.manacost and a5:GetCooldown(a5.level) < possibleSteal:GetCooldown(possibleSteal.level)) or (a5.cd > possibleSteal.cd and IsKeyDown(chasekey))) and GetDistance2D(possibleStealfrom,me) < steal.castRange+100 and me:CanCast() and not me:IsChanneling() and not me:IsInvisible() and not channelactive then
				me:CastAbility(steal,possibleStealfrom)
				Sleep(client.latency+me:GetTurnTime(possibleStealfrom)*1000+100,"casting")
				Sleep(250,"rubiiick")
				return
			end
		end
	end
	local sunstrike = me:FindSpell("invoker_sun_strike")
	if not me:IsInvisible() and not me:IsChanneling() and sunstrike and combo == 0 and SleepCheck("strike") then
		if not enemies then
			enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,team=me:GetEnemyTeam()})
		end
		local Dmg = AbilityDamageGetDamage(sunstrike)
		local killable = nil
		for i = 1, #enemies do		
			local v = enemies[i]
			if not directiontable[v.handle] then directiontable[v.handle] = {v.rotR, gameTime, 0}
			elseif mathabs(directiontable[v.handle][1]-v.rotR) < 0.5 then local time = gameTime - directiontable[v.handle][2] directiontable[v.handle] = {v.rotR, directiontable[v.handle][2], time}
			else directiontable[v.handle] = {v.rotR, gameTime, 0}
			end
			Dmg = v:DamageTaken(Dmg,DAMAGE_PURE,me)
			--print(directiontable[v.handle][3])
			if (v.activity ~= LuaEntityNPC.ACTIVITY_MOVE or directiontable[v.handle][3] >= 2.5) and not v:IsIllusion() and ((KSSS and v.health <= Dmg) or ((v.health < (v.maxHealth/2) or KeyPressed) and stunDuration(v) > (1.7 - 150/v.movespeed) and DSS and ((not v:IsInvul() and not v:DoesHaveModifier("modifier_invoker_tornado") and not v:DoesHaveModifier("modifier_eul_cyclone")) or chainStun(v,1.7+client.latency/1000+(1/Animations.maxCount)*0.5+me:GetTurnTime(v))))) then
				killable = v
				break
			end
			--print(stunDuration(v))
		end
		--print(killable)
		if killable and killable.alive and killable.visible and (sunstrike:CanBeCasted() or ID == CDOTA_Unit_Hero_Invoker) and sunstrike.cd == 0 and sunstrike.manacost < me.mana and me:CanCast() then
			local delay = client.latency+1700+((1 / Animations.maxCount) * 3 * (1 + (1 - 1/ Animations.maxCount)))*1000
			if killable:IsHexed() then delay = delay/2 end
			local pred = SkillShotPredictedXYZ(killable,delay)
			pred = SkillShotPredictedXYZ(killable,delay + me:GetTurnTime(pred)*1000)
			if killable:IsStunned() or killable:IsRooted() then pred = killable.position end
			local position = nil
			local unitnum = 0
			local closest = nil
			local units = {}
			local unitsCount = 0
			local lanecreeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,team=me:GetEnemyTeam(),visible=true})
			local fam = entityList:GetEntities({classId=CDOTA_Unit_VisageFamiliar,team=me:GetEnemyTeam(),visible=true})
			local boar = entityList:GetEntities({classId=CDOTA_Unit_Hero_Beastmaster_Boar,team=me:GetEnemyTeam(),visible=true})
			local forg = entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,team=me:GetEnemyTeam(),visible=true})
			for i = 1, #lanecreeps do local v = lanecreeps[i] if not v:IsInvul() and v.alive and v.spawned then unitsCount = unitsCount + 1 units[unitsCount] = v end end
			for i = 1, #fam do local v = fam[i] if not v:IsInvul() and v.alive then unitsCount = unitsCount + 1 units[unitsCount] = v end end
			for i = 1, #boar do local v = boar[i] if not v:IsInvul() and v.alive then unitsCount = unitsCount + 1 units[unitsCount] = v end end 
			for i = 1, #forg do local v = forg[i] if not v:IsInvul() and v.alive then unitsCount = unitsCount + 1 units[unitsCount] = v end end
			for i = 1, #enemies do local v = enemies[i] if not v:IsInvul() and v.handle ~= killable.handle and v.alive then unitsCount = unitsCount + 1 units[unitsCount] = v end end
			for i = 1, unitsCount do
				local v = units[i]
				--print(v.name,GetDistance2D(v,pred))
				if GetDistance2D(v,pred) < 200 then
					if not position then
						position = v.position
						unitnum = 1
					else
						position = position + v.position
						unitnum = unitnum + 1
					end
					if not closest or GetDistance2D(v,pred) < GetDistance2D(closest,pred) then
						closest = v
					end
				end
			end
			if position then
				position = position/unitnum
				pred = (pred - position) * (200) / GetDistance2D(pred,position) + position
			end
			if pred then
				local invoked = false
				--print(sunstrike,me:GetAbility(4).name,me:GetAbility(5).name,sunstrike.cd,sunstrike.manacost,me.mana)
				if sunstrike and me:GetAbility(4) ~= sunstrike and me:GetAbility(5) ~= sunstrike and sunstrike.cd == 0 and sunstrike.manacost < me.mana then
					prepareSpell("invoker_sun_strike",me,true)
					invoked = true
				end
				if (sunstrike:CanBeCasted() or invoked) and (me:GetAbility(4) == sunstrike or me:GetAbility(5) == sunstrike) then
					me:CastAbility(sunstrike,pred)
				end
				Sleep(250,"strike")
			end
		end
	end
	
	--Custom Menu
	--EarthSpirit
	if ID == CDOTA_Unit_Hero_EarthSpirit then
		if not HUD then
			local hudW = client.screenSize.x*0.18
			local hudH = client.screenSize.y*0.04
			HUD = EasyHUD.new(client.screenSize.x*0.39,client.screenSize.y*0.75,hudW,hudH,"Moones's Combo Script - Earth Spirit Menu",54619000,99333580,true,true)
			HUD:AddCheckbox(HUD.w*0.25,HUD.h*0.25,HUD.h*0.5,HUD.h*0.5,"Use Spells to mouse position",nil,EStoMouse);
			local size = textFont:GetTextSize("Use Spells to mouse position").x + 10
			HUD:AddCheckbox(HUD.h*0.55+HUD.w*0.25+size,HUD.h*0.25,HUD.h*0.5,HUD.h*0.5,"Auto Stones",nil,UseStones);
		end
		EStoMouse = HUD:IsChecked(3)
		UseStones = HUD:IsChecked(4)
	--Invoker
	elseif ID == CDOTA_Unit_Hero_Invoker then
		if not HUD then
			local sizeX = (textFont:GetTextSize("Invoke Spells: ").x)+10
			local sizeY = (textFont:GetTextSize("Invoke Spells: ").y)*1.3
			local hudW = client.screenSize.x*0.18
			local hudH = client.screenSize.y*0.04
			local size1 = (textFont:GetTextSize("Refresher Combos").x)
			local size2 = (textFont:GetTextSize("Combo 1").x)
			if hudW < (sizeX+(sizeY)*10.6+sizeY*2.5+size1+size2+20) then hudW = (sizeX+(sizeY)*10.6+sizeY*2.5+size1+size2+20)*1.02 end
			if hudH < (sizeY*2+hudH*0.50) then hudH = (sizeY*2+hudH*0.50)*1.02 end
			HUD = EasyHUD.new(client.screenSize.x*0.39,client.screenSize.y*0.75,hudW,hudH,"Moones's Combo Script - Invoker Menu",54619000,99333580,true,true)
			local out
			HUD:AddText(HUD.w*0.02,HUD.h*0.25,'Invoke Spells: ')
			coldsnapButtonID, coldsnapButton, out, coldsnapButtonTEXT = HUD:AddButton(sizeX,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeColdsnap)
			coldsnapButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_cold_snap")
			ghostwalkButtonID, ghostwalkButton, out, ghostwalkButtonTEXT = HUD:AddButton(sizeX+(sizeY),HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeGhostwalk)
			ghostwalkButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_ghost_walk")
			icewallButtonID, icewallButton, out, icewallButtonTEXT = HUD:AddButton(sizeX+(sizeY)*2,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeIcewall)
			icewallButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_ice_wall")
			empButtonID, empButton, out, empButtonTEXT = HUD:AddButton(sizeX+(sizeY)*3,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeEmp)
			empButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_emp")
			tornadoButtonID, tornadoButton, out, tornadoButtonTEXT = HUD:AddButton(sizeX+(sizeY)*4,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeTornado)
			tornadoButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_tornado")
			alacrityButtonID, alacrityButton, out, alacrityButtonTEXT = HUD:AddButton(sizeX+(sizeY)*5,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeAlacrity)
			alacrityButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_alacrity")
			sunstrikeButtonID, sunstrikeButton, out, sunstrikeButtonTEXT = HUD:AddButton(sizeX+(sizeY)*6,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeSunstrike)
			sunstrikeButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_sun_strike")
			forgespiritButtonID, forgespiritButton, out, forgespiritButtonTEXT = HUD:AddButton(sizeX+(sizeY)*7,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeForgespirit)
			forgespiritButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_forge_spirit")
			chaosmeteorButtonID, chaosmeteorButton, out, chaosmeteorButtonTEXT = HUD:AddButton(sizeX+(sizeY)*8,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeChaosmeteor)
			chaosmeteorButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_chaos_meteor")
			blastButtonID, blastButton, out, blastButtonTEXT = HUD:AddButton(sizeX+(sizeY)*9,HUD.h*0.25,sizeY,sizeY,0x000000ff,"",invokeBlast)
			blastButton.textureId = drawMgr:GetTextureId("NyanUI/spellicons/invoker_deafening_blast")	
			HUD:AddCheckbox(HUD.w*0.02,HUD.h*0.4+sizeY,sizeY/1.5,sizeY/2,"Auto SunStrike KillSteal",nil,KSSS);
			local sizeKS = (textFont:GetTextSize("Auto SunStrike KillSteal").x)+sizeY+10
			HUD:AddCheckbox(HUD.w*0.02+sizeKS,sizeY+HUD.h*0.4,sizeY/1.5,sizeY/2,"Auto SunStrike on disabled enemy",nil,DSS);		
			buttons[1] = {}
			buttons[5] = {}
			buttons[5].id, buttons[5].obj, buttons[5].out, buttons[5].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25,sizeY + size2,sizeY,0x60615FFF,"Cancel",buttonClick)
			buttons[2] = {}
			buttons[2].id, buttons[2].obj, buttons[2].out, buttons[2].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25,sizeY + size2,sizeY,0x4560ff,"Combo 1",buttonClick)
			buttons[2].obj.visible = false buttons[2].out.visible = false buttons[2].txt.visible = false
			buttons[2].desc = {}
			buttons[2].desc.id, buttons[2].desc.obj = HUD:AddText(sizeX+(sizeY)*10.55+size1+sizeY*2+size2 + 20,HUD.h*0.25 + sizeY/6,"Tornado->EMP->Meteor->Blast->Refresher Orb->Meteor->Blast->EMP->Snap")
			buttons[2].desc.obj.visible = false
			buttons[3] = {}
			buttons[3].id, buttons[3].obj, buttons[3].out, buttons[3].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25 - sizeY*0.95,sizeY + size2,sizeY,0x4560ff,"Combo 2",buttonClick)
			buttons[3].obj.visible = false buttons[3].out.visible = false buttons[3].txt.visible = false
			buttons[3].desc = {}
			buttons[3].desc.id, buttons[3].desc.obj = HUD:AddText(sizeX+(sizeY)*10.55+size1+sizeY*2+size2 + 20,HUD.h*0.25 - sizeY*0.95 + sizeY/6,"Tornado->SS->Meteor->Blast->Refresher Orb->Meteor->Blast->SS->Snap")
			buttons[3].desc.obj.visible = false
			buttons[4] = {}
			buttons[4].id, buttons[4].obj, buttons[4].out, buttons[4].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25 - sizeY*1.95,sizeY + size2,sizeY,0x4560ff,"Combo 3",buttonClick)
			buttons[4].obj.visible = false buttons[4].out.visible = false buttons[4].txt.visible = false
			buttons[4].desc = {}
			buttons[4].desc.id, buttons[4].desc.obj = HUD:AddText(sizeX+(sizeY)*10.55+size1+sizeY*2+size2 + 20,HUD.h*0.25  - sizeY*1.95 + sizeY/6,"Snap->Meteor->Blast->SS->Refresher Orb->Blast->SS->Meteor->Snap")
			buttons[4].desc.obj.visible = false
					
			-- buttons[5] = {}
			-- buttons[5].id, buttons[5].obj, buttons[5].out, buttons[5].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25 - sizeY*2.9,sizeY + size2,sizeY,0x4560ff,"Combo 4",buttonClick)
			-- buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false
			-- buttons[5].desc = {}
			-- buttons[5].desc.id, buttons[5].desc.obj = HUD:AddText(sizeX+(sizeY)*10.55+size1+sizeY*2+size2 + 20,HUD.h*0.25 - sizeY*2.9 + sizeY/6,"Tornado->EMP->Meteor->Blast->Refresher Orb->Meteor->Blast->EMP->Ice Wall")
			-- buttons[5].desc.obj.visible = false
			-- buttons[6] = {}
			-- buttons[6].id, buttons[6].obj, buttons[6].out, buttons[6].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25 - sizeY*3.85,sizeY + size2,sizeY,0x4560ff,"Combo 5",buttonClick)
			-- buttons[6].obj.visible = false buttons[6].out.visible = false buttons[6].txt.visible = false
			-- buttons[6].desc = {}
			-- buttons[6].desc.id, buttons[6].desc.obj = HUD:AddText(sizeX+(sizeY)*10.55+size1+sizeY*2+size2 + 20,HUD.h*0.25 - sizeY*3.85 + sizeY/6,"Tornado->EMP->Meteor->Blast->Refresher Orb->Meteor->Blast->EMP->Ice Wall")
			-- buttons[6].desc.obj.visible = false
			buttons[1].id, buttons[1].obj, buttons[1].out, buttons[1].txt = HUD:AddButton(sizeX+(sizeY)*10.6,HUD.h*0.25,size1 + sizeY + 20,sizeY,0x196100ff,"Refresher Combos",buttonClick)
		else
			local invokemana, spell1, spell2 = me:GetAbility(6).manacost, me:GetAbility(4), me:GetAbility(5)
			local snapmana,empmana,tornadomana,ssmana,meteormana,blastmana,refmana = 100,125,150,175,200,200,375
			local tornado = me:FindSpell("invoker_tornado")
			local coldsnap = me:FindSpell("invoker_cold_snap")
			local refresher = me:FindItem("item_refresher")
			local dagon = me:FindDagon()
			if buttons[1] then
				if combo ~= 0 then 
					if not buttons[5] or not buttons[5].obj then
						local sizeX = (textFont:GetTextSize("Invoke Spells: ").x)+10
						local sizeY = (textFont:GetTextSize("Invoke Spells: ").y)*1.3
						local size1 = (textFont:GetTextSize("Refresher Combos").x)
						local size2 = (textFont:GetTextSize("Combo 1").x)
						buttons[5] = {}
						buttons[5].id, buttons[5].obj, buttons[5].out, buttons[5].txt = HUD:AddButton(sizeX+(sizeY)*10.55+size1+sizeY + 20,HUD.h*0.25,sizeY + size2,sizeY,0x60615FFF,"Cancel",buttonClick)
					else	
						buttons[5].obj.visible = true buttons[5].out.visible = true buttons[5].txt.visible = true 
					end
				elseif buttons[5] and buttons[5].obj then
					buttons[5].obj.visible = false buttons[5].out.visible = false buttons[5].txt.visible = false 
				end
				if combo == 0 and SleepCheck("refbutton") then
					buttons[1].txt.text = "Refresher Combos"
				elseif combo == 1 then
					mySpells = { CDOTA_Unit_Hero_Invoker, invokerCombo[5] }
					local manacost = tornadomana+empmana*2+meteormana*2+blastmana*2+refmana+invokemana*2
					if manacost > me.mana and not comboready then
						buttons[1].txt.text = "Need "..math.floor(manacost-me.mana).." more mana!" Sleep(1000,"refbutton") combo = 0
					elseif spell1.name == "invoker_emp" and spell2.name == "invoker_deafening_blast" and spell2.cd > 0 and refresher.cd > 0 then 
						if SleepCheck("casting2") then prepareSpell("invoker_cold_snap",me) end
					elseif spell1.name == "invoker_cold_snap" and spell2.name == "invoker_emp" and spell1.cd > 0 and spell2.cd > 0 and refresher.cd > 0 and comboready then 
						comboready = false combo = 0
					elseif spell1.name == "invoker_emp" and spell2.name == "invoker_tornado" and spell2.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
					elseif spell1.name == "invoker_chaos_meteor" and spell2.name == "invoker_emp" and spell2.cd > 0 and tornado.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_deafening_blast",me) end
					elseif (not dagon or not dagon:CanBeCasted()) and spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and spell1.cd > 0 and refresher:CanBeCasted() and SleepCheck("refresher") then
						me:CastAbility(refresher)
						Sleep(500,"refresher")
						Sleep(100,"casting")
						return
					elseif spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and spell1.cd > 0 and not refresher:CanBeCasted() then
						if SleepCheck("casting2") then prepareSpell("invoker_emp",me) end
					elseif (spell1.name ~= "invoker_emp" or spell2.name ~= "invoker_tornado") and not comboready then
						buttons[1].txt.text = "Preparing Combo 1"
						if (spell1.name ~= "invoker_emp" and spell2.name ~= "invoker_tornado" and spell1.name ~= "invoker_tornado") or (spell1.name ~= "invoker_emp" and spell2.name == "invoker_tornado") or (spell1.name == "invoker_emp" and spell2.name ~= "invoker_tornado") then
							if SleepCheck("casting2") then prepareSpell("invoker_tornado",me) end
						elseif spell1.name == "invoker_tornado" then
							if SleepCheck("casting2") then prepareSpell("invoker_emp",me) end
						end
					elseif (spell1.name ~= "invoker_emp" or spell2.name ~= "invoker_tornado") and not comboready then
						buttons[1].txt.text = "Preparing Combo 1"
						if (spell1.name ~= "invoker_emp" and spell2.name ~= "invoker_tornado" and spell1.name ~= "invoker_tornado") or (spell1.name ~= "invoker_emp" and spell2.name == "invoker_tornado") or (spell1.name == "invoker_emp" and spell2.name ~= "invoker_tornado") then
							if SleepCheck("casting2") then prepareSpell("invoker_tornado",me) end
						elseif spell1.name == "invoker_tornado" then
							if SleepCheck("casting2") then prepareSpell("invoker_emp",me) end
						end
					else
						if KeyPressed then
							buttons[1].txt.text = "Casting Combo 1!"
						else	
							buttons[1].txt.text = "Combo 1 prepared!"
							comboready = true
						end
					end							
				elseif combo == 2 then
					mySpells = { CDOTA_Unit_Hero_Invoker, invokerCombo[6] }
					local manacost = tornadomana+ssmana*2+meteormana*2+blastmana*2+refmana+invokemana*2
					if manacost > me.mana and not comboready then
						buttons[1].txt.text = "Need "..math.floor(manacost-me.mana).." more mana!" Sleep(1000,"refbutton") combo = 0
					elseif spell1.name == "invoker_sun_strike" and spell2.name == "invoker_deafening_blast" and spell2.cd > 0 and refresher.cd > 0 then 
						if SleepCheck("casting2") then prepareSpell("invoker_cold_snap",me) end
					elseif spell1.name == "invoker_cold_snap" and spell2.name == "invoker_sun_strike" and spell1.cd > 0 and spell2.cd > 0 and refresher.cd > 0 and comboready then 
						comboready = false combo = 0
					elseif spell1.name == "invoker_sun_strike" and spell2.name == "invoker_tornado" and spell2.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
					elseif spell1.name == "invoker_chaos_meteor" and spell2.name == "invoker_sun_strike" and spell2.cd > 0 and tornado.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_deafening_blast",me) end
					elseif (not dagon or not dagon:CanBeCasted()) and spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and spell1.cd > 0 and refresher:CanBeCasted() and SleepCheck("refresher") then
						me:CastAbility(refresher)
						Sleep(500,"refresher")
						Sleep(100,"casting")
						return
					elseif spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and spell1.cd > 0 and not refresher:CanBeCasted() then
						if SleepCheck("casting2") then prepareSpell("invoker_sun_strike",me) end
					elseif (spell1.name ~= "invoker_sun_strike" or spell2.name ~= "invoker_tornado") and not comboready then
						buttons[1].txt.text = "Preparing Combo 2"
						if (spell1.name ~= "invoker_sun_strike" and spell2.name ~= "invoker_tornado" and spell1.name ~= "invoker_tornado") or (spell1.name ~= "invoker_sun_strike" and spell2.name == "invoker_tornado") or (spell1.name == "invoker_sun_strike" and spell2.name ~= "invoker_tornado") then
							if SleepCheck("casting2") then prepareSpell("invoker_tornado",me) end
						elseif spell1.name == "invoker_tornado" then
							if SleepCheck("casting2") then prepareSpell("invoker_sun_strike",me) end
						end
					elseif (spell1.name ~= "invoker_sun_strike" or spell2.name ~= "invoker_tornado") and not comboready then
						buttons[1].txt.text = "Preparing Combo 2"
						if (spell1.name ~= "invoker_sun_strike" and spell2.name ~= "invoker_tornado" and spell1.name ~= "invoker_tornado") or (spell1.name ~= "invoker_sun_strike" and spell2.name == "invoker_tornado") or (spell1.name == "invoker_sun_strike" and spell2.name ~= "invoker_tornado") then
							if SleepCheck("casting2") then prepareSpell("invoker_tornado",me) end
						elseif spell1.name == "invoker_tornado" then
							if SleepCheck("casting2") then prepareSpell("invoker_sun_strike",me) end
						end
					else
						if KeyPressed then
							buttons[1].txt.text = "Casting Combo 2!"
						else	
							buttons[1].txt.text = "Combo 2 prepared!"
							comboready = true
						end
					end	
				elseif combo == 3 then
					--Snap->Meteor->Blast->SS->Refresher Orb->Blast->SS->Meteor->Snap
					mySpells = { CDOTA_Unit_Hero_Invoker, invokerCombo[7] }
					local manacost = snapmana+meteormana*2+ssmana*2+blastmana+refmana+invokemana*2
					if manacost > me.mana and not comboready then
						buttons[1].txt.text = "Need "..math.floor(manacost-me.mana).." more mana!" Sleep(1000,"refbutton") combo = 0
					elseif spell1.name == "invoker_cold_snap" and spell2.name == "invoker_chaos_meteor" and spell1.cd > 0 and spell2.cd > 0 and refresher.cd > 0 and comboready then 
						comboready = false combo = 0
					elseif spell1.name == "invoker_chaos_meteor" and spell2.name == "invoker_cold_snap" and spell2.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_deafening_blast",me) end
					elseif spell1.name == "invoker_chaos_meteor" and spell2.name == "invoker_sun_strike" and spell2.cd > 0 and not refresher:CanBeCasted() then
						if SleepCheck("casting2") then prepareSpell("invoker_cold_snap",me) end
					elseif spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and coldsnap.cd > 0 then
						if SleepCheck("casting2") then prepareSpell("invoker_sun_strike",me) end
					elseif spell1.name == "invoker_sun_strike" and spell2.name == "invoker_deafening_blast" and spell2.cd > 0 and not refresher:CanBeCasted() then
						if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
					elseif (not dagon or not dagon:CanBeCasted()) and spell1.name == "invoker_sun_strike" and spell2.name == "invoker_deafening_blast" and spell2.cd > 0 and spell1.cd > 0 and refresher:CanBeCasted() and SleepCheck("refresher") then
						me:CastAbility(refresher)
						Sleep(500,"refresher")
						Sleep(100,"casting")
						return
					elseif spell1.name == "invoker_deafening_blast" and spell2.name == "invoker_chaos_meteor" and spell2.cd > 0 and spell1.cd > 0 and not refresher:CanBeCasted() then
						if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
					elseif (spell1.name ~= "invoker_chaos_meteor" or spell2.name ~= "invoker_cold_snap") and not comboready then
						buttons[1].txt.text = "Preparing Combo 3"
						if (spell1.name ~= "invoker_chaos_meteor" and spell2.name ~= "invoker_cold_snap" and spell1.name ~= "invoker_cold_snap") or (spell1.name ~= "invoker_chaos_meteor" and spell2.name == "invoker_cold_snap") or (spell1.name == "invoker_chaos_meteor" and spell2.name ~= "invoker_cold_snap") then
							if SleepCheck("casting2") then prepareSpell("invoker_cold_snap",me) end
						elseif spell1.name == "invoker_cold_snap" then
							if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
						end
					elseif (spell1.name ~= "invoker_chaos_meteor" or spell2.name ~= "invoker_cold_snap") and not comboready then
						buttons[1].txt.text = "Preparing Combo 3"
						if (spell1.name ~= "invoker_chaos_meteor" and spell2.name ~= "invoker_cold_snap" and spell1.name ~= "invoker_cold_snap") or (spell1.name ~= "invoker_chaos_meteor" and spell2.name == "invoker_cold_snap") or (spell1.name == "invoker_chaos_meteor" and spell2.name ~= "invoker_cold_snap") then
							if SleepCheck("casting2") then prepareSpell("invoker_cold_snap",me) end
						elseif spell1.name == "invoker_cold_snap" then
							if SleepCheck("casting2") then prepareSpell("invoker_chaos_meteor",me) end
						end
					else
						if KeyPressed then
							buttons[1].txt.text = "Casting Combo 3!"
						else	
							buttons[1].txt.text = "Combo 3 prepared!"
							comboready = true
						end
					end	
				end
			end
			local mousePosition = client.mouseScreenPosition
			local hovered = false
			for i = 2, 4 do
				local v = buttons[i]
				local b = v.obj
				--print(b and b.visible and IsInside(mousePosition.x,mousePosition.y,b.x,b.y,b.w,b.h))
				if b and b.visible and v.desc and IsInside(mousePosition.x,mousePosition.y,b.x,b.y,b.w,b.h) then
					buttons[i].desc.obj.visible = true
					hovered = true
				elseif b and v.desc then
					buttons[i].desc.obj.visible = false
				end
				if i == 2 then
					local manacost = tornadomana+empmana*2+meteormana*2+blastmana*2+refmana+invokemana*2
					if me.mana < manacost then
						buttons[i].obj.color = 0x60615FFF
						buttons[i].txt.color = 0x60615FFF
						buttons[i].desc.obj.text = "Need "..math.floor(manacost-me.mana).." more mana!"
					else
						buttons[i].desc.obj.text = "Tornado->EMP->Meteor->Blast->Refresher Orb->Meteor->Blast->EMP->Snap"
						buttons[i].obj.color = 0x4560ff
						buttons[i].txt.color = -1
					end
				elseif i == 3 then
					local manacost = tornadomana+ssmana*2+meteormana*2+blastmana*2+refmana+invokemana*2
					if me.mana < manacost then
						buttons[i].obj.color = 0x60615FFF
						buttons[i].txt.color = 0x60615FFF
						buttons[i].desc.obj.text = "Need "..math.floor(manacost-me.mana).." more mana!"
					else
						buttons[i].desc.obj.text = "Tornado->SS->Meteor->Blast->Refresher Orb->Meteor->Blast->SS->Snap"
						buttons[i].obj.color = 0x4560ff
						buttons[i].txt.color = -1
					end
				elseif i == 4 then
					local manacost = snapmana+meteormana*2+ssmana*2+blastmana+refmana+invokemana*2
					if me.mana < manacost then
						buttons[i].obj.color = 0x60615FFF
						buttons[i].txt.color = 0x60615FFF
						buttons[i].desc.obj.text = "Need "..math.floor(manacost-me.mana).." more mana!"
					else
						buttons[i].desc.obj.text = "Snap->Meteor->Blast->SS->Refresher Orb->Blast->SS->Meteor->Snap"
						buttons[i].obj.color = 0x4560ff
						buttons[i].txt.color = -1
					end
				end
			end
			if hovered then statusText.visible = false elseif KeyPressed then statusText.visible = true end
		end
		
		KSSS = HUD:IsChecked(14)
		DSS = HUD:IsChecked(15)
		for i = 1, #abilities do
			local v = abilities[i]
			if v.name == "invoker_sun_strike" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					sunstrikeButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(sunstrikeButtonTEXT.text).x)
						sunstrikeButtonTEXT.x = sunstrikeButton.x + sunstrikeButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(sunstrikeButtonTEXT.text).x)
						sunstrikeButtonTEXT.x = sunstrikeButton.x + sunstrikeButton.h/2 - sizeX/2
					end
				else
					sunstrikeButtonTEXT.text = ""
				end
			elseif v.name == "invoker_cold_snap" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					coldsnapButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(coldsnapButtonTEXT.text).x)
						coldsnapButtonTEXT.x = coldsnapButton.x + coldsnapButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(coldsnapButtonTEXT.text).x)
						coldsnapButtonTEXT.x = coldsnapButton.x + coldsnapButton.h/2 - sizeX/2
					end
				else
					coldsnapButtonTEXT.text = ""
				end
			elseif v.name == "invoker_tornado" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					tornadoButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(tornadoButtonTEXT.text).x)
						tornadoButtonTEXT.x = tornadoButton.x + tornadoButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(tornadoButtonTEXT.text).x)
						tornadoButtonTEXT.x = tornadoButton.x + tornadoButton.h/2 - sizeX/2
					end
				else
					tornadoButtonTEXT.text = ""
				end
			elseif v.name == "invoker_deafening_blast" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					blastButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(blastButtonTEXT.text).x)
						blastButtonTEXT.x = blastButton.x + blastButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(blastButtonTEXT.text).x)
						blastButtonTEXT.x = blastButton.x + blastButton.h/2 - sizeX/2
					end
				else
					blastButtonTEXT.text = ""
				end
			elseif v.name == "invoker_forge_spirit" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					forgespiritButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(forgespiritButtonTEXT.text).x)
						forgespiritButtonTEXT.x = forgespiritButton.x + forgespiritButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(forgespiritButtonTEXT.text).x)
						forgespiritButtonTEXT.x = forgespiritButton.x + forgespiritButton.h/2 - sizeX/2
					end
				else
					forgespiritButtonTEXT.text = ""
				end
			elseif v.name == "invoker_ice_wall" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					icewallButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(icewallButtonTEXT.text).x)
						icewallButtonTEXT.x = icewallButton.x + icewallButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(icewallButtonTEXT.text).x)
						icewallButtonTEXT.x = icewallButton.x + icewallButton.h/2 - sizeX/2
					end
				else
					icewallButtonTEXT.text = ""
				end
			elseif v.name == "invoker_chaos_meteor" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					chaosmeteorButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(chaosmeteorButtonTEXT.text).x)
						chaosmeteorButtonTEXT.x = chaosmeteorButton.x + chaosmeteorButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(chaosmeteorButtonTEXT.text).x)
						chaosmeteorButtonTEXT.x = chaosmeteorButton.x + chaosmeteorButton.h/2 - sizeX/2
					end
				else
					chaosmeteorButtonTEXT.text = ""
				end
			elseif v.name == "invoker_alacrity" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					alacrityButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(alacrityButtonTEXT.text).x)
						alacrityButtonTEXT.x = alacrityButton.x + alacrityButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(alacrityButtonTEXT.text).x)
						alacrityButtonTEXT.x = alacrityButton.x + alacrityButton.h/2 - sizeX/2
					end
				else
					alacrityButtonTEXT.text = ""
				end
			elseif v.name == "invoker_emp" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					empButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(empButtonTEXT.text).x)
						empButtonTEXT.x = empButton.x + empButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(empButtonTEXT.text).x)
						empButtonTEXT.x = empButton.x + empButton.h/2 - sizeX/2
					end
				else
					empButtonTEXT.text = ""
				end
			elseif v.name == "invoker_ghost_walk" then
				if v.cd > 0 then
					local cd = mathfloor(v.cd)+1
					ghostwalkButtonTEXT.text = tostring(cd)
					if cd >= 10 then
						local sizeX = (textFont:GetTextSize(ghostwalkButtonTEXT.text).x)
						ghostwalkButtonTEXT.x = ghostwalkButton.x + ghostwalkButton.h/2 - sizeX/2
					else
						local sizeX = (textFont:GetTextSize(ghostwalkButtonTEXT.text).x)
						ghostwalkButtonTEXT.x = ghostwalkButton.x + ghostwalkButton.h/2 - sizeX/2
					end
				else
					ghostwalkButtonTEXT.text = ""
				end
			end
		end
	end	
		
	if me.health < me.maxHealth*0.4 and not retreat and tempvictim then
		if not statusText2.visible then
			statusText2.text = "Hold "..string.char(config.Retreat).." to retreat!"
			local sizeX = (F14:GetTextSize(statusText2.text).x)/2
			statusText2.x = -sizeX
			statusText2.y = -60*monitor
			statusText2.entity = me
			statusText2.entityPosition = Vector(0,0,me.healthbarOffset)
			statusText2.visible = true
		end
	elseif statusText2.visible then
		statusText2.visible = false
	end
	
	if SleepCheck("channel") then
		for i = 1, #abilities do
			local v = abilities[i]
			local c = v:GetChannelTime(v.level) or 0
			if v.abilityPhase and c > 0 then
				channelactive = true
				Sleep(v:FindCastPoint()*1000+100,"casting")
				Sleep(v:FindCastPoint()*1000+100,"channel")
				return
			end
		end
	end
	
	if ID == CDOTA_Unit_Hero_Shredder and SleepCheck("Shredder") then
		local trees = Trees
		for i = 1, #trees do
			local v = trees[i]
			if v.cutted and gameTime - v.cutTime > 300 then
				Trees[i].cutted = false
				Trees[i].cutTime = nil
			end
		end
		Sleep(500,"Shredder")
	end
	
	if not tempmyhero then	
		myhero = MyHero(me)
	else				
		local range = tempmyhero:GetAttackRange()
		if KeyPressed then	
			if IsKeyDown(config.Retreat) then retreat = true combo = 0 else retreat = false end
			if IsKeyDown(config.Harras) then harras = true else harras = false end
			local CanMove, tempvictimVisible, tempvictimAlive = Animations.CanMove(me), (tempvictim and tempvictim.visible), (tempvictim and tempvictim.alive)
			local a1,a2,a3,a4,a5,a6 = abilities[1],abilities[2],abilities[3],abilities[4],abilities[5],abilities[6]
			--print(a1.name,a2.name,a3.name,a4.name,a5.name,a6.name)
			if resettime then
				resettime = nil	
			end
			
			if not tempvictim or ((not tempvictim.alive or tempvictim.health < 0) and (not targetlock or tempvictim.visible)) then
				if tempvictim then
					indicate[tempvictim.playerId].visible = false
				end
				victim = nil
				tempvictim = nil
				targetlock = false
				enemyHP = nil
			end
			
			if config.AutoLock then targetlock = true end
			
			local victimdistance = 999999
			--Update my position
			if SleepCheck("blink") then
				mePosition = me.position
			end
			if tempvictim then victimdistance = GetDistance2D(mePosition,tempvictim) end
			--local closeEnemies = entityList:GetEntities(function (v) return (v.type == LuaEntity.TYPE_HERO and not v:IsIllusion() and v.alive and v.team ~= me.team and v ~= tempvictim) end)
			local blink = me:FindItem("item_blink") or me:FindSpell("antimage_blink") or me:FindSpell("queenofpain_blink")
			
			--Get Target
			if (not targetlock or not tempvictim or tempvictimVisible or victimdistance > mathmax(range,800)) and (CanMove or not start or (not tempvictim or (victimdistance > mathmax(range+50,500) and tempvictimVisible) or not tempvictimAlive or tempvictim.health < 0)) then
				start = true
				local type = "phys"
				if ID == CDOTA_Unit_Hero_Invoker or ID == CDOTA_Unit_Hero_EarthSpirit or ID == CDOTA_Unit_Hero_Lina or ID == CDOTA_Unit_Hero_Lion or ID == CDOTA_Unit_Hero_Zuus or ID == CDOTA_Unit_Hero_Tinker then type = "magic" end
				local lowestHP = targetFind:GetLowestEHP(config.TargetFindRange, type)
				if config.TargetLowestHP and lowestHP and (not tempvictim or ((tempvictim.creep or (GetDistance2D(me,tempvictim) > 600 and tempvictimVisible) or not tempvictimAlive or tempvictim.health < 0 or (lowestHP.health < tempvictim.health and tempvictimVisible)) and GetDistance2D(tempvictim,me) > range+100)) and SleepCheck("victim") then			
					victim = lowestHP
					enemyHP = victim.health
				end
				tempvictim = victim
				if (config.TargetClosestToMouse and tempvictim and GetDistance2D(tempvictim,me) > range+100 and tempvictimVisible) or (config.TargetClosestToMouse and not config.TargetLowestHP and (not tempvictim or tempvictimVisible)) or (tempvictim and (GetDistance2D(tempvictim,me) > range+100 or not tempvictimVisible)) then
					local closest = targetFind:GetClosestToMouse(me,config.TargetFindRange)
					if closest and (config.TargetClosestToMouse or (GetDistance2D(me,closest) < GetDistance2D(me,tempvictim) and GetDistance2D(me,tempvictim) > range+100 and (not blink or (not blink:CanBeCasted() and blink.cd > 3)))) then 
						victim = closest
						enemyHP = victim.health
					end
				end
				tempvictim = victim
				-- if not tempvictim or not tempvictim.hero then 					
					-- local creeps = entityList:GetEntities(function (v) return (v.courier or (v.creep and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Neutral and v.spawned) or v.classId == CDOTA_BaseNPC_Tower or v.classId == CDOTA_BaseNPC_Venomancer_PlagueWard or v.classId == CDOTA_BaseNPC_Warlock_Golem or (v.classId == CDOTA_BaseNPC_Creep_Lane and v.spawned) or (v.classId == CDOTA_BaseNPC_Creep_Siege and v.spawned) or v.classId == CDOTA_Unit_VisageFamiliar or v.classId == CDOTA_Unit_Undying_Zombie or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.classId == CDOTA_Unit_Hero_Beastmaster_Boar or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_BaseNPC_Creep) and v.team ~= me.team and v.alive and v.health > 0 and GetDistance2D(v,me) <= mathmax(range*2+50,500) end)
					-- if GetType(creeps) == "Table" then
						-- tablesort(creeps, function (a,b) return a.health < b.health end)
						-- victim = creeps[1]
					-- end
				-- end
				-- tempvictim = victim
			end
			
			if tempvictim then
				anientiCount = 2
				Animations.entities[2] = tempvictim
				if indicate[tempvictim.playerId] then
					if not indicate[tempvictim.playerId].visible then
						 indicate[tempvictim.playerId].visible = true
					end
				else
					local xx = GetXX(tempvictim)
					x,y,h,w = xx-20+x_*tempvictim.playerId,0,x_,35*monitor
					indicate[tempvictim.playerId] = drawMgr:CreateRect(x,y,h,w,9911861800) 
				end
				for i = 1, 9 do	
					local v = indicate[i]
					if v and v.visible and i ~= tempvictim.playerId then
						indicate[i].visible = false
					end
				end
			end
			
			local prediction 
			if tempvictim and tempvictimVisible then
				prediction = SkillShotPredictedXYZ(tempvictim,500+client.latency)	
			elseif tempvictim then prediction = SkillShot.BlindSkillShotXYZ(me,tempvictim,1100,0.5+client.latency/1000) end
			if not prediction and tempvictim and tempvictimVisible then prediction = tempvictim.position end
			--print(prediction)
			local movespeed
			if tempvictim then movespeed = tempvictim:GetMovespeed() end
			if tempvictim and tempvictim.visible then
				if tempvictim.activity == LuaEntityNPC.ACTIVITY_MOVE then
					local pred = SkillShot.PredictedXYZ(tempvictim,1000)
					if pred then
						movespeed = GetDistance2D(tempvictim,pred)
					end
				end
			end
			local facing
			if tempvictim then
				facing = ((mathmax(mathabs(FindAngleR(me) - mathrad(FindAngleBetween(me, tempvictim))) - 0.20, 0)) == 0)
			end
			--Special Combo: Controlling Summons/Neutrals
			-- local summons = entityList:GetEntities(function (v) return ((v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_Unit_VisageFamiliar or 
			-- v.classId == CDOTA_BaseNPC_Creep_Neutral or v.classId == CDOTA_Unit_Hero_Beastmaster_Beasts or v.classId == CDOTA_Unit_Broodmother_Spiderling or v.name == "npc_dota_necronomicon_archer_1" or v.name == "npc_dota_necronomicon_archer_2" or v.name == "npc_dota_necronomicon_archer_3" or v.name == "npc_dota_necronomicon_warrior_1" or 
			-- v.name == "npc_dota_necronomicon_warrior_2" or v.name == "npc_dota_necronomicon_warrior_3" or (v.type == LuaEntity.TYPE_HERO and v:IsIllusion())) and v.alive and v.controllable and v.team == me.team) end)
			local entities = {}
			local spider,boar,forg,familiars,bear,necorwarriors,spirit,sigil,treants,golems = {},{},{},{},nil,{},nil,nil,{},{}
			if ID == CDOTA_Unit_Hero_Broodmother or ID == CDOTA_Unit_Hero_Rubick then
				spider = entityList:GetEntities({classId=CDOTA_Unit_Broodmother_Spiderling,alive=true,visible=true,team=me.team})
			elseif ID == CDOTA_Unit_Hero_Beastmaster or ID == CDOTA_Unit_Hero_Rubick then
				boar = entityList:GetEntities({classId=CDOTA_Unit_Hero_Beastmaster_Beasts,alive=true,visible=true,team=me.team})
			elseif ID == CDOTA_Unit_Hero_Invoker or ID == CDOTA_Unit_Hero_Rubick then
				forg = entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,alive=true,visible=true,team=me.team})
			elseif ID == CDOTA_Unit_Hero_Visage or ID == CDOTA_Unit_Hero_Rubick then
				familiars = entityList:GetEntities({classId=CDOTA_Unit_VisageFamiliar,alive=true,visible=true,team=me.team})
			elseif ID == CDOTA_Unit_Hero_LoneDruid or ID == CDOTA_Unit_Hero_Rubick then
				bear = entityList:GetEntities({classId=CDOTA_Unit_SpiritBear,alive=true,team=me.team})[1]
			-- elseif ID == CDOTA_Unit_Hero_Elder_Titan then
				-- spirit = entityList:GetEntities({classId=CDOTA_Unit_Elder_Titan_AncestralSpirit, alive=true, team=me.team, visible=true})[1]
			elseif ID == CDOTA_Unit_Hero_Tusk or ID == CDOTA_Unit_Hero_Rubick then
				sigil = entityList:GetEntities({classId=CDOTA_BaseNPC_Tusk_Sigil,alive=true,team=me.team})[1]
			--elseif ID == CDOTA_Unit_Hero_Furion or ID == CDOTA_Unit_Hero_Rubick then
				--treants = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep,alive = true, visible = true, team = me.team})	
			elseif ID == CDOTA_Unit_Hero_Warlock or ID == CDOTA_Unit_Hero_Rubick then
				golems = entityList:GetEntities({classId=CDOTA_BaseNPC_Warlock_Golem,alive=true,team=me.team,visible=true})
			end
			local tornado = entityList:GetEntities(function (v) return (v.name == "npc_dota_enraged_wildkin_tornado" and v.alive and v.visible and v.team == me.team and v.controllable) end)[1]
			local heroes = entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,visible=true,illusion=true,team=me.team})
			local neutral = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Neutral,alive=true,visible=true,team=me.team})
			if me:FindItem("item_necronomicon_2") or me:FindItem("item_necronomicon_1") or me:FindItem("item_necronomicon_3") then
				necorwarriors = entityList:GetEntities(function (v) return ((v.name == "npc_dota_necronomicon_archer_1" or v.name == "npc_dota_necronomicon_archer_2" or v.name == "npc_dota_necronomicon_archer_3" or v.name == "npc_dota_necronomicon_warrior_1" or 
				v.name == "npc_dota_necronomicon_warrior_2" or v.name == "npc_dota_necronomicon_warrior_3") and v.alive and v.visible and v.team == me.team and v.controllable) end)
			end
			local creeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep, team=me.team, alive=true})
			local entitiesCount = 0
			for i = 1, #heroes do local v = heroes[i] if v.controllable and v:IsIllusion() then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #necorwarriors do local v = necorwarriors[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #spider do local v = spider[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #boar do local v = boar[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #forg do local v = forg[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #neutral do local v = neutral[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #familiars do local v = familiars[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #treants do local v = treants[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end
			for i = 1, #golems do local v = golems[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end		
			for i = 1, #creeps do local v = creeps[i] if v.controllable then entitiesCount = entitiesCount + 1 entities[entitiesCount] = v end end		
			if bear then entitiesCount = entitiesCount + 1 entities[entitiesCount] = bear end
			if sigil then entitiesCount = entitiesCount + 1 entities[entitiesCount] = sigil end
			--if spirit then entitiesCount = entitiesCount + 1 entities[entitiesCount] = spirit end
			if tornado then entitiesCount = entitiesCount + 1 entities[entitiesCount] = tornado end
			if #entities > 0 then
				local l = #itemcomboTable
				for i = 1, #entities do
					local v = entities[i]
					if v.classId ~= CDOTA_Unit_Elder_Titan_AncestralSpirit and v.name ~= "npc_dota_enraged_wildkin_tornado" and v.classId ~= CDOTA_BaseNPC_Tusk_Sigil then
						anientiCount = anientiCount + 1
						Animations.entities[anientiCount] = v
					end
					local hand = v.handle
					if v.classId == CDOTA_Unit_SpiritBear and tempvictim and not stackTable[v.handle] then
						for i = 1, l do
							local data = itemcomboTable[i]
							local itemname = data[1] or data
							local item = v:FindItem(itemname)
							if item and item:CanBeCasted() then
								if not tempdamageTable[itemname] then
									damageTable[itemname] = {AbilityDamageGetDamage(item)}
									tempdamageTable = damageTable
								end
								local Dmg = tempdamageTable[itemname][1]
								local type = AbilityDamageGetDmgType(item)
								if Dmg then
									Dmg = tempvictim:DamageTaken(Dmg,type,v)
								end
								local go = true
								if itemname == "item_phase_boots" then Dmg = nil end
								if itemname == "item_dust" and not CanGoInvis(tempvictim) then go = false end
								if (itemname == "item_diffusal_blade" or itemname == "item_diffusal_blade_2") then
									if not ( tempvictim:DoesHaveModifier("modifier_ghost_state") or tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") or tempvictim:DoesHaveModifier("modifier_omninight_guardian_angel")) then 
										go = false 
									end
								end
								if itemname == "item_arcane_boots" and (v.maxMana - v.mana) < 135 then go = false end
								if (not tempvictim:IsMagicImmune() or type == DAMAGE_PHYS) and not tempvictim:DoesHaveModifier("modifier_"..itemname) and not tempvictim:DoesHaveModifier("modifier_"..itemname.."_debuff") and go and 
								SleepCheck(itemname) and (not data[2] or chainStun(tempvictim,0) or (itemname == "item_blade_mail" and chainStun(tempvictim,0,"modifier_axe_berserkers_call"))) and 
								(not Dmg or data[2] or Dmg/4 < enemyHP or GetDistance2D(v,tempvictim) > v.attackRange+300) and ((GetDistance2D(v,tempvictim) > v.attackRange+300) or (Dmg and Dmg > 0) or ((not Dmg or Dmg < 1) and enemyHP > 100) or itemname == "item_phase_boots") then
									local cast
									local delay = 0
									if item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) and go then
										if ((item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL))) then
											cast = v:SafeCastAbility(item,v)
										elseif (item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) or item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_CUSTOM) or item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL)) and not tempvictim:IsInvul() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_brewmaster_storm_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and victimdistance < mathmax(item.castRange+50, 500) then
											cast = v:SafeCastAbility(item,tempvictim)
											delay = delay + v:GetTurnTime(tempvictim)*1000
										end
									elseif item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) and (not data[3] or GetDistance2D(v,tempvictim) < data[3]) then
										cast = v:SafeCastAbility(item)
									elseif item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) or item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_AOE) then
										if item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) then
											cast = v:SafeCastAbility(item,v)
										else
											delay = delay + v:GetTurnTime(tempvictim)*1000
											local delay2 = delay + client.latency
											if data[2] then delay2 = delay2 + data[2]*1000 end
											local speed = item:GetSpecialData("speed")
											local prediction
											if not speed then 
												prediction = SkillShotPredictedXYZ(tempvictim,delay2)
											else
												prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay2,speed)
											end
											if prediction and GetDistance2D(prediction,mePosition) < item.castRange+150 then
												delay = delay + (mathmax(GetDistance2D(prediction,mePosition)-50-item.castRange,0)/v.movespeed)*1000
												cast = v:SafeCastAbility(item,prediction)
											end
										end
									end
									if cast then
										Sleep(delay+client.latency+100, itemname)
										if Dmg then
											enemyHP = enemyHP - Dmg
										end
										return
									end
								end
							end
						end	
					end
					if v:CanCast() and not v:IsChanneling() then
						local abs = v.abilities
						for i = 1, #abs do
							local abi = abs[i]
							if abi:CanBeCasted() and SleepCheck(abi.name) then
								local name = abi.name
								if tempvictim and (name == "necronomicon_archer_mana_burn" or name == "satyr_trickster_purge" or name == "satyr_soulstealer_mana_burn" or name == "satyr_hellcaller_shockwave" or name == "harpy_storm_chain_lightning" or ((name == "mud_golem_hurl_boulder" or name == "dark_troll_warlord_ensnare") and chainStun(tempvictim,abi:FindCastPoint()+(100/Animations.maxCount)*0.001 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))+v:GetTurnTime(tempvictim)+client.latency*0.01))) then
									v:CastAbility(abi,tempvictim)
									Sleep(abi:FindCastPoint()*1000+v:GetTurnTime(tempvictim)*1000+client.latency,hand.."moving")
									Sleep(600,name)
									if name == "dark_troll_warlord_ensnare" then
										Sleep(abi:FindCastPoint()*1000+client.latency+1000+v:GetTurnTime(tempvictim)*1000,"stun")
									elseif name == "mud_golem_hurl_boulder" then
										Sleep(abi:FindCastPoint()*1000+client.latency+GetDistance2D(v,tempvictim)/800+200+v:GetTurnTime(tempvictim)*1000,"stun")
									end
								elseif tempvictim and name == "enraged_wildkin_tornado" and prediction and GetDistance2D(v,tempvictim) < abi.castRange+100 then
									v:CastAbility(abi,prediction)
									Sleep(abi:FindCastPoint()*1000+v:GetTurnTime(tempvictim)*1000+client.latency+200,hand.."moving")
									Sleep(600,name)
								elseif name == "ogre_magi_frost_armor" then
									local allies = entityList:GetEntities(function (x) return (x.hero and x.alive and not x:IsIllusion() and GetDistance2D(v,x) < 1000 and not x:DoesHaveModifier("modifier_ogre_magi_frost_armor")) end)
									local ally = nil
									if #allies > 0 then
										tablesort(allies, function(a,b) return a.health < b.health end)
										ally = allies[1]
									end
									if ally then
										v:CastAbility(abi,ally)
										Sleep(abi:FindCastPoint()*1000+v:GetTurnTime(ally)*1000+client.latency+500,hand.."moving")
										Sleep(600,name)
									end
								elseif tempvictim and (name == "polar_furbolg_ursa_warrior_thunder_clap" or name == "centaur_khan_war_stomp" or name == "big_thunder_lizard_slam") and chainStun(tempvictim,abi:FindCastPoint()+(100/Animations.maxCount)*0.01 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))+client.latency*0.001) then
									local radius = abi:GetSpecialData("radius")
									if prediction and GetDistance2D(v,prediction) < radius-50 then
										v:CastAbility(abi)
										Sleep(abi:FindCastPoint()*1000+client.latency,hand.."moving")
										Sleep(600,name)
										if name == "centaur_khan_war_stomp" then
											Sleep(abi:FindCastPoint()*1000+client.latency+1000,"stun")
										end
									elseif SleepCheck(hand.."moving") and prediction then
										v:Move(prediction)
										Sleep(200,hand.."moving")
									end
								elseif tempvictim and name == "visage_summon_familiars_stone_form" then
									if chainStun(tempvictim,0.5+client.latency*0.001+(100/Animations.maxCount)*0.01 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))) then
										local asd = v:FindModifier("modifier_visage_summon_familiars_damage_charge")
										--print(asd.stacks)
										if (not asd or not asd.stacks or asd.stacks == 0) or retreat or (v.health < 8 and GetDistance2D(tempvictim,v) <= tempvictim.attackRange) or tempvictim:IsAttackImmune() then
											--print("ddd")
											local radius = abi:GetSpecialData("stun_radius")
											local prediction = SkillShotPredictedXYZ(tempvictim,500+client.latency+(100/Animations.maxCount)*100 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))*1000)
											if prediction and GetDistance2D(v,prediction) < radius-50 then
												v:CastAbility(abi)
												Sleep(500+client.latency,hand.."moving")
												Sleep(600,name)
												Sleep(500+client.latency+1000,"stun")
											elseif SleepCheck(hand.."moving") and prediction then
												v:Move(prediction)
												Sleep(200,hand.."moving")
											end
										end
									elseif SleepCheck(hand.."moving") and GetDistance2D(v,tempvictim) > 25 then
										v:Move(tempvictim.position)
										Sleep(200,hand.."moving")
									end									
								elseif tempvictim and name == "elder_titan_echo_stomp_spirit" and chainStun(tempvictim,abi:FindCastPoint()+client.latency*0.001+abi:GetChannelTime(abi.level)) then
									local radius = abi:GetSpecialData("radius")
									if GetDistance2D(v,tempvictim) < radius then
										v:CastAbility(abi)
										Sleep(abi:FindCastPoint()*1000+client.latency,hand.."moving")
										Sleep(600,name)
										Sleep(500,"casting")
										channelactive = true
									end
								elseif tempvictim and name == "big_thunder_lizard_frenzy" and GetDistance2D(tempvictim,v) <= 700 then
									v:CastAbility(abi)
									Sleep(abi:FindCastPoint()*1000+client.latency,hand.."moving")
									Sleep(600,name)
								end
							end
						end
					end
					if v.classId ~= CDOTA_Unit_Elder_Titan_AncestralSpirit and v.name ~= "npc_dota_enraged_wildkin_tornado" and v.classId ~= CDOTA_BaseNPC_Tusk_Sigil and not v:IsChanneling() then
						if Animations.GetAttackTime(v) > 0 and tempvictim and not Animations.CanMove(v) and GetDistance2D(v,tempvictim) <= mathmax(v.attackRange*2+50,700) and not tempvictim:IsInvul() and v:CanAttack() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then	
							if SleepCheck(hand.."moving") and SleepCheck(hand.."attack") then
								if not tempvictim:IsInvul() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then
									v:Attack(tempvictim)
									if GetDistance2D(v,tempvictim) < v.attackRange+50 then
										enemyHP = enemyHP - tempvictim:DamageTaken((v.dmgMin + v.dmgMax)/2,DAMAGE_PHYS,v)
									end
								else
									v:Follow(tempvictim)
								end
								Sleep(Animations.GetAttackTime(v)*1000,hand.."attack")
							end
						elseif Animations.GetAttackTime(v) > 0 and SleepCheck(hand.."moving") and SleepCheck(hand.."move") then
							local mPos = client.mousePosition
							if retreat or (((not tempvictim or ((GetDistance2D(v,mPos) > 300 or GetDistance2D(mPos, tempvictim) > 300) and tempvictimVisible and GetDistance2D(tempvictim,v) < 1000))) and (not tempvictim or (tempvictimVisible and GetDistance2D(tempvictim,v) < 1000)) and (not tempvictim or v:GetTurnTime(mPos)*2 < Animations.getBackswingTime(v))) then
								v:Move(mPos)
							elseif prediction and GetDistance2D(prediction,v) < v.attackRange and tempvictim and (GetDistance2D(v,tempvictim)-v.attackRange)/v.movespeed > Animations.getBackswingTime(v) then
								v:Move(mPos)
							elseif tempvictim then 
								v:Follow(tempvictim)
							end
							--print(math.abs(Animations.getBackswingTime(v))*1000)
							Sleep(math.abs(Animations.getBackswingTime(v))*1000,hand.."move")
						elseif tempvictim and SleepCheck(hand.."moving") and SleepCheck(hand.."attack") and not tempvictim:IsInvul() and v:CanAttack() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then
							v:Attack(tempvictim)
							Sleep(200,hand.."attack")
						end
					elseif SleepCheck(hand.."moving") and (v.name == "npc_dota_enraged_wildkin_tornado" or v.classId == CDOTA_BaseNPC_Tusk_Sigil) then
						if tempvictim and prediction then 
							local prev = SelectUnit(v)
							entityList:GetMyPlayer():Move(prediction)
							SelectBack(prev)
							Sleep(500,hand.."moving")
						end
					end
				end
			end	
			
			--Update target's health
			if tempvictim and enemyHP and tempvictim.health < enemyHP then enemyHP = tempvictim.health end
			if tempvictim and enemyHP and SleepCheck("casting") and tempvictim.health > enemyHP+200 then enemyHP = tempvictim.health end
			if not enemyHP and tempvictim then enemyHP = tempvictim.health end			
			--Update channeling status
			if me:IsChanneling() then channelactive = true end
			if SleepCheck("casting") and SleepCheck("channel") and not me:IsChanneling() then channelactive = false end
			--Pudge: Enable/Disable Rot
			local PudgeRot = me:FindSpell("pudge_rot")		
			if me:CanCast() and PudgeRot then
				if PudgeRot and PudgeRot:CanBeCasted() then
					if SleepCheck("rot2") and tempvictim and (victimdistance <= 350 or (tempvictim and tempvictim:DoesHaveModifier("modifier_pudge_meat_hook"))) and tempvictimVisible and tempvictimAlive and tempvictim.hero and not me:DoesHaveModifier("modifier_pudge_rot") and not tempvictim:DoesHaveModifier("modifier_pudge_rot") then
						me:SafeCastAbility(PudgeRot)
						Sleep(2000,"rot")
						Sleep(300,"rot2")
						return
					elseif SleepCheck("rot") and (not tempvictim or not tempvictimAlive or not tempvictimVisible or victimdistance > 350) and me:DoesHaveModifier("modifier_pudge_rot") then
						me:SafeCastAbility(PudgeRot)
						Sleep(500,"rot")
						return
					end
				end
			--Timber return
			elseif not tempvictim or not tempvictimAlive then
				local chakram = me:FindSpell("shredder_return_chakram")
				local chakram2 = me:FindSpell("shredder_return_chakram_2")
				if chakram and chakram:CanBeCasted() and SleepCheck("shredder_return_chakram") then
					local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and not v:IsIllusion() and v.team ~= me.team and GetDistance2D(lastChakram1,v) < 200+50 and v.health > AbilityDamage.GetDamage(a4)/2) end)
					--print(AbilityDamage.GetDamage(a4))
					if #closeEnemies <= 0 then
						me:CastAbility(chakram)
						Sleep(client.latency,"casting")
					end
				end
				if chakram2 and chakram2:CanBeCasted() and SleepCheck("shredder_return_chakram_2")  then
					local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and not v:IsIllusion() and v.team ~= me.team and GetDistance2D(lastChakram2,v) < 200+50 and v.health > AbilityDamage.GetDamage(a4)/2) end)
					if #closeEnemies <= 0 then
						me:CastAbility(chakram2)
						Sleep(client.latency,"casting")
					end
				end
			--Armlet: Auto toggle
			elseif me:DoesHaveModifier("modifier_item_armlet_unholy_strength") and SleepCheck("item_armlet") and me:CanCast() then
				if (not tempvictim or victimdistance > 500 or not tempvictimVisible) and not retreat then
					me:CastItem("item_armlet")
					if tempvictim then
						local delay = mathmin(Animations.GetAttackTime(tempvictim)*1000 + Animations.getBackswingTime(tempvictim)*1000, 500)
						Sleep(Animations.GetAttackTime(tempvictim)*1000 + Animations.getBackswingTime(tempvictim)*1000,"item_armlet")
					else
						Sleep(1000,"item_armlet")
					end
					return
				elseif (tempvictim or retreat) and me.health < 250 and ((Animations.CanMove(tempvictim) or ((not tempvictim or victimdistance > tempvictim.attackRange+100 or not tempvictimVisible) and (not Animations.isAttacking(tempvictim) or tempvictim:GetTurnTime(me) > 0)) or me.health <= me:DamageTaken((tempvictim.dmgMax+tempvictim.dmgMin)/2, DAMAGE_PHYS, tempvictim)) or retreat) then
					me:CastItem("item_armlet")
					me:CastItem("item_armlet")
					if tempvictim then 
						local delay = mathmin(Animations.GetAttackTime(tempvictim)*1000 + Animations.getBackswingTime(tempvictim)*1000, 500)
						Sleep(Animations.GetAttackTime(tempvictim)*1000 + Animations.getBackswingTime(tempvictim)*1000,"item_armlet")
					else
						Sleep(1000,"item_armlet")
					end
					return
				end
			--Tusk Auto Snowball add
			elseif me:DoesHaveModifier("modifier_tusk_snowball_movement") or tuskSnowBall then	
				local closeAllies = entityList:GetEntities(function (v) return (v.hero or v.classId == CDOTA_BaseNPC_Invoker_Forged_Spirit or v.classId == CDOTA_Unit_SpiritBear or v.classId == CDOTA_BaseNPC_Warlock_Golem or v.classId == CDOTA_Unit_Broodmother_Spiderling) and v.GetDistance2D and v.alive and v.visible and v.team == me.team and v ~= me and not v:IsAttackImmune() and not v:IsInvul() and GetDistance2D(me,v) < 500 and not v:DoesHaveModifier("modifier_tusk_snowball_movement_friendly") end) 
				if #closeAllies > 0 then
					for i = 1, #closeAllies do	
						local v = closeAllies[i]
						if v and not v:IsAttackImmune() and not v:IsInvul() and SleepCheck(v.handle.."tusk") and SleepCheck("tusk") then
							me:Attack(v)
							Sleep(100,v.handle.."tusk")
							Sleep(25,"tusk")
							return
						end
					end
				else
					tuskSnowBall = false
				end
			--Spirit Breaker: Anti Charge canceling
			elseif ID == CDOTA_Unit_Hero_SpiritBreaker or ID == CDOTA_Unit_Hero_Rubick then
				local charge = a1
				if ID == CDOTA_Unit_Hero_Rubick then charge = a4 end
				if charge and charge.abilityPhase and SleepCheck("charge") then
					Sleep(1000,"charge")
				end
			end
			local glimpsePos = false
			if disruptor then
				local glimpse = disruptor:FindSpell("disruptor_glimpse")
				local gcd = glimpse:GetCooldown(glimpse.level)
				gcd = gcd - 1.8 - client.latency/1000
				if glimpse.cd > gcd then glimpsePos = true else glimpsePos = false end
			end
			if tempvictim and (tempvictim:DoesHaveModifier("modifier_kunkka_x_marks_the_spot") or glimpsePos) then
				if not xposition then 
					if glimpsePos then
						if positionsTable[tempvictim.handle] then
							--local modif = tempvictim:FindModifier("modifier_disruptor_glimpse")
							local pos = positionsTable[tempvictim.handle]
							local time = gameTime-4
							local closest = nil
							local closesttime = nil
							for i,v in pairs(pos) do
								if not closest or math.abs(time-i) < closesttime then
									closest = v
									closesttime = math.abs(time-i)
								end
							end
							if closest then xposition = closest end
						end
					else
						xposition = tempvictim.position 
					end
				end
			elseif xposition and SleepCheck("kunkka_x_marks_the_spot") and not glimpsePos and SleepCheck("disruptor_glimpse") and not a3.abilityPhase and a3.name ~= "kunkka_return" then xposition = nil end
			-- if xposition then
				-- if not eff then 
					-- eff = Effect(xposition, "range_display" )
					-- eff:SetVector(1,Vector(500,0,0))
					-- eff:SetVector(0, xposition )
				-- else
					-- eff:SetVector(0, xposition )
				-- end
			-- end
			--Special Combo: Kunkka
			if ID == CDOTA_Unit_Hero_Kunkka and tempvictim then
				local torrent = a1
				local x_mark = a3	
				if x_mark.name == "kunkka_return" or xposition then
					if xposition and torrent.cd ~= 0 and mathfloor(torrent.cd*10) == 90 + mathfloor((client.latency/100)) and SleepCheck("casting2") and me:CanCast() then
						me:CastAbility(x_mark)
						Sleep(200+client.latency, "casting2")
						Sleep(200+client.latency, "casting")
						return
					end
					local ship = a4
					if torrent.cd ~= 0 and SleepCheck("casting") and ship:CanBeCasted() and me:CanCast() and xposition and GetDistance2D(me,xposition) > 750 then
						me:CastAbility(ship, xposition)
						local Dmg 
						if tempdamageTable[ship.name] then
							Dmg = tempdamageTable[ship.name][1]
							Dmg = tempvictim:DamageTaken(Dmg,DAMAGE_MAGC,me)
							enemyHP = enemyHP - Dmg
						end
						Sleep(ship:FindCastPoint()*1000+me:GetTurnTime(xposition)*1000,"casting")
						Sleep(ship:FindCastPoint()*1000+me:GetTurnTime(xposition)*1000,"moving")
						Sleep(6000,"stun")
						return
					end
				elseif xposition and SleepCheck("kunkka_x_marks_the_spot") and not x_mark.abilityPhase then
					xposition = nil
				end
			end
			if me:IsChanneling() or channelactive then 
				local glimmer_cape = me:FindItem("item_glimmer_cape")
				if glimmer_cape and glimmer_cape:CanBeCasted() and SleepCheck("glim") then
					me:CastAbility(glimmer_cape,me)
					Sleep(200,"glim")
				end
				return
			end
			local quas, wex, exort, spell1, spell2
			--Wips: Auto Aim with spirits
			if me:DoesHaveModifier("modifier_wisp_spirits") and tempvictim then
				local spirits = entityList:GetEntities({classId=CDOTA_Wisp_Spirit,alive=true,team=me.team,visible=true})
				tablesort(spirits, function (a,b) return a.handle > b.handle end)
				local spirit = nil
				for i = 1, #spirits do
					local v = spirits[i]
					if GetDistance2D(me,v) < 900 then spirit = v break end
				end
				if spirit then
					local spiritsin = me:FindSpell("wisp_spirits_in")
					local spiritsout = me:FindSpell("wisp_spirits_out")
					local mepred = SkillShotPredictedXYZ(me,client.latency)
					local vicpred = SkillShotPredictedXYZ(tempvictim,client.latency)
					if not tempvictimVisible then vicpred = SkillShot.BlindSkillShotXYZ(me,tempvictim,1100,client.latency/1000) end
					local dist = GetDistance2D(spirit,me)
					local vicdist = GetDistance2D(mepred,vicpred)
					if mathabs(dist-vicdist) < 100 then
						if spiritsin.toggled and SleepCheck("in") then me:SafeCastAbility(spiritsin) Sleep(250,"in")
						elseif spiritsout.toggled and SleepCheck("out") then me:SafeCastAbility(spiritsout) Sleep(250,"out") end
					elseif dist > vicdist and SleepCheck("in") and not spiritsin.toggled then me:SafeCastAbility(spiritsin) Sleep(250,"in")
					elseif dist < vicdist and SleepCheck("out") and not spiritsout.toggled then me:SafeCastAbility(spiritsout) Sleep(250,"out") end
				end
			
			--Pudge hook cancel if no target
			elseif ID == CDOTA_Unit_Hero_Pudge and a1.abilityPhase and (not tempvictim or not tempvictimAlive) then
				me:Stop()
			end
			
			--SkillShots Canceling 
			if prediction then
				if not lastPrediction then lastPrediction = {prediction, tempvictim.rotR}
				elseif not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") then
					if ID == CDOTA_Unit_Hero_Pudge and not SleepCheck("pudge_meat_hook") then
						local hook = a1
						if hook.abilityPhase and ((GetDistance2D(lastPrediction[1],prediction) > mathabs(GetDistance2D(tempvictim,lastPrediction[1])-150) and mathabs((tempvictim.rotR) - lastPrediction[2]) > 0.5) or SkillShot.__GetBlock(me.position,lastPrediction[1],tempvictim,100,true)) then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Mirana and not SleepCheck("mirana_arrow") then
						local arrow = a2
						if arrow.abilityPhase and ((GetDistance2D(lastPrediction[1],prediction) > mathabs(GetDistance2D(tempvictim,lastPrediction[1])-115) and mathabs((tempvictim.rotR) - lastPrediction[2]) > 0.3) or SkillShot.__GetBlock(me.position,lastPrediction[1],tempvictim,115,false)) then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Rattletrap and not SleepCheck("rattletrap_hookshot") then
						local hookshot = a4
						if hookshot.abilityPhase and ((GetDistance2D(lastPrediction[1],prediction) > mathabs(GetDistance2D(tempvictim,lastPrediction[1])-125) and mathabs((tempvictim.rotR) - lastPrediction[2]) > 0.3) or SkillShot.__GetBlock(me.position,lastPrediction[1],tempvictim,125,true)) then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Lina and not SleepCheck("lina_light_strike_array") then
						local LightStrike = a2
						if LightStrike.abilityPhase and GetDistance2D(lastPrediction[1],prediction) > 275 then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Leshrac and not SleepCheck("leshrac_split_earth") then
						local SplitEarth = a1
						local radius = SplitEarth:GetSpecialData("radius")
						if SplitEarth.abilityPhase and GetDistance2D(lastPrediction[1],prediction) > radius+50 then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Sniper and not SleepCheck("sniper_shrapnel") then
						local shrapnel = a1
						local radius = shrapnel:GetSpecialData("radius")
						if shrapnel.abilityPhase and GetDistance2D(lastPrediction[1],prediction) > radius+50 then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Kunkka and not SleepCheck("kunkka_torrent") and not xposition then
						local torrent = a1
						if torrent.abilityPhase and GetDistance2D(lastPrediction[1],prediction) > mathabs(GetDistance2D(tempvictim,lastPrediction[1])) and GetDistance2D(lastPrediction[1],prediction) > 250 then
							me:Stop()
						end
					elseif ID == CDOTA_Unit_Hero_Nevermore then
						if not SleepCheck("nevermore_shadowraze1") then
							local raze = a1
							if raze.abilityPhase and (GetDistance2D(lastPrediction[1],tempvictim) > 275 or me:GetTurnTime(lastPrediction[1]) > 0.01) then
								me:Stop()
							end
						elseif not SleepCheck("nevermore_shadowraze2") then
							local raze = a2
							if raze.abilityPhase and (GetDistance2D(lastPrediction[1],tempvictim) > 275 or me:GetTurnTime(lastPrediction[1]) > 0.01) then
								me:Stop()
							end
						elseif not SleepCheck("nevermore_shadowraze3") then
							local raze = a3
							if raze.abilityPhase and (GetDistance2D(lastPrediction[1],tempvictim) > 275 or me:GetTurnTime(lastPrediction[1]) > 0.01) then
								me:Stop()
							end
						end
					end
				end
			end
			local closestTrap = nil
			local meld, refraction
			local meDmg = 0
			if tempvictim then meDmg = tempvictim:DamageTaken((me.dmgMin + me.dmgMax)/2,DAMAGE_PHYS,me) end
			--Special Combo: Templar Assassin
			if ID == CDOTA_Unit_Hero_TemplarAssassin or ID == CDOTA_Unit_Hero_Rubick then
				if ID == CDOTA_Unit_Hero_TemplarAssassin then
					meld,refraction = a2,a1
				else
					meld,refraction = me:FindSpell("templar_assassin_meld"), me:FindSpell("templar_assassin_refraction")
				end
				local traps = entityList:GetEntities({classId=CDOTA_BaseNPC_Additive,alive=true,team=me.team,visible=true})
				for i = 1, #traps do
					local v = traps[i]
					local spell = v:GetAbility(1)
					if (spell and spell.name == "templar_assassin_self_trap" and spell:CanBeCasted()) then
						if not closestTrap or GetDistance2D(closestTrap, tempvictim) > GetDistance2D(v, tempvictim) then
							if GetDistance2D(v, tempvictim) <= 400 then
								closestTrap = v
							end
							if closestTrap and GetDistance2D(closestTrap, tempvictim) > 400 then
								closestTrap = nil
							end
						end
					end
				end
				local trap = a5
				if ID == CDOTA_Unit_Hero_Rubick then trap = me:FindSpell("templar_assassin_psionic_trap") end
				if trap and tempvictim and (not harras or victimdistance < range+100) and tempvictim.hero and CanBeSlowed(tempvictim) and (tempvictim and tempvictim:CanMove() and tempvictim.activity == LuaEntityNPC.ACTIVITY_MOVE) and (meDmg*2 < enemyHP or victimdistance > range) then
					local trapslow = tempvictim:FindModifier("modifier_templar_assassin_trap_slow")
					if (tempvictim:CanMove() and (not trapslow or trapslow.remainingTime <= (trap:FindCastPoint()*1.5 + client.latency/1000))) and chainStun(tempvictim,trap:FindCastPoint()+client.latency/1000) then
						if (closestTrap and GetDistance2D(closestTrap, tempvictim) <= 400) and SleepCheck("trap2") then
							local boom = closestTrap:GetAbility(1)
							if boom:CanBeCasted() then
								closestTrap:SafeCastAbility(boom)
								Sleep(trap:FindCastPoint()*1000 + 200 + client.latency, "trap2")
								Sleep(trap:FindCastPoint()*1000 + 200 + client.latency, "trap")
							end
						elseif not ((blink and blink:CanBeCasted()) and (prediction and GetDistance2D(prediction,me) > 500 and GetDistance2D(prediction,me) > range+50 and GetDistance2D(prediction,me) < 1700)) and (not a2 or not a2:CanBeCasted() or victimdistance > range+100) and me:CanCast() and victimdistance <= trap.castRange+375 and (not trapslow or trapslow.remainingTime <= (trap:FindCastPoint()*1.5)) and SleepCheck("trap") and trap:CanBeCasted() and chainStun(tempvictim,trap:FindCastPoint()+client.latency/1000) and SleepCheck("casting") and (not meld or not meld:CanBeCasted() or GetDistance2D(me,prediction)+50 > range) then
							local prediction = SkillShotPredictedXYZ(tempvictim,me:GetTurnTime(tempvictim)*1000+trap:FindCastPoint()*2000+client.latency)	
							local pos
							if tempvictimVisible then
								pos = prediction
								me:SafeCastAbility(trap, prediction)
							else
								local blind = SkillShot.BlindSkillShotXYZ(me,tempvictim,1100,trap:FindCastPoint()+client.latency/1000)
								if blind then
									pos = blind
									me:SafeCastAbility(trap, blind)
								else
									pos = Vector(tempvictim.position.x + (movespeed * (trap:FindCastPoint() + client.latency/1000) + 100) * mathcos(tempvictim.rotR), tempvictim.position.y + (movespeed * (trap:FindCastPoint() + client.latency/1000) + 100) * mathsin(tempvictim.rotR), tempvictim.position.z)
									me:SafeCastAbility(trap, pos)
								end
							end
							Sleep(trap:FindCastPoint()*1000 + me:GetTurnTime(pos)*1000 + 100, "casting")
							Sleep(trap:FindCastPoint()*1000 + me:GetTurnTime(pos)*1000, "moving")
							Sleep(trap:FindCastPoint()*1000 + 200 + client.latency, "trap")
							return
						end
					end
				end
				
			--Special Combo: Brewmaster Ultimate
			elseif ID == CDOTA_Unit_Hero_Brewmaster or ID == CDOTA_Unit_Hero_Rubick then
				local ulti = a4
				if ID == CDOTA_Unit_Hero_Rubick then ulti = me:FindSpell("brewmaster_primal_split") end
				if ulti and ulti.cd > 0 then
					local dur = ulti:GetSpecialData("duration")
					if ulti.cd+dur > ulti:GetCooldown(ulti.level) then
						local splits = entityList:GetEntities(function (ent) return (ent.classId == CDOTA_Unit_Brewmaster_PrimalEarth or ent.classId == CDOTA_Unit_Brewmaster_PrimalFire or ent.classId == CDOTA_Unit_Brewmaster_PrimalStorm) and ent.controllable and ent.alive end)
						local BrewmasterComboTable = {
							{ CDOTA_Unit_Brewmaster_PrimalEarth, {{ 1, nil, true}, { 4, "radius", true }} },
							{ CDOTA_Unit_Brewmaster_PrimalStorm, {{ 4, nil, true}, { 1 }, { 3, 650 }} }
						}
						local l = #BrewmasterComboTable
						for z = 1, #splits do
							local split = splits[z]
							anientiCount = anientiCount + 1
							Animations.entities[anientiCount] = split
							local hand = split.handle
							if tempvictim and tempvictim.hero and tempvictimVisible then
								for i = 1, l do
									local table = BrewmasterComboTable[i]
									if table[1] == split.classId then
										local t2 = table[2]
										local l2 = #t2
										for i = 1, l2 do
											local data = t2[i]
											local slot = data[1] or data
											if slot then
												local spell
												if GetType(slot) == "string" then
													spell = split:FindSpell(slot)
												else
													spell = split:GetAbility(slot)
												end	
												if spell and spell:CanBeCasted() then
													local speed = spell:GetSpecialData("speed",spell.level)
													local range = spell.castRange
													if data[2] then
														distance = data[2]
													end
													local victimdistance = GetDistance2D(split,tempvictim)
													if distance then
														if GetType(distance) == "string" then
															distance = spell:GetSpecialData(distance,spell.level)
														end
													end
													local delay = spell:FindCastPoint()*1000
													local delay2 = delay/1000 + client.latency/1000
													local prediction = SkillShotPredictedXYZ(tempvictim,mathmax(delay, 100)+client.latency)
													if speed then delay2 = delay2 + (mathmin(range-50, GetDistance2D(split,prediction))/speed) end
													local cast = nil
													if SleepCheck(hand.."casting") and SleepCheck(hand..""..spell.name) and (not data[3] or chainStun(tempvictim, delay2)) then
														if spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) then
															if spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not DoesHaveModifier("modifier_"..spell.name) and not DoesHaveModifier("modifier_"..spell.name.."_debuff") and not spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL) then
																cast = split:SafeCastAbility(spell,split)
															elseif (spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) or spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_CUSTOM) or spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL)) and not tempvictim:IsInvul() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and not tempvictim:DoesHaveModifier("modifier_brewmaster_storm_cyclone") and victimdistance < mathmax(spell.castRange+500, 1000) and not tempvictim:DoesHaveModifier("modifier_"..spell.name) and not tempvictim:DoesHaveModifier("modifier_"..spell.name.."_debuff") then
																cast = split:SafeCastAbility(spell,tempvictim)
																delay = delay + split:GetTurnTime(tempvictim)*1000 + (mathmax(victimdistance-50-range,0)/split.movespeed)*1000
															end
														elseif spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) and tempvictimVisible and not tempvictim:DoesHaveModifier("modifier_"..spell.name) 
														and (spell.name ~= "brewmaster_storm_wind_walk" or GetDistance2D(split,prediction) < distance) and (spell.name ~= "brewmaster_thunder_clap" or (prediction and GetDistance2D(split,prediction) < distance)) and not tempvictim:DoesHaveModifier("modifier_"..spell.name.."_debuff") and not DoesHaveModifier("modifier_"..spell.name) and not DoesHaveModifier("modifier_"..spell.name.."_debuff") then												
															cast = split:SafeCastAbility(spell)
														elseif spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) or spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_AOE) then
															if spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) then
																cast = split:SafeCastAbility(spell,split)
															else
																delay = delay + split:GetTurnTime(tempvictim)*1000
																local delay2 = delay + client.latency
																if data[2] then delay2 = delay2 + data[2]*1000 end
																local speed = spell:GetSpecialData("speed")
																local prediction
																if not speed then 
																	prediction = SkillShotPredictedXYZ(tempvictim,delay2)
																else
																	prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay2,speed)
																end
																if prediction and GetDistance2D(prediction,mePosition) < spell.castRange+150 then
																	delay = delay + (mathmax(GetDistance2D(prediction,mePosition)-50-spell.castRange,0)/split.movespeed)*1000
																	cast = split:SafeCastAbility(spell,prediction)
																end
															end
														end
															
														if cast then
															if tempdamageTable[spell.name] then
																local Dmg = tempdamageTable[spell.name][1]
																Dmg = tempvictim:DamageTaken(Dmg,DAMAGE_MAGC,me)
																enemyHP = enemyHP - Dmg
															end
															if data[3] then Sleep(delay+300+client.latency,"stun") end
															Sleep(delay,hand.."casting")
															Sleep(delay,hand.."moving")
															Sleep(delay+client.latency+100, hand..""..spell.name)
														end
													end
												end
											end
										end
									end
								end
							end

							if not retreat and tempvictim and not Animations.CanMove(split) and GetDistance2D(split,tempvictim) <= mathmax(split.attackRange*2+50,500) and not tempvictim:IsInvul() and split:CanAttack() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then	
								if SleepCheck(hand.."moving") and SleepCheck(hand.."attack") then
									if not tempvictim:IsInvul() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then
										split:Attack(tempvictim)
										if GetDistance2D(split,tempvictim) < split.attackRange+50 then
											enemyHP = enemyHP - tempvictim:DamageTaken((split.dmgMin + split.dmgMax)/2,DAMAGE_PHYS,split)
										end
									else
										split:Follow(tempvictim)
									end
									Sleep(Animations.GetAttackTime(split)*1000,hand.."attack")
								end
							elseif not targetlock and SleepCheck(hand.."moving") and SleepCheck(hand.."move") then
								local mPos = client.mousePosition
								if retreat or (((not tempvictim or (GetDistance2D(split,mPos) > 300 and tempvictimVisible and GetDistance2D(tempvictim,split) < 1000))) and (not tempvictim or (tempvictimVisible and GetDistance2D(tempvictim,split) < 1000))) then
									split:Move(mPos)
								elseif prediction and GetDistance2D(prediction,split) < split.attackRange and (GetDistance2D(split,tempvictim)-range)/movespeed > Animations.getBackswingTime(split) then
									if not tempvictim:IsInvul() and split:CanAttack() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") and (not tempvictim:CanMove() or GetDistance2D(split,prediction)-100 < GetDistance2D(split,tempvictim)) then
										split:Attack(tempvictim)
									else
										split:Move(mPos)
									end
								else
									split:Follow(tempvictim)
								end
								Sleep(Animations.getBackswingTime(split)*1000,hand.."move")
							end
						end
						return 
					end
				end
						
			--Special Combo: Invoker
			elseif ID == CDOTA_Unit_Hero_Invoker then
				quas, wex, exort, spell1, spell2, invoke = a1, a2, a3, a4, a5, a6  
				if (not me:IsInvisible() or me.visibleToEnemy) and combo == 0 then
					
					--Build Recognition
					local build = {{wex, 2}, {quas, 1}, {exort, 3}}	
					tablesort(build, function(a,b) return a[1].level > b[1].level end)
					local spells = {}
					local spellsCount = 0
					local orbSpells = invokerCombo[build[1][2]]
					local cyclone = me:FindItem("item_cyclone")
					local tornado = me:FindItem("invoker_tornado")
					local octa = me:FindItem("item_octarine_core")
					
					function test(name) 
						return
							(
								(name ~= "invoker_tornado" or wex.level > 3) 
								and (not harras or ((me:FindSpell(name).manacost+invoke.manacost) < me.mana*0.2 
									and victimdistance < range+100)) 
								and (name ~= "invoker_chaos_meteor" or exort.level > 3 
									or (tempvictim and (tempvictim:IsStunned() or tempvictim:IsRooted() 
									or movespeed < 200))) 
								and (name ~= "invoker_ice_wall" or quas.level > 3) 
								and (name ~= "invoker_emp" or wex.level > 3 or build[1][1] == wex) 
								and (name ~= "invoker_sun_strike" or (exort.level > 3 
									and (tempvictim and (tempvictim:IsStunned() or tempvictim:IsRooted() 
										or (cyclone and cyclone:CanBeCasted()) or (tornado and tornado:CanBeCasted()) 
										or tempvictim:DoesHaveModifier("modifier_eul_cyclone") 
										or tempvictim:DoesHaveModifier("modifier_invoker_tornado") or movespeed < 200 
										or enemyHP < 500)))) 
								and (name ~= "invoker_ice_wall" or (name == "invoker_ice_wall" 
									and tempvictim and (facing or GetDistance2D(me,prediction) < 450))) 
								and (name ~= "invoker_alacrity" or (not retreat and wex.level > 3 and exort.level > 3)) 
								and (name ~= "invoker_emp" or not retreat) 
								and (name ~= "invoker_chaos_meteor" or not retreat) 
								and (name ~= "invoker_tornado" or (name == "invoker_tornado" or not tempvictim 
									or (not tempvictim:DoesHaveModifier("modifier_invoker_chaos_meteor_burn") 
										and not tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") 
										and not tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_aura"))))
							) 
					end
					
					local canInvoke = ((spell2.cd > 3 or (tempvictim and spell2.cd ~= 0)) or spell2.name == "invoker_ghost_walk" or (retreat and spell2.name == "invoker_alacrity") or (spell2.name == "invoker_ice_wall" and victimdistance > 700))
					
					
					--Combo Recognition:
					--Ghost Walk for escaping
					if retreat and wex.level > 0 and quas.level > 0 and SleepCheck("casting2") then
						prepareSpell("invoker_ghost_walk", me)
					
					--Blast after combos using tornado/euls
					elseif (((spell1.name == "invoker_sun_strike" or spell1.name == "invoker_chaos_meteor") and (spell2.name == "invoker_sun_strike" or spell2.name == "invoker_chaos_meteor")) or
						((spell1.name == "invoker_tornado" or spell1.name == "invoker_chaos_meteor") and (spell2.name == "invoker_tornado" or spell2.name == "invoker_chaos_meteor")) or
						((spell1.name == "invoker_tornado" or spell1.name == "invoker_emp") and (spell2.name == "invoker_tornado" or spell2.name == "invoker_emp")) or retreat) and canInvoke and wex.level > 0  and quas.level > 0 and SleepCheck("casting2") then
						local spell2cd = spell2:GetCooldown(spell2.level)
						if octa then
							spell2cd = spell2cd*0.75
						end
						spell2cd = spell2cd-7
						if spell2 and spell2.cd > spell2cd then
							prepareSpell("invoker_deafening_blast", me)
						end
						
					--Tornado->Meteor/EMP->Blast
					elseif me:AghanimState() and quas.level > 5 then 
						local spell2cd = spell2:GetCooldown(spell2.level)
						if octa then
							spell2cd = spell2cd*0.75
						end
						spell2cd = spell2cd-7
						if spell1.name == "invoker_chaos_meteor" and spell2.name == "invoker_tornado" and tempvictim and spell2 and spell2.cd > spell2cd and canInvoke and wex.level > 0 and SleepCheck("casting2") then
							prepareSpell("invoker_emp", me)
						end
						if spell1.name == "invoker_emp" and spell2.name == "invoker_tornado" and tempvictim and spell2 and spell2.cd > spell2cd and canInvoke and wex.level > 0 and SleepCheck("casting2") then
							prepareSpell("invoker_chaos_meteor", me)
						end
						if (spell1.name == "invoker_emp" or spell1.name == "invoker_chaos_meteor") and spell2 and spell2.cd > spell2cd and (spell2.name == "invoker_emp" or spell2.name == "invoker_chaos_meteor") and canInvoke and wex.level > 0  and quas.level > 0 and SleepCheck("casting2") then
							prepareSpell("invoker_deafening_blast", me)
						end
					elseif (((spell1.name == "invoker_tornado" or spell1.name == "invoker_emp") and (spell2.name == "invoker_tornado" or spell2.name == "invoker_emp"))) and tempvictim and canInvoke and quas.level > 0 and SleepCheck("casting2") then
						prepareSpell("invoker_cold_snap", me)
					
					--alacrity after vaginal injection
					elseif (spell1.name == "invoker_cold_snap" or spell2.name == "invoker_cold_snap") and tempvictim and canInvoke and wex.level > exort.level and wex.level > 0 and exort.level > 0 and SleepCheck("casting2") then
						local snap = me:FindSpell("invoker_cold_snap")
						local spell2cd = snap:GetCooldown(snap.level)
						if octa then
							spell2cd = spell2cd*0.75
						end
						spell2cd = spell2cd-3
						if snap and snap.cd > spell2cd then
							prepareSpell("invoker_alacrity", me)
						end
					
					--Sunstrike KillSteal
					elseif victimdistance > range+50 and (not blink or blink.cd > 5) then
						local sunstrike = me:FindSpell("invoker_sun_strike")
						local Dmg = AbilityDamageGetDamage(sunstrike)
						if sunstrike and spell1 ~= sunstrike and spell2 ~= sunstrike and sunstrike.cd and sunstrike.cd == 0 and sunstrike.manacost and sunstrike.manacost < me.mana and Dmg and enemyHP and Dmg >= enemyHP then
							prepareSpell("invoker_sun_strike", me)
						end
					
					--Meteor after Tornado
					elseif tempvictim and tempvictim:DoesHaveModifier("modifier_invoker_tornado") and canInvoke and wex.level > 0 and exort.level > 0 and SleepCheck("casting2") then
						prepareSpell("invoker_chaos_meteor", me)
					
					--EMP after tornado from ghost walk
					elseif (((spell1.name == "invoker_tornado" or spell1.name == "invoker_ghost_walk") and (spell2.name == "invoker_tornado" or spell2.name == "invoker_ghost_walk"))) and tempvictim and tempvictim:DoesHaveModifier("modifier_invoker_tornado") and canInvoke and wex.level > 0 and SleepCheck("casting2") then
						prepareSpell("invoker_emp", me)
					end
					
					for i = 1,#orbSpells do
						local spell = orbSpells[i]
						local ent = me:FindSpell(spell[1])
						if ent then
							if ent:CanBeCasted() and (ent == spell1 or ent == spell2) then
								spellsCount = spellsCount + 1
								spells[spellsCount] = spell
							elseif ent.cd == 0 and ent.manacost+invoke.manacost < me.mana and (ent ~= spell1 and ent ~= spell2) and (canInvoke or spell1.name == "invoker_empty1" or spell1.name == "invoker_empty2" or spell2.name == "invoker_empty1" or spell2.name == "invoker_empty2") and SleepCheck("casting2") and test(ent.name) then	
								prepareSpell(ent.name, me)
							end
						end			
					end
					orbSpells = invokerCombo[build[2][2]]
					for i = 1,#orbSpells do
						local spell = orbSpells[i]
						local ent = me:FindSpell(spell[1])
						if ent then
							if ent:CanBeCasted() and (ent == spell1 or ent == spell2) then
								spellsCount = spellsCount + 1
								spells[spellsCount] = spell
							elseif ent.cd == 0 and ent.manacost+invoke.manacost < me.mana and (ent ~= spell1 and ent ~= spell2) and (canInvoke or spell1.name == "invoker_empty1" or spell1.name == "invoker_empty2" or spell2.name == "invoker_empty1" or spell2.name == "invoker_empty2") and SleepCheck("casting2") and test(ent.name) then	
								prepareSpell(ent.name, me)
							end
						end	
					end
					if build[3][1].level > 0 then
						orbSpells = invokerCombo[build[3][2]]
						for i = 1,#orbSpells do
							local spell = orbSpells[i]
							local ent = me:FindSpell(spell[1])
							if ent then
								if ent:CanBeCasted() and (ent == spell1 or ent == spell2) then
									spellsCount = spellsCount + 1
									spells[spellsCount] = spell
								elseif ent.cd == 0 and ent.manacost+invoke.manacost < me.mana and (ent ~= spell1 and ent ~= spell2) and (canInvoke or spell1.name == "invoker_empty1" or spell1.name == "invoker_empty2" or spell2.name == "invoker_empty1" or spell2.name == "invoker_empty2") and SleepCheck("casting2") and test(ent.name) then	
									prepareSpell(ent.name, me)
								end
							end	
						end
					end
					if quas.level > 0 and wex.level > 0 and exort.level > 0 then
						spellsCount = spellsCount + 1
						spells[spellsCount] = invokerCombo[4][1]
					end
					if retreat and quas.level > 0 and wex.level > 0 then
						spellsCount = spellsCount + 1
						spells[spellsCount] = invokerCombo[4][2]
					end
					for i = 1, spellsCount do
						local data = spells[i]
						local spell = data[1]
						if spell == "invoker_tornado" and spellsCount > 1 then
							if quas.level > 3 then
								spells[i] = spells[1]
								spells[1] = data
							else
								spells[i] = spells[2]
								spells[2] = data
							end
						end
					end
					mySpells = { CDOTA_Unit_Hero_Invoker, spells }
				end
			
			--Ember Spirit: Searing Chains
			elseif ID == CDOTA_Unit_Hero_EmberSpirit and tempvictim then
				local chains = a1
				if chains and chains:CanBeCasted() and not SleepCheck("ember_spirit_sleight_of_fist") and GetDistance2D(mePosition,tempvictim) < 500 and SleepCheck(chains.name) then
					me:CastAbility(chains)
					Sleep(500,chains.name)
					return
				end
			end
			if tempvictim and tempvictim.hero and (not me:IsInvisible() or (a2.name == "templar_assassin_meld" and a2:CanBeCasted() and victimdistance < range)) and ((enemyHP > 0 and enemyHP > meDmg) or victimdistance > range-100) and me.alive and tempvictimAlive then
				local CanCast = me:CanCast()
				local al = #abilities
				local items = me.items
				local il = #items
				local manaboots = me:FindItem("item_arcane_boots")
				--Blink
				if tempvictim and tempvictimVisible and tempvictimAlive and blink and SleepCheck("blink") and GetDistance2D(prediction,me) > 500 and GetDistance2D(prediction,me) > range+50 and GetDistance2D(prediction,me) < 1700 and not me:IsStunned() and blink:CanBeCasted() and useblink and SleepCheck("casting") then
					local distance = blink:GetSpecialData("blink_range")
					local blinkPos = prediction
					if retreat then
						blinkPos = client.mousePosition
					end
					if GetDistance2D(prediction,me) > distance or retreat then
						blinkPos = (blinkPos - me.position) * (distance-1) / GetDistance2D(blinkPos,me) + me.position
					end
					if me:SafeCastAbility(blink,blinkPos) then
						Sleep(me:GetTurnTime(blinkPos)*1000+client.latency+400,"blink")
						Sleep(me:GetTurnTime(blinkPos)*1000+client.latency+100,"casting")
						Sleep(me:GetTurnTime(blinkPos)*1000+client.latency,"moving")
						mePosition = blinkPos
						return
					end
				end
				local dagon = me:FindDagon()
				local ethereal = me:FindItem("item_ethereal_blade")
				--Item Combo
				if SleepCheck("casting") and not me:IsStunned() and tempvictimVisible and (not meld or (not me:DoesHaveModifier("modifier_templar_assassin_meld") or SleepCheck("moving"))) then
					local l = #itemcomboTable
					for i = 1, l do
						local data = itemcomboTable[i]
						local itemname = data[1] or data
						local item = me:FindItem(itemname)
						if item and item:CanBeCasted() then
							local mainatr = 0
							if itemname == "item_ethereal_blade" then
								if not atr then atr = me.primaryAttribute end
								local atr = atr
								if atr == LuaEntityHero.ATTRIBUTE_STRENGTH then mainatr = me.strengthTotal
								elseif atr == LuaEntityHero.ATTRIBUTE_AGILITY then mainatr = me.agilityTotal
								elseif atr == LuaEntityHero.ATTRIBUTE_INTELLIGENCE then mainatr = me.intellectTotal
								end
							end
							if not tempdamageTable[itemname] or (itemname == "item_ethereal_blade" and tempdamageTable[itemname][2] ~= mainatr) then
								damageTable[itemname] = {AbilityDamageGetDamage(item), mainatr}
								tempdamageTable = damageTable
							end
							local Dmg = tempdamageTable[itemname][1]
							if itemname == "item_urn_of_shadows" then Dmg = 100 end
							local type = AbilityDamageGetDmgType(item)
							if Dmg then
								Dmg = tempvictim:DamageTaken(Dmg,type,me)
							end
							local go = true
							if itemname == "item_refresher" or (itemname == "item_cyclone" and ID == CDOTA_Unit_Hero_Tinker) then
								for z = 1, al do
									local ab = abilities[z]
									if ab.name ~= "tinker_march_of_the_machines" and ab.name ~= "tinker_rearm" and ab.name ~= "invoker_alacrity" and ab.name ~= "invoker_forge_spirit" and ab.name ~= "invoker_ice_wall" and ab.name ~= "invoker_ghost_walk" and ab.name ~= "invoker_cold_snap" and ab.name ~= "invoker_quas" and ab.name ~= "invoker_exort" and ab.name ~= "invoker_wex" and ab.name ~= "invoker_invoke" and ab.level > 0 and ab.cd == 0 and not ab:IsBehaviourType(LuaEntityAbility.BEHAVIOR_PASSIVE) then
										go = false
										break
									end
								end
								for z = 1, il do
									local ab = items[z]
									if ab.name ~= "item_blink" and ab.name ~= "item_travel_boots" and ab.name ~= itemname and ab.name ~= "item_travel_boots_2" and ab.name ~= "item_tpscroll" and ab.abilityData.itemCost > 1000 and ab:CanBeCasted() then
										go = false
										break
									end
								end
							end
							if itemname == "item_cyclone" then
								if not config.UseEul then go = false end
								for z = 1, al do
									local ab = abilities[z]
									local abcd = ab:GetCooldown(ab.level)
									local octa = me:FindItem("item_octarine_core")
									if octa then
										abcd = abcd*0.75
									end
									abcd = abcd-3
									local dmg 
									if tempdamageTable[ab.name] then
										dmg = tempdamageTable[ab.name][1]
									end
									if (ab.cd > abcd) and ab.cd ~= 0 and dmg and dmg > 0 then go = false end
								end
								if combo ~= 0 then go = false end
							end
							if itemname == "item_urn_of_shadows" and not me.visibleToEnemy and enemyHP > Dmg then go = false end
							if itemname ~= "item_veil_of_discord" and itemname ~= "item_soul_ring" and itemname ~= "item_arcane_boots" then
								local spell1,spell2 = a4,a5
								if (spell1.name == "invoker_tornado" and spell1:CanBeCasted()) or (spell2.name == "invoker_tornado" and spell2:CanBeCasted()) then
									go = false
								end
							end
							
							if (item == dagon or item == ethereal) and ID ~= CDOTA_Unit_Hero_Tinker and ((a4 and a4.name == "necrolyte_reapers_scythe" and a4:CanBeCasted()) or (data[4] and Dmg < enemyHP and not tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") and not tempvictim:DoesHaveModifier("modifier_necrolyte_reapers_scythe"))) then
								--print("aaaa")
								go = false
							end
							if itemname == "item_phase_boots" then Dmg = nil end
							if itemname == "item_force_staff" and not me:DoesHaveModifier("modifier_batrider_flaming_lasso_self") then go = false end
							if itemname == "item_dust" and not CanGoInvis(tempvictim) then go = false end
							if (itemname == "item_diffusal_blade" or itemname == "item_diffusal_blade_2") then
								if not (tempvictim:DoesHaveModifier("modifier_ghost_state") or tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") or tempvictim:DoesHaveModifier("modifier_omninight_guardian_angel")) then 
									go = false 
								end
							end
							if itemname == "item_arcane_boots" and (me.maxMana - me.mana) < 135 then go = false end
							local coldfeet
							if ID == CDOTA_Unit_Hero_AncientApparition then
								coldfeet = a1
							end
							if ID == CDOTA_Unit_Hero_Rubick then coldfeet = me:FindSpell("ancient_apparition_cold_feet") end
							
							if itemname == "item_cyclone" then 
								delay = 500 
								if xposition then 
									go = false 
								end 
								if coldfeet and coldfeet:CanBeCasted() then 
									go = false 
								end
								if ID == CDOTA_Unit_Hero_Skywrath_Mage then
									local mfcd = a4:GetCooldown(a4.level)
									local octa = me:FindItem("item_octarine_core")
									if octa then
										mfcd = mfcd*0.75
									end
									mfcd = mfcd-3
									if a4 and a4.cd > mfcd then go = false end
								end
								if ID == CDOTA_Unit_Hero_Invoker then
									local emp = me:FindSpell("invoker_emp")
									local empcd = emp:GetCooldown(emp.level)
									local blast = me:FindSpell("invoker_deafening_blast")
									local blastcd = blast:GetCooldown(blast.level)
									local meteor = me:FindSpell("invoker_chaos_meteor")
									local meteorcd = meteor:GetCooldown(meteor.level)
									local sunstrike = me:FindSpell("invoker_sun_strike")
									local sunstrikecd = sunstrike:GetCooldown(sunstrike.level)
									local octa = me:FindItem("item_octarine_core")
									local spell1,spell2 = a4,a5
									if (spell1.name == "invoker_tornado" and spell1:CanBeCasted()) or (spell2.name == "invoker_tornado" and spell2:CanBeCasted()) then
										go = false
									end
									if octa then
										empcd = empcd*0.75
										blastcd = blastcd*0.75
										meteorcd = meteorcd*0.75
										sunstrikecd = sunstrikecd*0.75
									end
									empcd = empcd-3
									blastcd = blastcd-3
									meteorcd = meteorcd-5
									sunstrikecd = sunstrikecd-3
									if (emp and emp.cd > empcd) or (blast and blast.cd > blastcd) or (meteor and meteor.cd > meteorcd) or (sunstrike and sunstrike.cd > sunstrikecd) then
										go = false
									end
								end
								if (ID == CDOTA_Unit_Hero_Pudge and (tempvictim:DoesHaveModifier("modifier_pudge_rot") or (a4 and a4:CanBeCasted() and victimdistance < 400) or (a1 and a1:CanBeCasted() and victimdistance+100 > item.castRange))) or tempvictim:DoesHaveModifier("modifier_invoker_chaos_meteor_burn") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_aura") or not tempvictim:CanMove() or tempvictim:DoesHaveModifier("modifier_pudge_meat_hook") or tempvictim:IsHexed() or tempvictim:IsDisarmed() or tempvictim:IsSilenced() or movespeed < 250 or tempvictim:IsRooted() or tempvictim:DoesHaveModifier("modifier_ghost_state") or tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") then go = false end
							end
							if ID == CDOTA_Unit_Hero_Invoker then
								local tornado = me:FindSpell("invoker_tornado")
								local tornadocd = tornado:GetCooldown(tornado.level)
								if octa then
									tornadocd = tornadocd*0.75
								end
								tornadocd = tornadocd-((GetDistance2D(me,tempvictim))/1000+client.latency/1000)
								if tornado and tornado.cd > tornadocd then
									go = false
								end
							end
							local d = 0
							if itemname == "item_shivas_guard" then
								d = GetDistance2D(me,tempvictim)/350
								if ID == CDOTA_Unit_Hero_Tinker then
									data[2] = false
								end
							end
							if (not tempvictim:DoesHaveModifier("modifier_item_blade_mail_reflect") or not Dmg or Dmg < me.health) and (not tempvictim:IsMagicImmune() or type == DAMAGE_PHYS or data[5]) and not tempvictim:DoesHaveModifier("modifier_"..itemname.."_debuff") and 
							(go and (itemname ~= "item_refresher" or (item.manacost*2 < me.mana or (manaboots and item.manacost*2 < (me.mana+135))))) and 
							SleepCheck(itemname) and ((not data[2] and not tempvictim:IsInvul() and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and not tempvictim:DoesHaveModifier("modifier_eul_cyclone")) or chainStun(tempvictim,client.latency*0.001+d+(100/Animations.maxCount)*0.01 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))) or (itemname == "item_blade_mail" and chainStun(tempvictim,0,"modifier_axe_berserkers_call"))) and (not retreat or (Dmg and Dmg > enemyHP) or data[6] or data[3]) and 
							(not Dmg or data[2] or Dmg/4 < enemyHP or victimdistance > range) and ((victimdistance > range) or (Dmg and Dmg > 0) or ((not Dmg or Dmg < 1) and enemyHP > 100) or itemname == "item_phase_boots")
							and ((not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") and SleepCheck("charge")) or itemname == "item_armlet") then
								local cast
								local delay = 0
								if itemname == "item_cyclone" then 
									delay = 500 
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.team == me.team and v ~= me and GetDistance2D(tempvictim,v) < 500) end)
									if #closeEnemies > 1 then go = false end
									if xposition then 
										go = false 
									elseif coldfeet and coldfeet:CanBeCasted() then 
										go = false 
									elseif ID == CDOTA_Unit_Hero_Invoker then
										local emp = me:FindSpell("invoker_emp")
										local empcd = emp:GetCooldown(emp.level)
										local blast = me:FindSpell("invoker_deafening_blast")
										local blastcd = blast:GetCooldown(blast.level)
										local meteor = me:FindSpell("invoker_chaos_meteor")
										local meteorcd = meteor:GetCooldown(meteor.level)
										local sunstrike = me:FindSpell("invoker_sun_strike")
										local sunstrikecd = sunstrike:GetCooldown(sunstrike.level)
										local octa = me:FindItem("item_octarine_core")
										local spell1,spell2 = a4,a5
										if (spell1.name == "invoker_tornado" and spell1:CanBeCasted()) or (spell2.name == "invoker_tornado" and spell2:CanBeCasted()) then
											go = false
										end
										if octa then
											empcd = empcd*0.75
											blastcd = blastcd*0.75
											meteorcd = meteorcd*0.75
											sunstrikecd = sunstrikecd*0.75
										end
										empcd = empcd-3
										blastcd = blastcd-3
										meteorcd = meteorcd-5
										sunstrikecd = sunstrikecd-3
										if (emp and emp.cd > empcd) or (blast and blast.cd > blastcd) or (meteor and meteor.cd > meteorcd) or (sunstrike and sunstrike.cd > sunstrikecd) then
											go = false
										end
									elseif ID == CDOTA_Unit_Hero_Pudge then
										local hook = me:FindSpell("pudge_meat_hook")
										local hookcd = hook:GetCooldown(hook.level)
										local octa = me:FindItem("item_octarine_core")
										if octa then
											hookcd = hookcd*0.75
										end
										hookcd = hookcd - 2
										if (hook and hook.cd > hookcd) then go = false end
									elseif ID == CDOTA_Unit_Hero_Mirana then
										local arrow = me:FindSpell("mirana_arrow")
										local arrowcd = arrow:GetCooldown(arrow.level)
										local octa = me:FindItem("item_octarine_core")
										if octa then
											arrowcd = arrowcd*0.75
										end
										arrowcd = arrowcd - 5
										if (arrow and arrow.cd > arrowcd) or (arrow:CanBeCasted() and victimdistance+100 > item.castRange) then go = false end
									end
									if (ID == CDOTA_Unit_Hero_Pudge and (tempvictim:DoesHaveModifier("modifier_pudge_rot") or (a4 and a4:CanBeCasted() and victimdistance < 400) or (a1 and a1:CanBeCasted() and victimdistance+100 > item.castRange))) or tempvictim:DoesHaveModifier("modifier_invoker_chaos_meteor_burn") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_aura") or not tempvictim:CanMove() or tempvictim:DoesHaveModifier("modifier_pudge_meat_hook") or tempvictim:IsHexed() or tempvictim:IsDisarmed() or tempvictim:IsSilenced() or tempvictim:IsRooted() or tempvictim:DoesHaveModifier("modifier_ghost_state") or tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") then go = false end
								end
								--if itemname == "item_ethereal_blade" and dagon and dagon:CanBeCasted() then delay = (mathmin(item.castRange-50,victimdistance-100)/item:GetSpecialData("projectile_speed"))*1000 end
								if dagon and itemname == dagon.name and ((not SleepCheck("stuneth") and ethereal) or (ethereal and ethereal:CanBeCasted())) then go = false end
								if item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) and go then
									if ((item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL)) or itemname == "item_force_staff") then
										cast = me:SafeCastAbility(item,me)
									elseif (item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) or item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_CUSTOM) or item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL)) and not tempvictim:IsInvul() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_brewmaster_storm_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and (not retreat or victimdistance < item.castRange+50) then
										cast = me:SafeCastAbility(item,tempvictim)
										delay = delay + me:GetTurnTime(tempvictim)*1000 --+ (mathmax(victimdistance-50-item.castRange,0)/me.movespeed)*1000
									end
								elseif item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) and (not data[3] or victimdistance-50 < data[3]) and (itemname ~= "item_armlet" or not me:DoesHaveModifier("modifier_item_armlet_unholy_strength")) then
									cast = me:SafeCastAbility(item)
								elseif item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) or item:IsBehaviourType(LuaEntityAbility.BEHAVIOR_AOE) then
									if item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not item:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) then
										cast = me:SafeCastAbility(item,me)
									else
										delay = delay + me:GetTurnTime(tempvictim)*1000
										local delay2 = delay + client.latency
										if data[2] then delay2 = delay2 + data[2]*1000 end
										local speed = item:GetSpecialData("speed")
										local prediction
										if not speed then 
											prediction = SkillShotPredictedXYZ(tempvictim,delay2)
										else
											prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay2,speed)
										end
										if prediction then
											cast = me:SafeCastAbility(item,prediction)
										end
									end
								end
								if cast then
									if data[2] then stunAbility = item end
									if itemname == "item_cyclone" then
										Sleep(200, itemname)
										Sleep(200, "casting")
									else
										Sleep(mathmax(delay,200), itemname)
									end
									if victimdistance < item.castRange+50 or (data[3] and victimdistance-50 < data[3]) then
										Sleep(delay+client.latency,"casting")
										if itemname == "item_ethereal_blade" then Sleep(delay+(mathmin(item.castRange-100,victimdistance-100)/item:GetSpecialData("projectile_speed"))*1000, "stuneth") 
										elseif itemname == "item_cyclone" then Sleep(500, "stun") end
										if Dmg then
											enemyHP = enemyHP - Dmg
										end
										return
									end
									if itemname == "item_cyclone" then return end
								else Sleep(150,itemname) end
							end
						end
					end	
				end
				if ID == CDOTA_Unit_Hero_EarthSpirit then 
					if not a3:CanBeCasted() or SleepCheck("esstone") then esstone = false end
				end
				--Spell Combo
				if mySpells and SleepCheck("casting") and CanCast and not me:DoesHaveModifier("modifier_batrider_flaming_lasso_self") and not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") and SleepCheck("charge") then	
					local t2 = mySpells[2]
					local l2 = #t2
					for i = 1, l2 do
						local data = t2[i]
						local slot = data[1] or data
						if slot then
							local spell
							if GetType(slot) == "string" then
								spell = me:FindSpell(slot)
							else
								spell = abilities[slot]
							end
							if spell and (spell.name == "troll_warlord_whirling_axes_melee" or spell.name == "troll_warlord_whirling_axes_ranged") then
								if ((spell.cd == 0 and not spell:CanBeCasted() and me.mana >= spell.manacost) or trolltoggle) and SleepCheck("toggle") and (victimdistance < spell.castRange or (victimdistance < 450)) then
									me:ToggleSpell(a1.name)
									Sleep(200+client.latency,"toggle")
									Sleep(client.latency,"casting")
									trolltoggle = false
									return
								end
							elseif spell and spell:CanBeCasted() and (not meld or CanMove or (meld:CanBeCasted() and spell == meld) or victimdistance > range+50) then
								local distance = nil
								local delay = mathmax(spell:FindCastPoint()*1000, 50)
								if spell.name == "templar_assassin_refraction" then delay = 0 end
								if data[2] then
									distance = data[2]
								end
								if distance then
									if GetType(distance) == "string" then
										if spell.name == "invoker_tornado" then
											distance = spell:GetSpecialData(distance,wex.level)
										elseif spell.name == "invoker_deafening_blast" then
											distance = spell:GetSpecialData(distance,wex.level)
										else
											distance = spell:GetSpecialData(distance,spell.level)
										end
									end
								end
								local prediction 
								if tempvictimVisible then
									prediction = SkillShotPredictedXYZ(tempvictim,mathmax(delay, 100)+client.latency)
								else
									prediction = SkillShot.BlindSkillShotXYZ(me,tempvictim,1100,mathmax(delay, 100)/1000+client.latency/1000) 
								end
								local add = 0
								if data[4] then add = data[4] end
								if GetType(add) == "string" then
									add = spell:GetSpecialData(add,spell.level)
								end
								if me:DoesHaveModifier("modifier_ember_spirit_fire_remnant") and spell.name == "ember_spirit_sleight_of_fist" then go = false end
								local go = true
								if spell.name == "tinker_rearm" then
									for i = 1, al do
										local ab = abilities[i]
										if ab.name ~= "tinker_march_of_the_machines" and ab.name ~= "tinker_rearm" and ab:CanBeCasted() and not ab:IsBehaviourType(LuaEntityAbility.BEHAVIOR_PASSIVE) then
											go = false
											break
										end
									end
									for i = 1, il do
										local ab = items[i]
										if ab.name ~= "item_blink" and ab.name ~= "item_travel_boots" and ab.name ~= "item_refresher" and ab.name ~= "item_travel_boots_2" and ab.name ~= "item_tpscroll" and ab.abilityData.itemCost > 1000 and ab:CanBeCasted() then
											go = false
											break
										end
									end
								end
								local castRange = spell.castRange
								if spell.name == "phoenix_icarus_dive" then castRange = 1400 end
								local octa = me:FindItem("item_octarine_core")
								if spell.name == "invoker_tornado" then 
									castRange = distance 
									local emp = me:FindSpell("invoker_emp")
									local empcd = emp:GetCooldown(emp.level)
									local blast = me:FindSpell("invoker_deafening_blast")
									local blastcd = blast:GetCooldown(blast.level)
									local meteor = me:FindSpell("invoker_chaos_meteor")
									local meteorcd = meteor:GetCooldown(meteor.level)
									local sunstrike = me:FindSpell("invoker_sun_strike")
									local sunstrikecd = sunstrike:GetCooldown(sunstrike.level)
									if octa then
										empcd = empcd*0.75
										blastcd = blastcd*0.75
										meteorcd = meteorcd*0.75
										sunstrikecd = sunstrikecd*0.75
									end
									empcd = empcd-3
									blastcd = blastcd-3
									meteorcd = meteorcd-5
									sunstrikecd = sunstrikecd-3
									if (blink and blink:CanBeCasted()) or tempvictim:IsSilenced() or tempvictim:IsRooted() or tempvictim:IsStunned() or tempvictim:DoesHaveModifier("modifier_ghost_state") or tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow") or tempvictim:DoesHaveModifier("modifier_invoker_chaos_meteor_burn") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_aura") or (emp and emp.cd > empcd and quas.level > 3) or (blast and blast.cd > blastcd) or (meteor and meteor.cd > meteorcd) or (sunstrike and sunstrike.cd > sunstrikecd) then
										go = false
									end
								elseif spell.name == "lone_druid_true_form" and retreat then go = false
								elseif spell.name == "invoker_cold_snap" then
									local tornado = me:FindSpell("invoker_tornado")
									local tornadocd = tornado:GetCooldown(tornado.level)
									if octa then
										tornadocd = tornadocd*0.75
									end
									tornadocd = tornadocd-3
									if tornado and tornado.cd > tornadocd then go = false end
								elseif spell.name == "pugna_decrepify" then
									local blast = a1
									if blast and blast:CanBeCasted() then 
										go = false
									end
								elseif ID == CDOTA_Unit_Hero_Invoker and spell.name ~= "invoker_tornado" then
									local tornado = me:FindSpell("invoker_tornado")
									local tornadocd = tornado:GetCooldown(tornado.level)
									if octa then
										tornadocd = tornadocd*0.75
									end
									if spell.name == "invoker_emp" then tornadocd = tornadocd-((GetDistance2D(me,tempvictim)-350)/1000)
									else tornadocd = tornadocd-((GetDistance2D(me,tempvictim))/1000+client.latency/1000) end
									if tornado and tornado.cd > tornadocd then
										go = false
									end
								elseif spell.name == "shadow_shaman_ether_shock" and (a2:CanBeCasted() or (a3:CanBeCasted() and spell.manacost+a3.manacost > me.mana)) then go = false								
								end
								if castRange < 1 then castRange = 9999999 end
								if spell.name == "earth_spirit_boulder_smash" then 
									local grip = a3
									if grip and grip:CanBeCasted() then
										castRange = 1200
									end 
								elseif spell.name == "earth_spirit_rolling_boulder" then castRange = 1200 if not a1:CanBeCasted() and a4:CanBeCasted() then castRange = 3000 end
								elseif spell.name == "slark_pounce" then castRange = 700 end
								if not tempdamageTable[spell.name] or tempdamageTable[spell.name][2] ~= spell.level or (me:AghanimState() and not tempdamageTable[spell.name][3]) then
									damageTable[spell.name] = {AbilityDamageGetDamage(spell), spell.level, me:AghanimState()}
									tempdamageTable = damageTable
								end
								local Dmg = tempdamageTable[spell.name][1]
								if ID == CDOTA_Unit_Hero_Invoker then Dmg = AbilityDamageGetDamage(spell) end
								if spell.name == "visage_soul_assumption" then
									local modif = me:FindModifier("modifier_visage_soul_assumption")
									if modif then
										Dmg = 20
										if modif.stacks > 0 then
											Dmg = Dmg + modif.stacks*65
										end
									end
								elseif spell.name == "necrolyte_reapers_scythe" then
									if dagon and dagon:CanBeCasted() then
										if tempdamageTable[dagon.name] then
											Dmg = Dmg*(tempvictim.maxHealth - (enemyHP - tempvictim:DamageTaken(tempdamageTable[dagon.name][1],DAMAGE_MAGC,me))) + tempvictim:DamageTaken(tempdamageTable[dagon.name][1],DAMAGE_MAGC,me)
										else
											Dmg = Dmg*(tempvictim.maxHealth - (enemyHP - tempvictim:DamageTaken(AbilityDamageGetDamage(dagon),DAMAGE_MAGC,me))) + tempvictim:DamageTaken(AbilityDamageGetDamage(dagon),DAMAGE_MAGC,me)
										end
									elseif Dagon and Dagon:CanBeCasted() and ethereal and etherel:CanBeCasted() then
										if tempdamageTable[dagon.name] and tempdamageTable[ethereal.name] then
											Dmg = Dmg*(tempvictim.maxHealth - (enemyHP - tempvictim:DamageTaken(tempdamageTable[dagon.name][1],DAMAGE_MAGC,me) - tempvictim:DamageTaken(tempdamageTable[ethereal.name][1],DAMAGE_MAGC,me))) + tempvictim:DamageTaken(tempdamageTable[ethereal.name][1],DAMAGE_MAGC,me) + tempvictim:DamageTaken(tempdamageTable[dagon.name][1],DAMAGE_MAGC,me)
										else
											Dmg = Dmg*(tempvictim.maxHealth - (enemyHP - tempvictim:DamageTaken(AbilityDamageGetDamage(dagon),DAMAGE_MAGC,me) - tempvictim:DamageTaken(AbilityDamageGetDamage(ethereal),DAMAGE_MAGC,me))) + tempvictim:DamageTaken(AbilityDamageGetDamage(ethereal),DAMAGE_MAGC,me) + tempvictim:DamageTaken(AbilityDamageGetDamage(dagon),DAMAGE_MAGC,me)
										end
									else
										Dmg = Dmg*(tempvictim.maxHealth - enemyHP)
									end
									if ethereal and ethereal:CanBeCasted() then
										Dmg = Dmg*1.4
									end
								end
								local type = AbilityDamageGetDmgType(spell)
								if spell.name == "antimage_mana_void" then
									local missingMana = (tempvictim.maxMana - tempvictim.mana)
									Dmg = missingMana*Dmg
									if missingMana > tempvictim.maxMana*0.1 and tempvictim:DamageTaken(Dmg,type,me) < tempvictim.health then
										go = false
									end
								elseif ID == CDOTA_Unit_Hero_StormSpirit then
									local Overload = me:DoesHaveModifier("modifier_storm_spirit_overload")
									local pull = a2
									--print(Overload,victimdistance)
									--print((15 + me.maxMana*0.15))
									if Overload and (victimdistance < range+50 or me:DoesHaveModifier("modifier_storm_spirit_ball_lightning")) then
										go = false
									end
									if not tempvictimVisible then go = false end
									if spell.name == "storm_spirit_ball_lightning" and ((a1:CanBeCasted() and victimdistance < range+50) or (victimdistance < range+50 and (me.mana < (15 + me.maxMana*0.15) or (pull and pull:CanBeCasted() and victimdistance < pull.castRange and chainStun(tempvictim,pull:FindCastPoint() + client.latency)))) or me:DoesHaveModifier("modifier_storm_spirit_ball_lightning") or spell.abilityPhase) then
										go = false
									end
									if spell.name == "storm_spirit_static_remnant" and (victimdistance > range+50 or a4.abilityPhase or not SleepCheck("storm_spirit_ball_lightning")) and not CanMove then
										go = false
									end
								elseif spell.name == "storm_spirit_ball_lightning" and ID == CDOTA_Unit_Hero_Rubick and victimdistance < range+50 then
									go = false
								elseif spell.name == "leshrac_pulse_nova" and me:DoesHaveModifier("modifier_leshrac_pulse_nova") then go = false 
								elseif spell.name == "leshrac_split_earth" and a3 and a3:CanBeCasted() and (not (tempvictim:IsStunned() or tempvictim:IsRooted() or tempvictim:IsHexed() or not tempvictim:CanMove() or tempvictim:IsInvul()) and not Animations.isAttacking(tempvictim) and tempvictim.activity ~= LuaEntityNPC.ACTIVITY_IDLE) then go = false 
								elseif spell.name == "invoker_emp" then
									if tempvictim.mana < Dmg then
										Dmg = tempvictim.mana
									end
									Dmg = Dmg/2
									if tempvictim.mana < 100 and combo ~= 1 then
										go = false
									end
								elseif spell.name == "tusk_walrus_kick" then
									local base = entityList:GetEntities({classId = CDOTA_Unit_Fountain,team = me.team})[1]
									if not retreat then go = false end
									if GetDistance2D(me,base) > GetDistance2D(base,tempvictim) then go = true end
								elseif spell.name == "phoenix_sun_ray" then
									Dmg = Dmg + tempvictim.maxHealth*(spell:GetSpecialData("hp_perc_dmg",spell.level)/100)
								end
								if Dmg and tempvictim then
									Dmg = tempvictim:DamageTaken(Dmg,type,me)
								end
								if ID == CDOTA_Unit_Hero_Zuus then
									local staticF = a3
									if staticF and staticF.level > 0 and victimdistance < 1250 then
										Dmg = Dmg + tempvictim:DamageTaken(((staticF:GetSpecialData("damage_health_pct",staticF.level)/100)*enemyHP),DAMAGE_MAGC,me)
									end
								elseif spell.name == "necrolyte_reapers_scythe" and not (tempvictim and tempvictim:DoesHaveModifier("modifier_item_ethereal_blade_slow")) and enemyHP > Dmg then
									go = false
								end
								local channel = spell:GetChannelTime(spell.level) or 0
								if spell.name == "bane_fiends_grip" then channel = 0 end
								local speed = spell:GetSpecialData("speed", spell.level)
								if data[6] then 
									speed = spell:GetSpecialData(data[6], spell.level)
								end
								if spell.name == "shredder_timber_chain" then
									speed = speed/2
								end
								if spell.name == "earth_spirit_rolling_boulder" then speed = 800 if not a1:CanBeCasted() and a4:CanBeCasted() then speed = 1600 end
								elseif spell.name == "invoker_cold_snap" then
									local tornado = me:FindSpell("invoker_tornado")
									local tornadocd = tornado:GetCooldown(tornado.level)
									if octa then
										tornadocd = tornadocd*0.75
									end
									tornadocd = tornadocd-((GetDistance2D(me,tempvictim))/1000+client.latency/1000)
									if tornado and tornado.cd > tornadocd then
										go = false
									end
								elseif spell.name == "morphling_adaptive_strike" or spell.name == "morphling_waveform" then
									local eth = me:FindItem("item_ethereal_blade")
									if eth and eth:CanBeCasted() then
										go = false
									end
								elseif spell.name == "shadow_demon_demonic_purge" and a1 and a1:CanBeCasted() and victimdistance <= a1.castRange+100 then go = false 
								elseif (retreat or harras) and (delay > 600 or channel > 0) then
									go = false
								elseif spell.name == "ember_spirit_activate_fire_remnant" then
									local remnants = entityList:GetEntities(function (v) return (v.classId == CDOTA_BaseNPC_Additive and v.team == me.team and v.alive == true and v.name == "npc_dota_ember_spirit_remnant" and GetDistance2D(v,tempvictim) < 700) end)
									if #remnants <= 0 then go = false end
								end
								local raze1, raze2, raze3
								if ID == CDOTA_Unit_Hero_Nevermore then
									raze1, raze2, raze3 = SkillShot.InFront(me,200), SkillShot.InFront(me,450), SkillShot.InFront(me,700)
								elseif spell.name == "disruptor_glimpse" then
									local pos = positionsTable[tempvictim.handle]
									local time = gameTime-4
									local closest = nil
									local closesttime = nil
									for i,v in pairs(pos) do
										if not closest or math.abs(time-i) < closesttime then
											closest = v
											closesttime = math.abs(time-i)
										end
									end
									--print(a1.name, GetDistance2D(tempvictim,closest))
									if GetDistance2D(tempvictim,closest) < 500 or GetDistance2D(me,closest) > victimdistance then go = false end
									local a3cd = a3:GetCooldown(a3.level)
									a3cd = a3cd - 3.800
									if a3.cd > a3cd then go = false end
									if not tempvictim:DoesHaveModifier("modifier_disruptor_thunder_strike") and a1:CanBeCasted() and victimdistance < a1.castRange+200 and not me.visibleToEnemy then go = false end
									--print(go)
								elseif spell.name == "rubick_spell_steal" and a5 and (a5:CanBeCasted() or (a5.cd < 5 and a5.manacost < me.mana)) and a5.name ~= "rubick_empty1" then go = false end
								local speeddist = 0	
								local radius = spell:GetSpecialData("radius") or spell:GetSpecialData("area_of_effect") or distance or 100
								if data[8] then
									radius = spell:GetSpecialData(data[8], spell.level)
								end
								--if distance then radius = distance end
								--print(radius)
								if spell.name == "ember_spirit_fire_remnant" then speed = me.movespeed*2.5 if not config.EMBERUseUlti then go = false end end
								if speed then speeddist = math.abs(victimdistance-100)/speed end
								if ID == CDOTA_Unit_Hero_Lion and spell.name ~= "lion_voodoo" and a2 and a2:CanBeCasted() and not tempvictim:IsInvul() then go = false
								elseif ID == CDOTA_Unit_Hero_ShadowShaman and spell.name ~= "shadow_shaman_voodoo" and a2 and a2:CanBeCasted() then go = false 
								--elseif spell.name == "lion_impale" then speeddist = (victimdistance)/speed 
								elseif spell.name == "kunkka_torrent" and (a3:CanBeCasted() or a3.cd < 3) and a3.name == "kunkka_x_marks_the_spot" then go = false 
								--if spell.name == "earth_spirit_rolling_boulder" then speeddist = (victimdistance-100)/speed end
								elseif spell.name == "shadow_shaman_shackles" then channel = 0 
								--if spell.name == "windrunner_powershot" then print((a1 and (a1:CanBeCasted() or a1.cd < 3)), (victimdistance+100 > a1.castRange and enemyHP <= Dmg), not chainStun(tempvictim,delay*0.001 + (100/Animations.maxCount)*0.001 + client.latency*0.001 + add + channel + me:GetTurnTime(tempvictim),nil,true)) end
								elseif spell.name == "windrunner_powershot" and ((a1 and enemyHP > Dmg and (a1:CanBeCasted() or a1.cd < 3 or not chainStun(tempvictim,delay*0.001 + (100/Animations.maxCount)*0.001 + client.latency*0.001 + add + channel + me:GetTurnTime(tempvictim),nil,true) or chainStun(tempvictim,delay*0.001 + (100/Animations.maxCount)*0.001 + client.latency*0.001 + add + me:GetTurnTime(tempvictim),nil,true)))) then go = false
								elseif spell.name == "kunkka_ghostship" then
									if a3:CanBeCasted() and a3.name ~= "kunkka_return" then go = false end
									if a3.name == "kunkka_return" and not xposition then xposition = tempvictim.position end
								elseif spell.name == "visage_soul_assumption" then 
									local modif = me:FindModifier("modifier_visage_soul_assumption")
									if not modif or (modif.stacks ~= spell.level+2 and Dmg < enemyHP) then
										go = false
									end
								elseif spell.name == "disruptor_thunder_strike" and xposition and victimdistance > castRange then
									go = false
								elseif spell.name == "gyrocopter_flak_cannon" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(me,v) < 1000) end)
									if #closeEnemies < 1 then
										go = false
									end
								elseif spell.name == "dark_seer_ion_shell" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and v ~= tempvictim and not v:DoesHaveModifier("modifier_dark_seer_ion_shell") and GetDistance2D(tempvictim,v) < 350) end)
									if #closeEnemies < 1 then
										go = false
									else
										tablesort(closeEnemies, function (a,b) return GetDistance2D(a,tempvictim) < GetDistance2D(b,tempvictim) end)
										local closest = closeEnemies[1]
										if closest then
											me:CastAbility(spell,closest) Sleep(300, "dark_seer_ion_shell") Sleep(delay, "casting") return
										end
									end
								elseif spell.name == "dark_seer_surge" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and v.team == me.team and v ~= tempvictim and GetDistance2D(tempvictim,v) < 1000) end)
									if #closeEnemies < 1 then
										go = false
									else
										tablesort(closeEnemies, function (a,b) return GetDistance2D(a,tempvictim) < GetDistance2D(b,tempvictim) end)
										local closest = closeEnemies[1]
										if closest then
											me:CastAbility(spell,closest) Sleep(300, "dark_seer_ion_shell") Sleep(delay, "casting") return
										end
									end
								elseif spell.name == "dark_seer_wall_of_replica" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(tempvictim,v) < 700) end)
									if #closeEnemies < 3 then
										go = false
									end
								elseif spell.name == "terrorblade_sunder" and SleepCheck("terrorblade_sunder") then
									local myPercent = me.health/me.maxHealth
									local possibleEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and GetDistance2D(me,v) < castRange+150 and v.health/v.maxHealth > (myPercent+0.3)) end)
									if myPercent > 0.5 then go = false
									elseif #possibleEnemies > 0 then
										local maxHP = nil
										for i = 1, #possibleEnemies do
											local v = possibleEnemies[i]
											if not maxHP or maxHP.health/maxHP.maxHealth < v.health/v.maxHealth then
												maxHP = v
											end
										end
										if maxHP then me:CastAbility(spell,maxHP) Sleep(300, "terrorblade_sunder") Sleep(delay, "casting") return
										else go = false end
									else
										go = false
									end
								elseif spell.name == "shredder_return_chakram" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and v.visible and not v:IsIllusion() and v.team ~= me.team and GetDistance2D(lastChakram1,SkillShotPredictedXYZ(v,client.latency+0.1)) < radius and v.health > AbilityDamage.GetDamage(a4)/2) end)
									--print(AbilityDamage.GetDamage(a4))
									if #closeEnemies > 0 then go = false
									else go = true
									end
								elseif spell.name == "shredder_return_chakram_2" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and v.visible and not v:IsIllusion() and v.team ~= me.team and GetDistance2D(lastChakram2,SkillShotPredictedXYZ(v,client.latency+0.1)) < radius and v.health > AbilityDamage.GetDamage(a4)/2) end)
									if #closeEnemies > 0 then go = false
									else go = true
									end
								elseif spell.name == "warlock_fatal_bonds" then
									local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.team ~= me.team and v.alive and v ~= tempvictim and GetDistance2D(SkillShotPredictedXYZ(tempvictim,delay),v) < 680) end)
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(SkillShotPredictedXYZ(tempvictim,delay),SkillShotPredictedXYZ(v,delay)) < 680) end)
									if #closeUnits < 2 and #closeEnemies < 1 then go = false
									elseif #closeUnits > 0 and victimdistance > castRange then
										tablesort(closeUnits, function (a,b) return GetDistance2D(a,me) < GetDistance2D(b,me) end)
										local closest = closeUnits[1]
										if closest and GetDistance2D(closest,me) < victimdistance then
											me:CastAbility(spell,closest) Sleep(300, "warlock_fatal_bonds") Sleep(delay, "casting") return
										end
									end
								elseif spell.name == "ursa_enrage" and not retreat then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(tempvictim,v) < 700) end)
									if #closeEnemies < 1 then go = false end
								elseif spell.name == "winter_wyvern_splinter_blast" then
									local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.team ~= me.team and v.alive and v ~= tempvictim and GetDistance2D(tempvictim,v) < 500) end)
									if #closeUnits < 1 then go = false
									elseif #closeUnits > 0 then
										tablesort(closeUnits, function (a,b) return GetDistance2D(a,tempvictim) < GetDistance2D(b,tempvictim) end)
										local closest = closeUnits[1]
										if closest then
											me:CastAbility(spell,closest) Sleep(300, "winter_wyvern_splinter_blast") Sleep(delay, "casting") return
										end
									end
								elseif spell.name == "earth_spirit_stone_caller" and (not tempvictim:DoesHaveModifier("modifier_earth_spirit_magnetize") or tempvictim:FindModifier("modifier_earth_spirit_magnetize").remainingTime > (client.latency*0.001 + me:GetTurnTime(tempvictim) + 0.5 + delay*0.001) or not UseStones) then
									go = false
								elseif spell.name == "puck_ethereal_jaunt" then								
									local orb = FindEntity(entityList:GetEntities({classId=CDOTA_BaseNPC}),me,800,nil)
									if not orb then go = false
									elseif (GetDistance2D(tempvictim,orb) > 225 or GetDistance2D(me,orb)+200 < victimdistance) and GetDistance2D(PuckPosition,orb) < 1500 and (not retreat or GetDistance2D(PuckPosition,orb) < 1500) then go = false end
								elseif spell.name == "undying_tombstone" then
									local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(me,v) < 700) end)
									if #closeEnemies < 2 then
										go = false
									end
								elseif spell.name == "earthshaker_echo_slam" then
									local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.team ~= me.team and v.alive and v ~= tempvictim and GetDistance2D(me,v) < 600) end)
									if #closeUnits < 2 then
										go = false
									end
								elseif spell.name == "undying_soul_rip" then
									local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.alive and v ~= tempvictim and GetDistance2D(me,v) < 1000) end)
									if #closeUnits < 3 then
										go = false
									end
								elseif spell.name == "tusk_ice_shards" and me:DoesHaveModifier("modifier_tusk_snowball_movement") then
									go = false
								elseif spell.name == "nevermore_requiem" and (not tempvictim:IsInvul() or chainStun(tempvictim,delay*0.0004 + client.latency*0.001)) then
									go = false
								elseif ID == CDOTA_Unit_Hero_EarthSpirit then
									local petrify = me:FindSpell("earth_spirit_petrify")
									if spell.name ~= "earth_spirit_petrify" and spell.name ~= "earth_spirit_rolling_boulder" and petrify:CanBeCasted() and enemyHP > tempvictim.maxHealth*0.5 then
										go = false
										--print(5)
									elseif spell.name == "earth_spirit_petrify" then
										local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.team == me.team and v ~= me and GetDistance2D(tempvictim,v) < 500) end)
										if #closeEnemies > 1 then go = false end
										if me.mana < (spell.manacost + a2.manacost + a1.manacost) and not retreat then go = false end
									elseif tempvictim:DoesHaveModifier("modifier_earthspirit_petrify") and a2:CanBeCasted() and spell.name ~= "earth_spirit_rolling_boulder" and (spell.name ~= "earth_spirit_boulder_smash" or victimdistance > 300) then
										--print(4)
										go = false
									elseif spell.name == "earth_spirit_geomagnetic_grip" or spell.name == "earth_spirit_rolling_boulder" then
										if spell.name == "earth_spirit_rolling_boulder" and (me.mana - spell.manacost) < a3.manacost then
											--print(2)
											go = false
										end
										local smash = a1
										if not tempvictim:DoesHaveModifier("modifier_earthspirit_petrify") and SleepCheck("earth_spirit_petrify") and smash:CanBeCasted() and not smash.abilityPhase and a4:CanBeCasted() and not petrify:CanBeCasted() and spell.name ~= "earth_spirit_petrify" then go = false end
										local base = entityList:GetEntities({classId = CDOTA_Unit_Fountain,team = me.team})[1]		
										if tempvictim:DoesHaveModifier("modifier_earthspirit_petrify") and (spell.name ~= "earth_spirit_rolling_boulder" or victimdistance > 700) and (spell.name ~= "earth_spirit_boulder_smash" or (victimdistance < 300 and GetDistance2D(me,base)+25 > GetDistance2D(tempvictim,base))) then
											--print(1)
											go = false
										end
									end
								end
								--print(go,spell.name) 
								local cast = nil
								local chanab = me:GetChanneledAbility()
								local chaindelay = delay*0.001 + client.latency*0.001 + add + channel + speeddist + me:GetTurnTime(tempvictim)
								if spell.name == "phoenix_sun_ray" and me:DoesHaveModifier("modifier_phoenix_icarus_dive") then go = false end
								--print((1/Animations.maxCount)*3*(1 + (1 - 1/Animations.maxCount)))
								--print(go,chanab,(not spell.abilityPhase or spell:FindCastPoint() <= 0),spell.name,((not data[3] and spell.name ~= "invoker_sun_strike" and spell.name ~= "invoker_emp" and spell.name ~= "invoker_chaos_meteor") or (chainStun(tempvictim,chaindelay) and (spell.name ~= "earth_spirit_rolling_boulder" or victimdistance < 400))), 
								--(not Dmg or data[3] or Dmg/4 < enemyHP or spell.name == "invoker_sun_strike" or spell.name == "ember_spirit_activate_fire_remnant" or (victimdistance > (range+200+(me.movespeed*(delay/1000))) and victimdistance < castRange+radius) or spell.name == "axe_culling_blade" or spell.name == "legion_commander_duel") , (spell.name ~= "sniper_assassinate" or victimdistance > range+100) , (spell.name ~= "shadow_shaman_mass_serpent_ward" or (victimdistance < castRange-50 and victimdistance > 300)) and (not data[5] or (spell.name ~= "axe_culling_blade" or Dmg >= tempvictim.health)) and ((victimdistance > (range+200+(me.movespeed*(delay/1000))) or (Dmg and Dmg > 0) or ((not Dmg or Dmg < 1) and enemyHP > 100))) and (not retreat or (Dmg and enemyHP and Dmg > enemyHP) or not data[11] or (data[3] and not data[11])))
								-- if spell.name == "invoker_chaos_meteor" then
									-- print((not data[3] and not tempvictim:IsInvul() and spell.name ~= "invoker_sun_strike" and spell.name ~= "invoker_emp" and spell.name ~= "invoker_chaos_meteor") , (chainStun(tempvictim,chaindelay) and (spell.name ~= "earth_spirit_rolling_boulder" or victimdistance < 400)))
								-- end
								--if spell.name =="lion_impale" then
								--print((not spell.abilityPhase or spell:FindCastPoint() <= 0) , not chanab , tempvictim , (not harras or (spell.manacost < me.mana*0.2 and victimdistance < range+100)) , (not tempvictim:IsMagicImmune() or type == DAMAGE_PHYS or data[10]) , go , SleepCheck(spell.name) , ((not data[3] and not tempvictim:IsInvul() and (ID == CDOTA_Unit_Hero_Invoker or SleepCheck("stuneth")) and ((not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and not tempvictim:DoesHaveModifier("modifier_eul_cyclone")) or spell.name == "invoker_emp")) or (chainStun(tempvictim,chaindelay) and (spell.name ~= "earth_spirit_rolling_boulder" or victimdistance < 400))) , 
								--(not Dmg or data[3] or Dmg/2.5 < enemyHP or spell.abilityType ~= LuaEntityAbility.TYPE_ULTIMATE or spell.name == "invoker_sun_strike" or spell.name == "ember_spirit_activate_fire_remnant" or (victimdistance > (range+(me.movespeed*(delay/1000))) and victimdistance < castRange+radius) or spell.name == "axe_culling_blade" or spell.name == "legion_commander_duel") , (spell.name ~= "sniper_assassinate" or (victimdistance > range+100 and enemyHP < Dmg)) , (spell.name ~= "shadow_shaman_mass_serpent_ward" or (victimdistance > 100)) and (not data[5] or Dmg >= tempvictim.health) and ((victimdistance > (range+200+(me.movespeed*(delay/1000))) or (Dmg and Dmg > 0) or (not Dmg or Dmg < 1) or data[3])) and (not retreat or (Dmg and enemyHP and Dmg > enemyHP) or not data[11] or (data[3] and not data[11])))
								--end
								--print(spell.name)
								if (meDmg < enemyHP or (((delay*0.001 + add + channel) < Animations.GetAttackTime(me) or victimdistance > range+150) and Dmg > enemyHP)) and (not tempvictim:DoesHaveModifier("modifier_item_blade_mail_reflect") or Dmg < me.health) and (not spell.abilityPhase or spell:FindCastPoint() <= 0) and not chanab and tempvictim and (not harras or (spell.manacost < me.mana*0.2 and victimdistance < range+100)) and (not tempvictim:IsMagicImmune() or type == DAMAGE_PHYS or data[10]) and go and SleepCheck(spell.name) and ((not data[3] and not tempvictim:IsInvul() and (ID == CDOTA_Unit_Hero_Invoker or SleepCheck("stuneth")) and ((not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and not tempvictim:DoesHaveModifier("modifier_eul_cyclone")) or spell.name == "invoker_emp")) or ((chainStun(tempvictim,chaindelay) or (not tempvictim:IsInvul() and Dmg > enemyHP) or not SleepCheck("earth_spirit_petrify") or (ID == CDOTA_Unit_Hero_EarthSpirit and tempvictim:DoesHaveModifier("modifier_earthspirit_petrify"))) and (spell.name ~= "earth_spirit_rolling_boulder" or victimdistance < 400))) and 
								(not Dmg or data[3] or Dmg/2.5 < enemyHP or spell.abilityType ~= LuaEntityAbility.TYPE_ULTIMATE or spell.name == "invoker_sun_strike" or spell.name == "ember_spirit_activate_fire_remnant" or (victimdistance > (range+(me.movespeed*(delay/1000))) and victimdistance < castRange+radius) or spell.name == "axe_culling_blade" or spell.name == "legion_commander_duel") and (spell.name ~= "sniper_assassinate" or (victimdistance > range+100 and enemyHP < Dmg)) and (spell.name ~= "shadow_shaman_mass_serpent_ward" or (victimdistance > 100)) and (not data[5] or Dmg >= tempvictim.health) and ((victimdistance > (range+200+(me.movespeed*(delay/1000))) or (Dmg and Dmg > 0) or (not Dmg or Dmg < 1) or data[3])) and (not retreat or (Dmg and enemyHP and Dmg > enemyHP) or not data[11] or (data[3] and not data[11])) then
									--print(spell.name)
									if spell.name == "shadow_shaman_shackles" then channel = spell:GetChannelTime(spell.level)
									elseif spell.name == "bane_fiends_grip" then channel = spell:GetChannelTime(spell.level) end
									if spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_UNIT_TARGET) and spell.name ~= "magnataur_shockwave" and spell.name ~= "lion_impale" and tempvictimVisible and (spell.name ~= "earth_spirit_boulder_smash" or not a4:CanBeCasted() or tempvictim:DoesHaveModifier("modifier_earthspirit_petrify")) and spell.name ~= "earth_spirit_geomagnetic_grip" then
										lastCastPrediction = nil
										if not me:IsMagicImmune() and spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not DoesHaveModifier("modifier_"..spell.name) and not DoesHaveModifier("modifier_"..spell.name.."_debuff") and not spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL) and spell.name ~= "bloodseeker_bloodrage" then
											cast = me:SafeCastAbility(spell,me)
										elseif (spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) or spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_CUSTOM) or spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALL)) and not tempvictim:IsInvul() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado") and (victimdistance < mathmax(castRange+500, 1000) or spell.name == "kunkka_x_marks_the_spot" or data[3]) and (not retreat or victimdistance < castRange+50) and ((not tempvictim:DoesHaveModifier("modifier_"..spell.name) and not tempvictim:DoesHaveModifier("modifier_"..spell.name.."_debuff")) or spell.name == "bristleback_viscous_nasal_goo" or spell.name == "disruptor_glimpse") then
											if spell.name == "earth_spirit_boulder_smash" then	
												local remn = entityList:GetEntities({classId = CDOTA_Unit_Earth_Spirit_Stone})
												local found = false
												for i = 1, #remn do
													local v = remn[i]
													local calc1 = (mathfloor(mathsqrt((tempvictim.position.x-v.position.x)^2 + (tempvictim.position.y-v.position.y)^2)))
													local calc2 = (mathfloor(mathsqrt((me.position.x-v.position.x)^2 + (me.position.y-v.position.y)^2)))
													local calc4 = (mathfloor(mathsqrt((me.position.x-tempvictim.position.x)^2 + (me.position.y-tempvictim.position.y)^2)))
													if calc1 < calc4 and calc2 < calc4 and GetDistance2D(me,v) < 300 then
														found = true
														esstone = true
														cast = me:SafeCastAbility(spell,tempvictim)
														Sleep(me:GetTurnTime(tempvictim)*1000, "casting")
														Sleep(me:GetTurnTime(prediction)*1000+spell:FindCastPoint()*1000+((victimdistance+500)/speed)*1000+client.latency+200, "esstone")
														Sleep(me:GetTurnTime(prediction)*1000+client.latency+client.latency+spell:FindCastPoint()*1000, "moving")
														Sleep(me:GetTurnTime(tempvictim)*1000+spell:FindCastPoint()*1000+client.latency,spell.name)
														return
													end
												end
												local base = entityList:GetEntities({classId = CDOTA_Unit_Fountain,team = me.team})[1]
												if victimdistance < 300 and GetDistance2D(me,base)+50 > GetDistance2D(tempvictim,base) then
													cast = me:SafeCastAbility(spell,tempvictim)
													Sleep(me:GetTurnTime(tempvictim)*1000, "casting")
													Sleep(me:GetTurnTime(prediction)*1000+client.latency+client.latency+spell:FindCastPoint()*1000, "moving")
													Sleep(me:GetTurnTime(tempvictim)*1000+spell:FindCastPoint()*1000+client.latency,spell.name)
													return
												end
											else
												cast = me:SafeCastAbility(spell,tempvictim)
												delay = delay + me:GetTurnTime(tempvictim)*1000 --+ (mathmax(victimdistance-50-castRange,0)/me.movespeed)*1000
												if spell.name == "spirit_breaker_charge_of_darkness" then Sleep(delay + me:GetTurnTime(tempvictim)*1000 + 1000, "charge") end
											end
										end
									elseif ((spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_NO_TARGET) and spell.name ~= "slark_pounce" and spell.name ~= "nevermore_shadowraze1" and spell.name ~= "nevermore_shadowraze2" and spell.name ~= "nevermore_shadowraze3") or (spell.name == "invoker_deafening_blast" and quas.level == 7 and wex.level == 7 and exort.level == 7)) and tempvictimVisible and  
									((not tempvictim:DoesHaveModifier("modifier_"..spell.name) and (spell.name ~= "tinker_heat_seeking_missile" or not tempvictim:DoesHaveModifier("modifier_eul_cyclone")) and not tempvictim:DoesHaveModifier("modifier_"..spell.name.."_debuff") and not DoesHaveModifier("modifier_"..spell.name)) or spell.name == "bristleback_quill_spray") and tempvictimVisible and not DoesHaveModifier("modifier_"..spell.name.."_debuff") then
										lastCastPrediction = nil
										if spell.name == "invoker_ice_wall" and prediction and (GetDistance2D(me,prediction)-50) > 200 and (GetDistance2D(me,prediction)-50) < 610 then
											local mepred = SkillShotPredictedXYZ(me,client.latency+100)
											if not facing then
												mepred = (me.position - tempvictim.position) * 50 / GetDistance2D(me,tempvictim) + tempvictim.position
											end
											local v = {prediction.x-mepred.x,prediction.y-mepred.y}
											local mathacos = math.acos
											local a = mathacos(175/GetDistance2D(prediction,mepred))
											local vec1, vec2 = nil, nil
											if a ~= nil then
												local x1 = rotateX(v[1],v[2],a)
												local y1 = rotateY(v[1],v[2],a)
												if x1 and y1 then      
													local k = {x1*50/mathsqrt((x1*x1)+(y1*y1)),y1*50/mathsqrt((x1*x1)+(y1*y1))}
													vec1 = Vector(k[1]+mepred.x,k[2]+mepred.y,mepred.z)
												end
											end
											if not vec1 then vec1 = vec2 end
											if vec1 and vec2 and me:GetTurnTime(vec2) < me:GetTurnTime(vec1) then
												vec1 = vec2
											end
											if vec1 and GetDistance2D(me,vec1) > 0 then
												me:Move(mepred)
												me:Move(vec1,true)
												cast = me:SafeCastAbility(spell,true)
												Sleep((GetDistance2D(me,vec1)/me.movespeed)*1000+me:GetTurnTime(vec1)*1000+500, "casting")
												Sleep((GetDistance2D(me,vec1)/me.movespeed)*1000+me:GetTurnTime(vec1)*1000+500, "moving")
												return
											end
										elseif (spell.name ~= "templar_assassin_meld" or (not retreat and not CanMove and GetDistance2D(mePosition,SkillShotPredictedXYZ(tempvictim,client.latency+spell:FindCastPoint()*1000+me:GetTurnTime(tempvictim)*1000)) <= range+50)) then													
											if spell.name ~= "invoker_ice_wall" or (retreat or facing) then
												local prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay,999999)
												if prediction and (not distance or GetDistance2D(prediction,mePosition) < distance or a2.name == "elder_titan_return_spirit") then
													cast = me:SafeCastAbility(spell)
												end
											end
											if spell.name == "templar_assassin_meld" then
												me:Attack(tempvictim)
												delay = delay + me:GetTurnTime(tempvictim)*1000 + Animations.GetAttackTime(me)*1000
												Sleep(delay + me:GetTurnTime(tempvictim)*1000 + Animations.GetAttackTime(me)*1000 + client.latency, "casting")
											end
										end
									elseif spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_POINT) or spell:IsBehaviourType(LuaEntityAbility.BEHAVIOR_AOE) or spell.name == "slark_pounce" or (spell.name == "nevermore_shadowraze1" and prediction and GetDistance2D(prediction,raze1) < 250) or (spell.name == "nevermore_shadowraze2" and prediction and GetDistance2D(prediction,raze2) < 250) or (spell.name == "nevermore_shadowraze3" and prediction and GetDistance2D(prediction,raze3) < 250) then
										--print(spell.name, prediction, )
										if not me:IsMagicImmune() and spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ALLIED) and not spell:IsTargetTeam(LuaEntityAbility.TARGET_TEAM_ENEMY) and spell.name ~= "earth_spirit_geomagnetic_grip" then
											lastCastPrediction = nil
											cast = me:SafeCastAbility(spell,me.position)
										elseif ((prediction and tempvictimAlive and (GetDistance2D(prediction,mePosition) < castRange+radius or (xposition and GetDistance2D(xposition,me) < castRange+radius))) or (spell.name == "earth_spirit_rolling_boulder" and retreat)) then
											delay = delay + me:GetTurnTime(tempvictim)*1000
											local delay2 = delay + client.latency + channel*1000 + ((1 / Animations.maxCount) * 3 * (1 + (1 - 1/ Animations.maxCount)))*1000
											if data[4] then delay2 = delay2 + data[4]*1000 end
											local prediction
											if not speed or speed == 0 then speed = 9999999 end
											if tempvictimVisible then
												if data[7] then
													local radius = spell:GetSpecialData(data[8], spell.level)
													prediction = SkillShotBlockableSkillShotXYZ(mePosition,tempvictim,speed,delay2,radius,data[9])
													if prediction then
														prediction = SkillShotBlockableSkillShotXYZ(mePosition,tempvictim,speed,delay2+me:GetTurnTime(prediction)*1000,radius,data[9])
													end
												else
													prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay2,speed,radius)
													if prediction then
														prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,delay2+me:GetTurnTime(prediction)*1000,speed,radius)
													end
												end
											else
												if data[7] then
													local radius = spell:GetSpecialData(data[8], spell.level)
													prediction = SkillShot.BlockableBlindSkillShotXYZ(me,tempvictim,speed,delay2/1000,radius,data[9])
												else
													prediction = SkillShot.BlindSkillShotXYZ(me,tempvictim,speed,delay2/1000)
												end
											end
											if spell.name == "rubick_telekinesis_land" then prediction = me.position end
											if xposition then prediction = xposition end
											if prediction or (spell.name == "earth_spirit_rolling_boulder" and retreat) then
												local preddist = 0
												if spell.name == "skywrath_mage_mystic_flare" then
													if (not chainStun(tempvictim, delay2, nil, true) and (not tempvictim:IsStunned() and not tempvictim:IsHexed() and not tempvictim:IsRooted()) and enemyHP > Dmg and not tempvictim:DoesHaveModifier("modifier_skywrath_mage_concussive_shot_slow")) or tempvictim:DoesHaveModifier("modifier_eul_cyclone") or tempvictim:DoesHaveModifier("modifier_invoker_tornado") then
														go = false
													end
												elseif spell.name == "storm_spirit_ball_lightning" then
													local pull = a2
													if prediction then preddist = GetDistance2D(prediction,mePosition) end
													local manaReq = (15 + me.maxMana*0.07 + ((preddist*0.01)*(12+(me.maxMana*0.0075))))
													if me.mana < manaReq then
														if victimdistance < range+50 then 
															prediction = SkillShotPredictedXYZ(me,client.latency)
														else go = false end
													elseif pull and pull:CanBeCasted() and (me.mana-pull.manacost) < manaReq and victimdistance < pull.castRange then
														go = false
													end
													if victimdistance+50 < preddist then
														prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)+200) / GetDistance2D(prediction,tempvictim) + tempvictim.position
													end
												elseif spell.name == "ember_spirit_fire_remnant" then
													if me.mana < 150 or (victimdistance < 500 and not retreat) then go = false end
													if retreat then prediction = client.mousePosition
														prediction = (prediction - me.position) * 1500 / GetDistance2D(prediction,me) + me.position
													else
														local ulti = me:FindSpell("ember_spirit_activate_fire_remnant")
														if not tempdamageTable["ember_spirit_activate_fire_remnant"] or tempdamageTable["ember_spirit_activate_fire_remnant"][2] ~= ulti.level then
															damageTable["ember_spirit_activate_fire_remnant"] = {AbilityDamageGetDamage(ulti), ulti.level, me:AghanimState()}
															tempdamageTable = damageTable
														end
														local ultiDamage = tempdamageTable["ember_spirit_activate_fire_remnant"][1]
														ultiDamage = tempvictim:DamageTaken(ultiDamage,DAMAGE_MAGC,me)
														if me.mana < 260 and enemyHP > ultiDamage then go = false end
														if ((me.mana > 650 and enemyHP < ultiDamage*3) or (me.mana > 300 and enemyHP < ultiDamage*2)) and (tempvictim:IsStunned() or tempvictim:IsRooted()) and victimdistance < 500 and speed > 500 then delay = 0 go = true  
														else 
														local remnants = entityList:GetEntities({classId=CDOTA_BaseNPC_Additive, team=me.team, alive=true})
														for i = 1, #remnants do
															local v = remnants[i]
															if GetDistance2D(v,prediction) < 500 then
																go = false
															end
														end
														delay = delay + (victimdistance/speed)*1000 - (victimdistance/1300)*1000 end
													end
												end
												if prediction then preddist = GetDistance2D(prediction,mePosition) end
												if preddist < castRange+radius then
													if preddist > castRange then	
														if ID == CDOTA_Unit_Hero_EmberSpirit then
															prediction = (prediction - mePosition) * ((castRange+300) - (radius/2)) / preddist + mePosition
														elseif spell.name ~= "tusk_ice_shards" then
															prediction = (prediction - mePosition) * (castRange) / preddist + mePosition
														end
													end
													if ID == CDOTA_Unit_Hero_Invoker then
														local tornado = me:FindSpell("invoker_tornado")
														if tornado then
															local tornadocd = tornado:GetCooldown(tornado.level)
															if octa then
																tornadocd = tornadocd*0.75
															end
															tornadocd = tornadocd-((GetDistance2D(me,tempvictim))/1000+client.latency/1000)-0.1
															if tornado and (tornado.cd > tornadocd or tornado:CanBeCasted()) then
																prediction = tempvictim.position
															end
														end
													end
													if spell.name == "tusk_ice_shards" and victimdistance+50 < preddist then
														prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)+225) / GetDistance2D(prediction,tempvictim) + tempvictim.position
													elseif spell.name == "earthshaker_fissure" and victimdistance+50 < preddist then
														prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)+225) / GetDistance2D(prediction,tempvictim) + tempvictim.position
													elseif spell.name == "invoker_emp" and GetDistance2D(prediction,tempvictim) > 675 then
														prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)/2) / GetDistance2D(prediction,tempvictim) + tempvictim.position
														if combo ~= 0 and combo ~= 3 then prediction = client.mousePosition end
													elseif spell.name == "bloodseeker_blood_bath" and GetDistance2D(prediction,tempvictim) > 300 then
														prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)/2) / GetDistance2D(prediction,tempvictim) + tempvictim.position
														if combo ~= 0 and combo ~= 3 then prediction = client.mousePosition end
													elseif ID == CDOTA_Unit_Hero_Rubick and spell.name ~= "rubick_telekinesis_land" then
														if tempvictim:DoesHaveModifier("modifier_rubick_telekinesis") then
															prediction = (mePosition - tempvictim.position) * (math.min(victimdistance,275)) / GetDistance2D(me,tempvictim.position) + tempvictim.position
														end
													elseif spell.name == "invoker_sun_strike" then
														local spell1,spell2 = a4, a5							
														if (not chainStun(tempvictim, delay2, nil, true) and not tempvictim:IsStunned() and not tempvictim:IsRooted() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:IsHexed() and not tempvictim:DoesHaveModifier("modifier_invoker_tornado")) and enemyHP > Dmg then
															go = false
														end
														if GetDistance2D(prediction,tempvictim) > 50 and ((((spell1.name == "invoker_cold_snap" and spell1:CanBeCasted()) or (spell2.name == "invoker_cold_snap" and spell2:CanBeCasted()))) or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap_freeze")) then
															if victimdistance < range/1.5 then
																prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)/2) / GetDistance2D(prediction,tempvictim) + tempvictim.position
															else
																prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)/1.5) / GetDistance2D(prediction,tempvictim) + tempvictim.position
															end
															go = true
														end
														if tempvictim.activity == LuaEntityNPC.ACTIVITY_MOVE and directiontable[tempvictim.handle] and directiontable[tempvictim.handle][3] < 3 then go = false end
														--local refresher = me:FindItem("item_refresher")
														--if combo == 3 or combo == 2 then
														local blast = me:FindSpell("invoker_deafening_blast")
														if blast then
															local blastcd = blast:GetCooldown(blast.level)
															if octa then
																blastcd = blastcd*0.75
															end
															blastcd = blastcd-((GetDistance2D(me,tempvictim)+100)/1100+client.latency/1000)
															if blast and (blast.cd > blastcd or blast:CanBeCasted() or tempvictim:DoesHaveModifier("modifier_invoker_deafening_blast_knockback")) then
																if tempvictim:DoesHaveModifier("modifier_invoker_deafening_blast_knockback") then
																	prediction = (tempvictim.position - me.position) * (GetDistance2D(tempvictim,me)+100) / GetDistance2D(tempvictim,me) + me.position
																elseif GetDistance2D(tempvictim,prediction) > 50 then																
																	prediction = (prediction - me.position) * (GetDistance2D(prediction,me)+200) / GetDistance2D(prediction,me) + me.position
																else
																	prediction = (tempvictim.position - me.position) * (GetDistance2D(tempvictim,me)+200) / GetDistance2D(tempvictim,me) + me.position
																end
															end
														end
														--end
														-- if combo == 2 then
															-- if refresher.cd > 0 and comboready and GetDistance2D(tempvictim,prediction) > 50 then
																-- prediction = (prediction - me.position) * (GetDistance2D(prediction,me)+100) / GetDistance2D(prediction,me) + me.position
															-- end
														-- end
													elseif spell.name == "shredder_timber_chain" then
														if retreat then prediction = client.mousePosition end
														local trees = Trees
														local closest = nil
														local id = nil
														for i,v in ipairs(trees) do
															--local v = trees[i]
															if not v.cutted and GetDistance2D(v.position,me) < castRange-50 and GetDistance2D(prediction,v.position) < GetDistance2D(me,v.position) and GetDistance2D(v.position,me) > victimdistance and ((GetDistance2D(prediction,v.position) + GetDistance2D(me,prediction)) - GetDistance2D(me,v.position) < 50 or (GetDistance2D(prediction,me) < 225 and Dmg < enemyHP)) then
																if not closest or GetDistance2D(v.position,me) < GetDistance2D(closest,me) then
																	closest = v.position
																	id = i
																end
															end
														end
														if not closest then Sleep(200,"shredder_timber_chain") go = false
														else
															prediction = closest
															lastTreeID = id
														end
													elseif spell.name == "invoker_chaos_meteor" then
														--print(gameTime)
														local spell1,spell2 = a4, a5
														if ((not chainStun(tempvictim, delay2, nil, true) and combo == 0) and not tempvictim:IsStunned() and not tempvictim:IsHexed() and not tempvictim:IsRooted() and not tempvictim:DoesHaveModifier("modifier_eul_cyclone") and not tempvictim:DoesHaveModifier("modifier_invoker_tornado")) and (enemyHP > Dmg/4 or victimdistance > 500) then
															go = false
														end
														if ((spell1.name == "invoker_deafening_blast" and spell1:CanBeCasted()) or (spell2.name == "invoker_deafening_blast" and spell2:CanBeCasted())) then
															go = true
														end
														if GetDistance2D(prediction,tempvictim) > 50 and ((((spell1.name == "invoker_cold_snap" and spell1:CanBeCasted()) or (spell2.name == "invoker_cold_snap" and spell2:CanBeCasted())) and victimdistance < range/1.5) or tempvictim:DoesHaveModifier("modifier_invoker_ice_wall_slow_debuff") or tempvictim:DoesHaveModifier("modifier_invoker_cold_snap")) then
															prediction = (prediction - tempvictim.position) * (GetDistance2D(prediction,tempvictim)/2) / GetDistance2D(prediction,tempvictim) + tempvictim.position
															go = true
														end
														--if combo ~= 0 and combo ~= 3 then prediction = client.mousePosition end
														if comb == 3 then
															local blast = me:FindSpell("invoker_deafening_blast")
															local blastcd = blast:GetCooldown(blast.level)
															if octa then
																blastcd = blastcd*0.75
															end
															blastcd = blastcd-((GetDistance2D(me,tempvictim)+100)/1100+client.latency/1000)
															if blast and (blast.cd > blastcd or blast:CanBeCasted() or tempvictim:DoesHaveModifier("modifier_invoker_deafening_blast_knockback")) then
																if tempvictim:DoesHaveModifier("modifier_invoker_deafening_blast_knockback") then
																	prediction = (tempvictim.position - me.position) * (GetDistance2D(tempvictim,me)+50) / GetDistance2D(tempvictim,me) + me.position
																elseif GetDistance2D(tempvictim,prediction) > 50 then																
																	prediction = (prediction - me.position) * (GetDistance2D(prediction,me)+100) / GetDistance2D(prediction,me) + me.position
																else
																	prediction = (tempvictim.position - me.position) * (GetDistance2D(tempvictim,me)+100) / GetDistance2D(tempvictim,me) + me.position
																end
															end
														end
													
													-- if spell.name == "dark_seer_vacuum" then
														-- local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(tempvictim,
														-- PredictedXYZ(v,delay)) < radius*2+50) end)
														-- --print(radius)
														-- if #closeEnemies > 0 then
															-- local avpos = nil
															-- for i = 1, #closeEnemies do	
																-- if not avpos then avpos = SkillShotPredictedXYZ(closeEnemies[i],delay)
																-- else avpos = avpos + SkillShotPredictedXYZ(closeEnemies[i],delay) end
															-- end
															-- avpos = avpos/#closeEnemies
															-- prediction = (prediction + avpos)/2
														-- else
															-- prediction = (mePosition - prediction) * (radius/2-200) / GetDistance2D(me,prediction) + prediction
														-- end
													elseif spell.name == "puck_illusory_orb" and retreat then prediction = client.mousePosition
													--if spell.name == "invoker_tornado" and combo ~= 0 and combo ~= 3 then prediction = client.mousePosition end
													elseif spell.name == "ember_spirit_sleight_of_fist" and prediction then
														local position = nil
														local unitnum = 0
														local closest = nil
														if a1 and a1:CanBeCasted() and enemyHP > Dmg then
															local units = {}
															local unitsCount = 0
															local lanecreeps = entityList:GetEntities({classId=CDOTA_BaseNPC_Creep_Lane,team=me:GetEnemyTeam(),visible=true})
															local fam = entityList:GetEntities({classId=CDOTA_Unit_VisageFamiliar,team=me:GetEnemyTeam(),visible=true})
															local boar = entityList:GetEntities({classId=CDOTA_Unit_Hero_Beastmaster_Boar,team=me:GetEnemyTeam(),visible=true})
															local forg = entityList:GetEntities({classId=CDOTA_BaseNPC_Invoker_Forged_Spirit,team=me:GetEnemyTeam(),visible=true})
															for i = 1, #lanecreeps do local v = lanecreeps[i] if not v:IsInvul() and v.alive and v.spawned then unitsCount = unitsCount + 1 units[unitsCount] = v end end
															for i = 1, #fam do local v = fam[i] if not v:IsInvul() and v.alive and not v:IsAttackImmune() then unitsCount = unitsCount + 1 units[unitsCount] = v end end
															for i = 1, #boar do local v = boar[i] if not v:IsInvul() and v.alive and not v:IsAttackImmune() then unitsCount = unitsCount + 1 units[unitsCount] = v end end 
															for i = 1, #forg do local v = forg[i] if not v:IsInvul() and v.alive and not v:IsAttackImmune() then unitsCount = unitsCount + 1 units[unitsCount] = v end end
															for i = 1, unitsCount do
																local v = units[i]
																if GetDistance2D(v,prediction) < (radius/2)+300 then
																	if not position then
																		position = v.position
																		unitnum = 1
																	else
																		position = position + v.position
																		unitnum = unitnum + 1
																	end
																	if not closest or GetDistance2D(v,prediction) < GetDistance2D(closest,prediction) then
																		closest = v
																	end
																end
															end
														end
														if closest then
															prediction = (prediction - closest.position) * (GetDistance2D(closest,prediction)+200+(radius/2)) / GetDistance2D(prediction,closest) + closest.position
														end
														if GetDistance2D(tempvictim,prediction) > ((radius/2)+200) then	
															prediction = (prediction - mePosition) * (castRange+200) / GetDistance2D(me,prediction) + mePosition
														end
													end
													if ((prediction and GetDistance2D(prediction,mePosition) < castRange+100) or ((spell.name == "earth_spirit_rolling_boulder" or spell.name == "shredder_timber_chain") and retreat)) and go then
														if spell.name ~= "slark_pounce" and spell.name ~= "nevermore_shadowraze1" and spell.name ~= "nevermore_shadowraze2" and spell.name ~= "nevermore_shadowraze3" and spell.name ~= "earth_spirit_boulder_smash" then
														--	if spell.name == "invoker_sun_strike" then print("asd") end
															if spell.name ~= "earth_spirit_rolling_boulder" and spell.name ~= "invoker_sun_strike" and spell.name ~= "skywrath_mage_mystic_flare" and radius and radius > 0 and not data[7] and spell.name ~= "invoker_sun_strike" then
																local closeEnemies = entityList:GetEntities(function (v) return (v.hero and not v:IsIllusion() and v.alive and v.visible and v.team ~= me.team and v ~= tempvictim and GetDistance2D(tempvictim,SkillShotSkillShotXYZ(mePosition,v,delay2,speed,radius)) < radius*2+50) end)
																--print(radius)
																if #closeEnemies > 0 then
																	local avpos = nil
																	for i = 1, #closeEnemies do	
																		if not avpos then avpos = SkillShotPredictedXYZ(closeEnemies[i],delay)
																		else avpos = avpos + SkillShotPredictedXYZ(closeEnemies[i],delay) end
																	end
																	avpos = avpos/#closeEnemies
																	prediction = (prediction + avpos)/2
																--else
																	--prediction = (mePosition - prediction) * (radius/2-200) / GetDistance2D(me,prediction) + prediction
																end
															end
															if spell.name == "earth_spirit_rolling_boulder" then
																local smash = a1
																local smashcd = smash:GetCooldown(smash.level)
																if octa then
																	smashcd = smashcd*0.75
																end
																smashcd = smashcd-2
																if smash and (smash.cd > smashcd or smash.abilityPhase) and tempvictimVisible then
																	prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,0.00001,1600,radius)
																end
																if retreat or EStoMouse then
																	prediction = client.mousePosition
																end
																local remn = entityList:GetEntities({classId = CDOTA_Unit_Earth_Spirit_Stone})
																local found = false
																for i = 1, #remn do
																	local v = remn[i]
																	local calc1 = (mathfloor(mathsqrt((prediction.x-v.position.x)^2 + (prediction.y-v.position.y)^2)))
																	local calc2 = (mathfloor(mathsqrt((me.position.x-v.position.x)^2 + (me.position.y-v.position.y)^2)))
																	local calc4 = (mathfloor(mathsqrt((me.position.x-prediction.x)^2 + (me.position.y-prediction.y)^2)))
																	if calc1 < calc4 and calc2 < calc4 and GetDistance2D(me,v) < 360 then
																		found = true
																		cast = me:SafeCastAbility(spell,prediction)
																		Sleep(spell:FindCastPoint()*1000+600,"moving")
																		Sleep(spell:FindCastPoint()*1000+600,spell.name)
																		return
																	end
																end
																if not found and (victimdistance > 800 or retreat) then
																	local stone = a4
																	if stone and stone:CanBeCasted() and SleepCheck("stone") then
																		local vector = (prediction - me.position) * 200 / GetDistance2D(prediction,me) + me.position
																		me:CastAbility(stone, vector)
																		cast = me:SafeCastAbility(spell,prediction)
																		Sleep(spell:FindCastPoint()*1000+600,"moving")
																		Sleep(spell:FindCastPoint()*1000+600,spell.name)
																		Sleep(100+client.latency,"stone")
																		return
																	end
																elseif not found then
																	cast = me:SafeCastAbility(spell,prediction)
																	Sleep(spell:FindCastPoint()*1000+600,"moving")
																	Sleep(spell:FindCastPoint()*1000+600,spell.name)
																	return
																end
															elseif spell.name == "earth_spirit_geomagnetic_grip" then
																local remn = entityList:GetEntities({classId = CDOTA_Unit_Earth_Spirit_Stone, alive=true, visible = true})
																local found = nil
																for i = 1, #remn do
																	local v = remn[i]
																	if not found and GetDistance2D(tempvictim,v) < 300 and GetDistance2D(me,tempvictim)-10 <= GetDistance2D(me,v) then
																		found = v
																	end
																	if GetDistance2D(me,v) < castRange+50 and GetDistance2D(me,tempvictim)-10 <= GetDistance2D(me,v) then
																		local calc1 = (mathfloor(mathsqrt((v.position.x-tempvictim.position.x)^2 + (v.position.y-tempvictim.position.y)^2)))
																		local calc2 = (mathfloor(mathsqrt((me.position.x-tempvictim.position.x)^2 + (me.position.y-tempvictim.position.y)^2)))
																		local calc4 = (mathfloor(mathsqrt((me.position.x-v.position.x)^2 + (me.position.y-v.position.y)^2)))
																		if GetDistance2D(me,v) <= (GetDistance2D(me,tempvictim)+GetDistance2D(tempvictim,v)) and GetDistance2D(me,v)+500 > (GetDistance2D(me,tempvictim)+GetDistance2D(tempvictim,v)) then
																			found = v
																		end
																		if not found and calc1 < calc4 and calc2 < calc4 and GetDistance2D(me,v) < castRange+50 then
																			found = v
																		end
																	end
																end	
																local smash = a1
																if found or esstone then
																	if found then
																		local vec = (found.position - me.position) * (GetDistance2D(found,me)+client.latency*1.2+25) / GetDistance2D(found,me) + me.position
																		cast = me:SafeCastAbility(spell,vec)
																		cast = me:SafeCastAbility(spell,found.position)
																	end
																	lastCastPrediction = tempvictim.position
																 elseif GetDistance2D(prediction,me) < castRange+50 then
																	local stone = a4
																	if stone and stone:CanBeCasted() and SleepCheck("stone") then
																		me:CastAbility(stone, prediction)
																		cast = me:SafeCastAbility(spell,prediction)
																		lastCastPrediction = prediction
																		Sleep(100+client.latency,"stone")
																	end
																end
															elseif spell.name ~= "kunkka_ghostship" or GetDistance2D(me,prediction) > 750 then
																if spell.name == "magnataur_skewer" then
																	prediction = (prediction - me.position) * 1400 / GetDistance2D(prediction,me) + me.position
																end
																lastPrediction = {prediction, tempvictim.rotR}
																lastCastPrediction = prediction
																cast = me:SafeCastAbility(spell,prediction)
																delay = delay + (mathmax(GetDistance2D(prediction,mePosition)-50-castRange,0)/me.movespeed)*1000
																if spell.name == "ancient_apparition_ice_blast" then delay = delay + (mathmax(GetDistance2D(prediction,mePosition)-50,0)/speed)*1000 end
																if spell.name == "ember_spirit_sleight_of_fist" then
																	delay = me:GetTurnTime(prediction)*1000
																end
															end
														elseif ((spell.name ~= "nevermore_shadowraze1" and spell.name ~= "nevermore_shadowraze2" and spell.name ~= "nevermore_shadowraze3") or (not retreat or Dmg > enemyHP)) and (meDmg < Dmg or victimdistance > range+100 or ID == CDOTA_Unit_Hero_EarthSpirit) then
															if not speed or speed == 0 then speed = 9999999 end
															if ID == CDOTA_Unit_Hero_EarthSpirit then
																if not tempvictimVisible then
																	prediction = SkillShot.BlindSkillShotXYZ(me,tempvictim,speed,me:GetTurnTime(prediction)+client.latency/1000+(100/Animations.maxCount)/1000 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount))))
																else
																	prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,me:GetTurnTime(prediction)*1000+client.latency+(100/Animations.maxCount) - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))*1000,speed,radius)
																end
															elseif not tempvictimVisible then
																prediction = SkillShot.BlindSkillShotXYZ(me,tempvictim,speed,me:GetTurnTime(prediction)+client.latency/1000+(100/me.movespeed)+(100/Animations.maxCount)/1000 - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount))))
															else
																prediction = SkillShotSkillShotXYZ(mePosition,tempvictim,me:GetTurnTime(prediction)*1000+client.latency+(100/me.movespeed)*1000+(100/Animations.maxCount) - ((client.latency/1000)/(1 + (1 - 1/Animations.maxCount)))*1000,speed,radius)
															end
															if spell.name == "slark_pounce" and retreat then
																prediction = client.mousePosition
															end
															if SleepCheck("movetoprediction") and prediction and (spell.name ~= "earth_spirit_boulder_smash" or a4:CanBeCasted()) and (GetDistance2D(me,prediction) < castRange+100 or (distance and GetDistance2D(me,prediction) < distance+100)) then
																-- local mepred = SkillShotPredictedXYZ(me,client.latency+100)
																-- if not facing then
																	-- mepred = (me.position - tempvictim.position) * 25 / GetDistance2D(me,tempvictim) + tempvictim.position
																-- end
																-- local vector = (prediction - mepred) * 25 / GetDistance2D(prediction,mepred) + mepred
																local vector = prediction
																if GetDistance2D(me,vector) < 200 then 
																	vector = (me.position - vector) * 500 / GetDistance2D(me.position,vector) + vector
																end
																if victimdistance < 150 then me:Attack(tempvictim)
																else me:Move(vector) end
																Sleep(me:GetTurnTime(prediction)*1000+client.latency+delay, "moving")
																Sleep(200, "movetoprediction")
															end
															if prediction and ((mathmax(mathabs(FindAngleR(me) - mathrad(FindAngleBetween(me, prediction))) - 0.40, 0)) == 0 or spell.name == "earth_spirit_boulder_smash") and (spell.name ~= "slark_pounce" or ((mathmax(mathabs(FindAngleR(me) - mathrad(FindAngleBetween(me, prediction))) - 0.10, 0)) == 0))  then
																if spell.name == "earth_spirit_boulder_smash" then
																	if EStoMouse and not retreat then prediction = client.mousePosition end
																	local stone = a4
																	local remn = entityList:GetEntities({classId = CDOTA_Unit_Earth_Spirit_Stone})
																	local found = false
																	local foundStone = nil
																	for i = 1, #remn do
																		local v = remn[i]
																		local calc1 = (mathfloor(mathsqrt((tempvictim.position.x-v.position.x)^2 + (tempvictim.position.y-v.position.y)^2)))
																		local calc2 = (mathfloor(mathsqrt((me.position.x-v.position.x)^2 + (me.position.y-v.position.y)^2)))
																		local calc4 = (mathfloor(mathsqrt((me.position.x-tempvictim.position.x)^2 + (me.position.y-tempvictim.position.y)^2)))
																		if calc1 < calc4 and calc2 < calc4 and GetDistance2D(me,v) < 300 then
																			found = true
																			foundStone = v
																		end
																	end
																	if (stone and stone:CanBeCasted()) or found then
																		esstone = true
																		if not found and SleepCheck("stone") and not tempvictim:DoesHaveModifier("modifier_earthspirit_petrify") and SleepCheck("earth_spirit_petrify") then
																			local vector = (prediction - me.position) * 200 / GetDistance2D(prediction,me) + me.position
																			me:CastAbility(stone, vector)
																			Sleep(100+client.latency,"stone")
																		end
																		cast = me:SafeCastAbility(spell,prediction)
																		if foundStone then
																			Sleep(me:GetTurnTime(prediction)*1000+spell:FindCastPoint()*1000, "casting")
																		else
																			Sleep(me:GetTurnTime(prediction)*1000+spell:FindCastPoint()*1000, "casting")
																		end
																		Sleep(me:GetTurnTime(prediction)*1000+spell:FindCastPoint()*1000+((GetDistance2D(me,prediction))/speed)*1000+client.latency+1000, "esstone")
																		Sleep(me:GetTurnTime(prediction)*1000+spell:FindCastPoint()*1000+client.latency, spell.name)
																		Sleep(me:GetTurnTime(prediction)*1000+client.latency+client.latency+spell:FindCastPoint()*1000, "moving")
																		return
																	end
																else
																	lastPrediction = {prediction, tempvictim.rotR}
																	cast = me:SafeCastAbility(spell)
																end
																if cast then
																	Sleep(me:GetTurnTime(prediction)*1000+client.latency+spell:FindCastPoint()*1000, "casting")
																	Sleep(me:GetTurnTime(prediction)*1000+client.latency+2000, spell.name)
																	return
																end
															end
															return
														end
													end
												end
											end
										end
									end
									if cast then
										if ID == CDOTA_Unit_Hero_StormSpirit then delay = delay + Animations.GetAttackTime(me)*1000 end 
										if (data[3] or spell.name == "legion_commander_duel") and spell.name ~= "storm_spirit_ball_lightning" then stunAbility = spell end
										--if spell.name == "kunkka_ghostship" then Sleep(3000,"stun") end
										if spell.name == "batrider_flaming_lasso" then delay = delay + 200
										elseif spell.name == "invoker_ghost_walk" then Sleep(1000, "casting") Sleep(1000, "casting2") Sleep(1000, "casting3")
										elseif spell.name == "invoker_sun_strike" then Sleep(client.latency+200,"moving") end
										if spell.name ~= "ancient_apparition_ice_blast" and spell.name ~= "pudge_meat_hook" then
											if spell.name ~= "ember_spirit_sleight_of_fist" then
												Sleep(client.latency+200+spell:FindCastPoint()*1000,"moving")
											else
												mePosition = tempvictim.position
												Sleep(spell:FindCastPoint()*1000+client.latency+300,"blink")
												Sleep(spell:FindCastPoint()*1000+client.latency+300,"moving")
											end
										end
										if spell.name == "riki_blink_strike" then Sleep(delay+client.latency+Animations.GetAttackTime(me)*1000+Animations.getBackswingTime(me)*1000, spell.name)
										elseif spell.name == "earth_spirit_geomagnetic_grip" then Sleep(100, spell.name) return
										elseif spell.name == "leshrac_pulse_nova" then Sleep(500, spell.name) return
										elseif spell.name == "kunkka_torrent" then Sleep(500,spell.name) end
										if channel and channel > 0 then if victimdistance < castRange+150 or (distance and victimdistance < distance+150) or (lastCastPrediction and GetDistance2D(mePosition,lastCastPrediction) < castRange+150) then channelactive = true delay = delay + 600 if spell.name ~= "pudge_dismember" then Sleep(delay + channel*1000 + 200, spell.name) end end
										elseif data[3] and spell.name ~= "ember_spirit_fire_remnant" and spell.name ~= "earth_spirit_petrify" and spell.name ~= "ancient_apparition_cold_feet" and spell.name ~= "invoker_emp" and spell.name ~= "ursa_earthshock" and spell.name ~= "earth_spirit_boulder_smash" and spell.name ~= "earth_spirit_geomagnetic_grip" and spell.name ~= "earth_spirit_rolling_boulder" and spell.name ~= "kunkka_torrent" then Sleep(delay+mathmax(add,0.4)*1000+client.latency,"stun") end
										if spell.name == "ember_spirit_fire_remnant" then
											local ultiDamage = tempdamageTable["ember_spirit_activate_fire_remnant"][1]
											ultiDamage = tempvictim:DamageTaken(ultiDamage,DAMAGE_MAGC,me)
											if me.mana > 650 and enemyHP < ultiDamage*3 and (tempvictim:IsStunned() or tempvictim:IsRooted()) and victimdistance < 500 and speed > 500 then delay = 0   
											else 
											Sleep(delay + (victimdistance/speed)*1000, spell.name) end
										elseif spell.name == "kunkka_x_marks_the_spot" then
											Sleep(1000, spell.name)
										elseif spell.name == "rubick_telekinesis_land" then
											Sleep(1000, spell.name)
										elseif spell.name == "earth_spirit_stone_caller" then
											Sleep(1000, spell.name)
										elseif spell.name == "storm_spirit_ball_lightning" then
											Sleep(delay+(GetDistance2D(lastCastPrediction,me)/speed)*1000+Animations.GetAttackTime(me)*1000+client.latency,spell.name)
										elseif spell.name == "earth_spirit_petrify" then
											Sleep(500+client.latency, spell.name)
										elseif spell.name ~= "pudge_dismember" then
											--print(delay)
											Sleep(delay, spell.name)
										end
										if spell.name == "troll_warlord_whirling_axes_ranged" then
											local melee = me:FindSpell("troll_warlord_whirling_axes_melee")
											if melee.cd > 0 then
												trolltoggle = true
											end
										end
										--print(spell.name)
										--if spell.name == "huskar_life_break" and not me:DoesHaveModifier("modifier_item_armlet_unholy_strength") then Sleep(delay+500,"item_armlet") end
										--if spell.name == "pudge_dismember" then delay = delay + 500 end
										--if spell.name == "phoenix_sun_ray" then print(Dmg) end
										if spell.name == "phoenix_launch_fire_spirit" then Sleep(2000,spell.name)
										elseif spell.name == "phoenix_icarus_dive" then Sleep(1000,"phoenix_icarus_dive_stop") Sleep(1000,"phoenix_sun_ray") end
										if spell.name ~= "ember_spirit_sleight_of_fist" and spell.name ~= "earth_spirit_geomagnetic_grip" then
											if victimdistance < castRange+150 or (distance and victimdistance < distance+150) or (lastCastPrediction and GetDistance2D(mePosition,lastCastPrediction) < castRange+150) then
												if spell.name == "tusk_snowball" then tuskSnowBall = true
												elseif spell.name == "windrunner_shackleshot" and a2 and a2:CanBeCasted() then Sleep(delay+((victimdistance)/speed)*1000+750+client.latency,"stun") Sleep(delay+((victimdistance)/speed)*1000+500,"casting")
												elseif spell.name == "invoker_tornado" then Sleep(delay+((victimdistance)/speed)*1000+100,"stun")
												elseif spell.name == "kunkka_x_marks_the_spot" then Sleep(1000, spell.name) Sleep(delay+client.latency+200, "stun")
												elseif spell.name == "rattletrap_hookshot" then Sleep(delay+((victimdistance-50)/speed)*1000+mathmax(client.latency,1000),"blink")
												elseif spell.name == "puck_illusory_orb" then Sleep(3000, "blink") PuckPosition = me.position
												elseif spell.name == "shredder_timber_chain" and lastTreeID then Trees[lastTreeID].cutted = true Trees[lastTreeID].cutTime = gameTime lastTreeID = nil Sleep(500, "blink")
												elseif spell.name == "shredder_chakram" then lastChakram1 = lastCastPrediction Sleep((GetDistance2D(me,lastChakram1)/speed)*1000+delay+client.latency,"shredder_return_chakram")
												elseif spell.name == "shredder_chakram_2" then lastChakram2 = lastCastPrediction Sleep((GetDistance2D(me,lastChakram2)/speed)*1000+delay+client.latency,"shredder_return_chakram_2") end
												if ID ~= CDOTA_Unit_Hero_Pudge then											
													Sleep(delay,"casting")
												end
												if Dmg then
													if spell.name ~= "invoker_ice_wall" then
														enemyHP = enemyHP - Dmg
													else
														enemyHP = enemyHP - Dmg/2
													end
												end
												return
											end
										end
									elseif not data[3] then Sleep(150,spell.name) end
								end
							end
						end
					end
				end
			end
			
			if me:IsChanneling() or (tempvictim and (tempvictim:DoesHaveModifier("modifier_pudge_meat_hook") or a4.abilityPhase) and ID == CDOTA_Unit_Hero_Pudge) then return end
			
			if stunAbility then
				if stunAbility.cd > 0 then stunAbility = nil 
				elseif tempvictimAlive and tempvictimVisible and me.activity == LuaEntityNPC.ACTIVITY_MOVE then return 
				end
			end
		
			--Orb Walk
			--print(not me:DoesHaveModifier("modifier_phoenix_sun_ray") , (not retreat or (tempvictim and meDmg > enemyHP and victimdistance < range)) , not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") , SleepCheck("charge") , me.alive , not CanMove , not me:DoesHaveModifier("modifier_batrider_flaming_lasso_self") , tempvictim , victimdistance <= mathmax(range*2+50,500) , tempvictimVisible , not tempvictim:IsInvul() , me:CanAttack() , not tempvictim:IsAttackImmune() , not tempvictim:DoesHaveModifier("modifier_bane_nightmare") )
			if not me:DoesHaveModifier("modifier_shredder_chakram_disarm") and not me:DoesHaveModifier("modifier_phoenix_sun_ray") and (not retreat or (tempvictim and meDmg > enemyHP and victimdistance < range)) and not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") and SleepCheck("charge") and me.alive and not CanMove and not me:DoesHaveModifier("modifier_batrider_flaming_lasso_self") and tempvictim and victimdistance <= mathmax(range*2+50,500) and tempvictimVisible and not tempvictim:IsInvul() and me:CanAttack() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then	
				if tick > tempattack and SleepCheck("moving") then
					if (not meld or not meld:CanBeCasted() or me:DoesHaveModifier("modifier_templar_assassin_meld") or enemyHP < meDmg) and (not a1 or a1.name ~= "mirana_starfall" or not a1:CanBeCasted() or enemyHP < meDmg) and not tempvictim:IsInvul() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then
						if ID == CDOTA_Unit_Hero_Invoker and exort and exort.level > 0 and SleepCheck("casting3") then
							if not me:IsInvisible() and setOrbs("exort", me) then
								Sleep(250,"casting3")
							end
						end
						if (not me:DoesHaveModifier("modifier_bloodseeker_rupture") or victimdistance <= range) then
							if not me:DoesHaveModifier("modifier_item_armlet_unholy_strength") and SleepCheck("item_armlet") and (not me:DoesHaveModifier("modifier_huskar_life_break_charge") and (ID ~= CDOTA_Unit_Hero_Huskar or not a4.abilityPhase)) then
								--print(not me:DoesHaveModifier("modifier_huskar_life_break_charge") , a4.abilityPhase)
								local armlet = me:FindItem("item_armlet")
								if armlet then
									me:CastItem("item_armlet")
									Sleep(client.latency+100,"item_armlet")
									return
								end
							end
							if xposition then
								if GetDistance2D(xposition,me) > 700 then me:Move(xposition)
								end
							elseif me:DoesHaveModifier("modifier_gyrocopter_flak_cannon") and victimdistance > range+100 then
								local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(me,v) < range) end)
								if #closeUnits > 0 then
									me:AttackMove(SkillShot.InFront(me,500))
								else
									myhero:Hit(tempvictim,me)
								end
							elseif ID == CDOTA_Unit_Hero_Kunkka and a2.cd == 0 then
								local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(me,v) < range) end)
								if #closeUnits > 0 then
									local attackableUnit = nil
									for i = 1, #closeUnits do
										local v = closeUnits[i]
										local calc1 = (mathfloor(mathsqrt((tempvictim.position.x-v.position.x)^2 + (tempvictim.position.y-v.position.y)^2)))
										local calc2 = (mathfloor(mathsqrt((me.position.x-v.position.x)^2 + (me.position.y-v.position.y)^2)))
										local calc4 = (mathfloor(mathsqrt((me.position.x-tempvictim.position.x)^2 + (me.position.y-tempvictim.position.y)^2)))
										if calc1 < calc4 and calc2 < calc4 and GetDistance2D(me,v) < 300 then
											attackableUnit = v
										end
									end
									if attackableUnit then
										me:Attack(attackableUnit)
									else
										myhero:Hit(tempvictim,me)
									end
								else
									myhero:Hit(tempvictim,me)
								end
							else
								myhero:Hit(tempvictim,me)
							end
						else
							player:HoldPosition()
						end
						if victimdistance <= range and SleepCheck("casting") then
							enemyHP = enemyHP - meDmg
							--Sleep(Animations.GetAttackTime(me)*1000+client.latency+me:GetTurnTime(tempvictim)*1000,"casting")
						end
					elseif not me:DoesHaveModifier("modifier_templar_assassin_meld") or not meld then
						if not me:DoesHaveModifier("modifier_bloodseeker_rupture") then
							me:Follow(tempvictim)
						else
							player:HoldPosition()
						end
					end
					attack = tick + Animations.maxCount + client.latency
					type = nil
				end
			elseif not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") and SleepCheck("charge") and me.alive and not me:DoesHaveModifier("modifier_bloodseeker_rupture") and tick > tempmove and SleepCheck("moving") and (SleepCheck("casting") or ID ~= CDOTA_Unit_Hero_TemplarAssassin) and (not meld or not me:DoesHaveModifier("modifier_templar_assassin_meld") or SleepCheck("casting")) then
				--print("asd")
				local mPos = client.mousePosition
				if ID == CDOTA_Unit_Hero_Invoker and quas and quas.level > 0 and SleepCheck("casting3") and ((not tempvictim and (me.maxHealth-me.health) > 100) or ((not wex or wex.level == 0) and (not exort or exort.level == 0))) and not retreat then
					if not me:IsInvisible() and setOrbs("quas", me) then
						Sleep(250, "casting3")
					end
				elseif exort and exort.level > 0 and SleepCheck("casting3") and (not wex or wex.level == 0) then
					if not me:IsInvisible() and setOrbs("exort", me) then
						Sleep(250, "casting3")
					end
				elseif wex and wex.level > 0 and SleepCheck("casting3") then
					if not me:IsInvisible() and setOrbs("wex", me) then
						Sleep(250, "casting3")
					end
				end
				--print(tempvictimVisible, ((not targetlock and config.MoveToEnemyWhenLocked) or retreat) , (not tempvictim or (GetDistance2D(me,mPos) > 300 and GetDistance2D(tempvictim,mPos) > 300 and tempvictimVisible and GetDistance2D(tempvictim,me) < 1000 and (me:GetTurnTime(mPos)*2 < Animations.getBackswingTime(me) or me.activity ~= LuaEntityNPC.ACTIVITY_MOVE))) , (temptype and temptype == 1) , (not tempvictim or (tempvictimVisible and GetDistance2D(tempvictim,me) < 1000)))
				if xposition or ((not targetlock and config.MoveToEnemyWhenLocked) or retreat) or ((((not tempvictim or (GetDistance2D(me,mPos) > 150 and tempvictimVisible and GetDistance2D(tempvictim,me) < 1000 and (me:GetTurnTime(mPos)*2 < Animations.getBackswingTime(me) or me.activity ~= LuaEntityNPC.ACTIVITY_MOVE))) or (temptype and temptype == 1)) and (not tempvictim or (tempvictimVisible and GetDistance2D(tempvictim,me) < 1000)))) then
					me:Move(mPos)
					type = 1
				elseif (config.AutoMoveToEnemy or not tempvictimVisible or (prediction and GetDistance2D(me,prediction) > range and GetDistance2D(prediction,tempvictim) > 100) or GetDistance2D(me,tempvictim) > 1000) and GetDistance2D(me,mPos) > 100 then
					me:Follow(tempvictim)
					follow = tick + 6000
				end
				move = tick + Animations.maxCount + client.latency
				start = false
			end
		--Target Reset
		else
			if victim then
				if config.AutoLock or targetlock then
					if not resettime then
						resettime = gameTime
					elseif (gameTime - resettime) >= 6 then
						indicate[victim.playerId].visible = false
						victim = nil
						resettime = nil	
						targetlock = false		
					end
					start = false
				else
					indicate[victim.playerId].visible = false
					victim = nil
					resettime = nil	
					targetlock = false	
				end
			end
		end

		if not KeyPressed and SleepCheck("asdstack") then Sleep(500,"asdstack")
		end
	end
end

function OrbWalk()
	local client, PlayingGame = client, PlayingGame
	if not PlayingGame() or client.paused then return end
	local GetDistance2D = GetDistance2D
	local mathmax, tablesort, AbilityDamageGetDamage, AbilityDamageGetDmgType, Sleep, SleepCheck, SkillShotPredictedXYZ, SkillShotSkillShotXYZ = math.max, table.sort, AbilityDamage.GetDamage, AbilityDamage.GetDmgType, Sleep, SleepCheck, SkillShot.PredictedXYZ, SkillShot.SkillShotXYZ
	local tempmyhero, IsKeyDown, targetFind, entityList, SkillShotBlockableSkillShotXYZ, chainStun = myhero, IsKeyDown, targetFind, entityList, SkillShot.BlockableSkillShotXYZ, chainStun
	local me, player = entityList:GetMyHero(), entityList:GetMyPlayer()
	local mathfloor, mathceil, mathmin, mathsqrt, mathrad, mathabs, mathcos, mathsin = math.floor, math.ceil, math.min, math.sqrt, math.rad, math.abs, math.cos, math.sin
	local LuaEntity, LuaEntityAbility, LuaEntityHero, LuaEntityNPC = LuaEntity, LuaEntityAbility, LuaEntityHero, LuaEntityNPC
	local drawMgr, Animations, SkillShot = drawMgr, Animations, SkillShot
	local config, tostring, myId, gameTime = config, tostring, myId, client.gameTime
	local tempvictim, comboTable, tempattack, tempmove, temptype, itemcomboTable, tempdamageTable, invokerCombo = victim, comboTable, attack, move, type, itemcomboTable, damageTable, invokerCombo
	local abilities = me.abilities	
	
	local ID = me.classId if ID ~= myId then Close() end
	
	local KeyPressed = (IsKeyDown(chasekey) or IsKeyDown(config.Retreat) or IsKeyDown(config.Harras)) and not client.chat
	
	Animations.entities[1] = me
	
	if KeyPressed and myhero then
		if SleepCheck("channel") then
			for i = 1, #abilities do
				local v = abilities[i]
				local c = v:GetChannelTime(v.level) or 0
				if v.abilityPhase and c > 0 then
					channelactive = true
					Sleep(v:FindCastPoint()*1000+100,"casting")
					Sleep(v:FindCastPoint()*1000+100,"channel")
					return
				end
			end
		end
		if me:IsChanneling() or channelactive then 
			local glimmer_cape = me:FindItem("item_glimmer_cape")
			if glimmer_cape and glimmer_cape:CanBeCasted() and SleepCheck("glim") then
				me:CastAbility(glimmer_cape,me)
				Sleep(200,"glim")
			end
			return
		end
		local victimdistance = GetDistance2D(me,tempvictim)
		local meDmg = me.dmgMin + me.dmgBonus
		local range = myhero:GetAttackRange()
		local meld = nil
		local CanMove, tempvictimVisible, tempvictimAlive = Animations.CanMove(me), (tempvictim and tempvictim.visible), (tempvictim and tempvictim.alive)
		local a1,a2,a3,a4,a5,a6 = abilities[1],abilities[2],abilities[3],abilities[4],abilities[5],abilities[6]
		local quas, wex, exort
		if ID == CDOTA_Unit_Hero_Invoker then quas, wex, exort = a1, a2, a3 end
		if ID == CDOTA_Unit_Hero_TemplarAssassin then meld = a2 end
		if stunAbility then
			if stunAbility.cd > 0 then stunAbility = nil 
			elseif tempvictimAlive and tempvictimVisible then return 
			end
		end
		if SleepCheck("casting") and lastOrder ~= "attack" and not me:DoesHaveModifier("modifier_phoenix_sun_ray") and (not retreat or (tempvictim and meDmg > enemyHP and victimdistance < range)) and not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") and SleepCheck("charge") and me.alive and not CanMove and not me:DoesHaveModifier("modifier_batrider_flaming_lasso_self") and tempvictim and victimdistance <= mathmax(range*2+50,500) and tempvictimVisible and not tempvictim:IsInvul() and me:CanAttack() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then	
			--print("Asd1")
			--print("asd")
			if (not meld or not meld:CanBeCasted() or me:DoesHaveModifier("modifier_templar_assassin_meld") or enemyHP < meDmg) and (not a1 or a1.name ~= "mirana_starfall" or not a1:CanBeCasted() or enemyHP < meDmg) and not tempvictim:IsInvul() and not tempvictim:IsAttackImmune() and not tempvictim:DoesHaveModifier("modifier_bane_nightmare") then
				if ID == CDOTA_Unit_Hero_Invoker and exort and exort.level > 0 and SleepCheck("casting3") then
					if not me:IsInvisible() and setOrbs("exort", me) then
						Sleep(250,"casting3")
					end
				end
				if (not me:DoesHaveModifier("modifier_bloodseeker_rupture") or victimdistance <= range) then
					if not me:DoesHaveModifier("modifier_item_armlet_unholy_strength") and SleepCheck("item_armlet") and (not me:DoesHaveModifier("modifier_huskar_life_break_charge") and (ID ~= CDOTA_Unit_Hero_Huskar or not a4.abilityPhase)) then
						--print(not me:DoesHaveModifier("modifier_huskar_life_break_charge") , a4.abilityPhase)
						local armlet = me:FindItem("item_armlet")
						if armlet then
							me:CastItem("item_armlet")
							Sleep(client.latency+100,"item_armlet")
							return
						end
					end
					if xposition then
						if GetDistance2D(xposition,me) > 700 then me:Move(xposition)
						end
					elseif me:DoesHaveModifier("modifier_gyrocopter_flak_cannon") and victimdistance > range+100 then
						local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(me,v) < range) end)
						if #closeUnits > 0 then
							me:AttackMove(SkillShot.InFront(me,500))
						else
							myhero:Hit(tempvictim,me)
						end
					elseif ID == CDOTA_Unit_Hero_Kunkka and a2.cd == 0 then
						local closeUnits = entityList:GetEntities(function (v) return ((v.hero or v.creep) and v.alive and v.team ~= me.team and v ~= tempvictim and GetDistance2D(me,v) < range) end)
						if #closeUnits > 0 then
							local attackableUnit = nil
							for i = 1, #closeUnits do
								local v = closeUnits[i]
								local calc1 = (mathfloor(mathsqrt((tempvictim.position.x-v.position.x)^2 + (tempvictim.position.y-v.position.y)^2)))
								local calc2 = (mathfloor(mathsqrt((me.position.x-v.position.x)^2 + (me.position.y-v.position.y)^2)))
								local calc4 = (mathfloor(mathsqrt((me.position.x-tempvictim.position.x)^2 + (me.position.y-tempvictim.position.y)^2)))
								if calc1 < calc4 and calc2 < calc4 and GetDistance2D(me,v) < 300 then
									attackableUnit = v
								end
							end
							if attackableUnit then
								me:Attack(attackableUnit)
							else
								myhero:Hit(tempvictim,me)
							end
						else
							myhero:Hit(tempvictim,me)
						end
					else
						myhero:Hit(tempvictim,me)
					end
				else
					player:HoldPosition()
				end
				if victimdistance <= range+50 and SleepCheck("casting") then
					enemyHP = enemyHP - meDmg
					--Sleep(Animations.GetAttackTime(me)*1000+client.latency+me:GetTurnTime(tempvictim)*1000,"casting")
				end
			elseif not me:DoesHaveModifier("modifier_templar_assassin_meld") or not meld then
				if not me:DoesHaveModifier("modifier_bloodseeker_rupture") then
					me:Follow(tempvictim)
				else
					player:HoldPosition()
				end
			end
			type = nil
			lastOrder = "attack"
		elseif CanMove and SleepCheck("casting") and lastOrder ~= "move" and not me:DoesHaveModifier("modifier_spirit_breaker_charge_of_darkness") and SleepCheck("charge") and me.alive and not me:DoesHaveModifier("modifier_bloodseeker_rupture") and SleepCheck("moving") and (SleepCheck("casting") or ID ~= CDOTA_Unit_Hero_TemplarAssassin) and (not meld or not me:DoesHaveModifier("modifier_templar_assassin_meld") or SleepCheck("casting")) then
			--print("Asd2")
			local mPos = client.mousePosition
			if ID == CDOTA_Unit_Hero_Invoker and quas and quas.level > 0 and SleepCheck("casting3") and ((not tempvictim and (me.maxHealth-me.health) > 100) or ((not wex or wex.level == 0) and (not exort or exort.level == 0))) and not retreat then
				if not me:IsInvisible() and setOrbs("quas", me) then
					Sleep(250, "casting3")
				end
			elseif exort and exort.level > 0 and SleepCheck("casting3") and (not wex or wex.level == 0) then
				if not me:IsInvisible() and setOrbs("exort", me) then
					Sleep(250, "casting3")
				end
			elseif wex and wex.level > 0 and SleepCheck("casting3") then
				if not me:IsInvisible() and setOrbs("wex", me) then
					Sleep(250, "casting3")
				end
			end
			--print(((not targetlock and config.MoveToEnemyWhenLocked) or retreat) , (not tempvictim or (GetDistance2D(me,mPos) > 300 and GetDistance2D(tempvictim,mPos) > 300 and tempvictimVisible and GetDistance2D(tempvictim,me) < 1000 and (me:GetTurnTime(mPos)*2 < Animations.getBackswingTime(me) or me.activity ~= LuaEntityNPC.ACTIVITY_MOVE))) , (temptype and temptype == 1) , (not tempvictim or (tempvictimVisible and GetDistance2D(tempvictim,me) < 1000)))
			if xposition or ((not targetlock and config.MoveToEnemyWhenLocked) or retreat) or ((((not tempvictim or (GetDistance2D(me,mPos) > 300 and GetDistance2D(tempvictim,mPos) > 300 and tempvictimVisible and GetDistance2D(tempvictim,me) < 1000 and (me:GetTurnTime(mPos)*2 < Animations.getBackswingTime(me) or me.activity ~= LuaEntityNPC.ACTIVITY_MOVE))) or (temptype and temptype == 1)) and (not tempvictim or (tempvictimVisible and GetDistance2D(tempvictim,me) < 1000)))) then
				me:Move(mPos)
				type = 1
			elseif (config.AutoMoveToEnemy or not tempvictimVisible or (prediction and GetDistance2D(me,prediction) > range and GetDistance2D(prediction,tempvictim) > 100) or GetDistance2D(me,tempvictim) > 1000) and GetDistance2D(me,mPos) > 100 then
				me:Follow(tempvictim)
			end
			lastOrder = "move"
			start = true
		end
	end
end

function invokeSunstrike(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_sun_strike",me,true)
	return true
end

function invokeColdsnap(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_cold_snap",me,true)
	return true
end

function invokeGhostwalk(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_ghost_walk",me,true)
	return true
end

function invokeIcewall(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_ice_wall",me,true)
	return true
end

function invokeEmp(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_emp",me,true)
	return true
end

function invokeChaosmeteor(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_chaos_meteor",me,true)
	return true
end

function invokeTornado(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_tornado",me,true)
	return true
end

function invokeAlacrity(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_alacrity",me,true)
	return true
end

function invokeBlast(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_deafening_blast",me,true)
	return true
end

function invokeForgespirit(button, button2, text) 
	local me = entityList:GetMyHero()
	prepareSpell("invoker_forge_spirit",me,true)
	return true
end

function chainStun(target, delay, except, onlychain)
	local chain = false
	local stunned = false
	local modifiers_table = {"modifier_shadow_demon_disruption", "modifier_obsidian_destroyer_astral_imprisonment_prison", 
		"modifier_eul_cyclone", "modifier_invoker_tornado", "modifier_bane_nightmare", "modifier_shadow_shaman_shackles", 
		"modifier_crystal_maiden_frostbite", "modifier_ember_spirit_searing_chains", "modifier_axe_berserkers_call",
		"modifier_lone_druid_spirit_bear_entangle_effect", "modifier_meepo_earthbind", "modifier_naga_siren_ensnare",
		"modifier_storm_spirit_electric_vortex_pull", "modifier_treant_overgrowth", "modifier_cyclone",
		"modifier_sheepstick_debuff", "modifier_shadow_shaman_voodoo", "modifier_lion_voodoo", "modifier_brewmaster_storm_cyclone",
		"modifier_puck_phase_shift", "modifier_dark_troll_warlord_ensnare" , "modifier_invoker_deafening_blast_knockback"}
	local modifiers = target.modifiers
	local length = #modifiers_table
	table.sort(modifiers, function (a,b) return a.remainingTime > b.remainingTime end)
	for i = 1, #modifiers do
		local m = modifiers[i]
		for z = 1, length do
			local k = modifiers_table[z]
			if m and (m.stunDebuff or m.name == k) and (not except or m.name ~= except) and m.name ~= "modifier_invoker_cold_snap" then
				stunned = true
				local remainingTime = m.remainingTime
				if m.name == "modifier_eul_cyclone" or m.name == "modifier_invoker_tornado" then remainingTime = m.remainingTime+0.07 end
				--print(remainingTime,delay)
				if remainingTime > 0 and remainingTime <= delay then					
					--print(m.name,remainingTime,delay)
					chain = true
				else
					chain = false
				end
			end
		end
	end
	--print((not (stunned or target:IsStunned()) or chain), (onlychain and chain), SleepCheck("stun"))
	return (((not (stunned or target:IsStunned() or target:IsRooted() or not target:CanMove() or target:IsHexed()) or chain) and SleepCheck("stun") and not onlychain) or (onlychain and chain))
end

function stunDuration(target)
	local modifiers_table = {"modifier_shadow_demon_disruption", "modifier_obsidian_destroyer_astral_imprisonment_prison", 
		"modifier_eul_cyclone", "modifier_invoker_tornado", "modifier_bane_nightmare", "modifier_shadow_shaman_shackles", 
		"modifier_crystal_maiden_frostbite", "modifier_ember_spirit_searing_chains", "modifier_axe_berserkers_call",
		"modifier_lone_druid_spirit_bear_entangle_effect", "modifier_meepo_earthbind", "modifier_naga_siren_ensnare",
		"modifier_storm_spirit_electric_vortex_pull", "modifier_treant_overgrowth", "modifier_cyclone",
		"modifier_sheepstick_debuff", "modifier_shadow_shaman_voodoo", "modifier_lion_voodoo", "modifier_brewmaster_storm_cyclone",
		"modifier_puck_phase_shift", "modifier_dark_troll_warlord_ensnare" , "modifier_invoker_deafening_blast_knockback"}
	local modifiers = target.modifiers
	local length = #modifiers_table
	table.sort(modifiers, function (a,b) return a.remainingTime > b.remainingTime end)
	for i = 1, #modifiers do
		local m = modifiers[i]
		for z = 1, length do
			local k = modifiers_table[z]
			if m and (m.stunDebuff or m.name == k) and m.name ~= "modifier_invoker_cold_snap" then
				local remainingTime = m.remainingTime
				if m.name == "modifier_eul_cyclone" then remainingTime = m.remainingTime+0.07 end
				return remainingTime
			end
		end
	end
	if target:IsChanneling() then
		local ab = target:GetChanneledAbility()
		return ab:GetChannelTime(ab.level) - ab.channelTime
	end
	local abilities = target.abilities
	for i = 1, #abilities do
		local v = abilities[i]
		if v.abilityPhase then
			return v:FindCastPoint()
		end
	end
	return 0
end

class 'MyHero'

function MyHero:__init(heroEntity)
	self.heroEntity = heroEntity
	local name = heroEntity.name
	if not heroInfo[name] then
		return nil
	end
end

function MyHero:GetAttackRange()
	local bonus = 0
	if self.heroEntity.classId == CDOTA_Unit_Hero_TemplarAssassin then	
		local psy = self.heroEntity:GetAbility(3)
		psyrange = {60,120,180,240}		
		if psy and psy.level > 0 then		
			bonus = psyrange[psy.level]			
		end
	elseif self.heroEntity.classId == CDOTA_Unit_Hero_Sniper then	
		local aim = self.heroEntity:GetAbility(3)
		aimrange = {100,200,300,400}		
		if aim and aim.level > 0 then		
			bonus = aimrange[aim.level]			
		end		
	elseif self.heroEntity.classId == CDOTA_Unit_Hero_Enchantress then
		if enablemodifiers then
			local impetus = self.heroEntity:GetAbility(4)
			if impetus.level > 0 and self.heroEntity:AghanimState() then
				bonus = 190
			end
		end
	elseif self.heroEntity.classId == CDOTA_Unit_Hero_LoneDruid then
		local lonetrue = self.heroEntity:FindSpell("lone_druid_true_form")
		if self.heroEntity.attackRange < 130 and (not (lonetrue and lonetrue.level > 0) or not self.heroEntity:DoesHaveModifier("modifier_lone_druid_true_form")) then
			bonus = 423
		end
	end
	local winter = self.heroEntity:FindSpell("winter_wyvern_arctic_burn")
	if winter and winter.level > 0 and self.heroEntity:DoesHaveModifier("modifier_winter_wyvern_arctic_burn") then
		bonus = winter:GetSpecialData("attack_range_bonus")
	end
	local dragon = self.heroEntity:FindSpell("dragon_knight_elder_dragon_form")
	if dragon and dragon.level > 0 and self.heroEntity:DoesHaveModifier("modifier_dragon_knight_dragon_form") then
		bonus = 372
	end
	local terrormorph = self.heroEntity:FindSpell("terrorblade_metamorphosis")
	if terrormorph and terrormorph.level > 0 and self.heroEntity:DoesHaveModifier("modifier_terrorblade_metamorphosis") then
		bonus = 422
	end
	return self.heroEntity.attackRange + bonus
end

function MyHero:Hit(target)
	if target and target.team ~= self.heroEntity.team then
		if target and target.hero then
			if self.heroEntity.classId == CDOTA_Unit_Hero_Clinkz then
				local searinga = self.heroEntity:GetAbility(2)
				if searinga.level > 0 and self.heroEntity.mana > 10 then
					self.heroEntity:SafeCastAbility(searinga, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_DrowRanger and not target:IsMagicImmune() then
				local frost = self.heroEntity:GetAbility(1)
				if frost.level > 0 and self.heroEntity.mana > 12 then
					self.heroEntity:SafeCastAbility(frost, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Viper and not target:IsMagicImmune() then
				local poison = self.heroEntity:GetAbility(1)
				if poison.level > 0 and self.heroEntity.mana > 21 then
					self.heroEntity:SafeCastAbility(poison, target)
				else self.heroEntity:Attack(target) end  
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Huskar and not target:IsMagicImmune() then
				local burning = self.heroEntity:GetAbility(2)
				if burning.level > 0 and self.heroEntity.health > 15 then
					self.heroEntity:SafeCastAbility(burning, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Silencer and not target:IsMagicImmune() then
				local glaives = self.heroEntity:GetAbility(2)
				if glaives.level > 0 and self.heroEntity.mana > 15 then
					self.heroEntity:SafeCastAbility(glaives, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Jakiro and not target:IsMagicImmune() then
				local liquid = self.heroEntity:GetAbility(3)
				if liquid.level > 0 and liquid:CanBeCasted() then
					self.heroEntity:SafeCastAbility(liquid, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Obsidian_Destroyer and not target:IsMagicImmune() then
				local arcane = self.heroEntity:GetAbility(1)
				if arcane.level > 0 and self.heroEntity.mana > 100 then
					self.heroEntity:SafeCastAbility(arcane, target)
				else self.heroEntity:Attack(target) end
			elseif self.heroEntity.classId == CDOTA_Unit_Hero_Enchantress and not target:IsMagicImmune() then
				local impetus = self.heroEntity:GetAbility(4)
				local impemana = {55,60,65}
				if impetus.level > 0 and self.heroEntity.mana > impemana[impetus.level] then
					self.heroEntity:SafeCastAbility(impetus, target)
				else self.heroEntity:Attack(target) end
			else
				self.heroEntity:Attack(target)
			end
		else
			self.heroEntity:Attack(target)
		end
	end
end

--Return max value from table
function max(t, fn)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            key, value = i, t[i]
        end
    end
    return key, value
end

--Invoker: Spell Invoking
function prepareSpell(name,me,click)
	local abilities = me.abilities
	local spell = me:FindSpell(name)
	local quas, wex, exort, invoke, spell2 = abilities[1], abilities[2], abilities[3], abilities[6], abilities[5]  
	--print(spell.name, spell2.name)
	if not invoke:CanBeCasted() or not me:CanCast() or (spell2.cd <= spell.cd and not click and not retreat and combo == 0 and spell and spell2.name ~= "invoker_empty2" and spell2.name ~= "invoker_empty1") then return end
	if name == "invoker_cold_snap" and quas.level > 0 then
		me:CastAbility(quas) me:CastAbility(quas) me:CastAbility(quas)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_ice_wall" and quas.level > 0 and exort.level > 0 then
		me:CastAbility(quas) me:CastAbility(quas) me:CastAbility(exort)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_forge_spirit" and quas.level > 0 and exort.level > 0 then
		me:CastAbility(quas) me:CastAbility(exort) me:CastAbility(exort)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_sun_strike" and exort.level > 0 then
		me:CastAbility(exort) me:CastAbility(exort) me:CastAbility(exort)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_chaos_meteor" and exort.level > 0 and wex.level > 0 then
		me:CastAbility(exort) me:CastAbility(exort) me:CastAbility(wex)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_deafening_blast" and quas.level > 0 and exort.level > 0 and wex.level > 0 then
		me:CastAbility(quas) me:CastAbility(wex) me:CastAbility(exort)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_alacrity" and exort.level > 0 and wex.level > 0 then
		me:CastAbility(wex) me:CastAbility(wex) me:CastAbility(exort)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_tornado" and quas.level > 0 and wex.level > 0 then
		me:CastAbility(quas) me:CastAbility(wex) me:CastAbility(wex)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_emp" and wex.level > 0 then
		me:CastAbility(wex) me:CastAbility(wex) me:CastAbility(wex)
		me:CastAbility(invoke)
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	elseif name == "invoker_ghost_walk" and wex.level > 0 and quas.level > 0 then
		me:CastAbility(wex) me:CastAbility(quas) me:CastAbility(quas)
		me:CastAbility(invoke)
		if SleepCheck("casting3") then
			if not me:IsInvisible() and setOrbs("wex", me) then
				Sleep(250, "casting3")
			end
		end
		Sleep(100+client.latency, "casting")
		Sleep(200+client.latency, "casting2")
		return true
	end
end

--Invoker: Orb switching
function setOrbs(orb, me)
	local modif = me.modifiers
	local count = 0
	local spell = me:FindSpell("invoker_"..orb)
	for i = 1, #modif do
		local mod = modif[i]
		if mod.name == "modifier_invoker_"..orb.."_instance" then
			count = count + 1
		end
	end
	if me:IsInvisible() then return false end
	if count == 0 then
		me:CastAbility(spell) me:CastAbility(spell) me:CastAbility(spell)
		return true
	elseif count == 1 then
		me:CastAbility(spell) me:CastAbility(spell)
		return true
	elseif count == 2 then
		me:CastAbility(spell)
		return true
	end
	return false
end

function getBlockPositions(target,rotR,unit)
	local rotR1,rotR2 = -rotR,(-3-rotR)
	local infront = Vector(target.position.x+unit.movespeed*math.cos(rotR), target.position.y+unit.movespeed*math.sin(rotR), target.position.z)
	local behind = Vector(target.position.x+(-unit.movespeed/2)*math.cos(rotR), target.position.y+(-unit.movespeed/2)*math.sin(rotR), target.position.z)
	return Vector(infront.x+90*math.cos(rotR1), infront.y+90*math.sin(rotR1), infront.z),
	Vector(infront.x+90*math.cos(rotR2), infront.y+90*math.sin(rotR2), infront.z),
	Vector(behind.x+120*math.cos(rotR1), behind.y+120*math.sin(rotR1), behind.z),
	Vector(behind.x+120*math.cos(rotR2), behind.y+120*math.sin(rotR2), behind.z),infront
end

function getClosestCamp(me)
	local closest = nil
	local tempJungleCamps = JungleCamps
	local mouPos = client.mousePosition
	for i = 1, #tempJungleCamps do
		local camp = tempJungleCamps[i]	
		if not camp.farmed then
			if (not closest and (not camp.stacked or camp.stacked == me.handle)) or (closest and GetDistance2D(mouPos,camp.waitPosition) < GetDistance2D(mouPos,closest.waitPosition) and (not camp.stacked or camp.stacked == me.handle)) or camp.stacked == me.handle then
				closest = camp
			end
		end
	end
	return closest
end

function CanGoInvis(hero) 
	local invis = hero:FindSpell("bounty_hunter_wind_walk") or hero:FindSpell("clinkz_skeleton_walk") or hero:FindItem("item_invis_sword") or hero:FindItem("item_silver_edge") or hero:FindItem("item_glimmer_cape") or hero:FindItem("item_moon_shard")
	local riki = hero:FindSpell("riki_permanent_invisibility")
	return (invis and invis:CanBeCasted()) or riki
end

function CanBeSlowed(target)
	return not target:IsMagicImmune() and not target:IsInvul() and not target:DoesHaveModifier("modifier_rune_haste") and not target:DoesHaveModifier("modifier_lycan_shapeshift") and not target:DoesHaveModifier("modifier_centaur_stampede")
end
	
function rotateX(x,y,angle)
    return x*math.cos(angle) - y*math.sin(angle)
end
       
function rotateY(x,y,angle)
    return y*math.cos(angle) + x*math.sin(angle)
end

function GetXX(ent)
	local team = ent.team
	if team == 2 then		
		return client.screenSize.x/txxG + 1
	elseif team == 3 then
		return client.screenSize.x/txxB 
	end
end

function IsMouseOnButton(x,y,h,w)
	local mx = client.mouseScreenPosition.x
	local my = client.mouseScreenPosition.y
	return mx > x and mx <= x + w and my > y and my <= y + h
end

----Check Version
function Version()
	local file = io.open(SCRIPT_PATH.."/MCScript_version_by_ensage-forum.ru.lua", "r")
	local ver = nil
	if file then
		ver = file:read("*number")
		file:read("*line")
		beta = file:read("*line")
		info = file:read("*line")
		file:close()
	end
	if ver then
		local bcheck = ""..beta
		if ver <= currentVersion and (bcheck == Beta or ver < currentVersion) then
			outdated = false
			return true,ver,beta,info
		elseif ver > currentVersion or (bcheck ~= Beta and ver <= currentVersion) then
			outdated = true
			return false,ver,beta,info
		end
	else
		versionSign.text = "You didn't download version info file from ensage-forum.ru Please do so to keep the script updated."
		versionSign.color = -1
		return false
	end
end	

function FindEntity(cast,me,dayvision,m1)
	for i = 1, #cast do
		local z = cast[i]
		if (not dayvision or z.dayVision == dayvision) and (not m1 or z:DoesHaveModifier(m1)) then
			return z
		end
	end
	return nil
end

function Load()
	
	--VersionInfo
	local up,ver,beta,info = Version()
	if up then
		if Beta ~= "" then
			versionSign.text = "Your version of MCScript by ensage-forum.ru is up-to-date! (v"..currentVersion.." "..Beta..")"
		else
			versionSign.text = "Your version of MCScript by ensage-forum.ru is up-to-date! (v"..currentVersion..")"
		end
		versionSign.color = 0x007ACCFF
		if info then
			infoSign.text = info
			infoSign.visible = true
		end
	end
	if outdated then
		if beta ~= "" then
			versionSign.text = "Your version of MCScript by ensage-forum.ru is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.." "..beta.."), to find news and updates, go to ensage-forum.ru!"
		else
			versionSign.text = "Your version of MCScript by ensage-forum.ru is OUTDATED (Yours: v"..currentVersion.." "..Beta.." Current: v"..ver.."), to find news and updates, go to ensage-forum.ru!"
		end
		versionSign.color = 0xA40062FF
		if info then
			infoSign.text = info
			infoSign.visible = true
		end
	end
	versionSign.visible = true
	
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then 
			script:Disable()
		else
			local mathfloor = math.floor
			if mathfloor(client.screenRatio*100) == 177 then testX = 1600 tinfoHeroSize = 55 tinfoHeroDown = 25.714 txxB = 2.535 txxG = 3.485
			elseif mathfloor(client.screenRatio*100) == 166 then testX = 1280 tinfoHeroSize = 47.1 tinfoHeroDown = 25.714 txxB = 2.558 txxG = 3.62
			elseif mathfloor(client.screenRatio*100) == 160 then testX = 1280 tinfoHeroSize = 48.5 tinfoHeroDown = 25.714 txxB = 2.579 txxG = 3.74
			elseif mathfloor(client.screenRatio*100) == 133 then testX = 1024 tinfoHeroSize = 47 tinfoHeroDown = 25.714 txxB = 2.78 txxG = 4.63
			elseif mathfloor(client.screenRatio*100) == 125 then testX = 1280 tinfoHeroSize = 58 tinfoHeroDown = 25.714 tinfoHeroSS = 23 txxB = 2.747 txxG = 4.54
			else testX = 1600 tinfoHeroSize = 55 tinfoHeroDown = 25.714 tinfoHeroSS = 22 txxB = 2.535 txxG = 3.485 end
			rate = client.screenSize.x/testX
			con = rate
			if rate < 1 then rate = 1 end
			x_ = tinfoHeroSize*(con)
			y_ = client.screenSize.y/tinfoHeroDown
			monitor = client.screenSize.x/1600
			atr = nil
			statusText.visible = false
			myhero = nil
			reg = true
			victim = nil
			if HUD and (HUD:IsClosed() or HUD:IsMinimized()) and me.classId == CDOTA_Unit_Hero_Invoker then
				HUD:Open()
			end
			start = false
			useblink = config.UseBlink
			myId = me.classId
			sleep = 0 
			xposition = nil
			comboready = false
			lastCastPrediction = nil
			resettime = nil
			targetlock = false
			type = nil
			enemyHP = nil
			mySpells = nil
			retreat = false
			lastPrediction = nil
			stackTable = {}
			combo = 0
			esstone = false
			checked = false
			harras = false
			trolltoggle = false
			JungleCamps = {
				{position = Vector(-1131,-4044,127), stackPosition = Vector(-2750.94,-3517.86,128), waitPosition = Vector(-1401.69,-3791.52,128), team = 2, id = 1, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 54.5},
				{position = Vector(-366,-2945,127), stackPosition = Vector(-534.219,-1795.27,128), waitPosition = Vector(-408,-2731,127), team = 2, id = 2, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 55},
				{position = Vector(1606.45,-3433.36,256), stackPosition = Vector(1598.19,-5117.22,256), waitPosition = Vector(1541.87,-4265.38,256), team = 2, id = 3, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 54.5},
				{position = Vector(3126,-3439,256), stackPosition = Vector(5284.49,-3922,256), waitPosition = Vector(3231,-3807,256), team = 2, id = 4, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 53.1},
				{position = Vector(3031.03,-4480.06,256), stackPosition = Vector(3774.15,-6700.85,256), waitPosition = Vector(3030,-4975,256), team = 2, id = 5, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 53},
				{position = Vector(-2991,191,256), stackPosition = Vector(-3351,-1798,205), waitPosition = Vector(-2684,-23,256), team = 2, id = 6, farmed = false, lvlReq = 12, visible = false, visTime = 0, ancients = true, stacking = false, stacked = nil, stackTime = 54},
				{position = Vector(1167,3295,256), stackPosition = Vector(570.86,4515.96,256), waitPosition = Vector(1011,3656,256), team = 3, id = 7, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 54},
				{position = Vector(-244,3629,256), stackPosition = Vector(236.481,5000.22,256), waitPosition = Vector(-523,4041,256), team = 3, id = 8, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 54.5},
				{position = Vector(-1588,2697,127), stackPosition = Vector(-1302,3689.41,136.411), waitPosition = Vector(-1491,2986,127), team = 3, id = 9, farmed = false, lvlReq = 3, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 53},
				{position = Vector(-3157.74,4475.46,256), stackPosition = Vector(-3296.1,5508.48,256), waitPosition = Vector(-3086,4924,256), team = 3, id = 10, farmed = false, lvlReq = 1, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 54},
				{position = Vector(-4382,3612,256), stackPosition = Vector(-3026.54,3819.69,132.345), waitPosition = Vector(-4200,3850,256), team = 3, id = 11, farmed = false, lvlReq = 8, visible = false, visTime = 0, stacking = false, stacked = nil, stackTime = 53},
				{position = Vector(4026,-709.943,128), stackPosition = Vector(2636,-1017,127), waitPosition = Vector(3583,-736,127), team = 3, id = 12, farmed = false, lvlReq = 12, visible = false, visTime = 0,  ancients = true, stacking = false, stacked = nil, stackTime = 54}
			}
			camp = nil
			tuskSnowBall = false
			positionsTable = {}
			PuckPosition = nil
			lastChakram1 = nil 
			lastChakram2 = nil 
			lastTreeID = nil
			stunAbility = nil
			directiontable = {}
			LastCastedTable = {}
			indicate = {}
			damageTable = {}
			comboTable = {
				{ CDOTA_Unit_Hero_Ursa, {{ 1, "shock_radius", true}, { 2, nil, false, nil, false, nil, false, nil, nil, true, true }, { 5, 350, false, nil, false, nil, false, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Bloodseeker, {{ 4, nil, false, nil, false, nil, false, nil, nil, true }, { 2 , nil, false, 2.6}, { 1, nil, false, nil, false, nil, false, nil, nil, true, true }} },
				{ CDOTA_Unit_Hero_Lina, {{ 2, nil, true , 0.5}, { 1, nil, true, nil, false, "dragon_slave_speed", nil, nil, nil, nil, true }, { 4, nil, false, nil, killsteal, nil, nil, nil, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Zuus, {{ 2, nil, true }, { 1, nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, { 4, nil, true, -0.1, killsteal, nil, nil, nil, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Tinker, {{ 2 , "radius"}, { 1 }, { 4, nil, nil, nil, nil, nil, nil, nil, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Lion, {{ 1, 450, true, nil, nil, nil, nil, "width" }, { 2, nil, true }, { 4, nil, false, nil, killsteal, nil, nil, nil, nil, nil, true }} },
				{ CDOTA_Unit_Hero_ShadowShaman, {{ 2, nil, true }, { 3, nil, true, nil, nil, nil, nil, nil, nil, nil, true }, { 1, nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, { 4 }} },
				{ CDOTA_Unit_Hero_Axe, {{ 1, "radius", true }, { 2 }, { 4, nil, false, nil, true, nil, false, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Necrolyte, {{ 1, "area_of_effect" }, { 4 }} },
				{ CDOTA_Unit_Hero_PhantomAssassin, {{ 1, nil, true, nil, false, "dagger_speed" }, { 2, nil, nil, nil, nil, nil, nil, nil, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Pudge, {{ 1, nil, false, nil, false, "hook_speed", true, "hook_width", true, true }, { 4, nil, true, nil, nil, nil, nil, nil, nil, true, true }} },
				{ CDOTA_Unit_Hero_Earthshaker, {{ 4, 625, true}, { 2, 350, true }, { 1, nil, true, -0.1 }} },
				{ CDOTA_Unit_Hero_Skywrath_Mage, {{ 2, "launch_radius", true }, { 3 }, { 4, nil, false, 0.2 }, { 1 }} },
				{ CDOTA_Unit_Hero_Leshrac, {{ 1, nil, true, 0.35}, { 2, "radius" }, { 3, nil, true }, { 4, "radius" }} },
				{ CDOTA_Unit_Hero_Windrunner, {{ 1, nil, true, nil, false, "arrow_speed" }, { 2, nil, true, nil, false, "arrow_speed" }} },
				{ CDOTA_Unit_Hero_Rattletrap, {{ 4, nil, true, nil, false, nil, true, "latch_radius", true, true }, { 1, "radius", true, 0.7 }, { 3 }, { 2, 125, true, 0.1 }} },
				{ CDOTA_Unit_Hero_Ogre_Magi, {{ 4, nil, true }, { 1, nil, true }, { 2, nil, true, nil, false, "projectile_speed" }, { 3 }} },
				{ CDOTA_Unit_Hero_Kunkka, {{ "kunkka_x_marks_the_spot", nil, false, 0.1 }, { 1, nil, true, 1.7 }, { 4, nil, false, nil, false, "ghostship_speed" }} },
				{ CDOTA_Unit_Hero_Slardar, {{ 2, "crush_radius", true}, { 1, nil, true }, { 4 }} },
				{ CDOTA_Unit_Hero_Bane, {{ "bane_nightmare", nil, true, 1 }, { 4, nil, true}, { "bane_enfeeble" , nil, true }, { 2, nil, true }} },
				{ CDOTA_Unit_Hero_Bristleback, {{ 1 }, { 2, "radius", false, nil, false, nil, false, nil, nil, true }} },
				{ CDOTA_Unit_Hero_Centaur, {{ 1, "radius" }, { 2 }} },
				{ CDOTA_Unit_Hero_Clinkz, {{ 1, 630 }} },
				{ CDOTA_Unit_Hero_CrystalMaiden, {{ 1, nil, true, -0.1 }, { 2, nil, true }} },
				{ CDOTA_Unit_Hero_DeathProphet, {{ 1, nil, true }, { 2, nil, true, -0.1 }} },
				{ CDOTA_Unit_Hero_DoomBringer, {{ 2, "radius" }, { 4, nil, true }, { 3, nil, true}} },
				{ CDOTA_Unit_Hero_DragonKnight, {{ 2, nil, true }, { 1, nil, true }} },
				{ CDOTA_Unit_Hero_DrowRanger, {{ 2, nil, true, nil, false, "wave_speed" }} },
				{ CDOTA_Unit_Hero_Furion, {{ 1, nil, true, -0.1 }} },
				{ CDOTA_Unit_Hero_Huskar, {{ 4, nil, false, nil, false, "charge_speed" }} },
				{ CDOTA_Unit_Hero_Jakiro, {{ 2, nil, true, 0.5 }, { 1, nil, true }} },
				{ CDOTA_Unit_Hero_Lich, {{ 1, nil, true }, { 2 }} },
				{ CDOTA_Unit_Hero_Life_Stealer, {{ 3, nil, true }} },
				{ CDOTA_Unit_Hero_Luna, {{ 1, nil, true }} },
				{ CDOTA_Unit_Hero_Mirana, {{ 2, nil, true, nil, false, "arrow_speed", true, "arrow_width", "ally" }, { 1, 400 }} },
				{ CDOTA_Unit_Hero_Morphling, {{ 1 }, { 2, nil, true, nil, false, "projectile_speed" }} },
				{ CDOTA_Unit_Hero_NightStalker, {{ 1, nil, true }, { 2, nil, true}} },
				{ CDOTA_Unit_Hero_Nyx_Assassin, {{ 1, nil, true }, { 2 }} },
				{ CDOTA_Unit_Hero_QueenOfPain, {{ 1, nil, true, nil, false, "projectile_speed" }, { 3 , "area_of_effect" }, { 4, nil, true, nil, false, "speed" }} },
				{ CDOTA_Unit_Hero_Razor, {{ 2 }, { 1, "radius" }} },
				{ CDOTA_Unit_Hero_Riki, {{ 1, nil, true, -0.1 }, { 4 }} },
				{ CDOTA_Unit_Hero_Sniper, {{ 1, "radius", true, 1.4 }, { 4, nil, false, nil, true }} },
				{ CDOTA_Unit_Hero_SpiritBreaker, {{ 1, nil, true, nil, false, "movement_speed" }, { 4, nil, true }} },
				{ CDOTA_Unit_Hero_Sven, {{ "sven_storm_bolt", nil, true, nil, false, "bolt_speed" }} },
				{ CDOTA_Unit_Hero_Tidehunter, {{ 1, nil, true, nil, false, "projectile_speed" }, { 3, "radius"}} },
				{ CDOTA_Unit_Hero_Tiny, {{ 1, nil, true, 0.5 }, { 2 }} },
				{ CDOTA_Unit_Hero_Invoker, {} },
				{ CDOTA_Unit_Hero_TemplarAssassin, {{ 2, nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, { 1 }} },
				{ CDOTA_Unit_Hero_Abaddon, {{ 2 }, { 1 }} },
				{ CDOTA_Unit_Hero_AncientApparition, {{ 1, nil, true, 4 }, { 2, nil, true }, { "ancient_apparition_ice_blast", nil, true, 2.01}, { "ancient_apparition_ice_blast_release" }} },
				{ CDOTA_Unit_Hero_AntiMage, {{ 4, nil, false, nil, true }} },
				{ CDOTA_Unit_Hero_Batrider, {{ 4, nil, true, "duration", false, nil, false, nil, nil, true }, { 1, nil, false, 0.2 }, { 2, nil, true, 0.3 }} },
				{ CDOTA_Unit_Hero_Beastmaster, {{ "beastmaster_primal_roar", nil, true }, { 1, nil, true }, { "beastmaster_call_of_the_wild_boar", nil, true }} },
				{ CDOTA_Unit_Hero_BountyHunter, {{ 4 }, { 1, nil, true, nil, true }} },
				{ CDOTA_Unit_Hero_Broodmother, {{ 1 }} },
				{ CDOTA_Unit_Hero_ChaosKnight, {{ 2, nil, true, nil, nil, nil, nil, nil, nil, nil, true }, { 1, nil, true }} },
				{ CDOTA_Unit_Hero_Elder_Titan, {{ "elder_titan_ancestral_spirit", nil, true }, { 1, "radius", true }, { "elder_titan_earth_splitter" }} },
				{ CDOTA_Unit_Hero_Enchantress, {{ 2, nil, true }} },
				{ CDOTA_Unit_Hero_Enigma, {{ 1, nil, true}, { 3 }} },
				{ CDOTA_Unit_Hero_Legion_Commander, {{ 2 }, { 1, nil, true }, { 4 }} },
				{ CDOTA_Unit_Hero_Magnataur, {{ 1, nil, nil, nil, nil, "shock_speed" }, { 3, nil, true, nil, nil, "skewer_speed" }} },
				{ CDOTA_Unit_Hero_Medusa, {{ 1 }} },
				{ CDOTA_Unit_Hero_Naga_Siren, {{ 2, nil, true, nil, false, "net_speed", nil, nil, nil, true }, { 3, "radius" }} },
				{ CDOTA_Unit_Hero_Omniknight, {{ 1, "radius" }, { 2 }} },
				{ CDOTA_Unit_Hero_Pugna, {{ 1, nil, true }, { 2, nil, true }} },
				{ CDOTA_Unit_Hero_Shadow_Demon, {{ 5, nil, true}, { 1, nil, true }, { 2 }, { 3 }} },
				{ CDOTA_Unit_Hero_SkeletonKing, {{ 1, nil, true, nil, false, "blast_speed" }} },
				{ CDOTA_Unit_Hero_Spectre, {{ 1 }} },
				{ CDOTA_Unit_Hero_VengefulSpirit, {{ 1, nil, true, nil, false, "magic_missile_speed"}, { 2 }} },
				{ CDOTA_Unit_Hero_Venomancer, {{ 1, nil, true }, { 3 }} },
				{ CDOTA_Unit_Hero_Brewmaster, {{ 1, "radius", true }, { 2, nil, true }} },
				{ CDOTA_Unit_Hero_StormSpirit, {{ 4, nil, false, nil, false, "ball_lightning_move_speed" }, { 2, nil, true }, { 1 }} },
				{ CDOTA_Unit_Hero_EmberSpirit, {{ "ember_spirit_fire_remnant" }, { "ember_spirit_activate_fire_remnant" }, { 2, "radius"}, { 1, "radius", true }, { 3, "radius"}} },
				{ CDOTA_Unit_Hero_Slark, {{ 1, "radius"}, { 2, "pounce_radius", true, nil, false, "pounce_speed" }} },
				{ CDOTA_Unit_Hero_Nevermore, {{ "nevermore_requiem" }, { 1, "shadowraze_range"}, { 2, "shadowraze_range"}, { 3, "shadowraze_range"}} },
				{ CDOTA_Unit_Hero_Weaver, {{ 1, "radius"}, { 2 }} },
				{ CDOTA_Unit_Hero_TrollWarlord, {{ "troll_warlord_whirling_axes_ranged", nil, true, nil, false, "axe_speed"}, { "troll_warlord_whirling_axes_melee", "max_range" }} },
				{ CDOTA_Unit_Hero_EarthSpirit, {{ "earth_spirit_petrify", nil, true }, { 1, nil, true }, { 3, nil, false }, { 2, nil, false, 0.6 }, { 4, 400 }} },
				{ CDOTA_Unit_Hero_LoneDruid, {{ "lone_druid_rabid" }, { "lone_druid_true_form_battle_cry", 700 }} },
				{ CDOTA_Unit_Hero_Wisp, {{ "wisp_spirits", 1300 }} },
				{ CDOTA_Unit_Hero_Chen, {{ "chen_penitence" }, { "chen_test_of_faith" }} },
				{ CDOTA_Unit_Hero_Phoenix, {{ 1, nil, true }, { 2, nil, true, nil, nil, "spirit_speed" }, { "phoenix_sun_ray", nil, false, nil, true }, { "phoenix_sun_ray_toggle_move" }} },
				{ CDOTA_Unit_Hero_Tusk, {{ 2, nil, true, nil, false, "snowball_speed" }, { "tusk_ice_shards", nil, true, nil, false, "shard_speed" }, { 3, nil, true }, { "tusk_walrus_punch", nil, false }, { "tusk_walrus_kick", nil, true }} },				
				{ CDOTA_Unit_Hero_Visage, {{ 1, nil, true }, { 2 }} },
				{ CDOTA_Unit_Hero_Gyrocopter, {{ 2, nil, true, 3, false, "speed" }, { 1, "radius" }, { 3, "radius" }} },
				{ CDOTA_Unit_Hero_Undying, {{ 1 }, { 2 }, { 3, "radius" }} },
				{ CDOTA_Unit_Hero_Terrorblade, {{ 4 }, { 1, nil, true }, { 3, 700 }, { 2 }} },
				{ CDOTA_Unit_Hero_Puck, {{ "puck_waning_rift", "radius", true }, { "puck_illusory_orb", nil, false, nil, false, "orb_speed" }, { "puck_ethereal_jaunt" }} },
				{ CDOTA_Unit_Hero_Treant, {{ 2, nil, true }} },
				{ CDOTA_Unit_Hero_PhantomLancer, {{ 1, nil, true, nil, false, "lance_speed" }} },
				{ CDOTA_Unit_Hero_Silencer, {{ 3, nil, true, 4 }, { 2 }} },
				{ CDOTA_Unit_Hero_Disruptor, {{ "disruptor_kinetic_field", nil, true, 1.2 }, { 1 }, { "disruptor_glimpse", nil, true }} },
				{ CDOTA_Unit_Hero_KeeperOfTheLight, {{ "keeper_of_the_light_illuminate" }, { "keeper_of_the_light_spirit_form_illuminate" }, { "keeper_of_the_light_mana_leak", nil, true }, { "keeper_of_the_light_blinding_light", nil, true }} },
				{ CDOTA_Unit_Hero_Oracle, {{ 1, nil, true, nil, false, "bolt_speed" }, { "oracle_purifying_flames", nil, false, nil, true }} },
				{ CDOTA_Unit_Hero_SandKing, {{ 1, nil, true, nil, false, "burrow_speed" }} },
				{ CDOTA_Unit_Hero_Warlock, {{ 1 }, { 2 }} },
				{ CDOTA_Unit_Hero_DarkSeer, {{ 1, "radius", true }, { 4 }, { 2 }, { 3, nil, true }} },
				{ CDOTA_Unit_Hero_Winter_Wyvern, {{ 2 }} },
				{ CDOTA_Unit_Hero_Shredder, {{ 4, "radius", false, 0.5, false, "speed" }, { 6 }, { 5, "radius", false, 0.5, false, "speed" }, { 7 }, { 1, "whirling_radius" }, { 2, "chain_radius", false, nil, false, "speed" }} },
				{ CDOTA_Unit_Hero_Rubick, {{ 1, nil, true }, { "rubick_telekinesis_land" }, { "ursa_earthshock", "shock_radius", true}, 
																			{ "ursa_overpower", nil, false, nil, false, nil, false, nil, nil, true, true }, 
																			{ "ursa_enrage", 350, false, nil, false, nil, false, nil, nil, true },
																			{ "bloodseeker_rupture", nil, false, nil, false, nil, false, nil, nil, true }, 
																			{ "bloodseeker_blood_bath" , nil, false, 2.6}, 
																			{ "bloodseeker_bloodrage", nil, false, nil, false, nil, false, nil, nil, true, true },
  																			{ "lina_light_strike_array", nil, true , 0.5}, 
																			{ "lina_dragon_slave", nil, true, nil, false, "dragon_slave_speed", nil, nil, nil, nil, true }, 
																			{ "lina_laguna_blade", nil, false, nil, killsteal, nil, nil, nil, nil, nil, true }, 
																			{ "zuus_lightning_bolt", nil, true }, 
																			{ "zuus_arc_lightning", nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "zuus_thundergods_wrath", nil, true, -0.1, killsteal, nil, nil, nil, nil, nil, true },
																			{ "tinker_heat_seeking_missile" , "radius"}, 
																			{ "tinker_laser" }, 
																			{ "tinker_rearm", nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "lion_voodoo", 450, true }, 
																			{ "lion_impale", nil, true }, 
																			{ "lion_finger_of_death", nil, false, nil, killsteal, nil, nil, nil, nil, nil, true },
																			{ "shadow_shaman_voodoo", nil, true }, 
																			{ "shadow_shaman_shackles", nil, true, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "shadow_shaman_ether_shock", nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "shadow_shaman_mass_serpent_ward" },
																			{ "axe_berserkers_call", "radius", true }, 
																			{ "axe_battle_hunger" }, 
																			{ "axe_culling_blade", nil, false, nil, true, nil, false, nil, nil, true },
																			{ "necrolyte_death_pulse", "area_of_effect" }, 
																			{ "necrolyte_reapers_scythe" },
																			{ "phantom_assassin_stifling_dagger", nil, true, nil, false, "dagger_speed" }, 
																			{ "phantom_assassin_phantom_strike", nil, nil, nil, nil, nil, nil, nil, nil, nil, true },
																			{ "pudge_meat_hook", nil, true, nil, false, "hook_speed", true, "hook_width", true, true }, 
																			{ "pudge_dismember", nil, true, nil, nil, nil, nil, nil, nil, true, true },
																			{ "earthshaker_echo_slam", 625, true}, 
																			{ "earthshaker_enchant_totem", 350, true }, 
																			{ "earthshaker_fissure", nil, true, -0.1 },
																			{ "skywrath_mage_concussive_shot", "launch_radius", true }, 
																			{ "skywrath_mage_ancient_seal" }, 
																			{ "skywrath_mage_mystic_flare", nil, false, 0.2 }, 
																			{ "skywrath_mage_ancient_seal" },
																			{ "leshrac_split_earth", nil, true, 0.35}, 
																			{ "leshrac_diabolic_edict", "radius" }, 
																			{ "leshrac_lightning_storm", nil, true }, 
																			{ "leshrac_pulse_nova", "radius" },
																			{ "windrunner_shackleshot", nil, true, nil, false, "arrow_speed" }, 
																			{ "windrunner_powershot", nil, true, nil, false, "arrow_speed" },
																			{ "rattletrap_hookshot", nil, true, nil, false, nil, true, "latch_radius", true, true }, 
																			{ "rattletrap_battery_assault", "radius", true, 0.7 }, 
																			{ "rattletrap_rocket_flare" }, 
																			{ "rattletrap_power_cogs", 125, true, 0.1 },
																			{ "ogre_magi_unrefined_fireblast", nil, true }, 
																			{ "ogre_magi_fireblast", nil, true }, 
																			{ "ogre_magi_ignite", nil, true, nil, false, "projectile_speed" }, 
																			{ "ogre_magi_bloodlust" },
																			{ "kunkka_x_marks_the_spot", nil, false, 0.1 }, 
																			{ "kunkka_torrent", nil, true, 1.7 }, 
																			{ "kunkka_ghostship", nil, false, nil, false, "ghostship_speed" },
																			{ "slardar_slithereen_crush", "crush_radius", true}, 
																			{ "slardar_sprint", nil, true }, 
																			{ "slardar_amplify_damage" },
																			{ "bane_nightmare", nil, true, 1 }, 
																			{ "bane_fiends_grip", nil, true}, 
																			{ "bane_enfeeble" , nil, true }, 
																			{ "bane_brain_sap", nil, true },
																			{ "bristleback_viscous_nasal_goo" }, 
																			{ "bristleback_quill_spray", "radius", false, nil, false, nil, false, nil, nil, true },
																			{ "centaur_hoof_stomp", "radius", true }, 
																			{ "centaur_double_edge" },
																			{ "clinkz_strafe", 630 },
																			{ "crystal_maiden_freezing_field", nil, true, -0.1 }, 
																			{ "crystal_maiden_frostbite", nil, true },
																			{ "death_prophet_carrion_swarm", nil, true }, 
																			{ "death_prophet_silence", nil, true, -0.1 },
																			{ "doom_bringer_scorched_earth", "radius" }, 
																			{ "doom_bringer_doom", nil, true }, 
																			{ "doom_bringer_lvl_death", nil, true},
																			{ "dragon_knight_dragon_tail", nil, true }, 
																			{ "dragon_knight_breathe_fire", nil, true },
																			{ "drow_ranger_wave_of_silence", nil, true, nil, false, "wave_speed" },
																			{ "furion_sprout", nil, true, -0.1 },
																			{ "huskar_life_break", nil, false, nil, false, "charge_speed" },
																			{ "jakiro_ice_path", nil, true, 0.5 }, 
																			{ "jakiro_dual_breath", nil, true },
																			{ "lich_frost_nova", nil, true }, 
																			{ "lich_frost_armor" },
																			{ "life_stealer_open_wounds", nil, true },
																			{ "luna_lucent_beam", nil, true },
																			{ "mirana_arrow", nil, true, nil, false, "arrow_speed", true, "arrow_width", "ally" }, 
																			{ "mirana_starfall", 400 },
																			{ "morphling_waveform" }, 
																			{ "morphling_adaptive_strike", nil, true, nil, false, "projectile_speed" },
																			{ "night_stalker_void", nil, true }, 
																			{ "night_stalker_crippling_fear", nil, true },
																			{ "nyx_assassin_impale", nil, true }, 
																			{ "nyx_assassin_mana_burn" },
																			{ "queenofpain_shadow_strike", nil, true, nil, false, "projectile_speed" }, 
																			{ "queenofpain_scream_of_pain" , "area_of_effect" }, 
																			{ "queenofpain_sonic_wave", nil, true, nil, false, "speed" },
																			{ "razor_static_link" }, 
																			{ "razor_plasma_field", "radius" },
																			{ "riki_smoke_screen", nil, true, -0.1 }, 
																			{ "riki_blink_strike" },
																			{ "sniper_shrapnel", "radius", true, 1.4 }, 
																			{ "sniper_assassinate", nil, false, nil, true },
																			{ "spirit_breaker_charge_of_darkness", nil, true, nil, false, "movement_speed" }, 
																			{ "spirit_breaker_nether_strike", nil, true },
																			{ "sven_storm_bolt", nil, true, nil, false, "bolt_speed" },
																			{ "tidehunter_gush", nil, true, nil, false, "projectile_speed" }, 
																			{ "tidehunter_anchor_smash", "radius" },
																			{ "tiny_avalanche", nil, true, 0.5 }, 
																			{ "tiny_toss" },
																			{ "invoker_cold_snap"}, {"invoker_ice_wall", 590, true, 1},
																			{ "invoker_tornado", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_emp", nil, false, 2.9},
																			{ "invoker_forge_spirit", 700}, {"invoker_sun_strike", nil, false, 1.7}, {"invoker_chaos_meteor", nil, false, 1.3}, {"invoker_alacrity", nil, nil, nil, nil, nil, nil, nil, nil, nil, true},
																			{ "invoker_deafening_blast", "travel_distance", true, nil, false, "travel_speed"}, {"invoker_ghost_walk", nil, true},
																			{ "templar_assassin_meld", nil, nil, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "templar_assassin_refraction" },
																			{ "abaddon_aphotic_shield" }, { "abaddon_death_coil" },
																			{ "ancient_apparition_cold_feet", nil, true, 4 }, 
																			{ "ancient_apparition_ice_vortex", nil, true }, 
																			{ "ancient_apparition_ice_blast", nil, true, 2.01}, 
																			{ "ancient_apparition_ice_blast_release" },
																			{ "antimage_mana_void", nil, false, nil, true },
																			{ "batrider_flaming_lasso", nil, true, "duration", false, nil, false, nil, nil, true }, 
																			{ "batrider_sticky_napalm", nil, false, 0.2 }, 
																			{ "batrider_flamebreak", nil, true, 0.3 },
																			{ "beastmaster_primal_roar", nil, true }, 
																			{ "beastmaster_wild_axes", nil, true }, 
																			{ "beastmaster_call_of_the_wild_boar", nil, true },
																			{ "bounty_hunter_track" }, 
																			{ "bounty_hunter_shuriken_toss", nil, true, nil, true },
																			{ "broodmother_spawn_spiderlings" },
																			{ "chaos_knight_chaos_strike", nil, true, nil, nil, nil, nil, nil, nil, nil, true }, 
																			{ "chaos_knight_chaos_bolt", nil, true },
																			{ "elder_titan_ancestral_spirit", nil, true }, 
																			{ "elder_titan_echo_stomp", "radius", true }, 
																			{ "elder_titan_earth_splitter" },
																			{ "enchantress_enchant", nil, true },
																			{ "enigma_malefice", nil, true}, 
																			{ "enigma_midnight_pulse" },
																			{ "legion_commander_press_the_attack" }, 
																			{ "legion_commander_overwhelming_odds", nil, true }, 
																			{ "legion_commander_duel" },
																			{ "magnataur_shockwave", nil, nil, nil, nil, "shock_speed" }, 
																			{ "magnataur_skewer", nil, true, nil, nil, "skewer_speed" },
																			{ "medusa_mystic_snake" },
																			{ "naga_siren_ensnare", nil, true, nil, false, "net_speed", nil, nil, nil, true }, 
																			{ "naga_siren_rip_tide", "radius" },
																			{ "omniknight_purification" },
																			{ "omniknight_repel" },
																			{ "pugna_nether_blast", nil, true }, 
																			{ "pugna_decrepify", nil, true },
																			{ "shadow_demon_demonic_purge", nil, true}, 
																			{ "shadow_demon_disruption", nil, true }, 
																			{ "shadow_demon_soul_catcher" }, 
																			{ "shadow_demon_shadow_poison" },
																			{ "skeleton_king_hellfire_blast", nil, true, nil, false, "blast_speed" },
																			{ "spectre_spectral_dagger" },
																			{ "vengefulspirit_magic_missile", nil, true, nil, false, "magic_missile_speed"}, 
																			{ "vengefulspirit_wave_of_terror" },
																			{ "venomancer_venomous_gale", nil, true }, 
																			{ "venomancer_plague_ward" },
																			{ "brewmaster_thunder_clap", "radius", true }, 
																			{ "brewmaster_drunken_haze", nil, true },
																			{ "storm_spirit_ball_lightning", nil, true, nil, false, "ball_lightning_move_speed" }, 
																			{ "storm_spirit_electric_vortex", nil, true }, 
																			{ "storm_spirit_static_remnant" },
																			{ "ember_spirit_fire_remnant" }, 
																			{ "ember_spirit_activate_fire_remnant" }, 
																			{ "ember_spirit_sleight_of_fist", "radius"}, 
																			{ "ember_spirit_searing_chains", "radius", true }, 
																			{ "ember_spirit_flame_guard", "radius" },
																			{ "slark_dark_pact", "radius"}, 
																			{ "slark_pounce", "pounce_radius", true, nil, false, "pounce_speed" },
																			{ "nevermore_shadowraze1", "shadowraze_range" }, 
																			{ "nevermore_shadowraze2", "shadowraze_range" }, 
																			{ "nevermore_shadowraze3", "shadowraze_range" },
																			{ "weaver_the_swarm", "radius"}, 
																			{ "weaver_shukuchi" },
																			{ "troll_warlord_whirling_axes_ranged", nil, true, nil, false, "axe_speed"}, 
																			{ "troll_warlord_whirling_axes_melee", "max_range" },
																			{ "earth_spirit_boulder_smash", nil, true }, 
																			{ "earth_spirit_geomagnetic_grip", nil, false }, 
																			{ "earth_spirit_rolling_boulder", nil, false, 0.6 },
																			{ "lone_druid_rabid" }, { "lone_druid_true_form_battle_cry", 700 },
																			{ "wisp_spirits", 1300 },
																			{ "chen_penitence" }, { "chen_test_of_faith" },
																			{ "phoenix_icarus_dive", nil, true }, 
																			{ "phoenix_icarus_dive_stop" }, 
																			{ "phoenix_fire_spirits", nil, true, nil, nil, "spirit_speed" }, 
																			{ "phoenix_sun_ray", nil, false, nil, true }, 
																			{ "phoenix_sun_ray_toggle_move" },
																			{ "tusk_snowball", nil, true, nil, false, "snowball_speed" }, 
																			{ "tusk_ice_shards", nil, true, nil, false, "shard_speed" }, 
																			{ "tusk_frozen_sigil", nil, true }, 
																			{ "tusk_walrus_punch", nil, false }, 
																			{ "tusk_walrus_kick", nil, true },				
																			{ "visage_grave_chill", nil, true }, 
																			{ "visage_soul_assumption" }, 
																			{ "gyrocopter_homing_missile" , nil, true, 3, false, "speed" }, { "gyrocopter_rocket_barrage", "radius" }, 
																			{ "gyrocopter_flak_cannon", "radius" },
																			{ "undying_decay" }, 
																			{ "undying_soul_rip" }, 
																			{ "undying_tombstone", "radius" },
																			{ "terrorblade_sunder" }, 
																			{ "terrorblade_reflection", nil, true }, 
																			{ "terrorblade_metamorphosis" }, 
																			{ "terrorblade_conjure_image" },
																			{ "puck_waning_rift", "radius", true }, 
																			{ "puck_illusory_orb", nil, false, nil, false, "orb_speed" }, 
																			{ "puck_ethereal_jaunt" },
																			{ "treant_leech_seed", nil, true },
																			{ "phantom_lancer_spirit_lance", nil, true, nil, false, "lance_speed" },
																			{ "silencer_last_word", nil, true, 4 }, 
																			{ "silencer_curse_of_the_silent" },
																			{ "disruptor_kinetic_field", nil, true, 1.2 }, 
																			{ "disruptor_thunder_strike" }, 
																			{ "disruptor_glimpse", nil, true },
																			{ "keeper_of_the_light_illuminate" }, 
																			{ "keeper_of_the_light_spirit_form_illuminate" }, 
																			{ "keeper_of_the_light_mana_leak", nil, true }, 
																			{ "keeper_of_the_light_blinding_light", nil, true },
																			{ "oracle_fortunes_end", nil, true, nil, false, "bolt_speed" }, 
																			{ "oracle_purifying_flames", nil, false, nil, true },
																			{ "sandking_burrowstrike", nil, true, nil, false, "burrow_speed" },
																			{ "warlock_fatal_bonds" }, 
																			{ "warlock_shadow_word" },
																			{ "dark_seer_vacuum", "radius", true }, 
																			{ "dark_seer_wall_of_replica" }, 
																			{ "dark_seer_ion_shell" }, 
																			{ "dark_seer_surge", nil, true },
																			{ "winter_wyvern_splinter_blast" }, 
																			{ "shredder_whirling_death", "whirling_radius" }, 
																			{ "shredder_timber_chain", "chain_radius", false, nil, false, "speed" }, 
																			{ "shredder_chakram", "radius", false, 0.2, false, "speed" }, 
																			{ "shredder_return_chakram" }, 
																			{ "shredder_chakram_2", "radius", false, 0.2, false, "speed" }, 
																			{ "shredder_return_chakram_2" }, { 3 }} }
			}
			script:RegisterEvent(EVENT_TICK, Main)
			script:RegisterEvent(EVENT_FRAME, OrbWalk)
			script:RegisterEvent(EVENT_KEY, Key)
			script:UnregisterEvent(Load)
		end
	end	
end

function Close()
	statusText.visible = false
	myhero = nil
	atr = nil
	victim = nil
	myId = nil
	start = false
	resettime = nil
	damageTable = {}
	indicate = {}
	type = nil
	targetlock = false
	tuskSnowBall = false
	if HUD then
		HUD:Close()	
		HUD = nil
		buttons = {}
	end
	collectgarbage("collect")
	if reg then
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		script:UnregisterEvent(OrbWalk)
		script:RegisterEvent(EVENT_TICK, Load)	
		reg = false
	end
end

script:RegisterEvent(EVENT_CLOSE, Close)
script:RegisterEvent(EVENT_TICK, Load)

--[[ Protection removed by ensage-forum.ru]]--