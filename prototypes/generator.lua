local config = require("config")
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
      repeat_count = 16,
      hr_version = {
        filename = "__biter-power__/graphics/generator/generator-back.png",
        width = 195,
        height = 230,        
        scale = 0.5 * 4 / 3,
        repeat_count = 16,
      }
    },
    belt_sprite_at({-2.1, 0.4}, "left"),
    belt_sprite_at({-1.1, 0.4}),
    belt_sprite_at({-0.1, 0.4}),
    belt_sprite_at({0.9, 0.4}, "right"),
  }
}

-- Now copy copy and start working on the working animation
local animation = table.deepcopy(idle_animation)

local biter_scale = 0.45
local biter_shift = {-0.55, 0.2}
table.insert(animation.layers, {
  filename = "__base__/graphics/entity/biter/biter-run-shadow-02.png",
  width = 216,
  height = 144,
  line_length = 8,
  frame_count = 16,
  scale = biter_scale,
  shift = util.mul_shift(util.by_pixel(8 + biter_shift[1]*32, 0 + biter_shift[2]*32), biter_scale),
  hr_version = {
    filename ="__base__/graphics/entity/biter/hr-biter-run-shadow-02.png",
    width = 432,
    height = 292,
    scale = 0.5 * biter_scale,
    line_length = 8,
    frame_count = 16,
    shift = util.mul_shift(util.by_pixel(8 + biter_shift[1]*64, -1 + biter_shift[2]*64), biter_scale),
  }
})
table.insert(animation.layers, {
  filename = "__base__/graphics/entity/biter/biter-run-02.png",
  width = 202,
  height = 158,
  line_length = 8,
  frame_count = 16,
  scale = biter_scale,
  shift = util.mul_shift(util.by_pixel(-2 + biter_shift[1]*32, -6 + biter_shift[2]*32), biter_scale),
  hr_version = {
    filename ="__base__/graphics/entity/biter/hr-biter-run-02.png",
    width = 398,
    height = 310,
    scale = 0.5 * biter_scale,
    line_length = 8,
    frame_count = 16,
    shift = util.mul_shift(util.by_pixel(-1 + biter_shift[1]*64, -5 + biter_shift[2]*64), biter_scale),
  }
})  

-- Now add the outer cage edge to both
for _, property in pairs{idle_animation, animation} do
  table.insert(property.layers, {
    filename = "__biter-power__/graphics/generator/hr-motor.png",
    width = 114,
    height = 318,
    frame_count = 16,
    line_length = 4,
    scale = 0.5 * 0.8,
    shift = {1.2, 0},
    hr_version = {
      filename = "__biter-power__/graphics/generator/hr-motor.png",
      width = 114,
      height = 318,
      frame_count = 16,
      line_length = 4,
      scale = 0.5 * 0.8,
      shift = {1.2, 0},
    }
  })
  table.insert(property.layers, {
    filename = "__biter-power__/graphics/generator/hr-generator-shadow.png",
    draw_as_shadow = true,
    width = 274,
    height = 196,
    scale = 0.5 * 4 / 3,
    shift = {0.8, 0.3},
    repeat_count = 16,
    hr_version = {
      filename = "__biter-power__/graphics/generator/hr-generator-shadow.png",
      draw_as_shadow = true,
      width = 274,
      height = 196,
      scale = 0.5 * 4 / 3,
      shift = {0.8, 0.3},
      repeat_count = 16,
    }
  })
  table.insert(property.layers, {
    filename = "__biter-power__/graphics/generator/generator-front.png",
    width = 195,
    height = 230,
    scale = 0.5 * 4 / 3,
    repeat_count = 16,
    hr_version = {
      filename = "__biter-power__/graphics/generator/generator-front.png",
      width = 195,
      height = 230,
      scale = 0.5 * 4 / 3,
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
    type = "item",
    name = "bp-generator",
    icon = "__biter-power__/graphics/generator/icon.png",
    icon_size = 64,
    subgroup = "bp-biter-machines",
    order = "c[generator]",
    place_result = "bp-generator",
    stack_size = 50
  },
  {
    type = "recipe",
    name = "bp-generator",
    enabled = false,
    ingredients =
    {
      {"electronic-circuit", 3},
      {"transport-belt", 5},
      {"steel-plate", 5}
    },
    result = "bp-generator"
  },
  {
    name = "bp-generator",
    type = "burner-generator",
    localised_description = {"",
      {"entity-description.bp-generator"},
      {"bp-text.escape-chance", lib.formattime(config.escapes.escapable_machine["bp-generator"])},
    },
    icon = "__biter-power__/graphics/generator/icon.png",
    icon_size = 64,
    flags = {"placeable-neutral","player-creation"},
    max_health = 400,
    dying_explosion = "medium-explosion",
    corpse = "steam-engine-remnants",
    collision_box = {{-1.7, -1.7}, {1.7, 1.7}},
    selection_box = {{-2.0, -2.0}, {2.0, 2.0}},
    max_power_output = util.format_number(config.generator.power_output, true).."W",
    minable = {mining_time = 1, result = "bp-generator"},
    burner = {
      fuel_category = "bp-biter-power",
      effectivity = 1,
      fuel_inventory_size = 1,
      burnt_inventory_size = 1,
      emissions_per_minute = 10,
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
        shift = util.by_pixel(0, 230/2-222/2),
        repeat_count = 16,
        hr_version = {
          filename = "__biter-power__/graphics/generator/hr-integration-patch.png",
          width = 220,
          height = 222,
          scale = 0.5 * 4 / 3,
          shift = util.by_pixel(0, 230/2-222/2),
          repeat_count = 16,
        }
    },
  }
})

-- I'm placing all sprites at the wrong place with the middle in the middle, and not 
-- the bottom on the bottom tile edge. Shift everything up
local shift_correction = {0, -0.3}
local generator = data.raw["burner-generator"]["bp-generator"]
for _, property in pairs({"idle_animation", "animation"}) do
  for _, layer in pairs(generator[property].layers) do    
    layer.shift = layer.shift or {0, 0}
    layer.shift[1] = layer.shift[1] + shift_correction[1]
    layer.shift[2] = layer.shift[2] + shift_correction[2]
    layer.hr_version.shift = layer.hr_version.shift or {0, 0}
    layer.hr_version.shift[1] = layer.hr_version.shift[1] + shift_correction[1]
    layer.hr_version.shift[2] = layer.hr_version.shift[2] + shift_correction[2]
  end
end
generator.integration_patch.shift = generator.integration_patch.shift or {0, 0}
generator.integration_patch.shift[1] = generator.integration_patch.shift[1] + shift_correction[1]
generator.integration_patch.shift[2] = generator.integration_patch.shift[2] + shift_correction[2]
generator.integration_patch.hr_version.shift = generator.integration_patch.hr_version.shift or {0, 0}
generator.integration_patch.hr_version.shift[1] = generator.integration_patch.hr_version.shift[1] + shift_correction[1]
generator.integration_patch.hr_version.shift[2] = generator.integration_patch.hr_version.shift[2] + shift_correction[2]