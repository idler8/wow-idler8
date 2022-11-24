local ADDON_NAME, Core = ...
local Event = Core:Lib('Event');
local frame = CreateFrame("Frame")
local events = {};
function Event:AddListener(event, callback, once)
    if not events[event] then
        frame:RegisterEvent(event);
        events[event] = {};
    end
    table.insert(events[event], callback);
end
function Event:DelListener(event, callback)
    if not events[event] then return end;
    for i = #events[event], 1, -1 do
        if events[event][i] == callback then
            table.remove(events[event], i);
        end
    end
    if #events[event] == 0 then
        frame:UnregisterEvent(event);
        events[event] = nil
    end;
end
function Event:OnceListener(event, callback)
    local function fn(...)
        callback(...)
        self:DelListener(event, fn)
    end
    self:AddListener(event, fn, true)
end
function Event:Call(event, ...)
    if not events[event] then return end;
    for i = 1, #events[event] do
        events[event][i](...)
    end
end
frame:SetScript("OnEvent", function(self, event, ...)
    Event:Call(event, ...);
end)


-- local _E = Event
-- print('ADDON_RUNING')
-- _E:AddListener('BAG_UPDATE', function(...) print('BAG_UPDATE', ...); end)
-- _E:AddListener('BAG_UPDATE_DELAYED', function(...) print('BAG_UPDATE_DELAYED', ...); end)
-- _E:AddListener('BAG_UPDATE_COOLDOWN', function(...) print('BAG_UPDATE_COOLDOWN', ...); end)
-- _E:AddListener('SPELLS_CHANGED', function(...) print('SPELLS_CHANGED', ...); end)
-- _E:AddListener('PLAYER_ENTERING_WORLD', function(...) print('PLAYER_ENTERING_WORLD', ...); end)
-- _E:AddListener('PLAYER_REGEN_DISABLED', function(...) print('PLAYER_REGEN_DISABLED', ...); end)
-- _E:AddListener('PLAYER_REGEN_ENABLED', function(...) print('PLAYER_REGEN_ENABLED', ...); end)
-- _E:AddListener('PLAYERBANKBAGSLOTS_CHANGED', function(...) print('PLAYERBANKBAGSLOTS_CHANGED', ...); end)
-- _E:AddListener('REAGENTBANK_UPDATE', function(...) print('REAGENTBANK_UPDATE', ...); end)
-- _E:AddListener('PLAYERBANKSLOTS_CHANGED', function(...) print('PLAYERBANKSLOTS_CHANGED', ...); end)
-- _E:AddListener('PLAYERREAGENTBANKSLOTS_CHANGED', function(...) print('PLAYERREAGENTBANKSLOTS_CHANGED', ...); end)

-- _E:AddListener('BAG_NEW_ITEMS_UPDATED', function(...) print('BAG_NEW_ITEMS_UPDATED', ...); end)
-- _E:AddListener('BAG_OVERFLOW_WITH_FULL_INVENTORY', function(...) print('BAG_OVERFLOW_WITH_FULL_INVENTORY', ...); end)
-- _E:AddListener('BAG_SLOT_FLAGS_UPDATED', function(...) print('BAG_SLOT_FLAGS_UPDATED', ...); end)
-- _E:AddListener('EQUIP_BIND_REFUNDABLE_CONFIRM', function(...) print('EQUIP_BIND_REFUNDABLE_CONFIRM', ...); end)
-- _E:AddListener('EQUIP_BIND_TRADEABLE_CONFIRM', function(...) print('EQUIP_BIND_TRADEABLE_CONFIRM', ...); end)
-- _E:AddListener('INVENTORY_SEARCH_UPDATE', function(...) print('INVENTORY_SEARCH_UPDATE', ...); end)