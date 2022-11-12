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
require("prototypes.egg-extractor")
require("prototypes.cage-trap")
require("prototypes.technology")


if mods["debugadapter"] then
    log("====== Biter Power: Config [Stats for nerds] ======")
    local config = require("config")
    log(serpent.block(config))
    log("--- Extra Stats ---")
    log("Biter Effective Power: "..string.format("%.2f", config.biter.fuel_value_net/1e6/3600).." MW-hour")
    log("Buried Nest Power: "..string.format("%.2f", config.buried_nest.generators_supported*config.generator.power_output/1e6).." MW")
    log("Buried Nest Power Capacity: "..string.format("%.2f", config.buried_nest.spawn_amount/config.biter.egg_to_biter_ratio*config.biter.fuel_value_net/1e6/3600).." MW-hour")
end