local config = require("config")

data:extend({
    {
        type = "item",
        name = "bp-biter-incubator",
        icon = "__biter-power__/graphics/incubator/incubator-icon.png",
        icon_size = 64,
        subgroup = "bp-biter-machines",
        order = "b[biter-incubator]",
        place_result = "bp-biter-incubator",
        stack_size = 20
    },
    {
        type = "recipe",
        name = "bp-biter-incubator",
        icon = "__biter-power__/graphics/incubator/incubator-icon.png",
        icon_size = 64,
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
        icon = "__biter-power__/graphics/incubator/incubator-icon.png",
        icon_size = 64,
        category = "bp-biter-ergonomics",            
        subgroup = "raw-material",
        energy_required = config.incubator.duration,
        ingredients = config.incubator.ingredients,
        results = config.incubator.results,
    },
    {
        type = "assembling-machine",
        name = "bp-biter-incubator",
        icon = "__biter-power__/graphics/incubator/incubator-icon.png",
        icon_size = 64,
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

            -- K2 Air Purifier is -75, but we will have much less incubators then
            -- a player typically has purifiers
            emissions_per_minute = -200
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
        working_visualisations =
        {
          {
            effect = "uranium-glow",
            fadeout = true,
            light = {intensity = 0.2, size = 9.9, shift = {0.0, 0.0}, color = {r = 248/255, g = 104/255, b = 215/255}}
          },
          {
            effect = "uranium-glow",
            fadeout = true,
            draw_as_light = true,
            animation = { layers = {
                {
                    filename = "__biter-power__/graphics/incubator/center-glow.png",
                    priority = "high",
                    blend_mode = "additive", -- centrifuge
                    animation_speed = 0.5,
                    line_length = 8,
                    width = 55,
                    height = 98,
                    frame_count = 64,
                    hr_version = {
                        filename = "__biter-power__/graphics/incubator/hr-center-glow.png",
                        priority = "high",
                        blend_mode = "additive", -- centrifuge
                        animation_speed = 0.5,
                        line_length = 8,
                        width = 108,
                        height = 197,
                        frame_count = 64,
                        scale = 0.5 * 1.5,
                        shift = {0.03, -0.24},
                    }
                }
            }}
          }
        },
        always_draw_idle_animation = true,
        idle_animation = {
            layers = {
                {
                    filename = "__base__/graphics/entity/centrifuge/centrifuge-A.png",
                    priority = "high",
                    line_length = 8,
                    width = 70,
                    height = 123,
                    frame_count = 64,
                    scale = 1.5,
                    animation_speed = 0.5,
                    shift = {0, -1},
                    hr_version = {
                      filename = "__biter-power__/graphics/incubator/hr-center.png",
                      priority = "high",
                      line_length = 8,
                      width = 139,
                      height = 246,
                      animation_speed = 0.5,
                      frame_count = 64,
                      scale = 0.5 * 1.5,
                      shift = {-0.1, 0},
                    }
                },
                {
                    filename = "__base__/graphics/entity/centrifuge/centrifuge-A.png",
                    priority = "high",
                    width = 70,
                    height = 123,
                    scale = 1.5,
                    repeat_count = 64,
                    shift = {0, -1},
                    hr_version = {
                      filename = "__biter-power__/graphics/incubator/hr-center-front.png",
                      priority = "high",
                      width = 139,
                      height = 246,
                      repeat_count = 64,
                      scale = 0.5 * 1.5,
                      shift = {-0.1, 0},
                    }
                },
                {
                    filename = "__biter-power__/graphics/incubator/center-shadow.png",
                    draw_as_shadow = true,
                    priority = "high",
                    line_length = 8,
                    width = 108,
                    height = 54,
                    frame_count = 64,
                    scale = 1.4,
                    shift = {1.5, 0},
                    hr_version = {
                      filename = "__biter-power__/graphics/incubator/hr-center-shadow.png",
                      draw_as_shadow = true,
                      priority = "high",
                      line_length = 8,
                      width = 163,
                      height = 123,
                      frame_count = 64,
                      scale = 0.5 * 1.4,
                      shift = {1.5, 0},
                    }
                },
            },
        },
        integration_patch = {
            filename = "__base__/graphics/entity/lab/lab-integration.png",
            width = 122,
            height = 81,
            frame_count = 1,
            line_length = 1,
            repeat_count = 64,
            shift = util.by_pixel(0, 10.5),
            scale = 2 / 3 * 0.9,
            hr_version =
            {
              filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
              width = 242,
              height = 162,
              frame_count = 1,
              line_length = 1,
              repeat_count = 64,
              shift = util.by_pixel(0, 10.5),
              scale = 0.5 * 2 / 3 * 0.95,
            }
        },
    }
})