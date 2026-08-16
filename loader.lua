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

-- Load whitelist
local Whitelist = loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/whitelist.lua"))()

-- DEBUG: Show current username and expected key
local username = plr.Name
local expectedKey = Whitelist[username] or "Not in whitelist"

stgui:SetCore("SendNotification", {
    Title = "[DEBUG] Whitelist info",
    Text = "Username: " .. username .. "\nExpected key: " .. expectedKey,
    Duration = 8,
    Button1 = "OK"
})

print("DEBUG: Your username is:", username)
print("DEBUG: Expected key in whitelist:", expectedKey)

local function checkWhitelist(username, key)
    if Whitelist and Whitelist[username] then
        return Whitelist[username] == key
    end
    return false
end

-- UI (same as before)
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
        local entered = scriptkeyInput
        local user = plr.Name
        print("DEBUG: Checking key for", user, "entered:", entered)
        
        if checkWhitelist(user, entered) then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/main.lua"))()
            Window:Destroy()
        else
            local expected = Whitelist[user] or "(none)"
            Window:Dialog({
                Title = "Error",
                Content = "Wrong key or not whitelisted!\n\nYour username: " .. user .. "\nExpected key: " .. expected .. "\nYou entered: " .. entered,
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
