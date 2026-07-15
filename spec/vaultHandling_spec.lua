---
--- Created by xyzzycgn.
---
local Require = require("spec.require")
_G.require = Require.replace(_G.require)

require("spec.common")

local assert = require("luassert")
local vaultHandling
local global_data

describe("vaultHandling", function()
    local destroyedEntities

    local function init_factorio_globals()
        _G.storage = {
            forces = {},
            adapterPrototypes = {},
            adapterData = {},
            adaptees = {},
            protectedVaults = {},
            playerData = {},
        }


        _G.script = {
            mod_name = "TEST_OF_MOD",
            active_mods = {}
        }
    end

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
            table.insert(destroyedEntities, entity)
            entity.valid = false
            return true
        end

        return entity
    end

    setup(function()
        init_factorio_globals()

        -- must be done here - after running init_factorio_globals()
        vaultHandling = require("scripts.vaultHandling")
        global_data = require("scripts.global_data")
    end)

    before_each(function()
        init_factorio_globals()
        global_data.init()

        destroyedEntities = {}
    end)

    it("replaces a normal vault with a protected vault when an inhibitor is built nearby", function()
        local shardPos = { x = 10, y = 11 }
        local supplyDist = 5

        local vault = createMockEntity({
            name = "fulgoran-ruin-vault",
            position = { x = 11, y = 11 },
            direction = 2,
            force = { index = 2 },
            unit_number = 999
        })

        local spied_vault = spy.on(vault, "destroy")

        local protectedVault = createMockEntity({
            name = "ufo-fulgoran-ruin-vault",
            position = { x = 11, y = 11 },
            unit_number = 1000
        })

        local surface = {
            find_entities_filtered = function(_)
                return { vault }
            end,
            create_entity = function(_)
                return protectedVault
            end
        }

        local mocked_surface = mock(surface)

        local shard = {
            position = shardPos,
            unit_number = 123,
            prototype = {
                get_supply_area_distance = function()
                    return supplyDist
                end
            },
            surface = surface
        }

        vaultHandling.replaceWithProtecedVault(shard)

        assert.spy(mocked_surface.find_entities_filtered).was_called_with({
            name = { "fulgoran-ruin-vault" },
            area = { { x = 5, y = 6 }, { x = 15, y = 16 } }
        })

        assert.spy(spied_vault).was_called(1)

        assert.are.equal(vault, destroyedEntities[1])

        assert.spy(mocked_surface.create_entity).was_called_with({
            name = "ufo-fulgoran-ruin-vault",
            position = vault.position,
            direction = vault.direction,
            force = vault.force.index,
        })

        local protectedVaultData = global_data.getProtectedVaults()[123]

        assert.is_not_nil(protectedVaultData)
        assert.are.equal(protectedVault, protectedVaultData.entity)
        assert.are.same(vault.position, protectedVaultData.pos)
        assert.are.equal(vault.direction, protectedVaultData.direction)
        assert.are.equal(vault.force.index, protectedVaultData.force)
    end)

    it("replaces a protected vault with a normal vault when the inhibitor is removed first", function()
        local shardUnitNumber = 123
        local vaultPosition = { x = 11, y = 12 }
        local vaultDirection = 2
        local vaultForce = 3

        local protectedVault = createMockEntity({
            name = "ufo-fulgoran-ruin-vault",
            position = vaultPosition,
            unit_number = 1000
        })
        local spied_pvault = spy.on(protectedVault, "destroy")

        global_data.getProtectedVaults()[shardUnitNumber] = {
            entity = protectedVault,
            pos = vaultPosition,
            direction = vaultDirection,
            force = vaultForce
        }

        local surface = {
            create_entity = function(_)
                return {}
            end
        }
        local mocked_surface = mock(surface)

        local shard = {
            unit_number = shardUnitNumber,
            surface = surface
        }

        vaultHandling.replaceWithNormalVault(shard)

        assert.spy(spied_pvault).was_called(1)
        assert.are.equal(protectedVault, destroyedEntities[1])

        assert.spy(mocked_surface.create_entity).was_called_with({
            name = "fulgoran-ruin-vault",
            position = vaultPosition,
            direction = vaultDirection,
            force = vaultForce,
        })

        assert.is_nil(global_data.getProtectedVaults()[shardUnitNumber])
    end)

    it("removes protected vault data when the protected vault is removed before the inhibitor", function()
        local shardUnitNumber = 123
        local vaultUnitNumber = 1000

        local protectedVault = createMockEntity({
            unit_number = vaultUnitNumber
        })

        global_data.getProtectedVaults()[shardUnitNumber] = {
            entity = protectedVault,
            unit_number = vaultUnitNumber
        }

        local vaultEntity = {
            unit_number = vaultUnitNumber
        }

        vaultHandling.handleVaultBeforeInhibitor(vaultEntity)

        assert.is_nil(global_data.getProtectedVaults()[shardUnitNumber])
    end)
end)
