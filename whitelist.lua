-- whitelist.lua
return {
    -- Direct whitelist by username (no key required)
    usernames = {
        ["ClaysRetake"] = "lifetime",   -- lifetime access
        -- Add more users like: ["Friend"] = "2h"
    },

    -- Key system: key -> { username, expiry }
    keys = {
        ["123"] = {
            username = "ClaysRetake",   -- must match the player's name
            expiry = "lifetime"         -- or "1h", "2d", etc.
        },
        -- Add more keys as needed
        -- ["abc"] = { username = "Friend", expiry = "1d" }
    }
}
