---
--- Created by xyzzycgn.
---

--- class for handling player data
--- @class PlayerData any
--- @field guiModel GuiModel
--- @field pid number index of LuaPlayer
--- @field frdOn boolean true if FRD-Gui should be shown
--- @field inVehicleWithFRD boolean true if driving a vehicle with FRD
--- @field grid LuaEquipmentGrid
--- @field frd LuaEquipment
local PlayerData = {}

---@param pid number index of LuaPlayer
---@return PlayerData
function PlayerData.init_player_data(pid)
    -- Player data used during game
    local pd = {
        pid = pid,

        frdOn = false,
        inVehicleWithFRD = false,
    }

    return pd
end

return PlayerData