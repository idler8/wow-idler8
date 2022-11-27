local ADDON_NAME, Core = ...
local _F = Core:Lib('Frame');
local _D = Core:Lib('DB');
local Container = Core:Lib('Container')
local Storage = Core:Lib('Container.Storage')
local bagContainers = {};
local pool = CreateFramePool('ItemButton', nil, "ContainerFrameItemButtonTemplate");
function Container:CreateContainer(bagID)
    local bagContainer = CreateFrame("Frame")
    bagContainer._bagID = bagID;
    bagContainer._slotNumber = 0;
    bagContainer._needUpdate = true;
    bagContainer._needFinish = true;
    bagContainer._itemButtons = {};
    bagContainers[bagID] = bagContainer
    return bagContainer;
end
function Container:GetContainer(bagID)
    return bagContainers[bagID]
end
function Container:PerUpdateContainer(bagID)
    local bagContainer = self:GetContainer(bagID, true);
    if bagContainer then bagContainer._needUpdate = true end;
end
function Container:UpdateItemButton(bagID, slot)
    local bagContainer = self:GetContainer(bagID)
    local itemButtons = bagContainer._itemButtons;
    self:ItemUpdate(itemButtons[slot])
end
function Container:StorageContainer(bagID)
    Storage:UpdateContainer(bagID)
end
function Container:UpdateContainer(bagID)
    local bagContainer = self:GetContainer(bagID)
    if not bagContainer._needUpdate then return end;
    local itemButtons = bagContainer._itemButtons;
    for slot = 1, bagContainer._slotNumber do
        self:ItemUpdate(itemButtons[slot])
    end
    bagContainer._needUpdate = false
    return true
end
function Container:UpdateContainers(inShown)
    for bagID in self:Iterator() do 
        if not self:UpdateContainer(bagID) and not inShown then
            self:StorageContainer(bagID)
        end
    end
end
function Container:CheckContainer(bagID)
    local bagContainer = self:GetContainer(bagID)
    local slotNumber = C_Container.GetContainerNumSlots(bagID)
    Storage:UpdateSlotNumber(bagID, slotNumber)
    if slotNumber == bagContainer._slotNumber then return false, false end;
    local itemButtons = bagContainer._itemButtons;
    for slot = slotNumber + 1, bagContainer._slotNumber do
        if itemButtons[slot] then
            pool:Release(itemButtons[slot])
            itemButtons[slot] = nil
        end
    end
    for slot = bagContainer._slotNumber + 1, slotNumber do
        local item = pool:Acquire();
        bagContainer._needFinish = true
        item._slotID = slot;
        item:SetParent(bagContainer)
        item:ClearAllPoints();
        item:Show();
        itemButtons[slot] = item;
    end
    local needFinish = slotNumber > bagContainer._slotNumber
    bagContainer._slotNumber = slotNumber;
    return true, needFinish;
end
function Container:CheckContainers()
    local needResize = false
    for bagID in self:Iterator() do
        local bagContainer = self:GetContainer(bagID)
        local _needResize, _needFinish = Container:CheckContainer(bagID)
        if _needResize then needResize = true end
        if _needFinish then
            _F:SecureSetID(bagContainer, bagContainer._bagID)
            local itemButtons = bagContainer._itemButtons;
            for slot = 1, bagContainer._slotNumber do
                _F:SecureSetID(itemButtons[slot], itemButtons[slot]._slotID)
            end
        end;
    end
    return needResize;
end
function Container:UpdateCooldowns(bagID)
    local bagContainer = self:GetContainer(bagID)
    local itemButtons = bagContainer._itemButtons;
    for slot = 1, bagContainer._slotNumber do
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
        local bagContainer = self:GetContainer(bagID)
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
    return width, height
end
function Container:ItemUpdate(itemButton)
    if not itemButton then return end
    local bagID = itemButton:GetParent():GetID();
    local slotID = itemButton:GetID()
    local info = Storage:UpdateItemInfo(bagID, slotID)
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