local ADDON_NAME, Core = ...
local Debug = Core:Lib('Debug');
function Debug:version() print(GetBuildInfo()) end
function Debug:replace(domain, name, hook)
	local original = domain and domain[name]
	if original then
		domain[name] = function(...)
			if hook(...) then return original(...)end
		end
	end
end

local MISC = 0
local CLOTH = 1
local LEATHER = 2
local MAIL = 3
local PLATE = 4
local COSMETIC = 5

local classArmorTypeMap = {
    ["DEATHKNIGHT"] = PLATE,
    ["DEMONHUNTER"] = LEATHER,
    ["DRUID"] = LEATHER,
    ["HUNTER"] = MAIL,
    ["MAGE"] = CLOTH,
    ["MONK"] = LEATHER,
    ["PALADIN"] = PLATE,
    ["PRIEST"] = CLOTH,
    ["ROGUE"] = LEATHER,
    ["SHAMAN"] = MAIL,
    ["WARLOCK"] = CLOTH,
    ["WARRIOR"] = PLATE,
}
function Debug:ArmorType(className)
    className = className or select(2,UnitClass('player'))
    return classArmorTypeMap[className]
end

SLASH_IDLER1 = "/idler"
SlashCmdList["IDLER"] = function(msg)
end