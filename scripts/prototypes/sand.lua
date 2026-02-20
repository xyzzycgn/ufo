---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local data_util = require("__flib__.data-util")
local item_sounds = require("__base__.prototypes.item_sounds")
local scale = require("__ufo__.scripts.scale")

local scale_factor = 1.5
local ufo_crusher_entity = data_util.copy_prototype(data.raw["assembling-machine"]["crusher"], "ufo-crusher")
scale.rescale_entity(ufo_crusher_entity, scale_factor)
ufo_crusher_entity.energy_usage = "600kW"
ufo_crusher_entity.factoriopedia_description = { "factoriopedia-description.ufo-crusher" }
ufo_crusher_entity.icon_draw_specification.scale = scale_factor
ufo_crusher_entity.icon_draw_specification.scale_for_many = scale_factor
ufo_crusher_entity.surface_conditions = {{ property = "gravity", min = 1, }}
Log.logBlock(ufo_crusher_entity, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_crusher_item = data_util.copy_prototype(data.raw["item"]["crusher"], "ufo-crusher")
local order = ufo_crusher_item.order or "ufo"
ufo_crusher_item.subgroup = "production-machine"
ufo_crusher_item.order = order .. "-a"
Log.logBlock(ufo_crusher_item, function(m)log(m)end, Log.CONFIG)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local crusher = data.raw["recipe"]["crusher"]
local ufo_crusher_recipe = data_util.copy_prototype(crusher, "ufo-crusher")
ufo_crusher_recipe.enabled = false
Log.logBlock(ufo_crusher_recipe, function(m)log(m)end, Log.CONFIG)

-- enabled it with space-platform (like normal crusher)
local sppe = data.raw["technology"]["space-platform"].effects
sppe[#sppe + 1] = { type = "unlock-recipe", recipe = "ufo-crusher" }
Log.logBlock(sppe, function(m)log(m)end, Log.CONFIG)

-- ###############################################################

local sand_item = {
    type = "item",
    name = "sand",
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
    name = "sand",
    enabled = true, -- TODO??
    ingredients = { { type = "item", name = "stone", amount = 7 } },
    results = { { type = "item", name = "sand", amount = 5 } },
    allow_productivity = true,
    auto_recycle = false,
    category = "crushing",
    hide_from_player_crafting = true,
}
-- ###############################################################

data:extend( {
    ufo_crusher_entity,
    ufo_crusher_item,
    ufo_crusher_recipe,
    sand_item,
    sand_recipe
})