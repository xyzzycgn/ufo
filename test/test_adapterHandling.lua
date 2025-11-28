---
--- Created by xyzzycgn.
--- DateTime: 28.12.24 10:31
---
require('test.BaseTest')
local lu = require('luaunit')
local adapterHandling = require('scripts.adapterHandling')
local global_data = require('scripts.global_data')

-- ###############################################################

local arg2find
local arg2create
local arg2destroy
local destroyCalled

-- ###############################################################

TestAdapterHandling = {}

function TestAdapterHandling:setUp()
    storage.adapterPrototypes = {
        ["test-pole"] = true,
        ["test-pole2"] = true,
    }
    arg2find = nil
    arg2create = nil
    arg2destroy = nil
    destroyCalled = 0
end
-- ###############################################################

function TestAdapterHandling:test_addAdapterPrototypeToEmptyList()
    storage.adapterPrototypes = {}
    adapterHandling.addAdapterPrototype("test-pole")

    local erg = storage.adapterPrototypes
    lu.assertEquals({ ["test-pole"] = true }, erg)
end
-- ###############################################################

function TestAdapterHandling:test_addAdapterPrototype()
    adapterHandling.addAdapterPrototype("test-pole3")

    local erg = storage.adapterPrototypes
    lu.assertEquals({ ["test-pole"] = true, ["test-pole2"] = true, ["test-pole3"] = true }, erg)
end
-- ###############################################################

function TestAdapterHandling:test_removeAdapterPrototype()
    adapterHandling.removeAdapterPrototype("test-pole")

    local erg = storage.adapterPrototypes
    lu.assertEquals({ ["test-pole2"] = true }, erg)
end
-- ###############################################################

-- test no attractor in range of adapter
function TestAdapterHandling:test_handleBuildNoNeighbour()
    -- mock the prototype
    local prototype = {
         get_supply_area_distance = function() return 3.5 end
    }
    -- and the surface
    local surface = {
        find_entities_filtered = function(arg)
            arg2find = arg
            return {}
        end,
    }

    local adapterEntity = {
        position = { x = 1, y = 2 },
        name = "test-adapter",
        unit_number = 4711,
        quality = "HQ",
        prototype = prototype,
        surface = surface,
    }

    adapterHandling.handleBuild(adapterEntity)

    lu.assertNil(arg2create)
    lu.assertEquals({
        area = { { x = -2.5, y = -1.5 }, { x = 4.5, y = 5.5 } },
        name = { "fulgoran-ruin-attractor", "ufo-adapted-attractor" }
    }, arg2find)
end
-- ###############################################################

-- test a ruin attractor in range of adapter
function TestAdapterHandling:test_handleBuildOneRuinAttractor()
    storage.adapterData = {}

    local attractor = {
         name = "fulgoran-ruin-attractor",
         position = { x = 2.5, y = 3.5 },
         direction = 2,
         force = {
            index = 1,
         },
         destroy = function(arg)
             arg2destroy = arg
             destroyCalled = destroyCalled + 1
             return true
         end
    }

    local adapter = {
         name = "ufo-adapted-attractor",
         position = { x = 2.5, y = 3.5 },
         direction = 2,
         force = {
            index = 1,
         },
         unit_number = 815,
    }

    -- mock the prototype
    local prototype = {
         get_supply_area_distance = function() return 3.5 end
    }
    -- and the surface
    local surface = {
        find_entities_filtered = function(arg)
            arg2find = arg
            return { attractor }
        end,

        create_entity = function(arg)
            arg2create = arg
            return adapter
        end,
    }

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

    lu.assertEquals(destroyCalled, 1)
    lu.assertEquals(arg2create, { direction = 2, force = 1, name = "ufo-adapted-attractor", position = { x = 2.5, y = 3.5 }})
    lu.assertEquals(arg2find, {
        area = { { x = -2.5, y = -1.5 }, { x = 4.5, y = 5.5 } },
        name = { "fulgoran-ruin-attractor", "ufo-adapted-attractor" }
    })

    lu.assertEquals(global_data.getAdapterData(), {
        ["test-adapter"] = {
            [4711] = {
                adaptees = { [815] = true },
                dist = 3.5,
                pos = { x = 1, y = 2 }
            }
        }
    })
    lu.assertEquals(global_data.getAdaptees(), {
        [815] = {
            adaptedBy = { [4711] = true },
            direction = 2,
            force = 1,
            pos = { x = 2.5, y = 3.5 }
        }
    })
end
-- ###############################################################

-- test an already adapted attractor in range of adapter
function TestAdapterHandling:test_handleBuildOneAdaptedAttractor()
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
         -- no call to destroy() expected => no need to define
    }

    -- mock the prototype
    local prototype = {
         get_supply_area_distance = function() return 3.5 end
    }
    -- and the surface
    local surface = {
        find_entities_filtered = function(arg)
            arg2find = arg
            return { attractor }
        end,

        -- no call to create_entity expected => no need to define
    }

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

    lu.assertNil(arg2create)
    lu.assertEquals(arg2find, {
        area = { { x = -1.5, y = -0.5 }, { x = 5.5, y = 6.5 } },
        name = { "fulgoran-ruin-attractor", "ufo-adapted-attractor" }
    })

    lu.assertEquals(global_data.getAdapterData(), {
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
    })
    lu.assertEquals(global_data.getAdaptees(), {
        [815] = {
            adaptedBy = { [4711] = true, [1234] = true },
            direction = 2,
            force = 1,
            pos = { x = 2.5, y = 3.5 }
        }
    })
end
-- ###############################################################

-- test remove an adapted attractor
function TestAdapterHandling:test_handleDestruction()
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

    lu.assertEquals(global_data.getAdapterData(), {
        ["test-adapter"] = {
            [4712] = {
                adaptees = { [816] = true },
                dist = 3.5,
                pos = { x = 11, y = 12 }
            }
        }
    })
    lu.assertEquals(global_data.getAdaptees(), {
        [816] = {
            adaptedBy = { [4712] = true },
            direction = 2,
            force = 1,
            pos = { x = 12.5, y = 13.5 }
        }
    })
end
-- ###############################################################

BaseTest:hookTests()
