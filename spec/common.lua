---
--- Created by xyzzycgn.
--- common definitions used in busted test
---

_G.serpent = require("serpent") -- must be global

_G.defines = {
    direction = {
        east = 4,
        eastnortheast = 3,
        eastsoutheast = 5,
        north = 0,
        northeast = 2,
        northnortheast = 1,
        northnorthwest = 15,
        northwest = 14,
        south = 8,
        southeast = 6,
        southsoutheast = 7,
        southsouthwest = 9,
        southwest = 10,
        west = 12,
        westnorthwest = 13,
        westsouthwest = 11,
    },
    events = {
        on_player_mined_entity = 1,
        on_robot_mined_entity = 2,
        on_built_entity = 3,
        on_robot_built_entity = 4,
        on_entity_cloned = 5,
        on_entity_died = 6,
        on_runtime_mod_setting_changed = 7,
        on_force_created = 8,
        on_forces_merged = 9,
        on_force_reset = 10,
        on_lua_shortcut = 11,
        on_player_driving_changed_state = 12,
        on_player_removed_equipment = 13,
        on_player_placed_equipment = 14,
    },
    print_sound = {
        use_player_settings = true
    },
    print_skip = {
        if_visible = true
    }
}
-- ###############################################################

_G.storage = {}
-- ###############################################################

local event_num = 1700

_G.script = {
    mod_name = "TEST_OF_MOD",
    generate_event_name = function()
        event_num = event_num + 1
        return event_num
    end,
}
-- ###############################################################

_G.settings = {
    global = {
        ["ufo-logLevel"] = { value = 5 },
        ["ufo-frd-scan-radius"] = { value = 500 },
    },
    startup = {
        ["ufo-mined-ruin-vaults-needed"] = { value = 2 },
    }
}
-- ###############################################################

-- Required by Log.log() from log4factorio
function _G.log()
end

-- mock function table_size (normally provided by the game runtime)
function table_size(table)
    if (table) then
        if (type(table) == "table") then
            local count = 0
            for _ in pairs(table) do
                count = count + 1
            end
            return count
        end
    end

    return 0
end

