if not config then error("No config found!") end
local util = require("util")
local lib = require("lib.lib")


data:extend({
    {
        type = "item",
        name = "bp-biter-egg",
        icon = "__biter-power__/graphics/incubator/biter-egg.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "bp-husbandry-intermediates",
        order = "a[biter-egg]",
        stack_size = config.biter.egg_stack_size,
    },
})

-- create recipes for revitilization
for tier = 1, config.biter.max_tier do
    data:extend{
        {
            type = "item-subgroup",
            name = "bp-biters-tier-"..tier,
            group = "biter-power-husbandry",
            order = "b"
        },
    }
end

-- create biter items in cages
for biter_name, biter_config in pairs(config.biter.types) do
    local unit = data.raw.unit[biter_name] -- Should exist

    -- Create the caged and tired caged items
    local caged_icons = util.copy(biter_config.icons)
    table.insert(caged_icons, 1, {
        icon = "__biter-power__/graphics/cage/icon.png",
        icon_size = 64,
    })

    local tired_caged_icons = util.copy(biter_config.icons)
    table.insert(tired_caged_icons, 1, {
        icon = "__biter-power__/graphics/cage/icon.png",
        icon_size = 64,
    })
    table.insert(tired_caged_icons, 
        util.merge{tired_caged_icons[#tired_caged_icons], {
            tint = {a = 0.1, r = 1}
        }}
    )

    data:extend({
        {
            type = "item",
            name = "bp-caged-"..biter_name,
            localised_name = {"bp-text.caged-biter", unit.localised_name or {"entity-name."..unit.name}},
            localised_description = {"", 
                {"item-description.bp-caged-biter"},
                {"bp-text.escape-chance", lib.formattime(biter_config.escape_period)},
            },
            icons = caged_icons,
            subgroup = "bp-biters-tier-"..biter_config.tier,
            order = "[b]-["..biter_name.."]-[a]",
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
            localised_name = {"bp-text.tired-caged-biter", unit.localised_name or {"entity-name."..unit.name}},
            localised_description = {"", 
                {"item-description.bp-caged-biter-tired"},
                {"bp-text.escape-chance", lib.formattime(biter_config.escape_period * config.biter.tired_modifier)},
            },
            icons = tired_caged_icons,
            subgroup = "bp-biters-tier-"..biter_config.tier,
            order = "[b]-["..biter_name.."]-b[tired]",
            fuel_value = lib.format_number(config.biter.tired_fuel_value * biter_config.energy_modifer * biter_config.density_modifier, true).."J",
            fuel_category = "bp-biter-power",
            place_result = biter_name,
            stack_size = 1
        },
    })

    -- Add some description to the biter units
    unit.localised_description = {"", 
        {"bp-text.energy-capacity", data.raw.item["bp-caged-"..biter_name].fuel_value},
        {"bp-text.escape-chance", lib.formattime(biter_config.escape_period)},
    }
end