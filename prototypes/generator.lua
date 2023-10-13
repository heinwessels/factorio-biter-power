if not config then error("No config found!") end
local util = require("util")
local lib = require("lib.lib")

local function belt_sprite_at(shift, section)
    local y_offset = 0
    if section == "right" then y_offset = 19
    elseif section == "left" then y_offset = 14 end
    scale = scale or 1
    local sprite = {
      filename = "__base__/graphics/entity/transport-belt/transport-belt.png",
      width = 64,
      height = 64,
      frame_count = 16,
      line_length = 16,
      run_mode = "backward",
      y = y_offset * 64,
      hr_version = {
        filename = "__base__/graphics/entity/transport-belt/hr-transport-belt.png",
        width = 128,
        height = 128,
        scale = 0.5,
        frame_count = 16,
        line_length = 16,
        run_mode = "backward",
        y = y_offset * 128,
      }
    }
    sprite.shift = shift
    sprite.scale = (sprite.scale or 1) * scale
    sprite.hr_version.shift = shift
    sprite.hr_version.scale = (sprite.hr_version.scale or 1) * scale
    return sprite
  end
  
local idle_animation = {
  layers = {
    {
      filename = "__biter-power__/graphics/generator/generator-back.png",
      width = 195,
      height = 230,        
      scale = 0.5 * 4 / 3,
      shift = {0, -0.3},
      repeat_count = 16,
      hr_version = {
        filename = "__biter-power__/graphics/generator/generator-back.png",
        width = 195,
        height = 230,        
        shift = {0, -0.3},
        scale = 0.5 * 4 / 3,
        repeat_count = 16,
      }
    },
    belt_sprite_at({-2.0, -0.2}, "left"),
    belt_sprite_at({-1.0, -0.2}),
    belt_sprite_at({-0.0, -0.2}),
    belt_sprite_at({1.0, -0.2}, "right"),
  }
}

-- Now copy copy and start working on the working animation
local animation = table.deepcopy(idle_animation)

-- Now add the outer cage edge to both
for _, property in pairs{idle_animation, animation} do
  table.insert(property.layers, {
    filename = "__biter-power__/graphics/generator/hr-motor.png",
    width = 114,
    height = 318,
    frame_count = 16,
    line_length = 4,
    scale = 0.5 * 0.8,
    shift = {1.5, -0.3},
    hr_version = {
      filename = "__biter-power__/graphics/generator/hr-motor.png",
      width = 114,
      height = 318,
      frame_count = 16,
      line_length = 4,
      scale = 0.5 * 0.8,
      shift = {1.5, -0.3},
    }
  })
  table.insert(property.layers, {
    filename = "__biter-power__/graphics/generator/hr-generator-shadow.png",
    draw_as_shadow = true,
    width = 274,
    height = 196,
    scale = 0.5 * 4 / 3,
    shift = {0.8, 0},
    repeat_count = 16,
    hr_version = {
      filename = "__biter-power__/graphics/generator/hr-generator-shadow.png",
      draw_as_shadow = true,
      width = 274,
      height = 196,
      scale = 0.5 * 4 / 3,
      shift = {0.8, 0},
      repeat_count = 16,
    }
  })
  table.insert(property.layers, {
    filename = "__biter-power__/graphics/generator/generator-front.png",
    width = 195,
    height = 230,
    scale = 0.5 * 4 / 3,
    shift = {0, -0.3},
    repeat_count = 16,
    hr_version = {
      filename = "__biter-power__/graphics/generator/generator-front.png",
      width = 195,
      height = 230,
      scale = 0.5 * 4 / 3,
      shift = {0, -0.3},
      repeat_count = 16,
    }
  })
end

data:extend({
  {
      type = "fuel-category",
      name = "bp-biter-power"
  },
  {
    type = "fuel-category",
    name = "bp-biter-power-advanced"
  },
  {
    type = "item",
    name = "bp-generator",
    icon = "__biter-power__/graphics/generator/icon.png",
    icon_size = 64,
    subgroup = "bp-biter-machines",
    order = "c[generator]",
    place_result = "bp-generator",
    stack_size = 20
  },
  {
    type = "recipe",
    name = "bp-generator",
    enabled = false,
    ingredients =
    {
      {"electronic-circuit", 3},
      {"transport-belt", 2},
      {"steel-plate", 1}
    },
    result = "bp-generator"
  },
  {
    name = "bp-generator",
    type = "burner-generator",
    localised_description = {"",
      {"entity-description.bp-generator"},
      {"bp-text.escape-modifier", config.escapes.escapable_machine["bp-generator"]},
    },
    icon = "__biter-power__/graphics/generator/icon.png",
    icon_size = 64,
    flags = {"placeable-neutral","player-creation"},
    max_health = 400,
    dying_explosion = "big-explosion",
    corpse = "big-remnants",
    collision_box = {{-1.7, -1.7}, {1.7, 1.7}},
    selection_box = {{-2.0, -2.0}, {2.0, 2.0}},
    max_power_output = util.format_number(config.generator.power_output, true).."W",
    minable = {mining_time = 1, result = "bp-generator"},
    placeable_by = {item = "bp-generator", count = 1},
    next_upgrade = "bp-generator-reinforced",
    fast_replaceable_group = "bp-generators",
    burner = {
      fuel_category = "bp-biter-power",
      effectivity = 1,
      fuel_inventory_size = 1,
      burnt_inventory_size = 1,
      emissions_per_minute = config.generator.emissions_per_minute,
    },
    energy_source = {
      type = "electric",
      usage_priority = "secondary-output"
    },
    working_sound = {
      sound = {      
        {
          filename = "__base__/sound/transport-belt.ogg",
          volume = 0.3
        },
      },
      match_speed_to_activity = true,
      max_sounds_per_type = 2,
      audible_distance_modifier = 0.6,
    },
    idle_animation = idle_animation,
    animation = animation,
    integration_patch = {
        filename = "__biter-power__/graphics/generator/hr-integration-patch.png",
        width = 220,
        height = 222,
        scale = 0.5 * 4 / 3,
        shift = util.by_pixel(0, 230/2 - 222/2 - 0.3*32),
        repeat_count = 16,
        hr_version = {
          filename = "__biter-power__/graphics/generator/hr-integration-patch.png",
          width = 220,
          height = 222,
          scale = 0.5 * 4 / 3,
          shift = util.by_pixel(0, 230/2 - 222/2 - 0.3*32),
          repeat_count = 16,
        }
    },
  }
})
