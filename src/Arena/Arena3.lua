local ROUND_TIME = 300
local RUNE_RESPAWN_TIME = 30
local REVIVE_TIME = 15
local CART_MOVE_PER_TICK = 64 * TIMER_TICK
local CART_ANGLE_PER_TICK = 45 * TIMER_TICK

local RESULT_DRAW = -1
local RESULT_TEAM_1_WIN = 0
local RESULT_TEAM_2_WIN = 1

local GROUP = CreateGroup()
local runePool = { FourCC('rspl'), FourCC('rhe2'), FourCC('rman'), FourCC('rspd') }
local cart = nil
local distance = 0
local distanceText = nil

local function floatingText(text, x, y)
    local tt = CreateTextTag()
    SetTextTagText(tt, text, 0.022)
    SetTextTagPos(tt, x, y, 0.0)
    SetTextTagColor(tt, 255, 250, 250, 255)
    SetTextTagVisibility(tt, true)
    SetTextTagPermanent(tt, true)
    return tt
end

Arena3 = {
    initialized = false,
    result = RESULT_DRAW,
    team1Score = 0,
    team2Score = 0,
    reviveQ = {},
    Rect = nil,
    Team1Spawn = nil,
    Team2Spawn = nil,
    Name = "Arena 3",
    Tooltip = "To win, move cart further from arena center than opponent team",
}

local function moveCart(self, team)
    local x = GetUnitX(cart)
    local y = GetUnitY(cart)
    local facing = GetUnitFacing(cart)

    local tx, ty = 0, 0
    if team == 0 then
        if x >= GetRectCenterX(self.way[3]) then
            if facing > 90 then
                SetUnitFacing(cart, facing - CART_ANGLE_PER_TICK)
                return
            end
            tx, ty = GetRectCenterX(self.way[4]), GetRectCenterY(self.way[4])
        elseif x >= GetRectCenterX(self.way[2]) then
            if facing > 135 then
                SetUnitFacing(cart, facing - CART_ANGLE_PER_TICK)
                return
            end
            tx, ty = GetRectCenterX(self.way[3]), GetRectCenterY(self.way[3])
        elseif x < GetRectCenterX(self.way[2]) then
            tx, ty = GetRectCenterX(self.way[2]), GetRectCenterY(self.way[2])
        end

        if y <= GetRectCenterY(self.cartSpawn) then
            distance = distance + CART_MOVE_PER_TICK
            if distance > self.team1Score then self.team1Score = distance end
        else
            distance = distance - CART_MOVE_PER_TICK
        end
    elseif team == 1 then
        if y >= GetRectCenterY(self.way[2]) then
            if facing < 180 then
                SetUnitFacing(cart, facing + CART_ANGLE_PER_TICK)
                return
            end
            tx, ty = GetRectCenterX(self.way[1]), GetRectCenterY(self.way[1])
        elseif y >= GetRectCenterY(self.way[3]) then
            if facing < 135 then
                SetUnitFacing(cart, facing + CART_ANGLE_PER_TICK)
                return
            end
            tx, ty = GetRectCenterX(self.way[2]), GetRectCenterY(self.way[2])
        elseif y < GetRectCenterY(self.way[3]) then
            tx, ty = GetRectCenterX(self.way[3]), GetRectCenterY(self.way[3])
        end

        if x >= GetRectCenterX(self.cartSpawn) then
            distance = distance + CART_MOVE_PER_TICK
            if distance > self.team2Score then self.team2Score = distance end
        else
            distance = distance - CART_MOVE_PER_TICK
        end
    end
    
    local angle = math.atan(ty - y, tx - x)
    SetUnitX(cart, MoveX(x, CART_MOVE_PER_TICK, angle))
    SetUnitY(cart, MoveY(y, CART_MOVE_PER_TICK, angle))
    SetTextTagText(distanceText, math.ceil(distance), 0.024)
    SetTextTagPosUnit(distanceText, cart, 20)

    BlzFrameSetText(self.scoreFrame1, math.ceil(self.team1Score))
    BlzFrameSetText(self.scoreFrame2, math.ceil(self.team2Score))

    if y <= GetRectCenterY(self.way[4]) then
        Arena:finish(RESULT_TEAM_1_WIN)
    elseif x <= GetRectCenterX(self.way[1]) then
        Arena:finish(RESULT_TEAM_2_WIN)
    end
end

function Arena3:tick()
    self.time = self.time - TIMER_TICK
    if self.time <= 0 then
        if self.team1Score == self.team2Score then
            self.result = RESULT_DRAW
        elseif self.team1Score > self.team2Score then
            self.result = RESULT_TEAM_1_WIN
        elseif self.team1Score < self.team2Score then
            self.result = RESULT_TEAM_2_WIN
        end
        Arena:finish(self.result)
    end

    GroupEnumUnitsInRange(GROUP, GetWidgetX(cart), GetWidgetY(cart), 500)
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
        moveCart(self, 0)
    elseif team2 > 0 and team1 == 0 then
        moveCart(self, 1)
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

    MultiboardSetTitleText(Multiboard, "Arena 3 - time: "..math.ceil(self.time))
end


function Arena3:init()
    if self.initialized then return end
    self.initialized = true
    self.Rect = CreateRegion()
    RegionAddRect(self.Rect, gg_rct_Arena_3_1)
    RegionAddRect(self.Rect, gg_rct_Arena_3_2)
    RegionAddRect(self.Rect, gg_rct_Arena_3_3)
    self.Team1Spawn = gg_rct_Arena_3_team_1_spawn
    self.Team2Spawn = gg_rct_Arena_3_team_2_spawn
    self.cartSpawn = gg_rct_Arena_3_cart_spawn
    self.way = { gg_rct_Arena_3_cart_way_1, gg_rct_Arena_3_cart_way_2,
                 gg_rct_Arena_3_cart_way_3, gg_rct_Arena_3_cart_way_4, }

    self.rune = {
        [1] = { time = 0, rect = gg_rct_Arena_3_rune_1, item = nil },
        [2] = { time = 0, rect = gg_rct_Arena_3_rune_2, item = nil },
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
    BlzFrameSetText(self.scoreFrame1, self.team1Score)
    BlzFrameSetText(self.scoreFrame2, self.team2Score)
end

function Arena3:start()
    cart = CreateUnit(Player(6), FourCC('cart'), GetRectCenterX(self.cartSpawn), GetRectCenterY(self.cartSpawn), 135)
    self.time = ROUND_TIME
    self.team1Score = 0
    self.team2Score = 0
    BlzFrameSetText(self.scoreFrame1, self.team1Score)
    BlzFrameSetText(self.scoreFrame2, self.team2Score)
    distance = 0
    distanceText = floatingText(distance, GetWidgetX(cart), GetWidgetY(cart))
    SetTextTagPosUnit(distanceText, cart, 20)
    BlzFrameSetVisible(self.score1, true)
    BlzFrameSetVisible(self.score2, true)
    MultiboardSetTitleText(Multiboard, "Arena 3 - time: "..math.ceil(self.time))
end

function Arena3:finish()
    BlzFrameSetVisible(self.score1, false)
    BlzFrameSetVisible(self.score2, false)

    RemoveUnit(cart)
    DestroyTextTag(distanceText)

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

function Arena3:death(unit)
    local player = GetOwningPlayer(unit)
    local time = REVIVE_TIME
    table.insert(self.reviveQ, { unit, time })
    DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 5, GetUnitName(unit).." will revive in "..REVIVE_TIME.." sec")
    setReviveTime(player, time)
end