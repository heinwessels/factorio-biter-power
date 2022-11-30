local config = require("config")
local util = require("util")

data:extend({
    {
        type = "item-subgroup",
        name = "bp-biters",
        group = "intermediate-products",
        order = "m"
    },
    {
        type = "item",
        name = "bp-biter-egg",
        icon = "__biter-power__/graphics/incubator/biter-egg.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "bp-biters",
        order = "a[biter-egg]",
        stack_size = config.biter.egg_stack_size,
    },
})

-- create biter items in cages
for biter_name, biter_data in pairs(config.biter.types) do
    data:extend({
        {
            type = "item",
            name = "bp-caged-"..biter_name,
            localised_name = {"bp-text.caged-biter", biter_name},
            localised_description = {"item-description.bp-caged-biter"},
            icons = {
                {
                    icon = "__biter-power__/graphics/cage/icon.png",
                    icon_size = 64,
                },
                {
                    icon = "__base__/graphics/icons/"..biter_name..".png",
                    icon_size = 64, icon_mipmaps = 4,
                },
            },
            subgroup = "bp-biters",
            order = "b[caged-biter]",
            fuel_value = util.format_number(config.biter.fuel_value * biter_data.energy_modifer, true).."J",
            fuel_category = "bp-biter-power",
            burnt_result = "bp-tired-caged-"..biter_name,
            stack_size = 1,
        },
        {
            type = "item",
            name = "bp-tired-caged-"..biter_name,
            localised_name = {"bp-text.tired-caged-biter", biter_name},
            localised_description = {"item-description.bp-caged-biter-tired"},
            icons = {
                {
                    icon = "__base__/graphics/icons/deconstruction-planner.png",
                    icon_size = 64, icon_mipmaps = 4,
                },
                {
                    icon = "__biter-power__/graphics/cage/icon.png",
                    icon_size = 64,
                },
                {
                    icon = "__base__/graphics/icons/"..biter_name..".png",
                    icon_size = 64, icon_mipmaps = 4,
                },
            },
            subgroup = "bp-biters",
            order = "c[caged-biter-tired]",
            fuel_value = util.format_number(config.biter.tired_fuel_value * biter_data.energy_modifer, true).."J",
            fuel_category = "bp-biter-power",
            stack_size = 1
        },
    })
end