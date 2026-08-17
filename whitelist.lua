--[[
    M1 Reset Loader – Friend Whitelist with Durations
    Users enter their password; the script checks username, password, and expiry.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ========== CONFIGURATION ==========
local SCRIPT_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/m1reset_main.lua"  -- CHANGE THIS

-- ========== FRIEND LIST ==========
-- Add your friends here. Each entry:
--   username : their exact Roblox username (case-sensitive)
--   password : the password you give them (case-sensitive)
--   duration : "1h" = 1 hour, "1d" = 1 day, "lifetime" = never expires
local friends = {
    {username = "Friend1", password = "pass123",   duration = "1h"},
    {username = "Friend2", password = "secure456", duration = "1d"},
    {username = "Friend3", password = "lifetime789", duration = "lifetime"},
    -- Add more friends below...
}
-- ====================================

-- Helper: get expiry timestamp from duration string
local function getExpiry(duration)
    if duration == "1h" then
        return os.time() + 3600
    elseif duration == "1d" then
        return os.time() + 86400
    elseif duration == "lifetime" then
        return os.time() + 315360000  -- ≈10 years
    else
        return 0  -- invalid, will expire immediately
    end
end

-- Validate a password against the friend list
local function validatePassword(password)
    if type(password) ~= "string" or #password == 0 then return false end
    for _, friend in ipairs(friends) do
        if friend.password == password then
            -- Check username match
            if friend.username == LocalPlayer.Name then
                -- Compute expiry and check
                local expiry = getExpiry(friend.duration)
                if expiry > os.time() then
                    return true
                else
                    return false, "expired"
                end
            else
                return false, "wrong user"
            end
        end
    end
    return false, "not found"
end

-- ========== PASSWORD INPUT GUI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PasswordEntry"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 120)
mainFrame.Position = UDim2.new(0.5, -150, 0.4, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 200, 200)
stroke.Thickness = 1
stroke.Transparency = 0.5
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Enter Your Password"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = mainFrame

local passBox = Instance.new("TextBox")
passBox.Size = UDim2.new(1, -20, 0, 30)
passBox.Position = UDim2.new(0, 10, 0.5, -15)
passBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
passBox.TextColor3 = Color3.fromRGB(255, 255, 255)
passBox.Font = Enum.Font.Gotham
passBox.TextSize = 14
passBox.PlaceholderText = "Password"
passBox.Parent = mainFrame
local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 8)
boxCorner.Parent = passBox

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0, 100, 0, 30)
submitBtn.Position = UDim2.new(0.5, -50, 1, -45)
submitBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 16
submitBtn.Text = "Submit"
submitBtn.Parent = mainFrame
local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 8)
submitCorner.Parent = submitBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 1, -75)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = mainFrame

-- Parent the GUI
local function parentGUI()
    local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        screenGui.Parent = playerGui
        return true
    end
    local gui = game:GetService("CoreGui") or game:GetService("StarterGui")
    pcall(function() screenGui.Parent = gui end)
    return screenGui.Parent ~= nil
end
parentGUI()

submitBtn.MouseButton1Click:Connect(function()
    local password = passBox.Text
    if #password == 0 then
        statusLabel.Text = "Please enter your password."
        return
    end
    local valid, reason = validatePassword(password)
    if valid then
        statusLabel.Text = "✅ Valid – loading script..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(0.5)
        screenGui:Destroy()

        -- Load main script from GitHub
        local success, result = pcall(function()
            return game:HttpGet(SCRIPT_URL)
        end)
        if success and result then
            local func, err = loadstring(result)
            if func then
                func()
            else
                warn("Failed to compile main script: " .. tostring(err))
            end
        else
            warn("Failed to fetch main script: " .. tostring(result))
        end
    else
        if reason == "expired" then
            statusLabel.Text = "❌ This password has expired."
        elseif reason == "wrong user" then
            statusLabel.Text = "❌ Password not meant for this user."
        else
            statusLabel.Text = "❌ Invalid password."
        end
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

passBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        submitBtn.MouseButton1Click:Fire()
    end
end)
