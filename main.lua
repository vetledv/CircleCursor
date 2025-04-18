local defaults = {
    size = 32,
}

local frame

local function LoadSettings()
    if not CircleCursorDB then CircleCursorDB = {} end
    for key, value in pairs(defaults) do
        if CircleCursorDB[key] == nil then
            CircleCursorDB[key] = value
        end
    end
end

local function CreateCursorFrame()
    frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(CircleCursorDB.size, CircleCursorDB.size)

    frame.texture = frame:CreateTexture(nil, "OVERLAY")
    frame.texture:SetTexture("Interface\\AddOns\\CircleCursor\\assets\\circle.tga")
    frame.texture:SetBlendMode("BLEND")
    frame.texture:SetAlpha(1)
    frame.texture:SetVertexColor(1, 1, 1, 1)
    frame:SetFrameStrata("TOOLTIP")
    frame.texture:SetAllPoints(frame)

    frame:SetScript("OnUpdate", function()
        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    end)
end

local function HookFrameVisibility(target)
    if not target then return end
    target:HookScript("OnShow", function() frame:Hide() end)
    target:HookScript("OnHide", function() frame:Show() end)
end

SLASH_CIRCLECURSOR1 = "/cc"
SlashCmdList["CIRCLECURSOR"] = function(msg)
    local cmd, arg1 = strsplit(" ", msg)
    cmd = cmd:lower()

    if cmd == "size" and tonumber(arg1) then
        CircleCursorDB.size = tonumber(arg1)
        frame:SetSize(CircleCursorDB.size, CircleCursorDB.size)
        print("CircleCursor: size set to", arg1)
    else
        print("/cc size [number] - set size")
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "CircleCursor" then
        LoadSettings()
        CreateCursorFrame()

        HookFrameVisibility(GameMenuFrame)
        HookFrameVisibility(InterfaceOptionsFrame)

        if WeakAurasOptions then
            HookFrameVisibility(WeakAurasOptions)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if WeakAurasOptions then
            HookFrameVisibility(WeakAurasOptions)
        end
    end
end)
