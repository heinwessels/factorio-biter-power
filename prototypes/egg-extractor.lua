-- Holy moly mining-drills are complicated!
local config = require("config")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local shift = {x=-0, y=-0.5} -- Because getting that glow aligned was awful
data:extend({
    {
        type = "item",
        name = "bp-egg-extractor",
        icon = "__biter-power__/graphics/egg-extractor/icon.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "bp-biter-machines",
        order = "a[biter-egg-extractor]",
        place_result = "bp-egg-extractor",
        stack_size = 20
    },
    {
        type = "recipe",
        name = "bp-egg-extractor",
        icon_size = 64, icon_mipmaps = 4,
        ingredients = {
            {"steel-plate", 8},
            {"stone-brick", 5},
            {"iron-gear-wheel", 10},
        },
        result = "bp-egg-extractor"
    },
    {
        type = "mining-drill",
        name = "bp-egg-extractor",
        icon = "__biter-power__/graphics/egg-extractor/icon.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.3, result = "bp-egg-extractor"},
        max_health = 300,
        resource_categories = {"bp-biter-nest"},
        corpse = "electric-mining-drill-remnants",
        dying_explosion = "electric-mining-drill-explosion",
        collision_box = {{ -1.4, -1.4}, {1.4, 1.4}},
        selection_box = {{ -1.5, -1.5}, {1.5, 1.5}},
        damaged_trigger_effect = hit_effects.entity(),
        working_sound = {
          sound = { 
            allow_random_repeat = true,
            aggregation = {
              max_count = 1,
              remove = true,
            },
            variations = {
              {
                filename = "__base__/sound/centrifuge-1.ogg",
                volume = 0.3
              },
              {
                filename = "__base__/sound/centrifuge-2.ogg",
                volume = 0.3
              },
              {
                filename = "__base__/sound/centrifuge-6.ogg",
                volume = 0.3
              }
            }
          },
          fade_in_ticks = 4,
          fade_out_ticks = 20,
        },
        vehicle_impact_sound = sounds.generic_impact,
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        mining_speed = config.relocation_center.mining_speed,
        energy_source = {
          type = "electric",
          usage_priority = "secondary-input",

          -- This number should be big. For example a mining patch with 100 miners
          -- release 1000 pollution per minute. This should be worse, and there's 
          -- usually only one.
          emissions_per_minute = 2000,
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
                      filename = "__biter-power__/graphics/egg-extractor/hr-center-glow.png",
                      priority = "high",
                      blend_mode = "additive",
                      animation_speed = 0.5,
                      line_length = 8,
                      frame_count = 64,
                      -- width = 55,
                      -- height = 98,
                      width = 108,
                      height = 197,
                      scale = 0.5 * 1.5,
                      shift = {0.03 + shift.x, -0.24 + shift.y},
                      hr_version = {
                          filename = "__biter-power__/graphics/egg-extractor/hr-center-glow.png",
                          priority = "high",
                          blend_mode = "additive",
                          animation_speed = 0.5,
                          line_length = 8,
                          frame_count = 64,
                          width = 108,
                          height = 197,
                          scale = 0.5 * 1.5,
                          shift = {0.03 + shift.x, -0.24 + shift.y},
                      }
                  }
              }}
            }
          },
          always_draw_idle_animation = true,
          idle_animation = {
              layers = {
                  {
                    filename = "__biter-power__/graphics/egg-extractor/hr-hole-front.png",
                    priority = "extra-high",
                    animation_speed = 0.5,
                    width = 322,
                    height = 300,
                    scale = 0.5 * 3/4,
                    repeat_count = 64,
                    shift = {0.25, -0.5},
                    hr_version = {
                        filename = "__biter-power__/graphics/egg-extractor/hr-hole-front.png",
                        priority = "extra-high",
                        animation_speed = 0.5,
                        width = 322,
                        height = 300,
                        scale = 0.5 * 3/4,
                        repeat_count = 64,
                        shift = {0.25, -0.5},
                    }
                  },
                  {
                      filename = "__biter-power__/graphics/egg-extractor/hr-center.png",
                      priority = "high",
                      animation_speed = 0.5,
                      line_length = 8,
                      frame_count = 64,
                      -- width = 70,
                      -- height = 123,
                      -- scale = 1.5,
                      -- shift = {0 + shift.x, -1 + shift.y},
                      width = 139,
                      height = 246,
                      scale = 0.5 * 1.5,
                      shift = {-0.1 + shift.x, 0 + shift.y},
                      hr_version = {
                        filename = "__biter-power__/graphics/egg-extractor/hr-center.png",
                        priority = "high",
                        line_length = 8,
                        animation_speed = 0.5,
                        frame_count = 64,
                        width = 139,
                        height = 246,
                        scale = 0.5 * 1.5,
                        shift = {-0.1 + shift.x, 0 + shift.y},
                      }
                  },
                  {
                      filename = "__biter-power__/graphics/egg-extractor/hr-center-shadow.png",
                      draw_as_shadow = true,
                      priority = "high",
                      line_length = 8,
                      frame_count = 64,
                      -- width = 108,
                      -- height = 54,
                      -- scale = 1.4,
                      -- shift = {1.5 + shift.x, 0 + shift.y},
                      width = 163,
                      height = 123,
                      scale = 0.5 * 1.4,
                      shift = {1.5 + shift.x, 0 + shift.y},
                      hr_version = {
                        filename = "__biter-power__/graphics/egg-extractor/hr-center-shadow.png",
                        draw_as_shadow = true,
                        priority = "high",
                        line_length = 8,
                        frame_count = 64,
                        width = 163,
                        height = 123,
                        scale = 0.5 * 1.4,
                        shift = {1.5 + shift.x, 0 + shift.y},
                      }
                  },
              },
          },
        },
    }
})