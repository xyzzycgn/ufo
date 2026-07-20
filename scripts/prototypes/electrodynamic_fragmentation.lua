---
--- Created by xyzzycgn.
---

local Log = require("__log4factorio__.Log")
local consts = require("scripts.consts")
local prototypeHelper = require("scripts.prototypeHelper")
local edf_animation = require("scripts.prototypes.edf_animation")

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
    collision_box = { { -2, -2  }, { 2, 2 } },
    selection_box = { { -2, -2 }, { 2, 2 } },
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
-- ###############################################################

local ufo_edf_item = prototypeHelper.copyAndReplace("item", "assembling-machine-3", "ufo-electrodynamic-fragmentation-device", {
    icon = edf_animation.icon,
    icon_size = 256,
    icon_mipmaps = 4,
    subgroup = "production-machine"
})
local order_edf = ufo_edf_item.order or "ufo"
ufo_edf_item.order = order_edf .. "-b"
Log.logBlock(ufo_edf_item, function(m)log(m)end, Log.FINE)
-- ###############################################################

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

local sand_from_concrete_rubble_recipe =   {
    type = "recipe",
    name = "ufo-sand-from-concrete-rubble",
    enabled = false,
    icon = "__use-fulguran-objects__/graphics/icons/sand-pile.png",
    icon_size = 256,
    icon_mipmaps = 4,
    ingredients = {
        { type = "item", name = "ufo-concrete-rubble", amount = 50 },
        { type = "fluid", name = "water", amount = 100 }
    },
    results = {
        { type = "item", name = "ufo-sand", amount = 7 },
        { type = "fluid", name = "water", amount = 99, ignored_by_productivity = 99 }
    },
    main_product = "ufo-sand",
    allow_productivity = true,
    allow_quality = false,
    auto_recycle = false,
    categories = { "electrodynamic-fragmentation-category" },
    subgroup = "intermediate-product",
    hide_from_player_crafting = true,
    energy_required = 15,
    factoriopedia_description = { "factoriopedia-description.ufo-sand-from-concrete-rubble" },
    factoriopedia_alternative = "ufo-sand",
}
-- ###############################################################

data:extend( {
    recipe_category,
    ufo_electrodynamic_fragmentation_tech,
    ufo_edf_entity,
    ufo_edf_item,
    ufo_edf_recipe,
    sand_from_concrete_rubble_recipe,
})
