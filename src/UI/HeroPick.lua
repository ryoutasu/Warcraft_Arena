BlzLoadTOCFile("resources\\UI\\HeroPick.toc")
local emptyButtonPath = "UI\\Widgets\\EscMenu\\Human\\blank-background.blp"

local heroBoxX = 0.395
local heroBoxY = 0.54
local heroBoxFramepoint = FRAMEPOINT_TOPRIGHT
local descBoxFramepoint = FRAMEPOINT_TOPLEFT
local descBoxWidth = 0.28
local descBoxHeigth = 0.32
local descBoxOffsetX = 0.01
local descBoxOffsetY = 0
local descNameHeight = 0.020
local descNamePrefix = "|cffffcc00"
local descNameSuffix = "|r"
local attrTextHeight = 0.020

local buttonOffsetX = 0.008
local buttonOffsetY = 0.008
local colSize = 5

local borderSize = 0.025
local buttonSize = 0.036

HeroPicker = {}
HeroPicker.Frames = {}
HeroPicker.HeroButtons = {}
HeroPicker.Trigger = {}
HeroPicker.Events = {}

HeroPicker.Heroes = {}
HeroPicker.Heroes.Strength = {}
HeroPicker.Heroes.Agility = {}
HeroPicker.Heroes.Intelligence = {}
HeroPicker.HeroPool = {}
HeroPicker.Description = {}

function HeroPicker.initHeroes()
    HeroPicker.addHero('Hpal', HERO_ATTRIBUTE_STR)
    -- HeroPicker.addHero('Hmkg', HERO_ATTRIBUTE_STR)
    -- HeroPicker.addHero('Otch', HERO_ATTRIBUTE_STR)
    -- HeroPicker.addHero('Udea', HERO_ATTRIBUTE_STR)
    -- HeroPicker.addHero('Udre', HERO_ATTRIBUTE_STR)
    -- HeroPicker.addHero('Ucrl', HERO_ATTRIBUTE_STR)
    -- HeroPicker.addHero('Nalc', HERO_ATTRIBUTE_STR)
    -- HeroPicker.addHero('Npbm', HERO_ATTRIBUTE_STR)
    -- HeroPicker.addHero('Nbst', HERO_ATTRIBUTE_STR)

    HeroPicker.addHero('Hdrn', HERO_ATTRIBUTE_AGI) -- dark ranger
    -- HeroPicker.addHero('Obla', HERO_ATTRIBUTE_AGI)
    -- HeroPicker.addHero('Oshd', HERO_ATTRIBUTE_AGI)
    -- HeroPicker.addHero('Emoo', HERO_ATTRIBUTE_AGI)
    -- HeroPicker.addHero('Edem', HERO_ATTRIBUTE_AGI)
    -- HeroPicker.addHero('Ewar', HERO_ATTRIBUTE_AGI)
    -- HeroPicker.addHero('Nfir', HERO_ATTRIBUTE_AGI)
    
    HeroPicker.addHero('N000', HERO_ATTRIBUTE_INT) -- murloc
    HeroPicker.addHero('Hprs', HERO_ATTRIBUTE_INT) -- priest
    HeroPicker.addHero('Ulic', HERO_ATTRIBUTE_INT) -- lich
    -- HeroPicker.addHero('Hamg', HERO_ATTRIBUTE_INT)
    -- HeroPicker.addHero('Hblm', HERO_ATTRIBUTE_INT)
    -- HeroPicker.addHero('Ofar', HERO_ATTRIBUTE_INT)
    -- HeroPicker.addHero('Ekee', HERO_ATTRIBUTE_INT)
    -- HeroPicker.addHero('Nngs', HERO_ATTRIBUTE_INT)
    -- HeroPicker.addHero('Ntin', HERO_ATTRIBUTE_INT)
end

function HeroPicker.addHero(unitCode, attr)
    if not unitCode or unitCode == 0 then
        table.insert(HeroPicker.Heroes, 0)
    else
        --'Hpal' -> number?
        if type(unitCode) == "string" then
            unitCode = FourCC(unitCode)
        end

        --Such an object Exist?
        if GetObjectName(unitCode) == "" then print(('>I4'):pack(unitCode), "is not an valid Object") return end

        HeroPicker.HeroPool[unitCode] = true
        HeroPicker.Heroes[unitCode] = {Index = 0, Picked = false, Attribute = attr}
        table.insert(HeroPicker.Heroes, unitCode)
        HeroPicker.Heroes[unitCode].Index = #HeroPicker.Heroes   --remember the index for the unitCode
        if attr == HERO_ATTRIBUTE_STR then
            table.insert(HeroPicker.Heroes.Strength, unitCode)
        elseif attr == HERO_ATTRIBUTE_AGI then
            table.insert(HeroPicker.Heroes.Agility, unitCode)
        elseif attr == HERO_ATTRIBUTE_INT then
            table.insert(HeroPicker.Heroes.Intelligence, unitCode)
        end
    end
end

function HeroPicker.rollHero()
    local roll = {}
    for unitCode, value in pairs(HeroPicker.HeroPool) do
        local allow = true
        if HeroPicker.Heroes[unitCode].Picked then
            allow = false
        end

        if allow then
            table.insert(roll, unitCode)
        end
    end
    if #roll == 0 then return nil end
    return roll[GetRandomInt(1, #roll)]
end

function HeroPicker.checkPlayersPick()
    for key, player in pairs(PlayerIndex) do
        if not Players[player].Hero then
            return false
        end
    end
    return true
end

function HeroPicker.doPick(player)
    if not HeroPicker.HeroButtons[player] then return end
    local buttonIndex = HeroPicker.HeroButtons[player]
    if buttonIndex <= 0 then return end
    local unitCode = HeroPicker.Heroes[buttonIndex]
    
    HeroPicker.createUnit(player, unitCode, buttonIndex)
end

function HeroPicker.doRandom(player)
    local unitCode = HeroPicker.rollHero()
    if not unitCode then return end
    local buttonIndex = HeroPicker.Heroes[unitCode].Index

    HeroPicker.createUnit(player, unitCode, buttonIndex)
end

function HeroPicker.createUnit(player, unitCode, buttonIndex, isRandom)
    HeroPicker.Heroes[unitCode].Picked = true
    HeroPicker.disableButtonIndex(buttonIndex)
    HeroPicker.showBox(false, player)

    local x = GetRandomReal(GetRectMinX(Players[player].ReviveRect), GetRectMaxX(Players[player].ReviveRect))
    local y = GetRandomReal(GetRectMinY(Players[player].ReviveRect), GetRectMaxY(Players[player].ReviveRect))
    local unit = CreateUnit(player, unitCode, x, y, 270)
    ModifyHeroSkillPoints(unit, 0, 2)
    SuspendHeroXP(unit, false)
    SetPlayerHandicapXP(player, 0)
    SelectUnitForPlayerSingle(unit, player)

    Players[player].Hero = unit
    if isRandom then
        DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 5,"Player "..GetPlayerName(player).." has randomed "..GetUnitName(unit))
    else
        DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 5,"Player "..GetPlayerName(player).." has picked "..GetUnitName(unit))
    end
    
    -- SetPlayerName(player, GetPlayerName(player).."("..GetUnitName(unit)..")")
    setPlayerIcon(player)

    if HeroPicker.checkPlayersPick() then
        HeroPicker.destroy()
        Game:startPrepapre()
    end
end

function HeroPicker.getDisabledIcon(icon)
    --ReplaceableTextures\CommandButtons\BTNHeroPaladin.tga -> ReplaceableTextures\CommandButtonsDisabled\DISBTNHeroPaladin.tga
    if string.sub(icon,35,35) ~= "\\" then return icon end --this string has not enough chars return it
    --string.len(icon) < 35 then return icon end --this string has not enough chars return it
    local prefix = string.sub(icon, 1, 34)
    local sufix = string.sub(icon, 36)
    return prefix .."Disabled\\DIS"..sufix
end

function HeroPicker.disableButtonIndex(buttonIndex)
    if not buttonIndex then buttonIndex = 0 end
    
    if buttonIndex > 0 then
        BlzFrameSetEnable(HeroPicker.HeroButtons[buttonIndex].Frame, false)
        if HeroPicker.HeroButtons[GetLocalPlayer()] == buttonIndex then
            BlzFrameSetVisible(HeroPicker.SelectIndicator, false)
        end
        
        --deselect this Button from all players or the team
        for index= 0, GetBJMaxPlayers() - 1,1 do
            local player = Player(index)
            if HeroPicker.HeroButtons[player] == buttonIndex then
                HeroPicker.HeroButtons[player] = 0
            end
        end
    end
end

function HeroPicker.frameLoseFocus(frame)
    if BlzFrameGetEnable(frame) then
        BlzFrameSetEnable(frame, false)
        BlzFrameSetEnable(frame, true)
    end
end

function HeroPicker.heroButtonClick()
    local button = BlzGetTriggerFrame()
    local player = GetTriggerPlayer()
    local buttonIndex = HeroPicker.HeroButtons[button]
    local unitCode = HeroPicker.Heroes[buttonIndex]
    HeroPicker.HeroButtons[player] = buttonIndex
    if GetLocalPlayer() == player then
        BlzFrameSetVisible(HeroPicker.SelectIndicator, true)

        BlzFrameSetText(HeroPicker.Description.Name, descNamePrefix..GetObjectName(unitCode)..descNameSuffix)
        BlzFrameSetText(HeroPicker.Description.Tooltip, BlzGetAbilityExtendedTooltip(unitCode,0))
        
        BlzFrameSetPoint(HeroPicker.SelectIndicator, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, -0.001, 0.001)
        BlzFrameSetPoint(HeroPicker.SelectIndicator, FRAMEPOINT_BOTTOMRIGHT, button, FRAMEPOINT_BOTTOMRIGHT, -0.0012, -0.0016)
    end
end

function HeroPicker.acceptButtonClick()
    HeroPicker.frameLoseFocus(BlzGetTriggerFrame())
    HeroPicker.doPick(GetTriggerPlayer())
end

function HeroPicker.randomButtonClick()
    HeroPicker.frameLoseFocus(BlzGetTriggerFrame())
    local player = GetTriggerPlayer()
    HeroPicker.doRandom(player)
end

function HeroPicker.showBox(flag, player)
    if player == GetLocalPlayer() then
        BlzFrameSetVisible(HeroPicker.HeroBox, flag)
        BlzFrameSetVisible(HeroPicker.DescriptionBox, flag)
    end
end

function HeroPicker.destroy()
    for key, value in ipairs(HeroPicker.Frames)
    do
        BlzDestroyFrame(value)
    end
    HeroPicker.Frames = nil
    for key, value in ipairs(HeroPicker.HeroButtons)
    do
        BlzDestroyFrame(value.Tooltip)
        BlzDestroyFrame(value.Icon)
        BlzDestroyFrame(value.IconDisabled)
        BlzDestroyFrame(value.Frame)
    end
    HeroPicker.HeroButtons = nil
    for key, value in ipairs(HeroPicker.Description)
    do
        BlzDestroyFrame(value.Name)
        BlzDestroyFrame(value.Tooltip)
    end
    HeroPicker.Description = nil
    for key, value in ipairs(HeroPicker.Trigger)
    do
        TriggerRemoveAction(value, HeroPicker.Trigger[value])
        DestroyTrigger(value)
    end
    HeroPicker.Trigger = nil
    HeroPicker = nil
end

function HeroPicker.start()
    HeroPicker.initHeroes()

    local heroBox = BlzCreateFrame("EscMenuBackdrop", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
    local strText = BlzCreateFrame("StandardValueTextTemplate", heroBox, 0, 0)
    local agiText = BlzCreateFrame("StandardValueTextTemplate", heroBox, 0, 0)
    local intText = BlzCreateFrame("StandardValueTextTemplate", heroBox, 0, 0)
    local width = (borderSize * 2) + colSize * buttonSize + (colSize - 1) * buttonOffsetX
    local height = (borderSize * 2) + attrTextHeight + attrTextHeight + attrTextHeight
    BlzFrameSetSize(strText, width-borderSize-borderSize, attrTextHeight)
    BlzFrameSetSize(agiText, width-borderSize-borderSize, attrTextHeight)
    BlzFrameSetSize(intText, width-borderSize-borderSize, attrTextHeight)
    BlzFrameSetAbsPoint(heroBox, FRAMEPOINT_TOPRIGHT, heroBoxX, heroBoxY)
    BlzFrameSetText(strText, "|cffe11414Strength|r")
    BlzFrameSetText(agiText, "|cff32dc32Agility|r")
    BlzFrameSetText(intText, "|cff2080ffIntelligence|r")
    BlzFrameSetTextAlignment(strText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
    BlzFrameSetTextAlignment(agiText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
    BlzFrameSetTextAlignment(intText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
    BlzFrameSetVisible(heroBox, false)
    
    local descBox = BlzCreateFrame("EscMenuBackdrop", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
    BlzFrameSetPoint(descBox, descBoxFramepoint, heroBox, heroBoxFramepoint, descBoxOffsetX, descBoxOffsetY)
    BlzFrameSetSize(descBox, descBoxWidth, descBoxHeigth)
    
    HeroPicker.Description.Name = BlzCreateFrame("StandardValueTextTemplate", descBox, 0, 0)
    HeroPicker.Description.Tooltip = BlzCreateFrame("HeroSelectorText", descBox, 0, 0)
    BlzFrameSetSize(HeroPicker.Description.Name , descBoxWidth - (borderSize * 2), descNameHeight)
    BlzFrameSetSize(HeroPicker.Description.Tooltip , descBoxWidth - (borderSize * 2), descBoxHeigth-(borderSize*2)-descNameHeight)
    BlzFrameSetPoint(HeroPicker.Description.Name, FRAMEPOINT_TOP, descBox, FRAMEPOINT_TOP, 0,-borderSize)
    BlzFrameSetPoint(HeroPicker.Description.Tooltip, FRAMEPOINT_TOPLEFT, descBox, FRAMEPOINT_TOPLEFT, borderSize,-borderSize-0.015)
    BlzFrameSetText(HeroPicker.Description.Name, descNamePrefix.."Select hero"..descNameSuffix)
    BlzFrameSetText(HeroPicker.Description.Tooltip, "You have |cffffcc00"..PICK_TIME.."|r seconds to pick, or you get random hero.")
    BlzFrameSetTextAlignment(HeroPicker.Description.Name, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
    
    local onClickTrigger = CreateTrigger()
    HeroPicker.Trigger[onClickTrigger] = TriggerAddAction(onClickTrigger, HeroPicker.heroButtonClick)
    
    HeroPicker.SelectIndicator = BlzCreateFrameByType("SPRITE", "MyHeroIndikator", heroBox, "", 0)
    BlzFrameSetModel(HeroPicker.SelectIndicator, "UI\\Feedback\\Autocast\\UI-ModalButtonOn.mdl", 0)
    BlzFrameSetScale(HeroPicker.SelectIndicator, buttonSize/0.036) --scale the model to the button size.
    BlzFrameSetVisible(HeroPicker.SelectIndicator, false)
    
    local colCount = colSize
    -- Strength heroes
    BlzFrameSetPoint(strText, FRAMEPOINT_TOPLEFT, heroBox, FRAMEPOINT_TOPLEFT, borderSize, -borderSize+0.002)
    local rowRemaining = colSize
    local newSection = true
    local lastRowFirstButton = nil
    local buttonIndex = 0
    for key, unitCode in pairs(HeroPicker.Heroes.Strength) do
        buttonIndex = buttonIndex + 1

        local button = BlzCreateFrame("HeroSelectorButton", heroBox, 0, buttonIndex)
        local icon = BlzGetFrameByName("HeroSelectorButtonIcon", buttonIndex)
        local iconDisabled = BlzGetFrameByName("HeroSelectorButtonIconDisabled", buttonIndex)
        
        local tooltip = BlzCreateFrame("HeroSelectorText", heroBox, 0, buttonIndex)
        BlzFrameSetTooltip(button, tooltip)
        BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOM, button, FRAMEPOINT_TOP, 0,0)
        BlzFrameSetSize(button, buttonSize, buttonSize)
        
        if HeroPicker.Heroes[buttonIndex] and HeroPicker.Heroes[buttonIndex] > 0 then
            BlzFrameSetTexture(icon, BlzGetAbilityIcon(unitCode), 0, true)
            BlzFrameSetTexture(iconDisabled, HeroPicker.getDisabledIcon(BlzGetAbilityIcon(unitCode)), 0, true)
            BlzFrameSetText(tooltip, GetObjectName(unitCode))
        else
            BlzFrameSetEnable(button, false)
            BlzFrameSetTexture(icon, emptyButtonPath, 0, true)
            BlzFrameSetTexture(iconDisabled, emptyButtonPath, 0, true)
        end
        
        local heroButton = {}
        HeroPicker.HeroButtons[buttonIndex] = heroButton
        heroButton.Frame = button
        heroButton.Icon = icon
        heroButton.IconDisabled = iconDisabled
        heroButton.Tooltip = tooltip
        
        HeroPicker.HeroButtons[button] = buttonIndex
        table.insert(HeroPicker.Events, BlzTriggerRegisterFrameEvent(onClickTrigger, button, FRAMEEVENT_CONTROL_CLICK))
        
        if newSection then
            newSection = false
            lastRowFirstButton = button
            BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, strText, FRAMEPOINT_BOTTOMLEFT, 0, 0)
            height = height + buttonSize
        elseif rowRemaining <= 0 then
            lastRowFirstButton = button
            BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, HeroPicker.HeroButtons[buttonIndex - colCount].Frame, FRAMEPOINT_BOTTOMLEFT, 0, -buttonOffsetY)
            rowRemaining = colCount
            height = height + buttonOffsetY + buttonSize
        else
            BlzFrameSetPoint(button, FRAMEPOINT_LEFT, HeroPicker.HeroButtons[buttonIndex - 1].Frame, FRAMEPOINT_RIGHT, buttonOffsetX, 0)
        end

        rowRemaining = rowRemaining - 1
    end
    -- Agility heroes
    BlzFrameSetPoint(agiText, FRAMEPOINT_TOPLEFT, lastRowFirstButton, FRAMEPOINT_BOTTOMLEFT, 0, 0)
    newSection = true
    rowRemaining = colSize
    for key, unitCode in pairs(HeroPicker.Heroes.Agility) do
        buttonIndex = buttonIndex + 1

        local button = BlzCreateFrame("HeroSelectorButton", heroBox, 0, buttonIndex)
        local icon = BlzGetFrameByName("HeroSelectorButtonIcon", buttonIndex)
        local iconDisabled = BlzGetFrameByName("HeroSelectorButtonIconDisabled", buttonIndex)
        
        local tooltip = BlzCreateFrame("HeroSelectorText", heroBox, 0, buttonIndex)
        BlzFrameSetTooltip(button, tooltip)
        BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOM, button, FRAMEPOINT_TOP, 0,0)
        BlzFrameSetSize(button, buttonSize, buttonSize)
        
        if HeroPicker.Heroes[buttonIndex] and HeroPicker.Heroes[buttonIndex] > 0 then
            BlzFrameSetTexture(icon, BlzGetAbilityIcon(unitCode), 0, true)
            BlzFrameSetTexture(iconDisabled, HeroPicker.getDisabledIcon(BlzGetAbilityIcon(unitCode)), 0, true)
            BlzFrameSetText(tooltip, GetObjectName(unitCode))
        else
            BlzFrameSetEnable(button, false)
            BlzFrameSetTexture(icon, emptyButtonPath, 0, true)
            BlzFrameSetTexture(iconDisabled, emptyButtonPath, 0, true)
        end
        
        local heroButton = {}
        HeroPicker.HeroButtons[buttonIndex] = heroButton
        heroButton.Frame = button
        heroButton.Icon = icon
        heroButton.IconDisabled = iconDisabled
        heroButton.Tooltip = tooltip
        
        HeroPicker.HeroButtons[button] = buttonIndex
        table.insert(HeroPicker.Events, BlzTriggerRegisterFrameEvent(onClickTrigger, button, FRAMEEVENT_CONTROL_CLICK))
        
        if newSection then
            newSection = false
            lastRowFirstButton = button
            BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, agiText, FRAMEPOINT_BOTTOMLEFT, 0, 0)
            height = height + buttonSize
        elseif rowRemaining <= 0 then
            lastRowFirstButton = button
            BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, HeroPicker.HeroButtons[buttonIndex - colCount].Frame, FRAMEPOINT_BOTTOMLEFT, 0, -buttonOffsetY)
            rowRemaining = colCount
            height = height + buttonOffsetY + buttonSize
        else
            BlzFrameSetPoint(button, FRAMEPOINT_LEFT, HeroPicker.HeroButtons[buttonIndex - 1].Frame, FRAMEPOINT_RIGHT, buttonOffsetX, 0)
        end

        rowRemaining = rowRemaining - 1
    end
    -- Intelligence heroes
    BlzFrameSetPoint(intText, FRAMEPOINT_TOPLEFT, lastRowFirstButton, FRAMEPOINT_BOTTOMLEFT, 0, 0)
    newSection = true
    rowRemaining = colSize
    for key, unitCode in pairs(HeroPicker.Heroes.Intelligence) do
        buttonIndex = buttonIndex + 1

        local button = BlzCreateFrame("HeroSelectorButton", heroBox, 0, buttonIndex)
        local icon = BlzGetFrameByName("HeroSelectorButtonIcon", buttonIndex)
        local iconDisabled = BlzGetFrameByName("HeroSelectorButtonIconDisabled", buttonIndex)
        
        local tooltip = BlzCreateFrame("HeroSelectorText", heroBox, 0, buttonIndex)
        BlzFrameSetTooltip(button, tooltip)
        BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOM, button, FRAMEPOINT_TOP, 0,0)
        BlzFrameSetSize(button, buttonSize, buttonSize)
        
        if HeroPicker.Heroes[buttonIndex] and HeroPicker.Heroes[buttonIndex] > 0 then
            BlzFrameSetTexture(icon, BlzGetAbilityIcon(unitCode), 0, true)
            BlzFrameSetTexture(iconDisabled, HeroPicker.getDisabledIcon(BlzGetAbilityIcon(unitCode)), 0, true)
            BlzFrameSetText(tooltip, GetObjectName(unitCode))
        else
            BlzFrameSetEnable(button, false)
            BlzFrameSetTexture(icon, emptyButtonPath, 0, true)
            BlzFrameSetTexture(iconDisabled, emptyButtonPath, 0, true)
        end
        
        local heroButton = {}
        HeroPicker.HeroButtons[buttonIndex] = heroButton
        heroButton.Frame = button
        heroButton.Icon = icon
        heroButton.IconDisabled = iconDisabled
        heroButton.Tooltip = tooltip
        
        HeroPicker.HeroButtons[button] = buttonIndex
        table.insert(HeroPicker.Events, BlzTriggerRegisterFrameEvent(onClickTrigger, button, FRAMEEVENT_CONTROL_CLICK))
        
        if newSection then
            newSection = false
            BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, intText, FRAMEPOINT_BOTTOMLEFT, 0, 0)
            height = height + buttonSize
        elseif rowRemaining <= 0 then
            BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, HeroPicker.HeroButtons[buttonIndex - colCount].Frame, FRAMEPOINT_BOTTOMLEFT, 0, -buttonOffsetY)
            rowRemaining = colCount
            height = height + buttonOffsetY + buttonSize
        else
            BlzFrameSetPoint(button, FRAMEPOINT_LEFT, HeroPicker.HeroButtons[buttonIndex - 1].Frame, FRAMEPOINT_RIGHT, buttonOffsetX, 0)
        end

        rowRemaining = rowRemaining - 1
    end

    local acceptButton = BlzCreateFrameByType("GLUETEXTBUTTON", "OKButton", heroBox, "ScriptDialogButton", 0)
    local randomButton = BlzCreateFrameByType("GLUETEXTBUTTON", "RandomButton", heroBox, "ScriptDialogButton", 0)
    BlzFrameSetPoint(acceptButton, FRAMEPOINT_TOPLEFT, heroBox, FRAMEPOINT_BOTTOM, 0.005, 0)
    BlzFrameSetPoint(randomButton, FRAMEPOINT_TOPRIGHT, heroBox, FRAMEPOINT_BOTTOM, -0.005, 0)
    BlzFrameSetSize(acceptButton, 0.085, 0.03)
    BlzFrameSetSize(randomButton, 0.085, 0.03)
    BlzFrameSetText(acceptButton, "PICK")
    BlzFrameSetText(randomButton, "RANDOM")
    BlzFrameSetVisible(acceptButton, true)
    BlzFrameSetVisible(randomButton, true)
    
    local acceptTrigger = CreateTrigger()
    local randomTrigger = CreateTrigger()
    table.insert(HeroPicker.Events, BlzTriggerRegisterFrameEvent(acceptTrigger, acceptButton, FRAMEEVENT_CONTROL_CLICK))
    table.insert(HeroPicker.Events, BlzTriggerRegisterFrameEvent(randomTrigger, randomButton, FRAMEEVENT_CONTROL_CLICK))
    HeroPicker.Trigger[acceptTrigger] = TriggerAddAction(acceptTrigger, HeroPicker.acceptButtonClick)
    HeroPicker.Trigger[randomTrigger] = TriggerAddAction(randomTrigger, HeroPicker.randomButtonClick)

    table.insert(HeroPicker.Trigger, acceptTrigger)
    table.insert(HeroPicker.Trigger, randomTrigger)
    table.insert(HeroPicker.Trigger, onClickTrigger)
    table.insert(HeroPicker.Frames, strText)
    table.insert(HeroPicker.Frames, agiText)
    table.insert(HeroPicker.Frames, intText)
    table.insert(HeroPicker.Frames, acceptButton)
    table.insert(HeroPicker.Frames, randomButton)
    table.insert(HeroPicker.Frames, heroBox)
    table.insert(HeroPicker.Frames, descBox)
    HeroPicker.AcceptButton = acceptButton
    HeroPicker.RandomButton = randomButton
    HeroPicker.HeroBox = heroBox
    HeroPicker.DescriptionBox = descBox
    BlzFrameSetSize(heroBox, width, height)
    BlzFrameSetVisible(heroBox, true)
end