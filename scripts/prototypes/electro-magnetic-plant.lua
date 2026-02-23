---
--- Created by xyzzycgn.
--- improved electromagnetic plant
---
local Log = require("__log4factorio__.Log")
local data_util = require("__flib__.data-util")
local scale = require("__ufo__.scripts.scale")
local consts = require("__ufo__.scripts.consts")

-- ###############################################################

local scale_factor = 0.75
local tint = { r = 0.75, g = 0.75, b = 1, a = 0.6 }
-- to use tint it must be icons
local icons = {
    {
        icon = "__space-age__/graphics/icons/electromagnetic-plant.png",
        icon_size = 64,
        tint = tint,
        scale = scale_factor,
    }
}
-- ###############################################################

local ufo_emp_entity = data_util.copy_prototype(data.raw["assembling-machine"]["electromagnetic-plant"], "ufo-electromagnetic-plant")
Log.logBlock(ufo_emp_entity, function(m)log(m)end, Log.FINER)
scale.rescale_entity(ufo_emp_entity, scale_factor)
ufo_emp_entity.icon = nil
ufo_emp_entity.icons = icons
scale.move_pipe_connection(ufo_emp_entity.fluid_boxes, 1, { -1.125, 1 })
scale.move_pipe_connection(ufo_emp_entity.fluid_boxes, 2, { 1.125, -1 })
scale.move_pipe_connection(ufo_emp_entity.fluid_boxes, 3, { 1, 1.125 })
scale.move_pipe_connection(ufo_emp_entity.fluid_boxes, 4, { -1, -1.125 })
ufo_emp_entity.crafting_speed = 2
ufo_emp_entity.effect_receiver = {
    base_effect = {
      productivity = 1
    }
}
ufo_emp_entity.energy_usage = "1600kW"
-- scale icon of the production
ufo_emp_entity.icon_draw_specification.scale = scale_factor
ufo_emp_entity.icon_draw_specification.scale_for_many = scale_factor

Log.logBlock(ufo_emp_entity, function(m)log(m)end, Log.FINER)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_emp_item = data_util.copy_prototype(data.raw["item"]["electromagnetic-plant"], "ufo-electromagnetic-plant")
local order = ufo_emp_item.order or "ufo"
ufo_emp_item.icon = nil
ufo_emp_item.icons = icons
ufo_emp_item.order = order .. "-a"
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_emp_recipe = data_util.copy_prototype(data.raw["recipe"]["electromagnetic-plant"], "ufo-electromagnetic-plant")
local ingredients = ufo_emp_recipe.ingredients
ingredients[#ingredients + 1] = { type = 'item', name = 'ufo-adapter', amount = 10 }
ingredients[#ingredients + 1] = { type = 'fluid', name = 'holmium-solution', amount = 20 }
ufo_emp_recipe.enabled = false
ufo_emp_recipe.surface_conditions = consts.sc_only_fulgora
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- technology
local ufo_emp_tech = {
    name = "ufo-emp-tech",
    type = "technology",
    icons = {
        {
            icon = "__space-age__/graphics/technology/electromagnetic-plant.png",
            icon_size = 256,
            icon_mipmaps = 4,
            tint = tint,
            scale = scale_factor,
        }
    },

    prerequisites = { "electromagnetic-plant" , "ufo-fulgoran-know-how-tech" },
    effects = {{ type = "unlock-recipe", recipe = "ufo-electromagnetic-plant" }},

    unit = {
        count = 40,
        ingredients = {
            { "automation-science-pack", 2 },
            { "logistic-science-pack", 3 },
            { "production-science-pack", 1 },
            { "utility-science-pack", 4 },
            { "metallurgic-science-pack", 3 },
            { "electromagnetic-science-pack", 2 },
        },
        time = 35,
    },
    order = "c-e-b2",
    factoriopedia_description = { "factoriopedia-description.ufo-electromagnetic-plant" }
}
-- ###############################################################

data:extend({
    ufo_emp_item,
    ufo_emp_entity,
    ufo_emp_recipe,
    ufo_emp_tech
})
