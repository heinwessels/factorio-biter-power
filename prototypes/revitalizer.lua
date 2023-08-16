local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
if not config then error("No config found!") end
local lib = require("lib.lib")
local util = require("util")


local frame_sequence = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 10, 9, 8, 7, 8, 9, 10, 11}

local animation_speed = 0.5
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
            filename = "__biter-power__/graphics/revitalizer/center-back.png",
            width = 194,
            height = 173,
            scale = 0.25,
            repeat_count = #frame_sequence,
            hr_version = {
                filename = "__biter-power__/graphics/revitalizer/center-back.png",
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
        filename = "__biter-power__/graphics/revitalizer/center-front.png",
        width = 194,
        height = 173,
        scale = 0.5,
        repeat_count = #frame_sequence,
        hr_version = {
            filename = "__biter-power__/graphics/revitalizer/center-front.png",
            width = 194,
            height = 173,
            scale = 0.5,
            repeat_count = #frame_sequence,
        }
    })
end

local revitalizer_crafting_categories = {}
for tier = 1, config.biter.max_tier do
    table.insert(revitalizer_crafting_categories, "revitalization-tier-"..tier)
end

data:extend({
    {
        type = "item",
        name = "bp-revitalizer",
        icon = "__biter-power__/graphics/revitalizer/icon.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "bp-biter-machines",
        order = "d[biter-revitalizer]",
        place_result = "bp-revitalizer",
        stack_size = 20
    },
    {
        type = "recipe",
        name = "bp-revitalizer",
        icon = "__biter-power__/graphics/revitalizer/icon.png",
        icon_size = 64, icon_mipmaps = 4,
        ingredients = {
            {"steel-plate", 30},
            {"electronic-circuit", 10},
            {"copper-plate", 5},
        },
        result = "bp-revitalizer"
    },
    {
        type = "furnace",
        name = "bp-revitalizer",
        localised_description = {"",
            {"entity-description.bp-revitalizer"},
            {"bp-text.escape-modifier", config.escapes.escapable_machine["bp-revitalizer"]},
        },
        icon = "__biter-power__/graphics/revitalizer/icon.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"placeable-neutral", "placeable-player", "player-creation", "hide-alt-info"},
        minable = {mining_time = 0.2, result = "bp-revitalizer"},
        max_health = 400,
        corpse = "lab-remnants",
        dying_explosion = "lab-explosion",
        result_inventory_size = 1,
        source_inventory_size = 1, 
        crafting_categories = revitalizer_crafting_categories,
        resistances = {
            {
                type = "fire",
                percent = 70
            }
        },
        collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        damaged_trigger_effect = hit_effects.entity(),
        alert_icon_shift = util.by_pixel(-3, -12),
        crafting_speed = 1,
        energy_usage = util.format_number(config.revitalization.power_usage, true).."W",
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = config.revitalization.emissions_per_minute
        },
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        vehicle_impact_sound = sounds.generic_impact,
        working_sound = {
            sound = {
                {
                    filename = "__base__/sound/accumulator-working.ogg",
                    volume = 0.4
                },
                {
                    filename = "__base__/sound/creatures/biter-roar-mid-1.ogg",
                    volume = 0.4
                },
                {
                    filename = "__base__/sound/electric-furnace.ogg",
                    volume = 0.5
                }
            },
            max_sounds_per_type = 3,
            audible_distance_modifier = 0.6,
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

-- create recipes for revitilization
for tier = 1, config.biter.max_tier do
    data:extend{
        {
            type = "recipe-category",
            name = "revitalization-tier-"..tier,
        },
        {
            type = "item-subgroup",
            name = "revitalization-tier-"..tier,
            group = "biter-power-husbandry",
            order = "[b]-[tier-"..tier.."]-[b]"
        }
    }
end

for biter_name, biter_config in pairs(config.biter.types) do
    local icons = util.copy(biter_config.icons)
    table.insert(icons, 1, {
        icon = "__biter-power__/graphics/revitalizer/icon.png",
        icon_size = 64, icon_mipmaps = 4,
    })

    local recipe = {
        type = "recipe",
        name = "bp-revitalization-"..biter_name,
        localised_name = {"bp-text.revitalization", biter_name},
        icons = icons,
        show_amount_in_title = false,
        always_show_products = true,
        subgroup = "revitalization-tier-"..biter_config.tier,
        category =  "revitalization-tier-"..biter_config.tier,
        order = "c[revitilization]-["..data.raw.unit[biter_name].order:sub(-1).."]-["..biter_name.."]",
        ingredients = {{"bp-tired-caged-"..biter_name, 1}},
        energy_required = config.revitalization.time * biter_config.density_modifier,
        results = util.table.deepcopy(config.revitalization.results),
        enabled = false, -- Now needs to be unlocked by tech
    }
    recipe.results[1].name = "bp-caged-"..biter_name
    data:extend{ recipe }
end