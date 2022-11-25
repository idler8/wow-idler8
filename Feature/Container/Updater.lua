local ADDON_NAME, Core = ...
local _E = Core:Lib('Event')
local _D = Core:Lib('Debug')
local Container = Core:Lib('Container')
local Updater = Core:Lib('Container.Updater')
local Backpack = Core:Lib('Container.Backpack')
local Bank = Core:Lib('Container.Bank')

local function Running()
    _E:AddListener('BAG_UPDATE', function(bagID)
        local bagContainer = Container:GetContainer(bagID)
        if bagContainer then bagContainer._needUpdate = true end;
    end)
    local FRAME_THAT_OPENED_BAGS = nil
    _D:replace(_G, 'OpenAllBags', function(frame, forceUpdate)
        local Popup, Matrix = Backpack:Create();
        if Popup:IsShown() then return end;
        Popup:SetShown(true)
        if (frame and not FRAME_THAT_OPENED_BAGS) then
            FRAME_THAT_OPENED_BAGS = frame:GetName();
        end
    end)
    _D:replace(_G, 'CloseAllBags', function(frame, forceUpdate)
        if (frame and frame:GetName() ~= FRAME_THAT_OPENED_BAGS) then return end
        FRAME_THAT_OPENED_BAGS = nil;
        local Popup, Matrix = Backpack:Create();
        Popup:SetShown(false)
    end)
    _D:replace(_G, 'ToggleAllBags',function()
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
        end
    end)
    _E:AddListener('PLAYER_INTERACTION_MANAGER_FRAME_HIDE',function(type)
        if type == Enum.PlayerInteractionType.Banker then
            local Popup, Matrix = Bank:Create();
            Popup:SetShown(false)
        end
    end)
    _D:replace(PlayerInteractionFrameManager, 'ShowFrame', function(manager, type)
        -- Enum.PlayerInteractionType.GuildBanker
        -- Enum.PlayerInteractionType.VoidStorageBanker
        return type ~= Enum.PlayerInteractionType.Banker
    end)
    _D:replace(PlayerInteractionFrameManager, 'HideFrame', function(manager, type)
        -- Enum.PlayerInteractionType.GuildBanker
        -- Enum.PlayerInteractionType.VoidStorageBanker
        return type ~= Enum.PlayerInteractionType.Banker
    end)
    
    do
        local Popup, Matrix = Backpack:Create();
        Popup:SetPoint("TOPRIGHT", -300, -60)
        Popup:SetScript('OnShow', function()
            Backpack:Update();
        end)
        _E:AddListener('BAG_UPDATE_DELAYED', function()
            if Popup:IsShown() then Backpack:Update() end
        end)
        _E:AddListener('BAG_UPDATE_COOLDOWN', function()
            Backpack:Cooldowns()
        end)
    end
    do
        local Popup, Matrix = Bank:Create();
        Popup:SetPoint("TOPLEFT", 10, -60)
        Popup:SetScript('OnHide',function()
            CloseBankFrame()
        end)
        Popup:SetScript('OnShow', function()
            local _B = Backpack:Create();
            _B:ClearAllPoints();
            _B:SetPoint("TOPLEFT", Popup, "TOPRIGHT", 0, 0)
            _B:Show();
            Bank:Update();
        end)
        _E:AddListener('BAG_UPDATE_DELAYED', function()
            if Popup:IsShown() then Bank:Update() end
        end)
        _E:AddListener('PLAYERREAGENTBANKSLOTS_CHANGED', function(slot)
            if Popup:IsShown() then
                Container:UpdateItemButton(REAGENTBANK_CONTAINER, slot)
            else
                local bagContainer = Container:GetContainer(REAGENTBANK_CONTAINER)
                if bagContainer then bagContainer._needUpdate = true end;
            end
        end)
    end
end
_E:OnceListener('SPELLS_CHANGED', function()
    print('Running', InCombatLockdown())
    if InCombatLockdown() then
        _E:OnceListener('PLAYER_REGEN_ENABLED', Running)
    else
        Running()
    end
end)

-- -- 搜索、排序后倒查背包>设置忽略直到背包有空格>设置为倒序>再次排序
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