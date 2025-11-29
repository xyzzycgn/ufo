---
--- Created by xyzzycgn.
---

--- indexed by the name of the prototype of the adapter for the electric-pole
--- @alias AdapterData table<string, UfoAdapters>

--- indexed by the unit_number of the adapter entity
--- @alias UfoAdapters table<number, UfoAdapter>

--- describes an ufo adapter.
--- @class UfoAdapter
--- @field pos MapPosition location of adapter
--- @field dist float supply area distance
--- @field adaptees table<number, true> indexed by unit_number of adapted attractor

--- describes an attractor connected to at least one ufo adapter.
--- @class AdaptedAttractor
--- @field entity LuaEntity the attractor entity
--- @field pos MapPosition location of adapted attractor
--- @field direction defines.direction
--- @field force ForceID id of the owning force
--- @field adaptedBy table<number, true>unit_numbers of the adapter entities

