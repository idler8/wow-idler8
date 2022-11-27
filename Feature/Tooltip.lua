local ADDON_NAME, Core = ...
local _D = Core:Lib('DB')
local function ItemCountInContainer(bags, theContainer, itemID)
    local itemCount = 0;
    for bagID in theContainer:Iterator() do
        if bags[bagID] then
            local bag = bags[bagID];
            for slotID = 1, bag.slotNumber do
                if bag.itemIDs[slotID] == itemID then
                    itemCount = itemCount + (bag.itemCounts[slotID] or 0)
                end
            end
        end
    end
    return itemCount;
end
local function ShowItemCount(itemID)
    for i, Account in _D:Accounts() do
        local bags = Account.bags;
        local itemCountInBackpack = ItemCountInContainer(bags, Core:Lib('Container.Backpack'), itemID)
        local itemCountInBank = ItemCountInContainer(bags, Core:Lib('Container.Bank'), itemID)
        if itemCountInBackpack > 0 or itemCountInBank > 0 then
            local itemCountInBackpackString = itemCountInBackpack > 0 and '背包:'..itemCountInBackpack or '';
            local itemCountInBankString = itemCountInBank > 0 and '银行:'..itemCountInBank or '';
            local itemCountSplit = (itemCountInBackpack > 0 and itemCountInBank > 0) and '|' or '';
            GameTooltip:AddDoubleLine(Account.name, itemCountInBackpackString..itemCountSplit..itemCountInBankString)
        end
    end
end
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    if tooltip == GameTooltip then
        ShowItemCount(data.id)
        GameTooltip:AddLine('ID:'..data.id)
    end
end)