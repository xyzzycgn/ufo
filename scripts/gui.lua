---
--- Created by xyzzycgn.
--- DateTime: 02.02.26 07:36
---
local Log = require("__log4factorio__.Log")
local dump = require("__log4factorio__.dump")
local guibuilder = require("__flib__.gui")


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

function frdgui.init()
    Log.log('init FRD gui', function(m)log(m)end, Log.FINE)
    frdgui.setupEventhandler()
end
--###########################################################################

function frdgui.load()
    -- TODO ??
    --local all_pd = global_data.getAllPlayer_data()
    --for _, pd in ipairs(all_pd) do
    --    if (pd and pd.gui) then
    --        local gui = pd.gui
    --        Log.log('reload metatable for player data', function(m)log(m)end, Log.FINE)
    --        local mt = getmetatable(gui)
    --        if (mt == nil) then
    --            setmetatable(gui, { __index = Common })
    --        end
    --    end
    --end
    --
    --frdgui.setupEventhandler()
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
    Log.logBlock(function()
        return { top = dump.dumpLuaGuiElement(pg.top),
                 left = dump.dumpLuaGuiElement(pg.left),
                 center = dump.dumpLuaGuiElement(pg.center),
                 screen = dump.dumpLuaGuiElement(pg.screen),
                 relative = dump.dumpLuaGuiElement(pg.relative) }
    end, function(m)log(m)end, Log.FINER)
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

    local mt = getmetatable(guiModel)
    if (mt == nil) then
        setmetatable(guiModel, { __index = Common })
    end

    return guiModel
end
--###########################################################################

--
-- (GUI-)EVENTS
--

--local function clicked(event)
--    Log.logBlock(event, function(m)log(m)end, Log.FINE)
--    if event.element.name == "gui_close_button" then
--        --local player_global = global.players[event.player_index]
--        --control_toggle.caption = (player_global.controls_active) and {"ugg.deactivate"} or {"ugg.activate"}
--
--        local p = game.get_player(event.player_index)
--        local pd = global_data.getPlayer_data(event.player_index)
--        local gui = frdgui.getGui(p, pd)
--
--        gui:close()
--    end
--end
----###########################################################################
--
--local function closed(event)
--    Log.logBlock(event, function(m)log(m)end, Log.FINE)
--
--    local what = event.element and event.element.name
--    Log.logBlock(what, function(m)log(m)end, Log.FINE)
--
--    local p = game.get_player(event.player_index)
--    local pd = global_data.getPlayer_data(event.player_index)
--    local gui = frdgui.getGui(p, pd)
--    gui:close()
--end
----###########################################################################
--
--function frdgui.setupEventhandler()
--    Log.log('setupEventhandler', function(m)log(m)end, Log.FINER)
--    script.on_event(defines.events.on_gui_click, clicked)
--    script.on_event(defines.events.on_gui_closed, closed)
--end
----###########################################################################


return frdgui
