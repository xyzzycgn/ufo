---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local global_data = require("scripts.global_data")


---
--- @class MiningProgressOfPLayer
--- @field last_mining_progress float
--- @field disturbed boolean Flag if mining process disturbed guardian (due to low energy of inhibitor)

---
--- @class ProtectedVault
--- @field entity LuaEntity the protected vault (ufo-fulgoran-ruin-vault)
--- @field protector LuaEntity inhibitor in range of vault
--- @field pos MapPosition its location
--- @field direction defines.direction
--- @field force ForceID id of the owning force
--- @field mining_progress MiningProgressOfPLayer[] indexed by player ID


--- handles the build of an inhibitor near by a fulguran vault
--- @param entity LuaEntity inhibitor that has been build
local function replaceWithProtecedVault(entity)
    local pos = entity.position
    local un = entity.unit_number
    Log.logBlock(entity.prototype, function(m)log(m)end, Log.FINE)

    local dist = entity.prototype.get_supply_area_distance()
    local surface = entity.surface

    local left_top = { x = pos.x - dist, y = pos.y - dist }
    local right_bottom = { x = pos.x + dist, y = pos.y + dist }

    -- look for vaults in range
    local vaults = surface.find_entities_filtered({ area = { left_top, right_bottom }, name = { "fulgoran-ruin-vault" } })
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
            protector = entity,
            mining_progress = {}
        }
        global_data.getProtectedVaults()[un] = pv
    end
end
-- ###############################################################

--- handles mining the inhibitor before the vault
--- @param entity LuaEntity the inhibitor that has been removed
--- @return LuaEntity the recreated (unprotected) vault
local function replaceWithNormalVault(entity)
    local un = entity.unit_number
    local surface = entity.surface
    --- @type ProtectedVault
    local pv = global_data.getProtectedVaults()[un]
    if pv then
        -- handle mine of inhibitor before mining the vault
        local pvault = pv.entity
        if pvault.valid then
            pvault.destroy()
        end
        -- recreate (unprotected) vault
        local vault = surface.create_entity({ name = "fulgoran-ruin-vault",
                                position = pv.pos,
                                direction = pv.direction,
                                force = pv.force,
        })
        global_data.getProtectedVaults()[un] = nil
        return vault
    end
end
-- ###############################################################

--- handles mining of the (protected) vault before the inhibitor
--- @param entity LuaEntity the (protected) vault
local function handleVaultBeforeInhibitor(entity)
    local un = entity.unit_number

    for ndx, pvault in pairs(global_data.getProtectedVaults()) do
        if pvault.unit_number == un then
            local protector = pvault.protector
            Log.logBlock(protector and protector.energy, function(m)log(m)end, Log.FINE)
            -- found the protecting inhibitor - remove its data
            global_data.getProtectedVaults()[ndx] = nil
            return
        end
    end
end
-- ###############################################################

local adapterHandling = {
    replaceWithProtecedVault = replaceWithProtecedVault,
    replaceWithNormalVault = replaceWithNormalVault,
    handleVaultBeforeInhibitor = handleVaultBeforeInhibitor,
}

return adapterHandling