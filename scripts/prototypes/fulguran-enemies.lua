---
--- Created by xyzzycgn.
--- adapter to mod Electric_flying_enemies
---
local prototypeHelper = require("__ufo__.scripts.prototypeHelper")
local Log = require("__log4factorio__.Log")
local consts = require("__ufo__.scripts.consts")

-- ###############################################################

-- protected ruin vault
local ufo_vault = prototypeHelper.copyAndReplace("simple-entity", "fulgoran-ruin-vault", "ufo-fulgoran-ruin-vault", {
    hidden_in_factoriopedia = true
})
-- ###############################################################

-- part of the ufo-inhibitor
local ufo_inhibitor_shard_item = prototypeHelper.copyAndReplace("item", "iron-plate", "ufo-resonance-shard", {
    icon = "__ufo__/graphics/icons/pink-crystal.png",
    icon_size = 256,
    icon_mipmaps = 4,
})

local ufo_inhibitor_shard_recipe = prototypeHelper.copyAndReplace("recipe", "iron-plate", "ufo-resonance-shard", {
    category = "metallurgy",
    ingredients = {
        -- TODO
        { type = 'item', name = 'ufo-resonance-raw-shard', amount = 1 },
        { type = 'item', name = 'holmium-ore', amount = 1 }
    },
    results = { { type = "item", name = "ufo-resonance-shard", amount = 1 } },
    surface_conditions = consts.sc_only_fulgora,
    allow_speed = false,
    allow_productivity = false,
    maximum_productivity = 0,
    auto_recycle = false,
    enabled = false,
    energy_required = 50,
})
Log.logBlock(ufo_inhibitor_shard_recipe, function(m)log(m)end, Log.CONFIG)

-- ###############################################################

local scale_factor = 0.5
local ufo_inhibitor_entity = prototypeHelper.copyAndReplace("beacon", "fe_resonance_shard", "ufo-inhibitor", {
    max_health = 100,
    energy_usage = "150kW",
    factoriopedia_description = { "factoriopedia-description.ufo-inhibitor" },
    surface_conditions = consts.sc_only_fulgora,
    module_slots = 0,
}, scale_factor)
ufo_inhibitor_entity.radius_visualisation_picture = nil

---- change colors of animation
local gs = ufo_inhibitor_entity.graphics_set
gs.animation_list[1].animation.layers[3].tint = { 1, 0.3, 1, 0.9 }
gs.animation_list[2].animation.layers[3].tint = { 1, 1, 1, 0.9 }
gs.animation_list[2].animation.layers[4].tint = { 0.2, 0.4, 1, 0.9 }

Log.logBlock(ufo_inhibitor_entity, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_inhibitor_item = prototypeHelper.copyAndReplace("item", "fe_resonance_shard", "ufo-inhibitor", {
    weight = 25 * kg,
    stack_size = 40,
})
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_inhibitor_recipe = prototypeHelper.copyAndReplace("recipe", "beacon", "ufo-inhibitor", {
    enabled = false,
    surface_conditions = consts.sc_only_fulgora,
    module_slots = 0,  -- no slots
})
-- additional ingredients
local ingredients = ufo_inhibitor_recipe.ingredients
ingredients[#ingredients + 1] = { type = 'item', name = 'ufo-resonance-shard', amount = 1 }
ingredients[#ingredients + 1] = { type = 'item', name = 'holmium-plate', amount = 3 }

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- technologies

local ufo_inhibitor_shard_tech = {
    name = "ufo-resonance-shard-tech",
    type = "technology",
    icons = {
        {
            icon = "__ufo__/graphics/icons/pink-crystal.png",
            icon_size = 256,
            icon_mipmaps = 4,
            scale = scale_factor,
        }
    },

    prerequisites = { "ufo-resonance-raw-shard-tech" },
    effects = {{ type = "unlock-recipe", recipe = "ufo-resonance-shard" }},
    research_trigger = { type = "scripted", trigger_description = { "description.ufo-resonance-shard-tech" }},

    order = "c-e-b3",
    factoriopedia_description = { "factoriopedia-description.ufo-resonance-shard" }
}
Log.logBlock(ufo_inhibitor_shard_tech, function(m)log(m)end, Log.CONFIG)

local ufo_inhibitor_tech = {
    name = 'ufo-inhibitor-tech',
    type = 'technology',
    icons = {
        {
            icon = "__mferrari_graphics_pack_1__/graphics/entities/conduit/conduit-icon.png",
            icon_size = 256,
            icon_mipmaps = 4,
            scale = scale_factor,
        }
    },
    prerequisites = { "ufo-resonance-shard-tech" },
    unit = {
        count = 100,
        ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 2 },
            { "production-science-pack", 3 },
            { "utility-science-pack", 1 },
            { "metallurgic-science-pack", 2 },
        },
        time = 25,
    },

    effects = {{ type = "unlock-recipe", recipe = "ufo-inhibitor" }},

    order = "c-f-b3",
    factoriopedia_description = { "factoriopedia-description.ufo-inhibitor-tech" }
}
-- ###############################################################


data:extend({
    ufo_vault,
    ufo_inhibitor_shard_item,
    ufo_inhibitor_shard_recipe,
    ufo_inhibitor_shard_tech,
    ufo_inhibitor_entity,
    ufo_inhibitor_item,
    ufo_inhibitor_recipe,
    ufo_inhibitor_tech,
})
