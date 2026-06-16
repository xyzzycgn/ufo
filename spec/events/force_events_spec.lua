---
--- Tests for scripts/events/force.lua
---
local Require = require("test.require")
_G.require = Require.replace(require)

local assert = require("luassert")

local force_events
local global_data
local Log

describe("force events", function()
    local function reset_factorio_globals()
        _G.storage = {
            forces = {},
            adapterPrototypes = {},
            adapterData = {},
            adaptees = {},
            protectedVaults = {},
            playerData = {},
        }

        _G.settings = {
            global = {
                ["ufo-logLevel"] = { value = 5 },
            }
        }

        _G.defines = {
        }

        _G.log = function()
        end
    end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    setup(function()
        reset_factorio_globals()

        Log = require("__log4factorio__.Log")
        global_data = require("scripts.global_data")
        force_events = require("scripts.events.force")
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    before_each(function()
        reset_factorio_globals()
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("initializes force data when a force is created", function()
        local event = {
            force = {
                index = 1,
                name = "player"
            }
        }

        force_events.onForceCreated(event)

        local fd = global_data.getForce_data(1)

        assert.is_not_nil(fd)
        assert.are.equal(0, fd.num_vaults)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("does not overwrite existing force data when force is created again", function()
        local force = {
            index = 1,
            name = "player"
        }

        global_data.addForce_data(force, {
            num_vaults = 7,
            techLevel = 3
        })

        force_events.onForceCreated({
            force = force
        })

        local fd = global_data.getForce_data(1)

        assert.is_not_nil(fd)
        assert.are.equal(7, fd.num_vaults)
        assert.are.equal(3, fd.techLevel)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("deletes source force data when forces are merged", function()
        local source_force = {
            index = 1,
            name = "source"
        }

        global_data.addForce_data(source_force, {
            num_vaults = 4
        })

        force_events.onForcesMerged({
            source_index = 1
        })

        local fd = global_data.getForce_data(1)

        assert.is_nil(fd)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("resets techLevel when force is reset", function()
        local force = {
            index = 1,
            name = "player"
        }

        global_data.addForce_data(force, {
            num_vaults = 2,
            techLevel = 5
        })

        force_events.onForceReset({
            force = force
        })

        local fd = global_data.getForce_data(1)

        assert.is_not_nil(fd)
        assert.are.equal(2, fd.num_vaults)
        assert.are.equal(0, fd.techLevel)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("does nothing when resetting an unknown force", function()
        local event = {
            force = {
                index = 99,
                name = "unknown"
            }
        }

        assert.has_no.errors(function()
            force_events.onForceReset(event)
        end)

        assert.is_nil(global_data.getForce_data(99))
    end)
end)
