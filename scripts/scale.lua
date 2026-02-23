---
--- Created by xyzzycgn.
--- tiny scaling function for prototypes
---

--- Scales values within object
--- @param factor float scaling factor
local function scale_number(object, factor)
    return object * factor
end

--- Scales values within object
--- @param factor float scaling factor
local function scale_vector(object, factor)
    object[1] = object[1] * factor
    object[2] = object[2] * factor

    return object
end

--- Scales an area within object
--- @param factor float scaling factor
local function area(object, factor)
    object[1][1] = object[1][1] * factor
    object[1][2] = object[1][2] * factor
    object[2][1] = object[2][1] * factor
    object[2][2] = object[2][2] * factor

    return object
end
-- ###############################################################

-- supported fields for scaling within object
local fields = {
    shift = scale_vector,
    vector_to_place_result = scale_vector,
    scale = scale_number,
    collision_box = area,
    selection_box = area,
}

-- fields to ignore for scaling
local ignored_fields = {
    working_sound = true,
    pipe_covers = true,
    pipe_picture = true,
}
-- ###############################################################

--- used for shrinking a prototype
--- @param prototype any prototype to be scaled
--- @param factor float scaling factor
local function rescale_entity(prototype, factor)
    if not prototype then
        return
    end

    for key, value in pairs(prototype) do
        -- Check to see if we need to scale this key's value (currently only recognized scale or shift)
        local func = fields[key]

        if func then
            prototype[key] = func(value, factor)
            -- Check to see if we need to ignore this key
        elseif ignored_fields[key] then
            -- nothing to do
        elseif (type(value) == "table") then
            rescale_entity(value, factor) -- descend in object tree
        end
    end

    return prototype
end
-- ###############################################################

local function move_pipe_connection(fb, ndx, pos)
    fb[ndx].pipe_connections[1].position = pos
end


return {
    rescale_entity = rescale_entity,
    move_pipe_connection = move_pipe_connection,
}