---
--- Created by xyzzycgn.
---
local assert = require("luassert")
local scale = require("scripts.scale")

describe("prototypeHelper", function()
    local prototypeHelper
    local mock_scale
    local original_require

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
                }
            }
        }
    end

    setup(function()
        reset_data_raw()

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

    teardown(function()
        _G.require = original_require
    end)

    before_each(function()
        reset_data_raw()
    end)

    after_each(function()
        mock_scale:clear() -- clear the call history
    end)

    it("copyAndReplace copies a prototype and applies replacements without scaling", function()
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

    it("copyAndReplace copies a prototype, scales it, and applies replacements", function()
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

    it("additionalIngredients appends extra ingredients", function()
        local prototype = {
            ingredients = { { "iron-plate", 1 } }
        }
        local extra = {
            { "copper-plate", 5 },
            { "electronic-circuit", 2 }
        }

        prototypeHelper.additionalIngredients(prototype, extra)

        assert.is.same(prototype, {
            ingredients = {
                { "iron-plate", 1 },
                { "copper-plate", 5 },
                { "electronic-circuit", 2 }
            }
        })
    end)
end)