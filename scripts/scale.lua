---
--- Created by xyzzycgn.
--- tiny scaling function for prototypes
---

-- fields for scaling within object (as long as we have only this 2 possibilities the neat trick in scale() works)
local fields = {
    shift = true,
    scale = true,
}

-- fields to ignore for scaling
local ignored_fields = {
    working_sound = true,
    pipe_covers = true,
    pipe_picture = true,
}

--- Scales values within object
--- @param factor float scaling factor
local function scale(object, factor)
    -- Check if we have a number (i.e. it's scale)
    if type(object) == "number" then
        return object * factor
    else
        -- must be shift - neat trick as we have only 2 possibilities ;)
        object[1] = object[1] * factor
        object[2] = object[2] * factor

        return object
    end
end

--- used for shrinking the XXX prototype
--- @param prototype any prototype to be scaled
--- @param factor float scaling factor
local function rescale_entity(prototype, factor)
    if not prototype then
        return
    end

    for key, value in pairs(prototype) do
        -- Check to see if we need to scale this key's value (currently only recognized scale or shift)
        if fields[key] then
            prototype[key] = scale(value, factor)
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