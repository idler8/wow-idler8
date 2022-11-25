local ADDON_NAME, Core = ...
local GetQuestReward = GetQuestReward
local Quest = Core:Lib('Quest')
local Black = Core:Lib('DB'):Filter('QuestBlackList');
Black:Filter(64541);  -- 噬渊 死亡的代价
function Quest:Select()
    local infoActive = C_GossipInfo.GetActiveQuests()
    for i = 1, #infoActive do
        if infoActive[i].isComplete then
            return C_GossipInfo.SelectActiveQuest(infoActive[i].questID)
        end
    end
    local infoAvailable = C_GossipInfo.GetAvailableQuests()
    for i = 1, #infoAvailable do
        if not Black:IsFilter(infoAvailable[i].questID) then
            return C_GossipInfo.SelectAvailableQuest(infoAvailable[i].questID)
        end
    end
    if #infoActive == 0 and #infoAvailable == 0 then
        local infoOptions = C_GossipInfo.GetOptions()
        if #infoOptions == 1 then
            -- return C_GossipInfo.GetOptions(C_GossipInfo.SelectOption(infoOptions[1].gossipOptionID))
        end
    end
end
function Quest:Greeting()
    if GetNumActiveQuests() > 0 then
        return SelectActiveQuest(1)
    end
    if GetNumAvailableQuests() > 0 then
        return SelectAvailableQuest(1)
    end
end

local _E = Core:Lib('Event')
_E:AddListener('GOSSIP_SHOW', function(...)
    if IsLeftShiftKeyDown() then return end;
    Quest:Select()
end)
_E:AddListener('QUEST_PROGRESS', function(...)
    if IsLeftShiftKeyDown() then return end;
    if GetNumQuestCurrencies() > 0 then return end;
    for i = 1, GetNumQuestItems() do
        local itemLink = GetQuestItemLink('required', i);
        local itemType = select(12, GetItemInfo(itemLink))
        if itemType ~= Enum.ItemClass.Questitem then return end
    end;
    if IsQuestCompletable() then CompleteQuest() end
end)
_E:AddListener('QUEST_COMPLETE', function(...)
    if IsLeftShiftKeyDown() then return end;
    if GetNumQuestChoices() > 0 then return end;
    if GetQuestMoneyToGet() > 0 then return end;
    GetQuestReward(QuestFrameRewardPanel.itemChoice)
end)
_E:AddListener('QUEST_DETAIL', function(...)
    if IsLeftShiftKeyDown() then return end;
    if Black:IsFilter(GetQuestID()) then return end;
    AcceptQuest()
end)
_E:AddListener('QUEST_GREETING', function(...)
    if IsLeftShiftKeyDown() then return end;
    Quest:Greeting()
end)
hooksecurefunc('DeclineQuest',function()
    if IsLeftShiftKeyDown() then return end;
    local questID = GetQuestID()
    if not questID then return end
    if C_QuestLog.IsWorldQuest(questID) then return end;
    Black:Filter(questID)
end)
hooksecurefunc(C_QuestLog, 'AbandonQuest', function()
    if IsLeftShiftKeyDown() then return end;
    local questID = C_QuestLog.GetSelectedQuest()
    if not questID then return end
    if C_QuestLog.IsWorldQuest(questID) then return end;
    Black:Filter(questID)
end)
_E:AddListener('QUEST_ACCEPTED', function(questID)
    if IsLeftShiftKeyDown() then return end;
    if C_QuestLog.IsWorldQuest(questID) then return end;
    Black:UnFilter(questID)
end)