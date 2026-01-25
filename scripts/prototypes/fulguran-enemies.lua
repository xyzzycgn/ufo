---
--- Created by xyzzycgn.
--- adapter to mod Electric_flying_enemies
---
local data_util = require("__flib__.data-util")

-- ###############################################################

local vg_disabled = settings.startup["ufo-fe-resonance-shard-disables-vault-guardian"]
if vg_disabled and vg_disabled.value then
    local ufo_vault = data_util.copy_prototype(data.raw["simple-entity"]["fulgoran-ruin-vault"], "ufo-fulgoran-ruin-vault")

    data:extend({
        ufo_vault,
    })
end
-- ###############################################################

