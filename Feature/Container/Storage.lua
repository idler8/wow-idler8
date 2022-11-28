local ADDON_NAME, Core = ...
local _D = Core:Lib('DB')
local _E = Core:Lib('Event')
local Storage = Core:Lib('Container.Storage')

function Storage:GetContainer(bagID)
    local bags = _D:Account().bags;
    if not bags[bagID] then bags[bagID] = {slotNumber = 0, itemIDs = {}, itemCounts = {}} end
    return bags[bagID]
end
function Storage:UpdateSlotNumber(bagID, slotNumber)
    Storage:GetContainer(bagID).slotNumber = slotNumber
end
function Storage:UpdateItemInfo(bagID, slotID, info)
    local bag = Storage:GetContainer(bagID)
    local itemIDs = bag.itemIDs;
    local itemCounts = bag.itemCounts;
    if info and info.itemID then
        itemIDs[slotID] = info.itemID;
        itemCounts[slotID] = info.stackCount;
    else
        itemIDs[slotID] = nil
        itemCounts[slotID] = nil
    end
    return info
end