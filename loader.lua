local plr = game:GetService("Players").LocalPlayer
local stgui = game:GetService("StarterGui")

if not getgenv().DisableNotification then
    stgui:SetCore("SendNotification", {
        Title = "[claysPerk]",
        Icon = "rbxassetid://17280176207",  -- change this to your own icon if you want
        Text = "claysPerk is loading, wait a second",
        Duration = 5,
        Button1 = "Dismiss",
        Callback = function() end
    })
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- YOUR KEY – change this to whatever you want
local VALID_KEY = "claysretake"

-- Global toggle for auto-dash (will be used by main.lua)
getgenv().AutoDashEnabled = false

local Window = Fluent:CreateWindow({
    Title = "⚡ claysPerk",
    SubTitle = "by HB_HUB",
    TabWidth = 180,
    Size = UDim2.fromOffset(500, 250),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Key = Window:AddTab({ Title = "🔑 Key", Icon = "key" }),
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

local function performCheck()
    if scriptkeyInput == VALID_KEY then
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
-- INFO TAB
-- ============================
local infoSection = Tabs.Info:AddSection("About claysPerk")
infoSection:AddParagraph({
    Title = "M1 Dash Reset",
    Content = "Press V to toggle auto‑dash on/off.\n\nKey: " .. VALID_KEY .. "\n\nMade for M1 reset."
})

Fluent:Notify({
    Title = "🔔 Welcome",
    Content = "Enter your key to unlock.",
    Duration = 5
})

-- SaveManager / InterfaceManager (optional, but keep for settings)
SaveManager:LoadAutoloadConfig()
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Info)   -- put settings in Info tab
SaveManager:BuildConfigSection(Tabs.Info)
