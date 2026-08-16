local plr = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local stgui = game:GetService("StarterGui")

-- Load toggle from loader (default: false)
getgenv().AutoDashEnabled = getgenv().AutoDashEnabled or false

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

-- === MANUAL Q DASH (kept original behaviour) ===
uis.InputBegan:Connect(function(input, t)
    if t then return end
    if input.KeyCode == Enum.KeyCode.Q then
        local char = plr.Character
        if not char then return end

        if char:FindFirstChild("UsedDash") and not uis:IsKeyDown(Enum.KeyCode.D) and not uis:IsKeyDown(Enum.KeyCode.A) and not uis:IsKeyDown(Enum.KeyCode.S) then
            frontDash()
        end

        if not uis:IsKeyDown(Enum.KeyCode.W) and not uis:IsKeyDown(Enum.KeyCode.S) then
            emoteDash()
        end
    end
end)

-- === AUTO‑DASH LOOP (runs every 500ms) ===
coroutine.wrap(function()
    while true do
        if getgenv().AutoDashEnabled then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("UsedDash") then
                frontDash()
                emoteDash()
            end
        end
        task.wait(0.5) -- fixed 500ms interval (you can adjust here if needed)
    end
end)()

-- === PRESS V TO TOGGLE AUTO‑DASH ===
uis.InputBegan:Connect(function(input, t)
    if t then return end
    if input.KeyCode == Enum.KeyCode.V then
        getgenv().AutoDashEnabled = not getgenv().AutoDashEnabled
        stgui:SetCore("SendNotification", {
            Title = "claysPerk",
            Text = getgenv().AutoDashEnabled and "✅ Auto‑dash ON" : "❌ Auto‑dash OFF",
            Duration = 2,
            Button1 = "OK"
        })
    end
end)

-- === NOTIFICATION WHEN SCRIPT LOADS ===
if not getgenv().DisableNotification then
    stgui:SetCore("SendNotification", {
        Title = "[claysPerk loaded]",
        Icon = "rbxassetid://17280176207",
        Text = "Press V to toggle auto‑dash | Q for manual dash",
        Duration = 5,
        Button1 = "Dismiss"
    })
end
