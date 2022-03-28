local ROUND_TIME = 150
local RUNE_RESPAWN_TIME = 30
local REVIVE_TIME = 2
local LIVES = 4

local RESULT_DRAW = -1
local RESULT_TEAM_1_WIN = 0
local RESULT_TEAM_2_WIN = 1

local runePool = { FourCC('rspl'), FourCC('rhe2'), FourCC('rman'), FourCC('rspd') }
local reviveQ = {}

Arena2 = {
    initialized = false,
    result = RESULT_DRAW,
    team1lives = 0,
    team2lives = 0,
    Rect = nil,
    Team1Spawn = nil,
    Team2Spawn = nil,
    Name = "Arena 2",
    Tooltip = "Team deathmatch!\nEvery team have "..LIVES.." lives.\nReduce the number of lives of opponent team to zero to win",
}

function Arena2:tick()
    self.time = self.time - TIMER_TICK
    if self.time <= 0 then
        Arena:finish(self.result)
    end
        
    local rune = self.rune
    if not rune.item then
        rune.time = rune.time + TIMER_TICK
        if rune.time >= RUNE_RESPAWN_TIME then
            local n = GetRandomInt(1, #runePool)
            rune.item = CreateItem(runePool[n], GetRectCenterX(rune.rect), GetRectCenterY(rune.rect))
            rune.time = 0
        end
    end
    self.rune = rune
        
    for key, value in pairs(reviveQ) do
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

            table.remove(reviveQ, key)
            setReviveTime(player, "")
        end
    end
    
    MultiboardSetTitleText(Multiboard, "Arena 2 - alive: "..
    self.team1lives.." : "..self.team2lives.." - time: "..math.ceil(self.time))
end

function Arena2:init()
    if self.initialized then return end
    self.initialized = true
    self.Rect = CreateRegion()
    RegionAddRect(self.Rect, gg_rct_Arena_2)
    self.Team1Spawn = gg_rct_Arena_2_team_1_spawn
    self.Team2Spawn = gg_rct_Arena_2_team_2_spawn

    self.rune = { time = 0, rect = gg_rct_Arena_2_rune, item = nil }
    self.time = 0
    
    local runeTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(runeTrigger, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    TriggerAddAction(runeTrigger, function()
        local item = GetManipulatedItem()
        if item == self.rune.item then
            RemoveItem(self.rune.item)
            self.rune.item = nil
        end
    end)
end

function Arena2:start()
    self.time = ROUND_TIME
    self.team1lives = LIVES
    self.team2lives = LIVES
    MultiboardSetTitleText(Multiboard, "Arena 2 - alive: "..
    self.team1lives.." : "..self.team2lives.." - time: "..math.ceil(self.time))
end

function Arena2:finish()
    local rune = self.rune
    if rune.item then
        RemoveItem(rune.item)
        rune.item = nil
    end
    rune.time = 0
end

function Arena2:death(unit)
    local player = GetOwningPlayer(unit)
    DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 5, GetUnitName(unit).." died")
    local team = GetPlayerTeam(player)
    if team == 0 then
        self.team1lives = self.team1lives - 1
        if self.team1lives > 0 then
            table.insert(reviveQ, { unit, REVIVE_TIME })
            DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 5, GetUnitName(unit).." will revive in "..REVIVE_TIME.." sec")
            setReviveTime(player, REVIVE_TIME)
        end
    elseif team == 1 then
        self.team2lives = self.team2lives - 1
        if self.team2lives > 0 then
            table.insert(reviveQ, { unit, REVIVE_TIME })
            DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 5, GetUnitName(unit).." will revive in "..REVIVE_TIME.." sec")
            setReviveTime(player, REVIVE_TIME)
        end
    end

    if self.team1lives == 0 then
        Arena:finish(RESULT_TEAM_2_WIN)
    elseif self.team2lives == 0 then
        Arena:finish(RESULT_TEAM_1_WIN)
    end

    if self.team1lives > self.team2lives then
        self.result = RESULT_TEAM_1_WIN
    elseif self.team1lives < self.team2lives then
        self.result = RESULT_TEAM_2_WIN
    elseif self.team1lives == self.team2lives then
        self.result = RESULT_DRAW
    end

    MultiboardSetTitleText(Multiboard, "Arena 2 - lives: "..
    self.team1lives.." : "..self.team2lives.." - time: "..math.ceil(self.time))
end