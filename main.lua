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
				else
					return false
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
-- NEW: Macro function (exactly what an external macro would do)
-- ===============================
local function performDashReset()
    local char = plr.Character
    if not char then return end

    -- 1. Front dash (same conditions as Q: must have UsedDash and not holding D/A/S)
    if char:FindFirstChild("UsedDash") and not uis:IsKeyDown(Enum.KeyCode.D) and not uis:IsKeyDown(Enum.KeyCode.A) and not uis:IsKeyDown(Enum.KeyCode.S) then
        frontDash()
    end

    -- 2. Emote dash cancel (same conditions as the original emote dash)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        -- Only if not holding W/S and not playing backdash animation (10491993682)
        if not uis:IsKeyDown(Enum.KeyCode.W) and not uis:IsKeyDown(Enum.KeyCode.S) and not isAnimationRunning(char, 10491993682) then
            local vel = hrp:FindFirstChild("dodgevelocity")
            if vel then
                vel:Destroy()
                stopAnimation(char, 10480793962) -- right dash
                stopAnimation(char, 10480796021) -- left dash
            end
        end
    end
end

-- ===============================
-- Bind V to run the macro once per press
-- ===============================
uis.InputBegan:Connect(function(input, t)
    if t then return end
    if input.KeyCode == Enum.KeyCode.V then
        performDashReset()
    end
end)

-- ===============================
-- Loaded notification
-- ===============================
if not getgenv().DisableNotification then
	stgui:SetCore("SendNotification", {
		Title = "[claysPerk loaded]",
		Icon = "rbxassetid://17280176207",
		Text = "Q = manual dash | V = macro dash reset",
		Duration = 5,
		Button1 = "Dismiss",
		Callback = function() end
	})
end
