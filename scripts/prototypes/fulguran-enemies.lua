---
--- Created by xyzzycgn.
--- adapter to mod Electric_flying_enemies
---
local data_util = require("__flib__.data-util")

Log.log("mod Electric_flying_enemies detected", function(m)log(m)end, Log.CONFIG)
-- ###############################################################

local vg_disabled = settings.startup["ufo-fe-resonance-shard-disables-vault-guardian"]
if vg_disabled and vg_disabled.value then
    local ufo_vault = data_util.copy_prototype(data.raw["simple-entity"]["fulgoran-ruin-vault"], "ufo-fulgoran-ruin-vault")
    ufo_vault.hidden_in_factoriopedia = true

    data:extend({
        ufo_vault,
    })
end
-- ###############################################################

