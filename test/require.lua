---
--- Created by xyzzycgn.
--- DateTime: 01.02.25 05:31
---

local Require = {}
local alternatives = {
    -- here exact names
    --["__flib__.gui"] = "lib.flib.gui",

    -- here patterns, that start with
    starts_with = {
        ["__flib__"] = "lib.flib",
        ["__log4factorio__"] = "lib",
    }
}

-- copy of the original require used for delegation of loading the libs
local original

--- replaces the standard require with Require.require
function Require.replace(orig)
    original = orig
    return Require.require
end


function Require.require(lib)
    -- exact match?
    local alt = alternatives[lib]

    if alt then
        -- yes - load replacement
        return original(alt)
    else
        -- no - look for matching patterns
        for k, v in pairs(alternatives.starts_with) do
            local replaced, anz = string.gsub(lib, k, v, 1)
            if anz == 1 then
                -- load replacement
                return original(replaced)
            end
        end

        -- no match - use orignal require to load lib
        return original(lib)
    end
end

return Require