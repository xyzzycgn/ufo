---
--- Created by xyzzycgn.
--- fulgoran know how technology
---
local consts = require("scripts.consts")

local num_vaults = math.ceil(settings.startup["ufo-mined-ruin-vaults-needed"].value * consts.fulgoran_know_how_factor)

-- technology
local ufo_fulgoran_know_how_tech = {
    name = "ufo-fulgoran-know-how-tech",
    type = "technology",
    icons = {
        {
            icon = "__base__/graphics/technology/research-speed.png",
            icon_size = 256,
            icon_mipmaps = 4,
            tint = { r = 0.79, g = 0.55, b = 0.66, a = 0.9 },
        }
    },

    prerequisites = { "ufo-tech" },
    research_trigger = { type = "scripted", trigger_description = {"description.ufo-fulgoran-know-how-tech", tostring(num_vaults)}},
    order = "ufo-b-c4-d3",
    factoriopedia_description = { "factoriopedia-description.ufo-tech" } -- TODO ufo-fulgoran-know-how-tech + locales!
}
-- ###############################################################

data:extend({ ufo_fulgoran_know_how_tech })