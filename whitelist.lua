-- ============================================================
--  WHITELIST / KEY CHECKER
--  Edit the Keys table below, then run this script.
--  It will validate the key and load the main dash script.
-- ============================================================

-- ==================== CONFIGURATION ====================
local Keys = {
    -- ["your-key-string"] = { username = "RobloxUsername", duration = "1h" }
    -- duration can be "lifetime", "1h", "1d", "30m", etc.
    ["123"] = {
        username = "ClaysRetake",
        duration = "lifetime",
    },
    ["XYZ-789"] = {
        username = "Friend1",
        duration = "1h",
    },
    -- Add more keys here
}

-- Where to get the main script? 
-- Option A: from a remote URL (recommended – edit this link)
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/DashMain.lua"
-- Option B: embed the main script as a string (see the large block below)
-- If you use the URL, the string below is ignored.
-- ======================================================

-- ==================== HELPER FUNCTIONS ====================
local function parseDuration(str)
    if str == "lifetime" then return math.huge end
    local num = tonumber(str:match("%d+"))
    local unit = str:match("[a-zA-Z]+")
    if not num or not unit then return nil end
    unit = unit:lower()
    if unit == "s" then return num
    elseif unit == "m" then return num * 60
    elseif unit == "h" then return num * 3600
    elseif unit == "d" then return num * 86400
    else return nil end
end

-- ==================== KEY ENTRY POP-UP ====================
local player = game.Players.LocalPlayer

local keyGui = Instance.new("ScreenGui")
keyGui.Name = "KeyEntryGui"
keyGui.ResetOnSpawn = false
keyGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 120)
frame.Position = UDim2.new(0.5, -150, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BorderSizePixel = 0
frame.Parent = keyGui
Instance.new("UICorner").Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0, 30)
label.Position = UDim2.new(0, 0, 0, 5)
label.BackgroundTransparency = 1
label.Text = "Enter your key:"
label.TextColor3 = Color3.new(1,1,1)
label.Font = Enum.Font.GothamBold
label.TextSize = 16
label.Parent = frame

local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -40, 0, 30)
box.Position = UDim2.new(0, 20, 0, 35)
box.BackgroundColor3 = Color3.fromRGB(50,50,55)
box.TextColor3 = Color3.new(1,1,1)
box.Font = Enum.Font.GothamMedium
box.TextSize = 14
box.PlaceholderText = "Paste key here..."
box.ClearTextOnFocus = false
box.Parent = frame
Instance.new("UICorner").Parent = box

local submit = Instance.new("TextButton")
submit.Size = UDim2.new(0, 80, 0, 30)
submit.Position = UDim2.new(0.5, -40, 0, 75)
submit.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
submit.Text = "Unlock"
submit.TextColor3 = Color3.new(1,1,1)
submit.Font = Enum.Font.GothamBold
submit.TextSize = 14
submit.Parent = frame
Instance.new("UICorner").Parent = submit

-- Wait for click
local keyEntered = false
local enteredKey = ""
submit.MouseButton1Click:Connect(function()
    enteredKey = box.Text
    keyEntered = true
end)

repeat task.wait() until keyEntered
keyGui:Destroy()

-- ==================== VALIDATE KEY ====================
local keyData = Keys[enteredKey]
if not keyData then
    warn("❌ Invalid key.")
    return
end

if keyData.username ~= player.Name then
    warn("❌ This key is not assigned to your username.")
    return
end

local seconds = parseDuration(keyData.duration)
if seconds == nil then
    warn("❌ Invalid duration in key data.")
    return
end

-- Expiry check (session‑based)
if seconds ~= math.huge then
    if not validateKey._startTimes then validateKey._startTimes = {} end
    local start = validateKey._startTimes[enteredKey]
    if not start then
        start = os.time()
        validateKey._startTimes[enteredKey] = start
    end
    if (os.time() - start) >= seconds then
        warn("❌ Your key has expired.")
        return
    end
end

print("✅ Key accepted – Loading main dash script...")

-- ==================== LOAD MAIN SCRIPT ====================
local mainScript

-- Option 1: Fetch from URL (recommended)
if MAIN_SCRIPT_URL and MAIN_SCRIPT_URL ~= "" then
    local success, result = pcall(function()
        return game:HttpGet(MAIN_SCRIPT_URL)
    end)
    if success and result then
        mainScript = result
        print("📥 Main script fetched from URL.")
    else
        warn("⚠️ Failed to fetch from URL, falling back to embedded script.")
    end
end

-- Option 2: Embedded fallback (copy your main script here as a string)
if not mainScript then
    mainScript = [[
-- ============================================================
--  MAIN DASH SCRIPT (embedded fallback)
--  Replace this with your actual dash code if you're not using a URL.
-- ============================================================
local _call5 = game:GetService('UserInputService')
game:GetService('VirtualInputManager')
local _LocalPlayer10 = game:GetService('Players').LocalPlayer

_call5.InputBegan:Connect(function() end)

local _call16 = _LocalPlayer10:WaitForChild('PlayerGui')
local existing = _call16:FindFirstChild('DashGui')
if existing then existing:Destroy() end

local _call22 = Instance.new('ScreenGui')
_call22.Name = 'DashGui'
_call22.ResetOnSpawn = false
_call22.IgnoreGuiInset = true
_call22.Parent = _call16

local _call24 = Instance.new('Frame')
_call24.Name = 'Container'
_call24.Size = UDim2.new(0, 140, 0, 125)
_call24.Position = UDim2.new(1, -160, 1, -145)
_call24.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
_call24.BackgroundTransparency = 0.15
_call24.BorderSizePixel = 0
_call24.Active = true
_call24.Parent = _call22

local _call32 = Instance.new('UICorner')
_call32.CornerRadius = UDim.new(0, 8)
_call32.Parent = _call24

_call24.InputBegan:Connect(function() end)
_call24.InputChanged:Connect(function() end)
_call5.InputChanged:Connect(function() end)

local _call64 = Instance.new('TextLabel')
_call64.Name = 'Title'
_call64.Size = UDim2.new(1, 0, 0, 20)
_call64.Position = UDim2.new(0, 0, 0, 4)
_call64.BackgroundTransparency = 1
_call64.Text = 'DASH'
_call64.TextColor3 = Color3.fromRGB(255, 255, 255)
_call64.Font = Enum.Font.GothamBold
_call64.TextSize = 14
_call64.Parent = _call24

local _call74 = Instance.new('TextButton')
_call74.Name = 'DashRButton'
_call74.Size = UDim2.new(1, -16, 0, 28)
_call74.Position = UDim2.new(0, 8, 0, 28)
_call74.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
_call74.Text = 'Dash (R)'
_call74.TextColor3 = Color3.fromRGB(255, 255, 255)
_call74.Font = Enum.Font.GothamMedium
_call74.TextSize = 13
_call74.AutoButtonColor = true
_call74.Parent = _call24

local _call86 = Instance.new('UICorner')
_call86.CornerRadius = UDim.new(0, 6)
_call86.Parent = _call74

_call74.MouseButton1Click:Connect(function()
    local char = _LocalPlayer10.Character
    if not char then return end
    local root = char:WaitForChild('HumanoidRootPart')
    local humanoid = char:FindFirstChildOfClass('Humanoid')
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass('Animator')
    local anim = Instance.new('Animation')
    anim.AnimationId = 'rbxassetid://10480793962'
    if animator then
        animator:LoadAnimation(anim):Play()
    end
    local startPos = root.Position
    game:GetService('RunService').RenderStepped:Connect(function()
        if not root or not root.Parent then return end
        local newPos = startPos:Lerp((startPos + (root.CFrame.RightVector * 28)), 0.00490381478567492)
        root.CFrame = CFrame.new(newPos, (newPos + root.CFrame.LookVector))
    end)
end)

local _call127 = Instance.new('TextButton')
_call127.Name = 'DashTButton'
_call127.Size = UDim2.new(1, -16, 0, 28)
_call127.Position = UDim2.new(0, 8, 0, 60)
_call127.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
_call127.Text = 'Dash Jump (T)'
_call127.TextColor3 = Color3.fromRGB(255, 255, 255)
_call127.Font = Enum.Font.GothamMedium
_call127.TextSize = 13
_call127.AutoButtonColor = true
_call127.Parent = _call24
Instance.new('UICorner').Parent = _call127
_call127.MouseButton1Click:Connect(function() end)

local _call147 = Instance.new('TextButton')
_call147.Name = 'AutoRotateToggle'
_call147.Size = UDim2.new(1, -16, 0, 28)
_call147.Position = UDim2.new(0, 8, 0, 92)
_call147.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
_call147.Text = 'Auto Rotate'
_call147.TextColor3 = Color3.fromRGB(255, 255, 255)
_call147.Font = Enum.Font.GothamMedium
_call147.TextSize = 13
_call147.AutoButtonColor = false
_call147.Parent = _call24
Instance.new('UICorner').Parent = _call147

_call147.MouseButton1Click:Connect(function()
    _call147.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
end)

_LocalPlayer10.CharacterAdded:Connect(function()
    task.wait(1)
    _LocalPlayer10.PlayerGui:FindFirstChild('DashGui')
end)

print("🎮 Dash GUI loaded successfully!")
]]
end

-- Execute the main script
if mainScript then
    loadstring(mainScript)()
else
    warn("❌ No main script available to load.")
end
