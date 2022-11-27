local ADDON_NAME, Core = ...
local _E = Core:Lib('Event')
local _D = Core:Lib('Debug')
local Storage = Core:Lib('Container.Storage')
local Container = Core:Lib('Container')
local Updater = Core:Lib('Container.Updater')
local Backpack = Core:Lib('Container.Backpack')
local Bank = Core:Lib('Container.Bank')

local function Running()
    if InCombatLockdown() then return _E:OnceListener('PLAYER_REGEN_ENABLED', Running) end
    local FRAME_THAT_OPENED_BAGS = nil
    _D:replace(_G, 'OpenAllBags', function(frame, forceUpdate)
        local Popup, Matrix = Backpack:Create();
        if Popup:IsShown() then return end;
        Popup:SetShown(true)
        if (frame) then FRAME_THAT_OPENED_BAGS = frame:GetName() end
    end)
    _D:replace(_G, 'CloseAllBags', function(frame, forceUpdate)
        if (frame and frame:GetName() ~= FRAME_THAT_OPENED_BAGS) then return end
        FRAME_THAT_OPENED_BAGS = nil;
        local Popup, Matrix = Backpack:Create();
        Popup:SetShown(false)
    end)
    _D:replace(_G, 'ToggleAllBags',function(frame, forceUpdate)
        local Popup, Matrix = Backpack:Create();
        if Popup:IsShown() then
            _G.CloseAllBags()
        else
            _G.OpenAllBags()
        end
    end) 
    _D:replace(_G, 'OpenBackpack',function()
        _G.OpenAllBags()
    end) 
    _D:replace(_G, 'OpenBag',function(bagID)
        local bagContainer = Container:GetContainer(bagID);
        bagContainer:SetShown(true)
    end)
    _D:replace(_G, 'CloseBag',function(bagID)
        local bagContainer = Container:GetContainer(bagID);
        bagContainer:SetShown(false)
    end)
    _D:replace(_G, 'ToggleBag',function(bagID)
        _G.ToggleAllBags()
    end)
    _E:AddListener('PLAYER_INTERACTION_MANAGER_FRAME_SHOW',function(type)
        if type == Enum.PlayerInteractionType.Banker then
            local Popup, Matrix = Bank:Create();
            Popup:SetShown(true)
            local _B = Backpack:Create();
            _B:ClearAllPoints();
            _B:SetPoint("TOPLEFT", Popup, "TOPRIGHT", 0, 0)
            _G.OpenAllBags(Popup)
        end
    end)
    _E:AddListener('PLAYER_INTERACTION_MANAGER_FRAME_HIDE',function(type)
        if type == Enum.PlayerInteractionType.Banker then
            local Popup, Matrix = Bank:Create();
            Popup:SetShown(false)
            _G.CloseAllBags(Popup)
        end
    end)
    _D:replace(PlayerInteractionFrameManager, 'ShowFrame', function(manager, type)
        return type ~= Enum.PlayerInteractionType.Banker
    end)
    _D:replace(PlayerInteractionFrameManager, 'HideFrame', function(manager, type)
        return type ~= Enum.PlayerInteractionType.Banker
    end)
end
do
    local Popup, Matrix = Backpack:Create()
    if not Popup:IsUserPlaced() then Popup:SetPoint("TOPRIGHT", -300, -60) end
    Popup:SetScript('OnShow', function() Backpack:Update(true) end)
end
do
    local Popup, Matrix = Bank:Create()
    if not Popup:IsUserPlaced() then Popup:SetPoint("TOPLEFT", 10, -60) end
    Popup:SetScript('OnHide',function() CloseBankFrame() end)
    Popup:SetScript('OnShow', function()
        Bank:Update(true);
    end)
end
_E:AddListener('BAG_UPDATE', function(bagID) 
    Container:PerUpdateContainer(bagID) 
end)
_E:AddListener('BAG_UPDATE_DELAYED', function() 
    Backpack:Update()
    Bank:Update()
end)
_E:AddListener('PLAYERREAGENTBANKSLOTS_CHANGED', function(slot)
    local Popup = Bank:Create()
    if Popup:IsShown() then
        Container:UpdateItemButton(REAGENTBANK_CONTAINER, slot)
    else
        Container:PerUpdateContainer(REAGENTBANK_CONTAINER)
    end
end)
_E:OnceListener('SPELLS_CHANGED', function() 
    print('SPELLS_CHANGED')
    -- _E:AddListener('BAG_UPDATE_COOLDOWN', function()
    --     Backpack:Cooldowns()
    --     Bank:Cooldowns()
    -- end)
    Running()
 end)




-- -- 搜索
-- -- 配置：顺序、内容、忽略
-- -- 统计：资金、背包
-- -- -- banking frames
-- -- self:StopIf(_G, 'GuildBankFrame_LoadUI', self:Show('guild'))
-- -- self:StopIf(_G, 'VoidStorage_LoadUI', self:Show('vault'))
-- -- self:StopIf(_G, 'BankFrame_Open', self:Show('bank'))
-- -- BankFrame:SetScript('OnEvent', function(frame, event, ...) -- only way in classic
-- --     if (event ~= 'BANKFRAME_OPENED' or not Addon.Frames:Show('bank')) and (event ~= 'BANKFRAME_CLOSED' or not Addon.Frames:Hide('bank')) then
-- --         BankFrame_OnEvent(frame, event, ...)
-- --     end
-- -- end)
-- -- -- user frames
-- -- CharacterFrame:HookScript('OnShow', self:If('playerFrame', self:Show('inventory')))
-- -- CharacterFrame:HookScript('OnHide', self:If('playerFrame', self:Hide('inventory')))
-- -- WorldMapFrame:HookScript('OnShow', self:If('mapFrame', self:Hide('inventory', true)))