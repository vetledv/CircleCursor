local addon, ns = ...

local CircleCursor = ns.CircleCursor or {}

CircleCursor.defaults = { size = 32 }

local defaults = CircleCursor.defaults

local config = CreateFrame("Frame", "CircleCursorEventFrame")

function config:createCursor()
    if self.cursorFrame then return end
    local f = CreateFrame("Frame", nil, UIParent)

    f:SetSize(CircleCursorDB.size, CircleCursorDB.size)
    f.texture = f:CreateTexture(nil, "OVERLAY")
    f.texture:SetTexture("Interface\\AddOns\\CircleCursor\\assets\\circle.tga")
    f.texture:SetBlendMode("BLEND")
    f.texture:SetAlpha(1)
    f.texture:SetVertexColor(1, 1, 1, 1)
    f:SetFrameStrata("TOOLTIP")
    f.texture:SetAllPoints(f)

    f:SetScript("OnUpdate", function()
        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        f:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    end)

    self.cursorFrame = f
end

function config:loadSettings()
    if not CircleCursorDB then CircleCursorDB = {} end
    self.globalDb = CircleCursorDB
    for key, value in pairs(defaults) do
        if CircleCursorDB[key] == nil then
            CircleCursorDB[key] = value
        end
    end
end

function config:HookFrameVisibility(target)
    if not target then return end
    target:HookScript("OnShow", function() self.cursorFrame:Hide() end)
    target:HookScript("OnHide", function() self.cursorFrame:Show() end)
end

function config:ADDON_LOADED(addonName)
    if addonName == addon then
        self:UnregisterEvent("ADDON_LOADED")
        self.ADDON_LOADED = nil

        self:loadSettings()
        self:createCursor()

        self:HookFrameVisibility(GameMenuFrame)
        self:HookFrameVisibility(SettingsPanel)
    end
end

function config:PLAYER_ENTERING_WORLD()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self.PLAYER_ENTERING_WORLD = nil

    if self.globalDb.size then
        self.cursorFrame:SetSize(self.globalDb.size, self.globalDb.size)
    end
end

function config:executeCommand(msg)
    local cmd, arg1 = strsplit(" ", msg)
    cmd = cmd:lower()

    if cmd == "size" then
        self:handleSizeCommand(arg1)
    else
        print("/cc size [number] - set size")
    end
end

function config:handleSizeCommand(sizeArg)
    if sizeArg and tonumber(sizeArg) then
        self.globalDb.size = tonumber(sizeArg)
        self.cursorFrame:SetSize(self.globalDb.size, self.globalDb.size)
        print("CircleCursor: size set to", sizeArg)
    end
end

SLASH_CIRCLECURSOR1 = "/cc"
SlashCmdList["CIRCLECURSOR"] = function(msg) config:executeCommand(msg) end

config:RegisterEvent("ADDON_LOADED")
config:RegisterEvent("PLAYER_ENTERING_WORLD")

config:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)
