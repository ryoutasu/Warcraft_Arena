require('Arena.Arena1')
require('Arena.Arena2')
require('Arena.Arena3')

Arena = {}
Arena.started = false

local arenaPool = { Arena1, Arena2, Arena3 }
local currentPool = deepcopy(arenaPool)

local GROUP = CreateGroup()

function Arena:setArena(num)
    self.current = arenaPool[num]
    return self.current
end

function Arena:roll()
    if #currentPool < 1 then currentPool = deepcopy(arenaPool) end
    local n = math.random(#currentPool)
    self.current = table.remove(currentPool, n)
    return self.current
end

function Arena:start()
    self.started = true
    SetTimeOfDay(6)
    self.current:init()
    for key, player in pairs(PlayerIndex) do
        local hero = Players[player].Hero
        local rect = nil
        if GetPlayerTeam(player) == 0 then
            rect = self.current.Team1Spawn
        else
            rect = self.current.Team2Spawn
        end

        local x = GetRandomReal(GetRectMinX(rect), GetRectMaxX(rect))
        local y = GetRandomReal(GetRectMinY(rect), GetRectMaxY(rect))
        if IsUnitAliveBJ(hero) then
            SetUnitX(hero, x)
            SetUnitY(hero, y)
        else
            ReviveHero(hero, x, y, false)
        end
        SetUnitState(hero, UNIT_STATE_LIFE, GetUnitState(hero, UNIT_STATE_MAX_LIFE))
        SetUnitState(hero, UNIT_STATE_MANA, GetUnitState(hero, UNIT_STATE_MAX_MANA))
        UnitResetCooldown(hero)
        if GetLocalPlayer() == player then
            ClearSelection()
            SelectUnit(hero, true)
            PanCameraToTimed(x, y, 0)
        end
        
        Players[player].ReviveRect = rect
    end
    Ability.RainOfFire.reset() --for now

    self.current:start()
end

function Arena:finish(winner)
    self.started = false
    for key, player in pairs(PlayerIndex) do
        local hero = Players[player].Hero
        local rect = nil
        if GetPlayerTeam(player) == 0 then
            rect = gg_rct_Team_1_base
        else
            rect = gg_rct_Team_2_base
        end

        local x = GetRandomReal(GetRectMinX(rect), GetRectMaxX(rect))
        local y = GetRandomReal(GetRectMinY(rect), GetRectMaxY(rect))
        if IsUnitAliveBJ(hero) then
            SetUnitX(hero, x)
            SetUnitY(hero, y)
        else
            ReviveHero(hero, x, y, true)
        end
        setReviveTime(player, "")
        SetUnitState(hero, UNIT_STATE_LIFE, GetUnitState(hero, UNIT_STATE_MAX_LIFE))
        SetUnitState(hero, UNIT_STATE_MANA, GetUnitState(hero, UNIT_STATE_MAX_MANA))
        UnitResetCooldown(hero)
        if GetLocalPlayer() == player then
            ClearSelection()
            SelectUnit(hero, true)
            PanCameraToTimed(x, y, 0)
        end
        
        if winner == -1 then
            SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, (PLAYER_STATE_RESOURCE_GOLD)) + 300)
        elseif winner == GetPlayerTeam(player) then
            SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, (PLAYER_STATE_RESOURCE_GOLD)) + 350)
        else
            SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, (PLAYER_STATE_RESOURCE_GOLD)) + 250)
        end
        SetHeroLevel(hero, GetHeroLevel(hero)+1, true)
        Players[player].ReviveRect = rect
    end
    Ability.RainOfFire.reset() --for now

    if winner == -1 then
        DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 10, "Draw!")
    elseif winner == 0 then
        addTeamWin(winner)
        DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 10, "Team 1 win!")
    elseif winner == 1 then
        addTeamWin(winner)
        DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 10, "Team 2 win!")
    end

    GroupEnumUnitsInRect(GROUP, GetPlayableMapRect())
    for i = BlzGroupGetSize(GROUP) - 1, 0, -1 do
        local unit = BlzGroupUnitAt(GROUP, i)
        if IsUnitInRegion(self.current.Rect, unit) then
            RemoveUnit(unit)
        end
    end
    GroupClear(GROUP)
    self.current:finish()
    Game:startPrepapre()
end