local plr = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local stgui = game:GetService("StarterGui")

-- Load settings from the loader (fallback to defaults)
getgenv().AutoDashEnabled = getgenv().AutoDashEnabled or false
getgenv().DashInterval = getgenv().DashInterval or 500

-- === DASH FUNCTIONS ===

local frontDashArgs = {
    [1] = {
        ["Dash"] = Enum.KeyCode.W,
        ["Key"] = Enum.KeyCode.Q,
        ["Goal"] = "KeyPress"
    }
}

local function frontDash()
    local char = plr.Character
    if char and char:FindFirstChild("Communicate") then
        char.Communicate:FireServer(unpack(frontDashArgs))
    end
end

local function stopAnimation(char, id)
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then
        local animator = hum:FindFirstChildWhichIsA("Animator")
        if animator then
            for _, track in animator:GetPlayingAnimationTracks() do
                if track.Animation and track.Animation.AnimationId == "rbxassetid://" .. tostring(id) then
                    track:Stop()
                end
            end
        end
    end
end

local function isAnimationPlaying(char, id)
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then
        local animator = hum:FindFirstChildWhichIsA("Animator")
        if animator then
            for _, track in animator:GetPlayingAnimationTracks() do
                if track.Animation and track.Animation.AnimationId == "rbxassetid://" .. tostring(id) then
                    return true
                end
            end
        end
    end
    return false
end

local function emoteDash()
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not uis:IsKeyDown(Enum.KeyCode.W) and not uis:IsKeyDown(Enum.KeyCode.S) and not isAnimationPlaying(char, 10491993682) then
        local vel = hrp:FindFirstChild("dodgevelocity")
        if vel then
            vel:Destroy()
            stopAnimation(char, 10480793962) -- right dash
            stopAnimation(char, 10480796021) -- left dash
        end
    end
end

-- === MANUAL Q DASH ===
uis.InputBegan:Connect(function(input, t)
    if t then return end
    if input.KeyCode == Enum.KeyCode.Q then
        local char = plr.Character
        if not char then return end

        -- Front dash (original M1 reset)
        if char:FindFirstChild("UsedDash") and not uis:IsKeyDown(Enum.KeyCode.D) and not uis:IsKeyDown(Enum.KeyCode.A) and not uis:IsKeyDown(Enum.KeyCode.S) then
            frontDash()
        end

        -- Emote dash cancel
        if not uis:IsKeyDown(Enum.KeyCode.W) and not uis:IsKeyDown(Enum.KeyCode.S) then
            emoteDash()
        end
    end
end)

-- === AUTO‑DASH LOOP (BUILT‑IN MACRO) ===
coroutine.wrap(function()
    while true do
        if getgenv().AutoDashEnabled then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("UsedDash") then
                frontDash()
                emoteDash()
            end
        end
        local interval = getgenv().DashInterval or 500
        task.wait(interval / 1000) -- convert ms to seconds
    end
end)()

-- === PRESS F TO TOGGLE AUTO‑DASH (IN‑GAME) ===
uis.InputBegan:Connect(function(input, t)
    if t then return end
    if input.KeyCode == Enum.KeyCode.F then
        getgenv().AutoDashEnabled = not getgenv().AutoDashEnabled
        stgui:SetCore("SendNotification", {
            Title = "Auto-Dash",
            Text = getgenv().AutoDashEnabled and "✅ Enabled" : "❌ Disabled",
            Duration = 2,
            Button1 = "OK"
        })
    end
end)

-- === LOADED NOTIFICATION ===
if not getgenv().DisableNotification then
    stgui:SetCore("SendNotification", {
        Title = "[M1 reset loaded]",
        Icon = "rbxassetid://17280176207",
        Text = "Press Q to dash | Press F to toggle auto-dash",
        Duration = 5,
        Button1 = "Dismiss"
    })
end
