---
--- Created by xyzzycgn.
--- improved recycler
---
local Log = require("__log4factorio__.Log")
local data_util = require("__flib__.data-util")
local prototypeHelper = require("__ufo__.scripts.prototypeHelper")
local consts = require("__ufo__.scripts.consts")

-- ###############################################################

local scale_factor = 0.5
local tint = { r = 0.75, g = 0.75, b = 1, a = 0.6 }
-- to use tint it must be icons
local icons = {
    {
        icon = "__quality__/graphics/icons/recycler.png",
        icon_size = 64,
        tint = tint,
        scale = scale_factor,
    }
}
-- ###############################################################

local ufo_recycler_entity = prototypeHelper.copyAndReplace("furnace", "recycler", "ufo-recycler", {
    icons = icons,
    result_inventory_size = 18,
    crafting_speed = 2,
    effect_receiver = {
        base_effect = {
          productivity = 1
        }
    },
    energy_usage = "160kW",
    factoriopedia_description = { "factoriopedia-description.ufo-recycler" },
}, scale_factor)
-- to make big-beautiful-module-icons working
ufo_recycler_entity.icons_positioning = nil
-- scale icon of the production
ufo_recycler_entity.icon_draw_specification.scale = scale_factor
ufo_recycler_entity.icon_draw_specification.scale_for_many = scale_factor

Log.logBlock(ufo_recycler_entity, function(m)log(m)end, Log.FINER)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_recycler_item = data_util.copy_prototype(data.raw["item"]["recycler"], "ufo-recycler")
local order = ufo_recycler_item.order or "ufo"
ufo_recycler_item.icon = nil
ufo_recycler_item.icons = icons
ufo_recycler_item.order = order .. "-a"
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_recycler_recipe = data_util.copy_prototype(data.raw["recipe"]["recycler"], "ufo-recycler")
local ingredients = ufo_recycler_recipe.ingredients
ingredients[#ingredients + 1] = { type = 'item', name = 'ufo-adapter', amount = 2 }
ingredients[#ingredients + 1] = { type = 'item', name = 'holmium-plate', amount = 3 }
ufo_recycler_recipe.enabled = false
ufo_recycler_recipe.surface_conditions = consts.sc_only_fulgora
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- technology
local ufo_recycler_tech = {
    name = "ufo-recycling-tech",
    type = "technology",
    icons = {
        {
            icon = "__quality__/graphics/technology/recycling.png",
            icon_size = 256,
            icon_mipmaps = 4,
            tint = tint,
            scale = scale_factor,
        }
    },

    prerequisites = { "recycling", "ufo-fulgoran-know-how-tech" },
    effects = {{ type = "unlock-recipe", recipe = "ufo-recycler" }},

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
    factoriopedia_description = { "factoriopedia-description.ufo-recycler" }
}
-- ###############################################################

data:extend({
    ufo_recycler_item,
    ufo_recycler_entity,
    ufo_recycler_recipe,
    ufo_recycler_tech
})

return emp