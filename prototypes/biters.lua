local config = require("config")
local util = require("util")
local lib = require("lib.lib")

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
for biter_name, biter_config in pairs(config.biter.types) do
    data:extend({
        {
            type = "item",
            name = "bp-caged-"..biter_name,
            localised_name = {"bp-text.caged-biter", biter_name},
            localised_description = {"", 
                {"item-description.bp-caged-biter"},
                {"bp-text.escape-chance", lib.formattime(biter_config.escape_period)},
            },
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
            order = "b[caged-biter]-[tier-"..biter_config.tier.."]-["..biter_name.."]",
            fuel_glow_color = biter_config.tint,
            fuel_value = lib.format_number(config.biter.fuel_value * biter_config.energy_modifer * biter_config.density_modifier, true).."J",
            fuel_category = biter_config.tier <= 2 and "bp-biter-power" or "bp-biter-power-advanced",
            burnt_result = "bp-tired-caged-"..biter_name,
            place_result = biter_name,
            stack_size = 1,
        },
        {
            type = "item",
            name = "bp-tired-caged-"..biter_name,
            localised_name = {"bp-text.tired-caged-biter", biter_name},
            localised_description = {"", 
                {"item-description.bp-caged-biter-tired"},
                {"bp-text.escape-chance", lib.formattime(biter_config.escape_period * config.biter.tired_modifier)},
            },
            icons = {
                {
                    icon = "__biter-power__/graphics/cage/icon.png",
                    icon_size = 64,
                },
                {
                    icon = "__base__/graphics/icons/"..biter_name..".png",
                    icon_size = 64, icon_mipmaps = 4,
                },
                {
                    icon = "__base__/graphics/icons/"..biter_name..".png",
                    icon_size = 64, icon_mipmaps = 4,
                    tint = {a = 0.1, r = 1}
                },
            },
            subgroup = "bp-biters",
            order = "c[caged-biter-tired]-[tier-"..biter_config.tier.."]-["..biter_name.."]",
            fuel_value = lib.format_number(config.biter.tired_fuel_value * biter_config.energy_modifer * biter_config.density_modifier, true).."J",
            fuel_category = "bp-biter-power",
            place_result = biter_name,
            stack_size = 1
        },
    })
end