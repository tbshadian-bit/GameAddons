-- ItemDestroyer
-- Destroys the item currently under your mouse cursor when you run the
-- /destroyitem slash command from a macro/keybind.

local ADDON_NAME = ...
local PREFIX = "|cffff4040ItemDestroyer:|r "

ItemDestroyerDB = ItemDestroyerDB or {}

local function InitDB()
    if ItemDestroyerDB.requireConfirm == nil then
        if ItemDestroyerDB.requireModifier ~= nil then
            -- migrate old setting name
            ItemDestroyerDB.requireConfirm = ItemDestroyerDB.requireModifier
        else
            ItemDestroyerDB.requireConfirm = true -- prompt "are you sure?" by default
        end
    end
    ItemDestroyerDB.requireModifier = nil
end

local function GetMouseoverFrame()
    if GetMouseFoci then
        local foci = GetMouseFoci()
        return foci and foci[1]
    end
    return GetMouseFocus and GetMouseFocus()
end

-- Tries several known ways bag item buttons expose their bag/slot,
-- to support the default Blizzard bags as well as common replacement
-- bag addons (ElvUI, Bagnon, etc).
local function GetBagSlotFromFrame(frame)
    if not frame then
        return nil
    end

    if frame.GetBagID and frame.GetID then
        local ok, bag = pcall(frame.GetBagID, frame)
        if ok and bag then
            local slot = frame:GetID()
            if slot and slot > 0 then
                return bag, slot
            end
        end
    end

    if frame.bagID and frame.slotID then
        return frame.bagID, frame.slotID
    end

    if frame.bag and frame.slot then
        return frame.bag, frame.slot
    end

    local parent = frame.GetParent and frame:GetParent()
    if parent and parent.GetID and frame.GetID then
        local ok, bag = pcall(parent.GetID, parent)
        local slot = frame:GetID()
        if ok and bag and slot and slot > 0 then
            return bag, slot
        end
    end

    return nil
end

-- Actually picks up and deletes the item, re-checking it's still the same
-- item (it may have moved or been consumed while a confirmation was open).
local function PerformDestroy(bag, slot, expectedLink)
    if CursorHasItem() then
        print(PREFIX .. "Your cursor already has an item on it. Aborting.")
        return
    end

    local info = C_Container.GetContainerItemInfo(bag, slot)
    if not info or not info.hyperlink then
        print(PREFIX .. "That bag slot is empty.")
        return
    end

    if expectedLink and info.hyperlink ~= expectedLink then
        print(PREFIX .. "That slot changed since you confirmed. Aborting.")
        return
    end

    if info.isLocked then
        print(PREFIX .. "That item is locked and can't be destroyed right now.")
        return
    end

    local itemName = C_Item.GetItemNameByID and C_Item.GetItemNameByID(info.hyperlink) or info.hyperlink

    C_Container.PickupContainerItem(bag, slot)
    if not CursorHasItem() then
        print(PREFIX .. "Could not pick up the item.")
        return
    end

    DeleteCursorItem()
    print(PREFIX .. "Destroyed " .. tostring(itemName) .. ".")
end

StaticPopupDialogs["ITEMDESTROYER_CONFIRM"] = {
    text = "Destroy %s?",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, data)
        PerformDestroy(data.bag, data.slot, data.link)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function DestroyMouseoverItem()
    InitDB()

    if CursorHasItem() then
        print(PREFIX .. "Your cursor already has an item on it. Aborting.")
        return
    end

    local frame = GetMouseoverFrame()
    local bag, slot = GetBagSlotFromFrame(frame)
    if not bag or not slot then
        print(PREFIX .. "No bag item is under your mouse cursor.")
        return
    end

    local info = C_Container.GetContainerItemInfo(bag, slot)
    if not info or not info.hyperlink then
        print(PREFIX .. "That bag slot is empty.")
        return
    end

    if info.isLocked then
        print(PREFIX .. "That item is locked and can't be destroyed right now.")
        return
    end

    if ItemDestroyerDB.requireConfirm then
        local itemName = C_Item.GetItemNameByID and C_Item.GetItemNameByID(info.hyperlink) or info.hyperlink
        StaticPopup_Show("ITEMDESTROYER_CONFIRM", itemName, nil, { bag = bag, slot = slot, link = info.hyperlink })
    else
        PerformDestroy(bag, slot, info.hyperlink)
    end
end

SLASH_ITEMDESTROYER1 = "/destroyitem"
SLASH_ITEMDESTROYER2 = "/dstry"
SlashCmdList["ITEMDESTROYER"] = function(msg)
    InitDB()
    msg = (msg or ""):lower():trim()

    if msg == "safety on" then
        ItemDestroyerDB.requireConfirm = true
        print(PREFIX .. "Safety check enabled: destroying an item will ask for confirmation.")
        return
    elseif msg == "safety off" then
        ItemDestroyerDB.requireConfirm = false
        print(PREFIX .. "Safety check disabled: the macro will destroy the item under your cursor immediately, no prompt.")
        return
    end

    DestroyMouseoverItem()
end
