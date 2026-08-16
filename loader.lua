local plr = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
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

-- Load the global key and KeyIndex (original)
scriptkey = game:HttpGet('https://pastefy.app/K3CkiCrr/raw')
loadstring(game:HttpGet("https://pastefy.app/02uj0pdM/raw"))()

-- Load the whitelist from GitHub (NEW)
local Whitelist = loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/whitelist.lua"))()

-- Original function to get player's key type from KeyIndex
local function getPlayerKeyType(userId)
    for keyType, idList in pairs(KeyIndex) do
        if table.find(idList, userId) then
            return keyType:gsub(plr.Name.."_", "")
        end
    end
    return nil
end

-- NEW: Check if the player is whitelisted and key matches
local function checkWhitelist(username, key)
    if Whitelist and Whitelist[username] then
        return Whitelist[username] == key
    end
    return false
end

-- UI – same as before (only name changed)
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

-- The Check button – now checks whitelist FIRST, then global key, then KeyIndex
Tabs.Main:AddButton({
    Title = "Check",
    Callback = function()
        local playerKeyType = getPlayerKeyType(plr.UserId)
        
        -- 1. Check whitelist (NEW)
        if checkWhitelist(plr.Name, scriptkeyInput) then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/main.lua"))()
            Window:Destroy()
            return
        end
        
        -- 2. Check global key
        if scriptkeyInput == scriptkey then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/main.lua"))()
            Window:Destroy()
            return
        end
        
        -- 3. Check KeyIndex (original per-user keys)
        if playerKeyType and scriptkeyInput == playerKeyType then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/thecousinsmobile-art/ok/main/main.lua"))()
            Window:Destroy()
            return
        end
        
        -- If none match, show error
        Window:Dialog({
            Title = "Error",
            Content = "The key is warned",
            Buttons = {
                {
                    Title = "OK",
                    Callback = function() end
                }
            }
        })
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
