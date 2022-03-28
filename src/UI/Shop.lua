local emptyButtonPath = "UI\\Widgets\\EscMenu\\Human\\blank-background.blp"
local emptyInventorySlotPath = "UI\\Widgets\\Console\\Human\\human-inventory-slotfiller.blp"
-- local emptyInventorySlotPath = "resources\\BTNNoItem.blp"

local borderSize        = 0.014
local buttonSize        = 0.032
local buttonOffsetX     = 0.004
local buttonOffsetY     = 0.004
local rowSize           = 3
local colSize           = 5
local shopTitleSize     = 0.020
local descriptionWidth          = 0.265
local descriptionHeight         = 0.092
local descriptionNameSize       = 0.018
local descriptionNamePrefix     = "|cffffcc00"
local descriptionNameSufix      = "|r"
local buyButtonWidth    = 0.102
local buyButtonHeight   = 0.031
local sellButtonWidth   = 0.102
local sellButtonHeight  = 0.031
local shopButtonX       = 0.78
local shopButtonY       = 0.115
local shopButtonWidth   = 0.102
local shopButtonHeight  = 0.034
local inventoryButtonSize       = 0.032
local inventoryButtonOffsetX    = 0.003

Shop = {}
Shop.Frames = {}
Shop.ItemButtons = {}
Shop.InventoryButtons = {}
Shop.Trigger = {}
Shop.Events = {}

Shop.Items = {}
Shop.PlayerItems = {}

function Shop.init()
    Shop.addItem('I000', 150)
    Shop.addItem('I001', 150)
    Shop.addItem('I002', 150)
    Shop.addItem('I003', 350)
    Shop.addItem('I004', 350)
    Shop.addItem('I005', 350)
    Shop.addItem('I006', 570)
    Shop.addItem('I007', 570)
    Shop.addItem('I008', 570)
    Shop.addItem('I009', 100)
    Shop.addItem('I00A', 100)
    Shop.addItem('I00B', 150)
    Shop.addItem('I00C', 150)
    Shop.addItem('I00D', 200)
    Shop.addItem('I00E', 300)

end

function Shop.addItem(itemCode, cost)
    --if not cost then cost = 0 end
    if not itemCode or itemCode == 0 then
        table.insert(Shop.Items, 0)
    else
        --'Hpal' -> number?
        if type(itemCode) == "string" then
            itemCode = FourCC(itemCode)
        end
            
        --Such an object Exist?
        if GetObjectName(itemCode) == "" then print(('>I4'):pack(itemCode), "is not an valid Object") return end

        Shop.Items[itemCode] = { Index = 0, Cost = cost or 10 }
        table.insert(Shop.Items, itemCode)
        Shop.Items[itemCode].Index = #Shop.Items
    end
end

function Shop.getHeroSlot(player)
    for i = 0, 5, 1 do
        if not Shop.PlayerItems[player][i] then return i end
    end
    return -1
end

function Shop.updateInventoryBox(player)
    if GetLocalPlayer() == player then
        for i = 0, 5, 1 do
            local itemCode = Shop.PlayerItems[player][i]
            local icon = Shop.InventoryButtons[i].Icon
            local tooltip = Shop.InventoryButtons[i].Tooltip
            if not itemCode then
                BlzFrameSetTexture(icon, emptyInventorySlotPath, 0, true)
                BlzFrameSetText(tooltip, "Empty")
            else
                BlzFrameSetTexture(icon, BlzGetAbilityIcon(itemCode), 0, true)
                BlzFrameSetText(tooltip, GetObjectName(itemCode))
            end
        end
    end
end

function Shop.getDisabledIcon(icon)
    --ReplaceableTextures\CommandButtons\BTNHeroPaladin.tga -> ReplaceableTextures\CommandButtonsDisabled\DISBTNHeroPaladin.tga
    if string.sub(icon,35,35) ~= "\\" then return icon end --this string has not enough chars return it
    --string.len(icon) < 35 then return icon end --this string has not enough chars return it
    local prefix = string.sub(icon, 1, 34)
    local sufix = string.sub(icon, 36)
    return prefix .."Disabled\\DIS"..sufix
end

function Shop.itemButtonClick()
    local button = BlzGetTriggerFrame()
    local player = GetTriggerPlayer()
    local buttonIndex = Shop.ItemButtons[button]
    local itemCode = Shop.Items[buttonIndex]
    local cost = Shop.Items[itemCode].Cost
    Shop.ItemButtons[player] = buttonIndex
    if GetLocalPlayer() == player then
        BlzFrameSetScale(Shop.SelectIndicator, buttonSize/0.036)
        BlzFrameSetVisible(Shop.SelectIndicator, true)
        BlzFrameSetEnable(Shop.SellButton, false)
        BlzFrameSetVisible(Shop.SellButton, false)
        BlzFrameSetVisible(Shop.BuyButton, true)
        BlzFrameSetEnable(Shop.BuyButton, true)

        BlzFrameSetText(Shop.BuyButton, "BUY - "..cost)
        BlzFrameSetText(Shop.ItemName, descriptionNamePrefix..GetObjectName(itemCode)..descriptionNameSufix)
        BlzFrameSetText(Shop.ItemDescription, BlzGetAbilityExtendedTooltip(itemCode, 0))
        
        BlzFrameSetPoint(Shop.SelectIndicator, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, -0.001, 0.001)
        BlzFrameSetPoint(Shop.SelectIndicator, FRAMEPOINT_BOTTOMRIGHT, button, FRAMEPOINT_BOTTOMRIGHT, -0.0012, -0.0016)
    end
end

function Shop.inventoryButtonClick()
    local button = BlzGetTriggerFrame()
    local player = GetTriggerPlayer()
    local buttonIndex = Shop.InventoryButtons[button]
    if not Shop.PlayerItems[player][buttonIndex] then return end
    local itemCode = Shop.PlayerItems[player][buttonIndex]
    local cost = Shop.Items[itemCode].Cost
    Shop.InventoryButtons[player] = buttonIndex
    if GetLocalPlayer() == player then
        BlzFrameSetScale(Shop.SelectIndicator, inventoryButtonSize/0.036)
        BlzFrameSetVisible(Shop.SelectIndicator, true)
        BlzFrameSetVisible(Shop.BuyButton, false)
        BlzFrameSetEnable(Shop.BuyButton, false)
        BlzFrameSetEnable(Shop.SellButton, true)
        BlzFrameSetVisible(Shop.SellButton, true)

        BlzFrameSetText(Shop.SellButton, "SELL - "..cost)
        BlzFrameSetText(Shop.ItemName, descriptionNamePrefix..GetObjectName(itemCode)..descriptionNameSufix)
        BlzFrameSetText(Shop.ItemDescription, BlzGetAbilityExtendedTooltip(itemCode, 0))
        
        BlzFrameSetPoint(Shop.SelectIndicator, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, -0.001, 0.001)
        BlzFrameSetPoint(Shop.SelectIndicator, FRAMEPOINT_BOTTOMRIGHT, button, FRAMEPOINT_BOTTOMRIGHT, -0.0012, -0.0016)
    end
end

function Shop.actionBuyButton()
    local player = GetTriggerPlayer()
    if not Shop.ItemButtons[player] then return false end
    local buttonIndex = Shop.ItemButtons[player]
    if buttonIndex <= 0 then return false end -- reject nothing selected
    local itemCode = Shop.Items[buttonIndex]
    local cost = Shop.Items[itemCode].Cost
    if GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) < cost then
        DisplayTextToPlayer(player, 0, 0, "|cffffcc00Not enough gold|r")
    else
        Shop.PlayerItems[player] = Shop.PlayerItems[player] or {}
        local hero = Players[player].Hero
        if IsUnitDeadBJ(hero) then DisplayTextToPlayer(player, 0, 0, "|cffffcc00Hero is dead|r") return end
        local slot = Shop.getHeroSlot(player)
        if slot == -1 then
            DisplayTextToPlayer(player, 0, 0, "|cffffcc00Need a free slot for item|r")
            return
        end
        Shop.PlayerItems[player][slot] = itemCode
        UnitAddItemToSlotById(hero, itemCode, slot)
        local item = UnitItemInSlot(hero, slot)
        SetItemDroppable(item, false)
        SetItemPawnable(item, false)
        SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) - cost)
        Shop.updateInventoryBox(player)
    end
end

function Shop.actionSellButton()
    local player = GetTriggerPlayer()
    if not Shop.InventoryButtons[player] then return false end
    local buttonIndex = Shop.InventoryButtons[player]
    if buttonIndex < 0 then return false end -- reject nothing selected
    local itemCode = Shop.PlayerItems[player][buttonIndex]
    local cost = Shop.Items[itemCode].Cost

    local hero = Players[player].Hero
    if IsUnitDeadBJ(hero) then DisplayTextToPlayer(player, 0, 0, "|cffffcc00Hero is dead|r") return end
    Shop.PlayerItems[player][buttonIndex] = nil
    RemoveItem(UnitRemoveItemFromSlot(hero, buttonIndex))
    SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) + cost)
    Shop.updateInventoryBox(player)

    BlzFrameSetEnable(Shop.SellButton, false)
    BlzFrameSetText(Shop.SellButton, "SELL")
    BlzFrameSetText(Shop.ItemName, "")
    BlzFrameSetText(Shop.ItemDescription, "")
    BlzFrameSetVisible(Shop.SelectIndicator, false)
end

function Shop.actionShopButton()
    local player = GetTriggerPlayer()
    if GetLocalPlayer() == player then
        if Shop.IsVisible then
            BlzFrameSetVisible(Shop.ShopBox, false)
            BlzFrameSetVisible(Shop.DescriptionBox, false)
            BlzFrameSetVisible(Shop.InventoryBox, false)
            BlzFrameSetVisible(Shop.SelectIndicator, false)
            Shop.IsVisible = false
            BlzFrameSetText(Shop.ShopButton, "SHOP")
        else
            BlzFrameSetVisible(Shop.ShopBox, true)
            BlzFrameSetVisible(Shop.DescriptionBox, true)
            BlzFrameSetVisible(Shop.InventoryBox, true)
            BlzFrameSetVisible(Shop.SelectIndicator, true)
            Shop.IsVisible = true
            BlzFrameSetText(Shop.ShopButton, "CLOSE")
        end
    end
end

function Shop.enable(flag)
    if flag == false then
        Shop.IsVisible = flag
        BlzFrameSetVisible(Shop.SelectIndicator, flag)
        BlzFrameSetVisible(Shop.InventoryBox, flag)
        BlzFrameSetVisible(Shop.DescriptionBox, flag)
        BlzFrameSetVisible(Shop.ShopBox, flag)
        BlzFrameSetText(Shop.ShopButton, "SHOP")
    end
    BlzFrameSetEnable(Shop.ShopButton, flag)
    BlzFrameSetVisible(Shop.ShopButton, flag)
end

function Shop.create()
    Shop.init()
    
    local shopBox = BlzCreateFrame("EscMenuPopupMenuTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
    local shopBackdrop = BlzCreateFrame('EscMenuButtonBackdropTemplate', shopBox, 0, 0)
    local shopTitle = BlzCreateFrame('StandardTitleTextTemplate', shopBox, 0, 0)
    local descriptionBox = BlzCreateFrame("EscMenuPopupMenuTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
    local descriptionBackdrop = BlzCreateFrame('EscMenuControlBackdropTemplate', descriptionBox, 0, 0)
    local descriptionName = BlzCreateFrame('StandardTitleTextTemplate', descriptionBox, 0, 0)
    local descriptionText = BlzCreateFrame('StandardValueTextTemplate', descriptionBox, 0, 0)
    local inventoryBox = BlzCreateFrame("EscMenuPopupMenuTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
    local inventoryBackdrop = BlzCreateFrame('EscMenuButtonBackdropTemplate', inventoryBox, 0, 0)

    local width = (borderSize * 2) + rowSize * buttonSize + (rowSize - 1) * buttonOffsetX
    local height = (borderSize * 2) + colSize * buttonSize + (colSize - 1) * buttonOffsetY + shopTitleSize
    BlzFrameSetSize(shopBox, width, height)
    BlzFrameSetSize(shopTitle, width-borderSize-borderSize, shopTitleSize)
    width = (borderSize * 2) + 6 * inventoryButtonSize + 5 * inventoryButtonOffsetX
    BlzFrameSetSize(descriptionBox, width, height)
    BlzFrameSetSize(descriptionName, width-borderSize-borderSize, descriptionNameSize)
    BlzFrameSetSize(descriptionText, width-borderSize-borderSize, height-borderSize-borderSize-descriptionNameSize)
    height = (borderSize * 2) + inventoryButtonSize-- + shopTitleSize
    BlzFrameSetSize(inventoryBox, width, height)
    BlzFrameSetAbsPoint(shopBox, FRAMEPOINT_TOPRIGHT, 0.8, 0.5)
    BlzFrameSetAllPoints(shopBackdrop, shopBox)
    BlzFrameSetPoint(shopTitle, FRAMEPOINT_TOPLEFT, shopBox, FRAMEPOINT_TOPLEFT, borderSize, -borderSize)
    BlzFrameSetPoint(descriptionBox, FRAMEPOINT_TOPRIGHT, shopBox, FRAMEPOINT_TOPLEFT, 0, 0)
    BlzFrameSetAllPoints(descriptionBackdrop, descriptionBox)
    BlzFrameSetPoint(descriptionName, FRAMEPOINT_TOPLEFT, descriptionBox, FRAMEPOINT_TOPLEFT, borderSize, -borderSize)
    BlzFrameSetPoint(descriptionText, FRAMEPOINT_TOPLEFT, descriptionName, FRAMEPOINT_BOTTOMLEFT, 0, 0)
    BlzFrameSetPoint(inventoryBox, FRAMEPOINT_TOPRIGHT, descriptionBox, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
    BlzFrameSetAllPoints(inventoryBackdrop, inventoryBox)
    BlzFrameSetTextAlignment(shopTitle, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
    BlzFrameSetTextAlignment(descriptionName, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
    BlzFrameSetTextAlignment(descriptionText, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(shopTitle, "Items")

    local onClickTrigger = CreateTrigger()
    local onInvClickTrigger = CreateTrigger()
    Shop.Trigger[onClickTrigger] = TriggerAddAction(onClickTrigger, Shop.itemButtonClick)
    Shop.Trigger[onInvClickTrigger] = TriggerAddAction(onInvClickTrigger, Shop.inventoryButtonClick)

    Shop.SelectIndicator = BlzCreateFrameByType("SPRITE", "SelectIndicator", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
    BlzFrameSetModel(Shop.SelectIndicator, "UI\\Feedback\\Autocast\\UI-ModalButtonOn.mdl", 0)
    BlzFrameSetScale(Shop.SelectIndicator, buttonSize/0.036) --scale the model to the button size.
    BlzFrameSetVisible(Shop.SelectIndicator, false)

    local rowCount = rowSize
    local colCount = colSize
    local rowRemain = rowCount
    local x = borderSize
    local y = -borderSize-shopTitleSize
    for buttonIndex = 1, rowCount*colCount, 1 do
        local button = BlzCreateFrame("HeroSelectorButton", shopBox, 0, buttonIndex)
        local icon = BlzGetFrameByName("HeroSelectorButtonIcon", buttonIndex)
        local iconDisabled = BlzGetFrameByName("HeroSelectorButtonIconDisabled", buttonIndex)

        local tooltip = BlzCreateFrame("HeroSelectorText", shopBox, 0, buttonIndex)
        BlzFrameSetTooltip(button, tooltip)
        BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOM, button, FRAMEPOINT_TOP, 0,0)
        BlzFrameSetSize(button, buttonSize, buttonSize)

        if Shop.Items[buttonIndex] and Shop.Items[buttonIndex] > 0 then
            local itemCode = Shop.Items[buttonIndex]
            BlzFrameSetTexture(icon, BlzGetAbilityIcon(itemCode), 0, true)
            BlzFrameSetTexture(iconDisabled, Shop.getDisabledIcon(BlzGetAbilityIcon(itemCode)), 0, true)
            BlzFrameSetText(tooltip, GetObjectName(itemCode))
        else
            BlzFrameSetEnable(button, false)
            BlzFrameSetTexture(icon, emptyButtonPath, 0, true)
            BlzFrameSetTexture(iconDisabled, emptyButtonPath, 0, true)
        end

        local itemButton = {}
        Shop.ItemButtons[buttonIndex] = itemButton
        itemButton.Frame = button
        itemButton.Icon = icon
        itemButton.IconDisabled = iconDisabled
        itemButton.Tooltip = tooltip

        Shop.ItemButtons[button] = buttonIndex
        table.insert(Shop.Events, BlzTriggerRegisterFrameEvent(onClickTrigger, button, FRAMEEVENT_CONTROL_CLICK))

        if rowRemain <= 0 then
            x = borderSize
            rowRemain = rowCount
            y = y - buttonSize - buttonOffsetY
        elseif buttonIndex ~= 1 then
            x = x + buttonSize + buttonOffsetX
        end
        BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, shopBox, FRAMEPOINT_TOPLEFT, x, y)

        rowRemain = rowRemain - 1
    end
    x = borderSize
    y = -borderSize
    for buttonIndex = 0, 5, 1 do
        local button = BlzCreateFrame("HeroSelectorButton", inventoryBox, 0, buttonIndex)
        local icon = BlzGetFrameByName("HeroSelectorButtonIcon", buttonIndex)

        local tooltip = BlzCreateFrame("HeroSelectorText", inventoryBox, 0, buttonIndex)
        BlzFrameSetTooltip(button, tooltip)
        BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOM, button, FRAMEPOINT_TOP, 0,0)
        BlzFrameSetSize(button, inventoryButtonSize, inventoryButtonSize)

        BlzFrameSetTexture(icon, emptyInventorySlotPath, 0, true)
        BlzFrameSetText(tooltip, "Empty")

        local inventoryButton = {}
        Shop.InventoryButtons[buttonIndex] = inventoryButton
        inventoryButton.Frame = button
        inventoryButton.Icon = icon
        inventoryButton.Tooltip = tooltip

        Shop.InventoryButtons[button] = buttonIndex
        table.insert(Shop.Events, BlzTriggerRegisterFrameEvent(onInvClickTrigger, button, FRAMEEVENT_CONTROL_CLICK))

        if buttonIndex > 0 then
            x = x + inventoryButtonSize + inventoryButtonOffsetX
        end
        BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, inventoryBox, FRAMEPOINT_TOPLEFT, x, y)
    end
    
    local buyButton = BlzCreateFrameByType("GLUETEXTBUTTON", "BuyButton", shopBox, "ScriptDialogButton", 0)
    local sellButton = BlzCreateFrameByType("GLUETEXTBUTTON", "SellButton", shopBox, "ScriptDialogButton", 0)
    local buyTrigger = CreateTrigger()
    local sellTrigger = CreateTrigger()
    TriggerAddAction(buyTrigger, Shop.actionBuyButton)
    TriggerAddAction(sellTrigger, Shop.actionSellButton)
    BlzTriggerRegisterFrameEvent(buyTrigger, buyButton, FRAMEEVENT_CONTROL_CLICK)
    BlzTriggerRegisterFrameEvent(sellTrigger, sellButton, FRAMEEVENT_CONTROL_CLICK)
    BlzFrameSetSize(buyButton, buyButtonWidth, buyButtonHeight)
    BlzFrameSetSize(sellButton, sellButtonWidth, sellButtonHeight)

    BlzFrameSetText(buyButton, "BUY")
    BlzFrameSetText(sellButton, "SELL")
    BlzFrameSetPoint(buyButton, FRAMEPOINT_TOP, shopBox, FRAMEPOINT_BOTTOM, 0, 0)
    BlzFrameSetPoint(sellButton, FRAMEPOINT_TOP, shopBox, FRAMEPOINT_BOTTOM, 0, 0)
    Shop.BuyButton = buyButton
    Shop.SellButton = sellButton
    BlzFrameSetVisible(buyButton, true)
    BlzFrameSetEnable(buyButton, false)
    BlzFrameSetVisible(sellButton, false)

    local shopButton = BlzCreateFrameByType("GLUETEXTBUTTON", "ShopButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ScriptDialogButton", 0)
    BlzFrameSetAbsPoint(shopButton, FRAMEPOINT_BOTTOMRIGHT, shopButtonX, shopButtonY)
    BlzFrameSetSize(shopButton, shopButtonWidth, shopButtonHeight)
    BlzFrameSetText(shopButton, "SHOP")
    BlzFrameSetTextAlignment(shopButton, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)

    local shopTrigger = CreateTrigger()
    TriggerAddAction(shopTrigger, Shop.actionShopButton)
    BlzTriggerRegisterFrameEvent(shopTrigger, shopButton, FRAMEEVENT_CONTROL_CLICK)
    Shop.ShopButton = shopButton
    
    Shop.ShopBox = shopBox
    Shop.DescriptionBox = descriptionBox
    Shop.ItemName = descriptionName
    Shop.ItemDescription = descriptionText
    Shop.InventoryBox = inventoryBox
    
    Shop.enable(false)
end