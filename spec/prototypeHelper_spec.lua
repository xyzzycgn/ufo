---
--- Created by xyzzycgn.
---
local Require = require("test.require")
_G.require = Require.replace(require)

require("spec.common")

local assert = require("luassert")
local scale = require("scripts.scale")

describe("prototypeHelper", function()
    local prototypeHelper
    local mock_scale
    local original_require
    local original_mods
    local original_log

    local function reset_data_raw()
        _G.data = {
            raw = {
                ["item"] = {
                    ["test-item"] = {
                        name = "test-item",
                        type = "item",
                        stack_size = 10,
                        ingredients = { { "iron-plate", 1 } }
                    }
                },
                ["recipe"] = {
                    ["test-recipe"] = {
                        name = "test-recipe",
                        type = "recipe",
                        ingredients = { { "iron-plate", 1 } }
                    }
                }
            }
        }
    end

    setup(function()
        original_mods = _G.mods

        reset_data_raw()
        _G.mods = {}

        mock_scale = spy.on(scale, "rescale_entity")

        local mock_data_util = {
            copy_prototype = function(proto, newName)
                local newProto = {}
                for k, v in pairs(proto) do
                    newProto[k] = v
                end
                newProto.name = newName
                return newProto
            end
        }

        original_require = _G.require
        _G.require = function(name)
            if name == "__flib__.data-util" then
                return mock_data_util
            end

            return original_require(name)
        end

        prototypeHelper = require("scripts.prototypeHelper")
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    teardown(function()
        _G.require = original_require
        _G.mods = original_mods
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    before_each(function()
        reset_data_raw()
        _G.mods = {}
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    after_each(function()
        mock_scale:clear() -- clear the call history
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    describe("copyAndReplace", function()
        it("copies a prototype and applies replacements without scaling", function()
            local replacement = { stack_size = 50, icon = "new-icon" }

            local result = prototypeHelper.copyAndReplace("item", "test-item", "new-test-item", replacement)

            assert.is.same(result, {
                name = "new-test-item",
                type = "item",
                stack_size = 50,
                icon = "new-icon",
                ingredients = { { "iron-plate", 1 } }
            })
            assert.spy(mock_scale).was_not_called()
        end)
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        it("copies a prototype, scales it, and applies replacements", function()
            local replacement = { stack_size = 20 }
            local scale_factor = 2.5

            local result = prototypeHelper.copyAndReplace("item", "test-item", "scaled-item", replacement, scale_factor)

            assert.is.same(result, {
                name = "scaled-item",
                type = "item",
                stack_size = 20,
                ingredients = { { "iron-plate", 1 } }
            })
            assert.spy(mock_scale).was_called_with({
                name = "scaled-item",
                type = "item",
                stack_size = 10,
                ingredients = { { "iron-plate", 1 } }
            }, scale_factor)
        end)
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    end)

    describe("additionalIngredients", function()
        it("appends extra ingredients", function()
            local prototype = {
                ingredients = { { type = "item", name = "iron-plate", amount = 1 } }
            }
            local extra = {
                { type = "item", name = "copper-plate", amount = 5 },
                { type = "item", name = "electronic-circuit", amount = 2 }
            }

            prototypeHelper.additionalIngredients(prototype, extra)

            assert.is.same(prototype, {
                ingredients = {
                    { type = "item", name = "iron-plate", amount = 1 },
                    { type = "item", name = "copper-plate", amount = 5 },
                    { type = "item", name = "electronic-circuit",amount =  2 }
                }
            })
        end)

        it("adds amounts for existing ingredients", function()
            local prototype = {
                ingredients = {
                    { type = "item", name = "iron-plate", amount = 1 },
                    { type = "item", name = "copper-plate", amount = 3 },
                }
            }
            local extra = {
                { type = "item", name = "copper-plate", amount = 5 },
                { type = "item", name = "electronic-circuit", amount = 2 }
            }

            prototypeHelper.additionalIngredients(prototype, extra)

            assert.is.same(prototype, {
                ingredients = {
                    { type = "item", name = "iron-plate", amount = 1 },
                    { type = "item", name = "copper-plate", amount = 8 },
                    { type = "item", name = "electronic-circuit", amount = 2 }
                }
            })
        end)

    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("fillBlacklist adds prototypes only for active mods", function()
        _G.mods = {
            ActiveMod = true
        }
        local blacklist = {}
        local prototypesToBeBlacklisted = {
            ActiveMod = { "blocked-a", "blocked-b" },
            InactiveMod = { "not-blocked" }
        }

        prototypeHelper.fillBlacklist(blacklist, prototypesToBeBlacklisted)

        assert.is_true(blacklist["blocked-a"])
        assert.is_true(blacklist["blocked-b"])
        assert.is_nil(blacklist["not-blocked"])
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("fillWhitelist adds prototypes only for active mods", function()
        _G.mods = {
            ActiveMod = true
        }
        local whitelist = {}
        local prototypesToBeWhitelisted = {
            ActiveMod = { "blocked-a", "blocked-b" },
            InactiveMod = { "not-blocked" }
        }

        prototypeHelper.fillWhitelist(whitelist, prototypesToBeWhitelisted)

        assert.is_true(whitelist["blocked-a"])
        assert.is_true(whitelist["blocked-b"])
        assert.is_nil(whitelist["not-blocked"])
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("fillSpecialTints adds special tints only for active mods", function()
        _G.mods = {
            ActiveTintMod = true
        }
        local tintA = { r = 0.1, g = 0.2, b = 0.3, a = 0.4 }
        local tintB = { r = 0.5, g = 0.6, b = 0.7, a = 0.8 }
        local specialTints = {}
        local modsWithSpecialtintedPrototypes = {
            ActiveTintMod = {
                ["special-a"] = tintA,
                ["special-b"] = tintB
            },
            InactiveTintMod = {
                ["ignored"] = { r = 1, g = 1, b = 1, a = 1 }
            }
        }

        prototypeHelper.fillSpecialTints(specialTints, modsWithSpecialtintedPrototypes)

        assert.is.same(tintA, specialTints["special-a"])
        assert.is.same(tintB, specialTints["special-b"])
        assert.is_nil(specialTints["ignored"])
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("add_tint converts icon and icon_size into tinted icons using a special tint", function()
        local specialTint = { r = 0.2, g = 0.3, b = 0.4, a = 0.5 }
        local defaultTint = { r = 0.9, g = 0.8, b = 0.7, a = 0.6 }
        local specialTints = {
            ["test-pole"] = specialTint
        }
        local prototype = {
            icon = "test-icon.png",
            icon_size = 64
        }

        prototypeHelper.add_tint(specialTints, prototype, "test-pole", defaultTint)

        assert.is.same({
            {
                icon = "test-icon.png",
                icon_size = 64,
                tint = specialTint
            }
        }, prototype.icons)
        assert.is_nil(prototype.icon)
        assert.is_nil(prototype.icon_size)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("add_tint falls back to the passed default tint when no special tint exists", function()
        local defaultTint = { r = 0.9, g = 0.8, b = 0.7, a = 0.6 }
        local prototype = {
            icon = "test-icon.png",
            icon_size = 32
        }

        prototypeHelper.add_tint({}, prototype, "unknown-pole", defaultTint)

        assert.is.same({
            {
                icon = "test-icon.png",
                icon_size = 32,
                tint = defaultTint
            }
        }, prototype.icons)
        assert.is_nil(prototype.icon)
        assert.is_nil(prototype.icon_size)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("getExistingPrototype returns an existing prototype from data.raw", function()
        local result = prototypeHelper.getExistingPrototype("recipe", "test-recipe")

        assert.is.same(_G.data.raw["recipe"]["test-recipe"], result)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("layer creates a tinted layer from a rotated sprite", function()
        local sprite = {
            filename = "base.png",
            size = 128,
            x = 1,
            y = 2,
            height = 64,
            width = 32,
            priority = "high",
            shift = { 0.1, 0.2 },
            line_length = 8,
            direction_count = 4
        }
        local layerTint = { r = 0.1, g = 0.2, b = 0.3, a = 0.4 }

        local result = prototypeHelper.layer(sprite, layerTint)

        assert.is.same({
            filename = "base.png",
            direction_count = 4,
            size = 128,
            x = 1,
            y = 2,
            height = 64,
            width = 32,
            priority = "high",
            shift = { 0.1, 0.2 },
            line_length = 8,
            tint = layerTint
        }, result)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("layer uses the provided filename override", function()
        local sprite = {
            filename = "base.png",
            direction_count = 17,
            size = 128,
            x = 1,
            y = 2,
            height = 64,
            width = 32,
            priority = "high",
            shift = { 0.1, 0.2 },
            line_length = 8
        }
        local layerTint = { r = 0.1, g = 0.2, b = 0.3, a = 0.4 }

        local result = prototypeHelper.layer(sprite, layerTint, "override.png")

        assert.are.equal("override.png", result.filename)
        assert.is.same(layerTint, result.tint)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("setLayersAndResetUnused sets layers and removes sprite fields that are no longer used", function()
        local sprite = {
            direction_count = 4,
            filename = "base.png",
            size = 128,
            x = 1,
            y = 2,
            height = 64,
            width = 32,
            priority = "high",
            shift = { 0.1, 0.2 },
            line_length = 8
        }
        local layers = {
            {
                filename = "base.png",
                tint = { r = 1, g = 0, b = 0, a = 1 }
            }
        }

        prototypeHelper.setLayersAndResetUnused(sprite, layers)

        assert.is.same(layers, sprite.layers)
        assert.is_nil(sprite.direction_count)
        assert.is_nil(sprite.filename)
        assert.is_nil(sprite.size)
        assert.is_nil(sprite.x)
        assert.is_nil(sprite.y)
        assert.is_nil(sprite.height)
        assert.is_nil(sprite.width)
        assert.is_nil(sprite.priority)
        assert.is_nil(sprite.shift)
        assert.is_nil(sprite.line_length)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("tintPicture tints all existing picture layers using a special tint", function()
        local specialTint = { r = 0.2, g = 0.3, b = 0.4, a = 0.5 }
        local defaultTint = { r = 0.9, g = 0.8, b = 0.7, a = 0.6 }
        local prototype = {
            pictures = {
                layers = {
                    { filename = "layer-a.png" },
                    { filename = "layer-b.png" }
                }
            }
        }

        prototypeHelper.tintPicture({ ["test-pole"] = specialTint }, prototype, "test-pole", defaultTint)

        assert.is.same(specialTint, prototype.pictures.layers[1].tint)
        assert.is.same(specialTint, prototype.pictures.layers[2].tint)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("tintPicture converts a single filename picture into tinted layers using the passed default tint", function()
        local defaultTint = { r = 0.9, g = 0.8, b = 0.7, a = 0.6 }
        local prototype = {
            pictures = {
                filename = "single.png",
                size = 128,
                x = 1,
                y = 2,
                height = 64,
                width = 32,
                priority = "high",
                shift = { 0.1, 0.2 },
                line_length = 8,
                direction_count = 4
            }
        }

        prototypeHelper.tintPicture({}, prototype, "test-pole", defaultTint)

        assert.is.same({
            {
                filename = "single.png",
                direction_count = 4,
                size = 128,
                x = 1,
                y = 2,
                height = 64,
                width = 32,
                priority = "high",
                shift = { 0.1, 0.2 },
                line_length = 8,
                tint = defaultTint
            }
        }, prototype.pictures.layers)
        assert.is_nil(prototype.pictures.direction_count)
        assert.is_nil(prototype.pictures.filename)
        assert.is_nil(prototype.pictures.size)
        assert.is_nil(prototype.pictures.x)
        assert.is_nil(prototype.pictures.y)
        assert.is_nil(prototype.pictures.height)
        assert.is_nil(prototype.pictures.width)
        assert.is_nil(prototype.pictures.priority)
        assert.is_nil(prototype.pictures.shift)
        assert.is_nil(prototype.pictures.line_length)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("tintPicture converts multiple filenames into tinted layers using a special tint", function()
        local specialTint = { r = 0.2, g = 0.3, b = 0.4, a = 0.5 }
        local defaultTint = { r = 0.9, g = 0.8, b = 0.7, a = 0.6 }
        local prototype = {
            pictures = {
                filenames = {
                    "first.png",
                    "second.png"
                },
                size = 128,
                x = 1,
                y = 2,
                height = 64,
                width = 32,
                priority = "high",
                shift = { 0.1, 0.2 },
                line_length = 8,
                direction_count = 4
            }
        }

        prototypeHelper.tintPicture({ ["test-pole"] = specialTint }, prototype, "test-pole", defaultTint)

        assert.is.same({
            {
                filename = "first.png",
                direction_count = 4,
                size = 128,
                x = 1,
                y = 2,
                height = 64,
                width = 32,
                priority = "high",
                shift = { 0.1, 0.2 },
                line_length = 8,
                tint = specialTint
            },
            {
                filename = "second.png",
                direction_count = 4,
                size = 128,
                x = 1,
                y = 2,
                height = 64,
                width = 32,
                priority = "high",
                shift = { 0.1, 0.2 },
                line_length = 8,
                tint = specialTint
            }
        }, prototype.pictures.layers)
        assert.is_nil(prototype.pictures.direction_count)
        assert.is_nil(prototype.pictures.filename)
        assert.is_nil(prototype.pictures.size)
        assert.is_nil(prototype.pictures.x)
        assert.is_nil(prototype.pictures.y)
        assert.is_nil(prototype.pictures.height)
        assert.is_nil(prototype.pictures.width)
        assert.is_nil(prototype.pictures.priority)
        assert.is_nil(prototype.pictures.shift)
        assert.is_nil(prototype.pictures.line_length)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    describe("next_upgrade only filled", function()
        it("if orig_pole not already has a next_upgrade", function()
            local pole = { next_upgrade = "already set" }
            prototypeHelper.next_upgrade(pole, "upgrade")

            assert.is.same({ next_upgrade = "already set" }, pole)
        end)

        it("if flag 'not-upgradable' isn't set ", function()
            local pole = { flags = { ["not-upgradable"] = true } }
            prototypeHelper.next_upgrade(pole, "upgrade")

            assert.is.same({ flags = { ["not-upgradable"] = true } }, pole)
        end)

        it("if both aren't set", function()
            local pole = {}
            prototypeHelper.next_upgrade(pole, "upgrade")

            assert.is.same({ next_upgrade = "upgrade" }, pole)

            pole = { flags = {}}
            prototypeHelper.next_upgrade(pole, "upgrade")

            assert.is.same({ flags = {}, next_upgrade = "upgrade" }, pole)
        end)
    end)
end)
