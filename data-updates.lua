---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
Log.setSeverity(Log.CONFIG)

local fra = require("__ufo__.scripts.prototypes.fra")
local emp = require("__ufo__.scripts.prototypes.emp")

data:extend(fra.extensions)
data:extend(emp.extensions)
