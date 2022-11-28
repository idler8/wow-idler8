local ADDON_NAME, Core = ...
local _E = Core:Lib('Event')
local _D = Core:Lib('Debug')
local Storage = Core:Lib('Container.Storage')
local Container = Core:Lib('Container')
local Updater = Core:Lib('Container.Updater')
local Backpack = Core:Lib('Container.Backpack')
local Bank = Core:Lib('Container.Bank')

local FRAME_THAT_OPENED_BAGS = nil
local function OpenAllBags(frame, forceUpdate)
    local Popup, Matrix = Backpack:Create();
    if Popup:IsShown() then return end;
    Popup:Show(true)
    if (frame) then FRAME_THAT_OPENED_BAGS = frame:GetName() end
end
local function CloseAllBags(frame, forceUpdate)
    if (frame and frame:GetName() ~= FRAME_THAT_OPENED_BAGS) then return end
    FRAME_THAT_OPENED_BAGS = nil;
    local Popup, Matrix = Backpack:Create();
    Popup:SetShown(false)
end
local function PLAYER_INTERACTION_MANAGER_FRAME_SHOW(type)
    if type ~= Enum.PlayerInteractionType.Banker then return end
    local Popup, Matrix = Bank:Create();
    Popup:SetShown(true)
    local _B = Backpack:Create();
    _B:ClearAllPoints();
    _B:SetPoint("TOPLEFT", Popup, "TOPRIGHT", 0, 0)
    OpenAllBags(Popup)
end
local function PLAYER_INTERACTION_MANAGER_FRAME_HIDE(type)
    if type ~= Enum.PlayerInteractionType.Banker then return end
    local Popup, Matrix = Bank:Create();
    Popup:SetShown(false)
    CloseAllBags(Popup)
end
local function PlayerInteractionFrameManagerToggle(manager, type)
    return type ~= Enum.PlayerInteractionType.Banker
end
local function Finish() 
    if InCombatLockdown() then return _E:OnceListener('PLAYER_REGEN_ENABLED', Finish) end
    Container:UpdateLockdown()
    Backpack:Finish()
    Bank:Finish()
    print('插件入口启用')
    _D:replace(_G, 'OpenAllBags', OpenAllBags)
    _D:replace(_G, 'CloseAllBags', CloseAllBags)
    _D:replace(_G, 'ToggleAllBags', function(frame, forceUpdate)
        _G[Backpack:Create():IsShown() and 'CloseAllBags' or 'OpenAllBags'](frame, forceUpdate)
    end) 
    _D:replace(_G, 'OpenBackpack', function() OpenAllBags() end) 
    _D:replace(_G, 'ToggleBag', function() ToggleAllBags() end)
    _E:AddListener('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', PLAYER_INTERACTION_MANAGER_FRAME_SHOW)
    _E:AddListener('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', PLAYER_INTERACTION_MANAGER_FRAME_HIDE)
    _D:replace(PlayerInteractionFrameManager, 'ShowFrame', PlayerInteractionFrameManagerToggle)
    _D:replace(PlayerInteractionFrameManager, 'HideFrame', PlayerInteractionFrameManagerToggle)
end
_E:AddListener('PLAYER_REGEN_ENABLED', function()
    Container:UpdateLockdown()
    Backpack:Finish()
    Bank:Finish()
end)
_E:OnceListener('SPELLS_CHANGED', Finish)

_E:AddListener('BAG_UPDATE_DELAYED', function() 
    Container:UpdateLockdown()
    Backpack:Update()
    Bank:Update()
end)
_E:AddListener('BAG_UPDATE_COOLDOWN', function() 
    Backpack:Cooldowns()
    Bank:Cooldowns()
end)
_E:AddListener('BAG_UPDATE', function(bagID) 
    Container:PerUpdateContainer(bagID) -- 标记 元素可以更新、数据可以更新
end)
_E:AddListener('PLAYERREAGENTBANKSLOTS_CHANGED', function(slot)
    Container:PerUpdateContainer(REAGENTBANK_CONTAINER)
    Bank:Update()
    -- Bank:UpdateItemButton(REAGENTBANK_CONTAINER, slot) -- 打开则更新元素，未打开则更新数据
end)
do
    local Popup, Matrix = Backpack:Create()
    if not Popup:IsUserPlaced() then Popup:SetPoint("TOPRIGHT", -300, -60) end
    Popup:SetScript('OnShow', function()
        Backpack:Show()
    end)
end
do
    local Popup, Matrix = Bank:Create()
    if not Popup:IsUserPlaced() then Popup:SetPoint("TOPLEFT", 10, -60) end
    Popup:SetScript('OnHide',function() CloseBankFrame() end)
    Popup:SetScript('OnShow', function() 
        Bank:Show()
    end)
end
