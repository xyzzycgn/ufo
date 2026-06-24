---
--- Created by xyzzycgn.
--- improved beacon
---
local Log = require("__log4factorio__.Log")
local data_util = require("__flib__.data-util")
local scale = require("scripts.scale")
local consts = require("scripts.consts")
local prototypeHelper = require("scripts.prototypeHelper")

-- ###############################################################

local scale_factor = 2 / 3
local tint = { r = 0.75, g = 0.75, b = 1, a = 0.6 }
-- to use tint it must be icons
local icons = {
    {
        icon = "__base__/graphics/icons/beacon.png",
        icon_size = 64,
        tint = tint,
        scale = scale_factor,
    }
}
-- ###############################################################

local ufo_beacon_entity = data_util.copy_prototype(data.raw["beacon"]["beacon"], "ufo-beacon")
Log.logBlock(ufo_beacon_entity, function(m)log(m)end, Log.FINE)
scale.rescale_entity(ufo_beacon_entity, scale_factor)
ufo_beacon_entity.icon = nil
ufo_beacon_entity.icons = icons
ufo_beacon_entity.energy_usage = "360kW"
ufo_beacon_entity.module_slots = 4
ufo_beacon_entity.distribution_effectivity = ufo_beacon_entity.distribution_effectivity * 1.2
ufo_beacon_entity.supply_area_distance = ufo_beacon_entity.supply_area_distance + 2
ufo_beacon_entity.factoriopedia_description = { "factoriopedia-description.ufo-beacon" }
-- to make big-beautiful-module-icons working
ufo_beacon_entity.icons_positioning = nil
-- fix for #33 - deals with other mods setting next_upgrade in the vanilla beacon and prevent load errors
ufo_beacon_entity.next_upgrade = nil

Log.logBlock(ufo_beacon_entity, function(m)log(m)end, Log.FINE)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_beacon_item = data_util.copy_prototype(data.raw["item"]["beacon"], "ufo-beacon")
local order = ufo_beacon_item.order or "ufo"
ufo_beacon_item.icon = nil
ufo_beacon_item.icons = icons
ufo_beacon_item.order = order .. "-a"
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local ufo_beacon_recipe = prototypeHelper.copyAndReplace("recipe", "beacon", "ufo-beacon", {
    enabled = false,
    surface_conditions = consts.sc_only_fulgora
})
prototypeHelper.additionalIngredients(ufo_beacon_recipe, {
    { type = 'item', name = 'ufo-adapter', amount = 2 },
    { type = 'item', name = 'holmium-plate', amount = 3 },
})
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- technology
local ufo_beacon_tech = {
    name = "ufo-effect-transmission-tech",
    type = "technology",
    icons = {
        {
            icon = "__base__/graphics/technology/effect-transmission.png",
            icon_size = 256,
            icon_mipmaps = 4,
            tint = tint,
            scale = scale_factor,
        }
    },

    prerequisites = { "effect-transmission" , "ufo-fulgoran-know-how-tech" },
    effects = {{ type = "unlock-recipe", recipe = "ufo-beacon" }},

    unit = {
        count = 60,
        ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 2 },
            { "production-science-pack", 1 },
            { "utility-science-pack", 3 },
            { "metallurgic-science-pack", 2 },
        },
        time = 20,
    },
    order = "ufo-b-c4-d3-e3",
    factoriopedia_description = { "factoriopedia-description.ufo-beacon" }
}
-- ###############################################################

data:extend({
    ufo_beacon_item,
    ufo_beacon_entity,
    ufo_beacon_recipe,
    ufo_beacon_tech
})

return emp