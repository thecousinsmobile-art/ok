local plr = game:GetService("Players").LocalPlayer
local stgui = game:GetService("StarterGui")

if not getgenv().DisableNotification then
    stgui:SetCore("SendNotification", {
        Title = "[claysPerk]",
        Icon = "rbxassetid://17280176207",
        Text = "claysPerk is loading, wait a second",
        Duration = 5,
        Button1 = "Dismiss",
        Callback = function() end
    })
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Load whitelist from GitHub
local success, Whitelist = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/whitelist.lua"))()
end)

if not success or not Whitelist then
    stgui:SetCore("SendNotification", {
        Title = "[ERROR]",
        Text = "Could not load whitelist! Check your internet or the file URL.",
        Duration = 10,
        Button1 = "OK"
    })
    Whitelist = {}
end

-- Debug: show current username and if found in whitelist
local username = plr.Name
local foundKey = Whitelist[username]

if foundKey then
    stgui:SetCore("SendNotification", {
        Title = "[DEBUG] Whitelist entry found",
        Text = "Username: " .. username .. "\nExpected key: " .. foundKey,
        Duration = 8,
        Button1 = "OK"
    })
else
    stgui:SetCore("SendNotification", {
        Title = "[DEBUG] Not in whitelist",
        Text = "Username: " .. username .. "\nNo matching entry in whitelist.",
        Duration = 8,
        Button1 = "OK"
    })
end

local function checkWhitelist(username, key)
    if Whitelist and Whitelist[username] then
        return Whitelist[username] == key
    end
    return false
end

-- UI
local Window = Fluent:CreateWindow({
    Title = "claysPerk " .. Fluent.Version,
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

local Options = Fluent.Options

Fluent:Notify({
    Title = "Notification",
    Content = "This is a notification",
    SubContent = "SubContent",
    Duration = 5
})

Window:SelectTab(1)
scriptkeyInput = "string"

local Input = Tabs.Main:AddInput("Input", {
    Title = "Key",
    Default = "",
    Placeholder = "key",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        scriptkeyInput = Value
    end
})

Input:OnChanged(function()
    print("Input updated:", Input.Value)
end)

Tabs.Main:AddButton({
    Title = "Check",
    Callback = function()
        if checkWhitelist(plr.Name, scriptkeyInput) then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/main.lua"))()
            Window:Destroy()
        else
            -- Show detailed error
            local expected = Whitelist[plr.Name] or "(none)"
            Window:Dialog({
                Title = "Error",
                Content = "Wrong key or not whitelisted!\n\nYour username: " .. plr.Name .. "\nExpected key: " .. expected .. "\nYou entered: " .. scriptkeyInput,
                Buttons = {
                    {
                        Title = "OK",
                        Callback = function() end
                    }
                }
            })
        end
    end
})

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
