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




-- TODO detector (tech, recipe, equipment, item)
data:extend({
    {
        type = "item",
        name = "detector-equipment",
        icon = "__ufo__/graphics/icons/compass.png",
        icon_size = 64,
        scale = 0.5,
        subgroup = "equipment",
        order = "b[personal-transport]-c[detector]",
        --inventory_move_sound = item_sounds.vehicle_inventory_move,
        --pick_sound = item_sounds.vehicle_inventory_pickup,
        --drop_sound = item_sounds.vehicle_inventory_move,
        place_as_equipment_result = "detector-equipment",
        stack_size = 10
    },
    {
        type = "recipe",
        name = "detector-equipment",
        enabled = true, -- TODO tech
        energy_required = 4,
        ingredients = {
            { type = "item", name = "iron-gear-wheel", amount = 2 },
            { type = "item", name = "iron-plate", amount = 1 },
        },
        results = { { type = "item", name = "detector-equipment", amount = 1 } }
    },
})

data:extend({
    {
        type = "battery-equipment",
        name = "detector-equipment",
        sprite = {
            filename = "__ufo__/graphics/icons/compass.png",
            width = 160,
            height = 160,
            scale = 0.5,
        },
        shape = {
            width = 1,
            height = 1,
            type = "full",
        },
        energy_source = {
            type = "electric",
            buffer_capacity = "20kJ",
            input_flow_limit = "10kW",
            output_flow_limit = "10kW",
            usage_priority = "primary-input"
        },
        categories = { "vehicle" }
    },
})

Log.logBlock(data.raw["battery-equipment"], function(m)log(m)end, Log.CONFIG)

-- TODO upgrade tech and new item/entity
local car = data.raw.car.car
car.equipment_grid = "small-car-equipment"