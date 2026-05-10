---
--- Created by Junie (AI).
--- Tests for ufo.lua
---
local Require = require("test.require")
_G.require = Require.replace(require)

local assert = require("luassert")
serpent = require("serpent")

local ufo
local global_data
local adapterHandling
local Log


_G.log = function()
end

_G.table_size = function(tbl)
    if type(tbl) ~= "table" then
        return 0
    end

    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end

    return count
end

describe("ufo", function()
    local events
    local adapterDestructionCalled
    local adapterBuildCalled
    local researchTriggered
    local origHandleDestruction
    local origHandleBuild

    local function init_factorio_globals()
        _G.storage = {
            forces = {},
            adapterPrototypes = {},
            adapterData = {},
            adaptees = {},
            force_data = {},
            protectedVaults = {},
            playerData = {},
        }

        _G.game = {
            players = {},
            forces = {}
        }

        _G.settings = {
            global = {
                ["ufo-logLevel"] = { value = 5 },
                ["ufo-frd-scan-radius"] = { value = 500 },
            },
            startup = {
                ["ufo-mined-ruin-vaults-needed"] = { value = 2 },
            }
        }

        _G.script = {
            mod_name = "TEST_OF_MOD",
            on_event = function(event_id, handler, filters)
                events[event_id] = {
                    handler = handler,
                    filters = filters
                }
            end,
            active_mods = {}
        }

        _G.prototypes = {
            get_entity_filtered = function()
                return {}
            end
        }

        _G.defines = {
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

        events = {}
    end

    setup(function()
        init_factorio_globals()

        -- must be done here - after running init_factorio_globals()
        adapterHandling = require("scripts.adapterHandling")
        global_data = require("scripts.global_data")
        Log = require("__log4factorio__.Log")
        ufo = require("scripts.ufo")
    end)

    before_each(function()
        init_factorio_globals()

        adapterDestructionCalled = 0
        adapterBuildCalled = 0
        researchTriggered = {}

        origHandleDestruction = adapterHandling.handleDestruction
        adapterHandling.handleDestruction = function()
            adapterDestructionCalled = adapterDestructionCalled + 1
        end

        origHandleBuild = adapterHandling.handleBuild
        adapterHandling.handleBuild = function()
            adapterBuildCalled = adapterBuildCalled + 1
        end
    end)

    after_each(function()
        adapterHandling.handleDestruction = origHandleDestruction
        adapterHandling.handleBuild = origHandleBuild
    end)

    it("initialisiert Force-Daten in on_init", function()
        local force1 = {
            index = 1,
            name = "player"
        }

        game.players = {
            { force = force1 }
        }

        ufo.on_init()

        local fd = global_data.getForce_data(1)

        assert.is_not_nil(fd)
        assert.are.equal(0, fd.num_vaults)
    end)

    it("zählt geminte Vaults und triggert ufo-tech nach Erreichen des Schwellwerts", function()
        local force = {
            index = 1,
            technologies = {
                ["ufo-archeological-tech"] = { researched = true },
                ["ufo-tech"] = { researched = false },
                ["ufo-fulgoran-know-how-tech"] = { researched = false }
            },
            script_trigger_research = function(name)
                table.insert(researchTriggered, name)
            end
        }

        game.players[1] = {
            force = force
        }

        ufo.on_init()

        local event = {
            player_index = 1,
            entity = {
                name = "fulgoran-ruin-vault"
            }
        }

        ufo.on_configuration_changed()

        local handler = events[defines.events.on_player_mined_entity].handler

        assert.is_not_nil(handler)

        handler(event)

        local fd = global_data.getForce_data(1)

        assert.are.equal(1, fd.num_vaults)
        assert.are.equal(0, #researchTriggered)

        handler(event)

        assert.are.equal(2, fd.num_vaults)
        assert.are.equal("ufo-tech", researchTriggered[1])
    end)

    it("delegiert beim Minen eines Adapters an adapterHandling.handleDestruction", function()
        local event = {
            entity = {
                name = "ufo-adapter-test"
            }
        }

        ufo.on_configuration_changed()

        local handler = events[defines.events.on_player_mined_entity].handler

        handler(event)

        assert.are.equal(1, adapterDestructionCalled)
    end)

    it("delegiert beim Bauen eines Adapters an adapterHandling.handleBuild", function()
        local event = {
            entity = {
                name = "ufo-adapter-test"
            }
        }

        ufo.on_configuration_changed()

        local handler = events[defines.events.on_built_entity].handler

        handler(event)

        assert.are.equal(1, adapterBuildCalled)
    end)

    it("delegiert bei Entity-Tod an adapterHandling.handleDestruction", function()
        local event = {
            entity = {
                name = "ufo-adapter-test"
            }
        }

        ufo.on_configuration_changed()

        local handler = events[defines.events.on_entity_died].handler

        handler(event)

        assert.are.equal(1, adapterDestructionCalled)
    end)

    it("ändert das Log-Level bei Runtime-Setting-Änderung", function()
        local event = {
            setting = "ufo-logLevel"
        }

        settings.global["ufo-logLevel"] = {
            value = "FINE"
        }

        local handler = ufo.events[defines.events.on_runtime_mod_setting_changed]

        assert.is_not_nil(handler)

        handler(event)

        assert.are.equal(Log.FINE, Log.getSeverity())
    end)

    it("triggert fulgoran-know-how-tech nach genügend weiteren Vaults", function()
        local force = {
            index = 1,
            technologies = {
                ["ufo-archeological-tech"] = { researched = true },
                ["ufo-tech"] = { researched = true },
                ["ufo-fulgoran-know-how-tech"] = { researched = false }
            },
            script_trigger_research = function(name)
                table.insert(researchTriggered, name)
            end
        }

        game.players[1] = {
            force = force
        }

        ufo.on_init()

        local fd = global_data.getForce_data(1)
        fd.num_vaults = 2

        local event = {
            player_index = 1,
            entity = {
                name = "fulgoran-ruin-vault"
            }
        }

        ufo.on_configuration_changed()

        local handler = events[defines.events.on_player_mined_entity].handler

        handler(event)

        assert.are.equal(3, fd.num_vaults)
        assert.are.equal("ufo-fulgoran-know-how-tech", researchTriggered[1])
    end)
end)
