---
--- Created by xyzzycgn.
---

--- @class ForceData any  convenience class for handling data of a force
--- @field num_vaults number the actual number of mined vaults

local ForceData = {}

--- @return ForceData
function ForceData.init_force_data()
    -- Force data used during game
    local fd = {
        num_vaults = 0,
    }

    return fd
end

return ForceData