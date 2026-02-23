---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local global_data = require("scripts.global_data")

---
--- @class ProtectedVault
--- @field entity LuaEntity the protected vault (ufo-fulgoran-ruin-vault)
--- @field pos MapPosition its location
--- @field direction defines.direction
--- @field force ForceID id of the owning force


--- handles the build of a resonace shard near by a fulguran vault
--- @param entity LuaEntity
local function handleBuild(entity)
    local pos = entity.position
    local quality = entity.quality
    local name = entity.name
    local un = entity.unit_number
    Log.logBlock(entity.prototype, function(m)log(m)end, Log.FINE)

    local dist = entity.prototype.get_supply_area_distance()
    local surface = entity.surface

    local left_top = { x = pos.x - dist, y = pos.y - dist }
    local right_bottom = { x = pos.x + dist, y = pos.y + dist }

    local vaults = surface.find_entities_filtered({ area = { left_top, right_bottom}, name = { "fulgoran-ruin-vault" } })
    Log.logBlock(vaults, function(m)log(m)end, Log.FINE)

    for _, vault in pairs(vaults) do
        local vaultposition = vault.position
        local vaultdirection = vault.direction
        local vaultforce = vault.force.index
        -- destroy the original vault
        Log.logLine(vault.destroy(), function(m)log(m)end, Log.FINER)
        -- create the protected vault
        local pvault = surface.create_entity({ name = "ufo-fulgoran-ruin-vault",
                                               position = vaultposition,
                                               direction = vaultdirection,
                                               force = vaultforce,
        })

        --- @type ProtectedVault
        local pv = {
            entity = pvault,
            pos = vaultposition,
            direction = vaultdirection,
            force = vaultforce,
        }
        global_data.getProtectedVaults()[un] = pv
    end
end
-- ###############################################################

--- handles mining the shard before the vault
--- @param entity LuaEntity the shard
local function handleShardBeforeVault(entity)
    local un = entity.unit_number
    local surface = entity.surface
    --- @type ProtectedVault
    local pv = global_data.getProtectedVaults()[un]
    if pv then
        -- handle mine of shard before mining the vault
        local pvault = pv.entity
        if pvault.valid then
            pvault.destroy()
        end
        -- recreate (unprotected) vault
        surface.create_entity({ name = "fulgoran-ruin-vault",
                                position = pv.pos,
                                direction = pv.direction,
                                force = pv.force,
        })
        global_data.getProtectedVaults()[un] = nil
    end
end
-- ###############################################################

--- handles mining of the (protected) vault before the inhibitor
--- @param entity LuaEntity the (protected) vault
local function handleVaultBeforeInhibitor(entity)
    local un = entity.unit_number

    for ndx, pvault in pairs(global_data.getProtectedVaults()) do
        if pvault.unit_number == un then
            -- found the protecting inhibitor - remove its data
            global_data.getProtectedVaults()[ndx] = nil
            return
        end
    end
end
-- ###############################################################

local adapterHandling = {
    handleBuild = handleBuild,
    handleInhibitorBeforeVault = handleShardBeforeVault,
    handleVaultBeforeInhibitor = handleVaultBeforeInhibitor,
}

return adapterHandling