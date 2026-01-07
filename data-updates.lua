---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
Log.setSeverity(Log.CONFIG)

local fra = require("__ufo__.scripts.prototypes.fra")
local alien = require("__ufo__.scripts.prototypes.fkh")
local emp = require("__ufo__.scripts.prototypes.emp")

data:extend(fra.extensions)
data:extend(alien.extensions)
data:extend(emp.extensions)
