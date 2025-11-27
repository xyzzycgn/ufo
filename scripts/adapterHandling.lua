---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local global_data = require("scripts.global_data")

--- returns a list of all known adapted electric-pole
--- @return table<string, true> indexed by name of prototype
local function getAdapter()
    return global_data.getAdapter()
end
-- ###############################################################

--- adds a new prototype
--- @param name string name of the new prototype
local function addAdapter(name)
    getAdapter()[name] = true
end
-- ###############################################################

--- removes a prototype
--- @param name string name of the prototype to be removed
local function removeAdapter(name)
    -- TODO clean up existing adapters of this type
    getAdapter()[name] = nil
end
-- ###############################################################

--- @param entity LuaEntity
local function handleBuild(entity)
    local pos = entity.position
    local quality = entity.quality
    Log.logBlock(entity.prototype, function(m)log(m)end, Log.FINE)
    local dist = entity.prototype.get_supply_area_distance(quality)
    Log.logLine({ pos = pos, quality = quality, dist = dist }, function(m)log(m)end, Log.FINE)

    local left_top = { x = pos.x - dist, y = pos.y - dist }
    local right_bottom = { x = pos.x + dist, y = pos.y + dist }

    local attractors = game.surfaces["fulgora"].find_entities_filtered(
    { area = { left_top, right_bottom}, name = { "fulgoran-ruin-attractor", "ufo-adapted-attractor" }})
    Log.logBlock(attractors, function(m)log(m)end, Log.FINE)

    for _, att in pairs(attractors) do
        if att.name == "fulgoran-ruin-attractor" then
            -- original ruin-attractor
            Log.logLine(
                { name = att.name, type = att.type, position = att.position, dir = att.direction, force = att.force},
                 function(m)log(m)end, Log.FINE)


            Log.logBlock(prototypes.entity["ufo-adapted-attractor"], function(m)log(m)end, Log.FINE)
            Log.logBlock(prototypes.item["ufo-adapted-attractor"], function(m)log(m)end, Log.FINE)

            local surface = att.surface
            -- save for later use
            local attposition = att.position
            local attdirection = att.direction
            local attforce = att.force

            -- simply replacing (with fast_replace) the existing attractor doesn't work - strange
            -- so first destroy the old one
            Log.logLine(att.destroy(), function(m)log(m)end, Log.FINE)
            -- and then create the adapted-attractor
            local adaptee = surface.create_entity({ name = "ufo-adapted-attractor",
                                                    position = attposition,
                                                    direction = attdirection,
                                                    force = attforce,
            })
            -- TODO create structures

        else
            -- already adapted attractor
            -- TODO add to structures
        end
    end

end
-- ###############################################################


local adapterHandling = {
    getAdapter = getAdapter,
    addAdapter = addAdapter,
    removeAdapter = removeAdapter,
    handleBuild = handleBuild,
}

return adapterHandling