local plr = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local stgui = game:GetService("StarterGui")

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

		if input.KeyCode == Enum.KeyCode.Q and not uis:IsKeyDown(Enum.KeyCode.W) and not uis:IsKeyDown(Enum.KeyCode.S) and not isAnimationRunning(char, 10491993682) --[[backdash]] then
			local vel = hrp:FindFirstChild("dodgevelocity")
			if vel then
				vel:Destroy()
				stopAnimation(char, 10480793962) -- side dash right
				stopAnimation(char, 10480796021) -- side dash left
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

-- (Optional) Webhook – you can keep or remove this line
-- loadstring(game:HttpGet("https://pastefy.app/YAgfMYsH/raw"))()
