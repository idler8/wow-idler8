local ADDON_NAME, Core = ...
if not iDB then iDB = {} end
local DB = Core:Lib('DB');
function DB:Filter(key)
   local filter = {}
   if not iDB[key] then iDB[key] = {} end
   function filter:IsFilter(id)
        return iDB[key][id] == 1;
   end
   function filter:Filter(id)
        if not id then return end
        iDB[key][id] = 1
   end
   function filter:UnFilter(id)
        if not id then return end
        iDB[key][id] = nil
   end
   return filter
end
local player, server = UnitFullName('player')
local _, faction = UnitFactionGroup('player')
function DB:Storage(bagID, slotID, itemID, quality)
    -- iDB['Storage'][server][faction][player][bagID][slotID] = {itemID, quality}
end