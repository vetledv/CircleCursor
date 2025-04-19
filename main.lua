local addon, ns = ...

local CircleCursor = ns.CircleCursor or {}

CircleCursor.defaults = { size = 32 }

local defaults = CircleCursor.defaults

local frame

local config = CreateFrame("Frame")

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

function config:loadSettings()
    if not CircleCursorDB then CircleCursorDB = {} end
    for key, value in pairs(defaults) do
        if CircleCursorDB[key] == nil then
            CircleCursorDB[key] = value
        end
    end
end

function config:HookFrameVisibility(target)
    if not target then return end
    target:HookScript("OnShow", function() frame:Hide() end)
    target:HookScript("OnHide", function() frame:Show() end)
end

local function WatchWeakAurasOptions()
    local watcher = CreateFrame("Frame")
    watcher:SetScript("OnUpdate", function(self)
        if WeakAurasOptions then
            config:HookFrameVisibility(WeakAurasOptions)
            self:SetScript("OnUpdate", nil)
            self:Hide()
        end
    end)
end

config:RegisterEvent("ADDON_LOADED")
config:RegisterEvent("PLAYER_ENTERING_WORLD")

function config:ADDON_LOADED(addonName)
    if addonName == addon then
        self:UnregisterEvent("ADDON_LOADED")
        self.ADDON_LOADED = nil

        self:loadSettings()
        CreateCursorFrame()

        self:HookFrameVisibility(GameMenuFrame)
        self:HookFrameVisibility(InterfaceOptionsFrame)

        WatchWeakAurasOptions()
    end
end

function config:PLAYER_ENTERING_WORLD()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self.PLAYER_ENTERING_WORLD = nil

    if CircleCursorDB.size then
        frame:SetSize(CircleCursorDB.size, CircleCursorDB.size)
    end
end

function config:executeCommand(msg)
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

SLASH_CIRCLECURSOR1 = "/cc"
SlashCmdList["CIRCLECURSOR"] = function(msg) config:executeCommand(msg) end

config:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

