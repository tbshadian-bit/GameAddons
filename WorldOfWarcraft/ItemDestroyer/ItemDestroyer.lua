-- ItemDestroyer
-- Destroys the item currently under your mouse cursor when you run the
-- /destroyitem slash command from a macro/keybind.

local ADDON_NAME = ...
local PREFIX = "|cffff4040ItemDestroyer:|r "

ItemDestroyerDB = ItemDestroyerDB or {}

local function InitDB()
    if ItemDestroyerDB.requireModifier == nil then
        ItemDestroyerDB.requireModifier = true -- require holding Shift by default, as a safety net
    end
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

local function DestroyMouseoverItem(modifierHeld)
    InitDB()

    if ItemDestroyerDB.requireModifier and not modifierHeld then
        print(PREFIX .. "Hold Shift while triggering the macro to destroy an item (safety check). Use /destroyitem safety off to disable this.")
        return
    end

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

    local itemName = C_Item.GetItemNameByID and C_Item.GetItemNameByID(info.hyperlink) or info.hyperlink

    C_Container.PickupContainerItem(bag, slot)
    if not CursorHasItem() then
        print(PREFIX .. "Could not pick up the item.")
        return
    end

    DeleteCursorItem()
    print(PREFIX .. "Destroyed " .. tostring(itemName) .. ".")
end

SLASH_ITEMDESTROYER1 = "/destroyitem"
SLASH_ITEMDESTROYER2 = "/dstry"
SlashCmdList["ITEMDESTROYER"] = function(msg)
    InitDB()
    msg = (msg or ""):lower():trim()

    if msg == "safety on" then
        ItemDestroyerDB.requireModifier = true
        print(PREFIX .. "Safety check enabled: hold Shift while triggering the macro to destroy an item.")
        return
    elseif msg == "safety off" then
        ItemDestroyerDB.requireModifier = false
        print(PREFIX .. "Safety check disabled: the macro will destroy the item under your cursor immediately.")
        return
    end

    DestroyMouseoverItem(IsShiftKeyDown())
end
