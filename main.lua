-- dash.lua
-- Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/dash.lua"))()

-- ===== CONFIGURATION =====
local WHITELIST_URL = "https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/whitelist.lua"

-- ===== FETCH WHITELIST =====
local function fetchWhitelist()
    local success, data = pcall(function()
        return loadstring(game:HttpGet(WHITELIST_URL))()
    end)
    if success and type(data) == "table" then
        return data
    else
        warn("Failed to load whitelist. Running with no restrictions.")
        return { usernames = {}, keys = {} }  -- fallback: block everyone
    end
end

local whitelist = fetchWhitelist()
local usernames = whitelist.usernames or {}
local keys = whitelist.keys or {}

local player = game:GetService("Players").LocalPlayer
local playerName = player.Name

-- ===== EXPIRY PARSER =====
local function parseExpiry(expiryStr)
    if expiryStr == "lifetime" then return math.huge end
    local num = tonumber(expiryStr:match("%d+"))
    local unit = expiryStr:match("%a+")
    if not num or not unit then return 0 end
    local seconds = 0
    if unit:lower():sub(1,1) == "h" then
        seconds = num * 3600
    elseif unit:lower():sub(1,1) == "d" then
        seconds = num * 86400
    else
        return 0
    end
    return os.time() + seconds
end

-- ===== CHECK DIRECT WHITELIST =====
local function isDirectlyWhitelisted()
    local expiryStr = usernames[playerName]
    if not expiryStr then return false end
    local expiryTime = parseExpiry(expiryStr)
    return os.time() <= expiryTime
end

-- ===== AUTHENTICATION STATE =====
local authenticated = isDirectlyWhitelisted()
local authExpiry = authenticated and parseExpiry(usernames[playerName]) or 0

-- ===== KEY INPUT GUI =====
if not authenticated then
    local UserInputService = game:GetService("UserInputService")
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeySystem"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 120)
    frame.Position = UDim2.new(0.5, -150, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Position = UDim2.new(0, 0, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = "Enter License Key"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.Parent = frame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 200, 0, 30)
    textBox.Position = UDim2.new(0.5, -100, 0, 45)
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.GothamMedium
    textBox.TextSize = 14
    textBox.PlaceholderText = "Enter key"
    textBox.ClearTextOnFocus = false
    textBox.Parent = frame

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0, 80, 0, 30)
    submitBtn.Position = UDim2.new(0.5, -40, 0, 80)
    submitBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
    submitBtn.Text = "Submit"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Enum.Font.GothamMedium
    submitBtn.TextSize = 14
    submitBtn.Parent = frame

    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 4)
    submitCorner.Parent = submitBtn

    -- Response label (hidden initially)
    local response = Instance.new("TextLabel")
    response.Size = UDim2.new(1, 0, 0, 20)
    response.Position = UDim2.new(0, 0, 0, 115)  -- below button
    response.BackgroundTransparency = 1
    response.Text = ""
    response.TextColor3 = Color3.fromRGB(255, 0, 0)
    response.Font = Enum.Font.GothamMedium
    response.TextSize = 12
    response.Parent = frame

    -- Dragging (optional)
    local function makeDraggable(frameObj)
        local dragging = false
        local dragStart, startPos
        frameObj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frameObj.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragStart and dragging then
                local delta = input.Position - dragStart
                frameObj.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    makeDraggable(frame)

    -- Submit logic
    local function tryAuthenticate()
        local key = textBox.Text
        local entry = keys[key]
        if entry then
            local targetUser = entry.username
            if targetUser == playerName then
                local expiryTime = parseExpiry(entry.expiry)
                if os.time() <= expiryTime then
                    authenticated = true
                    authExpiry = expiryTime
                    screenGui:Destroy()
                    -- Continue to load dash
                    loadDash()
                    return
                else
                    response.Text = "Key expired."
                    response.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            else
                response.Text = "Key does not match this username."
                response.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        else
            response.Text = "Invalid key."
            response.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    submitBtn.MouseButton1Click:Connect(tryAuthenticate)
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then tryAuthenticate() end
    end)

    -- Block script until authenticated (or forever if not)
    repeat task.wait() until authenticated
end

-- ===== LOAD DASH FUNCTIONALITY =====
function loadDash()
    -- (The entire original dash script goes here, exactly as you provided it.)
    -- Since you said "don't change it", I paste the original code verbatim below.
    -- Only the top part (authentication) has been added.

    -- ===== ORIGINAL CODE STARTS =====
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

    -- GUI creation
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
    -- ===== ORIGINAL CODE ENDS =====
end

-- If already authenticated (direct whitelist), load dash immediately.
if authenticated then
    loadDash()
end
