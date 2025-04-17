local defaults = {
    size = 32,
    r = 1,
    g = 1,
    b = 1,
    a = 1,
}

local function LoadSettings()
    if not CircleCursorDB then CircleCursorDB = {} end
    for k, v in pairs(defaults) do
        if CircleCursorDB[k] == nil then
            CircleCursorDB[k] = v
        end
    end
end

LoadSettings()

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetSize(CircleCursorDB.size, CircleCursorDB.size)

frame.texture = frame:CreateTexture(nil, "OVERLAY")
frame.texture:SetTexture("Interface\\AddOns\\CircleCursor\\assets\\circle.tga")
frame.texture:SetBlendMode("BLEND")
frame.texture:SetAlpha(CircleCursorDB.a or defaults.a)
frame.texture:SetVertexColor(CircleCursorDB.r, CircleCursorDB.g, CircleCursorDB.b, CircleCursorDB.a)

frame:SetFrameStrata("TOOLTIP")
frame.texture:SetAllPoints(frame)

frame:SetScript("OnUpdate", function()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
end)

local function HookFrameVisibility(target)
    if not target then return end
    target:HookScript("OnShow", function() frame:Hide() end)
    target:HookScript("OnHide", function() frame:Show() end)
end

HookFrameVisibility(GameMenuFrame)
HookFrameVisibility(InterfaceOptionsFrame)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "WeakAuras" then
        if WeakAurasOptions then
            HookFrameVisibility(WeakAurasOptions)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if WeakAurasOptions then
            HookFrameVisibility(WeakAurasOptions)
        end
    end
end)

SLASH_CIRCLECURSOR1 = "/cc"
SlashCmdList["CIRCLECURSOR"] = function(msg)
    local cmd, arg1, arg2, arg3, arg4 = strsplit(" ", msg)
    cmd = cmd:lower()

    if cmd == "size" and tonumber(arg1) then
        CircleCursorDB.size = tonumber(arg1) or defaults.size
        frame:SetSize(CircleCursorDB.size, CircleCursorDB.size)
        print("CircleCursor: size set to", arg1)
    elseif cmd == "color" and arg1 and arg2 and arg3 then
        local r, g, b, a = tonumber(arg1) or defaults.r, tonumber(arg2) or defaults.g, tonumber(arg3) or defaults.b,
            tonumber(arg4) or defaults.a
        CircleCursorDB.r = r
        CircleCursorDB.g = g
        CircleCursorDB.b = b
        CircleCursorDB.a = a
        frame.texture:SetVertexColor(r, g, b, a)
        print("CircleCursor: color set to", r, g, b, a)
    else
        print("CircleCursor commands:")
        print("/cc size [number] - set size")
        print("/cc color r g b [a] - set color (0-1 values)")
    end
end
