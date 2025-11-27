---
--- encapsulates the storage (formerly global) table
--- Created by xyzzycgn.
---

local Log = require("__log4factorio__.Log")

local global_data = {}

function global_data.init()
    Log.log('global_data.init', function(m)log(m)end, Log.FINER)
    storage.forces = storage.forces or {}
    storage.adapterPrototypes = storage.adapterPrototypes or {}
    storage.adapterData = storage.adapterData or {}
    storage.adaptees = storage.adaptees or {}
end
-- ###############################################################

--- @param force LuaForce
--- @param forceData ForceData
function global_data.addForce_data(force, forceData)
    local fi = force.index
    if (storage.forces[fi] == nil) then
        storage.forces[fi] = forceData
    else
        Log.log("force already known", function(m)log(m)end, Log.WARN)
    end
end

--- @param forceindex number
--- @return ForceData
function global_data.getForce_data(forceindex)
    return storage.forces[forceindex]
end

--- @param forceindex number
--- @return ForceData
function global_data.deleteForce_data(forceindex)
    Log.logMsg(function(m)log(m)end, Log.INFO, "force deleted - index=%d", forceindex)
    storage.forces[forceindex] = nil
end
-- ###############################################################

--- List of known prototypes for adapted electric poles
--- @return table<string, true> indexed by name of prototype
function global_data.getAdapterPrototypes()
    return storage.adapterPrototypes
end

-- ###############################################################

--- List of known adapted electric poles
--- @return table<string, AdapterData> indexed by name of prototype
function global_data.getAdapterData()
    return storage.adapterData
end
-- ###############################################################

--- List of known adapted attractors
--- @return table<number, AdaptedAttractor> indexed by unit_number of adapted attractor entity
function global_data.getAdaptees()
    return storage.adaptees
end
-- ###############################################################

return global_data
