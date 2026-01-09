---
--- Created by xyzzycgn.
--- DateTime: 28.12.24 14:43
---
--- executes all tests

local Require = require("test.require")
require = Require.replace(require)

local lu = require('luaunit')
serpent=require('serpent') -- must be global

--########################################################
-- needed by Log.log() which is called by some tests
function log()
end

-- mock several global objects - normally provided by game
settings = {
    global = {
        ["ufo-logLevel"] = { value = 5 }, -- == Log.INFO
    },
    startup = {
        ["ufo-mined-ruin-vaults-needed"] = { value = 2 },
    }
}

storage = {
    forces = {},
    adapterPrototypes = {},
    adapterData = {},
    adaptees = {}
}

script = {
    mod_name = "TEST_OF_MOD",
}

defines = {
    events = {
        on_runtime_mod_setting_changed = 7,
        on_force_created = 8,
        on_forces_merged = 9,
        on_force_reset = 10
    },
    print_sound = {
        use_player_settings = true
    },
    print_skip = {
        if_visible = true
    }
}

--########################################################

BaseTest = {
    hooked = false
}

function BaseTest:hookTests()
    if (not self.hooked) then
        os.exit(lu.LuaUnit.run())
        self.hooked = true
    end
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

-- mock function log() (normally provided by the game runtime)
function log()
end

