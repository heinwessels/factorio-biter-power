local config = require("config")

local frame_sequence = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 10, 9, 8, 7, 8, 9, 10, 11}

local animation_speed = 0.7
local idle_animation = {
    layers = {
        {
            filename = "__base__/graphics/entity/lab/lab-shadow.png",
            width = 122,
            height = 68,
            frame_count = 1,
            line_length = 1,
            repeat_count = #frame_sequence,
            shift = util.by_pixel(13, 11),
            animation_speed = animation_speed,
            draw_as_shadow = true,
            hr_version =
            {
                filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
                width = 242,
                height = 136,
                frame_count = 1,
                line_length = 1,
                repeat_count = #frame_sequence,
                shift = util.by_pixel(13, 11),
                animation_speed = animation_speed,
                scale = 0.5,
                draw_as_shadow = true
            } 
        },
        {
            filename = "__BiterPower__/graphics/revitalization-center/center-back.png",
            width = 194,
            height = 173,
            scale = 0.25,
            repeat_count = #frame_sequence,
            hr_version = {
                filename = "__BiterPower__/graphics/revitalization-center/center-back.png",
                width = 194,
                height = 173,
                scale = 0.5,
                repeat_count = #frame_sequence,
            }
        },
    }
}

-- Now copy copy and start working on the working animation
local animation = table.deepcopy(idle_animation)

table.insert(animation.layers, {
    filename = "__base__/graphics/entity/accumulator/accumulator-charge.png",
    priority = "high",
    width = 90,
    height = 100,
    line_length = 6,
    frame_count = #frame_sequence,
    draw_as_glow = true,
    scale = 0.5,
    shift = util.by_pixel(0, -5),
    hr_version =
    {
      filename = "__base__/graphics/entity/accumulator/hr-accumulator-charge.png",
      priority = "high",
      width = 178,
      height = 206,
      line_length = 6,
      frame_count = #frame_sequence,
      draw_as_glow = true,
      shift = util.by_pixel(0, -5),
      scale = 0.5 * 0.5,
    }
}) 

-- Add the internal biter
local biter_scale = 0.45
local biter_shift = {0, 0.3}
table.insert(animation.layers, {
    filename = "__base__/graphics/entity/biter/biter-attack-shadow-02.png",
    width = 240,
    height = 128,
    y = 128,
    line_length = 11,
    frame_count = 11,
    scale = biter_scale,
    frame_sequence = frame_sequence,
    shift = util.mul_shift(util.by_pixel(30 + biter_shift[1]*32, 0 + biter_shift[2]*32), biter_scale),
    hr_version = {
        filename ="__base__/graphics/entity/biter/hr-biter-attack-shadow-02.png",
        width = 476,
        height = 258,
        y = 258,
        scale = 0.5 * biter_scale,
        frame_sequence = frame_sequence,
        line_length = 11,
        frame_count = 11,
        shift = util.mul_shift(util.by_pixel(13 + biter_shift[1]*64, -1 + biter_shift[2]*64), biter_scale),
    }
})
table.insert(animation.layers, {
    filename = "__base__/graphics/entity/biter/biter-attack-02.png",
    width = 182,
    height = 176,
    y = 176,
    line_length = 11,
    frame_count = 11,
    scale = biter_scale,
    frame_sequence = frame_sequence,
    shift = util.mul_shift(util.by_pixel(-2 + biter_shift[1]*32, -26 + biter_shift[2]*32), biter_scale),
    hr_version = {
        filename ="__base__/graphics/entity/biter/hr-biter-attack-02.png",
        width = 356,
        height = 348,
        y = 348,
        scale = 0.5 * biter_scale,
        frame_sequence = frame_sequence,
        line_length = 11,
        frame_count = 11,
        shift = util.mul_shift(util.by_pixel(0 + biter_shift[1]*64, -25 + biter_shift[2]*64), biter_scale),
    }
}) 

-- Now add the front to both
for _, property in pairs{idle_animation, animation} do
    table.insert(property.layers, {
        filename = "__BiterPower__/graphics/revitalization-center/center-front.png",
        width = 194,
        height = 173,
        scale = 0.25,
        repeat_count = #frame_sequence,
        hr_version = {
            filename = "__BiterPower__/graphics/revitalization-center/center-front.png",
            width = 194,
            height = 173,
            scale = 0.5,
            repeat_count = #frame_sequence,
        }
    })
end

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
        icons = {
            {
                icon = "__base__/graphics/icons/lab.png",
                icon_size = 64, icon_mipmaps = 4,
            },
            {
                icon = "__base__/graphics/icons/medium-biter.png",
                icon_size = 64, icon_mipmaps = 4,
            },
        }, 
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
        icons = {
            {
                icon = "__base__/graphics/icons/lab.png",
                icon_size = 64, icon_mipmaps = 4,
            },
            {
                icon = "__base__/graphics/icons/medium-biter.png",
                icon_size = 64, icon_mipmaps = 4,
            },
        },
        subgroup = "raw-material",
        category = "bp-biter-ergonomics",
        ingredients = {{"bp-caged-biter-tired", 1}},
        energy_required = config.revitalization.time,
        results = config.revitalization.results,
    },
    {
        type = "assembling-machine",
        name = "bp-biter-revitalization-center",
        icon = "__base__/graphics/icons/assembling-machine-1.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"placeable-neutral", "placeable-player", "player-creation", "hide-alt-info"},
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
        },
        idle_animation = idle_animation,
        animation = animation,
        integration_patch = {
            filename = "__base__/graphics/entity/lab/lab-integration.png",
            width = 122,
            height = 81,
            frame_count = 1,
            line_length = 1,
            repeat_count = #frame_sequence,
            shift = util.by_pixel(0, 15.5),
            hr_version =
            {
              filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
              width = 242,
              height = 162,
              frame_count = 1,
              line_length = 1,
              repeat_count = #frame_sequence,
              shift = util.by_pixel(0, 15.5),
              scale = 0.5
            }
          },
    }
})