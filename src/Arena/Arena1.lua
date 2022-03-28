local ROUND_TIME = 180
local RUNE_RESPAWN_TIME = 30
local REVIVE_TIME = 10
local PERCENT_PER_TICK = 2 * TIMER_TICK

local RESULT_DRAW = -1
local RESULT_TEAM_1_WIN = 0
local RESULT_TEAM_2_WIN = 1

local GROUP = CreateGroup()
local runePool = { FourCC('rspl'), FourCC('rhe2'), FourCC('rman'), FourCC('rspd') }

Arena1 = {
    initialized = false,
    result = RESULT_DRAW,
    team1Percent = 0,
    team2Percent = 0,
    reviveQ = {},
    capturePoint = nil,
    Rect = nil,
    Team1Spawn = nil,
    Team2Spawn = nil,
    Name = "Arena 1",
    Tooltip = "To win, capture point in center of arena",
}



function Arena1:tick()
    self.time = self.time - TIMER_TICK
    if self.time <= 0 then
        if self.team1Percent == self.team2Percent then
            self.result = RESULT_DRAW
        elseif self.team1Percent > self.team2Percent then
            self.result = RESULT_TEAM_1_WIN
        elseif self.team1Percent < self.team2Percent then
            self.result = RESULT_TEAM_2_WIN
        end
        Arena:finish(self.result)
    end

    GroupEnumUnitsInRect(GROUP, self.capturePoint)
    local team1 = 0
    local team2 = 0
    for i = BlzGroupGetSize(GROUP) - 1, 0, -1 do
        local unit = BlzGroupUnitAt(GROUP, i)
        local player = GetOwningPlayer(unit)
        if IsUnitType(unit, UNIT_TYPE_HERO)
        and IsUnitAliveBJ(unit) then
            if GetPlayerTeam(player) == 0 then
                team1 = team1 + 1
            else
                team2 = team2 + 1
            end
        end
    end
    GroupClear(GROUP)
    
    if team1 > 0 and team2 == 0 then
        self.team1Percent = self.team1Percent + PERCENT_PER_TICK
    elseif team2 > 0 and team1 == 0 then
        self.team2Percent = self.team2Percent + PERCENT_PER_TICK
    end
    BlzFrameSetText(self.scoreFrame1, R2I(self.team1Percent))
    BlzFrameSetText(self.scoreFrame2, R2I(self.team2Percent))

    if self.team1Percent >= 100 then
        self.result = RESULT_TEAM_1_WIN
        Arena:finish(self.result)
    elseif self.team2Percent >= 100 then
        self.result = RESULT_TEAM_2_WIN
        Arena:finish(self.result)
    end
    
    for key, value in pairs(self.reviveQ) do
        local unit = value[1]
        local time = value[2] - TIMER_TICK
        local player = GetOwningPlayer(unit)
        setReviveTime(player, math.floor(time))
        value[2] = time
        if time <= 0 then
            local rect = Players[player].ReviveRect
            local x = GetRandomReal(GetRectMinX(rect), GetRectMaxX(rect))
            local y = GetRandomReal(GetRectMinY(rect), GetRectMaxY(rect))
            ReviveHero(unit, x, y, true)
            SetUnitState(unit, UNIT_STATE_LIFE, GetUnitState(unit, UNIT_STATE_MAX_LIFE))
            SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MAX_MANA))
            SelectUnitForPlayerSingle(unit, player)

            table.remove(self.reviveQ, key)
            setReviveTime(player, "")
        end
    end

    for key, value in pairs(self.rune) do
        if not value.rune then
            value.time = value.time + TIMER_TICK
            if value.time >= RUNE_RESPAWN_TIME then
                local n = GetRandomInt(1, #runePool)
                value.rune = CreateItem(runePool[n], GetRectCenterX(value.rect), GetRectCenterY(value.rect))
                value.time = 0
            end
        end
    end

    MultiboardSetTitleText(Multiboard, "Arena 1 - time: "..math.ceil(self.time))
end


function Arena1:init()
    if self.initialized then return end
    self.initialized = true
    self.Rect = CreateRegion()
    RegionAddRect(self.Rect, gg_rct_Arena_1)
    self.Team1Spawn = gg_rct_Arena_1_team_1_spawn
    self.Team2Spawn = gg_rct_Arena_1_team_2_spawn
    self.capturePoint = gg_rct_Arena_1_capture_point

    self.rune = {
        [1] = { time = 0, rect = gg_rct_Arena_1_rune_1, item = nil },
        [2] = { time = 0, rect = gg_rct_Arena_1_rune_2, item = nil },
    }
    self.time = 0

    local tg = CreateTrigger()
    TriggerRegisterEnterRectSimple(tg, self.Team1Spawn)
    TriggerAddAction(tg, function()
        local unit = GetTriggerUnit()
        local player = GetOwningPlayer(unit)
        if GetPlayerTeam(player) == 0 then
            UnitAddAbility(unit, FourCC('Avul'))
        end
    end)
    tg = CreateTrigger()
    TriggerRegisterLeaveRectSimple(tg, self.Team1Spawn)
    TriggerAddAction(tg, function()
        local unit = GetTriggerUnit()
        local player = GetOwningPlayer(unit)
        if GetPlayerTeam(player) == 0 then
            UnitRemoveAbility(unit, FourCC('Avul'))
        end
    end)

    tg = CreateTrigger()
    TriggerRegisterEnterRectSimple(tg, self.Team2Spawn)
    TriggerAddAction(tg, function()
        local unit = GetTriggerUnit()
        local player = GetOwningPlayer(unit)
        if GetPlayerTeam(player) == 1 then
            UnitAddAbility(unit, FourCC('Avul'))
        end
    end)
    tg = CreateTrigger()
    TriggerRegisterLeaveRectSimple(tg, self.Team2Spawn)
    TriggerAddAction(tg, function()
        local unit = GetTriggerUnit()
        local player = GetOwningPlayer(unit)
        if GetPlayerTeam(player) == 1 then
            UnitRemoveAbility(unit, FourCC('Avul'))
        end
    end)

    local runeTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(runeTrigger, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    TriggerAddAction(runeTrigger, function()
        local item = GetManipulatedItem()
        if item == self.rune[1].item then
            RemoveItem(self.rune[1].item)
            self.rune[1].item = nil
        elseif item == self.rune[2].item then
            RemoveItem(self.rune[2].item)
            self.rune[2].item = nil
        end
    end)

    local game_ui       = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
    self.score1         = BlzCreateFrame("TimerDialog", game_ui, 0, 0)
    self.score2         = BlzCreateFrame("TimerDialog", game_ui, 0, 1)
    local title1        = BlzGetFrameByName("TimerDialogTitle", 0)
    local title2        = BlzGetFrameByName("TimerDialogTitle", 1)
    self.scoreFrame1    = BlzGetFrameByName("TimerDialogValue", 0)
    self.scoreFrame2    = BlzGetFrameByName("TimerDialogValue", 1)
    
    BlzFrameSetSize(self.score1, 0.1, 0.023)
    BlzFrameSetSize(self.score2, 0.1, 0.023)
    BlzFrameSetText(title1, "|cff0000ffTeam 1|r")
    BlzFrameSetText(title2, "|cffff0000Team 2|r")
    BlzFrameSetAbsPoint(self.score1, FRAMEPOINT_RIGHT, 0.36, 0.56)
    BlzFrameSetAbsPoint(self.score2, FRAMEPOINT_LEFT, 0.44, 0.56)
    BlzFrameSetText(self.scoreFrame1, self.team1Percent)
    BlzFrameSetText(self.scoreFrame2, self.team2Percent)
end

function Arena1:start()
    self.time = ROUND_TIME
    self.team1Percent = 0
    self.team2Percent = 0
    BlzFrameSetVisible(self.score1, true)
    BlzFrameSetVisible(self.score2, true)
    MultiboardSetTitleText(Multiboard, "Arena 1 - time: "..math.ceil(self.time))
end

function Arena1:finish()
    BlzFrameSetVisible(self.score1, false)
    BlzFrameSetVisible(self.score2, false)

    for key, value in pairs(self.reviveQ) do
        table.remove(self.reviveQ, key)
    end
    for key, value in pairs(self.rune) do
        if value.rune then
            RemoveItem(value.rune)
            value.rune = nil
        end
        value.time = 0
    end
end

function Arena1:death(unit)
    local player = GetOwningPlayer(unit)
    local time = REVIVE_TIME
    table.insert(self.reviveQ, { unit, time })
    DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 5, GetUnitName(unit).." will revive in "..REVIVE_TIME.." sec")
    setReviveTime(player, time)
end