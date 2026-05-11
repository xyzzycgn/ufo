---
--- Created by xyzzycgn.
---
local Require = require("test.require")
_G.require = Require.replace(_G.require)

local assert = require("luassert")
local adapterHandling
local global_data

describe("adapterHandling", function()
    local function init_factorio_globals()
        _G.storage = {
            forces = {},
            adapterPrototypes = {
                ["test-pole"] = true,
                ["test-pole2"] = true,
            },
            adapterData = {},
            adaptees = {}
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
            active_mods = {}
        }

        _G.defines = {
            gui_type = {},
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

        _G.log = function()
        end

        _G.table_size = function(table)
            if type(table) ~= "table" then
                return 0
            end

            local count = 0
            for _ in pairs(table) do
                count = count + 1
            end

            return count
        end
    end

    setup(function()
        init_factorio_globals()

        -- must be done here - after running init_factorio_globals()
        adapterHandling = require("scripts.adapterHandling")
        global_data = require("scripts.global_data")
    end)

    before_each(init_factorio_globals)

    it("adds an adapter prototype to an empty list", function()
        storage.adapterPrototypes = {}

        adapterHandling.addAdapterPrototype("test-pole")

        assert.are.same({
            ["test-pole"] = true
        }, storage.adapterPrototypes)
    end)

    it("adds an adapter prototype", function()
        adapterHandling.addAdapterPrototype("test-pole3")

        assert.are.same({
            ["test-pole"] = true,
            ["test-pole2"] = true,
            ["test-pole3"] = true
        }, storage.adapterPrototypes)
    end)

    it("removes an adapter prototype", function()
        adapterHandling.removeAdapterPrototype("test-pole")

        assert.are.same({
            ["test-pole2"] = true
        }, storage.adapterPrototypes)
    end)

    it("handles building an adapter without attractors in range", function()
        local prototype = {
            get_supply_area_distance = function()
                return 3.5
            end
        }

        local surface = {
            find_entities_filtered = function(_)
                return {}
            end,
        }

        local spied_surface = spy.on(surface, "find_entities_filtered")

        local adapterEntity = {
            position = { x = 1, y = 2 },
            name = "test-adapter",
            unit_number = 4711,
            quality = "HQ",
            prototype = prototype,
            surface = surface,
        }

        adapterHandling.handleBuild(adapterEntity)
        assert.spy(spied_surface).was_called_with({
            area = { { x = -2.5, y = -1.5 }, { x = 4.5, y = 5.5 } },
            name = { "fulgoran-ruin-attractor", "ufo-adapted-attractor" }
        })
    end)

    it("handles building an adapter near a ruin attractor", function()
        storage.adapterData = {}

        local attractor = {
            name = "fulgoran-ruin-attractor",
            position = { x = 2.5, y = 3.5 },
            direction = 2,
            force = {
                index = 1,
            },
            destroy = function()
                return true
            end
        }

        local spied_attractor = spy.on(attractor, "destroy")

        local adapter = {
            name = "ufo-adapted-attractor",
            position = { x = 2.5, y = 3.5 },
            direction = 2,
            force = {
                index = 1,
            },
            unit_number = 815,
        }

        local prototype = {
            get_supply_area_distance = function()
                return 3.5
            end
        }

        local surface = {
            find_entities_filtered = function(_)
                return { attractor }
            end,

            create_entity = function(_)
                return adapter
            end,
        }

        local mocked_surface = mock(surface)

        attractor.surface = surface

        local adapterEntity = {
            position = { x = 1, y = 2 },
            name = "test-adapter",
            unit_number = 4711,
            quality = "HQ",
            prototype = prototype,
            surface = surface,
        }

        adapterHandling.handleBuild(adapterEntity)


        assert.spy(mocked_surface.find_entities_filtered).was_called_with({
            area = { { x = -2.5, y = -1.5 }, { x = 4.5, y = 5.5 } },
            name = { "fulgoran-ruin-attractor", "ufo-adapted-attractor" }
        })
        assert.spy(mocked_surface.create_entity).was_called_with({
            direction = 2,
            force = 1,
            name = "ufo-adapted-attractor",
            position = { x = 2.5, y = 3.5 },
            create_build_effect_smoke = false,
        })

        assert.spy(spied_attractor).was_called(1)

        assert.are.same({
            ["test-adapter"] = {
                [4711] = {
                    adaptees = { [815] = true },
                    dist = 3.5,
                    pos = { x = 1, y = 2 }
                }
            }
        }, global_data.getAdapterData())

        assert.are.same({
            [815] = {
                adaptedBy = { [4711] = true },
                direction = 2,
                force = 1,
                pos = { x = 2.5, y = 3.5 },
                entity = {
                    direction = 2,
                    force = { index = 1 },
                    name = "ufo-adapted-attractor",
                    position = { x = 2.5, y = 3.5 },
                    unit_number = 815
                },
            }
        }, global_data.getAdaptees())
    end)

    it("handles building an adapter near an already adapted attractor", function()
        storage.adaptees = {
            [815] = {
                adaptedBy = { [4711] = true },
                direction = 2,
                force = 1,
                pos = { x = 2.5, y = 3.5 }
            }
        }

        storage.adapterData = {
            ["test-adapter"] = {
                [4711] = {
                    adaptees = { [815] = true },
                    dist = 3.5,
                    pos = { x = 1, y = 2 }
                }
            }
        }

        local attractor = {
            name = "ufo-adapted-attractor",
            position = { x = 2.5, y = 3.5 },
            direction = 2,
            force = {
                index = 1,
            },
            unit_number = 815,
        }

        local prototype = {
            get_supply_area_distance = function()
                return 3.5
            end
        }

        local surface = {
            find_entities_filtered = function(_)
                return { attractor }
            end,
        }
        local spied_surface = spy.on(surface, "find_entities_filtered")

        attractor.surface = surface

        local adapterEntity = {
            position = { x = 2, y = 3 },
            name = "test-adapter",
            unit_number = 1234,
            quality = "HQ",
            prototype = prototype,
            surface = surface,
        }

        adapterHandling.handleBuild(adapterEntity)

        assert.spy(spied_surface).was_called_with({
            area = { { x = -1.5, y = -0.5 }, { x = 5.5, y = 6.5 } },
            name = { "fulgoran-ruin-attractor", "ufo-adapted-attractor" }
        })

        assert.are.same({
            ["test-adapter"] = {
                [4711] = {
                    adaptees = { [815] = true },
                    dist = 3.5,
                    pos = { x = 1, y = 2 }
                },
                [1234] = {
                    adaptees = { [815] = true },
                    dist = 3.5,
                    pos = { x = 2, y = 3 }
                }
            }
        }, global_data.getAdapterData())

        assert.are.same({
            [815] = {
                adaptedBy = { [4711] = true, [1234] = true },
                direction = 2,
                force = 1,
                pos = { x = 2.5, y = 3.5 }
            }
        }, global_data.getAdaptees())
    end)

    it("handles destruction of an adapted attractor", function()
        storage.adapterData = {
            ["test-adapter"] = {
                [4711] = {
                    adaptees = { [815] = true },
                    dist = 3.5,
                    pos = { x = 1, y = 2 }
                },
                [4712] = {
                    adaptees = { [815] = true, [816] = true },
                    dist = 3.5,
                    pos = { x = 11, y = 12 }
                }
            }
        }

        storage.adaptees = {
            [815] = {
                adaptedBy = { [4711] = true, [4712] = true },
                direction = 2,
                force = 1,
                pos = { x = 2.5, y = 3.5 }
            },
            [816] = {
                adaptedBy = { [4712] = true },
                direction = 2,
                force = 1,
                pos = { x = 12.5, y = 13.5 }
            }
        }

        local attractor = {
            name = "ufo-adapted-attractor",
            position = { x = 2.5, y = 3.5 },
            direction = 2,
            force = {
                index = 1,
            },
            unit_number = 815,
        }

        adapterHandling.handleDestruction(attractor)

        assert.are.same({
            ["test-adapter"] = {
                [4712] = {
                    adaptees = { [816] = true },
                    dist = 3.5,
                    pos = { x = 11, y = 12 }
                }
            }
        }, global_data.getAdapterData())

        assert.are.same({
            [816] = {
                adaptedBy = { [4712] = true },
                direction = 2,
                force = 1,
                pos = { x = 12.5, y = 13.5 }
            }
        }, global_data.getAdaptees())
    end)

    it("handles destruction of an adapter", function()
        local surface = {
            create_entity = function(_)
            end,
        }

        storage.adapterData = {
            ["test-adapter"] = {
                [4711] = {
                    adaptees = { [815] = true },
                    dist = 3.5,
                    pos = { x = 1, y = 2 }
                },
                [4712] = {
                    adaptees = { [815] = true, [816] = true },
                    dist = 3.5,
                    pos = { x = 11, y = 12 }
                }
            }
        }

        storage.adaptees = {
            [815] = {
                adaptedBy = { [4711] = true, [4712] = true },
                direction = 2,
                force = 1,
                pos = { x = 2.5, y = 3.5 },
                entity = {
                    direction = 2,
                    force = { index = 1 },
                    name = "ufo-adapted-attractor",
                    position = { x = 2.5, y = 3.5 },
                    unit_number = 815,
                    surface = surface
                },
            },
            [816] = {
                adaptedBy = { [4712] = true },
                direction = 2,
                force = 1,
                pos = { x = 12.5, y = 13.5 },
                entity = {
                    direction = 2,
                    force = { index = 1 },
                    name = "ufo-adapted-attractor",
                    position = { x = 12.5, y = 13.5 },
                    unit_number = 816,
                    destroy = function()
                        return true
                    end,
                    surface = surface
                },
            }
        }

        local adapter = {
            name = "test-adapter",
            position = { x = 11, y = 12 },
            force = {
                index = 1,
            },
            unit_number = 4712,
            surface = surface,
            destroy = function()
                return true
            end
        }

        local spied_adapter = spy.on(adapter, "destroy")
        local spied_816 = spy.on(storage.adaptees[816].entity, "destroy")

        adapterHandling.handleDestruction(adapter)

        assert.spy(spied_816).was_called(1)
        assert.spy(spied_adapter).was_not_called()

        assert.are.same({
            ["test-adapter"] = {
                [4711] = {
                    adaptees = { [815] = true },
                    dist = 3.5,
                    pos = { x = 1, y = 2 }
                },
            }
        }, global_data.getAdapterData())

        assert.are.same({
            [815] = {
                adaptedBy = { [4711] = true },
                direction = 2,
                force = 1,
                pos = { x = 2.5, y = 3.5 },
                entity = {
                    direction = 2,
                    force = { index = 1 },
                    name = "ufo-adapted-attractor",
                    position = { x = 2.5, y = 3.5 },
                    unit_number = 815,
                    surface = surface
                },
            },
        }, global_data.getAdaptees())
    end)
end)
