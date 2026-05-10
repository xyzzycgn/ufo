---
--- Created by xyzzycgn.
---
local Require = require("test.require")
_G.require = Require.replace(_G.require)

local assert = require("luassert")
local vaultHandling
local global_data

describe("vaultHandling", function()
    local arg2find
    local arg2create
    local destroyCalled
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

        _G.settings = {
            global = {
                ["ufo-logLevel"] = { value = 5 },
                ["ufo-frd-scan-radius"] = { value = 500 },
            },
            startup = {
                ["ufo-mined-ruin-vaults-needed"] = { value = 2 },
            }
        }

        _G.script = {
            mod_name = "TEST_OF_MOD",
            active_mods = {}
        }

        _G.defines = {
            events = {
                on_player_mined_entity = 1,
                on_robot_mined_entity = 2,
                on_built_entity = 3,
                on_robot_built_entity = 4,
                on_entity_cloned = 5,
                on_entity_died = 6,
                on_runtime_mod_setting_changed = 7,
                on_force_created = 8,
                on_forces_merged = 9,
                on_force_reset = 10,
                on_lua_shortcut = 11,
                on_player_driving_changed_state = 12,
                on_player_removed_equipment = 13,
                on_player_placed_equipment = 14,
            },
            print_sound = {
                use_player_settings = true
            },
            print_skip = {
                if_visible = true
            }
        }

        _G.log = function()
        end

        _G.table_size = function(table)
            if type(table) ~= "table" then
                return 0
            end

            local count = 0
            for _ in pairs(table) do
                count = count + 1
            end

            return count
        end
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
            destroyCalled = destroyCalled + 1
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

        arg2find = nil
        arg2create = nil
        destroyCalled = 0
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
                get_supply_area_distance = function()
                    return supplyDist
                end
            },
            surface = surface
        }

        vaultHandling.replaceWithProtecedVault(shard)

        assert.are.same({ "fulgoran-ruin-vault" }, arg2find.name)
        assert.are.same({ { x = 5, y = 6 }, { x = 15, y = 16 } }, arg2find.area)

        assert.are.equal(1, destroyCalled)
        assert.are.equal(vault, destroyedEntities[1])

        assert.are.equal("ufo-fulgoran-ruin-vault", arg2create.name)
        assert.are.same(vault.position, arg2create.position)
        assert.are.equal(vault.direction, arg2create.direction)
        assert.are.equal(vault.force.index, arg2create.force)

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

        global_data.getProtectedVaults()[shardUnitNumber] = {
            entity = protectedVault,
            pos = vaultPosition,
            direction = vaultDirection,
            force = vaultForce
        }

        local surface = {
            create_entity = function(arg)
                arg2create = arg
                return {}
            end
        }

        local shard = {
            unit_number = shardUnitNumber,
            surface = surface
        }

        vaultHandling.replaceWithNormalVault(shard)

        assert.are.equal(1, destroyCalled)
        assert.are.equal(protectedVault, destroyedEntities[1])

        assert.are.equal("fulgoran-ruin-vault", arg2create.name)
        assert.are.same(vaultPosition, arg2create.position)
        assert.are.equal(vaultDirection, arg2create.direction)
        assert.are.equal(vaultForce, arg2create.force)

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
