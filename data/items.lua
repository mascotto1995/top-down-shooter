return {
    -- Consumables
    health_pack = {
        name = "Health Pack",
        type = "consumable",
        effect = "heal",
        value = 50,
        sprite = "",
        rarity = "common",
        stack_size = 5
    },

    stim = {
        name = "Stim",
        type = "consumable",
        effect = "speed_boost",
        value = 1.5, -- speed multiplier
        duration = 15, -- seconds
        sprite = "",
        rarity = "common"
    },

    -- Permanent upgrades
    damage_upgrade = {
        name = "Damage Boost",
        type = "permanent",
        effect = "damage_multiplier",
        value = 1.1,
        sprite = "",
        rarity = "uncommon",
        description = "Increases all weapon damage by 10%"
    },

    extra_life = {
        name = "Extra Life",
        type = "permanent",
        effect = "revive_on_death",
        value = 1,
        sprite = "",
        rarity = "rare",
        description = "Revive once upon death"
    },

    -- Currency
    coin = {
        name = "Coin",
        type = "currency",
        value = 1,
        sprite = "",
        rarity = "common"
    }
}