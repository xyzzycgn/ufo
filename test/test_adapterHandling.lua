---
--- Created by xyzzycgn.
--- DateTime: 28.12.24 10:31
---
require('test.BaseTest')
local lu = require('luaunit')
local adapterHandling = require('scripts.adapterHandling')

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

TestAdapterHandling = {}

function TestAdapterHandling:setUp()
end
-- ###############################################################

function TestAdapterHandling:test_addAdapterPrototype()
    adapterHandling.addAdapterPrototype("test-pole")

    local erg = storage.adapterPrototypes
    lu.assertEquals({ ["test-pole"] = true }, erg)

    adapterHandling.addAdapterPrototype("test-pole2")
    lu.assertEquals({ ["test-pole"] = true,
                      ["test-pole2"] = true,}, erg)
end
-- ###############################################################

function TestAdapterHandling:test_removeAdapterPrototype()
    storage.adapterPrototypes = { ["test-pole"] = true, ["test-pole2"] = true, }

    adapterHandling.removeAdapterPrototype("test-pole")

    local erg = storage.adapterPrototypes
    lu.assertEquals({ ["test-pole2"] = true }, erg)
end
-- ###############################################################

BaseTest:hookTests()
