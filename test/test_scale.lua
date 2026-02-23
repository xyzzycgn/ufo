---
--- Created by xyzzycgn.
---
require('test.BaseTest')
local lu = require('luaunit')
local scale = require('scripts.scale')
local rescale_entity = scale.rescale_entity

TestScale = {}

function TestScale:test_rescale_nil()
    local result = rescale_entity(nil, 2.0)
    lu.assertNil(result)
end
-- ###############################################################

function TestScale:test_rescale_number_scale()
    local prototype = {
        scale = 1.0,
        other = "test"
    }
    local result = rescale_entity(prototype, 2.5)
    lu.assertEquals(result.scale, 2.5)
    lu.assertEquals(result.other, "test")
end
-- ###############################################################

function TestScale:test_rescale_boxey()
    local prototype = {
        collision_box = { { 1, 2 }, { 3, 4 }},
        selection_box = { { 2, 3 }, { 4, 5 }},
    }
    local result = rescale_entity(prototype, 2)
    lu.assertEquals(result.collision_box, { { 2, 4 }, { 6, 8 }})
    lu.assertEquals(result.selection_box, { { 4, 6 }, { 8, 10 }})
end
-- ###############################################################

function TestScale:test_rescale_table_shift()
    local prototype = {
        shift = { 1.0, 2.0 }
    }
    local result = rescale_entity(prototype, 2.0)
    lu.assertEquals(result.shift, { 2.0, 4.0 })
end
-- ###############################################################

function TestScale:test_rescale_ignored_fields()
    local prototype = {
        working_sound = { scale = 1.0 },
        pipe_covers = { shift = {2.0, 3.0} },
        pipe_picture = { scale = 3.0 },
        scale = 1.0
    }
    -- these fields should be ignored and not descended into
    local result = rescale_entity(prototype, 2.0)
    lu.assertEquals(result.working_sound.scale, 1.0)
    lu.assertEquals(result.pipe_covers.shift, {2.0, 3.0})
    lu.assertEquals(result.pipe_picture.scale, 3.0)
    lu.assertEquals(result.scale, 2.0)
end
-- ###############################################################

function TestScale:test_rescale_recursion()
    local prototype = {
        nested = {
            scale = 1.0,
            inner = {
                shift = { 10.0, 20.0 }
            }
        },
        root_scale = 5.0
    }
    -- we need to check if scale/shift are in the fields list in scale.lua
    -- root_scale is NOT in fields, so it should be descended into if it's a table,
    -- but here it is a number and not in 'fields', so it should be ignored.

    local result = rescale_entity(prototype, 0.5)
    lu.assertEquals(result.nested.scale, 0.5)
    lu.assertEquals(result.nested.inner.shift, { 5.0, 10.0 })
    lu.assertEquals(result.root_scale, 5.0)
end
-- ###############################################################

function TestScale:test_rescale_deep_recursion_with_scale()
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
    lu.assertEquals(result.a.b.c.scale, 1.0)
end
-- ###############################################################

BaseTest:hookTests()
