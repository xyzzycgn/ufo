---
--- Created by xyzzycgn.
--- adapted fulguran ruin attractor
---
local Log = require("__log4factorio__.Log")
local prototypeHelper = require("scripts.prototypeHelper")
local data_util = require('__flib__.data-util')
local util = require('util') -- from lualib
local consts = require("scripts.consts")

Log.setSeverity(Log.CONFIG)
-- tint for entities and items
local tint = { r = 0.793, g = 0.625, b = 0.668, a = 0.3 }

-- adapted attractor entity
local ufo_attractor = prototypeHelper.copyAndReplace("lightning-attractor", "fulgoran-ruin-attractor", "ufo-adapted-attractor", {
    energy_source = {
        buffer_capacity = "2GJ",
        drain = "100MW",
        output_flow_limit = "1GW",
        type = "electric",
        usage_priority = "primary-output"
    },
    efficiency = 0.55,
    hidden_in_factoriopedia =    false,
    factoriopedia_description = { "factoriopedia-description.ufo-adapted-attractor" },
    subgroup = "environmental-protection", --  change place where it's shown (not environment, but production)
    render_no_network_icon = true,
    icon = "__use-fulguran-objects__/graphics/icons/fulgoran-ruin-attractor.png",
    localised_description = { "entity-description.ufo-adapted-attractor" },
})

-- parameters for animation
local variation_count = 4
local frame_count = 8
local repeat_count = 2 * frame_count - 2
local animation_speed = 1/25

local oldsheet = ufo_attractor.stateless_visualisation.animation.sheet
oldsheet.filename = "__use-fulguran-objects__/graphics/entity/fulgoran-ruin-attractor.png"
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
            filename = "__use-fulguran-objects__/graphics/entity/fulgoran-ruin-attractor-glow.png",
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
ufo_attractor.order = nil

Log.logBlock(data.raw["lightning-attractor"], function(m)log(m)end, Log.FINE)
Log.logBlock(ufo_attractor, function(m)log(m)end, Log.FINE)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- adapter item
local ufo_adapter_item = data_util.copy_prototype(data.raw["item"]["processing-unit"], "ufo-adapter")
local order = ufo_adapter_item.order or "ufo"
ufo_adapter_item.icon = "__use-fulguran-objects__/graphics/icons/ufo-adapter.png"
ufo_adapter_item.order = order .. "-a"
ufo_adapter_item.factoriopedia_description = { "factoriopedia-description.ufo-adapter" }
Log.logBlock(ufo_adapter_item, function(m)log(m)end, Log.FINE)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_adapter_recipe = prototypeHelper.copyAndReplace("recipe", "processing-unit", "ufo-adapter", {
    ingredients = {
        { type = "item", name = "small-lamp", amount = 1 },
        { type = "item", name = "electronic-circuit", amount = 5 },
        { type = "item", name = "advanced-circuit", amount = 2 },
        { type = "item", name = "processing-unit", amount = 1 },
        { type = "item", name = "holmium-plate", amount = 1 },
        { type = "item", name = "ufo-resonance-raw-shard", amount = 1 },
    },
    category="electronics",
    allow_quality=false,
    energy_required=20,
})
Log.logBlock(ufo_adapter_recipe, function(m)log(m)end, Log.FINE)
-- ###############################################################

-- effects for tech
local effects = {
    { type = 'unlock-recipe', recipe = 'ufo-adapter' }
}

-- all recipes unlocked by tech
local recipes = { [1] = ufo_adapter_recipe }

-- all items unlocked by tech
local items = { [1] = ufo_adapter_item }

-- all entities unlocked by tech
local entities = {}

-- fix for #13
-- list of prototypes which must be blacklisted (e.g. due to no recipe)
local blacklist = {}

--- @type table<string, string[]> list of prototypes to be blacklisted per mod
local modsWithBlacklistedPrototypes = {
    Subsurface = { "tunnel-entrance-cable", "tunnel-exit-cable" }
}

-- fill blacklist
for mod, list in pairs(modsWithBlacklistedPrototypes) do
    if mods[mod] then
        Log.logMsg(function(m)log(m)end, Log.CONFIG, "detected mod %s with prototypes to be blacklisted", mod)
        for _, p in pairs(list) do
            blacklist[p] = true
            Log.logMsg(function(m)log(m)end, Log.CONFIG, "blacklisted prototype %s", p)
        end
    end
end
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

local function getExistingPrototype(group, prototypeName)
    return data.raw[group][prototypeName]
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--- fix for #19
--- @param picture RotatedSprite
local function layer(picture)
    return {
        direction_count = picture.direction_count,
        filename = picture.filename,
        size = picture.size,
        x = picture.x,
        y = picture.y,
        height = picture.height,
        width = picture.width,
        priority = picture.priority,
        shift = picture.shift,
        line_length = picture.line_length,
        tint = tint,
    }
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--- fix for #19
--- @param prototype ElectricPolePrototype
local function tintPicture(prototype)
    local old_pictures = prototype.pictures

    if old_pictures.layers then
        -- simple way, when prototype is using layers
        old_pictures.layers[1].tint = tint
    elseif old_pictures.filename then
        -- bit more complicated without layers, but single filename
        local layers = {
            [1] = layer(old_pictures)
        }
        old_pictures.layers = layers
        -- remove no longer used members
        old_pictures.direction_count = nil
        old_pictures.filename = nil
        old_pictures.size = nil
        old_pictures.x = nil
        old_pictures.y = nil
        old_pictures.height = nil
        old_pictures.width = nil
        old_pictures.priority = nil
        old_pictures.shift = nil
        old_pictures.line_length = nil
    else
        -- worst case – prototype uses filenames
    end
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--- @param poleName string
--- @param orig_pole ElectricPolePrototype
local function makeAdaptedPoles(poleName, orig_pole)
    -- fix for #13 ignore blacklisted prototypes
    if blacklist[poleName] then
        Log.logMsg(function(m)log(m)end, Log.CONFIG, "ignore blacklisted prototype %s", poleName)
        return
    end

    -- fix for #13 check prototypes not in blacklist without recipe
    local baserecipe = getExistingPrototype("recipe", poleName)
    if not baserecipe then
        Log.logMsg(function(m)log(m)end, Log.WARN, "ignore prototype not in blacklist without recipe - %s", poleName)
        return
    end
    -- fix for #13 check prototypes not in blacklist without item
    local baseitem = getExistingPrototype("item", poleName)
    if not baseitem then
        Log.logMsg(function(m)log(m)end, Log.WARN, "ignore prototype not in blacklist without item - %s", poleName)
        return
    end

    local adapted_name = 'ufo-adapted-' .. poleName
    -- effect for tech
    effects[#effects + 1] = { type = 'unlock-recipe', recipe = adapted_name }

    -- make recipe
    local recipe = data_util.copy_prototype(baserecipe, adapted_name)
    recipe.enabled = false
    -- add an adapter and 2 holmium plates
    recipe.ingredients[#recipe.ingredients + 1] = {type = 'item', name = 'ufo-adapter', amount = 1}
    recipe.ingredients[#recipe.ingredients + 1] = {type = 'item', name = 'holmium-plate', amount = 2}
    recipe.surface_conditions = consts.sc_only_fulgora
    recipes[#recipes + 1] = recipe
    Log.logBlock(recipe, function(m)log(m)end, Log.FINE)

    -- and item
    local ufo_adapted_item = data_util.copy_prototype(baseitem, adapted_name)
    Log.logBlock(ufo_adapted_item, function(m)log(m)end, Log.FINE)
    -- set tint for ufo_adapted_item
    add_tint(ufo_adapted_item)
    Log.logBlock(ufo_adapted_item, function(m)log(m)end, Log.FINE)

    items[#items + 1] = ufo_adapted_item

    -- and entity
    local ufo_adapted_entity = data_util.copy_prototype(orig_pole, adapted_name)
    local flags = orig_pole.flags
    -- orig_pole must not already have a next_upgrade or flag "not-upgradable" set
    if not (orig_pole.next_upgrade or (flags and flags["not-upgradable"])) then
        -- set adapted pole as possible upgrade
        orig_pole.next_upgrade = adapted_name
    end

    Log.logBlock(ufo_adapted_entity, function(m)log(m)end, Log.FINE)
    -- localised_name and localised_description are used for item and recipe too
    ufo_adapted_entity.localised_name = { "entity-name.ufo-adaptees" , { "entity-name." .. poleName }}
    ufo_adapted_entity.localised_description = { "entity-description.ufo-adaptees" , { "entity-name." .. poleName }}
    ufo_adapted_entity.surface_conditions = consts.sc_only_fulgora
    tintPicture(ufo_adapted_entity)
    -- set tint for the icon of ufo_adapted_entity
    add_tint(ufo_adapted_entity)
    Log.logBlock(ufo_adapted_entity, function(m)log(m)end, Log.FINE)

    entities[#entities + 1] = ufo_adapted_entity
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- create recipes and so on for each adapted electric-pole
for k, v in pairs(data.raw["electric-pole"]) do
    makeAdaptedPoles(k, v)
end
-- ###############################################################

--- ufo base technologies
local num_vaults = settings.startup["ufo-mined-ruin-vaults-needed"].value
local ufo_arch_tech = {
    name = 'ufo-archeological-tech',
    type = 'technology',
    icon = "__use-fulguran-objects__/graphics/icons/archeological-tech.png",
    icon_size = 256,
    icon_mipmaps = 4,
    essential = true,

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
    order = "ufo-a",
}
-- ###############################################################

local ufo_tech = {
    name = 'ufo-tech',
    type = 'technology',
    icon = "__use-fulguran-objects__/graphics/icons/fulgoran-ruin-attractor.png",

    prerequisites = { "ufo-resonance-raw-shard-tech" },
    effects = effects,

    research_trigger = { type = "scripted", trigger_description = {"description.ufo-tech", tostring(num_vaults)}},
    order = "ufo-b-c4",
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
