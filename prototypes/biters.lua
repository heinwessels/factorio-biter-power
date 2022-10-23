return function(ctx)
    data:extend({
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
            fuel_value = ctx.fuel_value,
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
            stack_size = 1
        },
    })
end