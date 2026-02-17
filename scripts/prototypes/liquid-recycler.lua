---
--- Created by xyzzycgn.
--- improved liquid-recycler
---

local Log = require("__log4factorio__.Log")
local data_util = require("__flib__.data-util")
local scale = require("__ufo__.scripts.scale")
local consts = require("__ufo__.scripts.consts")

Log.log("mod liquid_recycler detected", function(m)log(m)end, Log.CONFIG)
-- ###############################################################

local scale_factor = 0.5
local tint = { r = 0.75, g = 0.75, b = 1, a = 0.6 }
-- to use tint it must be icons
local icons = {
    {
        icon = "__liquid_recycler__/graphics/chemical-stager/chemical-stager-icon.png",
        icon_size = 64,
        tint = tint,
        scale = scale_factor,
    }
}
-- ###############################################################

local ufo_liquid_recycler_entity = data_util.copy_prototype(data.raw["furnace"]["fluid-recycler"], "ufo-fluid-recycler")
Log.logBlock(ufo_liquid_recycler_entity, function(m)log(m)end, Log.FINE)
scale.rescale_entity(ufo_liquid_recycler_entity, scale_factor)
ufo_liquid_recycler_entity.icon = nil
ufo_liquid_recycler_entity.icons = icons
ufo_liquid_recycler_entity.collision_box = {{ -2.1, -2.1 }, { 2.1, 2.1 }}
ufo_liquid_recycler_entity.selection_box = {{ -2.25, -2.25 }, { 2.25, 2.25  }}
scale.move_pipe_connection(ufo_liquid_recycler_entity.fluid_boxes, 1, { -1, 2 })
ufo_liquid_recycler_entity.crafting_speed = 2
ufo_liquid_recycler_entity.effect_receiver = {
    base_effect = {
        productivity = 1.2
    }
}
ufo_liquid_recycler_entity.energy_usage = "760kW"
ufo_liquid_recycler_entity.factoriopedia_description = { "factoriopedia-description.ufo-fluid-recycler" }

Log.logBlock(ufo_liquid_recycler_entity, function(m)log(m)end, Log.FINE)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_liquid_recycler_item = data_util.copy_prototype(data.raw["item"]["fluid-recycler"], "ufo-fluid-recycler")
local order = ufo_liquid_recycler_item.order or "ufo"
ufo_liquid_recycler_item.icon = nil
ufo_liquid_recycler_item.icons = icons
ufo_liquid_recycler_item.order = order .. "-a"
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_liquid_recycler_recipe = data_util.copy_prototype(data.raw["recipe"]["fluid-recycler"], "ufo-fluid-recycler")
local ingredients = ufo_liquid_recycler_recipe.ingredients
ingredients[#ingredients + 1] = { type = 'item', name = 'ufo-adapter', amount = 1 }
ingredients[#ingredients + 1] = { type = 'item', name = 'holmium-plate', amount = 4 }
ufo_liquid_recycler_recipe.enabled = false
ufo_liquid_recycler_recipe.surface_conditions = consts.sc_only_fulgora
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- technology
local ufo_liquid_recycler_tech = {
    name = "ufo-fluid-recycling-tech",
    type = "technology",
    icons = {
        {
            icon = "__liquid_recycler__/graphics/chemical-stager/technology.png",
            icon_size = 825,
            icon_mipmaps = 4,
            tint = tint,
            scale = 256 / 825,
        }
    },

    prerequisites = { "fluid-recycler" , "ufo-fulgoran-know-how-tech" },
    effects = {{ type = "unlock-recipe", recipe = "ufo-fluid-recycler" }},

    unit = {
        count = 60,
        ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 2 },
            { "production-science-pack", 1 },
            { "utility-science-pack", 3 },
            { "metallurgic-science-pack", 2 },
        },
        time = 20,
    },
    order = "c-e-b2",
    factoriopedia_description = { "factoriopedia-description.ufo-fluid-recycler" }
}
-- ###############################################################

data:extend({
    ufo_liquid_recycler_item,
    ufo_liquid_recycler_entity,
    ufo_liquid_recycler_recipe,
    ufo_liquid_recycler_tech
})

