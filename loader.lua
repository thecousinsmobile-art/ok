local plr = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local stgui = game:GetService("StarterGui")

if not getgenv().DisableNotification then
    stgui:SetCore("SendNotification", {
        Title = "[M1 reset hub]",
        Icon = "rbxassetid://17280176207",
        Text = "M1 reset hub is loading, wait a second",
        Duration = 5,
        Button1 = "Dismiss",
        Callback = function() end
    })
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- The only valid key – change this to whatever you want
local VALID_KEY = "claysretake"

local Window = Fluent:CreateWindow({
    Title = "HB hub " .. Fluent.Version,
    SubTitle = "by HB_HUB",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 250),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Key System", Icon = "key" }),
}

local scriptkeyInput = ""

local Input = Tabs.Main:AddInput("Input", {
    Title = "Key",
    Default = "",
    Placeholder = "Enter the key",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        scriptkeyInput = Value
    end
})

Input:OnChanged(function()
    print("Input updated:", Input.Value)
end)

-- Check function (shared by button and V key)
local function performCheck()
    if scriptkeyInput == VALID_KEY then
        -- Load the actual hack script from GitHub
        loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/main.lua"))()
        Window:Destroy()
    else
        Window:Dialog({
            Title = "Error",
            Content = "Wrong key!",
            Buttons = {
                {
                    Title = "OK",
                    Callback = function() end
                }
            }
        })
    end
end

-- Button click
Tabs.Main:AddButton({
    Title = "Check",
    Callback = performCheck
})

-- V‑key macro
uis.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.V and not gameProcessed then
        performCheck()
    end
end)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
