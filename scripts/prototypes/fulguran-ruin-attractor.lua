---
--- Created by xyzzycgn.
--- adapted fulguran ruin attractor
---
local Log = require("__log4factorio__.Log")
local data_util = require('__flib__.data-util')
local util = require('util') -- from lualib
local consts = require("__ufo__.scripts.consts")

Log.setSeverity(Log.CONFIG)
-- tint for entities and items
local tint = { r = 0.793, g = 0.625, b = 0.668, a = 0.3 }

-- adapted attractor entity
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
ufo_attractor.icon = "__ufo__/graphics/icons/fulgoran-ruin-attractor.png"
ufo_attractor.localised_description = { "entity-description.ufo-adapted-attractor" }
ufo_attractor.factoriopedia_description = { "factoriopedia-description.ufo-adapted-attractor" }
-- TODO if shown in factoriopedia change group where it's shown (not environment, but production)
ufo_attractor.render_no_network_icon = true

-- parameters for animation
local variation_count = 4
local frame_count = 8
local repeat_count = 2 * frame_count - 2
local animation_speed = 1/25

local oldsheet = ufo_attractor.stateless_visualisation.animation.sheet
oldsheet.filename = "__ufo__/graphics/entity/fulgoran-ruin-attractor.png"
oldsheet.line_length = 1
oldsheet.frame_count = 1
oldsheet.variation_count = variation_count
oldsheet.width = 448
oldsheet.height = 384
oldsheet.repeat_count = repeat_count
oldsheet.animation_speed = animation_speed,

Log.logBlock(oldsheet, function(m)log(m)end, Log.FINER)
ufo_attractor.stateless_visualisation.animation = {
    sheets = {
        -- attractor
        oldsheet,
        -- blue light on top
        {
            filename = "__ufo__/graphics/entity/fulgoran-ruin-attractor-glow.png",
            width = 120,
            height = 96,
            frame_count = frame_count,
            line_length = frame_count,
            scale = 0.5,
            shift = util.by_pixel(3, -127),
            variation_count = variation_count,
            animation_speed = animation_speed,
            run_mode = "forward-then-backward"
        }
    },
    sheet = nil
}
Log.logBlock(ufo_attractor, function(m)log(m)end, Log.FINER)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- adapter item
local ufo_adapter_item = data_util.copy_prototype(data.raw["item"]["processing-unit"], "ufo-adapter")
local order = ufo_adapter_item.order or "ufo"
ufo_adapter_item.icon = "__ufo__/graphics/icons/ufo-adapter.png"
ufo_adapter_item.order = order .. "-a"
ufo_adapter_item.factoriopedia_description = { "factoriopedia-description.ufo-adapter" }
Log.logBlock(ufo_adapter_item, function(m)log(m)end, Log.FINE)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_adapter_recipe = data_util.copy_prototype(data.raw["recipe"]["processing-unit"], "ufo-adapter")
ufo_adapter_recipe.ingredients = {
    { type = "item", name = "small-lamp", amount = 1 },
    { type = "item", name = "electronic-circuit", amount = 5 },
    { type = "item", name = "advanced-circuit", amount = 2 },
    { type = "item", name = "processing-unit", amount = 1 },
    { type = "item", name = "holmium-plate", amount = 1 },
    { type = "item", name = "ufo-resonance-raw-shard", amount = 1 },
}
ufo_adapter_recipe.category="electronics"
ufo_adapter_recipe.allow_quality=false
ufo_adapter_recipe.energy_required=20
Log.logBlock(ufo_adapter_recipe, function(m)log(m)end, Log.FINE)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local function add_tint(prototype)
    local icon = prototype.icon
    local icon_size = prototype.icon_size
    prototype.icons =  {
        {
            icon = icon,
            icon_size = icon_size,
            tint = tint,
        }
    }
    prototype.icon = nil
    prototype.icon_size = nil
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- effects for tech
local effects = {
    { type = 'unlock-recipe', recipe = 'ufo-resonance-raw-shard' },
    { type = 'unlock-recipe', recipe = 'ufo-adapter' }
}

-- all recipes unlocked by tech
local recipes = { [1] = ufo_adapter_recipe }

-- all items unlocked by tech
local items = { [1] = ufo_adapter_item }

-- all entities unlocked by tech
local entities = {}

-- create recipes and so on for each adapted electric-pole
for k, _ in pairs(data.raw["electric-pole"]) do
    local adapted_name = 'ufo-adapted-' .. k
    -- effect for tech
    effects[#effects + 1] = { type = 'unlock-recipe', recipe = adapted_name }

    -- make recipe
    local recipe = data_util.copy_prototype(data.raw["recipe"][k], adapted_name)
    recipe.enabled = false
    -- add an adapter and 2 holmium plates
    recipe.ingredients[#recipe.ingredients + 1] = {type = 'item', name = 'ufo-adapter', amount = 1}
    recipe.ingredients[#recipe.ingredients + 1] = {type = 'item', name = 'holmium-plate', amount = 2}
    recipe.surface_conditions = consts.sc_only_fulgora
    recipes[#recipes + 1] = recipe
    Log.logBlock(recipe, function(m)log(m)end, Log.FINE)

    -- and item
    local ufo_adapted_item = data_util.copy_prototype(data.raw["item"][k], adapted_name)
    Log.logBlock(ufo_adapted_item, function(m)log(m)end, Log.FINE)
    -- set tint for ufo_adapted_item
    add_tint(ufo_adapted_item)
    Log.logBlock(ufo_adapted_item, function(m)log(m)end, Log.FINE)

    items[#items + 1] = ufo_adapted_item

    -- and entity
    local orig_pole = data.raw["electric-pole"][k]
    local ufo_adapted_entity = data_util.copy_prototype(orig_pole, adapted_name)
    local flags = orig_pole.flags
    -- orig_pole must not already have a next_upgrade or flag "not-upgradable" set
    if not (orig_pole.next_upgrade or (flags and flags["not-upgradable"])) then
        -- set adapted pole as possible upgrade
        orig_pole.next_upgrade = adapted_name
    end

    Log.logBlock(ufo_adapted_entity, function(m)log(m)end, Log.FINE)
    -- localised_name and localised_description are used for item and recipe too
    ufo_adapted_entity.localised_name = { "entity-name.ufo-adaptees" , { "entity-name." .. k }}
    ufo_adapted_entity.localised_description = { "entity-description.ufo-adaptees" , { "entity-name." .. k }}
    ufo_adapted_entity.surface_conditions = consts.sc_only_fulgora
    ufo_adapted_entity.pictures.layers[1].tint = tint
    -- set tint for ufo_adapted_entity
    add_tint(ufo_adapted_entity)
    Log.logBlock(ufo_adapted_entity, function(m)log(m)end, Log.FINE)

    entities[#entities + 1] = ufo_adapted_entity
end

--- ufo base technologies
local num_vaults = settings.startup["ufo-mined-ruin-vaults-needed"].value
local ufo_arch_tech = {
    name = 'ufo-archeological-tech',
    type = 'technology',
    icon = "__ufo__/graphics/icons/archeological-tech.png",
    icon_size = 256,
    icon_mipmaps = 4,

    prerequisites = { "planet-discovery-fulgora" },
    unit = {
        count = 60,
        ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 1 },
            { "chemical-science-pack", 2 },
            { "utility-science-pack", 1 },
            { "space-science-pack", 2 },
            { "metallurgic-science-pack", 1 },
        },
        time = 35,
    },
    order = "c-e-b3",
}

local ufo_tech = {
    name = 'ufo-tech',
    type = 'technology',
    icon = "__ufo__/graphics/icons/fulgoran-ruin-attractor.png",

    prerequisites = { "ufo-archeological-tech" },
    effects = effects,

    research_trigger = { type = "scripted", trigger_description = {"description.ufo-tech", tostring(num_vaults)}},
    order = "c-e-b2",
    factoriopedia_description = { "factoriopedia-description.ufo-tech" }
}
-- ###############################################################

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

extensions[#extensions + 1] = ufo_arch_tech
extensions[#extensions + 1] = ufo_tech

data:extend(extensions)
