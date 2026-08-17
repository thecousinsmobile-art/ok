```lua
-- =========================================================
-- DASH SCRIPT + GITHUB WHITELIST
-- =========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- =========================================================
-- CONFIG
-- =========================================================

-- Put the RAW URL of your GitHub whitelist.lua here.
local WHITELIST_URL = "PASTE_YOUR_RAW_GITHUB_WHITELIST_URL_HERE"

local DASH_ANIMATION_ID = "rbxassetid://10480793962"

local DASH_DISTANCE = 28
local DASH_TIME = 0.24

local JUMP_DASH_DISTANCE = 52
local JUMP_DASH_TIME = 0.65
local JUMP_HEIGHT = 6

local busy = false
local autoRotate = false

-- =========================================================
-- WHITELIST
-- =========================================================

local function parseDuration(duration)
    if type(duration) ~= "string" then
        return nil
    end

    duration = duration:lower():gsub("%s+", "")

    if duration == "lifetime" then
        return math.huge
    end

    local amount, unit = duration:match("^(%d+)([smhd])$")

    if not amount or not unit then
        return nil
    end

    amount = tonumber(amount)

    if unit == "s" then
        return amount
    elseif unit == "m" then
        return amount * 60
    elseif unit == "h" then
        return amount * 60 * 60
    elseif unit == "d" then
        return amount * 60 * 60 * 24
    end

    return nil
end

local function getWhitelist()
    local success, source = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)

    if not success then
        warn("Whitelist download failed:", source)
        return nil
    end

    local success2, whitelist = pcall(function()
        return loadstring(source)()
    end)

    if not success2 then
        warn("Whitelist could not be loaded:", whitelist)
        return nil
    end

    if type(whitelist) ~= "table" then
        warn("Whitelist must return a table.")
        return nil
    end

    return whitelist
end

local function checkWhitelist()
    local whitelist = getWhitelist()

    if not whitelist then
        return false, "Whitelist unavailable"
    end

    local entry = whitelist[player.Name]

    if not entry then
        return false, "User not whitelisted"
    end

    if type(entry) ~= "table" then
        return false, "Invalid whitelist entry"
    end

    local key = entry.Key
    local duration = entry.Duration

    if type(key) ~= "string" or key == "" then
        return false, "Invalid key"
    end

    if type(duration) ~= "string" then
        return false, "Invalid duration"
    end

    local seconds = parseDuration(duration)

    if not seconds then
        return false, "Invalid duration"
    end

    -- Key supplied by the whitelist is compared against itself.
    -- Change this section if you later want a key-entry GUI.
    if seconds == math.huge then
        return true, "Lifetime"
    end

    -- Timed licenses require an expiry timestamp.
    --
    -- Example whitelist entry:
    --
    -- ["Player"] = {
    --     Key = "ABC123",
    --     Duration = "1h",
    --     ExpiresAt = 1780000000,
    -- }
    --
    -- This avoids resetting the timer every server restart.

    local expiresAt = entry.ExpiresAt

    if not expiresAt then
        return false, "Timed license has no ExpiresAt"
    end

    if os.time() >= expiresAt then
        return false, "License expired"
    end

    return true, "Active"
end

-- =========================================================
-- WHITELIST CHECK
-- =========================================================

local allowed, whitelistStatus = checkWhitelist()

if not allowed then
    warn("[DASH] Access denied:", whitelistStatus)
    return
end

print("[DASH] Whitelist accepted:", whitelistStatus)

-- =========================================================
-- CHARACTER
-- =========================================================

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

-- =========================================================
-- ANIMATION
-- =========================================================

local function playDashAnimation(character)
    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return nil
    end

    local animator =
        humanoid:FindFirstChildOfClass("Animator")

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

-- =========================================================
-- Q INPUT
-- =========================================================

local function pressQ()
    VirtualInputManager:SendKeyEvent(
        true,
        Enum.KeyCode.Q,
        false,
        game
    )

    task.wait()

    VirtualInputManager:SendKeyEvent(
        false,
        Enum.KeyCode.Q,
        false,
        game
    )
end

-- =========================================================
-- R DASH
-- =========================================================

local function dash()
    if busy then
        return
    end

    busy = true

    local character = getCharacter()
    local root = getRootPart()

    playDashAnimation(character)

    local startPosition = root.Position

    local targetPosition =
        startPosition
        + root.CFrame.RightVector * DASH_DISTANCE

    local startTime = os.clock()

    local connection

    connection = RunService.RenderStepped:Connect(function()
        if not root or not root.Parent then
            connection:Disconnect()
            busy = false
            return
        end

        local elapsed = os.clock() - startTime

        local alpha =
            math.clamp(elapsed / DASH_TIME, 0, 1)

        local easedAlpha =
            1 - (1 - alpha) ^ 2

        local newPosition =
            startPosition:Lerp(
                targetPosition,
                easedAlpha
            )

        root.CFrame = CFrame.new(
            newPosition,
            newPosition + root.CFrame.LookVector
        )

        if alpha >= 1 then
            connection:Disconnect()

            -- R dash finishes.
            -- Then press Q to trigger the forward dash.
            pressQ()

            busy = false
        end
    end)
end

-- =========================================================
-- T DASH JUMP
-- =========================================================

local function dashJump()
    if busy then
        return
    end

    busy = true

    local character = getCharacter()
    local root = getRootPart()

    playDashAnimation(character)

    if autoRotate then
        root.CFrame =
            root.CFrame
            * CFrame.Angles(0, math.pi / 2, 0)

        local camera = workspace.CurrentCamera

        if camera then
            camera.CFrame =
                camera.CFrame
                * CFrame.Angles(0, math.pi / 2, 0)
        end

        task.wait(0.05)
    end

    local startPosition = root.Position

    local targetPosition =
        startPosition
        + root.CFrame.RightVector
        * JUMP_DASH_DISTANCE

    local startTime = os.clock()

    local connection

    connection =
        RunService.RenderStepped:Connect(function()

        if not root or not root.Parent then
            connection:Disconnect()
            busy = false
            return
        end

        local elapsed = os.clock() - startTime

        local alpha =
            math.clamp(
                elapsed / JUMP_DASH_TIME,
                0,
                1
            )

        local easedAlpha =
            1 - (1 - alpha) ^ 2

        local newPosition =
            startPosition:Lerp(
                targetPosition,
                easedAlpha
            )
            + Vector3.new(
                0,
                math.sin(alpha * math.pi)
                    * JUMP_HEIGHT,
                0
            )

        root.CFrame = CFrame.new(
            newPosition,
            newPosition + root.CFrame.LookVector
        )

        if alpha >= 1 then
            connection:Disconnect()
            busy = false
        end
    end)
end

-- =========================================================
-- KEYBOARD
-- =========================================================

UserInputService.InputBegan:Connect(
    function(input, gameProcessed)

        if gameProcessed then
            return
        end

        if input.KeyCode == Enum.KeyCode.R then
            dash()

        elseif input.KeyCode == Enum.KeyCode.T then
            dashJump()
        end
    end
)

-- =========================================================
-- BUTTON
-- =========================================================

local function makeButton(
    parent,
    name,
    text,
    yPosition,
    callback
)

    local button =
        Instance.new("TextButton")

    button.Name = name

    button.Size =
        UDim2.new(1, -16, 0, 28)

    button.Position =
        UDim2.new(0, 8, 0, yPosition)

    button.BackgroundColor3 =
        Color3.fromRGB(45, 45, 55)

    button.Text = text

    button.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    button.Font =
        Enum.Font.GothamMedium

    button.TextSize = 13
    button.AutoButtonColor = true
    button.Parent = parent

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 6)

    corner.Parent = button

    button.MouseButton1Click:Connect(
        callback
    )

    return button
end

-- =========================================================
-- TOGGLE
-- =========================================================

local function makeToggle(
    parent,
    name,
    text,
    yPosition
)

    local button =
        Instance.new("TextButton")

    button.Name = name

    button.Size =
        UDim2.new(1, -16, 0, 28)

    button.Position =
        UDim2.new(0, 8, 0, yPosition)

    button.BackgroundColor3 =
        Color3.fromRGB(45, 45, 55)

    button.Text = text

    button.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    button.Font =
        Enum.Font.GothamMedium

    button.TextSize = 13
    button.AutoButtonColor = false
    button.Parent = parent

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 6)

    corner.Parent = button

    button.MouseButton1Click:Connect(
        function()

        autoRotate = not autoRotate

        if autoRotate then
            button.BackgroundColor3 =
                Color3.fromRGB(60, 120, 60)
        else
            button.BackgroundColor3 =
                Color3.fromRGB(45, 45, 55)
        end
    end)

    return button
end

-- =========================================================
-- DRAGGING
-- =========================================================

local function makeDraggable(frame)

    local dragging = false
    local dragStart
    local startPosition
    local dragInput

    frame.InputBegan:Connect(
        function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = frame.Position

            input.Changed:Connect(
                function()

                if input.UserInputState ==
                    Enum.UserInputState.End then

                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(
        function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(
        function(input)

        if input == dragInput and dragging then

            local delta =
                input.Position - dragStart

            frame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,

                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

-- =========================================================
-- GUI
-- =========================================================

local function createGui()

    local playerGui =
        player:WaitForChild("PlayerGui")

    local existing =
        playerGui:FindFirstChild("DashGui")

    if existing then
        existing:Destroy()
    end

    local screenGui =
        Instance.new("ScreenGui")

    screenGui.Name = "DashGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    local container =
        Instance.new("Frame")

    container.Name = "Container"

    container.Size =
        UDim2.new(0, 140, 0, 125)

    container.Position =
        UDim2.new(1, -160, 1, -145)

    container.BackgroundColor3 =
        Color3.fromRGB(25, 25, 30)

    container.BackgroundTransparency = 0.15
    container.BorderSizePixel = 0
    container.Active = true
    container.Parent = screenGui

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 8)

    corner.Parent = container

    makeDraggable(container)

    local title =
        Instance.new("TextLabel")

    title.Name = "Title"

    title.Size =
        UDim2.new(1, 0, 0, 20)

    title.Position =
        UDim2.new(0, 0, 0, 4)

    title.BackgroundTransparency = 1
    title.Text = "DASH"

    title.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    title.Font =
        Enum.Font.GothamBold

    title.TextSize = 14
    title.Parent = container

    makeButton(
        container,
        "DashRButton",
        "Dash (R)",
        28,
        dash
    )

    makeButton(
        container,
        "DashTButton",
        "Dash Jump (T)",
        60,
        dashJump
    )

    makeToggle(
        container,
        "AutoRotateToggle",
        "Auto Rotate",
        92
    )

    return screenGui
end

-- =========================================================
-- START
-- =========================================================

createGui()

player.CharacterAdded:Connect(
    function()

    task.wait(1)

    local playerGui =
        player:WaitForChild("PlayerGui")

    if not playerGui:FindFirstChild("DashGui") then
        createGui()
    end
end)
```
