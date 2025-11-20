---
--- Created by xyzzycgn.
--- DateTime: 20.11.25 08:47
---
local Log = require("__log4factorio__.Log")

local ufo = {}

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local function initLogging()
    Log.setSeverityFromSettings("ufo-logLevel")
end

-- ###############################################################

--- event handler for on_player_mined_entity
--- if triggered in editor mode for dart-fcc, dart-radar and ammo-turret entities remove entity from internal data
--- @param event EventData
local function onPlayerMinedEntity(event)
    Log.logEvent(event, function(m)log(m)end, Log.CONFIG)

    local player = game.players[event.player_index]
    player.force.script_trigger_research("ufo-tech")

    Log.log("triggered ufo-tech", function(m)log(m)end, Log.CONFIG)
end



--- register complexer events, e.g. with additional filters
local function registerEvents()
    local filters_ufo_components = { { filter = 'name', name = 'fulgoran-ruin-vault' }, }

    script.on_event(defines.events.on_player_mined_entity, onPlayerMinedEntity, filters_ufo_components)
end

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- complete initialization of ufo for new map/save-file
local function ufo_initializer()
    initLogging()
    Log.log('ufo on_init', function(m)log(m)end)

    registerEvents()
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--- initialization of ufo for save-file which already contained this mod
local function ufo_load()
    initLogging()
    Log.log('ufo on_load', function(m)log(m)end)

    registerEvents()
end

--- init ufo on every mod update or change
local function ufo_config_changed()
    Log.log('ufo config_changed', function(m)log(m)end)
end
--###############################################################

-- mod initialization
ufo.on_init = ufo_initializer
ufo.on_load = ufo_load
ufo.on_configuration_changed = ufo_config_changed

-- events without filters


--ufo.events = {
--    -- vvv mostly/only used in editor mode
--    [defines.events.on_surface_deleted]              = onSurfaceDeleted,
--    [defines.events.on_surface_cleared]              = onSurfaceCleared,
--    [defines.events.on_surface_imported]             = onSurfaceImported,
--    -- ^^^ mostly/only used in editor mode
--
--    [defines.events.on_object_destroyed ]            = onObjectDestroyed,
--    [defines.events.script_raised_destroy]           = entityRemoved,
--    [defines.events.on_surface_created]              = surfaceCreated,
--    [defines.events.on_space_platform_changed_state] = space_platform_changed_state,
--    [defines.events.on_player_created]               = events_player.playerJoinedOrCreated,
--    [defines.events.on_player_joined_game]           = events_player.playerJoinedOrCreated,
--    [defines.events.on_player_left_game]             = events_player.playerLeftGame,
--    [defines.events.on_player_removed]               = events_player.playerRemoved,
--    [defines.events.on_player_changed_surface]       = events_player.playerChangedSurface,
--    [defines.events.on_player_toggled_map_editor]    = events_player.toggleMapEditor,
--    [defines.events.on_runtime_mod_setting_changed]  = changeSettings,
--    [defines.events.on_research_finished]            = onResearchFinished,
--
--    [defines.events.on_force_created]                = events_force.onForceCreated,
--    [defines.events.on_forces_merged]                = events_force.onForcesMerged,
--    [defines.events.on_force_reset]                  = events_force.onForceReset,
--
--    [defines.events.on_tick] = asyncHandler.dequeue,
--
--}
--
---- handling of business logic
--ufo.on_nth_tick = {
--    [60] = businessLogic,
--    [ufo_update_stock_period] = updateAmmoInStock
--}

return ufo
