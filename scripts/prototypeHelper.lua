---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local data_util = require("__flib__.data-util")
local scale = require("scripts.scale")

--- @param ndx1 string 1st index into data.raw
--- @param ndx2 string 2nd index into data.raw
--- @param newName string name for the new prototype
--- @param replacement any data for the new prototype
--- @param scale_factor float? optional scaling factor
local function copyAndReplace(ndx1, ndx2, newName, replacement, scale_factor)
    local prototype = data_util.copy_prototype(data.raw[ndx1][ndx2], newName)

    if scale_factor and type(scale_factor) == "number" then
        scale.rescale_entity(prototype, scale_factor)
    end

    for k, v in pairs(replacement) do
        prototype[k] = v
    end

    return prototype
end
-- ###############################################################

local function additionalIngredients(prototype, ai)
    local ingredients = prototype.ingredients
    for _, ingredient in pairs(ai) do
        ingredients[#ingredients + 1] = ingredient
    end
end
-- ###############################################################

--- fill blacklist
--- @param blacklist any
--- @param prototypesToBeBlacklisted table<string, string[]> indexed by mod name
local function fillBlacklist(blacklist, prototypesToBeBlacklisted)
    for mod, list in pairs(prototypesToBeBlacklisted) do
        if mods[mod] then
            Log.logMsg(function(m)log(m)end, Log.CONFIG, "detected mod %s with prototypes to be blacklisted", mod)
            for _, p in pairs(list) do
                blacklist[p] = true
                Log.logMsg(function(m)log(m)end, Log.CONFIG, "blacklisted prototype %s", p)
            end
        end
    end
end
-- ###############################################################

--- fill specialTints
--- @param specialTints table<string, Color>
--- @param modsWithSpecialtintedPrototypes table<string, table<string, Color>> list of prototypes to be tinted specially per mod
local function fillSpecialTints(specialTints, modsWithSpecialtintedPrototypes)
    for mod, list in pairs(modsWithSpecialtintedPrototypes) do
        if mods[mod] then
            Log.logMsg(function(m)log(m)end, Log.CONFIG, "detected mod %s with special tinted prototypes", mod)
            for p, specialtint in pairs(list) do
                specialTints[p] = specialtint
                Log.logMsg(function(m)log(m)end, Log.CONFIG, "special tint for prototype %s", p)
            end
        end
    end
end
-- ###############################################################

--- @param specialTints table<string, Color> list of prototypes that need some different tint
--- @param prototype any prototype whose icon should be tinted
--- @param poleName string name of the original pole prototype, used to distinguish tint
--- @param default_tint Color
local function add_tint(specialTints, prototype, polename, default_tint)
    local icon = prototype.icon
    local icon_size = prototype.icon_size
    prototype.icons =  {
        {
            icon = icon,
            icon_size = icon_size,
            tint = specialTints[polename] or default_tint,
        }
    }
    prototype.icon = nil
    prototype.icon_size = nil
end
-- ###############################################################

local function getExistingPrototype(group, prototypeName)
    return data.raw[group][prototypeName]
end
-- ###############################################################

--- fix for #19
--- @param sprite RotatedSprite
--- @param usetint Color tint for the sprite
--- @param filename string? if not nil use instead of picture.filename
--- @return RotatedSprite
local function layer(sprite, usetint, filename)
    return {
        filename = filename or sprite.filename,
        direction_count = sprite.direction_count,
        size = sprite.size,
        x = sprite.x,
        y = sprite.y,
        height = sprite.height,
        width = sprite.width,
        priority = sprite.priority,
        shift = sprite.shift,
        line_length = sprite.line_length,
        tint = usetint,
    }
end
-- ###############################################################

--- fills sprite.layers an resets no longer used fields
--- @see https://lua-api.factorio.com/stable/types/RotatedSprite.html
--- @param sprite RotatedSprite
--- @param layers RotatedSprite[]
local function setLayersAndResetUnused(sprite, layers)
    sprite.layers = layers
    -- remove no longer used members
    sprite.direction_count = nil
    sprite.filename = nil
    sprite.size = nil
    sprite.x = nil
    sprite.y = nil
    sprite.height = nil
    sprite.width = nil
    sprite.priority = nil
    sprite.shift = nil
    sprite.line_length = nil
end
-- ###############################################################

--- fix for #19
--- @param specialTints table<string, Color> list of prototypes that need some different tint
--- @param prototype ElectricPolePrototype
--- @param poleName string name of the original pole prototype, used to distinguish tint
--- @param default_tint Color
local function tintPicture(specialTints, prototype, poleName, default_tint)
    --- @type RotatedSprite
    local old_pictures = prototype.pictures
    local usetint = specialTints[poleName] or default_tint

    if old_pictures.layers then
        -- simple way, when prototype is using layers
        for _, op_layer in pairs(old_pictures.layers) do
            op_layer.tint = usetint -- set tint for all layers
        end
    elseif old_pictures.filename then
        -- bit more complicated without layers, but single filename
        local layers = {
            [1] = layer(old_pictures, usetint)
        }
        setLayersAndResetUnused(old_pictures, layers)
    else
        -- prototype uses filenames
        local layers = {}
        for n, filename in pairs(old_pictures.filenames) do
            layers[n] = layer(old_pictures, usetint, filename)
        end
        setLayersAndResetUnused(old_pictures, layers)
    end
end
-- ###############################################################

return {
    copyAndReplace = copyAndReplace,
    additionalIngredients = additionalIngredients,
    fillBlacklist = fillBlacklist,
    fillSpecialTints = fillSpecialTints,
    add_tint = add_tint,
    getExistingPrototype = getExistingPrototype,
    layer = layer,
    setLayersAndResetUnused = setLayersAndResetUnused,
    tintPicture = tintPicture,
}