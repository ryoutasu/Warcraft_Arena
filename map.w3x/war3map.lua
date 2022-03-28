gg_rct_Arena_1 = nil
gg_rct_Arena_1_capture_point = nil
gg_rct_Arena_1_rune_1 = nil
gg_rct_Arena_1_rune_2 = nil
gg_rct_Arena_1_team_1_spawn = nil
gg_rct_Arena_1_team_2_spawn = nil
gg_rct_Arena_2 = nil
gg_rct_Arena_2_rune = nil
gg_rct_Arena_2_team_1_spawn = nil
gg_rct_Arena_2_team_2_spawn = nil
gg_rct_Arena_3_1 = nil
gg_rct_Arena_3_2 = nil
gg_rct_Arena_3_3 = nil
gg_rct_Arena_3_cart_spawn = nil
gg_rct_Arena_3_cart_way_1 = nil
gg_rct_Arena_3_cart_way_2 = nil
gg_rct_Arena_3_cart_way_3 = nil
gg_rct_Arena_3_cart_way_4 = nil
gg_rct_Arena_3_rune_1 = nil
gg_rct_Arena_3_rune_2 = nil
gg_rct_Arena_3_team_1_spawn = nil
gg_rct_Arena_3_team_2_spawn = nil
gg_rct_Team_1_base = nil
gg_rct_Team_2_base = nil
gg_trg_Untitled_Trigger_001 = nil
function InitGlobals()
end

function CreateNeutralPassive()
    local p = Player(PLAYER_NEUTRAL_PASSIVE)
    local u
    local unitID
    local t
    local life
    u = BlzCreateUnitWithSkin(p, FourCC("targ"), -4608.3, 506.5, 307.561, FourCC("targ"))
    u = BlzCreateUnitWithSkin(p, FourCC("targ"), -2560.9, 502.1, 48.616, FourCC("targ"))
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
end

function CreateAllUnits()
    CreatePlayerBuildings()
    CreateNeutralPassive()
    CreatePlayerUnits()
end

function CreateRegions()
    local we
    gg_rct_Arena_1 = Rect(-5376.0, -5248.0, -1280.0, -1408.0)
    gg_rct_Arena_1_capture_point = Rect(-3744.0, -3744.0, -2912.0, -2912.0)
    gg_rct_Arena_1_rune_1 = Rect(-5056.0, -2496.0, -4928.0, -2368.0)
    gg_rct_Arena_1_rune_2 = Rect(-1728.0, -4288.0, -1600.0, -4160.0)
    gg_rct_Arena_1_team_1_spawn = Rect(-5120.0, -5120.0, -4608.0, -4608.0)
    gg_rct_Arena_1_team_2_spawn = Rect(-2048.0, -2048.0, -1536.0, -1536.0)
    gg_rct_Arena_2 = Rect(-768.0, -5376.0, 2816.0, -1792.0)
    gg_rct_Arena_2_rune = Rect(928.0, -3680.0, 1120.0, -3488.0)
    gg_rct_Arena_2_team_1_spawn = Rect(2048.0, -5120.0, 2560.0, -4608.0)
    gg_rct_Arena_2_team_2_spawn = Rect(-512.0, -2560.0, 0.0, -2048.0)
    gg_rct_Arena_3_1 = Rect(-1280.0, -768.0, 1920.0, 1280.0)
    gg_rct_Arena_3_2 = Rect(1920.0, -2176.0, 5376.0, 1280.0)
    gg_rct_Arena_3_3 = Rect(3328.0, -5376.0, 5376.0, -2176.0)
    gg_rct_Arena_3_cart_spawn = Rect(3232.0, -864.0, 3328.0, -768.0)
    gg_rct_Arena_3_cart_way_1 = Rect(224.0, 480.0, 320.0, 576.0)
    gg_rct_Arena_3_cart_way_2 = Rect(1888.0, 480.0, 1984.0, 576.0)
    gg_rct_Arena_3_cart_way_3 = Rect(4576.0, -2208.0, 4672.0, -2112.0)
    gg_rct_Arena_3_cart_way_4 = Rect(4576.0, -3872.0, 4672.0, -3776.0)
    gg_rct_Arena_3_rune_1 = Rect(1216.0, -448.0, 1344.0, -320.0)
    gg_rct_Arena_3_rune_2 = Rect(3648.0, -2880.0, 3776.0, -2752.0)
    gg_rct_Arena_3_team_1_spawn = Rect(-1152.0, -640.0, -576.0, -64.0)
    gg_rct_Arena_3_team_2_spawn = Rect(3456.0, -5248.0, 4032.0, -4672.0)
    gg_rct_Team_1_base = Rect(-5248.0, -128.0, -3968.0, 1152.0)
    gg_rct_Team_2_base = Rect(-2688.0, -640.0, -1408.0, 640.0)
end

function Trig_Untitled_Trigger_001_Actions()
end

function InitTrig_Untitled_Trigger_001()
    gg_trg_Untitled_Trigger_001 = CreateTrigger()
    TriggerRegisterPlayerChatEvent(gg_trg_Untitled_Trigger_001, Player(0), "arena", false)
    TriggerAddAction(gg_trg_Untitled_Trigger_001, Trig_Untitled_Trigger_001_Actions)
end

function InitCustomTriggers()
    InitTrig_Untitled_Trigger_001()
end

function InitCustomPlayerSlots()
    SetPlayerStartLocation(Player(0), 0)
    ForcePlayerStartLocation(Player(0), 0)
    SetPlayerColor(Player(0), ConvertPlayerColor(0))
    SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    SetPlayerRaceSelectable(Player(0), false)
    SetPlayerController(Player(0), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(1), 1)
    ForcePlayerStartLocation(Player(1), 1)
    SetPlayerColor(Player(1), ConvertPlayerColor(1))
    SetPlayerRacePreference(Player(1), RACE_PREF_ORC)
    SetPlayerRaceSelectable(Player(1), false)
    SetPlayerController(Player(1), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(2), 2)
    ForcePlayerStartLocation(Player(2), 2)
    SetPlayerColor(Player(2), ConvertPlayerColor(2))
    SetPlayerRacePreference(Player(2), RACE_PREF_UNDEAD)
    SetPlayerRaceSelectable(Player(2), false)
    SetPlayerController(Player(2), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(3), 3)
    ForcePlayerStartLocation(Player(3), 3)
    SetPlayerColor(Player(3), ConvertPlayerColor(3))
    SetPlayerRacePreference(Player(3), RACE_PREF_NIGHTELF)
    SetPlayerRaceSelectable(Player(3), false)
    SetPlayerController(Player(3), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(4), 4)
    ForcePlayerStartLocation(Player(4), 4)
    SetPlayerColor(Player(4), ConvertPlayerColor(4))
    SetPlayerRacePreference(Player(4), RACE_PREF_HUMAN)
    SetPlayerRaceSelectable(Player(4), false)
    SetPlayerController(Player(4), MAP_CONTROL_USER)
    SetPlayerStartLocation(Player(5), 5)
    ForcePlayerStartLocation(Player(5), 5)
    SetPlayerColor(Player(5), ConvertPlayerColor(5))
    SetPlayerRacePreference(Player(5), RACE_PREF_ORC)
    SetPlayerRaceSelectable(Player(5), false)
    SetPlayerController(Player(5), MAP_CONTROL_USER)
end

function InitCustomTeams()
    SetPlayerTeam(Player(0), 0)
    SetPlayerState(Player(0), PLAYER_STATE_ALLIED_VICTORY, 1)
    SetPlayerTeam(Player(1), 0)
    SetPlayerState(Player(1), PLAYER_STATE_ALLIED_VICTORY, 1)
    SetPlayerTeam(Player(2), 0)
    SetPlayerState(Player(2), PLAYER_STATE_ALLIED_VICTORY, 1)
    SetPlayerAllianceStateAllyBJ(Player(0), Player(1), true)
    SetPlayerAllianceStateAllyBJ(Player(0), Player(2), true)
    SetPlayerAllianceStateAllyBJ(Player(1), Player(0), true)
    SetPlayerAllianceStateAllyBJ(Player(1), Player(2), true)
    SetPlayerAllianceStateAllyBJ(Player(2), Player(0), true)
    SetPlayerAllianceStateAllyBJ(Player(2), Player(1), true)
    SetPlayerAllianceStateVisionBJ(Player(0), Player(1), true)
    SetPlayerAllianceStateVisionBJ(Player(0), Player(2), true)
    SetPlayerAllianceStateVisionBJ(Player(1), Player(0), true)
    SetPlayerAllianceStateVisionBJ(Player(1), Player(2), true)
    SetPlayerAllianceStateVisionBJ(Player(2), Player(0), true)
    SetPlayerAllianceStateVisionBJ(Player(2), Player(1), true)
    SetPlayerTeam(Player(3), 1)
    SetPlayerState(Player(3), PLAYER_STATE_ALLIED_VICTORY, 1)
    SetPlayerTeam(Player(4), 1)
    SetPlayerState(Player(4), PLAYER_STATE_ALLIED_VICTORY, 1)
    SetPlayerTeam(Player(5), 1)
    SetPlayerState(Player(5), PLAYER_STATE_ALLIED_VICTORY, 1)
    SetPlayerAllianceStateAllyBJ(Player(3), Player(4), true)
    SetPlayerAllianceStateAllyBJ(Player(3), Player(5), true)
    SetPlayerAllianceStateAllyBJ(Player(4), Player(3), true)
    SetPlayerAllianceStateAllyBJ(Player(4), Player(5), true)
    SetPlayerAllianceStateAllyBJ(Player(5), Player(3), true)
    SetPlayerAllianceStateAllyBJ(Player(5), Player(4), true)
    SetPlayerAllianceStateVisionBJ(Player(3), Player(4), true)
    SetPlayerAllianceStateVisionBJ(Player(3), Player(5), true)
    SetPlayerAllianceStateVisionBJ(Player(4), Player(3), true)
    SetPlayerAllianceStateVisionBJ(Player(4), Player(5), true)
    SetPlayerAllianceStateVisionBJ(Player(5), Player(3), true)
    SetPlayerAllianceStateVisionBJ(Player(5), Player(4), true)
end

function InitAllyPriorities()
    SetStartLocPrioCount(0, 2)
    SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(0, 1, 2, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(1, 2)
    SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(1, 1, 2, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(2, 2)
    SetStartLocPrio(2, 0, 0, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(2, 1, 1, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(3, 2)
    SetStartLocPrio(3, 0, 4, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(3, 1, 5, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(4, 2)
    SetStartLocPrio(4, 0, 3, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(4, 1, 5, MAP_LOC_PRIO_HIGH)
    SetStartLocPrioCount(5, 2)
    SetStartLocPrio(5, 0, 3, MAP_LOC_PRIO_HIGH)
    SetStartLocPrio(5, 1, 4, MAP_LOC_PRIO_HIGH)
end

function main()
    SetCameraBounds(-5504.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -5504.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 5504.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 1408.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -5504.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 1408.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 5504.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -5504.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    NewSoundEnvironment("Default")
    SetAmbientDaySound("CityScapeDay")
    SetAmbientNightSound("CityScapeNight")
    SetMapMusic("Music", true, 0)
    CreateRegions()
    CreateAllUnits()
    InitBlizzard()
    InitGlobals()
    InitCustomTriggers()
end

function config()
    SetMapName("TRIGSTR_001")
    SetMapDescription("TRIGSTR_003")
    SetPlayers(6)
    SetTeams(6)
    SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)
    DefineStartLocation(0, -4608.0, 512.0)
    DefineStartLocation(1, -4608.0, 512.0)
    DefineStartLocation(2, -4608.0, 512.0)
    DefineStartLocation(3, -2560.0, 512.0)
    DefineStartLocation(4, -2560.0, 512.0)
    DefineStartLocation(5, -2560.0, 512.0)
    InitCustomPlayerSlots()
    InitCustomTeams()
    InitAllyPriorities()
end

