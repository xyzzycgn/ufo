---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
Log.setSeverity(Log.CONFIG)

require("__use-fulguran-objects__.scripts.prototypes.sand")
require("__use-fulguran-objects__.scripts.prototypes.fulguran-ruin-attractor")
require("__use-fulguran-objects__.scripts.prototypes.fulgoran-know-how")
require("__use-fulguran-objects__.scripts.prototypes.electric-furnace")
require("__use-fulguran-objects__.scripts.prototypes.electro-magnetic-plant")
require("__use-fulguran-objects__.scripts.prototypes.recycler")
require("__use-fulguran-objects__.scripts.prototypes.fulguran-relic-detector")
require("__use-fulguran-objects__.scripts.prototypes.beacon")
require("__use-fulguran-objects__.scripts.prototypes.electrodynamic_fragmentation")
require("__use-fulguran-objects__.scripts.prototypes.achievements")

if mods["Electric_flying_enemies"] then
    Log.log("mod Electric_flying_enemies detected", function(m)log(m)end, Log.CONFIG)
    require("__use-fulguran-objects__.scripts.prototypes.fulguran-enemies")
end
