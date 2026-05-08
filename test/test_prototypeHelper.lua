---
--- Created by Junie.
---
require('test.BaseTest')
local lu = require('luaunit')

-- Mock data.raw global before requiring prototypeHelper
data = {
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

-- Mock dependencies
local mock_scale = {
    rescale_called = false,
    rescale_factor = nil,
}
-- Define function separately to avoid closure issues with nil global if captured too early, 
-- although in Lua it should be fine if it's in the same scope, but let's be safe.
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

-- Inject mocks into require system
local original_require = require
require = function(name)
    if name == "__flib__.data-util" then
        return mock_data_util
    elseif name == "scripts.scale" then
        return mock_scale
    end
    return original_require(name)
end

local prototypeHelper = original_require('scripts.prototypeHelper')

-- Restore require (optional, but good practice if other tests follow)
require = original_require

TestPrototypeHelper = {}

function TestPrototypeHelper:setUp()
    mock_scale.rescale_called = false
    mock_scale.rescale_factor = nil
    
    -- Reset data.raw for each test if needed
    data.raw["item"]["test-item"] = {
        name = "test-item",
        type = "item",
        stack_size = 10,
        ingredients = { { "iron-plate", 1 } }
    }
end

--- Test copyAndReplace without scale factor
function TestPrototypeHelper:test_copyAndReplace_noScale()
    local replacement = { stack_size = 50, icon = "new-icon" }
    local result = prototypeHelper.copyAndReplace("item", "test-item", "new-test-item", replacement)
    
    lu.assertEquals(result.name, "new-test-item")
    lu.assertEquals(result.stack_size, 50)
    lu.assertEquals(result.icon, "new-icon")
    lu.assertEquals(result.type, "item") -- check if original value is still there
    lu.assertFalse(mock_scale.rescale_called)
end

--- Test copyAndReplace with scale factor
function TestPrototypeHelper:test_copyAndReplace_withScale()
    local replacement = { stack_size = 20 }
    local scale_factor = 2.5
    local result = prototypeHelper.copyAndReplace("item", "test-item", "scaled-item", replacement, scale_factor)
    
    lu.assertEquals(result.name, "scaled-item")
    lu.assertEquals(result.stack_size, 20)
    lu.assertTrue(mock_scale.rescale_called)
    lu.assertEquals(mock_scale.rescale_factor, 2.5)
    lu.assertTrue(result.rescaled)
end

--- Test additionalIngredients
function TestPrototypeHelper:test_additionalIngredients()
    local prototype = {
        ingredients = { { "iron-plate", 1 } }
    }
    local extra = { { "copper-plate", 5 }, { "electronic-circuit", 2 } }
    
    prototypeHelper.additionalIngredients(prototype, extra)
    
    lu.assertEquals(#prototype.ingredients, 3)
    lu.assertEquals(prototype.ingredients[1], { "iron-plate", 1 })
    lu.assertEquals(prototype.ingredients[2], { "copper-plate", 5 })
    lu.assertEquals(prototype.ingredients[3], { "electronic-circuit", 2 })
end

BaseTest:hookTests()
