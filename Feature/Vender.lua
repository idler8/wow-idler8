local ADDON_NAME, Core = ...
local UseContainerItem = UseContainerItem
local Vender = Core:Lib('Vender');
local Black = Core:Lib('DB'):Filter('VenderBlackList')
function Vender:RepairAllItems()
    RepairAllItems(true)
end
function Vender:SellAllItems(filter, unsafe)
    local totalNumber = 0
    local bagNumSlots, bag, slot, price
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        bagNumSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, bagNumSlots do
            if  Vender:Sell(bag, slot) then
                totalNumber = totalNumber + 1
                if not unsafe and totalNumber >= 12 then
                    return
                end
            end
        end
    end
end
function Vender:Safe(bag, slot)
    local id = C_Container.GetContainerItemID(bag, slot)
    if not id then return false end;
    local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
    -- print(1,itemInfo.hyperlink,itemInfo.isLocked ,itemInfo.hasNoValue )
    if itemInfo.isLocked then return false end; -- 被锁死
    if itemInfo.hasNoValue then return false end; -- 无价值
    if Black:IsFilter(itemInfo.itemID) then return false end; -- 被过滤
    if itemInfo.quality == Enum.ItemQuality.Poor then return true end; -- 是垃圾
    if not itemInfo.isBound then return false end; -- 未绑定
    -- TODO 过滤存在无需使用即有特效的物品？ 绑定到黑名单
    if IsArtifactRelicItem(itemInfo.itemID) then return true end; -- 是军团神器
    if IsEquippableItem(itemInfo.itemID) then
        if IsUsableItem(itemInfo.itemID) then return false end; -- 可使用
        if C_Container.GetContainerItemEquipmentSetInfo(bag, slot) then return false end; -- 被收藏
        local specTable = GetItemSpecInfo(itemInfo.itemID)
        if specTable and #specTable == 0 then return true end;  -- 职业区分且非本职业可用
        local classID, classSubID, _, expacID = select(12, GetItemInfo(itemInfo.itemID))
        if classID == 4 and classSubID == 0 then return false end;  -- 多种其它护甲
        if expacID < LE_EXPANSION_LEVEL_CURRENT - 1 then return true end; -- 早期版本
    else
        local specTable = GetItemSpecInfo(itemInfo.itemID)
        if specTable and #specTable == 0 then return true end;
    end
    return false;
end
function Vender:Sell(bag, slot)
    local isSafe = Vender:Safe(bag, slot);
    if isSafe then 
        C_Container.UseContainerItem(bag, slot)
     end;
    return isSafe
end
-- TODO 过滤购回的物品，根据当前可回购的数量判断回购
local _E = Core:Lib('Event');
_E:AddListener('MERCHANT_SHOW', function()
    local filter = {}
    for index, esID in pairs(C_EquipmentSet.GetEquipmentSetIDs()) do
        local locations = C_EquipmentSet.GetItemLocations(esID)
        for i,v in pairs(locations) do
            local slot,bag = select(5,EquipmentManager_UnpackLocation(v))
            if bag and slot then
                filter[bag..' '..slot] = true
            end
        end
    end
    Vender:RepairAllItems()
    Vender:SellAllItems(filter)
end)
_E:AddListener('MERCHANT_UPDATE', function()
    Black:UnFilter(C_MerchantFrame.GetBuybackItemID(GetNumBuybackItems()))
end)
hooksecurefunc("BuybackItem", function(slot)
    Black:Filter(C_MerchantFrame.GetBuybackItemID(slot))
end)