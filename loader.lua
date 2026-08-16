local plr = game:GetService("Players").LocalPlayer
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

-- CHANGE THIS TO YOUR OWN KEY
local VALID_KEY = "claysretake"

-- Create the main window with a sleek dark theme
local Window = Fluent:CreateWindow({
    Title = "⚡ M1 Hub",
    SubTitle = "by HB_HUB",
    TabWidth = 180,
    Size = UDim2.fromOffset(600, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs
local Tabs = {
    Key = Window:AddTab({ Title = "🔑 Key", Icon = "key" }),
    Dash = Window:AddTab({ Title = "💨 Dash", Icon = "dash" }),
    Info = Window:AddTab({ Title = "ℹ️ Info", Icon = "info" })
}

local scriptkeyInput = ""

-- ============================
-- KEY TAB
-- ============================
local keySection = Tabs.Key:AddSection("Enter Your Key")

local Input = keySection:AddInput("Input", {
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

local function performCheck()
    if scriptkeyInput == VALID_KEY then
        -- Load the main script from your GitHub
        loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/main.lua"))()
        Window:Destroy()
    else
        Window:Dialog({
            Title = "❌ Error",
            Content = "Wrong key! Please try again.",
            Buttons = {
                {
                    Title = "OK",
                    Callback = function() end
                }
            }
        })
    end
end

keySection:AddButton({
    Title = "✅ Verify Key",
    Callback = performCheck
})

-- ============================
-- DASH TAB (Settings for the macro)
-- ============================
local dashSection = Tabs.Dash:AddSection("Dash Configuration")

-- Toggle to enable auto-dash
local autoDashToggle = dashSection:AddToggle("AutoDash", {
    Title = "Auto Dash",
    Description = "Automatically performs M1 dash reset",
    Default = false,
    Callback = function(Value)
        getgenv().AutoDashEnabled = Value
    end
})

-- Slider for dash interval (in milliseconds)
local dashInterval = dashSection:AddSlider("DashInterval", {
    Title = "Dash Interval (ms)",
    Description = "Delay between each dash",
    Default = 500,
    Min = 100,
    Max = 2000,
    Rounding = 1,
    Callback = function(Value)
        getgenv().DashInterval = Value
    end
})

-- Add a keybind to toggle auto-dash with a key (optional)
local dashToggleKey = dashSection:AddKeybind("DashToggleKey", {
    Title = "Toggle Auto-Dash Key",
    Default = Enum.KeyCode.F,
    Callback = function(Key, Mode)
        if Mode == Enum.KeyCode.F then
            autoDashToggle:SetValue(not autoDashToggle.Value)
        end
    end
})

-- ============================
-- INFO TAB
-- ============================
local infoSection = Tabs.Info:AddSection("About")
infoSection:AddParagraph({
    Title = "M1 Reset Hub",
    Content = "Script loaded successfully.\nMade by HB_HUB.\n\nKey: " .. VALID_KEY .. "\nAuto-dash interval adjustable."
})

-- Notify
Fluent:Notify({
    Title = "🔔 Welcome",
    Content = "Enter your key to unlock the script.",
    Duration = 5
})

-- SaveManager / InterfaceManager setup
SaveManager:LoadAutoloadConfig()
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Info)  -- put settings in Info tab
SaveManager:BuildConfigSection(Tabs.Info)
