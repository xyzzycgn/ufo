--- copied from log4factorio V 0.2.2
---
--- Created by xyzzycgn.
--- DateTime: 20.03.25 13:21
---
--- Utility functions for dumping several game objects in more detail

local reverseTypes = {}

--- types for which translation is supported
local defines_types = {
    gui_type = defines.gui_type,
    events = defines.events
}

--- fills the translation table
--- @param types any one of the members from defines_types
local function fillReverseTypes(types)
    local rtypes = {}
    for k,v in pairs(defines_types[types] or {}) do
        rtypes[v] = k
    end

    reverseTypes[types] = rtypes
end
-- ###############################################################

--- transforms a number to the name of the correspondig constant (e.g.  defines.events.on_built_entity)
--- @param types any one of the members from defines_types
--- @param value number to be tranformed
local function getTypeName(types, value)
    if value then
        if not reverseTypes[types] then
            fillReverseTypes(types)
        end

        return reverseTypes[types][value] or ("unknown-" .. types .. (((type(value) == "number") and ("=" .. value)) or ""))
    end
    return nil
end
-- ###############################################################

--- @param quality LuaQualityPrototype
local function dumpQuality(quality)
    if quality.valid then
        local q = {
            level = quality.level,
            next = quality.next,
            range_multiplier = quality.range_multiplier,
        }
        return q
    end

    return quality
end
-- ###############################################################

--- @param entity LuaEntity
--- @param is_turret boolean
local function dumpEntity(entity, is_turret)
    if entity.valid then
        local de = {
            force = entity.force,
            force_index = entity.force_index,
            surface = entity.surface,
            status = entity.status,
            name = entity.name,
            type = entity.type,
            position = entity.position,
            prototype = entity.prototype,
            quality = dumpQuality(entity.quality),
            gps_tag = entity.gps_tag,
            destructible = entity.destructible,
            direction = entity.direction,
            speed = entity.speed,
            is_military_target = entity.is_military_target,
            get_radius = entity.get_radius(),
            unit_number = entity.unit_number,
        }

        if is_turret then
            de.shooting_target = entity.shooting_target
        end

        return de
    else
        return serpent.block(entity)
    end
end
-- ###############################################################

local function dumpCircuitNetwork(cn)
    local dcn = cn and {
        entity = cn.entity,
        network_id = cn.network_id,
        wire_type = cn.wire_type,
        signals = cn.signals,
        connected_circuit_count = cn.connected_circuit_count,
    } or {}

    return dcn
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local function dumpCircuitNetworks(cb)
    local dcn = {}

    for cn in pairs {
        defines.wire_connector_id.circuit_red,
        defines.wire_connector_id.circuit_green,
        defines.wire_connector_id.combinator_input_red,
        defines.wire_connector_id.combinator_input_green,
        defines.wire_connector_id.combinator_output_red,
        defines.wire_connector_id.combinator_output_green,
    } do
        dcn[cn] = dumpCircuitNetwork(cb.get_circuit_network(cn))
    end

    return dcn
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local function turretOnly(cb, dcb)
    if cb and (cb.type == defines.control_behavior.type.turret) then
        dcb.circuit_condition = cb.circuit_condition
        dcb.disabled = cb.disabled
    end
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

local function dumpControlBehavior(cb)
    local dcb = cb and {
        circuit_networks = dumpCircuitNetworks(cb),
        type = cb.type,
    } or {}

    turretOnly(cb, dcb)

    return dcb
end
-- ###############################################################

--- @param lge LuaGuiElement
local function dumpLuaGuiElement(lge)
    local dlge = lge and {
        type = getTypeName("gui_type", lge.type),
        children_names = lge.children_names,
        enabled = lge.enabled,
        tags = lge.tags,
        caption = lge.caption,
        name = lge.name,
        index = lge.index,
        valid = lge.valid,
        visible = lge.visible,
    } or {}

    return dlge
end
-- ###############################################################

local function tableCopy(obj)
    if type(obj) ~= 'table' then
        return obj
    end
    local res = {}
    for k, v in pairs(obj) do
        res[tableCopy(k)] = tableCopy(v)
    end
    return res
end
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--- @param event EventData
local function dumpEvent(event)
    if event then
        local erg = tableCopy(event)
        erg.gui_type = getTypeName("gui_type", event.gui_type)
        erg.name = getTypeName("events", event.name)
        return erg
    end

    return {}
end
-- ###############################################################

--- adds an event - generated with script.generate_event_name() - to the list of standard events (from defines.events)
--- to make dumpEvent() also work for these events
--- @param name string name of the generated event
--- @param eventNumber number return value of script.generate_event_name()
local function registerGeneratedEvent(name, eventNumber)
    if not reverseTypes["events"] then
        fillReverseTypes("events")
    end

    local rtypes = reverseTypes["events"]
    rtypes[eventNumber] = name
end
-- ###############################################################

local dump = {
    dumpEvent = dumpEvent,
    dumpLuaGuiElement = dumpLuaGuiElement,
    dumpControlBehavior = dumpControlBehavior,
    dumpEntity = dumpEntity,
    dumpQuality = dumpQuality,
    registerGeneratedEvent = registerGeneratedEvent,
}
return dump