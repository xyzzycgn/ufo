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
        default_value = "INFO",
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
}

if mods["Electric_flying_enemies"] then
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
