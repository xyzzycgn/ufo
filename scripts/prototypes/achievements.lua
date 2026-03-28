---
--- Created by xyzzycgn.
--- achievements
---

local function make_achievement(name, icon, order, technology)
    return {
        type = "research-achievement",
        name = name,
        icons = {
            {
                icon = "__ufo__/graphics/achievements/" .. icon,
                icon_size = 128,

            },
            {
                icon = "__ufo__/graphics/achievements/experienced_archaeologist.png",
                icon_size = 256,
                scale = 0.27,
            },
        },
        order = "ufo-a-" .. order,
        technology = technology,
    }
end

data:extend({
    make_achievement("ufo-rookie-archaeologist", "bg_bronze.png", "a", "ufo-resonance-raw-shard-tech"),
    make_achievement("ufo-senior-archaeologist", "bg_silver.png", "b", "ufo-tech"),
    make_achievement("ufo-experienced-archaeologist", "bg_gold.png", "c", "ufo-fulgoran-know-how-tech"),
})