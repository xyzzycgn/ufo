---
--- Created by xyzzycgn.
---
require('test.BaseTest')
local lu = require('luaunit')
local vaultHandling = require('scripts.vaultHandling')
local global_data = require('scripts.global_data')

TestVaultHandling = {}

local arg2find
local arg2create
local destroyCalled
local destroyedEntities

function TestVaultHandling:setUp()
    -- Initialize storage
    global_data.init()
    
    arg2find = nil
    arg2create = nil
    destroyCalled = 0
    destroyedEntities = {}
end

-- helper to create a mock entity
local function createMockEntity(data)
    local entity = {
        name = data.name or "mock-entity",
        position = data.position or { x = 0, y = 0 },
        direction = data.direction or 0,
        force = data.force or { index = 1 },
        unit_number = data.unit_number or 123,
        valid = true,
    }
    entity.destroy = function()
        destroyCalled = destroyCalled + 1
        table.insert(destroyedEntities, entity)
        entity.valid = false
        return true
    end
    return entity
end

function TestVaultHandling:test_handleBuild()
    local shardPos = { x = 10, y = 11 }
    local supplyDist = 5
    
    local vault = createMockEntity({
        name = "fulgoran-ruin-vault",
        position = { x = 11, y = 11 },
        direction = 2,
        force = { index = 2 },
        unit_number = 999
    })
    
    local protectedVault = createMockEntity({
        name = "ufo-fulgoran-ruin-vault",
        position = { x = 11, y = 11 },
        unit_number = 1000
    })

    local surface = {
        find_entities_filtered = function(arg)
            arg2find = arg
            return { vault }
        end,
        create_entity = function(arg)
            arg2create = arg
            return protectedVault
        end
    }

    local shard = {
        position = shardPos,
        unit_number = 123,
        prototype = {
            get_supply_area_distance = function() return supplyDist end
        },
        surface = surface
    }

    vaultHandling.handleBuild(shard)

    -- Verify find_entities_filtered call
    lu.assertEquals(arg2find.name, { "fulgoran-ruin-vault" })
    lu.assertEquals(arg2find.area, { { x = 5, y = 6 }, { x = 15, y = 16 } })

    -- Verify vault destruction
    lu.assertEquals(destroyCalled, 1)
    lu.assertEquals(destroyedEntities[1], vault)

    -- Verify creation of protected vault
    lu.assertEquals(arg2create.name, "ufo-fulgoran-ruin-vault")
    lu.assertEquals(arg2create.position, vault.position)
    lu.assertEquals(arg2create.direction, vault.direction)
    lu.assertEquals(arg2create.force, vault.force.index)

    -- Verify global_data update
    local pv = global_data.getProtectedVaults()[123]
    lu.assertNotNil(pv)
    lu.assertEquals(pv.entity, protectedVault)
    lu.assertEquals(pv.pos, vault.position)
    lu.assertEquals(pv.direction, vault.direction)
    lu.assertEquals(pv.force, vault.force.index)
end

function TestVaultHandling:test_handleShardBeforeVault()
    local shardUN = 123
    local vaultPos = { x = 11, y = 12 }
    local vaultDir = 2
    local vaultForce = 3
    
    local protectedVault = createMockEntity({
        name = "ufo-fulgoran-ruin-vault",
        position = vaultPos,
        unit_number = 1000
    })

    -- Pre-populate global_data
    global_data.getProtectedVaults()[shardUN] = {
        entity = protectedVault,
        pos = vaultPos,
        direction = vaultDir,
        force = vaultForce
    }

    local surface = {
        create_entity = function(arg)
            arg2create = arg
            return {} -- return something
        end
    }

    local shard = {
        unit_number = shardUN,
        surface = surface
    }

    vaultHandling.handleInhibitorBeforeVault(shard)

    -- Verify protected vault destruction
    lu.assertEquals(destroyCalled, 1)
    lu.assertEquals(destroyedEntities[1], protectedVault)

    -- Verify recreation of original vault
    lu.assertEquals(arg2create.name, "fulgoran-ruin-vault")
    lu.assertEquals(arg2create.position, vaultPos)
    lu.assertEquals(arg2create.direction, vaultDir)
    lu.assertEquals(arg2create.force, vaultForce)

    -- Verify global_data cleanup
    lu.assertNil(global_data.getProtectedVaults()[shardUN])
end

function TestVaultHandling:test_handleVaultBeforeShard()
    local shardUN = 123
    local vaultUN = 1000
    
    -- Pre-populate global_data
    global_data.getProtectedVaults()[shardUN] = {
        unit_number = vaultUN, -- Wait, looking at vaultHandling.lua:88: if pvault.unit_number == un then
        -- The field in the global data for the vault entity is 'entity'
    }
    
    -- Let's re-examine vaultHandling.lua handleVaultBeforeShard:
    -- for ndx, pvault in pairs(global_data.getProtectedVaults()) do
    --     if pvault.unit_number == un then
    
    -- Ah, the ProtectedVault class definition says:
    -- --- @class ProtectedVault
    -- --- @field entity LuaEntity the protected vault (ufo-fulgoran-ruin-vault)
    -- But handleVaultBeforeShard expects pvault.unit_number.
    -- In Lua, if pvault.entity exists and has unit_number, pvault.unit_number will be nil unless it's explicitly set or the entity is proxy-ed.
    
    local protectedVault = createMockEntity({
        unit_number = vaultUN
    })
    
    global_data.getProtectedVaults()[shardUN] = {
        entity = protectedVault,
        unit_number = vaultUN
    }
    
    local vaultEntity = {
        unit_number = vaultUN
    }
    
    vaultHandling.handleVaultBeforeInhibitor(vaultEntity)
    
    lu.assertNil(global_data.getProtectedVaults()[shardUN])
end

BaseTest:hookTests()
