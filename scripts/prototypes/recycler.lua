---
--- Created by xyzzycgn.
--- improved recycler
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

local ufo_recycler_entity = data_util.copy_prototype(data.raw["furnace"]["recycler"], "ufo-recycler")
Log.logBlock(ufo_recycler_entity, function(m)log(m)end, Log.CONFIG)
rescale_entity(ufo_recycler_entity, scale_factor)
ufo_recycler_entity.icon = nil
ufo_recycler_entity.icons = icons
ufo_recycler_entity.collision_box = {{ -0.35, -0.85 }, { 0.35, 0.85  }}
ufo_recycler_entity.selection_box = {{ -0.45, -0.925 }, { 0.45, 0.925 }}
ufo_recycler_entity.vector_to_place_result={ -0.25, -1.15 }
ufo_recycler_entity.result_inventory_size = 18
ufo_recycler_entity.crafting_speed = 2
ufo_recycler_entity.effect_receiver = {
    base_effect = {
      productivity = 1
    }
}
ufo_recycler_entity.energy_usage = "160kW"
-- ufo_recycler_entity.surface_conditions = sc_only_fulgora -- TODO?
-- scale icon of the production
ufo_recycler_entity.icon_draw_specification.scale = scale_factor
ufo_recycler_entity.icon_draw_specification.scale_for_many = scale_factor

Log.logBlock(ufo_recycler_entity, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_recycler_item = data_util.copy_prototype(data.raw["item"]["recycler"], "ufo-recycler")
local order = ufo_recycler_item.order or "ufo"
ufo_recycler_item.icon = nil
ufo_recycler_item.icons = icons
ufo_recycler_item.order = order .. "-a"
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_recycler_recipe = data_util.copy_prototype(data.raw["recipe"]["recycler"], "ufo-recycler")
ufo_recycler_recipe.ingredients = {
    -- TODO make realistic
    { type = "item", name = "electronic-circuit", amount = 4 },
    { type = "item", name = "advanced-circuit", amount = 2 },
    { type = "item", name = "processing-unit", amount = 1 },
}
ufo_recycler_recipe.enabled = false
ufo_recycler_recipe.surface_conditions = sc_only_fulgora
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

    prerequisites = { "recycling" , "ufo-fulgoran-know-how-tech" },
    effects = {{ type = "unlock-recipe", recipe = "ufo-recycler" }},

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
        ufo_recycler_item,
        ufo_recycler_entity,
        ufo_recycler_recipe,
        ufo_recycler_tech
    }
}

return emp