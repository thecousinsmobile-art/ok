local plr = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local stgui = game:GetService("StarterGui")
local http = game:GetService("HttpService")

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

local function performCheck()
    if scriptkeyInput == VALID_KEY then
        -- Send webhook notification on successful key
        sendWebhook(string.format("✅ **User Loaded Script**\nUser: %s\nUser ID: %s\nGame: %s", plr.Name, plr.UserId, game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown"))
        
        loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/main.lua"))()
        Window:Destroy()
    else
        -- Send webhook notification on failed key attempt
        sendWebhook(string.format("❌ **Failed Key Attempt**\nUser: %s\nUser ID: %s\nKey Entered: %s", plr.Name, plr.UserId, scriptkeyInput))
        
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

Tabs.Main:AddButton({
    Title = "Check",
    Callback = performCheck
})

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
