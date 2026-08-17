-- whitelist.lua
-- Return a table: key = player username, value = { key = "any", expiry = "1h"/"1d"/"lifetime" }
return {
    ["Claysretake"] = { key = "key1", expiry = "lifetime" },
    ["Friend1"] = { key = "key2", expiry = "1d" },    -- 1 day
    ["Friend2"] = { key = "key3", expiry = "2h" },    -- 2 hours
    -- Add more users as needed
}
