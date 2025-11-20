local Log = require("__log4factorio__.Log")
Log.setSeverity(Log.INFO)
local data_util = require('__flib__.data-util')
--local meld = require('meld') -- from lualib

-- der fulgoriansichw blitzableiter
Log.logBlock(data.raw["lightning-attractor"]["fulgoran-ruin-attractor"], function(m)log(m)end, Log.INFO)
-- der fortgeschrittene blitzableiter
Log.logBlock(data.raw["lightning-attractor"]["lightning-collector"], function(m)log(m)end, Log.INFO)
-- der einfache blitzableiter
Log.logBlock(data.raw["lightning-attractor"]["lightning-rod"], function(m)log(m)end, Log.INFO)


local ufo_item = data_util.copy_prototype(data.raw["item"]["radar"], "ufo-TODO-radar")
local order = ufo_item.order or "ufo"
ufo_item.icon = "__space-age__/graphics/icons/fulgoran-ruin-attractor.png"
ufo_item.order = order .. "-a"

----
local ufo_entity = data_util.copy_prototype(data.raw["radar"]["radar"], "ufo-TODO-radar")
----------

local ufo_recipe = data_util.copy_prototype(data.raw["recipe"]["radar"], "ufo-TODO-radar")
ufo_recipe.ingredients = {
    { type = "item", name = "radar", amount = 1 },
    { type = "item", name = "electronic-circuit", amount = 4 },
    { type = "item", name = "advanced-circuit", amount = 2 },
    { type = "item", name = "processing-unit", amount = 1 },
}


--- ufo technology
local ufo_tech = {
    name = 'ufo-tech',
    type = 'technology',
    icon = "__space-age__/graphics/icons/fulgoran-ruin-attractor.png",

    prerequisites = { "space-platform" },
    effects = {
        { type = 'unlock-recipe', recipe = 'ufo-TODO-radar' },
    },

    research_trigger = { type = "scripted", trigger_description = {"description.ufo-tech", "5"}},
    order = "c-e-b2",
}

data:extend({
    ufo_item,
    ufo_entity,
    ufo_recipe,
    ufo_tech,
})
