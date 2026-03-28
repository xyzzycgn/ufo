---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local data_util = require("__flib__.data-util")
local item_sounds = require("__base__.prototypes.item_sounds")
local consts = require("__ufo__.scripts.consts")
local prototypeHelper = require("__ufo__.scripts.prototypeHelper")

local scale_factor = 1.5
local ufo_crusher_entity = prototypeHelper.copyAndReplace("assembling-machine", "crusher", "ufo-crusher", {
    energy_usage = "600kW",
    factoriopedia_description = { "factoriopedia-description.ufo-crusher" },
    surface_conditions = {{ property = "gravity", min = 1, }},
}, scale_factor)
ufo_crusher_entity.icon_draw_specification.scale = scale_factor
ufo_crusher_entity.icon_draw_specification.scale_for_many = scale_factor
Log.logBlock(ufo_crusher_entity, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_crusher_item = data_util.copy_prototype(data.raw["item"]["crusher"], "ufo-crusher")
local order = ufo_crusher_item.order or "ufo"
ufo_crusher_item.subgroup = "production-machine"
ufo_crusher_item.order = order .. "-a"
Log.logBlock(ufo_crusher_item, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_crusher_recipe = prototypeHelper.copyAndReplace("recipe", "crusher", "ufo-crusher", { enabled = false })
Log.logBlock(ufo_crusher_recipe, function(m)log(m)end, Log.CONFIG)
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
    hide_from_player_crafting = true,
}
-- ###############################################################

-- enable sand and crusher with space-platform (like normal crusher)
local sppe = data.raw["technology"]["space-platform"].effects
sppe[#sppe + 1] = { type = "unlock-recipe", recipe = "ufo-crusher" }
sppe[#sppe + 1] = { type = "unlock-recipe", recipe = "ufo-sand" }
Log.logBlock(sppe, function(m)log(m)end, Log.FINE)
-- ###############################################################

local ufo_resonance_raw_shard_item = prototypeHelper.copyAndReplace("item", "iron-plate", "ufo-resonance-raw-shard", {
    icon = "__ufo__/graphics/icons/raw-pink-crystal.png",
    icon_size = 256,
    icon_mipmaps = 4,
})

local ufo_resonance_raw_shard_recipe = prototypeHelper.copyAndReplace("recipe", "iron-plate", "ufo-resonance-raw-shard", {
    category = "metallurgy",
    ingredients = {
        { type = "item", name = "ufo-sand", amount = 50 },
        { type = "item", name = "holmium-ore", amount = 15 }
    },
    results = { { type = "item", name = "ufo-resonance-raw-shard", amount = 1 } },
    surface_conditions = consts.sc_only_fulgora,
    enabled = false,
    allow_speed = false,
    allow_productivity = false,
    maximum_productivity = 0,
    auto_recycle = false,
    energy_required = 25,
})

Log.logBlock(ufo_resonance_raw_shard_recipe, function(m)log(m)end, Log.CONFIG)


local ufo_resonance_raw_shard_tech = {
    name = 'ufo-resonance-raw-shard-tech',
    type = 'technology',
    icon = "__ufo__/graphics/icons/raw-pink-crystal.png",
    icon_size = 256,
    icon_mipmaps = 4,

    prerequisites = { "ufo-archeological-tech" },
    effects = {{ type = 'unlock-recipe', recipe = 'ufo-resonance-raw-shard' }},

    research_trigger = { type = "mine-entity", entity = "fulgoran-ruin-colossal"},
    order = "c-e-a",
    factoriopedia_description = { "factoriopedia-description.ufo-resonance-raw-shard-tech" }
}


-- ###############################################################

data:extend( {
    ufo_crusher_entity,
    ufo_crusher_item,
    ufo_crusher_recipe,
    sand_item,
    sand_recipe,
    ufo_resonance_raw_shard_item,
    ufo_resonance_raw_shard_recipe,
    ufo_resonance_raw_shard_tech
})