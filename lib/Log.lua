---
--- Slim logging facility with the ability to change the amount of logged statements at runtime.
--- copied from log4factorio V 0.2.1
local dump = require("__log4factorio__.dump")

--- defines the log levels
local Log = {
    FATAL  = 8,
    ERROR  = 7,
    WARN   = 6,
    INFO   = 5,
    CONFIG = 4,
    FINE   = 3,
    FINER  = 2,
    FINEST = 1,
}

--- default log level
local DEFAULT = Log.CONFIG

--- actual active log level (severity)
local severity = DEFAULT

local MSG = {
    [Log.FINEST] = "[FINEST] ",
    [Log.FINER]  = "[FINER] ",
    [Log.FINE]   = "[FINE] ",
    [Log.CONFIG] = "[CONFIG] ",
    [Log.INFO]   = "[INFO] ",
    [Log.WARN]   = "[WARN] ",
    [Log.ERROR]  = "[ERROR] ",
    [Log.FATAL]  = "[FATAL] ",
}

---Sets the severity level for logging
---@param sev number The severity level to set
function Log.setSeverity(sev)
    severity = sev
end

---Sets the severity level from game settings
---@param setting string The name of the setting to read from settings.global
function Log.setSeverityFromSettings(setting)
    if (settings.global[setting] and settings.global[setting].value) then
        severity = Log[settings.global[setting].value] or DEFAULT
    end
end

---Logs a message with the specified severity level
---@param msgOrFunction string|function Message to log or a function that returns the message
---@param func function Function to use for logging (e.g., game.print)
---@param sev number? Severity level (optional, defaults to DEFAULT)
function Log.log(msgOrFunction, func, sev)
    sev = sev or DEFAULT
    if (sev >= severity) then
        local msg = (type(msgOrFunction) == "function") and msgOrFunction() or msgOrFunction
        func(MSG[sev] .. (msg or "<NIL>"))
    end
end

---Logs a message using serpent.block for detailed object inspection
---@param msgOrFunction string|function Message/object to log or a function that returns it
---@param func function Function to use for logging (e.g., game.print)
---@param sev number? Severity level (optional, defaults to DEFAULT)
function Log.logBlock(msgOrFunction, func, sev)
    sev = sev or DEFAULT
    if (sev >= severity) then
        local msg = (type(msgOrFunction) == "function") and msgOrFunction() or msgOrFunction
        func(MSG[sev] .. serpent.block(msg))
    end
end

---Logs a message using serpent.line for single-line object inspection
---@param msgOrFunction string|function Message/object to log or a function that returns it
---@param func function Function to use for logging (e.g., game.print)
---@param sev number? Severity level (optional, defaults to DEFAULT)
function Log.logLine(msgOrFunction, func, sev)
    sev = sev or DEFAULT
    if (sev >= severity) then
        local msg = (type(msgOrFunction) == "function") and msgOrFunction() or msgOrFunction
        func(MSG[sev] .. serpent.line(msg))
    end
end

--- logs a message using string.format to build the logmessage
--- @param func function Function to use for logging (e.g., game.print)
--- @param sev number Severity level
--- @param format string formating string used for string.format to build the logmessage
--- @param ...? varargs with the optional parameters used for string.format
--- @since 0.2.0
function Log.logMsg(func, sev, format, ...)
    if (sev >= severity) then
        func(MSG[sev] .. string.format(format, ...))
    end
end

--- logs an event and transforms the event number (event.name) to the corresponding identifier for more readability
--- @param event EventData the event to be logged
--- @param func function Function to use for logging (e.g., game.print)
--- @param sev number? Severity level
--- @since 0.2.0
function Log.logEvent(event, func, sev)
    Log.logLine(function() return dump.dumpEvent(event) end, func, sev)
end


--- logs a LuaEntity with more details
--- @param entity LuaEntity to be logged
--- @param func function Function to use for logging (e.g., game.print)
--- @param sev number? Severity level
--- @since 0.2.0
function Log.logEntity(entity, func, sev)
    Log.logBlock(function() return dump.dumpEntity(entity) end, func, sev)
end


--- logs a LuaGuiElement with more details
--- @param lge LuaGuiElement to be logged
--- @param func function function to use for logging (e.g., game.print)
--- @param sev number? Severity level
--- @since 0.2.0
function Log.logLuaGuiElement(lge, func, sev)
    Log.logBlock(function() return dump.dumpLuaGuiElement(lge) end, func, sev)
end


--- logs a ControlBehaviour with more details
--- @param cb ControlBehaviour to be logged
--- @param func function function to use for logging (e.g., game.print)
--- @param sev number? Severity level
--- @since 0.2.0
function Log.logLControlBehavior(cb, func, sev)
    Log.logBlock(function() return dump.dumpControlBehavior(cb) end, func, sev)
end


return Log