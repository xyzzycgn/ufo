---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local global_data = require("scripts.global_data")

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
            -- save for later use
            local vaultposition = vault.position
            local vaultdirection = vault.direction
            local vaultforce = vault.force.index
            Log.logLine(vault.destroy(), function(m)log(m)end, Log.FINE)
            -- and then create the protected vault
            local pvault = surface.create_entity({ name = "ufo-fulgoran-ruin-vault",
                                                   position = vaultposition,
                                                   direction = vaultdirection,
                                                   force = vaultforce,
            })

        -- TODO save vault* for handling mine of shard before mining the vault
    end
end
-- ###############################################################

--- @param entity LuaEntity
local function handleDestruction(entity)
    local un = entity.unit_number
    if entity.name == "fe_resonance_shard" then
        -- TODO handle mine of shard before mining the vault
    end
end
-- ###############################################################

local adapterHandling = {
    handleBuild = handleBuild,
    handleDestruction = handleDestruction,
}

return adapterHandling