---
--- Created by xyzzycgn.
--- improved electric furnace
---
local Log = require("__log4factorio__.Log")
local data_util = require("__flib__.data-util")
local prototypeHelper = require("__ufo__.scripts.prototypeHelper")
local scale = require("__ufo__.scripts.scale")
local consts = require("__ufo__.scripts.consts")

-- ###############################################################

local scale_factor = 2/3
local tint = { r = 0.75, g = 0.75, b = 1, a = 0.6 }
-- to use tint it must be icons
local icons = {
    {
        icon = "__base__/graphics/icons/electric-furnace.png",
        icon_size = 64,
        tint = tint,
        scale = scale_factor,
    }
}
-- ###############################################################

local ufo_furnace_entity = prototypeHelper.copyAndReplace("furnace", "electric-furnace", "ufo-electric-furnace", {
    crafting_speed = 8,
    module_slots = 4,
    energy_usage = "560kW",
    icons = icons,
    effect_receiver = {
        base_effect = {
          productivity = 1
        }
    },
    factoriopedia_description = { "factoriopedia-description.ufo-electric-furnace" },
    localised_description = { "entity-description.ufo-electric-furnace" }
})
Log.logBlock(ufo_furnace_entity, function(m)log(m)end, Log.FINE)
scale.rescale_entity(ufo_furnace_entity, scale_factor)
ufo_furnace_entity.icon = nil
ufo_furnace_entity.energy_source.emissions_per_minute = { pollution = 0.5 }
ufo_furnace_entity.energy_source.drain = "300W"
-- scale icon of the production
ufo_furnace_entity.icon_draw_specification.scale = scale_factor
ufo_furnace_entity.icon_draw_specification.scale_for_many = scale_factor

Log.logBlock(ufo_furnace_entity, function(m)log(m)end, Log.FINE)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_furnace_item = data_util.copy_prototype(data.raw["item"]["electric-furnace"], "ufo-electric-furnace")
local order = ufo_furnace_item.order or "ufo"
ufo_furnace_item.icon = nil
ufo_furnace_item.icons = icons
ufo_furnace_item.order = order .. "-a"
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_furnace_recipe = prototypeHelper.copyAndReplace("recipe", "electric-furnace", "ufo-electric-furnace", {
    enabled = false,
    category = "crafting-with-fluid",
    surface_conditions = consts.sc_only_fulgora,
})
prototypeHelper.additionalIngredients(ufo_furnace_recipe, {
    { type = 'item', name = 'ufo-adapter', amount = 5 },
    { type = 'fluid', name = 'holmium-solution', amount = 10 },
})
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- technology
local ufo_furnace_tech = {
    name = "ufo-electric-furnace-tech",
    type = "technology",
    icons = {
        {
            icon = "__base__/graphics/technology/advanced-material-processing-2.png",
            icon_size = 256,
            icon_mipmaps = 4,
            tint = tint,
            scale = scale_factor,
        }
    },

    prerequisites = { "advanced-material-processing-2" , "ufo-fulgoran-know-how-tech" },
    effects = {{ type = "unlock-recipe", recipe = "ufo-electric-furnace" }},

    unit = {
        count = 30,
        ingredients = {
            { "automation-science-pack", 2 },
            { "logistic-science-pack", 3 },
            { "production-science-pack", 2 },
            { "utility-science-pack", 3 },
            { "metallurgic-science-pack", 3 },
            { "electromagnetic-science-pack", 2 },
        },
        time = 45,
    },
    order = "c-e-b1",
    factoriopedia_description = { "factoriopedia-description.ufo-electric-furnace" }
}
-- ###############################################################

data:extend({
    ufo_furnace_item,
    ufo_furnace_entity,
    ufo_furnace_recipe,
    ufo_furnace_tech
})
