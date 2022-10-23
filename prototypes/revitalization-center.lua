return function(ctx)
    data:extend({
        {
            type = "item",
            name = "bp-biter-revitalization-center",
            icon = "__base__/graphics/icons/assembling-machine-1.png",
            icon_size = 64, icon_mipmaps = 4,
            subgroup = "production-machine",
            order = "a[assembling-machine-1]",
            place_result = "bp-biter-revitalization-center",
            stack_size = 20
        },
        {
            type = "recipe",
            name = "bp-biter-revitalization-center",
            icon = "__base__/graphics/icons/uranium-processing.png",
            icon_size = 64, icon_mipmaps = 4,
            ingredients = {
                {"iron-gear-wheel", 8},
                {"pipe", 5},
                {"iron-plate", 10}
            },
            result = "bp-biter-revitalization-center"
        },
        {
            type = "recipe",
            name = "bp-biter-revitalization",
            icon = "__base__/graphics/icons/uranium-processing.png",
            icon_size = 64, icon_mipmaps = 4,            
            subgroup = "raw-material",
            category = "bp-biter-ergonomics",
            ingredients = {{"bp-caged-biter-tired", 1}},
            energy_required = ctx.revitalization_time,
            results = {
                {
                    name = "bp-caged-biter",
                    probability = ctx.revitalization_rate,
                    amount = 1,
                },
                {
                    name = "bp-biter-egg",
                    probability = ctx.egg_drop_rate,
                    amount = 1,
                }
            }
        },
        {
            type = "assembling-machine",
            name = "bp-biter-revitalization-center",
            icon = "__base__/graphics/icons/assembling-machine-1.png",
            icon_size = 64, icon_mipmaps = 4,
            flags = {"placeable-neutral", "placeable-player", "player-creation"},
            minable = {mining_time = 0.2, result = "assembling-machine-1"},
            max_health = 300,
            corpse = "assembling-machine-1-remnants",
            dying_explosion = "assembling-machine-1-explosion", 
            crafting_categories = {"bp-biter-ergonomics"},
            fixed_recipe = "bp-biter-revitalization",
            resistances = {
                {
                    type = "fire",
                    percent = 70
                }
            },
            collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
            selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
            -- damaged_trigger_effect = hit_effects.entity(),
            alert_icon_shift = util.by_pixel(-3, -12),
            animation = {
                layers = {
                    {
                        filename = "__base__/graphics/entity/assembling-machine-1/assembling-machine-1.png",
                        priority="high",
                        width = 108,
                        height = 114,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, 2),
                        hr_version = {
                            filename = "__base__/graphics/entity/assembling-machine-1/hr-assembling-machine-1.png",
                            priority="high",
                            width = 214,
                            height = 226,
                            frame_count = 32,
                            line_length = 8,
                            shift = util.by_pixel(0, 2),
                            scale = 0.5
                        }
                    },
                    {
                        filename = "__base__/graphics/entity/assembling-machine-1/assembling-machine-1-shadow.png",
                        priority="high",
                        width = 95,
                        height = 83,
                        frame_count = 1,
                        line_length = 1,
                        repeat_count = 32,
                        draw_as_shadow = true,
                        shift = util.by_pixel(8.5, 5.5),
                        hr_version = {
                            filename = "__base__/graphics/entity/assembling-machine-1/hr-assembling-machine-1-shadow.png",
                            priority="high",
                            width = 190,
                            height = 165,
                            frame_count = 1,
                            line_length = 1,
                            repeat_count = 32,
                            draw_as_shadow = true,
                            shift = util.by_pixel(8.5, 5),
                            scale = 0.5
                        }
                    }
                }
            },
            crafting_speed = 0.5,
            energy_source = {
                type = "electric",
                usage_priority = "secondary-input",
                emissions_per_minute = 4
            },
            energy_usage = "75kW",
            -- open_sound = sounds.machine_open,
            -- close_sound = sounds.machine_close,
            -- vehicle_impact_sound = sounds.generic_impact,
            working_sound = {
                sound = {
                    {
                    filename = "__base__/sound/assembling-machine-t1-1.ogg",
                    volume = 0.5
                    }
                },
                audible_distance_modifier = 0.5,
                fade_in_ticks = 4,
                fade_out_ticks = 20
            }
        }
    })
end