local plr = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local stgui = game:GetService("StarterGui")
local http = game:GetService("HttpService")

-- YOUR DISCORD WEBHOOK URL
local WEBHOOK_URL = "https://discord.com/api/webhooks/1538654884776124638/Dfv3qBDhn62kt9DJkjOsPT2ledozwnea1tnzJ7_ourJkYpoLLAGHWvVPB-OOOtIJeJ1T"

-- Function to send Discord webhook notifications
local function sendWebhook(message)
    local data = {
        content = message,
        username = "M1 Hub Logger"
    }
    local jsonData = http:JSONEncode(data)
    local headers = {
        ["Content-Type"] = "application/json"
    }
    pcall(function()
        http:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson, false, headers)
    end)
end

-- Send webhook when script loads
sendWebhook(string.format("🚀 **Script Executed**\nUser: %s\nUser ID: %s\nGame: %s", plr.Name, plr.UserId, game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown"))

local frontDashArgs = {
    [1] = {
        ["Dash"] = Enum.KeyCode.W,
        ["Key"] = Enum.KeyCode.Q,
        ["Goal"] = "KeyPress"
    }
}

local function frontDash()
    plr.Character.Communicate:FireServer(unpack(frontDashArgs))
end

local function noEndlagSetup(char)
    uis.InputBegan:Connect(function(input, t)
        if t then return end

        if input.KeyCode == Enum.KeyCode.Q and not uis:IsKeyDown(Enum.KeyCode.D) and not uis:IsKeyDown(Enum.KeyCode.A) and not uis:IsKeyDown(Enum.KeyCode.S) and char:FindFirstChild("UsedDash") then
            frontDash()
        end
    end)
end

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
                else
                    return false
                end
            end
        end
    end
end

local function emoteDashSetup(char)
    local hrp = char:WaitForChild("HumanoidRootPart")
    uis.InputBegan:Connect(function(input, t)
        if t then return end

        if input.KeyCode == Enum.KeyCode.Q and not uis:IsKeyDown(Enum.KeyCode.W) and not uis:IsKeyDown(Enum.KeyCode.S) and not isAnimationRunning(char, 10491993682) then
            local vel = hrp:FindFirstChild("dodgevelocity")
            if vel then
                vel:Destroy()
                stopAnimation(char, 10480793962)
                stopAnimation(char, 10480796021)
            end
        end
    end)
end

if plr.Character then
    noEndlagSetup(plr.Character)
    emoteDashSetup(plr.Character)
end

plr.CharacterAdded:Connect(emoteDashSetup)
plr.CharacterAdded:Connect(noEndlagSetup)

if not getgenv().DisableNotification then
    stgui:SetCore("SendNotification", {
        Title = "[M1 reset loaded]",
        Icon = "rbxassetid://17280176207",
        Text = "play and enjoy!",
        Duration = 5,
        Button1 = "Dismiss",
        Callback = function() end
    })
end
