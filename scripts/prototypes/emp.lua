---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local data_util = require("__flib__.data-util")

--- @type SurfaceCondition only on fulgora
local sc_only_fulgora = {{ property = "magnetic-field", min = 99 }}

-- fields for scaling (as long as we have only 2 possibilities the neat trick in scale() works)
local fields = {
    shift = true,
    scale = true,
}

-- fields to ignore for scaling
local ignored_fields = {
    working_sound = true,
    pipe_covers = true,
    pipe_picture = true,
}

-- Scales values within object
local function scale(object, factor)
    -- Check if we have a number (i.e. it's scale)
    if type(object) == "number" then
        return object * factor
    else
        -- must be shift - neat trick as we have only 2 possibilities ;)
        object[1] = object[1] * factor
        object[2] = object[2] * factor

        return object
    end
end

-- used for shrinking the XXX entity
local function rescale_entity(prototype, factor)
    if not prototype then
        return
    end

    for key, value in pairs(prototype) do
        -- Check to see if we need to scale this key's value
        if fields[key] then
            prototype[key] = scale(value, factor)
            -- Check to see if we need to ignore this key
        elseif ignored_fields[key] then
            -- nothing to do
        elseif (type(value) == "table") then
            rescale_entity(value, factor)
        end
    end

    return prototype
end
-- ###############################################################

local function move_pipe_connection(fb, ndx, pos)
    fb[ndx].pipe_connections[1].position = pos
end
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

-- fulgoran electromagnetic plant
local ufo_emp_entity = data_util.copy_prototype(data.raw["assembling-machine"]["electromagnetic-plant"], "ufo-electromagnetic-plant")
Log.logBlock(ufo_emp_entity, function(m)log(m)end, Log.CONFIG)
rescale_entity(ufo_emp_entity, scale_factor)
ufo_emp_entity.icon = nil
ufo_emp_entity.icons = icons
ufo_emp_entity.collision_box = {{ -1.275, -1.275 }, { 1.275, 1.275 }}
ufo_emp_entity.selection_box = {{ -1.5, -1.5 }, { 1.5, 1.5 }}
move_pipe_connection(ufo_emp_entity.fluid_boxes, 1, { -1.125, 1 })
move_pipe_connection(ufo_emp_entity.fluid_boxes, 2, { 1.125, -1 })
move_pipe_connection(ufo_emp_entity.fluid_boxes, 3, { 1, 1.125 })
move_pipe_connection(ufo_emp_entity.fluid_boxes, 4, { -1, -1.125 })
ufo_emp_entity.crafting_speed = 2
ufo_emp_entity.effect_receiver = {
    base_effect = {
      productivity = 1
    }
}
ufo_emp_entity.energy_usage = "1700kW"
ufo_emp_entity.surface_conditions = sc_only_fulgora
-- scale icon of the production
ufo_emp_entity.icon_draw_specification.scale = scale_factor
ufo_emp_entity.icon_draw_specification.scale_for_many = scale_factor

Log.logBlock(ufo_emp_entity, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_emp_item = data_util.copy_prototype(data.raw["item"]["electromagnetic-plant"], "ufo-electromagnetic-plant")
local order = ufo_emp_item.order or "ufo"
ufo_emp_item.icon = nil
ufo_emp_item.icons = icons
ufo_emp_item.order = order .. "-a"
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_emp_recipe = data_util.copy_prototype(data.raw["recipe"]["electromagnetic-plant"], "ufo-electromagnetic-plant")
ufo_emp_recipe.ingredients = {
    -- TODO make realistic
    { type = "item", name = "electronic-circuit", amount = 4 },
    { type = "item", name = "advanced-circuit", amount = 2 },
    { type = "item", name = "processing-unit", amount = 1 },
}
ufo_emp_recipe.enabled = false
ufo_emp_recipe.surface_conditions = sc_only_fulgora
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
        count = 10,
        ingredients = {
            -- TODO more realistic values
            { "automation-science-pack", 2 },
            { "space-science-pack", 1 },
        },
        time = 35,
    },
    order = "c-e-b2",
}
-- ###############################################################

local emp = {
    extensions = {
        ufo_emp_item,
        ufo_emp_entity,
        ufo_emp_recipe,
        ufo_emp_tech
    }
}

return emp