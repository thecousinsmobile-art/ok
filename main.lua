local plr = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local stgui = game:GetService("StarterGui")
local runService = game:GetService("RunService")

-- Get settings from loader (if not set, use defaults)
getgenv().AutoDashEnabled = getgenv().AutoDashEnabled or false
getgenv().DashInterval = getgenv().DashInterval or 500

local frontDashArgs = {
    [1] = {
        ["Dash"] = Enum.KeyCode.W,
        ["Key"] = Enum.KeyCode.Q,
        ["Goal"] = "KeyPress"
    }
}

-- Function to perform front dash
local function frontDash()
    local char = plr.Character
    if char and char:FindFirstChild("Communicate") then
        char.Communicate:FireServer(unpack(frontDashArgs))
    end
end

-- Function to perform emote dash cancel (side dashes)
local function stopAnimation(char, animationId)
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildWhichIsA("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.Animation and track.Animation.AnimationId == "rbxassetid://" .. tostring(animationId) then
                    track:Stop()
                end
            end
        end
    end
end

local function isAnimationRunning(char, animationId)
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildWhichIsA("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.Animation and track.Animation.AnimationId == "rbxassetid://" .. tostring(animationId) then
                    return true
                end
            end
        end
    end
    return false
end

-- Function to perform emote dash cancel
local function emoteDash()
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not uis:IsKeyDown(Enum.KeyCode.W) and not uis:IsKeyDown(Enum.KeyCode.S) and not isAnimationRunning(char, 10491993682) then
        local vel = hrp:FindFirstChild("dodgevelocity")
        if vel then
            vel:Destroy()
            stopAnimation(char, 10480793962) -- side dash right
            stopAnimation(char, 10480796021) -- side dash left
        end
    end
end

-- Manual dash on Q (original)
local function manualDashSetup(char)
    uis.InputBegan:Connect(function(input, t)
        if t then return end
        if input.KeyCode == Enum.KeyCode.Q then
            -- Front dash if no A/D/S pressed and UsedDash exists
            if not uis:IsKeyDown(Enum.KeyCode.D) and not uis:IsKeyDown(Enum.KeyCode.A) and not uis:IsKeyDown(Enum.KeyCode.S) and char:FindFirstChild("UsedDash") then
                frontDash()
            end
            -- Emote dash cancel if not pressing W/S
            if not uis:IsKeyDown(Enum.KeyCode.W) and not uis:IsKeyDown(Enum.KeyCode.S) then
                emoteDash()
            end
        end
    end)
end

-- Auto-dash loop
local autoDashCoroutine
local function startAutoDash()
    if autoDashCoroutine then
        coroutine.close(autoDashCoroutine)
        autoDashCoroutine = nil
    end

    autoDashCoroutine = coroutine.create(function()
        while getgenv().AutoDashEnabled do
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("UsedDash") then
                -- Perform front dash and emote dash simultaneously
                frontDash()
                emoteDash()
            end
            task.wait(getgenv().DashInterval / 1000) -- convert ms to seconds
        end
    end)
    coroutine.resume(autoDashCoroutine)
end

-- Monitor changes to AutoDashEnabled and restart loop
uis.InputBegan:Connect(function(input, t)
    if t then return end
    if input.KeyCode == Enum.KeyCode.F and getgenv().AutoDashEnabled then
        getgenv().AutoDashEnabled = false
    end
end)

-- Run the auto-dash loop continuously (it will check the toggle inside)
coroutine.wrap(function()
    while true do
        if getgenv().AutoDashEnabled then
            startAutoDash()
            -- Wait until disabled or script ends
            while getgenv().AutoDashEnabled do
                task.wait(0.1)
            end
            -- If disabled, stop the coroutine
            if autoDashCoroutine then
                coroutine.close(autoDashCoroutine)
                autoDashCoroutine = nil
            end
        end
        task.wait(0.5)
    end
end)()

-- Attach manual dash to character
if plr.Character then
    manualDashSetup(plr.Character)
end
plr.CharacterAdded:Connect(manualDashSetup)

-- Notification
if not getgenv().DisableNotification then
    stgui:SetCore("SendNotification", {
        Title = "[M1 reset loaded]",
        Icon = "rbxassetid://17280176207",
        Text = "play and enjoy! (press F to toggle auto-dash)",
        Duration = 5,
        Button1 = "Dismiss",
        Callback = function() end
    })
end
