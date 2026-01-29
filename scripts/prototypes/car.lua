---
--- Created by xyzzycgn.
--- DateTime: 29.01.26 12:03
---
local Log = require("__log4factorio__.Log")

Log.logBlock(defines.prototypes["equipment-category"]["equipment-category"], function(m)log(m)end, Log.CONFIG)
Log.logBlock(data.raw["battery-equipment"], function(m)log(m)end, Log.CONFIG)
Log.logBlock(data.raw.item["battery-equipment"], function(m)log(m)end, Log.CONFIG)
Log.logBlock(data.raw["equipment-category"]["armor"], function(m)log(m)end, Log.CONFIG)

data:extend({
    -- new equipment-category
    {
        type = "equipment-category",
        name = "vehicle",
    },

    -- 2x2 equipment-grid for the car
    {
        type = "equipment-grid",
        name = "small-car-equipment",
        width = 2,
        height = 2,
        equipment_categories = { "vehicle" }
    }
})

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

-- TODO detector (tech?, recipe, equipment, item)

-- TODO upgrade tech and new item/entity
local car = data.raw.car.car
car.equipment_grid = "small-car-equipment"