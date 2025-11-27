---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local global_data = require("scripts.global_data")

--- returns a list of all known prototypes of adapted electric-poles
--- @return table<string, true> indexed by name of prototype
local function getAdapterPrototypes()
    return global_data.getAdapterPrototypes()
end
-- ###############################################################

--- adds a new prototype
--- @param name string name of the new prototype
local function addAdapterPrototype(name)
    getAdapterPrototypes()[name] = true
end
-- ###############################################################

--- removes a prototype
--- @param name string name of the prototype to be removed
local function removeAdapterPrototype(name)
    -- TODO clean up existing adapters of this type
    getAdapterPrototypes()[name] = nil
end
-- ###############################################################

--- @param entity LuaEntity
local function handleBuild(entity)
    local pos = entity.position
    local quality = entity.quality
    local name = entity.name
    Log.logBlock(entity.prototype, function(m)log(m)end, Log.FINE)
    local dist = entity.prototype.get_supply_area_distance(quality)
    Log.logLine({ pos = pos, quality = quality, dist = dist }, function(m)log(m)end, Log.FINE)

    --- @type UfoAdapter
    local ad = {
        pos = pos,
        dist = dist,
        adaptees = {}
    }
    Log.logLine(ad, function(m)log(m)end, Log.FINE)

    local gad = global_data.getAdapterData()
    local ufo_adapters = gad[name] or {}
    gad[name] = ufo_adapters

    ufo_adapters[entity.unit_number] = ad
    Log.logBlock(gad, function(m)log(m)end, Log.FINE)

    local left_top = { x = pos.x - dist, y = pos.y - dist }
    local right_bottom = { x = pos.x + dist, y = pos.y + dist }

    local attractors = entity.surface.find_entities_filtered(
        { area = { left_top, right_bottom},
          name = { "fulgoran-ruin-attractor", "ufo-adapted-attractor" }
        })
    Log.logBlock(attractors, function(m)log(m)end, Log.FINE)

    for _, att in pairs(attractors) do
        Log.logLine(
            { name = att.name, type = att.type, position = att.position, dir = att.direction, force = att.force},
             function(m)log(m)end, Log.FINE)

        local surface = att.surface
        -- save for later use
        local attposition = att.position
        local attdirection = att.direction
        local attforce = att.force.index

        --- @type AdaptedAttractor
        local aa = {
            pos = attposition,
            direction = attdirection,
            force = attforce
        }

        if att.name == "fulgoran-ruin-attractor" then
            -- original ruin-attractor

            -- simply replacing (with fast_replace) the existing attractor doesn't work - strange
            -- so first destroy the old one
            Log.logLine(att.destroy(), function(m)log(m)end, Log.FINE)
            -- and then create the adapted-attractor
            local adaptee = surface.create_entity({ name = "ufo-adapted-attractor",
                                                    position = attposition,
                                                    direction = attdirection,
                                                    force = attforce,
            })
            ad.adaptees[adaptee.unit_number] = aa
        else
            -- already adapted attractor
            ad.adaptees[att.unit_number] = aa
        end
    end

    Log.logBlock(gad, function(m)log(m)end, Log.FINE)
end
-- ###############################################################


local adapterHandling = {
    getAdapterPrototypes = getAdapterPrototypes,
    addAdapterPrototypes = addAdapterPrototype,
    removeAdapterPrototypes = removeAdapterPrototype,
    handleBuild = handleBuild,
}

return adapterHandling