local Log = require("__log4factorio__.Log")
Log.setSeverity(Log.INFO)

-- der fulgoriansichw blitzableiter
Log.logBlock(data.raw["lightning-attractor"]["fulgoran-ruin-attractor"], function(m)log(m)end, Log.INFO)
-- der fortgeschrittene blitzableiter
Log.logBlock(data.raw["lightning-attractor"]["lightning-collector"], function(m)log(m)end, Log.INFO)
-- der einfache blitzableiter
Log.logBlock(data.raw["lightning-attractor"]["lightning-rod"], function(m)log(m)end, Log.INFO)

