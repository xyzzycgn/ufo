---
--- Created by xyzzycgn.
--- adapter to mod Electric_flying_enemies
---
local data_util = require("__flib__.data-util")
local Log = require("__log4factorio__.Log")
local scale = require("__ufo__.scripts.scale")
local consts = require("__ufo__.scripts.consts")

-- ###############################################################
-- protected ruin vault
local ufo_vault = data_util.copy_prototype(data.raw["simple-entity"]["fulgoran-ruin-vault"], "ufo-fulgoran-ruin-vault")
ufo_vault.hidden_in_factoriopedia = true

-- ###############################################################

-- part of the ufo-inhibitor
local ufo_inhibitor_shard_item = data_util.copy_prototype(data.raw["item"]["iron-plate"], "ufo-resonance-shard")
ufo_inhibitor_shard_item.icon = "__ufo__/graphics/icons/pink-crystal.png"
ufo_inhibitor_shard_item.icon_size = 256
ufo_inhibitor_shard_item.icon_mipmaps = 4

local ufo_inhibitor_shard_recipe = data_util.copy_prototype(data.raw["recipe"]["iron-plate"], "ufo-resonance-shard")
ufo_inhibitor_shard_recipe.category = "metallurgy"
-- TODO
ufo_inhibitor_shard_recipe.ingredients = {
    { type = 'item', name = 'ufo-resonance-raw-shard', amount = 1 },
    { type = 'item', name = 'holmium-ore', amount = 1 }
}
ufo_inhibitor_shard_recipe.results = { { type = "item", name = "ufo-resonance-shard", amount = 1 } }
ufo_inhibitor_shard_recipe.surface_conditions = consts.sc_only_fulgora
ufo_inhibitor_shard_recipe.allow_productivity = false
ufo_inhibitor_shard_recipe.auto_recycle = false
Log.logBlock(ufo_inhibitor_shard_recipe, function(m)log(m)end, Log.CONFIG)

-- ###############################################################

local scale_factor = 0.5
local ufo_inhibitor_entity = data_util.copy_prototype(data.raw["beacon"]["fe_resonance_shard"], "ufo-inhibitor")
scale.rescale_entity(ufo_inhibitor_entity, scale_factor)
-- TODO icons?
ufo_inhibitor_entity.max_health = 100
ufo_inhibitor_entity.energy_usage = "150kW"
ufo_inhibitor_entity.factoriopedia_description = { "factoriopedia-description.ufo-inhibitor" }
-- to make big-beautiful-module-icons working
ufo_inhibitor_entity.icons_positioning = nil
ufo_inhibitor_entity.surface_conditions = consts.sc_only_fulgora

local gs = ufo_inhibitor_entity.graphics_set

-- TODO HACK for POC
gs.animation_list[2].animation = {
    filename = "__ufo__/graphics/icons/blue-crystal.png",
    frame_count = 1,
    width = 256,
    height = 256,
    scale = 0.25,
    blend_mode="additive"
}

Log.logBlock(ufo_inhibitor_entity, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_inhibitor_item = data_util.copy_prototype(data.raw["item"]["fe_resonance_shard"], "ufo-inhibitor")
ufo_inhibitor_item.weight = 25 * kg
ufo_inhibitor_item.stack_size = 40
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_inhibitor_recipe = data_util.copy_prototype(data.raw["recipe"]["beacon"], "ufo-inhibitor")
local ingredients = ufo_inhibitor_recipe.ingredients
-- TODO
ingredients[#ingredients + 1] = { type = 'item', name = 'ufo-resonance-shard', amount = 1 }
ingredients[#ingredients + 1] = { type = 'item', name = 'holmium-plate', amount = 3 }
ufo_inhibitor_recipe.enabled = false
ufo_inhibitor_recipe.surface_conditions = consts.sc_only_fulgora

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

    prerequisites = { "ufo-archeological-tech" },
    effects = {{ type = "unlock-recipe", recipe = "ufo-resonance-shard" }},
    research_trigger = { type = "scripted", trigger_description = { "description.ufo-resonance-shard-tech" }},

    order = "c-e-b4",
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

    order = "c-e-b3",
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
