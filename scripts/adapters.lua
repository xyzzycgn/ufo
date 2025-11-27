---
--- Created by xyzzycgn.
---

--- indexed by the name of the prototype of the adaper for the electric-pole
--- @class AdapterData
--- @field ad table<string, UfoAdapters>

--- indexed by the unit_number of the adapter entity
--- @alias UfoAdapters table<number, UfoAdapter>

--- describes an ufo adapter.
--- @class UfoAdapter
--- @field pos MapPosition location of adapter
--- @field dist float supply area distance
--- @field adaptees table<number, true> indexed by unit_number of adapted attractor

--- describes an attractor connected to an ufo adapter.
--- @class AdaptedAttractor
--- @field pos MapPosition location of adapted attractor
--- @field direction defines.direction
--- @field force ForceID id of the owning force

