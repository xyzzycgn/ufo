---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
Log.setSeverity(Log.CONFIG)

local fulg_attr = data.raw["lightning-attractor"]["fulgoran-ruin-attractor"]

fulg_attr.energy_source = {
    buffer_capacity = "2000MJ",
    drain = "2.5GJ",
    output_flow_limit = "2000MJ",
    type = "electric",
    usage_priority = "primary-output"
  }
fulg_attr.efficiency = 0.45

-- der fulgoriansichw blitzableiter
Log.logBlock(data.raw["lightning-attractor"]["fulgoran-ruin-attractor"], function(m)log(m)end)
