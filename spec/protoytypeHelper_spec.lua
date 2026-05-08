---
--- Created by xyzzycgn.
---
local assert = require("luassert")

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

        mock_scale = {
            rescale_called = false,
            rescale_factor = nil,
        }

        function mock_scale.rescale_entity(proto, factor)
            mock_scale.rescale_called = true
            mock_scale.rescale_factor = factor
            proto.rescaled = true
        end

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
            elseif name == "scripts.scale" then
                return mock_scale
            end

            return original_require(name)
        end

        prototypeHelper = require("scripts.prototypeHelper")
    end)

    teardown(function()
        _G.require = original_require
    end)

    before_each(function()
        mock_scale.rescale_called = false
        mock_scale.rescale_factor = nil
        reset_data_raw()
    end)

    it("copyAndReplace copies a prototype and applies replacements without scaling", function()
        local replacement = { stack_size = 50, icon = "new-icon" }

        local result = prototypeHelper.copyAndReplace("item", "test-item", "new-test-item", replacement)

        assert.are.equal("new-test-item", result.name)
        assert.are.equal(50, result.stack_size)
        assert.are.equal("new-icon", result.icon)
        assert.are.equal("item", result.type)
        assert.is_false(mock_scale.rescale_called)
    end)

    it("copyAndReplace copies a prototype, scales it, and applies replacements", function()
        local replacement = { stack_size = 20 }
        local scale_factor = 2.5

        local result = prototypeHelper.copyAndReplace("item", "test-item", "scaled-item", replacement, scale_factor)

        assert.are.equal("scaled-item", result.name)
        assert.are.equal(20, result.stack_size)
        assert.is_true(mock_scale.rescale_called)
        assert.are.equal(2.5, mock_scale.rescale_factor)
        assert.is_true(result.rescaled)
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

        assert.are.equal(3, #prototype.ingredients)
        assert.are.same({ "iron-plate", 1 }, prototype.ingredients[1])
        assert.are.same({ "copper-plate", 5 }, prototype.ingredients[2])
        assert.are.same({ "electronic-circuit", 2 }, prototype.ingredients[3])
    end)
end)