local ADDON_NAME, Core = ...
local anySteps2 = [[
  return print('---',player);
]];

local PetBattles = Core:Lib('PetBattles')
function PetBattles:AutoRunning()
    print('--', C_PetBattles.IsInBattle(), C_PetBattles.GetBattleState(), C_PetBattles.GetSelectedAction())
    if not C_PetBattles.IsInBattle() then return end;
    local selectedActionType, selectedActionIndex = C_PetBattles.GetSelectedAction()
    if selectedActionType then return end;
    if not PetBattles.env then PetBattles.env = PetBattles:GetEnviroment() end
    local func = loadstring(anySteps2)
    setfenv(func, PetBattles.env)
    print(func())
end

local AutoButton = CreateFrame('Button', '_F_PetBattles_Auto')
AutoButton:SetScript('OnClick', function()
    PetBattles:AutoRunning();
end)
local _E = Core:Lib('Event');
SetOverrideBindingClick(AutoButton, true, '-', '_F_PetBattles_Auto')
_E:AddListener('PET_BATTLE_OPENING_DONE', function()
  print('PET_BATTLE_OPENING_DONE')
    SetOverrideBindingClick(AutoButton, true, '-', '_F_PetBattles_Auto')
end)
_E:AddListener('PET_BATTLE_OVER', function()
    ClearOverrideBindings(AutoButton)
end)