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
      filename = "__BiterPower__/graphics/generator/generator-back.png",
      width = 195,
      height = 230,
      scale = 0.25 * 4 / 3,
      repeat_count = 16,
      hr_version = {
        filename = "__BiterPower__/graphics/generator/generator-back.png",
        width = 195,
        height = 230,        
        scale = 0.5 * 4 / 3,
        repeat_count = 16,
      }
    },
    belt_sprite_at({-2.1, 0.3}, "left"),
    belt_sprite_at({-1.1, 0.3}),
    belt_sprite_at({-0.1, 0.3}),
    belt_sprite_at({0.9, 0.3}, "right"),
    {
      filename = "__BiterPower__/graphics/generator/hr-motor.png",
      width = 195,
      height = 230,
      scale = 0.5 * 0.8 * 0.5,
      frame_count = 16,
      line_length = 4,
      shift = {1.2, 0},
      hr_version = {
        filename = "__BiterPower__/graphics/generator/hr-motor.png",
        width = 114,
        height = 318,
        frame_count = 16,
        line_length = 4,
        scale = 0.5 * 0.8,
        shift = {1.2, 0},
      }
    },
    {
      filename = "__BiterPower__/graphics/generator/generator-front.png",
      width = 195,
      height = 230,
      scale = 0.25 * 4 / 3,
      repeat_count = 16,
      hr_version = {
        filename = "__BiterPower__/graphics/generator/generator-front.png",
        width = 195,
        height = 230,
        scale = 0.5 * 4 / 3,
        repeat_count = 16,
      }
    },
  }
}

local biter_scale = 0.5
local animation = table.deepcopy(idle_animation)
table.insert(animation.layers, #animation.layers-1, {
  filename = "__base__/graphics/entity/biter/biter-run-02.png",
  width = 202,
  height = 158,
  line_length = 8,
  frame_count = 16,
  scale = biter_scale,
  shift = {-0.6, 0},
  hr_version =
  {
    filename ="__base__/graphics/entity/biter/hr-biter-run-02.png",
    width = 398,
    height = 310,
    scale = 0.5 * biter_scale,
    line_length = 8,
    frame_count = 16,
    shift = {-0.6, 0},
  }
})

data:extend({
  {
    type = "item",
    name = "bp-biter-generator",
    icon = "__base__/graphics/icons/assembling-machine-1.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "production-machine",
    order = "a[assembling-machine-1]",
    place_result = "bp-biter-generator",
    stack_size = 50
  },
  {
    type = "recipe",
    name = "bp-biter-generator",
    enabled = false,
    ingredients =
    {
      {"electronic-circuit", 3},
    },
    result = "bp-biter-generator"
  },
  {
    name = "bp-biter-generator",
    type = "burner-generator",
    icon = "__base__/graphics/icons/steam-engine.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral","player-creation"},
    max_health = 400,
    dying_explosion = "medium-explosion",
    corpse = "steam-engine-remnants",
    collision_box = {{-1.7, -1.7}, {1.7, 1.7}},
    selection_box = {{-2.0, -2.0}, {2.0, 2.0}},
    max_power_output = "1MW",
    minable = {mining_time = 1, result = "bp-biter-generator"},
    idle_animation = idle_animation,
    animation = animation,
    burner = {
      fuel_category = "chemical",
      effectivity = 0.5,
      fuel_inventory_size = 1,
      emissions_per_minute = 10,
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-output"
    }
  }
})