---
--- Created by xyzzycgn.
--- prototypes related to F.R.D.
---
local Log = require("__log4factorio__.Log")
local data_util = require('__flib__.data-util')

Log.logBlock(defines.prototypes["equipment-category"]["equipment-category"], function(m)log(m)end, Log.CONFIG)
Log.logBlock(data.raw["battery-equipment"], function(m)log(m)end, Log.CONFIG)
Log.logBlock(data.raw.item["battery-equipment"], function(m)log(m)end, Log.CONFIG)
Log.logBlock(data.raw["equipment-category"]["armor"], function(m)log(m)end, Log.CONFIG)

-- new equipment-category
local equipment_category = {
    type = "equipment-category",
    name = "vehicle",
}

-- 2x2 equipment-grid for the car
local equipment_grid =  {
    type = "equipment-grid",
    name = "small-car-equipment",
    width = 2,
    height = 2,
    equipment_categories = { "vehicle" }
}

-- allow the personal batteries as equipment
for _, be in pairs(data.raw["battery-equipment"]) do
    local cat = be.categories
    cat[#cat + 1] = "vehicle"
end

-- allow the portable solar panel as equipment
for _, be in pairs(data.raw["solar-panel-equipment"]) do
    local cat = be.categories
    cat[#cat + 1] = "vehicle"
end

-- technology
local detector_equipment_tech = {
    name = "ufo-detector-equipment-tech",
    type = "technology",
    icon = "__ufo__/graphics/icons/sensor.png",
    icon_size = 128,
    icon_mipmaps = 4,

    prerequisites = { "ufo-archeological-tech" },
    effects = {{ type = "unlock-recipe", recipe = "ufo-detector-equipment" }},

    unit = {
        count = 50,
        ingredients = {
            { "automation-science-pack", 2 },
            { "logistic-science-pack", 2 },
            { "production-science-pack", 1 },
            { "utility-science-pack", 3 },
        },
        time = 25,
    },
    order = "c-e-b3",
    factoriopedia_description = { "factoriopedia-description.ufo-detector-equipment" }
}

local detector_equipment_item = {
    type = "item",
    name = "ufo-detector-equipment",
    icon = "__ufo__/graphics/icons/sensor.png",
    icon_size = 128,
    icon_mipmaps = 4,
    subgroup = "equipment",
    order = "b[personal-transport]-c[detector]",
    place_as_equipment_result = "ufo-detector-equipment",
    stack_size = 10,
    factoriopedia_description = { "factoriopedia-description.ufo-detector-equipment" }
}

local detector_equipment_recipe = {
    type = "recipe",
    name = "ufo-detector-equipment",
    enabled = false,
    energy_required = 4,
    ingredients = {
        { type = "item", name = "iron-gear-wheel", amount = 2 },
        { type = "item", name = "iron-plate", amount = 1 },
    },
    results = { { type = "item", name = "ufo-detector-equipment", amount = 1 } }
}

local detector_equipment = {
    type = "battery-equipment",
    name = "ufo-detector-equipment",
    sprite = {
        filename = "__ufo__/graphics/icons/sensor.png",
        size = 128,
    },
    shape = { width = 1, height = 1, type = "full", },
    energy_source = {
        type = "electric",
        buffer_capacity = "20kJ",
        input_flow_limit = "10kW",
        output_flow_limit = "10kW",
        usage_priority = "primary-input"
    },
    categories = { "vehicle" },
    factoriopedia_description = { "factoriopedia-description.ufo-detector-equipment" }
}

Log.logBlock(data.raw["battery-equipment"], function(m)log(m)end, Log.CONFIG)

-- TODO upgrade tech and new item/entity

-- add small grid to car
data.raw.car.car.equipment_grid = "small-car-equipment"

-- add detector to tank
local tank_equipment_grid = data_util.copy_prototype(data.raw["equipment-grid"]["medium-equipment-grid"], "tank-equipment-grid")
-- need an own equipment_category, otherwise detector can be mounted in armor
table.insert(tank_equipment_grid.equipment_categories, "vehicle")
data.raw.car.tank.equipment_grid = "tank-equipment-grid"

-- add detector to spidertron
table.insert(data.raw["equipment-grid"]["spidertron-equipment-grid"].equipment_categories, "vehicle")

-- add detector to Hovercrafts (if mod is loaded)
if mods["Hovercrafts"] then
    table.insert(data.raw["equipment-grid"]["hovercraft-equipment"].equipment_categories, "vehicle")
    table.insert(data.raw["equipment-grid"]["missile-hovercraft-equipment"].equipment_categories, "vehicle")
end

data:extend({
    equipment_category,
    equipment_grid,
    tank_equipment_grid,
    detector_equipment_item,
    detector_equipment_recipe,
    detector_equipment,
    detector_equipment_tech,
})
