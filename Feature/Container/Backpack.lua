local ADDON_NAME, Core = ...
local _F = Core:Lib('Frame');
local Container = Core:Lib('Container')
local Updater = Core:Lib('Container.Updater')
local Backpack = Core:Lib('Container.Backpack')
local function Sortable(BagFrame)
    local SortButton = CreateFrame('Button', nil, BagFrame);
    SortButton:SetSize(28, 26)
    SortButton:SetNormalTexture("bags-button-autosort-up")
    SortButton:SetPushedTexture("bags-button-autosort-down")
    SortButton:SetHighlightTexture("Interface\Buttons\ButtonHilight-Square", "ADD")
    SortButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self);
        GameTooltip_SetTitle(GameTooltip, '快捷操作', HIGHLIGHT_FONT_COLOR);
        GameTooltip_AddNormalLine(GameTooltip, '整理背包物品');
        GameTooltip:Show();
    end)
    SortButton:SetScript('OnClick', function()
        PlaySound(SOUNDKIT.UI_BAG_SORTING_01);
        C_Container.SortBags();
    end)
    return SortButton
end
local function UseMoney(BagFrame)
    local MoneyButton = CreateFrame('Button', nil, BagFrame, 'SmallMoneyFrameTemplate');
    return MoneyButton
end
function Backpack:Iterator()
    local bag = BACKPACK_CONTAINER - 1;
    local max = NUM_BAG_SLOTS + 1
    return function()
        bag = bag + 1;
        if bag > max then return end
        return bag;
    end
end
function Backpack:Update()
    local Popup = self:Create();
    local isVisible = Popup:IsShown()
    for bagID in self:Iterator() do
        local bagContainer = Container:GetContainer(bagID)
        if bagContainer._needUpdate == 2 then
            if Container:CheckContainer(bagContainer) then self._needResize = true end
            Container:FinishContainer(bagContainer);
            if isVisible then
                bagContainer._needUpdate = 0
                Container:UpdateContainer(bagContainer)
            else
                bagContainer._needUpdate = 1
                Container:StorageContainer(bagContainer)
            end
        end
    end
    if not isVisible then return end;
    self:Resize()
end
function Backpack:Show()
    for bagID in self:Iterator() do
        local bagContainer = Container:GetContainer(bagID)
        if bagContainer._needUpdate == 1 then
            bagContainer._needUpdate = 0;
            Container:UpdateContainer(bagContainer)
        end
    end
    self:Resize()
end
function Backpack:Resize()
    local Popup = self:Create();
    if not self._needResize then return end
    self._needResize = false
    local width, height = Container:GetSize(self, 10, true)
    Popup:SetSize(width + 8 * 2 - 3, height + 8 * 2 - 3 + 24);
end
function Backpack:Finish()
    for bagID in self:Iterator() do
        Container:FinishContainer(Container:GetContainer(bagID));
    end
end
function Backpack:Create()
    local Popup = CreateFrame("Frame", "_Container_Backpack", UIParent, "BackdropTemplate");
    Popup:SetBackdrop(BACKDROP_TUTORIAL_16_16)
    Popup:SetFrameStrata('HIGH')
    Popup:ClearAllPoints()
    Popup:Hide()
    _F:Movable(Popup);
    _F:Closable(Popup):SetPoint("TOPRIGHT", -6, -6)
    Sortable(Popup):SetPoint("TOPLEFT", 4, -4)
    UseMoney(Popup):SetPoint("TOPRIGHT", -24, -12)
    local Matrix = CreateFrame('Frame', nil, Popup);
    Matrix:SetAllPoints();
    Matrix:SetPoint("TOPLEFT", 8, -30);
    for bagID in self:Iterator() do
        local bagContainer = Container:GetContainer(bagID)
        bagContainer:SetParent(Matrix);
        bagContainer:SetAllPoints();
    end
    function Backpack:Create() return Popup, Matrix end
    return Popup, Matrix;
end
-- function Backpack:Cooldowns()
--     if not self:Create():IsShown() then return end
--     for bagID in self:Iterator() do
--         if Container:GetContainer(bagID):IsShown() then
--             Container:UpdateCooldowns(bagID)
--         end
--     end
-- end