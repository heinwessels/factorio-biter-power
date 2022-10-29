local config = require("config")
local sounds = require ("__base__.prototypes.entity.sounds")

data:extend({
    {
        type = "resource-category",
        name = "bp-biter-nest"
    },
    {
        type = "resource",
        name = "bp-buried-biter-nest",
        icons = {
          {
            icon = "__BiterPower__/graphics/buried-biter-nest/hole-icon.png",
            icon_size = 64,
          },
          {
            icon = "__BiterPower__/graphics/incubator/biter-egg.png",
            icon_size = 64, 
            icon_mipmaps = 4, 
            scale = 0.3,
            shift = {0, -5}
          }
        },
        flags = {"placeable-neutral"},
        category = "bp-biter-nest",
        subgroup = "raw-resource",
        order="a-b-a",  
        highlight = true,
        resource_patch_search_radius = 12,
        minable = {
          mining_time = config.buried_nest.mining_time,
          results = config.buried_nest.results,
        },
        walking_sound = sounds.oil,
        collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
        selection_box = {{-1.4, -1.4}, {1.4, 1.4}},
        stage_counts = {0},
        stages = {
            sheet = {
                filename = "__BiterPower__/graphics/buried-biter-nest/hole.png",
                priority = "extra-high",
                width = 166,
                height = 122,
                scale = 3/4,
                variation_count = 1,
                hr_version = {
                    filename = "__BiterPower__/graphics/buried-biter-nest/hr-hole.png",
                    priority = "extra-high",
                    width = 322,
                    height = 240,
                    scale = 0.5 * 3/4,
                    variation_count = 1,
                }
            }
        },
        map_color = {0.78, 0.2, 0.77},
        map_grid = false
    }
})