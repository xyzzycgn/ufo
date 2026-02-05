local settings = {
    -- Startup
    {
        type = 'int-setting',
        name = 'ufo-mined-ruin-vaults-needed',
        setting_type = 'startup',
        minimum_value = 5,
        maximum_value = 30,
        default_value = 5,
        order = 'a',
    },

    -- runtime
    {
        type = "string-setting",
        name = "ufo-logLevel",
        order = "zz",
        setting_type = "runtime-global",
        default_value = "CONFIG",
        allowed_values = {
            "FATAL",
            "ERROR",
            "WARN",
            "INFO",
            "CONFIG",
            "FINE",
            "FINER",
            "FINEST",
        }
    },

    {
        type = 'color-setting',
        name = 'ufo-frd-vaults-color',
        setting_type = "runtime-global",
        default_value = { r = 0.8, g = 0, b = 0, a = 1 },
        order = 'a',
    },
}

if mods["Electric_flying_enemies"] then
    settings[#settings + 1] = {
        type = 'color-setting',
        name = 'ufo-frd-shard-color',
        setting_type = "runtime-global",
        default_value = { r = 0.5, g = 0.5, b = 1, a = 1 },
        order = 'b',
    }

    settings[#settings + 1] = {
        -- Startup
        type = 'bool-setting',
        name = 'ufo-fe-resonance-shard-disables-vault-guardian',
        setting_type = 'startup',
        default_value = true,
        order = 'b',
    }
end


data:extend(settings)
