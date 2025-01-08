-- HpManaRageAware.lua
HpManaRageAware = {}

local frame = CreateFrame("Button", "HpManaRageAwareFrame", UIParent, "BackdropTemplate, SecureActionButtonTemplate")
frame:SetSize(300, 150)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Add blue background
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
frame:SetBackdropColor(0, 0, 1, 1) -- Blue color (RGBA)

frame:RegisterForClicks("AnyUp")
frame:SetAttribute("type", "macro")
frame:SetAttribute("macrotext", "/target player")

local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
nameText:SetPoint("TOP", 0, -10)
nameText:SetText("Player Name")
nameText:SetTextColor(1, 1, 1) -- White color

local levelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
levelText:SetPoint("TOP", 0, -30)
levelText:SetText("Level: 1")
levelText:SetTextColor(1, 1, 1) -- White color

-- Health Bar
local healthBar = CreateFrame("StatusBar", nil, frame)
healthBar:SetSize(250, 20)
healthBar:SetPoint("TOP", 0, -60)
healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
healthBar:SetStatusBarColor(0, 1, 0)

local healthText = healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
healthText:SetPoint("CENTER")
healthText:SetText("Health: 0/0")
healthText:SetTextColor(1, 1, 1) -- White color

-- Mana/Rage Bar
local powerBar = CreateFrame("StatusBar", nil, frame)
powerBar:SetSize(250, 20)
powerBar:SetPoint("TOP", 0, -90)
powerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

local powerText = powerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
powerText:SetPoint("CENTER")
powerText:SetText("Mana: 0/0")
powerText:SetTextColor(1, 1, 1) -- White color

-- Buff Icons
local buffFrame = CreateFrame("Frame", nil, frame)
buffFrame:SetSize(300, 40)
buffFrame:SetPoint("TOP", 0, -120)

local buffIcons = {}

local function UpdateBuffs()
    -- Clear existing buff icons
    for _, icon in ipairs(buffIcons) do
        icon:Hide()
        icon:SetParent(nil)
    end
    buffIcons = {}

    buffFrame:SetSize(300, 40)
    local numBuffs = 0
    local row = 0
    local maxBuffsPerRow = 7

    for i = 1, 40 do
        local name, icon = UnitBuff("player", i)
        if not name then break end
        numBuffs = numBuffs + 1

        local buff = CreateFrame("Frame", nil, buffFrame)
        buff:SetSize(32, 32)
        local xOffset = ((numBuffs - 1) % maxBuffsPerRow) * 36 + 4 * ((numBuffs - 1) % maxBuffsPerRow)
        buff:SetPoint("LEFT", 5 + xOffset, -row * 40)
        
        local buffTexture = buff:CreateTexture(nil, "OVERLAY")
        buffTexture:SetAllPoints()
        buffTexture:SetTexture(icon)

        if not buffTexture:GetTexture() then
            print("Debug: Missing icon for buff: " .. name)
        end

        buff:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetUnitBuff("player", i)
            GameTooltip:Show()
        end)
        buff:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        table.insert(buffIcons, buff)

        if numBuffs % maxBuffsPerRow == 0 then
            row = row + 1
            buffFrame:SetHeight(buffFrame:GetHeight() + 40)
        end
    end

    frame:SetHeight(150 + (row + 1) * 40)
end

local function HideDefaultUI()
    PlayerFrame:Hide()
    BuffFrame:Hide()
    MainMenuBar:Hide()
end

local function ShowDefaultUI()
    PlayerFrame:Show()
    BuffFrame:Show()
    MainMenuBar:Show()
end

local function UpdateStats()
    local health = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")
    local power = UnitPower("player")
    local maxPower = UnitPowerMax("player")
    local powerType, powerToken = UnitPowerType("player")
    local level = UnitLevel("player")
    local playerName = UnitName("player")

    healthBar:SetMinMaxValues(0, maxHealth)
    healthBar:SetValue(health)
    healthText:SetText("Health: " .. health .. "/" .. maxHealth)

    nameText:SetText(playerName)
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

    -- Update Buffs
    UpdateBuffs()
end

frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_XP_UPDATE") -- Add this event to track level progression
frame:RegisterEvent("UNIT_AURA") -- Track buffs
frame:SetScript("OnEvent", function(self, event, arg1)
    UpdateStats() -- Call UpdateStats for all relevant events
    HideDefaultUI() -- Hide the default UI elements
end)

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "HpManaRageAware" then
        HideDefaultUI() -- Hide default UI elements when the addon is loaded
    elseif event == "PLAYER_LOGOUT" then
        ShowDefaultUI() -- Show default UI elements when the player logs out
    else
        UpdateStats() -- Call UpdateStats for all relevant events
    end
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
