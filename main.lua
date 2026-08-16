local plr = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local stgui = game:GetService("StarterGui")

-- ===============================
-- ORIGINAL FUNCTIONS (unchanged)
-- ===============================

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
				end
            end
        end
    end
    return false
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

-- Attach to character
if plr.Character then
	noEndlagSetup(plr.Character)
	emoteDashSetup(plr.Character)
end

plr.CharacterAdded:Connect(emoteDashSetup)
plr.CharacterAdded:Connect(noEndlagSetup)

-- ===============================
-- V BIND – ONLY EMOTE DASH CANCEL
-- (stops side dash animations without front dash)
-- ===============================
local function emoteDashOnly()
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

uis.InputBegan:Connect(function(input, t)
    if t then return end
    if input.KeyCode == Enum.KeyCode.V then
        emoteDashOnly()
    end
end)

-- ===============================
-- Loaded notification
-- ===============================
if not getgenv().DisableNotification then
	stgui:SetCore("SendNotification", {
		Title = "[claysPerk loaded]",
		Icon = "rbxassetid://17280176207",
		Text = "Q = dash reset | V = emote cancel only",
		Duration = 5,
		Button1 = "Dismiss",
		Callback = function() end
	})
end
