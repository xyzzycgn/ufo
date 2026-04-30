---
--- Created by xyzzycgn.
--- further recipes for electrodynamic fragmentation device
--- these recycling recipes need to be defined here, as the originating recipes do not exist yet when data.lua is read
---
local Log = require("__log4factorio__.Log")
local prototypeHelper = require("__use-fulguran-objects__.scripts.prototypeHelper")

local edf_recipes = {}
local edf_sources = {
    ["electronic-circuit-recycling"]    = { energy = 15, in_amount = 6,  res = { amount = 8,  extra = 7,  delta = 0.5 }, input = 100, output = 99 },
    ["advanced-circuit-recycling"]      = { energy = 17, in_amount = 6,  res = { amount = 8,  extra = 7,  delta = 0.5 }, input = 110, output = 109 },
    ["processing-unit-recycling"]       = { energy = 20, in_amount = 6,  res = { amount = 8,  extra = 7,  delta = 0.4 }, input = 120, output = 118 },
    ["low-density-structure-recycling"] = { energy = 25, in_amount = 10, res = { amount = 12, extra = 11, delta = 0.7 }, input = 200, output = 196 },
}
local effects = data.raw["technology"]["ufo-electrodynamic-fragmentation-tech"].effects

for recipe, recipe_parameters in pairs(edf_sources) do
    Log.logLine(recipe, function(m)log(m)end, Log.CONFIG)
    local name = "ufo-edf-" .. recipe

    local ufo_edf_recipe = prototypeHelper.copyAndReplace("recipe", recipe , name, {
        enabled = false,
        category = "electrodynamic-fragmentation-category",
        subgroup = "intermediate-product",
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
        ingredient.amount = ingredient.amount * recipe_parameters.in_amount
    end

    for _, result in pairs(results) do
        local res = recipe_parameters.res
        result.amount = result.amount * res.amount
        result.extra_count_fraction = result.extra_count_fraction * res.extra + res.delta
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