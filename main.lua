-- ==========================================
-- GITHUB AUTHENTICATION & KEY SYSTEM (NO BYPASS)
-- ==========================================
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local GITHUB_WHITELIST_URL = "https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/whitelist.lua"
local GITHUB_MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/main.lua"

-- Fetch Whitelist Data
local success, whitelistData = pcall(function()
    return loadstring(game:HttpGet(GITHUB_WHITELIST_URL))()
end)

if not success or not whitelistData then
    player:Kick("Authentication Error: Failed to connect to whitelist server.")
    return
end

-- Key Input UI (Everyone must enter a key)
local playerGui = player:WaitForChild("PlayerGui")
local authGui = Instance.new("ScreenGui")
authGui.Name = "AuthGui"
authGui.ResetOnSpawn = false
authGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 140)
frame.Position = UDim2.new(0.5, -130, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = authGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Enter Your Key"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 35)
textBox.Position = UDim2.new(0, 10, 0, 40)
textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderText = "Type your password here..."
textBox.Text = ""
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 13
textBox.Parent = frame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = textBox

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(1, -20, 0, 35)
submitBtn.Position = UDim2.new(0, 10, 0, 85)
submitBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.Text = "Verify Key"
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 13
submitBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = submitBtn

local verified = false
local activeKeyData = nil

submitBtn.MouseButton1Click:Connect(function()
    local inputKey = textBox.Text
    local keyData = whitelistData.Keys and whitelistData.Keys[inputKey]

    if not keyData then
        textBox.Text = "Invalid Key!"
        task.wait(1)
        textBox.Text = ""
        return
    end

    if keyData.type == "lifetime" then
        verified = true
        activeKeyData = keyData
        authGui:Destroy()
    else
        local currentTime = os.time()
        if currentTime < keyData.expires then
            verified = true
            activeKeyData = keyData
            authGui:Destroy()
        else
            textBox.Text = "Key Expired!"
            task.wait(1)
            textBox.Text = ""
        end
    end
end)

repeat task.wait(0.1) until verified or not authGui.Parent
if not verified then return end

-- Create Live Timer UI for 1h or 1d keys
if activeKeyData and activeKeyData.type ~= "lifetime" then
    local timerGui = Instance.new("ScreenGui")
    timerGui.Name = "KeyTimerGui"
    timerGui.ResetOnSpawn = false
    timerGui.Parent = playerGui

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(0, 180, 0, 30)
    timerLabel.Position = UDim2.new(0.5, -90, 0, 10)
    timerLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    timerLabel.BackgroundTransparency = 0.3
    timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timerLabel.Font = Enum.Font.GothamBold
    timerLabel.TextSize = 12
    timerLabel.Parent = timerGui

    local timerCorner = Instance.new("UICorner")
    timerCorner.CornerRadius = UDim.new(0, 6)
    timerCorner.Parent = timerLabel

    task.spawn(function()
        while timerGui.Parent do
            local timeLeft = activeKeyData.expires - os.time()
            if timeLeft <= 0 then
                timerLabel.Text = "Key Expired!"
                task.wait(2)
                game:Shutdown()
                break
            else
                local hours = math.floor(timeLeft / 3600)
                local minutes = math.floor((timeLeft % 3600) / 60)
                local seconds = timeLeft % 60
                timerLabel.Text = string.format("Key Expires: %02d:%02d:%02d", hours, minutes, seconds)
            end
            task.wait(1)
        end
    end)
end

-- Load your main dash script from GitHub once verified
local mainSuccess, mainScript = pcall(function()
    return game:HttpGet(GITHUB_MAIN_SCRIPT_URL)
end)

if mainSuccess then
    loadstring(mainScript)()
else
    warn("Failed to load main script from GitHub.")
end
