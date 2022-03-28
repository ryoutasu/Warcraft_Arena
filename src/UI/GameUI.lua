local function PXTODPI()
    return 0.6 / BlzGetLocalClientHeight()
end

local function DPITOPX()
    return BlzGetLocalClientHeight() / 0.6
end

local function FrameBoundWidth()
    return (BlzGetLocalClientWidth()-BlzGetLocalClientHeight()/600*800)/2
end

local function GetScreenPosX(x)
    return (-FrameBoundWidth()+x)*PXTODPI()
end

local function GetScreenPosY(y)
    return y*PXTODPI()
end

local function ScreenRelativeX(x)
    return (x * DPITOPX()) * (0.8/BlzGetLocalClientWidth())
end

BlzLoadTOCFile("UI\\Frame\\Frames.toc")
do
    local ScreenWidth = BlzGetLocalClientWidth()
    local ScreenHeight = BlzGetLocalClientHeight()
    -- local BoundScreenWidth = ScreenWidth - FrameBoundWidth() * 2

    -- local deltaw = (ScreenHeight/ScreenWidth)/(600/800)
    local CPx = 0.38
    local CPy = 0
    local CPframepoint = FRAMEPOINT_BOTTOM
    
    local TopBackdropSize = 0.0425
    local TopButtonSize = 0.0355
    local TopButtonOffsetX = -0.0025
    local BottomBackdropSize = (5*TopBackdropSize)/7
    local BottomButtonSize = (TopButtonSize / TopBackdropSize) * BottomBackdropSize
    local BottomButtonOffsetX = (4*TopButtonOffsetX) /6
    local TopToBottomButtonsOffset = -0.0025
    
    local CPBorderSize = 0.005
    
    -- Inventory
    local InventoryBackdropSize = 0.035
    local InventoryButtonSize = 0.0255
    local InventoryButtonOffset = -0.002
    local InventoryBorderSize = 0.002
    
    -- Portrait
    local PortraitWidth = 0.120
    local PortratHeigth = 0.10
    local PortraitBorder = 0.006
    
    -- InfoFrames
    local InfoFrameBackdropWidth = 0.065
    local InfoFrameBackdropHeight = 0.09
    local InfoFrameBackdropOffsetX = -0.0062
    local InfoFrameBackdropOffsetY = -0.001
    local InfoFrameBackdropBorderSize = 0.009
    local InfoFrameIconSize = 0.015
    local InfoFrameIconOffsetZ = 0.005
    local InfoFrameAttributeIconOffsetZ = 0.0132
    local InfoFrameTextOffsetX = 0.003
    
    local TIMER_INTERVAL = 0.03125
    
    GameUI = {}
    GameUI.Frames = {}
    GameUI.ButtonsBackdrop = {}
    GameUI.Buttons = {}
    GameUI.InventoryButtonsBackdrop = {}
    GameUI.InventoryButtons = {}

    function showTopMessage(text)
        local topMsg = BlzGetOriginFrame(ORIGIN_FRAME_TOP_MSG, 0)
        BlzFrameAddText(topMsg, "text")
    end
    
    function GameUI.hideOriginUI()
        GAME_UI     = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        WORLD_FRAME = BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0)
        CONSOLE_UI  = BlzGetFrameByName("ConsoleUI", 0)
        
        BlzEnableUIAutoPosition(false)
        BlzFrameClearAllPoints(WORLD_FRAME)
        BlzFrameClearAllPoints(CONSOLE_UI)
        
        BlzFrameSetAllPoints(WORLD_FRAME, GAME_UI)
        BlzFrameSetAbsPoint(CONSOLE_UI, FRAMEPOINT_TOPRIGHT, -999.0, -999.0)
    end
    
    function GameUI.create()
        -- Command Panel
        local commandPanel = BlzCreateFrame("EscMenuPopupMenuTemplate", WORLD_FRAME, 0, 0)
        local commandPanelBackdrop = BlzCreateFrame("Steel-Backdrop", commandPanel, 0, 0)
        local width = (CPBorderSize * 2) + (TopBackdropSize * 5) + (TopButtonOffsetX * 4)
        local height = (CPBorderSize * 2) + TopBackdropSize + BottomBackdropSize + TopToBottomButtonsOffset - 0.002
        BlzFrameSetSize(commandPanel, width, height)
        BlzFrameSetAbsPoint(commandPanel, CPframepoint, CPx, CPy)
        BlzFrameSetAllPoints(commandPanelBackdrop, commandPanel)
        
        -- Top buttons positionate
        for i = 0, 4, 1 do
            local backdrop = BlzCreateFrame("Button-Backdrop", commandPanel, 0, i)
            local button   = BlzGetFrameByName("CommandButton_"..i, 0)

            BlzFrameSetSize(backdrop, TopBackdropSize, TopBackdropSize)
            BlzFrameSetSize(button, TopButtonSize, TopButtonSize)
            if i == 0 then
                BlzFrameSetPoint(backdrop, FRAMEPOINT_TOPLEFT, commandPanel, FRAMEPOINT_TOPLEFT, CPBorderSize, -CPBorderSize)
            else
                BlzFrameSetPoint(backdrop, FRAMEPOINT_TOPLEFT, GameUI.ButtonsBackdrop[i-1], FRAMEPOINT_TOPRIGHT, TopButtonOffsetX, 0)
            end
            BlzFrameClearAllPoints(button)
            BlzFrameSetPoint(button, FRAMEPOINT_CENTER, backdrop, FRAMEPOINT_CENTER, 0, 0)

            GameUI.ButtonsBackdrop[i] = backdrop
            GameUI.Buttons[i] = button
        end

        -- Bottom buttons positionate
        for i = 5, 11, 1 do
            local backdrop = BlzCreateFrame("Button-Backdrop", commandPanel, 0, i)
            local button   = BlzGetFrameByName("CommandButton_"..i, 0)

            BlzFrameSetSize(backdrop, BottomBackdropSize, BottomBackdropSize)
            BlzFrameSetSize(button, BottomButtonSize, BottomButtonSize)
            if i == 5 then
                BlzFrameSetPoint(backdrop, FRAMEPOINT_TOPLEFT, GameUI.ButtonsBackdrop[0], FRAMEPOINT_BOTTOMLEFT, 0, -TopToBottomButtonsOffset)
            else
                BlzFrameSetPoint(backdrop, FRAMEPOINT_TOPLEFT, GameUI.ButtonsBackdrop[i-1], FRAMEPOINT_TOPRIGHT, BottomButtonOffsetX, 0)
            end
            BlzFrameClearAllPoints(button)
            BlzFrameSetPoint(button, FRAMEPOINT_CENTER, backdrop, FRAMEPOINT_CENTER, 0, 0)

            GameUI.ButtonsBackdrop[i] = backdrop
            GameUI.Buttons[i] = button
        end

        for i = 0, 5, 1 do
            local backdrop = BlzCreateFrame('Item-Backdrop', WORLD_FRAME, 0, i)
            local button = BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, i)

            BlzFrameSetSize(backdrop, InventoryBackdropSize, InventoryBackdropSize)
            BlzFrameSetSize(button, InventoryButtonSize, InventoryButtonSize)
            if i == 0 then
                BlzFrameSetPoint(backdrop, FRAMEPOINT_BOTTOMLEFT, commandPanelBackdrop, FRAMEPOINT_RIGHT, InventoryBorderSize, -InventoryBorderSize)
            elseif i < 3 then
                BlzFrameSetPoint(backdrop, FRAMEPOINT_TOPLEFT, GameUI.InventoryButtonsBackdrop[i-1], FRAMEPOINT_TOPRIGHT, InventoryButtonOffset, 0)
            else
                BlzFrameSetPoint(backdrop, FRAMEPOINT_TOPLEFT, GameUI.InventoryButtonsBackdrop[i-3], FRAMEPOINT_BOTTOMLEFT, 0, -InventoryButtonOffset)
            end
            BlzFrameClearAllPoints(button)
            BlzFrameSetPoint(button, FRAMEPOINT_CENTER, backdrop, FRAMEPOINT_CENTER, 0, 0)

            GameUI.InventoryButtonsBackdrop[i] = backdrop
            GameUI.InventoryButtons[i] = button
        end

        local inventoryText = BlzGetFrameByName("InventoryText", 0)
        BlzFrameClearAllPoints(inventoryText)
        BlzFrameSetPoint(inventoryText, FRAMEPOINT_BOTTOM, GameUI.InventoryButtonsBackdrop[1], FRAMEPOINT_TOP, 0, 0)

        -- Portrait, XP Bar and Name
        local portraitPanel = BlzCreateFrame("EscMenuPopupMenuTemplate", WORLD_FRAME, 0, 0)
        local portraitBackdrop = BlzCreateFrame("Steel-Backdrop", portraitPanel, 0, 0)
        BlzFrameSetSize(portraitPanel, PortraitWidth, PortratHeigth)
        BlzFrameSetAbsPoint(portraitPanel, FRAMEPOINT_BOTTOMLEFT, GetScreenPosX(FrameBoundWidth()), 0)
        BlzFrameSetAllPoints(portraitBackdrop, portraitPanel)

        width = PortraitWidth - (PortraitBorder + PortraitBorder)
        height = PortratHeigth - (PortraitBorder + PortraitBorder)

        local levelBar = BlzGetFrameByName('SimpleHeroLevelBar', 0)
        -- BlzFrameSetSize(levelBar, width, BlzFrameGetHeight(levelBar))
        BlzFrameClearAllPoints(levelBar)
        -- BlzFrameSetPoint(levelBar, FRAMEPOINT_BOTTOM, portraitPanel, FRAMEPOINT_BOTTOM, 0, PortraitBorder)

        local progressIndicator = BlzGetFrameByName('SimpleProgressIndicator', 0)
        BlzFrameSetSize(progressIndicator, width, BlzFrameGetHeight(progressIndicator))
        BlzFrameClearAllPoints(progressIndicator)
        BlzFrameSetPoint(progressIndicator, FRAMEPOINT_BOTTOM, portraitPanel, FRAMEPOINT_BOTTOM, 0, PortraitBorder)
        
        -- Name value
        local nameValue = BlzGetFrameByName('SimpleNameValue', 0)
        BlzFrameSetSize(nameValue, width, BlzFrameGetHeight(nameValue))
        BlzFrameClearAllPoints(nameValue)
        BlzFrameSetPoint(nameValue, FRAMEPOINT_BOTTOM, portraitPanel, FRAMEPOINT_TOP, 0, 0)

        local buildingNameValue = BlzGetFrameByName('SimpleBuildingNameValue', 1)
        BlzFrameSetSize(buildingNameValue, width, BlzFrameGetHeight(buildingNameValue))
        BlzFrameClearAllPoints(buildingNameValue)
        BlzFrameSetPoint(buildingNameValue, FRAMEPOINT_BOTTOM, portraitPanel, FRAMEPOINT_TOP, 0, 0)

        local holdNameValue = BlzGetFrameByName('SimpleHoldNameValue', 2)
        BlzFrameSetSize(holdNameValue, width, BlzFrameGetHeight(holdNameValue))
        BlzFrameClearAllPoints(holdNameValue)
        BlzFrameSetPoint(holdNameValue, FRAMEPOINT_BOTTOM, portraitPanel, FRAMEPOINT_TOP, 0, 0)

        local itemNameValue = BlzGetFrameByName('SimpleItemNameValue', 3)
        BlzFrameSetSize(itemNameValue, width, BlzFrameGetHeight(itemNameValue))
        BlzFrameClearAllPoints(itemNameValue)
        BlzFrameSetPoint(itemNameValue, FRAMEPOINT_BOTTOM, portraitPanel, FRAMEPOINT_TOP, 0, 0)

        local destructableNameValue = BlzGetFrameByName('SimpleDestructableNameValue', 4)
        BlzFrameSetSize(destructableNameValue, width, BlzFrameGetHeight(destructableNameValue))
        BlzFrameClearAllPoints(destructableNameValue)
        BlzFrameSetPoint(destructableNameValue, FRAMEPOINT_BOTTOM, portraitPanel, FRAMEPOINT_TOP, 0, 0)
        -- Name value end

        local classValue = BlzGetFrameByName('SimpleClassValue', 0)
        BlzFrameSetSize(classValue, width, BlzFrameGetHeight(classValue))
        BlzFrameClearAllPoints(classValue)
        BlzFrameSetPoint(classValue, FRAMEPOINT_CENTER, progressIndicator, FRAMEPOINT_CENTER, 0, 0)

        local portrait = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT, 0)
        BlzFrameSetSize(portrait, ScreenRelativeX(width), height)
        BlzFrameSetVisible(portrait, true)
        BlzFrameClearAllPoints(portrait)
        --BlzFrameSetPoint(portrait, FRAMEPOINT_CENTER, portraitBackdrop, FRAMEPOINT_CENTER, 0.0545, 0)
        local x = FrameBoundWidth()*(0.8/ScreenWidth) + ScreenRelativeX(PortraitWidth) / 2
        BlzFrameSetAbsPoint(portrait, FRAMEPOINT_CENTER, x, PortratHeigth/2)

        local buffBar = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR, 0)
        local buffBarLabel = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR_LABEL, 0)
        BlzFrameSetSize(buffBar, width, BlzFrameGetHeight(buffBar))
        BlzFrameSetVisible(buffBar, true)
        BlzFrameClearAllPoints(buffBar)
        BlzFrameClearAllPoints(buffBarLabel)
        BlzFrameSetPoint(buffBar, FRAMEPOINT_BOTTOMLEFT, progressIndicator, FRAMEPOINT_TOPLEFT, 0, 0)
        --BlzFrameSetPoint(buffBar, FRAMEPOINT_BOTTOMRIGHT, levelBar, FRAMEPOINT_TOPRIGHT, 0, 0)
        
        -- Info
        local infoPanel = BlzCreateFrame("EscMenuPopupMenuTemplate", WORLD_FRAME, 0, 0)
        local infoPanelBackdrop = BlzCreateFrame('Info-Backdrop', infoPanel, 0, 0)
        BlzFrameSetSize(infoPanel, InfoFrameBackdropWidth, InfoFrameBackdropHeight)
        BlzFrameSetPoint(infoPanel, FRAMEPOINT_LEFT, portraitPanel, FRAMEPOINT_RIGHT, InfoFrameBackdropOffsetX, InfoFrameBackdropOffsetY)
        BlzFrameSetAllPoints(infoPanelBackdrop, infoPanel)

        local iconAttack = BlzGetFrameByName('InfoPanelIconBackdrop', 0)
        BlzFrameClearAllPoints(iconAttack)
        BlzFrameSetSize(iconAttack, InfoFrameIconSize, InfoFrameIconSize)
        BlzFrameSetPoint(iconAttack, FRAMEPOINT_TOPLEFT, infoPanel, FRAMEPOINT_TOPLEFT, InfoFrameBackdropBorderSize, -InfoFrameBackdropBorderSize)

        local iconArmor = BlzGetFrameByName('InfoPanelIconBackdrop', 2)
        BlzFrameClearAllPoints(iconArmor)
        BlzFrameSetSize(iconArmor, InfoFrameIconSize, InfoFrameIconSize)
        BlzFrameSetPoint(iconArmor, FRAMEPOINT_TOPLEFT, iconAttack, FRAMEPOINT_BOTTOMLEFT, 0, -InfoFrameIconOffsetZ)

        local iconAttr = BlzGetFrameByName('InfoPanelIconHeroIcon', 6)
        BlzFrameClearAllPoints(iconAttr)
        BlzFrameSetSize(iconAttr, InfoFrameIconSize, InfoFrameIconSize)
        BlzFrameSetPoint(iconAttr, FRAMEPOINT_TOPLEFT, iconArmor, FRAMEPOINT_BOTTOMLEFT, 0, -InfoFrameAttributeIconOffsetZ)

        width = InfoFrameBackdropWidth - InfoFrameBackdropBorderSize - InfoFrameBackdropBorderSize - InfoFrameIconSize - InfoFrameTextOffsetX
        local infoFrames = { { '', 0 }, { '', 2 }, { 'HeroStrength', 6 }, { 'HeroAgility', 6 }, { 'HeroIntellect', 6 } }
        local infoFrame  = {}
        for i = 1, #infoFrames do
            infoFrame[i] = BlzGetFrameByName('InfoPanelIcon' .. infoFrames[i][1] .. 'Value', infoFrames[i][2])
            BlzFrameClearAllPoints(infoFrame[i])
            BlzFrameSetSize(infoFrame[i], width, InfoFrameIconSize)
            BlzFrameSetTextAlignment(infoFrame[i], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
            BlzFrameSetText(BlzGetFrameByName('InfoPanelIcon' .. infoFrames[i][1] .. 'Label', infoFrames[i][2]), "")
        end

        BlzFrameSetPoint(infoFrame[1], FRAMEPOINT_LEFT, iconAttack, FRAMEPOINT_RIGHT, InfoFrameTextOffsetX, 0)
        BlzFrameSetPoint(infoFrame[2], FRAMEPOINT_LEFT, iconArmor, FRAMEPOINT_RIGHT, InfoFrameTextOffsetX, 0)
        BlzFrameSetPoint(infoFrame[3], FRAMEPOINT_LEFT, iconAttr, FRAMEPOINT_TOPRIGHT, InfoFrameTextOffsetX, 0.0042)
        BlzFrameSetPoint(infoFrame[4], FRAMEPOINT_LEFT, iconAttr, FRAMEPOINT_RIGHT, InfoFrameTextOffsetX, 0)
        BlzFrameSetPoint(infoFrame[5], FRAMEPOINT_LEFT, iconAttr, FRAMEPOINT_BOTTOMRIGHT, InfoFrameTextOffsetX, -0.0042)

        -- Health and mana bars
        -- local healthBar = BlzGetOriginFrame(ORIGIN_FRAME_HERO_HP_BAR, 0)
        -- local manaBar = BlzGetOriginFrame(ORIGIN_FRAME_HERO_MANA_BAR, 0)
		-- BlzFrameClearAllPoints(healthBar)
		-- BlzFrameClearAllPoints(manaBar)
        -- BlzFrameSetSize(healthBar, 0.1, 0.02)
        -- BlzFrameSetSize(manaBar, 0.1, 0.02)
        -- BlzFrameSetPoint(healthBar, FRAMEPOINT_BOTTOMRIGHT, commandPanelBackdrop, FRAMEPOINT_TOP, -0.001, 0)
        -- BlzFrameSetPoint(manaBar, FRAMEPOINT_BOTTOMLEFT, commandPanelBackdrop, FRAMEPOINT_TOP, 0.001, 0)
        GameUI.HealthBar = {}
        GameUI.ManaBar = {}
        GameUI.SelectedUnit = {}
        for i = 0, bj_MAX_PLAYERS - 1 do
            local healthBar = BlzCreateSimpleFrame("SimpleBarEx", WORLD_FRAME, i)
            local manaBar = BlzCreateSimpleFrame("SimpleBarEx", WORLD_FRAME, i+bj_MAX_PLAYER_SLOTS)
            BlzFrameSetPoint(healthBar, FRAMEPOINT_BOTTOMRIGHT, commandPanelBackdrop, FRAMEPOINT_TOP, -0.001, 0)
            BlzFrameSetPoint(manaBar, FRAMEPOINT_BOTTOMLEFT, commandPanelBackdrop, FRAMEPOINT_TOP, 0.001, 0)
            BlzFrameSetTexture(healthBar, "Replaceabletextures\\Teamcolor\\Teamcolor12.blp", 0, true)
            BlzFrameSetTexture(manaBar, "Replaceabletextures\\Teamcolor\\Teamcolor13.blp", 0, true)
            BlzFrameSetText(BlzGetFrameByName("SimpleBarExText", i), "")
            BlzFrameSetText(BlzGetFrameByName("SimpleBarExText", i+bj_MAX_PLAYER_SLOTS), "")
            BlzFrameSetValue(healthBar, 0)
            BlzFrameSetValue(manaBar, 0)
            BlzFrameSetVisible(healthBar, false)
            BlzFrameSetVisible(manaBar, false)
            if GetLocalPlayer() == Player(i) then
                BlzFrameSetVisible(healthBar, true)
                BlzFrameSetVisible(manaBar, true)
            end
            local t = CreateTrigger()
            TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_UNIT_SELECTED, nil)
            TriggerAddAction(t, function()
                local selectedUnit = GetTriggerUnit()
                local h = R2I(GetUnitState(selectedUnit, UNIT_STATE_LIFE))
                local mh = BlzGetUnitMaxHP(selectedUnit)
                local m = R2I(GetUnitState(selectedUnit, UNIT_STATE_MANA))
                local mm = BlzGetUnitMaxMana(selectedUnit)

                BlzFrameSetValue(healthBar, GetUnitLifePercent(selectedUnit))
                BlzFrameSetValue(manaBar, GetUnitManaPercent(selectedUnit))
                BlzFrameSetText(BlzGetFrameByName("SimpleBarExText", i), h.."/"..mh)
                BlzFrameSetText(BlzGetFrameByName("SimpleBarExText", i+bj_MAX_PLAYER_SLOTS), m.."/"..mm)

                GameUI.SelectedUnit[i] = selectedUnit
            end)

            GameUI.HealthBar[i] = healthBar
            GameUI.ManaBar[i] = manaBar
            GameUI.SelectedUnit[i] = nil
        end

        TimerStart(CreateTimer(), TIMER_INTERVAL, true, function()
            for i = 0, bj_MAX_PLAYERS - 1 do
                if GameUI.SelectedUnit[i] then
                    local unit = GameUI.SelectedUnit[i]
                    local h = R2I(GetUnitState(unit, UNIT_STATE_LIFE))
                    local mh = BlzGetUnitMaxHP(unit)
                    local m = R2I(GetUnitState(unit, UNIT_STATE_MANA))
                    local mm = BlzGetUnitMaxMana(unit)

                    BlzFrameSetValue(GameUI.HealthBar[i], GetUnitLifePercent(unit))
                    BlzFrameSetValue(GameUI.ManaBar[i], GetUnitManaPercent(unit))
                    BlzFrameSetText(BlzGetFrameByName("SimpleBarExText", i), h.."/"..mh)
                    BlzFrameSetText(BlzGetFrameByName("SimpleBarExText", i+bj_MAX_PLAYER_SLOTS), m.."/"..mm)
                end
            end

            if (ScreenWidth ~= BlzGetLocalClientWidth()) or (ScreenHeight ~= BlzGetLocalClientHeight()) then
                ScreenWidth = BlzGetLocalClientWidth()
                ScreenHeight = BlzGetLocalClientHeight()
                
                local w = PortraitWidth - (PortraitBorder + PortraitBorder)
                local h = PortratHeigth - (PortraitBorder + PortraitBorder)

                local xx = FrameBoundWidth()*(0.8/ScreenWidth) + ScreenRelativeX(PortraitWidth) / 2
                BlzFrameSetAbsPoint(portrait, FRAMEPOINT_CENTER, xx, PortratHeigth/2)
                BlzFrameSetSize(portrait, ScreenRelativeX(w), h)
            end
        end)

        -- Mimimap
        local minimap = BlzGetFrameByName("MiniMapFrame", 0)
        BlzFrameSetVisible(minimap, true)
        BlzFrameClearAllPoints(minimap)
        BlzFrameSetParent(BlzGetFrameByName("MiniMapFrame", 0), BlzGetFrameByName("ConsoleUIBackdrop", 0))
        BlzFrameSetAbsPoint(minimap, FRAMEPOINT_BOTTOMRIGHT, -999, -999)

        -- Chat
        local chat = BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0)
        BlzFrameSetVisible(chat, true)
        BlzFrameClearAllPoints(chat)
        BlzFrameSetSize(chat, 0.8, 0.40)
        BlzFrameSetAbsPoint(chat, FRAMEPOINT_TOPLEFT, GetScreenPosX(10), 0.6)

        -- Unit Msg
        local unitMsg = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG, 0)
        BlzFrameSetVisible(unitMsg, true)
        BlzFrameClearAllPoints(unitMsg)
        BlzFrameSetAbsPoint(unitMsg, FRAMEPOINT_BOTTOMLEFT, 0.06, 0.2)

        -- Top Msg
        local topMsg = BlzGetOriginFrame(ORIGIN_FRAME_TOP_MSG, 0)
        BlzFrameSetVisible(topMsg, true)
        BlzFrameClearAllPoints(topMsg)
        BlzFrameSetAbsPoint(topMsg, FRAMEPOINT_TOP, 0.4, 0.56)

        local mapCheckBox = BlzCreateFrame("QuestCheckBox", GAME_UI, 0, 0)
        local mapLabel = BlzCreateFrame("EscMenuLabelTextTemplate",  mapCheckBox, 0, 0)
        local mapWidth = BlzFrameGetWidth(minimap)
        BlzFrameSetAbsPoint(mapCheckBox, FRAMEPOINT_BOTTOMLEFT, 0.8-mapWidth, 0)
        BlzFrameSetPoint(mapLabel, FRAMEPOINT_LEFT, mapCheckBox, FRAMEPOINT_RIGHT, 5*PXTODPI(), 0)
        BlzFrameSetText(mapLabel, "Show map")

        local checkMapTrigger = CreateTrigger()
        BlzTriggerRegisterFrameEvent(checkMapTrigger, mapCheckBox, FRAMEEVENT_CHECKBOX_CHECKED)
        BlzTriggerRegisterFrameEvent(checkMapTrigger, mapCheckBox, FRAMEEVENT_CHECKBOX_UNCHECKED)
        TriggerAddAction(checkMapTrigger, function()
            if GetLocalPlayer() == GetTriggerPlayer() then
                local enable = BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED
                if enable then
                    BlzFrameSetAbsPoint(minimap, FRAMEPOINT_BOTTOMRIGHT, 0.8, 0)
                    BlzFrameSetText(mapLabel, "Hide map")
                else
                    BlzFrameSetAbsPoint(minimap, FRAMEPOINT_BOTTOMRIGHT, -999, -999)
                    BlzFrameSetText(mapLabel, "Show map")
                end
            end
        end)

        BlzFrameSetVisible(commandPanelBackdrop, true)
        GameUI.CommandPanel = commandPanelBackdrop
        GameUI.InventoryText = inventoryText
        GameUI.PortraitBackdrop = portraitBackdrop
        GameUI.Portrait = portrait
        -- GameUI.LevelBar = levelBar
        GameUI.ClassValue = classValue
        GameUI.NameValue = { [0] = nameValue, [1] = buildingNameValue, [2] = holdNameValue, [3] = itemNameValue, [4] = destructableNameValue}
        GameUI.ProgressIndicator = progressIndicator
        GameUI.InfoPanel = infoPanel
        GameUI.InfoIcon = { [0] = iconAttack, [2] = iconArmor, [6] = iconAttr }
        GameUI.InfoValue = { [0] = infoFrame[1], [2] = infoFrame[2], [6] = { Strength = infoFrame[3], Agility = infoFrame[4], Intellect =  infoFrame[5]}}
        GameUI.Minimap = minimap
        GameUI.BuffBar = buffBar
        GameUI.BuffBarLabel = buffBarLabel
    end
end