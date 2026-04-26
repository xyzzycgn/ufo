---
--- Created by xyzzycgn.
--- further recipes for electrodynamic fragmentation device
--- these recycling recipes need to be defined here, as the originating recipes do not exist yet when data.lua is read
---
local Log = require("__log4factorio__.Log")
local prototypeHelper = require("__ufo__.scripts.prototypeHelper")

local edf_recipes = {}
local edf_sources = {
    ["electronic-circuit-recycling"]    = { energy = 15, input = 100, output = 99 },
    ["advanced-circuit-recycling"]      = { energy = 17, input = 110, output = 109 },
    ["processing-unit-recycling"]       = { energy = 20, input = 120, output = 118 },
    ["low-density-structure-recycling"] = { energy = 25, input = 180, output = 177 },
}
local effects = data.raw["technology"]["ufo-electrodynamic-fragmentation-tech"].effects

for recipe, recipe_parameters in pairs(edf_sources) do
    Log.logLine(recipe, function(m)log(m)end, Log.CONFIG)
    local name = "ufo-edf-" .. recipe

    local ufo_edf_recipe = prototypeHelper.copyAndReplace("recipe", recipe , name, {
        enabled = false,
        category = "electrodynamic-fragmentation-category",
        hide_from_player_crafting = true,
        hidden = false,
        factoriopedia_alternative = recipe,
        allow_productivity = true,
        allow_quality = false,
        auto_recycle = false,
    })
    ufo_edf_recipe.energy_required = ufo_edf_recipe.energy_required * recipe_parameters.energy + 1

    local ingredients = ufo_edf_recipe.ingredients
    local results = ufo_edf_recipe.results

    for _, ingredient in pairs(ingredients) do
        ingredient.amount = ingredient.amount * 6
    end

    for _, result in pairs(results) do
        result.amount = result.amount * 8
        result.extra_count_fraction = result.extra_count_fraction * 7 + 0.5
    end

    ingredients[#ingredients + 1] = { type = "fluid", name = "water", amount = recipe_parameters.input }
    results[#results + 1] = { type = "fluid", name = "water", amount = recipe_parameters.output }

    edf_recipes[#edf_recipes + 1] = ufo_edf_recipe
    effects[#effects + 1] = { type = "unlock-recipe", recipe = name }
end
-- ###############################################################

Log.logBlock(edf_recipes, function(m)log(m)end, Log.CONFIG)
Log.logBlock(data.raw["technology"]["ufo-electrodynamic-fragmentation-tech"], function(m)log(m)end, Log.CONFIG)

data:extend(edf_recipes)