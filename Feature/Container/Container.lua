local ADDON_NAME, Core = ...
local _F = Core:Lib('Frame')
local Container = Core:Lib('Container')
local Storage = Core:Lib('Container.Storage')
local pool = CreateFramePool('ItemButton', nil, "ContainerFrameItemButtonTemplate");

local bagContainers = {};
function Container:CreateContainer(bagID)
    print('CreateContainer', bagID)
    local bagContainer = CreateFrame("Frame")
    bagContainer._bagID = bagID;
    bagContainer._slotNumber = 0;
    bagContainer._needUpdate = 2;
    bagContainer._needFinish = true;
    bagContainer._itemButtons = {};
    bagContainers[bagID] = bagContainer
    return bagContainer;
end
function Container:GetContainer(bagID)
    return bagContainers[bagID] or Container:CreateContainer(bagID)
end
function Container:PerUpdateContainer(bagID)
    Container:GetContainer(bagID)._needUpdate = 2;
end
function Container:CheckContainer(bagContainer)
    local bagID = bagContainer._bagID
    local beforeChange = bagContainer._slotNumber;
    local slotNumber = C_Container.GetContainerNumSlots(bagID)
    if slotNumber == beforeChange then return end;
    bagContainer._slotNumber = slotNumber;
    Storage:UpdateSlotNumber(bagID, slotNumber);
    if  slotNumber > beforeChange then bagContainer._needFinish = true end
    local itemButtons = bagContainer._itemButtons;
    for slot = slotNumber + 1, beforeChange do
        if itemButtons[slot] then
            pool:Release(itemButtons[slot])
            itemButtons[slot] = nil
        end
    end
    for slot = beforeChange + 1, slotNumber do
        local item = pool:Acquire();
        item:SetParent(bagContainer)
        item:ClearAllPoints();
        item:Show();
        item._slotID = slot;
        itemButtons[slot] = item;
    end
    return true
end
local global_lockdown = true
function Container:UpdateLockdown()
    global_lockdown = InCombatLockdown()
end
function Container:FinishContainer(bagContainer)
    if global_lockdown then return end
    if not bagContainer._needFinish then return end
    local bagID = bagContainer._bagID
    local slotNumber = bagContainer._slotNumber;
    local itemButtons = bagContainer._itemButtons;
    _F:SecureSetID(bagContainer, bagID)
    for slotID = 1, slotNumber do
        local itemButton = itemButtons[slotID]
        _F:SecureSetID(itemButton, slotID)
    end
    bagContainer._needFinish = nil;
end
function Container:UpdateContainer(bagContainer)
    local bagID = bagContainer._bagID;
    local slotNumber = bagContainer._slotNumber;
    local itemButtons = bagContainer._itemButtons;
    for slotID = 1, slotNumber do
        local info = C_Container.GetContainerItemInfo(bagID, slotID)
        local itemButton = itemButtons[slotID]
        local info = Container:ItemUpdate(itemButton)
        Storage:UpdateItemInfo(bagID, slotID, info)
    end
end
function Container:StorageContainer(bagContainer)
    local bagID = bagContainer._bagID;
    local slotNumber = bagContainer._slotNumber;
    for slotID = 1, slotNumber do
        local info = C_Container.GetContainerItemInfo(bagID, slotID)
        Storage:UpdateItemInfo(bagID, slotID, info)
    end
end
function Container:ItemUpdate(itemButton)
    if not itemButton then return end
    local bagID = itemButton:GetParent()._bagID;
    local slotID = itemButton._slotID;
    local info = C_Container.GetContainerItemInfo(bagID, slotID)
    local texture = info and info.iconFileID;
    local itemCount = info and info.stackCount;
    local locked = info and info.isLocked;
    local quality = info and info.quality;
    local readable = info and info.IsReadable;
    local itemLink = info and info.hyperlink;
    local isFiltered = info and info.isFiltered;
    local noValue = info and info.hasNoValue;
    local itemID = info and info.itemID;
    local isBound = info and info.isBound;
    local questInfo = C_Container.GetContainerItemQuestInfo(bagID, itemButton:GetID());
    local isQuestItem = questInfo.isQuestItem;
    local questID = questInfo.questID;
    local isActive = questInfo.isActive;
    ClearItemButtonOverlay(itemButton);
    itemButton:SetHasItem(texture);
    itemButton:SetItemButtonTexture(texture);
    local doNotSuppressOverlays = false;
    SetItemButtonQuality(itemButton, quality, itemLink, doNotSuppressOverlays, isBound);
    SetItemButtonCount(itemButton, itemCount);
    SetItemButtonDesaturated(itemButton, locked);
    itemButton:UpdateExtended();
    itemButton:UpdateQuestItem(isQuestItem, questID, isActive);
    itemButton:UpdateNewItem(quality);
    itemButton:UpdateJunkItem(quality, noValue);
    itemButton:UpdateItemContextMatching();
    itemButton:UpdateCooldown(texture);
    itemButton:SetReadable(readable);
    itemButton:CheckUpdateTooltip(tooltipOwner);
    itemButton:SetMatchesSearch(not isFiltered);
    -- if itemButton:CheckForTutorials(not isFiltered and shouldDoTutorialChecks, itemID) then
    --     shouldDoTutorialChecks = false;
    -- end
    return info
end
function Container:GetSize(Instance, max, reverse)
    local size, inline, x, y = 37 + 2, max or 10, 0, 0
    for bagID in Instance:Iterator() do
        local bagContainer = Container:GetContainer(bagID)
        if bagContainer:IsShown() then
            local itemButtons = bagContainer._itemButtons
            if reverse then 
                for slot = bagContainer._slotNumber, 1, -1 do
                    if x >= inline then y = y + 1; x = 0; end
                    itemButtons[slot]:SetPoint("TOPLEFT", x * size, - y * size)
                    x = x + 1
                end
            else
                for slot = 1, bagContainer._slotNumber do
                    if x >= inline then y = y + 1; x = 0; end
                    itemButtons[slot]:SetPoint("TOPLEFT", x * size, - y * size)
                    x = x + 1
                end
            end
        end
    end
    y = y + 1
    local width = (y > 0 and inline * size or x * size)
    local height = y * size
    print('GetSize',width, height)
    return width, height
end