---
--- Created by xyzzycgn.
---
local Log = require("__log4factorio__.Log")
local events_force = require("scripts.events.force")
local force_data = require("scripts.force_data")
local global_data = require("scripts.global_data")
local adapterHandling = require("scripts.adapterHandling")
local vaultHandling = require("scripts.vaultHandling")
local consts = require("__ufo__.scripts.consts")
local frdgui = require("scripts.gui")
local util = require("util")
local math2d = require("math2d")

local num_vaults = settings.startup["ufo-mined-ruin-vaults-needed"].value
local frd_radius = settings.global["ufo-frd-scan-radius"].value

local const_energy = util.parse_energy(consts.frd_energy) * 60 -- frd_energy is returned per tick, but needed per second
Log.logLine(const_energy, function(m)log(m)end, Log.CONFIG)

local function initLogging()
    Log.setSeverityFromSettings("ufo-logLevel")
end
-- ###############################################################

local function fe_mod_active()
    return script.active_mods["Electric_flying_enemies"]
end
-- ###############################################################

local function fe_mod_active_entity(entity, name)
    return fe_mod_active() and entity.name == name
end
-- ###############################################################

--- @param force LuaForce
--- @param tech string techname
--- @param threshold number
local function checkTechAndTrigger(force, tech, threshold)
    local fd = global_data.getForce_data(force.index)
    if not fd then
        -- just to be sure ;-)
        Log.log("new force detected", function(m)log(m)end, Log.INFO)
        fd = force_data.init_force_data()
        global_data.addForce_data(force, fd)
    end

    fd.num_vaults = fd.num_vaults + 1
    Log.logLine(fd.num_vaults, function(m)log(m)end, Log.FINE)

    if fd.num_vaults >= threshold then
        force.script_trigger_research(tech)
        Log.logMsg(function(m)log(m)end, Log.INFO, "triggered %s", tech)
    end
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--- @param force LuaForce
local function dig4tech(force)
    --- @type LuaTechnology
    local uat = force.technologies["ufo-archeological-tech"]
    if not (uat and uat.researched) then
        -- archeological-tech not researched yet
        Log.logLine(uat, function(m)log(m)end, Log.FINE)
        return
    end

    local ut = force.technologies["ufo-tech"]
    if not (ut and ut.researched) then
        checkTechAndTrigger(force,"ufo-tech", num_vaults)
    elseif ut then
        -- ufo-tech has been researched => dig for fulgoran-know-how-tech
        local fkht = force.technologies["ufo-fulgoran-know-how-tech"]
        Log.logLine(fkht, function(m)log(m)end, Log.FINE)
        if not (fkht and fkht.researched) then
            checkTechAndTrigger(force,"ufo-fulgoran-know-how-tech", math.ceil(num_vaults * consts.fulgoran_know_how_factor))
        end
    end
end
-- ###############################################################

--- triggered if a fulgoran-ruin-vault or an adapter has been mined
--- @param event EventData
local function onMinedEntity(event)
    Log.logEvent(event, function(m)log(m)end, Log.FINE)

    local entity = event.entity
    local is_vault = entity.name == "fulgoran-ruin-vault"
    if is_vault or fe_mod_active_entity(entity,"ufo-fulgoran-ruin-vault") then
        if event.player_index then
            -- player mined a vault (or protected vault)
            local player = game.players[event.player_index]
            dig4tech(player.force)
            if not is_vault then
                -- must be an protected vault (ufo-fulgoran-ruin-vault)
                vaultHandling.handleVaultBeforeShard(entity)
            end
        elseif event.robot then
            Log.log("mined by robot", function(m)log(m)end, Log.FINE)
            -- TODO???
        end
    elseif fe_mod_active_entity(entity, "fe_resonance_shard") then
        -- mined shard before vault
        vaultHandling.handleShardBeforeVault(entity)
    else
        -- player mined an adapter or an ufo-adapted-attractor
        Log.log(entity.name, function(m)log(m)end, Log.FINE)
        adapterHandling.handleDestruction(entity)
    end
end
-- ###############################################################

--- triggered if an adapter has been built
--- or a resonance shard if mod Electric_flying_enemies is active
--- @param event EventData
local function onBuiltEntity(event)
    Log.logEvent(event, function(m)log(m)end, Log.FINE)
    local entity = event.entity
    Log.logEntity(entity, function(m)log(m)end, Log.FINE)

    if fe_mod_active_entity(entity, "fe_resonance_shard") then
        vaultHandling.handleBuild(entity)
    else
        adapterHandling.handleBuild(entity)
    end
end
-- ###############################################################

--- event handler for on_entity_cloned
--- @param event EventData
local function onEntityCloned(event)
    Log.logEvent(event, function(m)log(m)end, Log.FINE)
end
-- ###############################################################

--- an adapter was destroyed
--- @param event EventData
local function entityDied(event)
    Log.logEvent(event, function(m)log(m)end, Log.FINE)
    adapterHandling.handleDestruction(event.entity)
end
-- ###############################################################

--- checks if ufo-detector-equipment-tech has been researched
--- @param pid LuaPlayer
--- @return LuaPlayer, boolean
local function checkTech4Player(p)
   return p and p.force.technologies["ufo-detector-equipment-tech"].researched
end
-- ###############################################################

--- checks if ufo-detector-equipment-tech has been researched
--- @param e EventData
--- @return LuaPlayer, boolean
local function checkTech(e)
   local p = game.get_player(e.player_index)
   return p, checkTech4Player(p)
end
--###############################################################

local function drawDot(parent, x, y, type)
    -- Create a circle
    local circle = parent.add {
        type = "sprite",
        sprite = type == "fulgoran-ruin-vault" and "dot-vault" or "dot-shard",
    }

    -- Position the circle specifically
    local style = circle.style
    style.left_padding = x
    style.top_padding = y
end
--###############################################################

-- 148 == height of F.R.D. sprite
-- 170 == width of F.R.D. sprite
local hofrd = 148 / 2
local wofrd = 170 / 2
local scalar = hofrd / frd_radius
local offset = { wofrd, hofrd }

--- @param relic LuaEntity
--- @param owningVehicle LuaEntity
local function normalizePosition(relic, owningVehicle)
    local diff = math2d.position.subtract(relic.position, owningVehicle.position)
    return math2d.position.add(math2d.position.multiply_scalar(diff, scalar), offset)
end
--###############################################################

--- @param frd LuaEquipment
--- @return boolean
local function check_energy(frd)
    local energy = (frd and frd.energy or 0)
    Log.logLine({ frd = frd, energy = energy }, function(m)log(m)end, Log.FINE)
    return energy >= const_energy
end
--###############################################################

--- @param player LuaPlayer
local function guiUpdates4Player(player)
    Log.logLine(player, function(m)log(m)end, Log.FINER)
    if checkTech4Player(player) then -- update only if tech is researched
        --- @type PlayerData
        local pd = global_data.getPlayerData(player.index)
        Log.logBlock(pd, function(m)log(m)end, Log.FINER)
        local gui = pd and pd.guiModel and pd.guiModel.gui
        if gui and gui.valid then
            local frd = pd.frd
            if check_energy(frd) then
                Log.log("##### high", function(m)log(m)end, Log.FINER)
                local high = pd.guiModel.refs["sprite-high"]
                high.visible = true
                pd.guiModel.refs["sprite-low"].visible = false

                -- clear all previous drawn dots
                high.clear()

                local grid = pd.grid
                if grid and grid.valid then
                    local owningVehicle = grid.entity_owner
                    Log.logLine(owningVehicle.position, function(m)log(m)end, Log.FINER)

                    for type, list in pairs(pd.relics or {}) do
                        for ndx, relic in pairs(list) do
                            if relic.valid then
                                local normalized = normalizePosition(relic, owningVehicle)
                                Log.logLine({ relic = relic.position, norm = normalized }, function(m)log(m)end, Log.FINER)
                                drawDot(high, normalized.x, normalized.y, type)
                            else
                                -- remove invalid (probably mined) relic
                                list[ndx] = nil
                            end
                        end
                    end
                end
            else
                Log.log("##### low", function(m)log(m)end, Log.FINER)
                pd.guiModel.refs["sprite-high"].visible = false
                pd.guiModel.refs["sprite-low"].visible = true
            end

        end
    end
end
--###############################################################

--- @param p LuaPlayer
--- @param pd PlayerData
local function toggleGui(p, pd)
    Log.logBlock(pd, function(m)log(m)end, Log.FINER)
    local guiModel = pd.guiModel
    Log.logLine( { frdOn = pd.frdOn, ivwfrd = pd.inVehicleWithFRD }, function(m)log(m)end, Log.FINE)

    if pd.frdOn and pd.inVehicleWithFRD then
        -- must show FRDgui
        guiModel = guiModel or frdgui.getGui(p, pd)
        Log.logBlock(guiModel, function(m)log(m)end, Log.FINER)
        guiModel:open()
        guiUpdates4Player(p)
    elseif guiModel then
        guiModel:close()
    end
end
-- ###############################################################

-- event handler
--- @param e EventData
local function toggle_frd_gui(e)
    Log.logEvent(e, function(m)log(m)end, Log.FINE)
    if (e.prototype_name == "ufo-toggle-gui") or (e.input_name == "ufo-toggle-gui-key") then
        local p, researched = checkTech(e)
        if researched then
            --- @type PlayerData
            local pd = global_data.getPlayerData(e.player_index)
            Log.logBlock(pd, function(m)log(m)end, Log.FINER)

            pd.frdOn = not pd.frdOn
            toggleGui(p, pd)
        end
    end
end
-- ###############################################################

--- @param characterOrPlayer LuaPlayer|LuaEntity
local function getIndex(characterOrPlayer)
    return characterOrPlayer
            and (characterOrPlayer.is_player() and characterOrPlayer.index
            or characterOrPlayer.player.index)
end
-- ###############################################################

--- @param e EventData
local function player_placed_equipment(e)
    Log.logEvent(e, function(m)log(m)end, Log.FINE)

    if e.equipment.name == "ufo-detector-equipment" then
        -- FRD has been added to grid
        --- @type PlayerData
        local pd = global_data.getPlayerData(e.player_index)
        local grid = e.grid
        local go = grid.entity_owner
        Log.logLine(go, function(m)log(m)end, Log.FINE)

        if go and go.valid and (go.type == "car" or go.type == "spider-vehicle") then
            -- FRD has been added to grid of vehicle
            local driver = go.get_driver()
            Log.logLine(driver, function(m)log(m)end, Log.FINE)

            local un = getIndex(driver)
            Log.logLine({ un = un , pid = e.player_index }, function(m)log(m)end, Log.FINE)

            if not un or (un ~= e.player_index) then
                -- no or different player is sitting in
                return
            end

            local equipments = grid.equipment
            local hasFrd = false
            for _, equipment in pairs(equipments) do
                if equipment.name == "ufo-detector-equipment" then
                    hasFrd = true
                    break
                end
            end

            if hasFrd and not pd.frd then
                Log.log("new FRD in grid in vehicle driven", function(m)log(m)end, Log.FINE)
                -- FRD new in grid
                pd.inVehicleWithFRD = true
                pd.frd = e.equipment
                pd.grid = grid
                local player = game.players[e.player_index]
                toggleGui(player, pd)
            end
        end
    end
end
-- ###############################################################

--- @param e EventData
local function player_removed_equipment(e)
    Log.logEvent(e, function(m)log(m)end, Log.FINE)

    if e.equipment == "ufo-detector-equipment" then
        -- FRD has been removed from grid
        --- @type PlayerData
        local pd = global_data.getPlayerData(e.player_index)
        local grid = pd.grid
        if grid and grid.valid and (grid.unique_id == e.grid.unique_id) then
            -- equipment has been removed from grid of vehicle the player is sitting in
            local equipments = grid.equipment
            local hasFrd = false
            for _, equipment in pairs(equipments) do
                if equipment.name == "ufo-detector-equipment" then
                    hasFrd = true
                    break
                end
            end

            if not hasFrd then
                -- no FRD in grid
                pd.inVehicleWithFRD = false
                pd.frd = nil
                pd.grid = nil
                local player = game.players[e.player_index]
                toggleGui(player, pd)
            end
        end
    end
end
-- ###############################################################

--- @param e EventData
local function driving_changed_state(e)
    Log.logEvent(e, function(m)log(m)end, Log.FINE)
    local p, researched = checkTech(e)
    if researched then
        local entity = e.entity
        -- planet-hopper raises this event, but without a vehicle as entity - so restrict to real vehicles
        -- car includes tank and hovercrafts
        if entity and entity.valid and (entity.type == "car" or entity.type == "spider-vehicle") then
            --- @type PlayerData
            local pd = global_data.getPlayerData(e.player_index)

            local driver = entity.get_driver()
            Log.logLine(driver, function(m)log(m)end, Log.FINE)

            -- driver can be LuaPlayer or LuaEntity
            -- @wube why simple if it can be complicated?
            local un = getIndex(driver)
            Log.logLine({ un = un , pid = e.player_index }, function(m)log(m)end, Log.FINER)

            local hasFrd = false
            if driver and (un == e.player_index) then
                -- driven by player
                local grid = entity.grid
                if grid and grid.valid then
                    local equipments = grid.equipment
                    Log.logBlock(equipment, function(m)log(m)end, Log.FINE)
                    for _, equipment in pairs(equipments) do
                        if equipment.name == "ufo-detector-equipment" then
                            hasFrd = true
                            pd.frd = equipment
                            pd.grid = grid
                            break
                        end
                    end

                    pd.inVehicleWithFRD = hasFrd
                end
            end

            if not hasFrd then
                -- not (or no longer) driven by player or no grid with FRD
                pd.inVehicleWithFRD = false
                pd.frd = nil
                pd.grid = nil
            end

            toggleGui(p, pd)
        end
    end
end
-- ###############################################################

--- register complexer events, i.e. with additional filters
local function registerEvents()
    -- filter for all known ufo-adapted-attractors
    local uaa = { filter = 'name', name = 'ufo-adapted-attractor' }
    -- filter for all known adapters of electric-poles (+ fe_resonance_shard if mod Electric_flying_enemies is active)
    local filters_building = {}
    -- filter for fulgoran-ruin-vault + ufo-adapted-attractor + all known adapters of electric-poles
    -- (+ ufo-fulgoran-ruin-vault + fe_resonance_shard if mod Electric_flying_enemies is active)
    local filters_mining = { { filter = 'name', name = 'fulgoran-ruin-vault' }, uaa }
    -- filter for ufo-adapted-attractor + all known adapter of electric-poles
    local filters_died = { uaa }

    local poles = adapterHandling.getAdapterPrototypes()
    for name, _ in pairs(poles) do
        local filter = { filter = 'name', name = name }
        filters_mining[#filters_mining + 1] = filter
        filters_building[#filters_building + 1] = filter
        filters_died[#filters_died + 1] = filter
        --filters_mining[#filters_mining + 1] = { filter = 'name', name = name }
        --filters_adapters_only[#filters_adapters_only + 1] = { filter = 'name', name = name }
        --filters_died[#filters_died + 1] = { filter = 'name', name = name }
    end

    if fe_mod_active() then
        Log.log("fe detected", function(m)log(m)end, Log.CONFIG)
        local vg_disabled = settings.startup["ufo-fe-resonance-shard-disables-vault-guardian"]
        if vg_disabled and vg_disabled.value then
            local rsfilter = { filter = 'name', name = "fe_resonance_shard" }
            filters_building[#filters_building + 1] = rsfilter
            filters_mining[#filters_mining + 1] = rsfilter
            filters_mining[#filters_mining + 1] = { filter = 'name', name = "ufo-fulgoran-ruin-vault" }
        end
    end

    Log.logLine(filters_building, function(m)log(m)end, Log.FINE)
    Log.logLine(filters_mining, function(m)log(m)end, Log.FINE)

    script.on_event(defines.events.on_player_mined_entity, onMinedEntity, filters_mining)
    script.on_event(defines.events.on_robot_mined_entity,  onMinedEntity, filters_mining)
    script.on_event(defines.events.on_built_entity,        onBuiltEntity, filters_building)
    script.on_event(defines.events.on_robot_built_entity,  onBuiltEntity, filters_building)
    script.on_event(defines.events.on_entity_cloned,       onEntityCloned, filters_building)
    script.on_event(defines.events.on_entity_died,         entityDied, filters_died)
end
-- ###############################################################

function string:startswith(start)
    return self:sub(1, #start) == start
end

--- checks if there changes to the set of electric-poles known by the game
--- @return any<string>, any<string> the names of the formerly unknown and of the no longer known adpters for poles
local function checkPoles()
    local known = adapterHandling.getAdapterPrototypes()
    Log.logBlock(known, function(m)log(m)end, Log.FINE)
    local remaining = {}
    local new = {}
    local removed = {}

    for name, prot in pairs(prototypes.get_entity_filtered({ { filter = "type", type = "electric-pole" }})) do
        if name:startswith("ufo-adapted-") then
            local type = prot.type
            Log.logLine({ name = name, type = type}, function(m)log(m)end, Log.FINE)
            if known[name] then
                remaining[name] = true
            else
                Log.logMsg(function(m)log(m)end, Log.CONFIG, "new type of pole detected: %s", name)
                new[name] = true
            end
        end
    end

    -- now new contains new pole types, remaining contains old types still in save
    -- known - new - remaining = removed types
    for name, _ in pairs(known) do
        if not (remaining[name] or new[name]) then
            Log.logMsg(function(m)log(m)end, Log.CONFIG, "type of pole has been removed: %s", name)
            removed[name] = true
        end
    end

    return new, removed
end
-- ###############################################################

local function updatePoles()
    local new, removed = checkPoles()
    for name, _ in pairs(new) do
        adapterHandling.addAdapterPrototype(name)
    end

    for name, _ in pairs(removed) do
        adapterHandling.removeAdapterPrototype(name)
    end
end
-- ###############################################################

-- complete initialization of ufo for new map/save-file
local function onInit()
    initLogging()
    Log.log('ufo on_init', function(m)log(m)end)
    global_data.init();

    local forces = {}
    for _, player in pairs(game.players) do
        local force = player.force
        Log.logLine(force, function(m)log(m)end, Log.FINER)
        if not forces[force] then
            forces[#forces + 1] = force
        end
    end
    Log.logLine(forces, function(m)log(m)end, Log.FINER)

    for _, force in pairs(forces) do
        local fd = force_data.init_force_data()
        global_data.addForce_data(force, fd)
    end
end
--###############################################################

--- initialization of ufo for save-file which already contained this mod
local function onLoad()
    initLogging()
    Log.log('ufo on_load', function(m)log(m)end)

    local new, removed = checkPoles()
    if (table_size(new) == 0 and table_size(removed) == 0) then
        -- no changes to set of poles known to game,
        -- this has to be done in on_configuration_changed as this implies also a change in mods
        registerEvents()
    end
    frdgui.load()
end
--###############################################################

--- init ufo on every mod update or change
local function onConfigurationChanged()
    Log.log('ufo config_changed', function(m)log(m)end)
    updatePoles()
    registerEvents()
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
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local function changeSettings(e)
    -- local var to make lua happy
    local _ =
        alterSetting(e, "ufo-logLevel", function(newval) Log.setSeverity(Log[newval]) end)
     or alterSetting(e, "ufo-frd-scan-radius")
end
--###############################################################

-- name of relics shown in F.R.D.
local fr_names = script.active_mods["Electric_flying_enemies"] and {
    "fulgoran-ruin-vault",
    "fe_resonance_shard",
} or {
    "fulgoran-ruin-vault",
}
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local function sortRelics(unsorted, owningVehicle)
    local sorted = {}

    -- split by type of relic
    for _, relic in pairs(unsorted) do
        local name = relic.name
        local byname = sorted[name] or {}
        byname[#byname + 1] = relic

        sorted[name] = byname
    end

    -- sort lists by distance
    local vpos = owningVehicle.position
    for _, list in pairs(sorted) do
        table.sort(list, function(a, b)
            -- position of vehicle as center point
            return math2d.position.distance_squared(vpos, a.position) < math2d.position.distance_squared(vpos, b.position)
        end)
    end

    Log.logBlock(sorted, function(m)log(m)end, Log.FINER)

    return sorted
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local function businessLogic()
    for _, player in pairs(game.players) do
        if checkTech4Player(player) then -- update only if tech is researched
            --- @type PlayerData
            local pd = global_data.getPlayerData(player.index)
            Log.logBlock(pd, function(m)log(m)end, Log.FINER)
            local guiModel = pd and pd.guiModel
            local gui = guiModel and guiModel.gui
            if guiModel and guiModel.state.visible and gui and gui.valid then
                -- @type LuaEquipment
                local frd = pd.frd
                local grid = pd.grid
                if grid and grid.valid and frd and frd.valid then
                    local owningVehicle = grid.entity_owner
                    Log.logEntity(owningVehicle, function(m)log(m)end, Log.FINER)
                    if owningVehicle and owningVehicle.valid then
                        Log.logLine({ frd = frd, energy = frd.energy, maxe = frd.max_energy, gen = frd.generator_power }, function(m)log(m)end, Log.FINER)
                        Log.logLine({ grid = grid, maxs = grid.max_solar_energy, bc = grid.battery_capacity, aib = grid.available_in_batteries, gen = grid.get_generator_energy() },
                                      function(m)log(m)end, Log.FINER)
                        if check_energy(frd) then
                            --- @type LuaSurface
                            local surface = owningVehicle.surface
                            if surface.name == "fulgora" then
                                local relics = surface.find_entities_filtered( { position = owningVehicle.position, radius = frd_radius, name = fr_names })
                                Log.logBlock(relics, function(m)log(m)end, Log.FINEST)
                                relics = sortRelics(relics, owningVehicle)
                                pd.relics = relics
                            end
                        end
                    end
                end
                Log.logBlock(pd, function(m)log(m)end, Log.FINER)

                guiUpdates4Player(player)
            end
        end
    end
end
--###############################################################

-- mod initialization/configuration of handlers
local ufo = {}

ufo.on_init = onInit
ufo.on_load = onLoad
ufo.on_configuration_changed = onConfigurationChanged

-- events without filters
ufo.events = {
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
    ["ufo-toggle-gui-key"]                           = toggle_frd_gui,
    [defines.events.on_lua_shortcut]                 = toggle_frd_gui,
    [defines.events.on_player_driving_changed_state] = driving_changed_state,
    [defines.events.on_player_removed_equipment]     = player_removed_equipment,
    [defines.events.on_player_placed_equipment]      = player_placed_equipment,

}

-- handling of gui updates
ufo.on_nth_tick = {
    [60] = businessLogic,
}

return ufo
