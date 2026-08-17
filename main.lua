-- dash.lua (main script)
-- Load this with: loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/dash.lua"))()

-- ===== CONFIGURATION =====
local WHITELIST_URL = "https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/whitelist.lua"  -- URL to your whitelist script

-- ===== LOAD WHITELIST =====
local function fetchWhitelist()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(WHITELIST_URL))()
    end)
    if success and type(result) == "table" then
        return result
    else
        warn("Failed to load whitelist. Running with no restrictions.")
        return nil  -- fallback: allow all (or change to an empty table to block all)
    end
end

local whitelistData = fetchWhitelist() or {}

-- ===== CHECK PLAYER =====
local player = game:GetService("Players").LocalPlayer
local playerName = player.Name

local function parseExpiry(expiryStr)
    if expiryStr == "lifetime" then
        return math.huge
    end
    local num = tonumber(expiryStr:match("%d+"))
    local unit = expiryStr:match("%a+")
    if not num or not unit then return 0 end
    local seconds = 0
    if unit:lower():sub(1,1) == "h" then
        seconds = num * 3600
    elseif unit:lower():sub(1,1) == "d" then
        seconds = num * 86400
    else
        seconds = 0
    end
    return os.time() + seconds
end

local function isWhitelisted()
    local entry = whitelistData[playerName]
    if not entry then return false end
    local expiryTime = parseExpiry(entry.expiry)
    return os.time() <= expiryTime
end

local whitelisted = isWhitelisted()

if not whitelisted then
    -- Show a simple notification and stop
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AccessDenied"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 300, 0, 50)
    label.Position = UDim2.new(0.5, -150, 0.5, -25)
    label.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.Text = "❌ Access Denied – Not whitelisted"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.Parent = screenGui
    return  -- stop execution
end

-- ===== ORIGINAL DASH SCRIPT (unchanged below) =====
-- All original code goes here, with the only change being that we've already validated the player.
-- Since we returned early if not whitelisted, the rest runs only for whitelisted users.

-- (Copy the entire original script from your file, starting from "local Players = game:GetService("Players")" etc.)
-- I'll include it for completeness, but you can just paste your existing code after this point.

-- ===== START ORIGINAL CODE =====
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

local DASH_ANIMATION_ID = "rbxassetid://10480793962"

local DASH_DISTANCE = 28
local DASH_TIME = 0.24

local JUMP_DASH_DISTANCE = 52
local JUMP_DASH_TIME = 0.65
local JUMP_HEIGHT = 6

local busy = false
local autoRotate = false

local function getCharacter()
    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    return character
end

local function getRootPart()
    local character = getCharacter()
    return character:WaitForChild("HumanoidRootPart")
end

local function playDashAnimation(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local animation = Instance.new("Animation")
    animation.AnimationId = DASH_ANIMATION_ID
    local success, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)
    animation:Destroy()
    if not success then
        warn("Could not load dash animation:", track)
        return nil
    end
    track:Play()
    return track
end

local function pressQ()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
end

local function dash()
    if busy then return end
    busy = true
    local character = getCharacter()
    local root = getRootPart()
    playDashAnimation(character)
    local startPosition = root.Position
    local targetPosition = startPosition + root.CFrame.RightVector * DASH_DISTANCE
    local startTime = os.clock()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not root or not root.Parent then
            connection:Disconnect()
            busy = false
            return
        end
        local elapsed = os.clock() - startTime
        local alpha = math.clamp(elapsed / DASH_TIME, 0, 1)
        local easedAlpha = 1 - (1 - alpha) ^ 2
        local newPosition = startPosition:Lerp(targetPosition, easedAlpha)
        root.CFrame = CFrame.new(newPosition, newPosition + root.CFrame.LookVector)
        if alpha >= 1 then
            connection:Disconnect()
            pressQ()
            busy = false
        end
    end)
end

local function dashJump()
    if busy then return end
    busy = true
    local character = getCharacter()
    local root = getRootPart()
    playDashAnimation(character)
    if autoRotate then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.pi / 2, 0)
        local camera = workspace.CurrentCamera
        if camera then
            camera.CFrame = camera.CFrame * CFrame.Angles(0, math.pi / 2, 0)
        end
        task.wait(0.05)
    end
    local startPosition = root.Position
    local targetPosition = startPosition + root.CFrame.RightVector * JUMP_DASH_DISTANCE
    local startTime = os.clock()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not root or not root.Parent then
            connection:Disconnect()
            busy = false
            return
        end
        local elapsed = os.clock() - startTime
        local alpha = math.clamp(elapsed / JUMP_DASH_TIME, 0, 1)
        local easedAlpha = 1 - (1 - alpha) ^ 2
        local newPosition = startPosition:Lerp(targetPosition, easedAlpha)
            + Vector3.new(0, math.sin(alpha * math.pi) * JUMP_HEIGHT, 0)
        root.CFrame = CFrame.new(newPosition, newPosition + root.CFrame.LookVector)
        if alpha >= 1 then
            connection:Disconnect()
            busy = false
        end
    end)
end

-- Keyboard controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        dash()
    elseif input.KeyCode == Enum.KeyCode.T then
        dashJump()
    end
end)

-- GUI creation (unchanged)
local function makeButton(parent, name, text, yPosition, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -16, 0, 28)
    button.Position = UDim2.new(0, 8, 0, yPosition)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.AutoButtonColor = true
    button.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    button.MouseButton1Click:Connect(callback)
    return button
end

local function makeToggle(parent, name, text, yPosition)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -16, 0, 28)
    button.Position = UDim2.new(0, 8, 0, yPosition)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.AutoButtonColor = false
    button.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    button.MouseButton1Click:Connect(function()
        autoRotate = not autoRotate
        if autoRotate then
            button.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
        else
            button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end
    end)
    return button
end

local function makeDraggable(frame)
    local dragging = false
    local dragStart
    local startPosition
    local dragInput
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

local function createGui()
    local playerGui = player:WaitForChild("PlayerGui")
    local existing = playerGui:FindFirstChild("DashGui")
    if existing then existing:Destroy() end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DashGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 140, 0, 125)
    container.Position = UDim2.new(1, -160, 1, -145)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    container.BackgroundTransparency = 0.15
    container.BorderSizePixel = 0
    container.Active = true
    container.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    makeDraggable(container)
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "DASH"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = container
    makeButton(container, "DashRButton", "Dash (R)", 28, dash)
    makeButton(container, "DashTButton", "Dash Jump (T)", 60, dashJump)
    makeToggle(container, "AutoRotateToggle", "Auto Rotate", 92)
    return screenGui
end

-- Initial GUI
createGui()

-- Recreate GUI after respawn
player.CharacterAdded:Connect(function()
    task.wait(1)
    local playerGui = player:WaitForChild("PlayerGui")
    if not playerGui:FindFirstChild("DashGui") then
        createGui()
    end
end)
