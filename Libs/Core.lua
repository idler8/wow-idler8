local ADDON_NAME, Core = ...
local Modules = {};
local function CreateModule(name)
    local Module = {};
    Modules[name] = Module
    return Module
end
function Core:Lib(name)
    return Modules[name] or CreateModule(name)
end
_G.iCore = Core;