---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local data_util = require("__flib__.data-util")
local item_sounds = require("__base__.prototypes.item_sounds")
local consts = require("__ufo__.scripts.consts")
local prototypeHelper = require("__ufo__.scripts.prototypeHelper")
local edf_animation = require("__ufo__.scripts.prototypes.edf_animation")

local scale_factor = 1.5
local ufo_crusher_entity = prototypeHelper.copyAndReplace("assembling-machine", "crusher", "ufo-crusher", {
    energy_usage = "600kW",
    factoriopedia_description = { "factoriopedia-description.ufo-crusher" },
    surface_conditions = {{ property = "gravity", min = 1, }},
}, scale_factor)
ufo_crusher_entity.icon_draw_specification.scale = scale_factor
ufo_crusher_entity.icon_draw_specification.scale_for_many = scale_factor
Log.logBlock(ufo_crusher_entity, function(m)log(m)end, Log.FINE)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_crusher_item = data_util.copy_prototype(data.raw["item"]["crusher"], "ufo-crusher")
local order = ufo_crusher_item.order or "ufo"
ufo_crusher_item.subgroup = "production-machine"
ufo_crusher_item.order = order .. "-a"
Log.logBlock(ufo_crusher_item, function(m)log(m)end, Log.FINE)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_crusher_recipe = prototypeHelper.copyAndReplace("recipe", "crusher", "ufo-crusher", { enabled = false })
Log.logBlock(ufo_crusher_recipe, function(m)log(m)end, Log.FINE)
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
    subgroup = "intermediate-product",
    hide_from_player_crafting = true,
    factoriopedia_alternative = "ufo-sand-from-concrete-rubble",
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

Log.logBlock(ufo_resonance_raw_shard_recipe, function(m)log(m)end, Log.FINE)

local ufo_resonance_raw_shard_tech = {
    name = 'ufo-resonance-raw-shard-tech',
    type = 'technology',
    icon = "__ufo__/graphics/icons/raw-pink-crystal.png",
    icon_size = 256,
    icon_mipmaps = 4,

    prerequisites = { "ufo-archeological-tech" },
    effects = {{ type = 'unlock-recipe', recipe = 'ufo-resonance-raw-shard' }},

    research_trigger = { type = "mine-entity", entity = "fulgoran-ruin-colossal"},
    order = "ufo-b",
    factoriopedia_description = { "factoriopedia-description.ufo-resonance-raw-shard-tech" }
}
-- ###############################################################

local recipe_category = {
  type = "recipe-category",
  name = "electrodynamic-fragmentation-category"
}
-- ###############################################################

Log.logBlock(data.raw["assembling-machine"]["assembling-machine-3"], function(m)log(m)end, Log.FINE)

local scale_factor_edf = 4/3
local ufo_edf_entity = prototypeHelper.copyAndReplace("assembling-machine", "assembling-machine-3", "ufo-electrodynamic-fragmentation-device", {
    energy_usage = "600kW",
    surface_conditions = consts.sc_only_fulgora,
    -- only very special recipes allowed ;-)
    crafting_categories = {
        "electrodynamic-fragmentation-category"
    },
    allowed_effects = {
        "consumption",
        "speed",
        "productivity",
        "pollution",
    },
    icon = edf_animation.icon,
    icon_size = 256,
    icon_mipmaps = 4,
    working_sound = {
        match_progress_to_activity = true,
        sound = {
            audible_distance_modifier = 1.5,
            filename = "__space-age__/sound/entity/lightning-attractor/lightning-attractor-discharge.ogg",
            volume = 0.75,
        }
    },
    graphics_set = edf_animation.graphics_set,
    circuit_connector = edf_animation.circuit_connector,
    fluid_boxes = edf_animation.fluid_boxes,

    factoriopedia_description = { "factoriopedia-description.ufo-electrodynamic-fragmentation-device" },
    localised_description = { "entity-description.ufo-electrodynamic-fragmentation-device" }
}, scale_factor_edf)

ufo_edf_entity.icon_draw_specification.scale = scale_factor_edf
ufo_edf_entity.icon_draw_specification.scale_for_many = scale_factor_edf
local flags = ufo_edf_entity.flags
flags[#flags + 1] = "not-rotatable"

Log.logBlock(ufo_edf_entity, function(m)log(m)end, Log.FINE)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_edf_item = prototypeHelper.copyAndReplace("item", "assembling-machine-3", "ufo-electrodynamic-fragmentation-device", {
    icon = edf_animation.icon,
    icon_size = 256,
    icon_mipmaps = 4,
    subgroup = "production-machine"
})
local order_edf = ufo_edf_item.order or "ufo"
ufo_edf_item.order = order_edf .. "-b"
Log.logBlock(ufo_edf_item, function(m)log(m)end, Log.FINE)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_edf_recipe = prototypeHelper.copyAndReplace("recipe", "assembling-machine-3", "ufo-electrodynamic-fragmentation-device", {
    enabled = false,
})
prototypeHelper.additionalIngredients(ufo_edf_recipe, {
    { type = "item", name = "ufo-resonance-raw-shard", amount = 3 },
    { type = 'item', name = 'holmium-plate', amount = 10 },
    { type = "item", name = "electronic-circuit", amount = 15 },
    { type = "item", name = "advanced-circuit", amount = 12 },
    { type = "item", name = "copper-cable", amount = 30 },
    { type = "item", name = "iron-plate", amount = 10 },
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
    energy_required = 12,
}
-- ###############################################################

local sand_from_concrete_rubble_recipe =   {
    type = "recipe",
    name = "ufo-sand-from-concrete-rubble",
    enabled = false,
    icon = "__ufo__/graphics/icons/sand-pile.png",
    icon_size = 256,
    icon_mipmaps = 4,
    ingredients = {
        { type = "item", name = "ufo-concrete-rubble", amount = 50 },
        { type = "fluid", name = "water", amount = 100 }
    },
    results = {
        { type = "item", name = "ufo-sand", amount = 6 },
        { type = "fluid", name = "water", amount = 99 }
    },
    main_product = "ufo-sand",
    allow_productivity = true,
    allow_quality = false,
    auto_recycle = false,
    category = "electrodynamic-fragmentation-category",
    subgroup = "intermediate-product",
    hide_from_player_crafting = true,
    energy_required = 15,
    factoriopedia_description = { "factoriopedia-description.ufo-sand-from-concrete-rubble" },
    factoriopedia_alternative = "ufo-sand",
}
-- ###############################################################

local ufo_electrodynamic_fragmentation_tech = {
    name = 'ufo-electrodynamic-fragmentation-tech',
    type = 'technology',
    icon = edf_animation.icon,
    icon_size = 256,
    icon_mipmaps = 4,
    prerequisites = { "ufo-resonance-raw-shard-tech" },
    effects = {
        { type = "unlock-recipe", recipe = "ufo-electrodynamic-fragmentation-device" },
        { type = "unlock-recipe", recipe = "ufo-sand-from-concrete-rubble" }
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
    order = "ufo-b-c1",
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
    recipe_category,
    ufo_electrodynamic_fragmentation_tech,
    ufo_edf_entity,
    ufo_edf_item,
    ufo_edf_recipe,
    sand_from_concrete_rubble_recipe,
})