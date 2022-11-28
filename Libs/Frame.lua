local ADDON_NAME, Core = ...
local Frame = Core:Lib('Frame');
function Frame:Movable(frame)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self, button)
        frame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        frame:StopMovingOrSizing()
    end)
end
function Frame:Closable(frame)
    local close = CreateFrame('Button', nil, frame, 'UIPanelCloseButtonNoScripts')
    close:SetScript('OnClick', function() frame:Hide() end)
    return close
end

Frame.HIDDEN = CreateFrame('Frame');
Frame.HIDDEN:Hide();
local Secure = CreateFrame("FRAME", nil, nil, "SecureHandlerBaseTemplate")
function Frame:SecureSetID(frame, id)
    if frame:GetID() == id then return end;
    Secure:SetFrameRef("frame", frame)
    Secure:Execute(string.format("self:GetFrameRef('frame'):SetID(%d)",id))
end