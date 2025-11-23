---
--- Created by xyzzycgn.
---
local global_data = require("scripts.global_data")

local function getAdapter()
    return global_data.getAdapter()
end
-- ###############################################################

local function addAdapter(name)
    getAdapter()[name] = true
end
-- ###############################################################

local function removeAdapter(name)
    getAdapter()[name] = nil
end
-- ###############################################################


local adapterHandling = {
    getAdapter = getAdapter,
    addAdapter = addAdapter,
    removeAdapter = removeAdapter,
}

return adapterHandling