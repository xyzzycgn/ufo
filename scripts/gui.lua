---
--- Created by xyzzycgn.
--- DateTime: 02.02.26 07:36
---
local Log = require("__log4factorio__.Log")
local guibuilder = require("__flib__.gui")
local global_data = require("scripts.global_data")


local frdgui = {}

-- common actions for all guis
local Common = {}

local function toggle_shortcut(player, flag)
    player.set_shortcut_toggled("ufo-toggle-gui", flag)
end
-- ###############################################################

function Common:open()
    Log.log('Common:open', function(m)log(m)end, Log.FINE)
    --self.gui.bring_to_front() -- only needed fo screen
    self.gui.visible = true
    self.state.visible = true

   toggle_shortcut(self.player, true)
    self.player.opened = self.gui
end
--###########################################################################

function Common:close()
    Log.log('Common:close', function(m)log(m)end, Log.FINE)
    self.gui.visible = false
    self.state.visible = false

   toggle_shortcut(self.player, false)
end
--###########################################################################

function Common:toggle()
    Log.logBlock(self.state, function(m)log(m)end, Log.FINE)
    -- lua is so crazy - Common:open() yields
    --    Error while running event RLD-man::on_lua_shortcut (ID 38)
    --    __RLD-man__/scripts/gui/rldman.lua:14: attempt to index field 'refs' (a nil value)
    -- while Common.open(self) works
    if self.state.visible then
        Common.close(self)
    else
        Common.open(self)
    end
end

function Common:update()
    -- TODO ?
    --if self.state.visible then
    --    local rld_data = global_data.getRld_data()
    --    local gui_model = global_data.getGui_model()
    --
    --    local ndx = self.state.selected_tab_index
    --    Log.log("update gui - player=" .. self.player.index .. ", ndx=" .. ndx, function(m)log(m)end, Log.FINER)
    --
    --    local func = switch[ndx]
    --    if (func) then
    --        func(self.refs, rld_data, gui_model, self.player.index)
    --    else
    --        Log.log("no func for ndx=" .. ndx, function(m)log(m)end, Log.WARN)
    --    end
    --end
end
--###########################################################################

---@class GuiModel: any
---@field gui LuaGuiElement top level GUI object
---@field player LuaPlayer
---@field refs table<string, LuaGuiElement> certain referenced children of top level object
---@field state any state of gui

---@param player LuaPlayer
---@return LuaGuiElement
function frdgui.build(player)
    local pg = player.gui

    local elems, gui = guibuilder.add(pg.left, {
        {
            type = "frame",
            direction = "vertical",
            visible = false,
            {
                type = "sprite",
                sprite = "frd-sprite",
                name = "sprite-high",
                visible = false,
            },
            {
                type = "sprite",
                sprite = "frd-sprite-low",
                name = "sprite-low",
                visible = false,
            },
        }
    })

    Log.logBlock({ elems = elems, gui=gui }, function(m)log(m)end, Log.FINEST)

    local GuiModel = {
        player = player,
        gui = gui,
        refs = elems,
        state = {},
    }

    return GuiModel
end
--###########################################################################

local function addMetaTable(guiModel)
    local mt = getmetatable(guiModel)
    if (mt == nil) then
        setmetatable(guiModel, { __index = Common })
    end
end
--###########################################################################

---@param player LuaPlayer
---@param pd PlayerData
---@return GuiModel
function frdgui.getGui(player, pd)
    local guiModel

    Log.logBlock(pd, function(m)log(m)end, Log.FINE)

    guiModel = pd and pd.guiModel
    if (guiModel == nil) then
        guiModel = frdgui.build(player)
        pd.guiModel = guiModel
    end

    addMetaTable(guiModel)

    return guiModel
end
--###########################################################################

function frdgui.load()
    local all_pd = global_data.getAllPlayerData()
    for _, pd in ipairs(all_pd) do
        if (pd and pd.guiModel) then
            local guiModel = pd.guiModel
            Log.log('reload metatable for player data', function(m)log(m)end, Log.FINE)
            addMetaTable(guiModel)
        end
    end
    --
    --frdgui.setupEventhandler()
end
--###########################################################################

function frdgui.init()
    Log.log('init FRD gui', function(m)log(m)end, Log.FINE)
    --frdgui.setupEventhandler()
end
--###########################################################################


return frdgui
