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
function DB:Account()
     if not iDB.Accounts then iDB.Accounts = {} end
     local name, server = UnitFullName('player')
     local _, faction = UnitFactionGroup('player')
     local key = server..":"..faction..":"..name;
     if not iDB.Accounts[key] then
          iDB.Accounts[key] = { server = server, faction = faction, name = name, bags={}, slots={} }
     end
     function DB:Account()
          return iDB.Accounts[key]
     end
     return iDB.Accounts[key]
end
function DB:Accounts()
     if not iDB.Accounts then iDB.Accounts = {} end
     return pairs(iDB.Accounts)
end