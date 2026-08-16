local plr = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local stgui = game:GetService("StarterGui")

-- ===============================
-- EMOTE DASH CANCEL FUNCTIONS
-- ===============================

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

local function emoteDashCancel()
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local vel = hrp:FindFirstChild("dodgevelocity")
        if vel then
            vel:Destroy()
            stopAnimation(char, 10480793962) -- right dash
            stopAnimation(char, 10480796021) -- left dash
        end
    end
end

-- ===============================
-- BIND V TO EMOTE DASH CANCEL
-- ===============================
uis.InputBegan:Connect(function(input, t)
    if t then return end
    if input.KeyCode == Enum.KeyCode.V then
        emoteDashCancel()
    end
end)

-- ===============================
-- LOADED NOTIFICATION
-- ===============================
if not getgenv().DisableNotification then
	stgui:SetCore("SendNotification", {
		Title = "[claysPerk loaded]",
		Icon = "rbxassetid://17280176207",
		Text = "Press V to cancel side dash",
		Duration = 5,
		Button1 = "Dismiss",
		Callback = function() end
	})
end
