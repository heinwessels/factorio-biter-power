local sounds = require ("__base__.prototypes.entity.sounds")

data:extend({
    {
        type = "resource-category",
        name = "bp-biter-nest"
    },
    {
        type = "resource",
        name = "bp-buried-biter-nest",
        icon = "__BiterPower__/graphics/incubator/biter-egg.png",
        icon_size = 64, icon_mipmaps = 4, 
        flags = {"placeable-neutral"},
        category = "bp-biter-nest",
        subgroup = "raw-resource",
        order="a-b-a",
        infinite = true,
        highlight = true,
        minimum = 60000,
        normal = 300000,
        infinite_depletion_amount = 10,
        resource_patch_search_radius = 12,
        minable =
        {
          mining_time = 1,
          results =
          {
            {
              name = "bp-biter-egg",
              amount_min = 10,
              amount_max = 10,
              probability = 1
            }
          }
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