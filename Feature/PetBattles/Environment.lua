local ADDON_NAME, Core = ...
local PetBattles = Core:Lib('PetBattles')
local freeze = function() return end
local function getRolePetValuePercent(petOwner, petIndex, stateID)
    return setmetatable({}, {
        __newindex = freeze,
        -- hp(40)/hpp(40), 属性值百分比
        __call = function(self, percent)
            return math.floor(C_PetBattles.GetStateValue(petOwner, petIndex, stateID) * percent / 100);
        end,
        -- hp/hpp 属性值
        __tostring = function(self)
            return C_PetBattles.GetStateValue(petOwner, petIndex, stateID)
        end
    })
end
local function getRolePetAura(petOwner, petIndex)
    return setmetatable({}, {
        __newindex = freeze,
        -- aura(abilityIndex) 状态存在
        __call = function(self, abilityIndex)
            -- todo 状态剩余回合
        end,
        -- aura 状态总数
        __tostring = function(self, index)
            return C_PetBattles.GetNumAuras(petOwner, petIndex)
        end,
        -- 单个状态
        __index = function(self, auraIndex)
            -- todo 搜索状态
            return C_PetBattles.GetAuraInfo(petOwner, petIndex, auraIndex)
        end
    })
end
local function getRolePetAbility(petOwner, petIndex)
    return setmetatable({}, {
        __newindex = freeze,
        -- ability(abilityIndex) 释放技能
        __call = function(self, abilityIndex)
            -- todo 搜索技能
            if petOwner ~= 1 or petIndex ~= C_PetBattles.GetActivePet(1) then return end
            if not abilityIndex then
                -- todo 下一个可用技能
            end
            return C_PetBattles.UseAbility(abilityIndex)
        end,
        -- ability 可用技能数量
        __tostring = function(self)
            -- todo 可用技能数量
        end,
        __index = function(self, abilityIndex)
            return { C_PetBattles.GetAbilityInfo(petOwner, petIndex, abilityIndex) }
        end
    })
end
local function getRolePet(petOwner, petIndex)
    local theRolePetHealth = getRolePetValuePercent(petOwner, petIndex, 106);
    local theRolePetHp = getRolePetValuePercent(petOwner, petIndex, 105);
    local theRolePetAuras = getRolePetAura(petOwner, petIndex)
    local theRolePetAbilitys = getRolePetAbility(petOwner, petIndex)
    return setmetatable({}, {
        __newindex = freeze,
        -- pet[1]()/pet(1)() 无效操作
        __call = function(self)

        end,
        -- pet[1]/pet(1) 宠物序号
        __tostring = function(self)
            return petIndex
        end,
        __index = function(self, key)
            if key == 'round' then
                return 0
            elseif key == 'hp' then
                return theRolePetHp
            elseif key == 'hpp' then
                return theRolePetHealth
            elseif key == 'aura' then
                return theRolePetAuras
            elseif key == 'ability' then
                return theRolePetAbilitys
            else
                -- todo 属性映射
                return C_PetBattles.GetStateValue(petOwner, petIndex, key)
            end
        end
    })
end
local function getRoleCurrentPet(petOwner)
    local pets = { getRolePet(petOwner, 1), getRolePet(petOwner, 2), getRolePet(petOwner, 3)}
    return setmetatable(pets, {
        __newindex = freeze, 
        -- pet(index) 获取宠物
        __call = function(self, index)
            -- todo 搜索宠物
            return pets[index];
        end,
        -- pet 当前宠物序号
        __tostring = function(self)
            return C_PetBattles.GetActivePet(petOwner)
        end,
        __index = function(self, key)
            if key == 'alive' then 
                -- todo 存活宠物数量
                return 
            end
            return pets[C_PetBattles.GetActivePet(petOwner)][key]
        end
    })
end
local function getRole(petOwner)
    local theRolePet = getRoleCurrentPet(petOwner);
    return setmetatable({}, {
        __newindex = freeze,
        -- player(index) 切换宠物
        __call = function(self, index)
            if petOwner ~= 1 then return end;
            if not index then 
                -- todo 下一个可用宠物
            end;
            C_PetBattles.ChangePet(index)
        end,
        -- player/enemy 当前角色序号
        __tostring = function(self)
            return petOwner
        end,
        __index = function(self, key)
            if key == 'round' then
                return 0
            elseif key == 'pet' then
                return theRolePet
            elseif key == 'hp' then
                return theRolePet.hp
            elseif key == 'hpp' then
                return theRolePet.hpp
            elseif key == 'aura' then
                return theRolePet.aura
            elseif key == 'ability' then
                return theRolePet.ability
            else
                return theRolePet[key]
            end
        end
    })
end

local enviroment = {
    __newindex = freeze,
    __index = function(self, key)
        print('__index',self, key)
        if key == 'round' then
            return 0
        elseif key == 'skip' then
            return C_PetBattles.SkipTurn()
        elseif key == 'trap' then
            return C_PetBattles.UseTrap()
        elseif key == 'end' then
            return C_PetBattles.ForfeitGame()
        elseif key == 'pet' then
            return self.player.pet
        elseif key == 'hp' then
            return self.player.hp
        elseif key == 'hpp' then
            return self.player.hpp
        elseif key == 'aura' then
            return self.player.aura
        elseif key == 'ability' then
            return self.player.ability
        else
            return self.player.pet[key]
        end
    end
}
function PetBattles:GetEnviroment(round)
    return setmetatable({
        player = getRole(1),
        enemy = getRole(2),
        print = _G.print
    }, enviroment)
end
