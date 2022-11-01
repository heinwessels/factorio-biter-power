-- Holy moly mining-drills are complicated!
local config = require("config")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

data:extend({
    {
        type = "item",
        name = "bp-biter-relocation-center",
        icon = "__base__/graphics/icons/electric-mining-drill.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "bp-biter-machines",
        order = "a[biter-relocation-center]",
        place_result = "bp-biter-relocation-center",
        stack_size = 20
    },
    {
        type = "recipe",
        name = "bp-biter-relocation-center",
        icon_size = 64, icon_mipmaps = 4,
        ingredients = {
            {"iron-gear-wheel", 8},
            {"pipe", 5},
            {"iron-plate", 10}
        },
        result = "bp-biter-relocation-center"
    },
    {
        type = "mining-drill",
        name = "bp-biter-relocation-center",
        icon = "__base__/graphics/icons/electric-mining-drill.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.3, result = "bp-biter-relocation-center"},
        max_health = 300,
        resource_categories = {"bp-biter-nest"},
        corpse = "electric-mining-drill-remnants",
        dying_explosion = "electric-mining-drill-explosion",
        collision_box = {{ -1.4, -1.4}, {1.4, 1.4}},
        selection_box = {{ -1.5, -1.5}, {1.5, 1.5}},
        damaged_trigger_effect = hit_effects.entity(),
        working_sound = {
          sound = {
            filename = "__base__/sound/electric-mining-drill.ogg",
            volume = 0.5
          },
          audible_distance_modifier = 0.6,
          fade_in_ticks = 4,
          fade_out_ticks = 20
        },
        vehicle_impact_sound = sounds.generic_impact,
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        mining_speed = config.relocation_center.mining_speed,
        energy_source = {
          type = "electric",
          emissions_per_minute = 10,
          usage_priority = "secondary-input"
        },
        energy_usage = "90kW",
        resource_searching_radius = 0.49,
        vector_to_place_result = {0, -1.85},
        module_specification = nil,
        monitor_visualization_tint = {r=78, g=173, b=255},    
        circuit_wire_connection_points = circuit_connector_definitions["electric-mining-drill"].points,
        circuit_connector_sprites = circuit_connector_definitions["electric-mining-drill"].sprites,
        circuit_wire_max_distance = default_circuit_wire_max_distance,

        graphics_set = {
          drilling_vertical_movement_duration = 10 / electric_drill_animation_speed,
          animation_progress = 1,
          min_animation_progress = 0,
          max_animation_progress = 30,
    
          status_colors = electric_mining_drill_status_colors(),
    
          circuit_connector_layer = "object",
          circuit_connector_secondary_draw_order = { north = 14, east = 30, south = 30, west = 30 },
    
          animation =
          {
            north =
            {
              layers =
              {
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-N.png",
                  line_length = 1,
                  width = 96,
                  height = 104,
                  frame_count = 1,
                  animation_speed = electric_drill_animation_speed,
                  direction_count = 1,
                  shift = util.by_pixel(0, -4),
                  repeat_count = 5,
                  hr_version =
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N.png",
                    line_length = 1,
                    width = 190,
                    height = 208,
                    frame_count = 1,
                    animation_speed = electric_drill_animation_speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -4),
                    repeat_count = 5,
                    scale = 0.5
                  }
                },
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-N-output.png",
                  line_length = 5,
                  width = 32,
                  height = 34,
                  frame_count = 5,
                  animation_speed = electric_drill_animation_speed,
                  direction_count = 1,
                  shift = util.by_pixel(-4, -44),
                  hr_version =
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-output.png",
                    line_length = 5,
                    width = 60,
                    height = 66,
                    frame_count = 5,
                    animation_speed = electric_drill_animation_speed,
                    direction_count = 1,
                    shift = util.by_pixel(-3, -44),
                    scale = 0.5
                  }
                },
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-N-shadow.png",
                  line_length = 1,
                  width = 106,
                  height = 104,
                  frame_count = 1,
                  animation_speed = electric_drill_animation_speed,
                  draw_as_shadow = true,
                  shift = util.by_pixel(6, -4),
                  repeat_count = 5,
                  hr_version =
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-shadow.png",
                    line_length = 1,
                    width = 212,
                    height = 204,
                    frame_count = 1,
                    animation_speed = electric_drill_animation_speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(6, -3),
                    repeat_count = 5,
                    scale = 0.5
                  }
                }
              }
            },
            east =
            {
              layers =
              {
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-E.png",
                  line_length = 1,
                  width = 96,
                  height = 94,
                  frame_count = 1,
                  animation_speed = electric_drill_animation_speed,
                  direction_count = 1,
                  shift = util.by_pixel(0, -4),
                  repeat_count = 5,
                  hr_version =
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E.png",
                    line_length = 1,
                    width = 192,
                    height = 188,
                    frame_count = 1,
                    animation_speed = electric_drill_animation_speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -4),
                    repeat_count = 5,
                    scale = 0.5
                  }
                },
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-E-output.png",
                  line_length = 5,
                  width = 26,
                  height = 38,
                  frame_count = 5,
                  animation_speed = electric_drill_animation_speed,
                  direction_count = 1,
                  shift = util.by_pixel(30, -8),
                  hr_version =
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-output.png",
                    line_length = 5,
                    width = 50,
                    height = 74,
                    frame_count = 5,
                    animation_speed = electric_drill_animation_speed,
                    direction_count = 1,
                    shift = util.by_pixel(30, -8),
                    scale = 0.5
                  }
                },
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-E-shadow.png",
                  line_length = 1,
                  width = 112,
                  height = 92,
                  frame_count = 1,
                  animation_speed = electric_drill_animation_speed,
                  draw_as_shadow = true,
                  shift = util.by_pixel(10, 2),
                  repeat_count = 5,
                  hr_version =
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-shadow.png",
                    line_length = 1,
                    width = 222,
                    height = 182,
                    frame_count = 1,
                    animation_speed = electric_drill_animation_speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(10, 2),
                    repeat_count = 5,
                    scale = 0.5
                  }
                }
              }
            },
            south =
            {
              layers =
              {
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-S.png",
                  line_length = 1,
                  width = 92,
                  height = 98,
                  frame_count = 1,
                  animation_speed = electric_drill_animation_speed,
                  direction_count = 1,
                  shift = util.by_pixel(0, -2),
                  repeat_count = 5,
                  hr_version =
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S.png",
                    line_length = 1,
                    width = 184,
                    height = 192,
                    frame_count = 1,
                    animation_speed = electric_drill_animation_speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -1),
                    repeat_count = 5,
                    scale = 0.5
                  }
                },
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-S-shadow.png",
                  line_length = 1,
                  width = 106,
                  height = 102,
                  frame_count = 1,
                  animation_speed = electric_drill_animation_speed,
                  draw_as_shadow = true,
                  shift = util.by_pixel(6, 2),
                  repeat_count = 5,
                  hr_version =
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-shadow.png",
                    line_length = 1,
                    width = 212,
                    height = 204,
                    frame_count = 1,
                    animation_speed = electric_drill_animation_speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(6, 2),
                    repeat_count = 5,
                    scale = 0.5
                  }
                }
              }
            },
            west =
            {
              layers =
              {
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-W.png",
                  line_length = 1,
                  width = 96,
                  height = 94,
                  frame_count = 1,
                  animation_speed = electric_drill_animation_speed,
                  direction_count = 1,
                  shift = util.by_pixel(0, -4),
                  repeat_count = 5,
                  hr_version =
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W.png",
                    line_length = 1,
                    width = 192,
                    height = 188,
                    frame_count = 1,
                    animation_speed = electric_drill_animation_speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -4),
                    repeat_count = 5,
                    scale = 0.5
                  }
                },
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-W-output.png",
                  line_length = 5,
                  width = 24,
                  height = 28,
                  frame_count = 5,
                  animation_speed = electric_drill_animation_speed,
                  direction_count = 1,
                  shift = util.by_pixel(-30, -12),
                  hr_version =
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-output.png",
                    line_length = 5,
                    width = 50,
                    height = 60,
                    frame_count = 5,
                    animation_speed = electric_drill_animation_speed,
                    direction_count = 1,
                    shift = util.by_pixel(-31, -13),
                    scale = 0.5
                  }
                },
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-W-shadow.png",
                  line_length = 1,
                  width = 102,
                  height = 92,
                  frame_count = 1,
                  animation_speed = electric_drill_animation_speed,
                  draw_as_shadow = true,
                  shift = util.by_pixel(-6, 2),
                  repeat_count = 5,
                  hr_version =
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-shadow.png",
                    line_length = 1,
                    width = 200,
                    height = 182,
                    frame_count = 1,
                    animation_speed = electric_drill_animation_speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(-5, 2),
                    repeat_count = 5,
                    scale = 0.5
                  }
                }
              }
            }
          },
          working_visualisations = {
            -- front frame
            {
              always_draw = true,
              north_animation = nil,
              east_animation =
              {
                priority = "high",
                filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-E-front.png",
                line_length = 1,
                width = 66,
                height = 74,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(22, 10),
                hr_version =
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-front.png",
                  line_length = 1,
                  width = 136,
                  height = 148,
                  frame_count = 1,
                  animation_speed = electric_drill_animation_speed,
                  direction_count = 1,
                  shift = util.by_pixel(21, 10),
                  scale = 0.5
                }
              },
              south_animation =
              {
                layers =
                {
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-S-output.png",
                    line_length = 5,
                    width = 44,
                    height = 28,
                    frame_count = 5,
                    animation_speed = electric_drill_animation_speed,
                    shift = util.by_pixel(-2, 34),
                    hr_version =
                    {
                      priority = "high",
                      filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-output.png",
                      line_length = 5,
                      width = 84,
                      height = 56,
                      frame_count = 5,
                      animation_speed = electric_drill_animation_speed,
                      shift = util.by_pixel(-1, 34),
                      scale = 0.5
                    }
                  },
                  {
                    priority = "high",
                    filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-S-front.png",
                    line_length = 1,
                    width = 96,
                    height = 54,
                    frame_count = 1,
                    animation_speed = electric_drill_animation_speed,
                    repeat_count = 5,
                    shift = util.by_pixel(0, 26),
                    hr_version =
                    {
                      priority = "high",
                      filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-front.png",
                      line_length = 1,
                      width = 190,
                      height = 104,
                      frame_count = 1,
                      animation_speed = electric_drill_animation_speed,
                      repeat_count = 5,
                      shift = util.by_pixel(0, 27),
                      scale = 0.5
                    }
                  }
                }
              },
              west_animation =
              {
                priority = "high",
                filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-W-front.png",
                line_length = 1,
                width = 68,
                height = 70,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-22, 12),
                hr_version =
                {
                  priority = "high",
                  filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-front.png",
                  line_length = 1,
                  width = 134,
                  height = 140,
                  frame_count = 1,
                  animation_speed = electric_drill_animation_speed,
                  direction_count = 1,
                  shift = util.by_pixel(-22, 12),
                  scale = 0.5
                }
              }
            },
          }
        },

        integration_patch = {
          north =
          {
            priority = "high",
            filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-N-integration.png",
            line_length = 1,
            width = 110,
            height = 108,
            frame_count = 1,
            animation_speed = electric_drill_animation_speed,
            direction_count = 1,
            shift = util.by_pixel(-2, 2),
            repeat_count = 5,
            hr_version =
            {
              priority = "high",
              filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-integration.png",
              line_length = 1,
              width = 216,
              height = 218,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(-1, 1),
              repeat_count = 5,
              scale = 0.5
            }
          },
          east =
          {
            priority = "high",
            filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-E-integration.png",
            line_length = 1,
            width = 116,
            height = 108,
            frame_count = 1,
            animation_speed = electric_drill_animation_speed,
            direction_count = 1,
            shift = util.by_pixel(4, 2),
            repeat_count = 5,
            hr_version =
            {
              priority = "high",
              filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-integration.png",
              line_length = 1,
              width = 236,
              height = 214,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(3, 2),
              repeat_count = 5,
              scale = 0.5
            }
          },
          south =
          {
            priority = "high",
            filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-S-integration.png",
            line_length = 1,
            width = 108,
            height = 114,
            frame_count = 1,
            animation_speed = electric_drill_animation_speed,
            direction_count = 1,
            shift = util.by_pixel(0, 4),
            repeat_count = 5,
            hr_version =
            {
              priority = "high",
              filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-integration.png",
              line_length = 1,
              width = 214,
              height = 230,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(0, 3),
              repeat_count = 5,
              scale = 0.5
            }
          },
          west =
          {
            priority = "high",
            filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-W-integration.png",
            line_length = 1,
            width = 118,
            height = 106,
            frame_count = 1,
            animation_speed = electric_drill_animation_speed,
            direction_count = 1,
            shift = util.by_pixel(-4, 2),
            repeat_count = 5,
            hr_version =
            {
              priority = "high",
              filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-integration.png",
              line_length = 1,
              width = 234,
              height = 214,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(-4, 1),
              repeat_count = 5,
              scale = 0.5
            }
          }
        },
    }
})