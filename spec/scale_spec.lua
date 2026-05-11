---
--- Created by xyzzycgn.
---
local scale = require('scripts.scale')
local rescale_entity = scale.rescale_entity -- shortcut
local assert = require("luassert")

describe("scale", function()
    it("should return nil for nil input", function()
        local result = rescale_entity(nil, 2.0)
        assert.is_nil(result)
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("should only change scale", function()
        local prototype = {
            scale = 1.0,
            other = "test"
        }
        local result = rescale_entity(prototype, 2.5)
        assert.are.same(result, { scale = 2.5, other = "test" })
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("should change all values in collision_box and selection_box", function()
        local prototype = {
            collision_box = { { 1, 2 }, { 3, 4 } },
            selection_box = { { 2, 3 }, { 4, 5 } },
        }
        local result = rescale_entity(prototype, 2)
        assert.are.same(result, {
            collision_box = { { 2, 4 }, { 6, 8 } },
            selection_box = { { 4, 6 }, { 8, 10 } },
        })
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("should scale both values", function()
        local prototype = {
            shift = { 1.0, 2.0 }
        }

        local result = rescale_entity(prototype, 2.0)
        assert.are.same(result, {
            shift = { 2.0, 4.0 }
        })
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("should not descended into ignored fields", function()
         local prototype = {
            working_sound = { scale = 1.0 },
            pipe_covers = { shift = {2.0, 3.0} },
            pipe_picture = { scale = 3.0 },
            scale = 1.0
        }

        local result = rescale_entity(prototype, 2.0)
        assert.are.same(result, {
            working_sound = { scale = 1.0 },
            pipe_covers = { shift = { 2.0, 3.0 } },
            pipe_picture = { scale = 3.0 },
            scale = 2.0
        })
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("should change scale and all values in shift, but NOT root_scale", function()
        local prototype = {
            nested = {
                scale = 1.0,
                inner = {
                    shift = { 10.0, 20.0 }
                }
            },
            root_scale = 5.0
        }

        local result = rescale_entity(prototype, 0.5)
        assert.are.same(result, {
            nested = {
                scale = 0.5,
                inner = {
                    shift = { 5.0, 10.0 }
                }
            },
            -- root_scale is NOT in fields, so it should be descended into if it's a table,
            -- but here it is a number and not in 'fields', so it should be ignored.
            root_scale = 5.0
        })
    end)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    it("should change scale in deep recursion", function()
        local prototype = {
            a = {
                b = {
                    c = {
                        scale = 4.0
                    }
                }
            }
        }
        local result = rescale_entity(prototype, 0.25)
        assert.are.same(result, {
            a = {
                b = {
                    c = {
                        scale = 1.0
                    }
                }
            }
        })
    end)
end)