local ADDON_NAME, Core = ...
local _F = Core:Lib('Frame');
local _D = Core:Lib('DB');
local Container = Core:Lib('Container')
local bagContainers = {};
local pool = CreateFramePool('ItemButton', nil, "ContainerFrameItemButtonTemplate");
function Container:CreateContainer(bagID)
    local bagContainer = CreateFrame("Frame")
    _F:SecureSetID(bagContainer, bagID);
    bagContainer.slotNumber = 0;
    bagContainer._needUpdate = true;
    bagContainer.itemButtons = {};
    bagContainers[bagID] = bagContainer
    return bagContainer;
end
function Container:GetContainer(bagID)
    return bagContainers[bagID] or self:CreateContainer(bagID);
end
function Container:UpdateItemButton(bagID, slot)
    local bagContainer = Container:GetContainer(bagID)
    local itemButtons = bagContainer.itemButtons;
    self:ItemUpdate(itemButtons[slot])
end
function Container:UpdateContainer(bagID, forceUpdate)
    local bagContainer = Container:GetContainer(bagID)
    if not forceUpdate and not bagContainer._needUpdate then return end;
    local itemButtons = bagContainer.itemButtons;
    for slot = 1, bagContainer.slotNumber do
        Container:ItemUpdate(itemButtons[slot])
    end
    bagContainer._needUpdate = false
end
function Container:CheckContainer(bagID)
    local bagContainer = self:GetContainer(bagID)
    local slotNumber = C_Container.GetContainerNumSlots(bagID)
    if slotNumber == bagContainer.slotNumber then return false end;
    local itemButtons = bagContainer.itemButtons;
    for slot = slotNumber + 1, bagContainer.slotNumber do
        if itemButtons[slot] then
            pool:Release(itemButtons[slot])
            itemButtons[slot] = nil
        end
    end
    for slot = bagContainer.slotNumber + 1, slotNumber do
        local item = pool:Acquire();
        _F:SecureSetID(item, slot)
        item:SetParent(bagContainer)
        item:ClearAllPoints();
        item:Show();
        itemButtons[slot] = item;
    end
    bagContainer.slotNumber = slotNumber;
    return true;
end
function Container:CheckContainers()
    local needResize = false
    for bagID in self:Iterator() do
        local bagContainer = Container:GetContainer(bagID)
        if bagContainer._shownChanged then
            needResize = true
            bagContainer._shownChanged = false
        end
        if bagContainer:IsShown() then
            if Container:CheckContainer(bagID) then
                needResize = true
            end
            Container:UpdateContainer(bagID);
        end
    end
    return needResize;
end
function Container:UpdateCooldowns(bagID)
    local bagContainer = self:GetContainer(bagID)
    local itemButtons = bagContainer.itemButtons;
    for slot = 1, bagContainer.slotNumber do
        local item = itemButtons[slot]
        local info = C_Container.GetContainerItemInfo(item:GetBagID(), item:GetID());
        local texture = info and info.iconFileID;
        item:UpdateCooldown(texture)
    end
end
local function ItemIterator(max, reverse)
    if reverse then
        return max, 1, -1;
    else
        return 1, max;
    end
end
function Container:Resize(max, reverse)
    local size, inline, x, y = 37 + 2, max or 10, 0, 0
    for bagID in self:Iterator() do
        local bagContainer = fill and self:GetFillContainer(bagID) or self:GetContainer(bagID)
        local itemButtons = bagContainer.itemButtons
        if reverse then 
            for slot = bagContainer.slotNumber, 1, -1 do
                if x >= inline then y = y + 1; x = 0; end
                itemButtons[slot]:SetPoint("TOPLEFT", x * size, - y * size)
                x = x + 1
            end
        else
            for slot = 1, bagContainer.slotNumber do
                if x >= inline then y = y + 1; x = 0; end
                itemButtons[slot]:SetPoint("TOPLEFT", x * size, - y * size)
                x = x + 1
            end
        end
    end
    y = y + 1
    local width = (y > 0 and inline * size or x * size)
    local height = y * size
    return width, height
end
function Container:ItemUpdate(itemButton)
    if not itemButton then return end
    local bagID = itemButton:GetBagID();
    local slotID = itemButton:GetID()
    local info = C_Container.GetContainerItemInfo(bagID, slotID);
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
    if itemButton:CheckForTutorials(not isFiltered and shouldDoTutorialChecks, itemID) then
        shouldDoTutorialChecks = false;
    end
    if itemID then 
        _D:Storage(bagID, slotID, itemID, quality)
    end
end
function Container:Create()
    local anyValues = {self:Initialize()}
    function self:Create() return unpack(anyValues) end
    return self:Create();
end
local function iterator() end
function Container:Iterator() return iterator end
function Container:Update() return end
function Container:Initialize() return  end;