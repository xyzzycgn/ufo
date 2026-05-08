---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
Log.setSeverity(Log.CONFIG)

require("scripts.prototypes.sand")
require("scripts.prototypes.fulguran-ruin-attractor")
require("scripts.prototypes.fulgoran-know-how")
require("scripts.prototypes.electric-furnace")
require("scripts.prototypes.electro-magnetic-plant")
require("scripts.prototypes.recycler")
require("scripts.prototypes.fulguran-relic-detector")
require("scripts.prototypes.beacon")
require("scripts.prototypes.electrodynamic_fragmentation")
require("scripts.prototypes.achievements")

if mods["Electric_flying_enemies"] then
    Log.log("mod Electric_flying_enemies detected", function(m)log(m)end, Log.CONFIG)
    require("scripts.prototypes.fulguran-enemies")
end
