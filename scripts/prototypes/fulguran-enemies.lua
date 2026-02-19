---
--- Created by xyzzycgn.
--- adapter to mod Electric_flying_enemies
---
local data_util = require("__flib__.data-util")
local Log = require("__log4factorio__.Log")
local scale = require("__ufo__.scripts.scale")
local consts = require("__ufo__.scripts.consts")

Log.log("mod Electric_flying_enemies detected", function(m)log(m)end, Log.CONFIG)
-- ###############################################################

local ufo_vault = data_util.copy_prototype(data.raw["simple-entity"]["fulgoran-ruin-vault"], "ufo-fulgoran-ruin-vault")
ufo_vault.hidden_in_factoriopedia = true

-- ###############################################################

local scale_factor = 0.5
local ufo_inhibitor_entity = data_util.copy_prototype(data.raw["beacon"]["fe_resonance_shard"], "ufo-inhibitor-shard")
scale.rescale_entity(ufo_inhibitor_entity, scale_factor)
-- TODO icons
ufo_inhibitor_entity.max_health = 100
ufo_inhibitor_entity.energy_usage = "150kW"
ufo_inhibitor_entity.factoriopedia_description = { "factoriopedia-description.ufo-recycler" }
-- to make big-beautiful-module-icons working
ufo_inhibitor_entity.icons_positioning = nil
ufo_inhibitor_entity.surface_conditions = consts.sc_only_fulgora
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_inhibitor_item = data_util.copy_prototype(data.raw["item"]["fe_resonance_shard"], "ufo-inhibitor-shard")
ufo_inhibitor_item.weight = 25 * kg
ufo_inhibitor_item.stack_size = 40
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_inhibitor_recipe = data_util.copy_prototype(data.raw["recipe"]["beacon"], "ufo-inhibitor-shard")
local ingredients = ufo_inhibitor_recipe.ingredients
-- TODO
ingredients[#ingredients + 1] = { type = 'item', name = 'stone', amount = 2 }
ingredients[#ingredients + 1] = { type = 'item', name = 'holmium-plate', amount = 3 }
ufo_inhibitor_recipe.enabled = false
ufo_inhibitor_recipe.surface_conditions = consts.sc_only_fulgora

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_inhibitor_tech = {
    name = 'ufo-inhibitor-tech',
    type = 'technology',
    icon = "__ufo__/graphics/icons/fulgoran-ruin-attractor.png",

    prerequisites = { "ufo-archeological-tech" },
    effects = {{ type = "unlock-recipe", recipe = "ufo-inhibitor-shard" }},

    research_trigger = { type = "scripted", trigger_description = { "description.ufo-inhibitor-tech" }},
    order = "c-e-b2",
    factoriopedia_description = { "factoriopedia-description.ufo-inhibitor-tech" }
}

data:extend({
    ufo_vault,
    ufo_inhibitor_entity,
    ufo_inhibitor_item,
    ufo_inhibitor_recipe,
    ufo_inhibitor_tech,
})
