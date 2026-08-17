-- Whitelist Server Script
-- Handles key generation, validation, and expiration

local DataStoreService = game:GetService("DataStoreService")
local keyStore = DataStoreService:GetDataStore("WhitelistKeys")

local REMOTE_EVENT_NAME = "KeyValidationRemote"
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = REMOTE_EVENT_NAME
remoteEvent.Parent = game:GetService("ReplicatedStorage")

-- Admin commands (use in chat with prefix "/")
local ADMIN_USER_ID = 123456789 -- Replace with your Roblox User ID
local ALLOWED_USERS = {ADMIN_USER_ID} -- Add more admins if needed

-- Helper: parse duration string
local function parseDuration(str)
	if str:lower() == "lifetime" then
		return math.huge
	end
	local num = tonumber(str)
	if num then
		if str:find("h") then return num * 3600 end
		if str:find("d") then return num * 86400 end
		if str:find("m") then return num * 60 end
		return num -- assume seconds
	end
	return nil
end

-- Generate a random key (6 alphanumeric characters)
local function generateKey()
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local key = ""
	for i = 1, 6 do
		key = key .. chars:sub(math.random(1, #chars), math.random(1, #chars))
	end
	return key
end

-- Add a key for a username
local function addKeyForUser(username, durationStr)
	local duration = parseDuration(durationStr)
	if not duration then return false, "Invalid duration. Use e.g. 1h, 2d, lifetime." end
	
	local key = generateKey()
	local expiry = duration == math.huge and math.huge or os.time() + duration
	
	-- Store in DataStore (keyed by username)
	local success, err = pcall(function()
		keyStore:SetAsync(username, {key = key, expiry = expiry})
	end)
	if not success then
		return false, "Failed to save key: " .. tostring(err)
	end
	return true, key
end

-- Validate a key for a username
local function validateKey(username, inputKey)
	local data = keyStore:GetAsync(username)
	if not data then return false, "No key found for this username." end
	if data.key ~= inputKey then return false, "Invalid key." end
	if data.expiry ~= math.huge and data.expiry < os.time() then
		return false, "Key has expired."
	end
	return true, "Valid key."
end

-- Remote event handler
remoteEvent.OnServerEvent:Connect(function(player, action, ...)
	local args = {...}
	
	if action == "validate" then
		local username = args[1]
		local key = args[2]
		local success, msg = validateKey(username, key)
		remoteEvent:FireClient(player, "validateResult", success, msg)
	
	elseif action == "addKey" then
		-- Only admins can add keys
		if not table.find(ALLOWED_USERS, player.UserId) then
			remoteEvent:FireClient(player, "addKeyResult", false, "You are not authorized.")
			return
		end
		local targetUsername = args[1]
		local duration = args[2]
		local success, result = addKeyForUser(targetUsername, duration)
		if success then
			remoteEvent:FireClient(player, "addKeyResult", true, "Key generated: " .. result .. " for " .. targetUsername)
		else
			remoteEvent:FireClient(player, "addKeyResult", false, result)
		end
	end
end)

-- Admin chat command handler
game:GetService("Players").PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		if not table.find(ALLOWED_USERS, player.UserId) then return end
		
		local parts = {}
		for word in string.gmatch(msg, "%S+") do
			table.insert(parts, word)
		end
		if #parts < 3 then return end
		
		if parts[1] == "/addkey" then
			local username = parts[2]
			local duration = parts[3]
			local success, result = addKeyForUser(username, duration)
			if success then
				player:Chat("Key for " .. username .. ": " .. result .. " (duration: " .. duration .. ")")
			else
				player:Chat("Error: " .. result)
			end
		end
	end)
end)

print("Whitelist server script loaded.")
