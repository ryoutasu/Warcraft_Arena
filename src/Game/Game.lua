Game = {}

Players = {}
Team = {}
PlayerIndex = {}

TIMER_TICK = 0.03125 -- 1/32 of second
-- TIMER_TICK = 0.015625 -- 1/64 of second
PICK_TIME = 30
PREPARE_TIME = 30

local PHASE_PICK    = 1
local PHASE_PREPARE = 2
local PHASE_ARENA   = 3

local time = 0
local phase = 0

local function debugCommands()
    local endTrigger = CreateTrigger()
    TriggerRegisterPlayerChatEvent(endTrigger, Player(0), "-end", true)
    TriggerAddAction(endTrigger, function()
        if phase == PHASE_PICK then
            Game:endPick()
        elseif phase == PHASE_PREPARE then
            Game:endPrepare()
        elseif phase == PHASE_ARENA then
            Arena:finish(-1)
        end
    end)

    local killTrigger = CreateTrigger()
    TriggerRegisterPlayerChatEvent(killTrigger, Player(0), "-kill", true)
    TriggerAddAction(killTrigger, function()
        KillUnit(Players[Player(0)].Hero)
    end)

    local arenaTrigger = CreateTrigger()
    TriggerRegisterPlayerChatEvent(arenaTrigger, Player(0), "-arena", false)
    TriggerAddAction(arenaTrigger, function()
        local msg = GetEventPlayerChatString():sub(7, 8)
        DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, math.min(15, PREPARE_TIME), 'Arena switched to Arena '..msg)
        Game:startPrepapre(20, tonumber(msg))
    end)
end

local function death()
    local rect = Arena.current.Rect
    local unit = GetTriggerUnit()
    local killer = GetKillingUnit()
    local playerD = GetOwningPlayer(unit)
    local playerK = GetOwningPlayer(killer)
    local x = GetUnitX(unit)
    local y = GetUnitY(unit)
    if unit == Players[playerD].Hero then
        if IsUnitInRegion(rect, unit) then
            Arena.current:death(unit)
            addPlayerDeath(playerD)
            addPlayerKill(playerK)
        else
            DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 5, "How stupid "..GetPlayerName(playerD)..", if he dies out of arena?")
            rect = Player[playerD].ReviveRect
            x = GetRandomReal(GetRectMinX(rect), GetRectMaxX(rect))
            y = GetRandomReal(GetRectMinY(rect), GetRectMaxY(rect))
            ReviveHero(unit, x, y, false)
            SelectUnitForPlayerSingle(unit, playerD)
        end
    end
end

local function leave()
    local player = GetTriggerPlayer()
    local index = Players[player].Index
    RemoveUnit(Players[player].Hero)
    Players[player].Hero = nil
    table.remove(PlayerIndex, index)
    Players[player] = nil
    DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 10,"Player "..GetPlayerName(player).." has left the game")
end

local function tick()
    time = time - TIMER_TICK
    if phase == PHASE_PICK then
        MultiboardSetTitleText(Multiboard, "Pick time - "..math.ceil(time))
        if time <= 0 then
            Game:endPick()
        end
    elseif phase == PHASE_PREPARE then
        MultiboardSetTitleText(Multiboard, "Next arena - "..Arena.current.Name.." - "..math.ceil(time))
        if time <= 0 then
            Game:endPrepare()
        end
    elseif phase == PHASE_ARENA then
        Arena.current:tick()
    end
end

function Game:startPick()
    time = PICK_TIME
    phase = PHASE_PICK
    
    HeroPicker.start()
end

function Game:endPick()
    for key, player in pairs(PlayerIndex) do
        if not Players[player].Hero then
            HeroPicker.doRandom(player)
        end
    end
    HeroPicker.destroy()
    Game:startPrepapre()
end

function Game:startPrepapre(ptime, arena)
    time = ptime or PREPARE_TIME
    phase = PHASE_PREPARE
    Shop.enable(true)
    if not arena then
        Arena:roll()
    else
        Arena:setArena(arena)
    end
    DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, math.min(15, PREPARE_TIME),
    "Next arena - "..Arena.current.Name.."\n"..
    Arena.current.Tooltip.."\n"..PREPARE_TIME.." seconds to fight.")
end

function Game:endPrepare()
    phase = PHASE_ARENA
    Shop.enable(false)
    Arena:start()
end

function Game:start()
    FogMaskEnable(false)
    FogEnable(false)

    -- EnableSelect(true, false)
    -- EnablePreSelect(false, true)
    EnableDragSelect(false, false)

    GameUI.create()

    local reviveTrigger = CreateTrigger()
    local leaveTrigger = CreateTrigger()
    TriggerAddAction(reviveTrigger, death)
    TriggerAddAction(leaveTrigger, leave)

    Team[0] = { Kills = 0, Deaths = 0, Wins = 0, Players = {}, Row = 0 }
    Team[1] = { Kills = 0, Deaths = 0, Wins = 0, Players = {}, Row = 0 }
    for i = 0, 5, 1 do
        local player = Player(i)
        local team = GetPlayerTeam(player)
        local rect = nil
        if GetPlayerSlotState(player) == PLAYER_SLOT_STATE_PLAYING then
            -- print("Player "..i.." in game")
            if GetPlayerTeam(player) == 0 then
                rect = gg_rct_Team_1_base
            else
                rect = gg_rct_Team_2_base
            end
            table.insert(PlayerIndex, player)
            table.insert(Team[team].Players, player)
            Players[player] = { Index = #PlayerIndex, Hero = nil, Kills = 0, Deaths = 0, Row = 0, ReviveRect = rect }
            
            SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, 300)
            TriggerRegisterPlayerUnitEvent(reviveTrigger, player, EVENT_PLAYER_UNIT_DEATH)
            TriggerRegisterPlayerEvent(leaveTrigger, player, EVENT_PLAYER_LEAVE)
        end
    end
    
    createMultiboard()
    debugCommands()
    initProjectiles()
    InitAllAbilities()
    
    self.timer = CreateTimer()
    TimerStart(self.timer, TIMER_TICK, true, tick)
    Shop:create()
    Game:startPick()
end
