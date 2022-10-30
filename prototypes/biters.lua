local config = require("config")
local util = require("util")

data:extend({
    {
        type = "item",
        name = "bp-biter-egg",
        icon = "__BiterPower__/graphics/incubator/biter-egg.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "raw-resource",
        order = "a[biter-egg]",
        stack_size = config.biter.egg_stack_size,
    },
    {
        type = "item",
        name = "bp-caged-biter",
        icons = {
            {
                icon = "__base__/graphics/icons/steel-chest.png",
                icon_size = 64, icon_mipmaps = 4,
            },
            {
                icon = "__base__/graphics/icons/medium-biter.png",
                icon_size = 64, icon_mipmaps = 4,
            },
        },
        subgroup = "raw-resource",
        order = "a[caged-biter]",
        fuel_value = util.format_number(config.biter.fuel_value, true).."J",
        fuel_category = "bp-biter-power",
        burnt_result = "bp-caged-biter-tired",
        stack_size = 1,
    },
    {
        type = "item",
        name = "bp-caged-biter-tired",
        icons = {
            {
                icon = "__base__/graphics/icons/deconstruction-planner.png",
                icon_size = 64, icon_mipmaps = 4,
            },
            {
                icon = "__base__/graphics/icons/steel-chest.png",
                icon_size = 64, icon_mipmaps = 4,
            },
            {
                icon = "__base__/graphics/icons/medium-biter.png",
                icon_size = 64, icon_mipmaps = 4,
            },
        },
        subgroup = "raw-resource",
        order = "a[caged-biter-tired]",
        fuel_value = util.format_number(config.biter.tired_fuel_value, true).."J",
        fuel_category = "bp-biter-power",
        stack_size = 1
    },
})