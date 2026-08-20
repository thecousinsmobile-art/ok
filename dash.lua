-- dash_and_visuals_split.lua (Updated with Enhanced Detection)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Configurations & Keybinds
local config = {
    dashKey = Enum.KeyCode.R,
    dashJumpKey = Enum.KeyCode.T,
    menuKey = Enum.KeyCode.LeftControl,
    customMovesetEnabled = false,
    snowEnabled = false,
    duskEnabled = false,
    crosshairEnabled = false,
}

local DASH_ANIMATION_ID = "rbxassetid://10480793962"
local DASH_DISTANCE = 28
local DASH_TIME = 0.24
local JUMP_DASH_DISTANCE = 52
local JUMP_DASH_TIME = 0.65
local JUMP_HEIGHT = 6

local busy = false
local autoRotate = false

-- Networking Setup for detecting other ClayV1 users (You and your friend)
local commsFolder = ReplicatedStorage:FindFirstChild("ClayV1Comms")
if not commsFolder then
    commsFolder = Instance.new("Folder")
    commsFolder.Name = "ClayV1Comms"
    commsFolder.Parent = ReplicatedStorage
end

local userSignal = commsFolder:FindFirstChild(player.Name)
if not userSignal then
    userSignal = Instance.new("BoolValue")
    userSignal.Name = player.Name
    userSignal.Value = true
    userSignal.Parent = commsFolder
end

-- Ensure signal stays alive if character respawns/resets
player.CharacterAdded:Connect(function()
    if not commsFolder:FindFirstChild(player.Name) then
        local sig = Instance.new("BoolValue")
        sig.Name = player.Name
        sig.Value = true
        sig.Parent = commsFolder
    end
end)

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
    elseif input.KeyCode == config.menuKey then
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            local dashGui = playerGui:FindFirstChild("DashGui")
            if dashGui then
                local settingsMenu = dashGui:FindFirstChild("SettingsMenu")
                if settingsMenu then
                    settingsMenu.Visible = not settingsMenu.Visible
                end
            end
        end
    end
end)

-- Visual Features Implementation

-- 1. Dusk Lighting Controller
local savedLighting = {}
local function updateDusk()
    if config.duskEnabled then
        savedLighting.ClockTime = Lighting.ClockTime
        savedLighting.Brightness = Lighting.Brightness
        savedLighting.Ambient = Lighting.Ambient
        savedLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        savedLighting.GlobalShadows = Lighting.GlobalShadows
        
        local oldSky = Lighting:FindFirstChildOfClass("Sky")
        savedLighting.Sky = oldSky and oldSky.SkyboxBk or nil

        Lighting.ClockTime = 18.5
        Lighting.Brightness = 1.2
        Lighting.Ambient = Color3.fromRGB(90, 100, 130)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 80, 110)
        Lighting.GlobalShadows = true

        local sky = oldSky
        if not sky then
            sky = Instance.new("Sky")
            sky.Parent = Lighting
        end
        sky.SkyboxBk = "rbxassetid://155359427"
        sky.SkyboxDn = "rbxassetid://155359429"
        sky.SkyboxFt = "rbxassetid://155359439"
        sky.SkyboxLf = "rbxassetid://155359438"
        sky.SkyboxRt = "rbxassetid://155359443"
        sky.SkyboxUp = "rbxassetid://155359448"
        sky.StarCount = 500
    else
        if savedLighting.ClockTime then
            Lighting.ClockTime = savedLighting.ClockTime
            Lighting.Brightness = savedLighting.Brightness
            Lighting.Ambient = savedLighting.Ambient
            Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
            Lighting.GlobalShadows = savedLighting.GlobalShadows
            local sky = Lighting:FindFirstChildOfClass("Sky")
            if sky then
                if savedLighting.Sky then
                    sky.SkyboxBk = savedLighting.Sky
                else
                    sky:Destroy()
                end
            end
        end
    end
end

-- 2. Snow Controller
local snowConnection = nil
local function updateSnow()
    local existingPart = workspace:FindFirstChild("ClayV1Snow")
    if existingPart then existingPart:Destroy() end
    if snowConnection then snowConnection:Disconnect() snowConnection = nil end

    if config.snowEnabled then
        local snowPart = Instance.new("Part")
        snowPart.Name = "ClayV1Snow"
        snowPart.Size = Vector3.new(200, 1, 200)
        snowPart.Anchored = true
        snowPart.CanCollide = false
        snowPart.CanTouch = false
        snowPart.CanQuery = false
        snowPart.Transparency = 1
        snowPart.CastShadow = false
        snowPart.Parent = workspace

        local snow = Instance.new("ParticleEmitter")
        snow.Name = "RealSnow"
        snow.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        snow.Rate = 350
        snow.Lifetime = NumberRange.new(5, 8)
        snow.Speed = NumberRange.new(8, 14)
        snow.Acceleration = Vector3.new(2, -8, 1)
        snow.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.20),
            NumberSequenceKeypoint.new(0.25, 0.40),
            NumberSequenceKeypoint.new(0.7, 0.35),
            NumberSequenceKeypoint.new(1, 0.15)
        })
        snow.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        snow.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(0.15, 0),
            NumberSequenceKeypoint.new(0.75, 0.05),
            NumberSequenceKeypoint.new(1, 0.45)
        })
        snow.Rotation = NumberRange.new(0, 360)
        snow.RotSpeed = NumberRange.new(-60, 60)
        snow.Shape = Enum.ParticleEmitterShape.Box
        snow.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
        snow.EmissionDirection = Enum.NormalId.Bottom
        snow.SpreadAngle = Vector2.new(15, 15)
        snow.LightEmission = 0.4
        snow.LightInfluence = 0
        snow.Enabled = true
        snow.Parent = snowPart

        snowConnection = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            if camera then
                snowPart.Position = camera.CFrame.Position + Vector3.new(0, 35, 0)
            end
        end)
    end
end

-- 3. Crosshair Controller
local crosshairGuiConn = nil
local function updateCrosshair()
    local playerGui = player:WaitForChild("PlayerGui")
    local existingGui = playerGui:FindFirstChild("ClayV1CrosshairGui")
    if existingGui then existingGui:Destroy() end
    if crosshairGuiConn then crosshairGuiConn:Disconnect() crosshairGuiConn = nil end

    if config.crosshairEnabled then
        local gui = Instance.new("ScreenGui")
        gui.Name = "ClayV1CrosshairGui"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 999999
        gui.Parent = playerGui

        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.fromOffset(220, 220)
        container.Position = UDim2.fromScale(0.5, 0.5)
        container.AnchorPoint = Vector2.new(0.5, 0.5)
        container.BackgroundTransparency = 1
        container.Parent = gui

        local crosshair = Instance.new("Frame")
        crosshair.Name = "Crosshair"
        crosshair.Size = UDim2.fromOffset(70, 70)
        crosshair.Position = UDim2.fromScale(0.5, 0.5)
        crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
        crosshair.BackgroundTransparency = 1
        crosshair.Parent = container

        local lines = {}
        local LINE_LENGTH, LINE_WIDTH = 15, 2
        for i = 1, 4 do
            local glow = Instance.new("Frame")
            glow.Size = UDim2.fromOffset(LINE_WIDTH + 8, LINE_LENGTH + 8)
            glow.Position = UDim2.fromScale(0.5, 0.5)
            glow.AnchorPoint = Vector2.new(0.5, 0.5)
            glow.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            glow.BackgroundTransparency = 0.45
            glow.BorderSizePixel = 0
            glow.Parent = crosshair

            local glowCorner = Instance.new("UICorner")
            glowCorner.CornerRadius = UDim.new(1, 0)
            glowCorner.Parent = glow

            local line = Instance.new("Frame")
            line.Size = UDim2.fromOffset(LINE_WIDTH, LINE_LENGTH)
            line.Position = UDim2.fromScale(0.5, 0.5)
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
            line.BorderSizePixel = 0
            line.Parent = crosshair

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = line

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(255, 90, 90)
            stroke.Thickness = 1
            stroke.Transparency = 0
            stroke.Parent = line

            local angle = (i - 1) * 90
            line.Rotation = angle
            glow.Rotation = angle

            table.insert(lines, {line = line, glow = glow, angle = angle})
        end

        local dotGlow = Instance.new("Frame")
        dotGlow.Size = UDim2.fromOffset(6, 6)
        dotGlow.Position = UDim2.fromScale(0.5, 0.5)
        dotGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        dotGlow.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        dotGlow.BackgroundTransparency = 0.25
        dotGlow.BorderSizePixel = 0
        dotGlow.Parent = crosshair

        local dotGlowCorner = Instance.new("UICorner")
        dotGlowCorner.CornerRadius = UDim.new(1, 0)
        dotGlowCorner.Parent = dotGlow

        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(2, 2)
        dot.Position = UDim2.fromScale(0.5, 0.5)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        dot.BorderSizePixel = 0
        dot.Parent = crosshair

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local textGlow = Instance.new("TextLabel")
        textGlow.Size = UDim2.fromOffset(180, 35)
        textGlow.Position = UDim2.new(0.5, 0, 0.5, 52)
        textGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        textGlow.BackgroundTransparency = 1
        textGlow.Text = "clayv1"
        textGlow.TextColor3 = Color3.fromRGB(255, 0, 0)
        textGlow.TextSize = 16
        textGlow.Font = Enum.Font.GothamBold
        textGlow.TextTransparency = 0.2
        textGlow.TextStrokeColor3 = Color3.fromRGB(255, 0, 0)
        textGlow.TextStrokeTransparency = 0
        textGlow.ZIndex = 2
        textGlow.Parent = container

        local nameText = Instance.new("TextLabel")
        nameText.Size = UDim2.fromOffset(180, 35)
        nameText.Position = UDim2.new(0.5, 0, 0.5, 52)
        nameText.AnchorPoint = Vector2.new(0.5, 0.5)
        nameText.BackgroundTransparency = 1
        nameText.Text = "clayv1"
        nameText.TextColor3 = Color3.fromRGB(255, 65, 65)
        nameText.TextSize = 16
        nameText.Font = Enum.Font.GothamBold
        nameText.TextStrokeColor3 = Color3.fromRGB(75, 0, 0)
        nameText.TextStrokeTransparency = 0
        nameText.TextTransparency = 0
        nameText.ZIndex = 3
        nameText.Parent = container

        local elapsed = 0
        local rotation = 0
        local MIN_DISTANCE, MAX_DISTANCE = 13, 21

        crosshairGuiConn = RunService.RenderStepped:Connect(function(dt)
            elapsed += dt
            if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
                UserInputService.MouseIconEnabled = false
            else
                UserInputService.MouseIconEnabled = true
            end

            rotation += 110 * dt
            crosshair.Rotation = rotation

            local pulse = (math.sin(elapsed * 4) + 1) / 2
            local distance = MIN_DISTANCE + (pulse * (MAX_DISTANCE - MIN_DISTANCE))

            for _, data in ipairs(lines) do
                local angle = math.rad(data.angle)
                local x = math.sin(angle) * distance
                local y = -math.cos(angle) * distance
                data.line.Position = UDim2.new(0.5, x, 0.5, y)
                data.glow.Position = UDim2.new(0.5, x, 0.5, y)
                data.glow.BackgroundTransparency = 0.72 - (pulse * 0.3)
            end

            local dotSize = 5 + (pulse * 2)
            dotGlow.Size = UDim2.fromOffset(dotSize, dotSize)
            dotGlow.BackgroundTransparency = 0.4 - (pulse * 0.15)
        end)
    end
end

-- 4. Fellow ClayV1 User Tag Manager (Displays "fellow clayv1 user" above your friend's head automatically)
local function setupTagsModule()
    RunService.RenderStepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local char = p.Character
                if char and char:FindFirstChild("Head") then
                    local head = char.Head
                    local billboard = head:FindFirstChild("ClayV1UserTag")
                    
                    local isUser = commsFolder:FindFirstChild(p.Name) ~= nil
                    
                    if isUser then
                        if not billboard then
                            billboard = Instance.new("BillboardGui")
                            billboard.Name = "ClayV1UserTag"
                            billboard.Size = UDim2.new(0, 200, 0, 50)
                            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                            billboard.AlwaysOnTop = true
                            billboard.Parent = head

                            local label = Instance.new("TextLabel")
                            label.Name = "TagText"
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.Text = "fellow clayv1 user"
                            label.TextColor3 = Color3.fromRGB(0, 255, 128)
                            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            label.TextStrokeTransparency = 0
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 14
                            label.Parent = billboard
                        end
                    else
                        if billboard then
                            billboard:Destroy()
                        end
                    end
                end
            end
        end
    end)
end

task.spawn(setupTagsModule)

-- GUI Helpers & Setup
local function makeButton(parent, name, text, size, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
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

local function makeToggle(parent, name, text, size, position, initialState, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
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

    local dashBtnRef = makeButton(container, "DashRButton", "Dash (" .. config.dashKey.Name .. ")", UDim2.new(1, -16, 0, 32), UDim2.new(0, 8, 0, 30), dash)
    local dashJumpBtnRef = makeButton(container, "DashTButton", "Dash Jump (" .. config.dashJumpKey.Name .. ")", UDim2.new(1, -16, 0, 32), UDim2.new(0, 8, 0, 65), dashJump)
    
    makeToggle(container, "AutoRotateToggle", "Auto Rotate", UDim2.new(1, -16, 0, 32), UDim2.new(0, 8, 0, 100), autoRotate, function(state)
        autoRotate = state
    end)

    -- Tabbed Control Panel (Toggled via Ctrl)
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsMenu"
    settingsFrame.Size = UDim2.new(0, 260, 0, 230)
    settingsFrame.Position = UDim2.new(0.5, -130, 0.5, -115)
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
    sTitle.Size = UDim2.new(1, 0, 0, 25)
    sTitle.Position = UDim2.new(0, 0, 0, 5)
    sTitle.BackgroundTransparency = 1
    sTitle.Text = "CONTROL PANEL (CTRL)"
    sTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextSize = 13
    sTitle.Parent = settingsFrame

    -- Tabs Container (Dash, Moveset, Visuals, Owner)
    local tabDashBtn = makeButton(settingsFrame, "TabDash", "Dash", UDim2.new(0.24, -4, 0, 26), UDim2.new(0, 4, 0, 35), function() end)
    local tabMovesetBtn = makeButton(settingsFrame, "TabMoveset", "Moveset", UDim2.new(0.24, -4, 0, 26), UDim2.new(0.25, 2, 0, 35), function() end)
    local tabVisualsBtn = makeButton(settingsFrame, "TabVisuals", "Visuals", UDim2.new(0.24, -4, 0, 26), UDim2.new(0.50, 0, 0, 35), function() end)
    local tabOwnerBtn = makeButton(settingsFrame, "TabOwner", "Owner", UDim2.new(0.24, -4, 0, 26), UDim2.new(0.75, -2, 0, 35), function() end)

    -- Content Frames for Tabs
    local dashTabContent = Instance.new("Frame")
    dashTabContent.Size = UDim2.new(1, -16, 0, 110)
    dashTabContent.Position = UDim2.new(0, 8, 0, 70)
    dashTabContent.BackgroundTransparency = 1
    dashTabContent.Visible = true
    dashTabContent.Parent = settingsFrame

    local movesetTabContent = Instance.new("Frame")
    movesetTabContent.Size = UDim2.new(1, -16, 0, 110)
    movesetTabContent.Position = UDim2.new(0, 8, 0, 70)
    movesetTabContent.BackgroundTransparency = 1
    movesetTabContent.Visible = false
    movesetTabContent.Parent = settingsFrame

    local visualsTabContent = Instance.new("ScrollingFrame")
    visualsTabContent.Size = UDim2.new(1, -16, 0, 110)
    visualsTabContent.Position = UDim2.new(0, 8, 0, 70)
    visualsTabContent.BackgroundTransparency = 1
    visualsTabContent.Visible = false
    visualsTabContent.CanvasSize = UDim2.new(0, 0, 0, 120)
    visualsTabContent.ScrollBarThickness = 4
    visualsTabContent.Parent = settingsFrame

    local ownerTabContent = Instance.new("ScrollingFrame")
    ownerTabContent.Size = UDim2.new(1, -16, 0, 110)
    ownerTabContent.Position = UDim2.new(0, 8, 0, 70)
    ownerTabContent.BackgroundTransparency = 1
    ownerTabContent.Visible = false
    ownerTabContent.CanvasSize = UDim2.new(0, 0, 0, 150)
    ownerTabContent.ScrollBarThickness = 4
    ownerTabContent.Parent = settingsFrame

    -- Tab Switching Logic
    local function selectTab(activeTab)
        dashTabContent.Visible = (activeTab == "Dash")
        movesetTabContent.Visible = (activeTab == "Moveset")
        visualsTabContent.Visible = (activeTab == "Visuals")
        ownerTabContent.Visible = (activeTab == "Owner")

        tabDashBtn.BackgroundColor3 = (activeTab == "Dash") and Color3.fromRGB(60, 60, 75) or Color3.fromRGB(40, 40, 50)
        tabMovesetBtn.BackgroundColor3 = (activeTab == "Moveset") and Color3.fromRGB(60, 60, 75) or Color3.fromRGB(40, 40, 50)
        tabVisualsBtn.BackgroundColor3 = (activeTab == "Visuals") and Color3.fromRGB(60, 60, 75) or Color3.fromRGB(40, 40, 50)
        tabOwnerBtn.BackgroundColor3 = (activeTab == "Owner") and Color3.fromRGB(60, 60, 75) or Color3.fromRGB(40, 40, 50)
    end

    tabDashBtn.MouseButton1Click:Connect(function() selectTab("Dash") end)
    tabMovesetBtn.MouseButton1Click:Connect(function() selectTab("Moveset") end)
    tabVisualsBtn.MouseButton1Click:Connect(function() selectTab("Visuals") end)
    tabOwnerBtn.MouseButton1Click:Connect(function() selectTab("Owner") end)
    tabDashBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)

    -- Populate Dash Tab
    local isListening = false
    
    local dashKeyButton = makeButton(dashTabContent, "BindDash", "Dash Key: " .. config.dashKey.Name, UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 0, 5), function()
        if isListening then return end
        isListening = true
        dashKeyButton.Text = "Press any key..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                config.dashKey = input.KeyCode
                dashKeyButton.Text = "Dash Key: " .. config.dashKey.Name
                dashBtnRef.Text = "Dash (" .. config.dashKey.Name .. ")"
                isListening = false
                connection:Disconnect()
            end
        end)
    end)

    local dashJumpKeyButton = makeButton(dashTabContent, "BindDashJump", "Jump Key: " .. config.dashJumpKey.Name, UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 0, 45), function()
        if isListening then return end
        isListening = true
        dashJumpKeyButton.Text = "Press any key..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                config.dashJumpKey = input.KeyCode
                dashJumpKeyButton.Text = "Jump Key: " .. config.dashJumpKey.Name
                dashJumpBtnRef.Text = "Dash Jump (" .. config.dashJumpKey.Name .. ")"
                isListening = false
                connection:Disconnect()
            end
        end)
    end)

    -- Populate Moveset Tab
    makeToggle(movesetTabContent, "CustomMovesetToggle", "enable moveset custom", UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 0, 20), config.customMovesetEnabled, function(state)
        config.customMovesetEnabled = state
    end)

    -- Populate Visuals Tab
    makeToggle(visualsTabContent, "SnowToggle", "Enable Snow", UDim2.new(1, -4, 0, 30), UDim2.new(0, 0, 0, 0), config.snowEnabled, function(state)
        config.snowEnabled = state
        updateSnow()
    end)

    makeToggle(visualsTabContent, "DuskToggle", "Enable Dusk Lighting", UDim2.new(1, -4, 0, 30), UDim2.new(0, 0, 0, 36), config.duskEnabled, function(state)
        config.duskEnabled = state
        updateDusk()
    end)

    makeToggle(visualsTabContent, "CrosshairToggle", "Enable Crosshair & Text", UDim2.new(1, -4, 0, 30), UDim2.new(0, 0, 0, 72), config.crosshairEnabled, function(state)
        config.crosshairEnabled = state
        updateCrosshair()
    end)

    -- Populate Owner Tab Features (Fly-All fully removed, useful admin tools retained)
    makeButton(ownerTabContent, "OwnerRespawn", "Respawn Character", UDim2.new(1, -4, 0, 30), UDim2.new(0, 0, 0, 0), function()
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end)

    makeButton(ownerTabContent, "OwnerSpeedBoost", "Toggle Speed Boost (Walk)", UDim2.new(1, -4, 0, 30), UDim2.new(0, 0, 0, 36), function()
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if humanoid.WalkSpeed == 16 then
                    humanoid.WalkSpeed = 32
                else
                    humanoid.WalkSpeed = 16
                end
            end
        end
    end)

    makeButton(ownerTabContent, "OwnerFullBright", "Toggle Fullbright", UDim2.new(1, -4, 0, 30), UDim2.new(0, 0, 0, 72), function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = not Lighting.GlobalShadows
    end)

    makeButton(ownerTabContent, "OwnerServerHop", "Copy Server Hop Script", UDim2.new(1, -4, 0, 30), UDim2.new(0, 0, 0, 108), function()
        pcall(function()
            if setclipboard then
                setclipboard('local TeleportService = game:GetService("TeleportService"); local Players = game:GetService("Players"); TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)')
            end
        end)
    end)

    -- Close Button
    makeButton(settingsFrame, "CloseMenu", "Close Menu", UDim2.new(1, -16, 0, 26), UDim2.new(0, 8, 0, 195), function()
        settingsFrame.Visible = false
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
