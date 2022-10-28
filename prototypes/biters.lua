local config = require("config")

data:extend({
    {
        type = "item",
        name = "bp-biter-egg",
        icon = "__BiterPower__/graphics/incubator/biter-egg.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "raw-resource",
        order = "a[biter-egg]",
        stack_size = 1
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
                icon = "__base__/graphics/icons/small-biter.png",
                icon_size = 64, icon_mipmaps = 4,
            },
        },
        subgroup = "raw-resource",
        order = "a[caged-biter]",
        fuel_value = config.biter_fuel_value,
        fuel_category = "bp-biter-power",
        burnt_result = "bp-caged-biter-tired",
        stack_size = 1,
    },
    {
        type = "item",
        name = "bp-caged-biter-tired",
        icons = {
            {
                icon = "__base__/graphics/icons/steel-chest.png",
                icon_size = 64, icon_mipmaps = 4,
            },
            {
                icon = "__base__/graphics/icons/small-biter.png",
                icon_size = 64, icon_mipmaps = 4,
            },
        },
        subgroup = "raw-resource",
        order = "a[caged-biter-tired]",
        fuel_value = config.biter_tired_fuel_value,
        fuel_category = "bp-biter-power",
        stack_size = 1
    },
})