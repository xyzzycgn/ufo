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

--- handles the build of an adapter entity
--- @param entity LuaEntity
local function handleBuild(entity)
    local pos = entity.position
    local quality = entity.quality
    local name = entity.name
    local un = entity.unit_number
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

    ufo_adapters[un] = ad
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


        if att.name == "fulgoran-ruin-attractor" then
            --- @type AdaptedAttractor
            local aa = {
                pos = attposition,
                direction = attdirection,
                force = attforce,
                adaptedBy = { [un] = true }
            }
            -- original ruin-attractor

            -- simply replacing (with fast_replace) the existing attractor doesn't work - strange
            -- so first destroy the old one
            Log.logLine(att.destroy(), function(m)log(m)end, Log.FINE)
            -- and then create the adapted-attractor
            local adaptee = surface.create_entity({ name = "ufo-adapted-attractor",
                                                    position = attposition,
                                                    direction = attdirection,
                                                    force = attforce,
                                                    create_build_effect_smoke = false,
            })
            aa.entity = adaptee -- for later use in handleDestruction
            global_data.getAdaptees()[adaptee.unit_number] = aa
            ad.adaptees[adaptee.unit_number] = true
        else
            -- already adapted attractor
            ad.adaptees[att.unit_number] = true -- adapter -> adaptee
            local aa = global_data.getAdaptees()[att.unit_number]
            aa.adaptedBy[un] = true -- adaptee -> adapter
        end
    end

    Log.logBlock(gad, function(m)log(m)end, Log.FINE)
    Log.logBlock(global_data.getAdaptees, function(m)log(m)end, Log.FINE)
end
-- ###############################################################

--- @param entity LuaEntity
local function handleDestruction(entity)
    local un = entity.unit_number
    if entity.name == "ufo-adapted-attractor" then
        -- removal of an adaptee aka ufo-adapted-attractor
        local adaptees = global_data.getAdaptees()
        --- @type AdaptedAttractor
        local adaptee = adaptees[un]
        if adaptee then
            -- array with the un of the adapter entities adapting this adaptee
            local adaptedBy = adaptee.adaptedBy
            -- iterating over all types of adapters
            for _, ufoAdapters in pairs(global_data.getAdapterData()) do
                for adapter_un, _ in pairs(adaptedBy) do
                    local adapteesOfAdapter = ufoAdapters[adapter_un].adaptees
                    -- remove attractor from list of adaptees
                    adapteesOfAdapter[un] = nil
                    if table_size(adapteesOfAdapter) == 0 then
                        -- last adaptee was removed => remove adapter from list
                        ufoAdapters[adapter_un] = nil
                    end
                end
            end

            -- remove it from list of known adapted attractors
            adaptees[un] = nil
        else
            Log.log("unknown ufo-adapted-attractor - ignored", function(m)log(m)end, Log.WARN)
        end
    else
        -- removal of an adapter
        local ufoAdapters = global_data.getAdapterData()[entity.name]
        local ufoAdapter = ufoAdapters and ufoAdapters[un]
        if ufoAdapter then
            -- found the removed adapter
            local all_adaptees = global_data.getAdaptees()

            for un_adaptee, _ in pairs(ufoAdapter.adaptees) do
                local aa = all_adaptees[un_adaptee]
                if aa then
                    -- remove adapter from list
                    aa.adaptedBy[un] = nil
                    if table_size(aa.adaptedBy) == 0 then
                        -- last adapter removed - replace ufo-adapted-attractor with fulgoran-ruin-attractor
                        local surface = aa.entity.surface
                        Log.logLine(aa.entity.destroy(), function(m)log(m)end, Log.FINE)
                        ---@type LuaEntity
                        local _ = surface.create_entity({ name = "fulgoran-ruin-attractor",
                                                position = aa.pos,
                                                direction = aa.direction,
                                                force = aa.force,
                                                create_build_effect_smoke = false,
                        })
                        -- remove from structures
                        all_adaptees[un_adaptee] = nil
                    end
                else
                    Log.log("unknown adaptee - ignored", function(m)log(m)end, Log.WARN)
                end
            end
            ufoAdapters[un] = nil
        else
            Log.log("unknown adapter - ignored", function(m)log(m)end, Log.WARN)
        end
    end
end
-- ###############################################################

--- removes a prototype
--- clean up existing adapters of this type
--- @param name string name of the prototype to be removed
local function removeAdapterPrototype(name)
    Log.logLine(name, function(m)log(m)end, Log.FINE)

    local gad = global_data.getAdapterData()[name] or {}
    Log.logBlock(gad, function(m)log(m)end, Log.FINER)

    -- look for (formerly) existing adapters of this type
    for adapter_un, _ in pairs(gad) do
        -- adapter_un was the unit_number of the adapter (already removed by game and invalid!)
        Log.logLine(adapter_un, function(m)log(m)end, Log.FINER)
        -- create facsimile of the removed adapter entity
        local entity = {
            name = name,
            unit_number = adapter_un,
        }
        handleDestruction(entity)
    end

    getAdapterPrototypes()[name] = nil
end
-- ###############################################################

local adapterHandling = {
    getAdapterPrototypes = getAdapterPrototypes,
    addAdapterPrototype = addAdapterPrototype,
    removeAdapterPrototype = removeAdapterPrototype,
    handleBuild = handleBuild,
    handleDestruction = handleDestruction,
}

return adapterHandling