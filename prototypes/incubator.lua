local config = require("config")

data:extend({
    {
        type = "item",
        name = "bp-biter-incubator",
        icon = "__base__/graphics/icons/assembling-machine-1.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "production-machine",
        order = "a[assembling-machine-1]",
        place_result = "bp-biter-incubator",
        stack_size = 20
    },
    {
        type = "recipe",
        name = "bp-biter-incubator",
        icon = "__base__/graphics/icons/uranium-processing.png",
        icon_size = 64, icon_mipmaps = 4,
        ingredients = {
            {"iron-gear-wheel", 8},
            {"pipe", 5},
            {"iron-plate", 10}
        },
        result = "bp-biter-incubator"
    },
    {
        type = "recipe-category",
        name = "bp-biter-ergonomics"
    },
    {
        type = "recipe",
        name = "bp-incubate-biter-egg",
        icons = {
            {
                icon = "__BiterPower__/graphics/incubator/biter-egg.png",
                icon_size = 64, icon_mipmaps = 4,
            },
            {
                icon = "__base__/graphics/icons/medium-biter.png",
                icon_size = 64, icon_mipmaps = 4,
            },
        },
        category = "bp-biter-ergonomics",            
        subgroup = "raw-material",
        energy_required = config.incubator.duration,
        ingredients = {
            {"bp-biter-egg", config.biter.egg_to_biter_ratio},
            {"steel-chest", 1}
        },
        results = {
            {
                name = "bp-caged-biter",
                probability = config.incubator.success_rate,
                amount_min = 0,
                amount_max = 2,
            },
            {
                name = "steel-chest",
                probability = 1 - config.incubator.success_rate,
                amount = 1,
            }
        }
    },
    {
        type = "assembling-machine",
        name = "bp-biter-incubator",
        icon = "__base__/graphics/icons/assembling-machine-1.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {mining_time = 0.2, result = "assembling-machine-1"},
        max_health = 300,
        corpse = "assembling-machine-1-remnants",
        dying_explosion = "assembling-machine-1-explosion", 
        fixed_recipe = "bp-incubate-biter-egg",
        crafting_categories = {"bp-biter-ergonomics"},
        resistances = {
            {
                type = "fire",
                percent = 70
            }
        },
        collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
        selection_box = {{-1, -1}, {1, 1}},
        -- damaged_trigger_effect = hit_effects.entity(),
        alert_icon_shift = util.by_pixel(-3, -12),
        energy_usage = util.format_number(config.incubator.power_usage, true).."W",
        crafting_speed = 1,
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = 4
        },
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
        },
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
                    scale = 2/3,
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-1/hr-assembling-machine-1.png",
                        priority="high",
                        width = 214,
                        height = 226,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, 2),
                        scale = 0.5 * 2/3
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
                    scale = 2/3,
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
                        scale = 0.5 * 2/3
                    }
                }
            }
        },
    }
})