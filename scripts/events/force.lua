---
--- Created by xyzzycgn.
--- DateTime: 27.10.25 15:20
---
--- handles game events related to forces
local global_data = require("scripts.global_data")
local force_data = require("scripts.force_data")
local Log = require("__log4factorio__.Log")

--- @param event EventData
local function onForceCreated(event)
    Log.logEvent(event, function(m)log(m)end, Log.FINER)

    global_data.addForce_data(event.force, force_data.init_force_data())
end
-- ###############################################################

--- @param event EventData
local function onForcesMerged(event)
    Log.logEvent(event, function(m)log(m)end, Log.FINER)
    global_data.deleteForce_data(event.source_index)
end
-- ###############################################################

--- @param event EventData
local function onForceReset(event)
    Log.logEvent(event, function(m)log(m)end, Log.FINER)

    local fd = global_data.getForce_data(event.force.index)
    if fd then
        fd.techLevel = 0
    end
end
-- ###############################################################

local force = {
    onForceCreated = onForceCreated,
    onForcesMerged = onForcesMerged,
    onForceReset = onForceReset,
}

return force