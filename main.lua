-- ============================================================
--  MAIN DASH SCRIPT – GUI and dash abilities
--  (No key/whitelist code – this is loaded after validation)
-- ============================================================

local _call5 = game:GetService('UserInputService')
game:GetService('VirtualInputManager')
local _LocalPlayer10 = game:GetService('Players').LocalPlayer

_call5.InputBegan:Connect(function() end)

local _call16 = _LocalPlayer10:WaitForChild('PlayerGui')
local existing = _call16:FindFirstChild('DashGui')
if existing then existing:Destroy() end

local _call22 = Instance.new('ScreenGui')
_call22.Name = 'DashGui'
_call22.ResetOnSpawn = false
_call22.IgnoreGuiInset = true
_call22.Parent = _call16

local _call24 = Instance.new('Frame')
_call24.Name = 'Container'
_call24.Size = UDim2.new(0, 140, 0, 125)
_call24.Position = UDim2.new(1, -160, 1, -145)
_call24.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
_call24.BackgroundTransparency = 0.15
_call24.BorderSizePixel = 0
_call24.Active = true
_call24.Parent = _call22

local _call32 = Instance.new('UICorner')
_call32.CornerRadius = UDim.new(0, 8)
_call32.Parent = _call24

_call24.InputBegan:Connect(function() end)
_call24.InputChanged:Connect(function() end)
_call5.InputChanged:Connect(function() end)

local _call64 = Instance.new('TextLabel')
_call64.Name = 'Title'
_call64.Size = UDim2.new(1, 0, 0, 20)
_call64.Position = UDim2.new(0, 0, 0, 4)
_call64.BackgroundTransparency = 1
_call64.Text = 'DASH'
_call64.TextColor3 = Color3.fromRGB(255, 255, 255)
_call64.Font = Enum.Font.GothamBold
_call64.TextSize = 14
_call64.Parent = _call24

local _call74 = Instance.new('TextButton')
_call74.Name = 'DashRButton'
_call74.Size = UDim2.new(1, -16, 0, 28)
_call74.Position = UDim2.new(0, 8, 0, 28)
_call74.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
_call74.Text = 'Dash (R)'
_call74.TextColor3 = Color3.fromRGB(255, 255, 255)
_call74.Font = Enum.Font.GothamMedium
_call74.TextSize = 13
_call74.AutoButtonColor = true
_call74.Parent = _call24

local _call86 = Instance.new('UICorner')
_call86.CornerRadius = UDim.new(0, 6)
_call86.Parent = _call74

_call74.MouseButton1Click:Connect(function()
    local char = _LocalPlayer10.Character
    if not char then return end
    local root = char:WaitForChild('HumanoidRootPart')
    local humanoid = char:FindFirstChildOfClass('Humanoid')
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass('Animator')
    local anim = Instance.new('Animation')
    anim.AnimationId = 'rbxassetid://10480793962'
    if animator then
        animator:LoadAnimation(anim):Play()
    end
    local startPos = root.Position
    game:GetService('RunService').RenderStepped:Connect(function()
        if not root or not root.Parent then return end
        local newPos = startPos:Lerp((startPos + (root.CFrame.RightVector * 28)), 0.00490381478567492)
        root.CFrame = CFrame.new(newPos, (newPos + root.CFrame.LookVector))
    end)
end)

local _call127 = Instance.new('TextButton')
_call127.Name = 'DashTButton'
_call127.Size = UDim2.new(1, -16, 0, 28)
_call127.Position = UDim2.new(0, 8, 0, 60)
_call127.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
_call127.Text = 'Dash Jump (T)'
_call127.TextColor3 = Color3.fromRGB(255, 255, 255)
_call127.Font = Enum.Font.GothamMedium
_call127.TextSize = 13
_call127.AutoButtonColor = true
_call127.Parent = _call24
Instance.new('UICorner').Parent = _call127
_call127.MouseButton1Click:Connect(function() end)

local _call147 = Instance.new('TextButton')
_call147.Name = 'AutoRotateToggle'
_call147.Size = UDim2.new(1, -16, 0, 28)
_call147.Position = UDim2.new(0, 8, 0, 92)
_call147.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
_call147.Text = 'Auto Rotate'
_call147.TextColor3 = Color3.fromRGB(255, 255, 255)
_call147.Font = Enum.Font.GothamMedium
_call147.TextSize = 13
_call147.AutoButtonColor = false
_call147.Parent = _call24
Instance.new('UICorner').Parent = _call147

_call147.MouseButton1Click:Connect(function()
    _call147.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
end)

_LocalPlayer10.CharacterAdded:Connect(function()
    task.wait(1)
    _LocalPlayer10.PlayerGui:FindFirstChild('DashGui')
end)

print("🎮 Dash GUI loaded successfully!")
