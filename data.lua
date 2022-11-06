data:extend{{ -- No other good to place this for now
    type = "item-subgroup",
    name = "bp-biter-machines",
    group = "production",
    order = "m"
}}

require("prototypes.biters")
require("prototypes.cage")
require("prototypes.generator")
require("prototypes.incubator")
require("prototypes.revitalization-center")
require("prototypes.buried-biter-nest")
require("prototypes.biter-relocation-center")


if mods["debugadapter"] then
    log("====== Biter Power: Config [Stats for nerds] ======")
    local config = require("config")
    log(serpent.block(config))
    log("--- Extra Stats ---")
    log("Biter Effective Power: "..string.format("%.2f", config.biter.fuel_value_net/1e6/3600).." MW-hour")
end