---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local data_util = require('__flib__.data-util')
Log.setSeverity(Log.CONFIG)

---- der fulgorianische Blitzableiter
Log.logBlock(data.raw["lightning-attractor"]["fulgoran-ruin-attractor"], function(m)log(m)end)


local ufo_attractor = data_util.copy_prototype(data.raw["lightning-attractor"]["fulgoran-ruin-attractor"], "ufo-adapted-attractor")
ufo_attractor.energy_source = {
    buffer_capacity = "2GJ",
    drain = "100MW",
    output_flow_limit = "1GW",
    type = "electric",
    usage_priority = "primary-output"
  }
ufo_attractor.efficiency = 0.55
ufo_attractor.hidden_in_factoriopedia = false
ufo_attractor.localised_description = { "entity-description.ufo-adapted-attractor" }
ufo_attractor.factoriopedia_description = { "factoriopedia-description.ufo-adapted-attractor" }
-- TODO if shown in factoriopedia change group where it's shown (not environment, but production)
ufo_attractor.render_no_network_icon = true
-- blue light on top
local sheet = ufo_attractor.stateless_visualisation.animation.sheet
ufo_attractor.stateless_visualisation.animation = {
    sheets = {
        [1] = sheet,
        [2] = {
            filename = "__ufo__/graphics/entity//fulgoran-ruin-attractor-glow.png",
            frame_count = 1,
            height = 96,
            line_length = 4,
            scale = 0.5,
            shift = { 1.609375, -3.8125 },
            variation_count = 4,
            width = 448
        }
    },
    sheet = nil
}
Log.logBlock(ufo_attractor, function(m)log(m)end)

-- adapter item
local ufo_adapter_item = data_util.copy_prototype(data.raw["item"]["small-lamp"], "ufo-adapter")
local order = ufo_adapter_item.order or "ufo"
ufo_adapter_item.icon = "__space-age__/graphics/icons/fulgoran-ruin-attractor.png"
ufo_adapter_item.order = order .. "-a"

-- adapter entity
local ufo_adapter_entity = data_util.copy_prototype(data.raw["lamp"]["small-lamp"], "ufo-adapter")

local ufo_adapter_recipe = data_util.copy_prototype(data.raw["recipe"]["small-lamp"], "ufo-adapter")
ufo_adapter_recipe.ingredients = {
    { type = "item", name = "small-lamp", amount = 1 },
    { type = "item", name = "electronic-circuit", amount = 5 },
    { type = "item", name = "advanced-circuit", amount = 2 },
    { type = "item", name = "processing-unit", amount = 1 },
}

-- effects for tech
local effects = {{ type = 'unlock-recipe', recipe = 'ufo-adapter' }}

-- all recipes unlocked by tech
local recipes = { [1] = ufo_adapter_recipe }

-- all items unlocked by tech
local items = { [1] = ufo_adapter_item }

-- all entities unlocked by tech
local entities = { [1] = ufo_adapter_entity }

--- @type SurfaceCondition only on fulgora
local sc_only_fulgora = {{ property = "magnetic-field", min = 99 }}

-- create recipes and so on for each electric-pole
for k, _ in pairs(data.raw["electric-pole"]) do
    local adapted_name = 'ufo-adapted-' .. k
    -- effect for tech
    effects[#effects + 1] = { type = 'unlock-recipe', recipe = adapted_name }

    -- make recipe
    local recipe = data_util.copy_prototype(data.raw["recipe"][k], adapted_name)
    recipe.enabled = false
    recipe.ingredients = {
        {type = 'item', name = k, amount = 1},
        {type = 'item', name = 'ufo-adapter', amount = 1},
    }
    recipe.results = {{ type = 'item', name = adapted_name, amount = 1}}
    recipe.surface_conditions = sc_only_fulgora
    recipes[#recipes + 1] = recipe

    -- and item
    local ufo_adapted_item = data_util.copy_prototype(data.raw["item"][k], adapted_name)
    -- ufo_adapted_entity.tint = ....
    items[#items + 1] = ufo_adapted_item

    -- and entity
    local ufo_adapted_entity = data_util.copy_prototype(data.raw["electric-pole"][k], adapted_name)
    -- localised_name and localised_description are used for item and recipe too
    ufo_adapted_entity.localised_name = { "entity-name.ufo-adaptees" , { "entity-name." .. k }}
    ufo_adapted_entity.localised_description = { "entity-description.ufo-adaptees" , { "entity-name." .. k }}
    ufo_adapted_entity.surface_conditions = sc_only_fulgora
    entities[#entities + 1] = ufo_adapted_entity
end

--- ufo technology
local num_vaults = settings.startup["ufo-mined-ruin-vaults-needed"].value
local ufo_tech = {
    name = 'ufo-tech',
    type = 'technology',
    icon = "__space-age__/graphics/icons/fulgoran-ruin-attractor.png",

    prerequisites = { "planet-discovery-fulgora" },
    effects = effects,

    research_trigger = { type = "scripted", trigger_description = {"description.ufo-tech", tostring(num_vaults)}},
    order = "c-e-b2",
}


local extensions = {
    [1] = ufo_attractor
}
for _, item in pairs(items) do
    extensions[#extensions + 1] = item
end
for _, entity in pairs(entities) do
    extensions[#extensions + 1] = entity
end
for _, recipe in pairs(recipes) do
    extensions[#extensions + 1] = recipe
end

extensions[#extensions + 1] = ufo_tech

data:extend(extensions)
