local ADDON_NAME, Core = ...
local Loot = Core:Lib('Loot')
local _E = Core:Lib('Event')
local _F = Core:Lib('Frame')
function Loot:All()
    for slot = GetNumLootItems(), 1, -1 do
        LootSlot(slot)
    end
end
function Loot:isAuto(toggle)
    return GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE");
end
function Loot:Toggle(isAutoLoot)
    LootFrame:SetParent(isAutoLoot and _F.HIDDEN or UIParent)
    return isAutoLoot
end
_E:AddListener('LOOT_READY', function(isAuto)
    if not Loot.isOpened then 
        Loot:Toggle(Loot:isAuto())
    elseif Loot:isAuto() then
        Loot.isOpened = false
    end;
end)
_E:AddListener('LOOT_OPENED', function(isAuto, isFromItem)
    Loot.isOpened = true
end)
_E:AddListener('LOOT_CLOSED', function(...)
    Loot.isOpened = false
end)