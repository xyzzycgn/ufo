---
--- Created by xyzzycgn.
--- DateTime: 23.12.24 16:16
---

--- convenience class for handling player_data
--- @class PlayerData any
--- @field gui LuaGuiElement
--- @field player LuaPlayer
local PlayerData = {}

---@param player LuaPlayer
---@return PlayerData
function PlayerData.init_player_data(player)
    -- Player data used during game
    local pd = {
        guis = nil,
        player = player,
    }

    return pd
end

return PlayerData