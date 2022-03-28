Multiboard = nil

--player_Color is Copied from TriggerHappy
player_color = {
    "ff0303",
    "0042ff",
    "1ce6b9",
    "540081",
    "fffc01",
    "fe8a0e",
    "20c000",
    "e55bb0",
    "959697",
    "7ebff1",
    "106246",
    "4e2a04",
    "9B0000",
    "0000C3",
    "00EAFF",
    "BE00FE",
    "EBCD87",
    "F8A48B",
    "BFFF80",
    "DCB9EB",
    "282828",
    "EBF0FF",
    "00781E",
    "A46F33"
}

local created = false
local nameWidth = 0.1
local reviveWidth = 0.02
local winWidth = 0.040
local KDWidth = 0.028
local winPrefix = "|cffffcc00"
local killPrefix = "|cffA46F33"
local deathPrefix = "|cff00781E"

function createMultiboard()
    if created then return end
    created = true
    local rows = #PlayerIndex + 3
    local mb = CreateMultiboard()
    MultiboardSetItemsStyle(mb, true, false)
    MultiboardSetTitleText(mb, "Multiboard")
    MultiboardSetRowCount(mb, rows)
    MultiboardSetColumnCount(mb, 5)
    
    -- Row 1
    local row = 0
    local mbi = MultiboardGetItem(mb, row, 0)
    MultiboardSetItemWidth(mbi, nameWidth)
    MultiboardSetItemValue(mbi, "")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 1)
    MultiboardSetItemWidth(mbi, reviveWidth)
    MultiboardSetItemValue(mbi, "")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 2)
    MultiboardSetItemWidth(mbi, winWidth)
    MultiboardSetItemValue(mbi, winPrefix.."Wins|r")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 3)
    MultiboardSetItemWidth(mbi, KDWidth)
    MultiboardSetItemValue(mbi, killPrefix.."Kill|r")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 4)
    MultiboardSetItemWidth(mbi, 0.036)
    MultiboardSetItemValue(mbi, deathPrefix.."Death|r")
    MultiboardReleaseItem(mbi)
    
    -- Row 2, Team 1
    row = row + 1
    Team[0].Row = row
    mbi = MultiboardGetItem(mb, row, 0)
    MultiboardSetItemWidth(mbi, nameWidth)
    MultiboardSetItemValue(mbi, "Team 1")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 1)
    MultiboardSetItemWidth(mbi, reviveWidth)
    MultiboardSetItemValue(mbi, "")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 2)
    MultiboardSetItemWidth(mbi, winWidth)
    MultiboardSetItemValue(mbi, winPrefix.."0|r")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 3)
    MultiboardSetItemWidth(mbi, KDWidth)
    MultiboardSetItemValue(mbi, killPrefix.."0|r")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 4)
    MultiboardSetItemWidth(mbi, KDWidth)
    MultiboardSetItemValue(mbi, deathPrefix.."0|r")
    MultiboardReleaseItem(mbi)
    
    -- Team 1 players
    local i = 0
    for key, player in pairs(Team[0].Players) do
        i = i + 1
        row = row + 1
        Players[player].Row = row
        mbi = MultiboardGetItem(mb, row, 0)
        MultiboardSetItemWidth(mbi, nameWidth)
        MultiboardSetItemStyle(mbi, true, true)
        MultiboardSetItemValue(mbi, "|cff"..player_color[GetConvertedPlayerId(player)]..GetPlayerName(player).."|r")
        MultiboardReleaseItem(mbi)
        mbi = MultiboardGetItem(mb, row, 1)
        MultiboardSetItemWidth(mbi, reviveWidth)
        MultiboardSetItemValue(mbi, "")
        MultiboardReleaseItem(mbi)
        mbi = MultiboardGetItem(mb, row, 2)
        MultiboardSetItemWidth(mbi, winWidth)
        MultiboardSetItemValue(mbi, "")
        MultiboardReleaseItem(mbi)
        mbi = MultiboardGetItem(mb, row, 3)
        MultiboardSetItemWidth(mbi, KDWidth)
        MultiboardSetItemValue(mbi, killPrefix.."0|r")
        MultiboardReleaseItem(mbi)
        mbi = MultiboardGetItem(mb, row, 4)
        MultiboardSetItemWidth(mbi, KDWidth)
        MultiboardSetItemValue(mbi, deathPrefix.."0|r")
        MultiboardReleaseItem(mbi)
    end
    
    -- Row N, Team 2
    row = row + 1
    Team[1].Row = row
    mbi = MultiboardGetItem(mb, row, 0)
    MultiboardSetItemWidth(mbi, nameWidth)
    MultiboardSetItemValue(mbi, "Team 2")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 1)
    MultiboardSetItemWidth(mbi, reviveWidth)
    MultiboardSetItemValue(mbi, "")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 2)
    MultiboardSetItemWidth(mbi, winWidth)
    MultiboardSetItemValue(mbi, winPrefix.."0|r")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 3)
    MultiboardSetItemWidth(mbi, KDWidth)
    MultiboardSetItemValue(mbi, killPrefix.."0|r")
    MultiboardReleaseItem(mbi)
    mbi = MultiboardGetItem(mb, row, 4)
    MultiboardSetItemWidth(mbi, KDWidth)
    MultiboardSetItemValue(mbi, deathPrefix.."0|r")
    MultiboardReleaseItem(mbi)
    
    -- Team 2 players
    for key, player in pairs(Team[1].Players) do
        i = i + 1
        row = row + 1
        Players[player].Row = row
        mbi = MultiboardGetItem(mb, row, 0)
        MultiboardSetItemWidth(mbi, nameWidth)
        MultiboardSetItemStyle(mbi, true, true)
        MultiboardSetItemValue(mbi, "|cff"..player_color[GetConvertedPlayerId(player)]..GetPlayerName(player).."|r")
        MultiboardReleaseItem(mbi)
        mbi = MultiboardGetItem(mb, row, 1)
        MultiboardSetItemWidth(mbi, reviveWidth)
        MultiboardSetItemValue(mbi, "")
        MultiboardReleaseItem(mbi)
        mbi = MultiboardGetItem(mb, row, 2)
        MultiboardSetItemWidth(mbi, winWidth)
        MultiboardSetItemValue(mbi, "")
        MultiboardReleaseItem(mbi)
        mbi = MultiboardGetItem(mb, row, 3)
        MultiboardSetItemWidth(mbi, KDWidth)
        MultiboardSetItemValue(mbi, killPrefix.."0|r")
        MultiboardReleaseItem(mbi)
        mbi = MultiboardGetItem(mb, row, 4)
        MultiboardSetItemWidth(mbi, KDWidth)
        MultiboardSetItemValue(mbi, deathPrefix.."0|r")
        MultiboardReleaseItem(mbi)
    end
    
    MultiboardDisplay(mb, true)
    MultiboardMinimize(mb, true)
    Multiboard = mb
end

function setPlayerIcon(player)
    local row = Players[player].Row
    local icon = BlzGetAbilityIcon(GetUnitTypeId(Players[player].Hero))
    local mbi = MultiboardGetItem(Multiboard, row, 0)
    MultiboardSetItemIcon(mbi, icon)
    MultiboardReleaseItem(mbi)
end

function addPlayerKill(player)
    local team = GetPlayerTeam(player)
    local row = Players[player].Row
    local kills = Players[player].Kills + 1
    local mbi = MultiboardGetItem(Multiboard, row, 3)
    MultiboardSetItemValue(mbi, killPrefix..kills.."|r")
    MultiboardReleaseItem(mbi)
    
    row = Team[team].Row
    kills = Team[team].Wins + 1
    mbi = MultiboardGetItem(Multiboard, row, 3)
    MultiboardSetItemValue(mbi, killPrefix..kills.."|r")
    MultiboardReleaseItem(mbi)
    
    Players[player].Kills = kills
    Team[team].Wins = kills
end

function addPlayerDeath(player)
    local team = GetPlayerTeam(player)
    local row = Players[player].Row
    local deaths = Players[player].Deaths + 1
    local mbi = MultiboardGetItem(Multiboard, row, 4)
    MultiboardSetItemValue(mbi, deathPrefix..deaths.."|r")
    MultiboardReleaseItem(mbi)
    
    row = Team[team].Row
    deaths = Team[team].Deaths + 1
    mbi = MultiboardGetItem(Multiboard, row, 4)
    MultiboardSetItemValue(mbi, deathPrefix..deaths.."|r")
    MultiboardReleaseItem(mbi)
    
    Players[player].Deaths = deaths
    Team[team].Deaths = deaths
end

function addTeamWin(team)
    local row = Team[team].Row
    local wins = Team[team].Wins + 1
    local mbi = MultiboardGetItem(Multiboard, row, 2)
    MultiboardSetItemValue(mbi, winPrefix..wins.."|r")
    MultiboardReleaseItem(mbi)
    
    Team[team].Wins = wins
end

function setReviveTime(player, time)
    local row = Players[player].Row
    local mbi = MultiboardGetItem(Multiboard, row, 1)
    MultiboardSetItemValue(mbi, time)
    MultiboardReleaseItem(mbi)
end