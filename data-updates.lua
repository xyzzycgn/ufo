---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
Log.setSeverity(Log.CONFIG)

require("__ufo__.scripts.prototypes.fulguran-ruin-attractor")
require("__ufo__.scripts.prototypes.fulgoran-know-how")
require("__ufo__.scripts.prototypes.electro-magnetic-plant")
require("__ufo__.scripts.prototypes.recycler")
require("__ufo__.scripts.prototypes.fulguran-relic-detector")

if mods['liquid_recycler'] then
    local olr = require("__ufo__.scripts.prototypes.olr")
    data:extend(olr.extensions)
end

if mods["Electric_flying_enemies"] then
    require("__ufo__.scripts.prototypes.fulguran-enemies")
end
