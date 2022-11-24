local ADDON_NAME, Core = ...
local _F = Core:Lib('Frame');
local Container = Core:Lib('Container')
local Updater = Core:Lib('Container.Updater')
local Backpack = Core:Lib('Container.Bank')
setmetatable(Backpack,{ __index = Container })
local function Sortable(BagFrame)
    local SortButton = CreateFrame('Button', nil, BagFrame);
    SortButton:SetSize(28, 26)
    SortButton:SetNormalTexture("bags-button-autosort-up")
    SortButton:SetPushedTexture("bags-button-autosort-down")
    SortButton:SetHighlightTexture("Interface\Buttons\ButtonHilight-Square", "ADD")
    SortButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self);
        GameTooltip_SetTitle(GameTooltip, '快捷操作', HIGHLIGHT_FONT_COLOR);
        GameTooltip_AddNormalLine(GameTooltip, '左键 - 整理银行物品');
        GameTooltip_AddNormalLine(GameTooltip, '右键 - 将所有材料放置到材料银行');
        GameTooltip:Show();
    end)
    SortButton:RegisterForClicks("LeftButtonUp","RightButtonUp");
    SortButton:SetScript('OnClick', function(self, button)
        if button == 'RightButton' then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
            DepositReagentBank();
        else
            PlaySound(SOUNDKIT.UI_BAG_SORTING_01);
            C_Container.SortBankBags();
            C_Timer.After(1, function()
                C_Container.SortReagentBankBags();
            end)
        end
    end)
    return SortButton
end
function Backpack:Iterator()
    local bag = BANK_CONTAINER - 1;
    local max = NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS;
    return function()
        if bag == REAGENTBANK_CONTAINER then return end
        if bag == BANK_CONTAINER then bag = NUM_TOTAL_EQUIPPED_BAG_SLOTS end;
        bag = bag + 1;
        if bag > max then bag = REAGENTBANK_CONTAINER end
        return bag;
    end
end
function Backpack:Initialize()
    local Popup = CreateFrame("Frame", "_Container_Bank", UIParent, "BackdropTemplate");
    Popup:SetBackdrop(BACKDROP_TUTORIAL_16_16)
    Popup:SetFrameStrata('HIGH')
    Popup:ClearAllPoints()
    Popup:Hide()
    tinsert(_G.UISpecialFrames, "_Container_Bank")
    _F:Movable(Popup);
    _F:Closable(Popup):SetPoint("TOPRIGHT", -6, -6)
    Sortable(Popup):SetPoint("TOPLEFT", 4, -4)
    local Matrix = CreateFrame('Frame', nil, Popup);
    Matrix:SetAllPoints();
    Matrix:SetPoint("TOPLEFT", 8, -30);
    for bagID in self:Iterator() do
        local bagContainer = Container:CreateContainer(bagID)
        bagContainer:SetParent(Matrix);
        bagContainer:SetAllPoints();
    end
    return Popup, Matrix;
end
function Backpack:Update()
    local Popup, Matrix = self:Create();
    if self:CheckContainers() then 
        local width, height = self:Resize(20);
        Popup:SetSize(width + 8 * 2 - 3, height + 8 * 2 - 3 + 24);
    end
    return Popup;
end
