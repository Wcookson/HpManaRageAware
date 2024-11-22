-- HpManaRageAware.lua
HpManaRageAware = {}

local frame = CreateFrame("Frame", "HpManaRageAwareFrame", UIParent, "BackdropTemplate")
frame:SetSize(300, 150)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Add blue background
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
frame:SetBackdropColor(0, 0, 1, 1) -- Blue color (RGBA)

local levelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
levelText:SetPoint("TOP", 0, -10)
levelText:SetText("Level: 1")

-- Health Bar
local healthBar = CreateFrame("StatusBar", nil, frame)
healthBar:SetSize(250, 20)
healthBar:SetPoint("TOP", 0, -40)
healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
healthBar:SetStatusBarColor(0, 1, 0)

local healthText = healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
healthText:SetPoint("CENTER")
healthText:SetText("Health: 0/0")

-- Mana/Rage Bar
local powerBar = CreateFrame("StatusBar", nil, frame)
powerBar:SetSize(250, 20)
powerBar:SetPoint("TOP", 0, -70)
powerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

local powerText = powerBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
powerText:SetPoint("CENTER")
powerText:SetText("Mana: 0/0")

local function UpdateStats()
    local health = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")
    local power = UnitPower("player")
    local maxPower = UnitPowerMax("player")
    local powerType, powerToken = UnitPowerType("player")
    local level = UnitLevel("player")

    healthBar:SetMinMaxValues(0, maxHealth)
    healthBar:SetValue(health)
    healthText:SetText("Health: " .. health .. "/" .. maxHealth)

    levelText:SetText("Level: " .. level)

    powerBar:SetMinMaxValues(0, maxPower)
    powerBar:SetValue(power)
    powerText:SetText(powerToken .. ": " .. power .. "/" .. maxPower)

    if powerType == 0 then -- Mana
        powerBar:SetStatusBarColor(0, 0, 1)
    elseif powerType == 1 then -- Rage
        powerBar:SetStatusBarColor(1, 0, 0)
    elseif powerType == 3 then -- Energy
        powerBar:SetStatusBarColor(1, 1, 0)
    end
end

frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_XP_UPDATE") -- Add this event to track level progression
frame:SetScript("OnEvent", function(self, event, arg1)
    UpdateStats() -- Call UpdateStats for all relevant events
end)

-- Make the frame movable
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Create a resize handle
local resizeHandle = CreateFrame("Frame", nil, frame)
resizeHandle:SetSize(16, 16)
resizeHandle:SetPoint("BOTTOMRIGHT")
resizeHandle:EnableMouse(true)
resizeHandle:SetScript("OnMouseDown", function(self)
    frame:StartSizing("BOTTOMRIGHT")
end)
resizeHandle:SetScript("OnMouseUp", function(self)
    frame:StopMovingOrSizing()
end)
resizeHandle:SetBackdrop({
    bgFile = "Interface\\Buttons\\UI-Panel-MinimizeButton-Down",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16
})

SLASH_HPMANARAGEAWARE1 = '/hpmr'
function SlashCmdList.HPMANARAGEAWARE(msg, editbox)
    local level = UnitLevel("player")
    print("Current Level: " .. level)
end

-- Initialize the level text and stats when the addon is loaded
UpdateStats()
