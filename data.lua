-----------------------------------------------
--[[        Create a global config           ]] 
-----------------------------------------------
config = require("config")
-----------------------------------------------

require("prototypes.organisation")
require("prototypes.biters")
require("prototypes.cage")
require("prototypes.generator")
require("prototypes.generator-reinforced")
require("prototypes.incubator")
require("prototypes.revitalizer")
require("prototypes.buried-biter-nest")
require("prototypes.egg-extractor")
require("prototypes.cage-trap")
require("prototypes.cage-cannon")
require("prototypes.pulper")
require("prototypes.technology")


if mods["debugadapter"] and false then
    log("====== Biter Power: Config [Stats for nerds] ======")
    log(serpent.block(config))
    log("--- Extra Stats ---")
    log("Biter Power Capacity: "..string.format("%.2f", config.biter.fuel_value/1e3/3600).." kW-hour")
    log("Biter Net Power Capacity: "..string.format("%.2f", config.biter.fuel_value_net/1e3/3600).." kW-hour")
    log("Biters consumed per MW-hour: "..string.format("%.2f", config.biter.consumed_per_watt*1e6*3600).." biters")
    log("Biters lost per MW-hour: "..string.format("%.2f", config.biter.loss_per_watt*1e6*3600).." biters")
    log("Buried Nest Power: "..string.format("%.2f", config.buried_nest.power_output/1e6).." MW")
    log("Buried Nest Power Capacity: "..string.format("%.2f", config.buried_nest.power_capacity/1e6/3600).." MW-hour")
end