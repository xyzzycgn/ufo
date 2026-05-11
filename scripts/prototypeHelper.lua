---
--- Created by xyzzycgn.
---
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


local function additionalIngredients(prototype, ai)
    local ingredients = prototype.ingredients
    for _, ingredient in pairs(ai) do
        ingredients[#ingredients + 1] = ingredient
    end
end

return {
    copyAndReplace = copyAndReplace,
    additionalIngredients = additionalIngredients
}