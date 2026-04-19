---
--- Created by xyzzycgn.
--- prototypes related to fulguran relic detector (F.R.D.)
---
local Log = require("__log4factorio__.Log")
local data_util = require('__flib__.data-util')
local consts = require('__ufo__.scripts.consts')

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

    prerequisites = { "ufo-resonance-raw-shard-tech" },
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
    order = "ufo-b-c2",
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
        { type = "item", name = "ufo-resonance-raw-shard", amount = 1 },
        { type = "item", name = "electronic-circuit", amount = 5 },
        { type = "item", name = "advanced-circuit", amount = 2 },
        { type = "item", name = "copper-cable", amount = 3 },
        { type = "item", name = "iron-plate", amount = 1 },
    },
    results = { { type = "item", name = "ufo-detector-equipment", amount = 1 } }
}

local detector_equipment = {
    type = "night-vision-equipment",
    name = "ufo-detector-equipment",
    sprite = {
        filename = "__ufo__/graphics/icons/sensor.png",
        size = 128,
    },
    shape = { width = 1, height = 1, type = "full", },
    energy_input = consts.frd_energy,
    energy_source = {
        type = "electric",
        buffer_capacity = "20kJ",
        input_flow_limit = consts.frd_energy,
        drain = consts.frd_drain,
        usage_priority = "primary-input"
    },
    color_lookup = {{ 1, "identity" }}, -- mandantory for type = "night-vision-equipment"
    darkness_to_turn_on = 1, -- to make it constantly consuming electricity
    categories = { "vehicle" },
    factoriopedia_description = { "factoriopedia-description.ufo-detector-equipment" }
}

-- technology for pimped car
local pimp_my_car_tech = data_util.copy_prototype(data.raw["technology"]["automobilism"], "ufo-pimp-my-car-tech")
local icon = pimp_my_car_tech.icon
local icon_size = pimp_my_car_tech.icon_size
local icons = {
    {
        icon = icon,
        icon_size = icon_size
    },
    {
        icon = "__ufo__/graphics/technology/tech_up.png",
        icon_size = 256,
        icon_mipmaps = 4,
    }
}
pimp_my_car_tech.icons = icons
pimp_my_car_tech.icon = nil
pimp_my_car_tech.icon_size = nil
pimp_my_car_tech.prerequisites = { "ufo-detector-equipment-tech", "automobilism" }
pimp_my_car_tech.effects = {{ type = "unlock-recipe", recipe = "ufo-pimp-my-car" }}
pimp_my_car_tech.unit = {
    count = 50,
    ingredients = {
        { "automation-science-pack", 2 },
        { "logistic-science-pack", 2 },
        { "production-science-pack", 1 },
        { "utility-science-pack", 3 },
    },
    time = 25,
}
pimp_my_car_tech.order = "ufo-b-c2-d1"

-- recipe for pimped car
local pimp_my_car_recipe = {
    type = "recipe",
    name = "ufo-pimp-my-car",
    enabled = false,
    energy_required = 4,
    ingredients = {
        { type = "item", name = "car", amount = 1 },
        { type = "item", name = "iron-plate", amount = 10 },
        { type = "item", name = "iron-gear-wheel", amount = 2 },
        { type = "item", name = "plastic-bar", amount = 5 },
        { type = "item", name = "copper-cable", amount = 5 },
    },
    results = { { type = "item", name = "ufo-pimp-my-car", amount = 1 } },
    icons = icons
}

-- item for pimped car
local my_pimped_car_item = data_util.copy_prototype(data.raw["item-with-entity-data"]["car"], "ufo-pimp-my-car")
my_pimped_car_item.icons = icons
my_pimped_car_item.icon = nil
my_pimped_car_item.icon_size = nil

-- and entity
-- add small grid to pimped car
local my_pimped_car_entity = data_util.copy_prototype(data.raw["car"]["car"], "ufo-pimp-my-car")
my_pimped_car_entity.equipment_grid = "small-car-equipment"
my_pimped_car_entity.icons = icons
my_pimped_car_entity.icon = nil
my_pimped_car_entity.icon_size = nil
my_pimped_car_entity.factoriopedia_description = { "factoriopedia-description.ufo-pimp-my-car" }


-- add detector to tank
local tank_equipment_grid = data_util.copy_prototype(data.raw["equipment-grid"]["medium-equipment-grid"], "tank-equipment-grid")
-- tanks needs an own equipment_category, otherwise detector can be mounted in armor
table.insert(tank_equipment_grid.equipment_categories, "vehicle")
data.raw.car.tank.equipment_grid = "tank-equipment-grid"

-- add detector to spidertron
table.insert(data.raw["equipment-grid"]["spidertron-equipment-grid"].equipment_categories, "vehicle")

-- add detector to Hovercrafts (if mod is loaded)
if mods["Hovercrafts"] then
    table.insert(data.raw["equipment-grid"]["hovercraft-equipment"].equipment_categories, "vehicle")
    table.insert(data.raw["equipment-grid"]["missile-hovercraft-equipment"].equipment_categories, "vehicle")
end

-- hotkey to open/close FRD-gui.
local custom_input =  {
    type         = 'custom-input',
    name         = 'ufo-toggle-gui-key',
    key_sequence = 'SHIFT + T',
}

-- shortcut
local shortcut =  {
    type = 'shortcut',
    name = 'ufo-toggle-gui',
    associated_control_input = "ufo-toggle-gui-key",
    action = "lua",
    icon = '__ufo__/graphics/icons/sensor.png',
    icon_size = 128,
    small_icon = '__ufo__/graphics/icons/sensor.png',
    small_icon_size = 64,
    toggleable = true,
    technology_to_unlock = "ufo-detector-equipment-tech",
    unavailable_until_unlocked = true,
}



local function bg_color_from_settings()
    local choosen = settings.startup["ufo-frd-bg-color"].value
    -- 00a606
    local color = { r = 0, g = 0.65, b = 0.024, a = 1 } -- GREEN

    if choosen == "AMBER" then
        color = { r = 1, g = 0.75, b = 0, a = 1 }
    elseif choosen == "FREE" then
        color = settings.startup["ufo-frd-free-bg-color"].value
    end

    return color
end

local function multiply_color(c1, n)
  return {
    (c1.r or c1[1] or 0) * (n or 0),
    (c1.g or c1[2] or 0) * (n or 0),
    (c1.b or c1[3] or 0) * (n or 0),
    (c1.a or c1[4] or 1)
  }
end

-- sprites for F.R.D. GUI (background)
local function gui_sprite_def(name, tint)
    return {
        type = "sprite",
        name = name,
        filename = "__ufo__/graphics/crosshairs.png",
        priority = "extra-high",
        width = 170,
        height = 148,
        tint = tint
    }
end

local bg_frd_color = bg_color_from_settings()
local bg_frd_color_dark = multiply_color(bg_frd_color, 0.5)

local sprite = gui_sprite_def("frd-sprite", bg_frd_color)
local sprite_low = gui_sprite_def("frd-sprite-low", bg_frd_color_dark)

-- sprites for F.R.D. GUI (small dots)
local function dot_sprite_def(name, settingname)
    return {
        type = "sprite",
        name = name,
        filename = "__base__/graphics/icons/list-dot.png",
        priority = "extra-high",
        width = 48,
        height = 48,
        scale = 1 / 16,
        tint = settings.startup[settingname].value
    }
end

local dot_sprite_vault = dot_sprite_def("dot-vault", "ufo-frd-vaults-color")

local extensions = {
    equipment_category,
    equipment_grid,
    tank_equipment_grid,
    my_pimped_car_item,
    my_pimped_car_entity,
    detector_equipment_item,
    detector_equipment_recipe,
    pimp_my_car_recipe,
    detector_equipment,
    detector_equipment_tech,
    pimp_my_car_tech,
    custom_input,
    shortcut,
    sprite,
    sprite_low,
    dot_sprite_vault,
}

-- add sprite for shard (if mod is loaded)
if mods["Electric_flying_enemies"] then
    local dot_sprite_shard = dot_sprite_def("dot-shard", "ufo-frd-shard-color")
    extensions[#extensions + 1] = dot_sprite_shard
end

data:extend(extensions)

Log.logBlock(data.raw["night-vision-equipment"], function(m)log(m)end, Log.FINE)
