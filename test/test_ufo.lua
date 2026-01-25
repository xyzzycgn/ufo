---
--- Created by Junie (AI).
--- Tests for ufo.lua
---
require('test.BaseTest')
local lu = require('luaunit')
local ufo = require('scripts.ufo')
local global_data = require('scripts.global_data')
local adapterHandling = require('scripts.adapterHandling')
local Log = require("__log4factorio__.Log")

TestUfo = {}

function TestUfo:setUp()
    -- Reset storage
    storage.forces = {}
    storage.adapterPrototypes = {}
    storage.adapterData = {}
    storage.adaptees = {}
    storage.force_data = {} -- Assuming this is where force data is stored in global_data

    -- Mock game object
    game = {
        players = {},
        forces = {}
    }

    -- Mock settings
    settings.startup["ufo-mined-ruin-vaults-needed"] = { value = 2 }
    settings.global["ufo-logLevel"] = { value = "INFO" }

    -- Mock defines
    defines.events = {
        on_player_mined_entity = 1,
        on_robot_mined_entity = 2,
        on_built_entity = 3,
        on_robot_built_entity = 4,
        on_entity_cloned = 5,
        on_entity_died = 6,
        on_runtime_mod_setting_changed = 7,
        on_force_created = 8,
        on_forces_merged = 9,
        on_force_reset = 10
    }

    -- Mock script.on_event
    self.events = {}
    script = {
        on_event = function(event_id, handler, filters)
            self.events[event_id] = { handler = handler, filters = filters }
        end,
        active_mods = {}
    }

    -- Mock prototypes
    prototypes = {
        get_entity_filtered = function() return {} end
    }

    -- Reset mocks for tracking calls
    self.adapterDestructionCalled = 0
    self.adapterBuildCalled = 0
    self.researchTriggered = {}

    -- Inject mocks into adapterHandling if necessary, or just monitor its state
    -- In this case, we can mock the functions in adapterHandling because it's required at the top
    self.origHandleDestruction = adapterHandling.handleDestruction
    adapterHandling.handleDestruction = function(entity)
        self.adapterDestructionCalled = self.adapterDestructionCalled + 1
    end

    self.origHandleBuild = adapterHandling.handleBuild
    adapterHandling.handleBuild = function(entity)
        self.adapterBuildCalled = self.adapterBuildCalled + 1
    end
end
-- ###############################################################

function TestUfo:tearDown()
    -- Restore original functions
    adapterHandling.handleDestruction = self.origHandleDestruction
    adapterHandling.handleBuild = self.origHandleBuild
end
-- ###############################################################

--- Test on_init
function TestUfo:test_onInit()
    local force1 = { index = 1, name = "player" }
    game.players = {
        { force = force1 }
    }

    ufo.on_init()

    -- Check if force data was initialized
    local fd = global_data.getForce_data(1)
    lu.assertNotNil(fd)
    lu.assertEquals(fd.num_vaults, 0)
end
-- ###############################################################

--- Test on_player_mined_entity for vault
function TestUfo:test_onMinedEntity_Vault()
    -- Set up force and its technology
    local force = {
        index = 1,
        technologies = {
            ["ufo-archeological-tech"] = { researched = true },
            ["ufo-tech"] = { researched = false },
            ["ufo-fulgoran-know-how-tech"] = { researched = false }
        },
        script_trigger_research = function(name)
            table.insert(self.researchTriggered, name)
        end
    }
    game.players[1] = { force = force }

    -- Initialize force data
    ufo.on_init()

    -- Mock event
    local event = {
        player_index = 1,
        entity = { name = "fulgoran-ruin-vault" }
    }

    -- Trigger handler (manually from the ufo.lua logic)
    -- Since onMinedEntity is local in ufo.lua, we need to get it from script.on_event
    ufo.on_configuration_changed() -- This calls registerEvents()

    local handler = self.events[defines.events.on_player_mined_entity].handler
    lu.assertNotNil(handler)

    -- Mine first vault
    handler(event)
    local fd = global_data.getForce_data(1)
    lu.assertEquals(fd.num_vaults, 1)
    lu.assertEquals(#self.researchTriggered, 0)

    -- Mine second vault (needed is 2)
    handler(event)
    lu.assertEquals(fd.num_vaults, 2)
    lu.assertEquals(self.researchTriggered[1], "ufo-tech")
end
-- ###############################################################

--- Test on_player_mined_entity for adapter
function TestUfo:test_onMinedEntity_Adapter()
    local event = {
        entity = { name = "ufo-adapter-test" }
    }

    ufo.on_configuration_changed()
    local handler = self.events[defines.events.on_player_mined_entity].handler

    handler(event)
    lu.assertEquals(self.adapterDestructionCalled, 1)
end
-- ###############################################################

--- Test on_built_entity
function TestUfo:test_onBuiltEntity()
    local event = {
        entity = { name = "ufo-adapter-test" }
    }

    ufo.on_configuration_changed()
    local handler = self.events[defines.events.on_built_entity].handler

    handler(event)
    lu.assertEquals(self.adapterBuildCalled, 1)
end
-- ###############################################################

--- Test entity_died
function TestUfo:test_entityDied()
    local event = {
        entity = { name = "ufo-adapter-test" }
    }

    ufo.on_configuration_changed()
    local handler = self.events[defines.events.on_entity_died].handler

    handler(event)
    lu.assertEquals(self.adapterDestructionCalled, 1)
end
-- ###############################################################

--- Test setting change
function TestUfo:test_changeSettings()
    local event = {
        setting = "ufo-logLevel"
    }
    -- Mock settings.global value
    settings.global["ufo-logLevel"] = { value = "FINE" }

    local handler = ufo.events[defines.events.on_runtime_mod_setting_changed]
    lu.assertNotNil(handler)

    handler(event)
    lu.assertEquals(Log.getSeverity(), Log.FINE)
end
-- ###############################################################

--- Test dig4tech for second stage research
function TestUfo:test_dig4tech_SecondStage()
    local force = {
        index = 1,
        technologies = {
            ["ufo-archeological-tech"] = { researched = true },
            ["ufo-tech"] = { researched = true },
            ["ufo-fulgoran-know-how-tech"] = { researched = false }
        },
        script_trigger_research = function(name)
            table.insert(self.researchTriggered, name)
        end
    }
    game.players[1] = { force = force }

    ufo.on_init()
    local fd = global_data.getForce_data(1)
    -- Need 2 * 1.5 = 3 vaults
    fd.num_vaults = 2

    local event = {
        player_index = 1,
        entity = { name = "fulgoran-ruin-vault" }
    }

    ufo.on_configuration_changed()
    local handler = self.events[defines.events.on_player_mined_entity].handler

    handler(event)
    lu.assertEquals(fd.num_vaults, 3)
    lu.assertEquals(self.researchTriggered[1], "ufo-fulgoran-know-how-tech")
end
-- ###############################################################

BaseTest:hookTests()
