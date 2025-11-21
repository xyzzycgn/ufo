---
--- Created by xyzzycgn.
--- DateTime: 20.11.25 08:47
---
local Log = require("__log4factorio__.Log")
local events_force = require("scripts.events.force")
local force_data = require("scripts.force_data")
local global_data = require("scripts.global_data")

local num_vaults = settings.startup["ufo-mined-ruin-vaults-needed"].value

local function initLogging()
    Log.setSeverityFromSettings("ufo-logLevel")
end
-- ###############################################################

--- event handler for on_player_mined_entity
--- triggered if a fulgoran-ruin-vault has been mined
--- @param event EventData
local function onPlayerMinedEntity(event)
    Log.logEvent(event, function(m)log(m)end, Log.FINE)

    local player = game.players[event.player_index]
    local force = player.force

    --- @type LuaTechnology
    local lt = force.technologies["ufo-tech"]
    if not (lt and lt.researched) then
        local fd = global_data.getForce_data(force.index)
        if not fd then
            -- just to be sure ;-)
            Log.log("new force detected", function(m)log(m)end, Log.INFO)
            fd = force_data.init_force_data()
            global_data.addForce_data(force, fd)
        end

        fd.num_vaults = fd.num_vaults + 1
        Log.logLine(fd.num_vaults, function(m)log(m)end, Log.FINE)

        if fd.num_vaults >= num_vaults then
            force.script_trigger_research("ufo-tech")
            Log.log("triggered ufo-tech", function(m)log(m)end, Log.INFO)
        end
    end
end
-- ###############################################################

--- register complexer events, i.e. with additional filters
local function registerEvents()
    local filters_ufo_components = { { filter = 'name', name = 'fulgoran-ruin-vault' }, }

    script.on_event(defines.events.on_player_mined_entity, onPlayerMinedEntity, filters_ufo_components)
end
-- ###############################################################

function string:startswith(start)
    return self:sub(1, #start) == start
end

local function checkPoles()
    local poles = prototypes.get_entity_filtered({ { filter = "type", type = "electric-pole" }})
    Log.logBlock(poles, function(m)log(m)end, Log.FINE)
    for ndx, prot in pairs(poles) do
        local name = prot.name
        if name:startswith("ufo-adapted-") then
            local type = prot.type
            Log.logLine({ ndx = ndx, name = name, type = type}, function(m)log(m)end, Log.FINE)
            -- TODO remember and check against old save
        end
    end
end
-- ###############################################################

-- complete initialization of ufo for new map/save-file
local function ufo_initializer()
    initLogging()
    Log.log('ufo on_init', function(m)log(m)end)
    global_data.init();

    local forces = {}
    for _, player in pairs(game.players) do
        local force = player.force
        Log.logLine(force, function(m)log(m)end, Log.FINE)
        if not forces[force] then
            forces[#forces + 1] = force
        end
    end
    Log.logLine(forces, function(m)log(m)end, Log.FINE)

    for _, force in pairs(forces) do
        local fd = force_data.init_force_data()
        global_data.addForce_data(force, fd)
    end

    registerEvents()
    checkPoles()
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--- initialization of ufo for save-file which already contained this mod
local function ufo_load()
    initLogging()
    Log.log('ufo on_load', function(m)log(m)end)

    registerEvents()
    checkPoles()
end

--- init ufo on every mod update or change
local function ufo_config_changed()
    Log.log('ufo config_changed', function(m)log(m)end)
end
--###############################################################

local function alterSetting(event, which, func)
    if event.setting == which then
        local new = settings.global[which].value
        if type(new) == "nil" then
            new = "<NIL>"
        elseif type(new) == "boolean" then
            new = new and "true" or "false"
        end
        Log.logMsg(function(m)log(m)end, Log.CONFIG, 'setting %s changed to %s', which, new)
        if func then
            func(new)
        end
        return true -- signals matching setting name
    end
    return false -- signals no match
end

local function changeSettings(e)
    -- local var to make lua happy
    local _ =
        alterSetting(e, "ufo-logLevel", function(newval) Log.setSeverity(Log[newval]) end)
--     or alterSetting(e, "ufo-xyz")
end
--###############################################################

-- mod initialization/configuration of handlers
local ufo = {}

ufo.on_init = ufo_initializer
ufo.on_load = ufo_load
ufo.on_configuration_changed = ufo_config_changed

-- events without filters
ufo.events = {
--    -- vvv mostly/only used in editor mode
--    [defines.events.on_surface_deleted]              = onSurfaceDeleted,
--    [defines.events.on_surface_cleared]              = onSurfaceCleared,
--    [defines.events.on_surface_imported]             = onSurfaceImported,
--    -- ^^^ mostly/only used in editor mode
--
--    [defines.events.on_object_destroyed ]            = onObjectDestroyed,
--    [defines.events.script_raised_destroy]           = entityRemoved,
--    [defines.events.on_player_created]               = events_player.playerJoinedOrCreated,
--    [defines.events.on_player_joined_game]           = events_player.playerJoinedOrCreated,
--    [defines.events.on_player_left_game]             = events_player.playerLeftGame,
--    [defines.events.on_player_removed]               = events_player.playerRemoved,
--    [defines.events.on_player_changed_surface]       = events_player.playerChangedSurface,
--    [defines.events.on_player_toggled_map_editor]    = events_player.toggleMapEditor,
    [defines.events.on_runtime_mod_setting_changed]  = changeSettings,
--    [defines.events.on_research_finished]            = onResearchFinished,
--
    [defines.events.on_force_created]                = events_force.onForceCreated,
    [defines.events.on_forces_merged]                = events_force.onForcesMerged,
    [defines.events.on_force_reset]                  = events_force.onForceReset,
--
--    [defines.events.on_tick] = asyncHandler.dequeue,
--
}
--
---- handling of business logic
--ufo.on_nth_tick = {
--    [60] = businessLogic,
--}

return ufo
