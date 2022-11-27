local ADDON_NAME, Core = ...
local _E = Core:Lib('Event')
local _D = Core:Lib('Debug')
local Storage = Core:Lib('Container.Storage')

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    if tooltip == GameTooltip then
        Storage:ShowItemCount(data.id)
        GameTooltip:AddLine('ID:'..data.id)
    end
end)