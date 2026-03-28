---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
Log.setSeverity(Log.CONFIG)

require("__ufo__.scripts.prototypes.sand")
require("__ufo__.scripts.prototypes.fulguran-ruin-attractor")
require("__ufo__.scripts.prototypes.fulgoran-know-how")
require("__ufo__.scripts.prototypes.electric-furnace")
require("__ufo__.scripts.prototypes.electro-magnetic-plant")
require("__ufo__.scripts.prototypes.recycler")
require("__ufo__.scripts.prototypes.fulguran-relic-detector")
require("__ufo__.scripts.prototypes.beacon")
require("__ufo__.scripts.prototypes.achievements")

if mods["Electric_flying_enemies"] then
    Log.log("mod Electric_flying_enemies detected", function(m)log(m)end, Log.CONFIG)
    require("__ufo__.scripts.prototypes.fulguran-enemies")
end
