-- whitelist.lua
return {
    Keys = {
        -- 1 HOUR KEYS (5 Users)
        ["KEY_1H_USER1"] = { owner = "user1", type = "1h", expires = 1787053600 },
        ["KEY_1H_USER2"] = { owner = "user2", type = "1h", expires = 1787053600 },
        ["KEY_1H_USER3"] = { owner = "user3", type = "1h", expires = 1787053600 },
        ["KEY_1H_USER4"] = { owner = "user4", type = "1h", expires = 1787053600 },
        ["KEY_1H_USER5"] = { owner = "user5", type = "1h", expires = 1787053600 },

        -- 1 DAY KEYS (5 Users)
        ["KEY_1D_USER1"] = { owner = "user1", type = "1d", expires = 1787136000 },
        ["KEY_1D_USER2"] = { owner = "user2", type = "1d", expires = 1787136000 },
        ["KEY_1D_USER3"] = { owner = "user3", type = "1d", expires = 1787136000 },
        ["KEY_1D_USER4"] = { owner = "user4", type = "1d", expires = 1787136000 },
        ["KEY_1D_USER5"] = { owner = "user5", type = "1d", expires = 1787136000 },

        -- LIFETIME KEYS (5 Users)
        ["LIFETIME_KEY_USER1"] = { owner = "user1", type = "lifetime" },
        ["LIFETIME_KEY_USER2"] = { owner = "user2", type = "lifetime" },
        ["LIFETIME_KEY_USER3"] = { owner = "user3", type = "lifetime" },
        ["LIFETIME_KEY_USER4"] = { owner = "user4", type = "lifetime" },
        ["LIFETIME_KEY_USER5"] = { owner = "user5", type = "lifetime" }
    }
}
