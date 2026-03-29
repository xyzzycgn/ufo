---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local data_util = require("__flib__.data-util")
local item_sounds = require("__base__.prototypes.item_sounds")
local consts = require("__ufo__.scripts.consts")
local prototypeHelper = require("__ufo__.scripts.prototypeHelper")
local scale = require("__ufo__.scripts.scale")

local scale_factor = 1.5
local ufo_crusher_entity = prototypeHelper.copyAndReplace("assembling-machine", "crusher", "ufo-crusher", {
    energy_usage = "600kW",
    factoriopedia_description = { "factoriopedia-description.ufo-crusher" },
    surface_conditions = {{ property = "gravity", min = 1, }},
}, scale_factor)
ufo_crusher_entity.icon_draw_specification.scale = scale_factor
ufo_crusher_entity.icon_draw_specification.scale_for_many = scale_factor
Log.logBlock(ufo_crusher_entity, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_crusher_item = data_util.copy_prototype(data.raw["item"]["crusher"], "ufo-crusher")
local order = ufo_crusher_item.order or "ufo"
ufo_crusher_item.subgroup = "production-machine"
ufo_crusher_item.order = order .. "-a"
Log.logBlock(ufo_crusher_item, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_crusher_recipe = prototypeHelper.copyAndReplace("recipe", "crusher", "ufo-crusher", { enabled = false })
Log.logBlock(ufo_crusher_recipe, function(m)log(m)end, Log.CONFIG)
-- ###############################################################

local sand_item = {
    type = "item",
    name = "ufo-sand",
    icon = "__ufo__/graphics/icons/sand-pile.png",
    icon_size = 256,
    icon_mipmaps = 4,
    subgroup = "intermediate-product",
    order = "a[basic-intermediates]-ba[sand]",
    inventory_move_sound = item_sounds.landfill_inventory_move,
    pick_sound = item_sounds.landfill_inventory_pickup,
    drop_sound = item_sounds.landfill_inventory_move,
    stack_size = 200,
}
-- ###############################################################

local sand_recipe =   {
    type = "recipe",
    name = "ufo-sand",
    enabled = false,
    ingredients = { { type = "item", name = "stone", amount = 7 } },
    results = { { type = "item", name = "ufo-sand", amount = 5 } },
    allow_productivity = true,
    auto_recycle = false,
    category = "crushing",
    hide_from_player_crafting = true,
}
-- ###############################################################

local ufo_resonance_raw_shard_item = prototypeHelper.copyAndReplace("item", "iron-plate", "ufo-resonance-raw-shard", {
    icon = "__ufo__/graphics/icons/raw-pink-crystal.png",
    icon_size = 256,
    icon_mipmaps = 4,
})

local ufo_resonance_raw_shard_recipe = prototypeHelper.copyAndReplace("recipe", "iron-plate", "ufo-resonance-raw-shard", {
    category = "metallurgy",
    ingredients = {
        { type = "item", name = "ufo-sand", amount = 25 },
        { type = "item", name = "holmium-ore", amount = 15 }
    },
    results = { { type = "item", name = "ufo-resonance-raw-shard", amount = 1 } },
    surface_conditions = consts.sc_only_fulgora,
    enabled = false,
    allow_speed = false,
    allow_productivity = false,
    maximum_productivity = 0,
    auto_recycle = false,
    energy_required = 35,
})

Log.logBlock(ufo_resonance_raw_shard_recipe, function(m)log(m)end, Log.CONFIG)

local ufo_resonance_raw_shard_tech = {
    name = 'ufo-resonance-raw-shard-tech',
    type = 'technology',
    icon = "__ufo__/graphics/icons/raw-pink-crystal.png",
    icon_size = 256,
    icon_mipmaps = 4,

    prerequisites = { "ufo-archeological-tech" },
    effects = {{ type = 'unlock-recipe', recipe = 'ufo-resonance-raw-shard' }},

    research_trigger = { type = "mine-entity", entity = "fulgoran-ruin-colossal"},
    order = "c-e-a",
    factoriopedia_description = { "factoriopedia-description.ufo-resonance-raw-shard-tech" }
}
-- ###############################################################

local scale_factor_efd = 4/3
local ufo_efd_entity = prototypeHelper.copyAndReplace("assembling-machine", "assembling-machine-3", "ufo-electrodynamic-fragmentation-device", {
    energy_usage = "600kW",
    factoriopedia_description = { "factoriopedia-description.fo-electrodynamic-fragmentation-device" },
    surface_conditions = consts.sc_only_fulgora
}, scale_factor_efd)
Log.logBlock(ufo_efd_entity, function(m)log(m)end, Log.CONFIG)

scale.move_pipe_connection(ufo_efd_entity.fluid_boxes, 1, { -1.125, 1 })
scale.move_pipe_connection(ufo_efd_entity.fluid_boxes, 2, { 1.125, -1 })
--scale.move_pipe_connection(ufo_efd_entity.fluid_boxes, 3, { 1, 1.125 })
--scale.move_pipe_connection(ufo_efd_entity.fluid_boxes, 4, { -1, -1.125 })

-- TODO icon + tint
-- TODO erlaubte rezepte (hoffentlich geht das)
ufo_efd_entity.icon_draw_specification.scale = scale_factor_efd
ufo_efd_entity.icon_draw_specification.scale_for_many = scale_factor_efd
Log.logBlock(ufo_efd_entity, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_efd_item = data_util.copy_prototype(data.raw["item"]["assembling-machine-3"], "ufo-electrodynamic-fragmentation-device")
local order_efd = ufo_efd_item.order or "ufo"
ufo_efd_item.subgroup = "production-machine"
ufo_efd_item.order = order_efd .. "-b"
Log.logBlock(ufo_efd_item, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_efd_recipe = prototypeHelper.copyAndReplace("recipe", "assembling-machine-3", "ufo-electrodynamic-fragmentation-device", {
    enabled = false
})
-- ###############################################################

local concrete_rubble_item = {
    type = "item",
    name = "ufo-concrete-rubble",
    icon = "__ufo__/graphics/icons/concrete-rubble.png",
    icon_size = 256,
    icon_mipmaps = 4,
    subgroup = "intermediate-product",
    order = "a[basic-intermediates]-ba[concrete-rubble]",
    inventory_move_sound = item_sounds.landfill_inventory_move,
    pick_sound = item_sounds.landfill_inventory_pickup,
    drop_sound = item_sounds.landfill_inventory_move,
    stack_size = 200,
}
-- ###############################################################

local concrete_rubble_recipe =   {
    type = "recipe",
    name = "ufo-concrete-rubble",
    enabled = false,
    ingredients = { { type = "item", name = "concrete", amount = 5 } },
    results = { { type = "item", name = "ufo-concrete-rubble", amount = 6 } },
    allow_productivity = true,
    auto_recycle = false,
    category = "crushing",
    hide_from_player_crafting = true,
}
-- ###############################################################

local ufo_electrodynamic_fragmentation_tech = {
    name = 'ufo-electrodynamic-fragmentation-tech',
    type = 'technology',
    icons = {
        {
            icon = "__base__/graphics/technology/automation-3.png", -- TODO???
            icon_size = 256,
            icon_mipmaps = 4,
        },
        {
            icon = "__ufo__/graphics/technology/tech_up.png",
            icon_size = 256,
            icon_mipmaps = 4,
        }
    },

    prerequisites = { "ufo-resonance-raw-shard-tech" },
    effects = {
        { type = "unlock-recipe", recipe = "ufo-electrodynamic-fragmentation-device" }
    },

    unit = {
        count = 50,
        ingredients = {
            { "automation-science-pack", 2 },
            { "logistic-science-pack", 1 },
            { "production-science-pack", 1 },
            { "utility-science-pack", 3 },
            { "electromagnetic-science-pack", 2 },
        },
        time = 25,
    },
    order = "c-e-b",
    factoriopedia_description = { "factoriopedia-description.electrodynamic-fragmentation" }
}
-- ###############################################################

-- enable sand, concrete-rubble and crusher with space-platform (like normal crusher)
local sppe = data.raw["technology"]["space-platform"].effects
sppe[#sppe + 1] = { type = "unlock-recipe", recipe = "ufo-crusher" }
sppe[#sppe + 1] = { type = "unlock-recipe", recipe = "ufo-sand" }
sppe[#sppe + 1] = { type = "unlock-recipe", recipe = "ufo-concrete-rubble" }
Log.logBlock(sppe, function(m)log(m)end, Log.FINE)
-- ###############################################################

data:extend( {
    ufo_crusher_entity,
    ufo_crusher_item,
    ufo_crusher_recipe,
    sand_item,
    sand_recipe,
    ufo_resonance_raw_shard_item,
    ufo_resonance_raw_shard_recipe,
    ufo_resonance_raw_shard_tech,
    concrete_rubble_item,
    concrete_rubble_recipe,
    ufo_electrodynamic_fragmentation_tech,
    ufo_efd_entity,
    ufo_efd_item,
    ufo_efd_recipe,
})