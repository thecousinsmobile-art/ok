-- dash_and_moveset.lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- Configurations & Keybinds
local config = {
    dashKey = Enum.KeyCode.R,
    dashJumpKey = Enum.KeyCode.T,
    menuKey = Enum.KeyCode.LeftControl,
    customMovesetEnabled = true,
}

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

    if not success then return nil end
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == config.dashKey then
        dash()
    elseif input.KeyCode == config.dashJumpKey then
        dashJump()
    end
end)

-- GUI Elements & Settings Menu Setup
local function makeButton(parent, name, text, yPosition, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -16, 0, 32)
    button.Position = UDim2.new(0, 8, 0, yPosition)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
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

local function makeToggle(parent, name, text, yPosition, initialState, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -16, 0, 32)
    button.Position = UDim2.new(0, 8, 0, yPosition)
    button.BackgroundColor3 = initialState and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(40, 40, 50)
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
        initialState = not initialState
        if initialState then
            button.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
        else
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
        callback(initialState)
    end)
    return button
end

local function makeDraggable(frame)
    local dragging = false
    local dragStart, startPosition, dragInput

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
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
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

    -- Main HUD
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 150, 0, 135)
    container.Position = UDim2.new(1, -170, 1, -155)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.Active = true
    container.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container

    makeDraggable(container)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 22)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "DASH HUD"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.Parent = container

    makeButton(container, "DashRButton", "Dash (" .. config.dashKey.Name .. ")", 30, dash)
    makeButton(container, "DashTButton", "Dash Jump (" .. config.dashJumpKey.Name .. ")", 65, dashJump)
    makeToggle(container, "AutoRotateToggle", "Auto Rotate", 100, autoRotate, function(state)
        autoRotate = state
    end)

    -- Config / Settings Panel (Toggled via Ctrl)
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsMenu"
    settingsFrame.Size = UDim2.new(0, 220, 0, 210)
    settingsFrame.Position = UDim2.new(0.5, -110, 0.5, -105)
    settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    settingsFrame.BackgroundTransparency = 0.05
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Visible = false
    settingsFrame.Active = true
    settingsFrame.Parent = screenGui

    local scCorner = Instance.new("UICorner")
    scCorner.CornerRadius = UDim.new(0, 10)
    scCorner.Parent = settingsFrame

    makeDraggable(settingsFrame)

    local sTitle = Instance.new("TextLabel")
    sTitle.Size = UDim2.new(1, 0, 0, 30)
    sTitle.Position = UDim2.new(0, 0, 0, 5)
    sTitle.BackgroundTransparency = 1
    sTitle.Text = "CONTROL PANEL (CTRL)"
    sTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextSize = 14
    sTitle.Parent = settingsFrame

    -- Keybind Bind Buttons
    local dashKeyButton = makeButton(settingsFrame, "BindDash", "Dash Key: " .. config.dashKey.Name, 40, function()
        dashKeyButton.Text = "Press any key..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                config.dashKey = input.KeyCode
                dashKeyButton.Text = "Dash Key: " .. config.dashKey.Name
                conn:Disconnect()
            end
        end)
    end)

    local dashJumpKeyButton = makeButton(settingsFrame, "BindDashJump", "Jump Key: " .. config.dashJumpKey.Name, 78, function()
        dashJumpKeyButton.Text = "Press any key..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                config.dashJumpKey = input.KeyCode
                dashJumpKeyButton.Text = "Jump Key: " .. config.dashJumpKey.Name
                conn:Disconnect()
            end
        end)
    end)

    makeToggle(settingsFrame, "CustomMovesetToggle", "Custom Moveset", 116, config.customMovesetEnabled, function(state)
        config.customMovesetEnabled = state
    end)

    makeButton(settingsFrame, "CloseMenu", "Close Menu", 160, function()
        settingsFrame.Visible = false
    end)

    -- Toggle settings visibility via Menu Key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == config.menuKey then
            settingsFrame.Visible = not settingsFrame.Visible
        end
    end)

    return screenGui
end

createGui()

player.CharacterAdded:Connect(function()
    task.wait(1)
    local playerGui = player:WaitForChild("PlayerGui")
    if not playerGui:FindFirstChild("DashGui") then
        createGui()
    end
end)

-- Custom Moveset & Hotbar Renamer Loop
task.spawn(function()
    local moveSet = {
        move2 = { animationId = "rbxassetid://10466974800" },
        move3 = { animationId = "rbxassetid://10471336737" }
    }

    local replacementMoveset = {
        move2 = { animationId = "rbxassetid://17799224866", startingTime = 0.56, endingTime = 8.37, speed = 1 },
        move3 = { animationId = "rbxassetid://12309835105", startingTime = 0.3, endingTime = 2.2 }
    }

    local function hookHumanoid(humanoid)
        humanoid.AnimationPlayed:Connect(function(animation)
            if not config.customMovesetEnabled then return end

            for moveName, moveData in pairs(moveSet) do
                if animation.Animation.AnimationId == moveData.animationId then
                    local replacementAnimation = replacementMoveset[moveName]
                    if not replacementAnimation then return end

                    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                        track:Stop()
                    end

                    local anim = Instance.new("Animation")
                    anim.AnimationId = replacementAnimation.animationId
                    local animTrack = humanoid:LoadAnimation(anim)
                    
                    animTrack:Play()
                    animTrack.TimePosition = replacementAnimation.startingTime

                    if replacementAnimation.speed then
                        animTrack:AdjustSpeed(replacementAnimation.speed)
                    end

                    local duration = replacementAnimation.endingTime - replacementAnimation.startingTime
                    local adjustedDuration = duration
                    if replacementAnimation.speed then
                        adjustedDuration = duration / replacementAnimation.speed
                    end

                    if adjustedDuration <= 60 then
                        task.wait(adjustedDuration)
                    end

                    animTrack:Stop()
                    break
                end
            end
        end)
    end

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    hookHumanoid(humanoid)

    player.CharacterAdded:Connect(function(newChar)
        character = newChar
        humanoid = newChar:WaitForChild("Humanoid")
        hookHumanoid(humanoid)
    end)

    local toolTable = {
        ["Consecutive Punches"] = "Fast Kicks",
        ["Shove"] = "My Grasp"
    }

    while true do
        local pGui = player:FindFirstChild("PlayerGui")
        if pGui then
            local textLabel = pGui:FindFirstChild("ScreenGui") and pGui.ScreenGui:FindFirstChild("MagicHealth") and pGui.ScreenGui.MagicHealth:FindFirstChild("TextLabel")
            local hotbarFrame = pGui:FindFirstChild("Hotbar") and pGui.Hotbar:FindFirstChild("Backpack") and pGui.Hotbar.Backpack:FindFirstChild("Hotbar")

            if hotbarFrame then
                for i = 1, 9 do
                    local baseButton = hotbarFrame:FindFirstChild(tostring(i)) and hotbarFrame[tostring(i)].Base
                    if baseButton and baseButton:FindFirstChild("ToolName") then
                        local oldName = baseButton.ToolName.Text
                        local newName = toolTable[oldName]
                        if newName then
                            baseButton.ToolName.Text = newName
                        end
                    end
                end
            end

            if textLabel and textLabel.Text == "SERIOUS MODE" then
                local selectedName = "Wonder How Fast I Can Go"
                textLabel.Text = ""
                for i = 1, #selectedName do
                    textLabel.Text = string.sub(selectedName, 1, i)
                    task.wait(0.1)
                end
            end
        end

        RunService.Heartbeat:Wait()
    end
end)
