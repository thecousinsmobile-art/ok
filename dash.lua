-- Combined Script
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- DASH VARIABLES
local DASH_ANIMATION_ID = "rbxassetid://10480793962"
local DASH_DISTANCE = 28
local DASH_TIME = 0.24
local JUMP_DASH_DISTANCE = 52
local JUMP_DASH_TIME = 0.65
local JUMP_HEIGHT = 6

local busy = false
local autoRotate = false

-- MOVESET REPLACEMENT VARIABLES
local movesetEnabled = false

local moveSet = {
    move2 = { animationId = "rbxassetid://10466974800" },
    move3 = { animationId = "rbxassetid://10471336737" }
}

local replacementMoveset = {
    move2 = { animationId = "rbxassetid://17799224866", startingTime = 0.56, endingTime = 8.37, speed = 1 },
    move3 = { animationId = "rbxassetid://12309835105", startingTime = 0.3, endingTime = 2.2 }
}

-- DASH FUNCTIONS
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

-- MOVESET REPLACEMENT FUNCTION
local function replaceMoveAnimation(humanoid)
    humanoid.AnimationPlayed:Connect(function(animation)
        if not movesetEnabled then return end
        
        for moveName, moveData in pairs(moveSet) do
            if animation.Animation.AnimationId == moveData.animationId then
                print("Original move detected: " .. moveName)

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

                if adjustedDuration > 60 then
                    return
                end

                wait(adjustedDuration)
                animTrack:Stop()
                break
            end
        end
    end)
end

-- INITIALIZE MOVESET
local function initializeMoveset()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        replaceMoveAnimation(humanoid)
    end
end

initializeMoveset()

player.CharacterAdded:Connect(function()
    task.wait(1)
    local character = player.Character
    local humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        replaceMoveAnimation(humanoid)
    end
end)

-- HOTBAR RENAMING FUNCTION
local function renameHotbar()
    local hotbarFrame = player.PlayerGui:FindFirstChild("Hotbar") and 
                        player.PlayerGui.Hotbar:FindFirstChild("Backpack") and 
                        player.PlayerGui.Hotbar.Backpack:FindFirstChild("Hotbar")
    
    if not hotbarFrame then return end
    
    local toolTable = {
        ["Consecutive Punches"] = "Fast Kicks",
        ["Shove"] = "My Grasp"
    }
    
    for i = 1, 9 do
        local baseButton = hotbarFrame:FindFirstChild(tostring(i)) and hotbarFrame[tostring(i)].Base
        if baseButton then
            local oldName = baseButton.ToolName.Text
            local newName = toolTable[oldName]
            if newName and movesetEnabled then
                baseButton.ToolName.Text = newName
            elseif not movesetEnabled then
                -- Reset to original names when disabled
                for original, replacement in pairs(toolTable) do
                    if baseButton.ToolName.Text == replacement then
                        baseButton.ToolName.Text = original
                    end
                end
            end
        end
    end
end

-- GUI FUNCTIONS
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
    local existing = playerGui:FindFirstChild("MovesetDashGui")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MovesetDashGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 160, 0, 200)
    container.Position = UDim2.new(1, -180, 1, -220)
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
    title.Text = "MOVESET + DASH"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = container

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

    local function makeToggle(parent, name, text, yPosition, isEnabled)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(1, -16, 0, 28)
        button.Position = UDim2.new(0, 8, 0, yPosition)
        button.BackgroundColor3 = isEnabled and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(45, 45, 55)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.GothamMedium
        button.TextSize = 13
        button.AutoButtonColor = false
        button.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button

        return button
    end

    -- Moveset Toggle Button
    local movesetToggle = makeToggle(container, "MovesetToggle", "Moveset: OFF", 28, false)
    movesetToggle.MouseButton1Click:Connect(function()
        movesetEnabled = not movesetEnabled
        if movesetEnabled then
            movesetToggle.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
            movesetToggle.Text = "Moveset: ON"
        else
            movesetToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            movesetToggle.Text = "Moveset: OFF"
        end
        renameHotbar()
    end)

    -- Dash Buttons
    makeButton(container, "DashRButton", "Dash (R)", 64, dash)
    makeButton(container, "DashTButton", "Dash Jump (T)", 96, dashJump)

    -- Auto Rotate Toggle
    local rotateToggle = makeToggle(container, "AutoRotateToggle", "Auto Rotate: OFF", 128, false)
    rotateToggle.MouseButton1Click:Connect(function()
        autoRotate = not autoRotate
        if autoRotate then
            rotateToggle.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
            rotateToggle.Text = "Auto Rotate: ON"
        else
            rotateToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            rotateToggle.Text = "Auto Rotate: OFF"
        end
    end)

    return screenGui
end

-- CREATE GUI
createGui()

-- RECREATE GUI ON RESPAWN
player.CharacterAdded:Connect(function()
    task.wait(1)
    local playerGui = player:WaitForChild("PlayerGui")
    if not playerGui:FindFirstChild("MovesetDashGui") then
        createGui()
    end
end)

-- KEYBINDS FOR DASH
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        dash()
    elseif input.KeyCode == Enum.KeyCode.T then
        dashJump()
    end
end)
