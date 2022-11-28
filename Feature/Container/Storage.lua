local ADDON_NAME, Core = ...
local _D = Core:Lib('DB')
local _E = Core:Lib('Event')
local Storage = Core:Lib('Container.Storage')

function Storage:UpdateSlotNumber(bagID, slotNumber)
    _D:Account().bags[bagID].slotNumber = slotNumber
end
function Storage:UpdateItemInfo(bagID, slotID, info)
    local bag = _D:Account().bags[bagID]
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