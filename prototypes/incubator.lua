local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local config = require("config")
local util = require("util")

data:extend({
    {
        type = "item",
        name = "bp-incubator",
        icon = "__biter-power__/graphics/incubator/icon.png",
        icon_size = 64,
        subgroup = "bp-biter-machines",
        order = "b[biter-incubator]",
        place_result = "bp-incubator",
        stack_size = 20
    },
    {
        type = "recipe",
        name = "bp-incubator",
        icon = "__biter-power__/graphics/incubator/icon.png",
        icon_size = 64,
        ingredients = {
            {"stone-brick", 6},
            {"copper-plate", 4}
        },
        result = "bp-incubator"
    },
    {
        type = "recipe-category",
        name = "bp-biter-incubation"
    },
    {
        type = "assembling-machine",
        name = "bp-incubator",
        icon = "__biter-power__/graphics/incubator/icon.png",
        icon_size = 64,
        flags = {"placeable-neutral", "placeable-player", "player-creation", "hide-alt-info"},
        minable = {mining_time = 0.2, result = "bp-incubator"},
        max_health = 300,        
        corpse = "chemical-plant-remnants",
        dying_explosion = "chemical-plant-explosion",
        crafting_categories = {"bp-biter-incubation"},
        resistances = {
            {
                type = "fire",
                percent = 70
            }
        },
        collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
        selection_box = {{-1, -1}, {1, 1}},
        damaged_trigger_effect = hit_effects.entity(),
        alert_icon_shift = util.by_pixel(-3, -12),
        energy_usage = util.format_number(config.incubator.power_usage, true).."W",
        crafting_speed = 1,
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = config.incubator.emissions_per_minute
        },
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        vehicle_impact_sound = sounds.generic_impact,
        working_sound = {
            sound = {
                {
                    filename = "__base__/sound/electric-furnace.ogg",
                    volume = 0.5
                }
            },
            audible_distance_modifier = 0.5,
            fade_in_ticks = 4,
            fade_out_ticks = 20
        },
        always_draw_idle_animation = true,
        idle_animation = {layers = {
            {
                filename = "__biter-power__/graphics/incubator/center.png",
                width = 194,
                height = 223,
                scale = 0.5 * 2 / 3,
                shift = {0, -0.2},
                hr_version = {
                    filename = "__biter-power__/graphics/incubator/center.png",
                    width = 194,
                    height = 223,
                    scale = 0.5 * 2 / 3,
                    shift = {0, -0.2},
                }
            },
            {
                filename = "__biter-power__/graphics/incubator/center-shadow.png",
                width = 294,
                height = 188,
                draw_as_shadow = true,
                scale = 0.5 * 2 / 3,
                shift = {0.5, 0.2},
                hr_version = {
                    filename = "__biter-power__/graphics/incubator/center-shadow.png",
                    width = 294,
                    height = 188,
                    draw_as_shadow = true,
                    scale = 0.5 * 2 / 3,
                    shift = {0.5, 0.2},
                }
            },
        }},
        working_visualisations = {
            {
                apply_recipe_tint = "primary",
                animation = {
                    filename = "__biter-power__/graphics/incubator/center-light-bottom.png",
                    draw_as_glow = true,
                    width = 194,
                    height = 223,
                    scale = 0.5 * 2 / 3,
                    shift = {0, -0.2},
                    hr_version = {
                        filename = "__biter-power__/graphics/incubator/center-light-bottom.png",
                        draw_as_glow = true,
                        width = 194,
                        height = 223,
                        scale = 0.5 * 2 / 3,
                        shift = {0, -0.2},
                    }
                }
            },
            {
                animation = {
                    filename = "__biter-power__/graphics/incubator/center-light-top.png",
                    blend_mode = "additive",
                    draw_as_glow = true,
                    width = 194,
                    height = 223,
                    scale = 0.5 * 2 / 3,
                    shift = {0, -0.2},
                    hr_version =
                    {
                        filename = "__biter-power__/graphics/incubator/center-light-top.png",
                        blend_mode = "additive",
                        draw_as_glow = true,
                        width = 194,
                        height = 223,
                        scale = 0.5 * 2 / 3,
                        shift = {0, -0.2},
                    }
                }
            }
        }
    }
})

-- create recipes for revitilization
for biter_name, biter_data in pairs(config.biter.types) do
    local recipe =     {
        type = "recipe",
        name = "bp-incubate-egg-"..biter_name,
        localised_name = {"bp-text.incubation", biter_name},
        icons = {
            {
                icon = "__biter-power__/graphics/incubator/biter-egg.png",
                icon_size = 64, icon_mipmaps = 4,
            },
            {
                icon = "__base__/graphics/icons/"..biter_name..".png",
                icon_size = 64, icon_mipmaps = 4,
            },
        },
        category = "bp-biter-incubation",        
        subgroup = "bp-biters",
        order = "c[incubation]",
        crafting_machine_tint = {primary={r=226, g=22, b=190}},
        energy_required = config.incubator.duration,
        ingredients = util.table.deepcopy(config.incubator.ingredients),
        results = util.table.deepcopy(config.incubator.results),
    }
    recipe.results[1].name = "bp-caged-"..biter_name
    data:extend{ recipe }
end