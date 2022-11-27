local ADDON_NAME, Core = ...
local _D = Core:Lib('DB')
local _E = Core:Lib('Event')
local Storage = Core:Lib('Container.Storage')
function Storage:GetContainer(bagID)
    local bags = _D:Account().bags;
    if not bags[bagID] then bags[bagID] = {slotNumber = 0, itemIDs = {}, itemCounts = {}} end
    return bags[bagID]
end
function Storage:UpdateContainer(bagID)
    local bag = Storage:GetContainer(bagID);
    local itemIDs = bag.itemIDs
    local itemCounts = bag.itemCounts
    for slotID = 1, bag.slotNumber do
        self:UpdateItemValue(bagID, slotID, itemIDs, itemCounts)
    end
end
function Storage:UpdateSlotNumber(bagID, slotNumber)
    self:GetContainer(bagID).slotNumber = slotNumber
end
function Storage:UpdateItemValue(bagID, slotID, itemIDs, itemCounts)
    local info = C_Container.GetContainerItemInfo(bagID, slotID)
    if info and info.itemID then
        itemIDs[slotID] = info.itemID;
        itemCounts[slotID] = info.stackCount;
    else
        itemIDs[slotID] = nil
        itemCounts[slotID] = nil
    end
    return info
end
function Storage:UpdateItemInfo(bagID, slotID)
    local bag = self:GetContainer(bagID);
    local itemIDs = bag.itemIDs
    local itemCounts = bag.itemCounts
    return self:UpdateItemValue(bagID, slotID, itemIDs, itemCounts)
end