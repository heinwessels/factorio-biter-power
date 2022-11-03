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


for _, spawner_name in pairs{"biter-spawner", "spitter-spawner"} do
  local spawner = data.raw["unit-spawner"][spawner_name]
  
  -- Add trigger effect to spawners to have a chance
  -- to create buried biter nest on death
  spawner.dying_trigger_effect = spawner.dying_trigger_effect or {}
  table.insert(spawner.dying_trigger_effect, {
    type = "create-entity",
    entity_name = "bp-buried-biter-nest",
    probability = config.buried_nest.spawn_chance,

    -- Need some way to clear the corpse later because
    -- it doesn't exist when these triggers fire
    trigger_created_entity = true,
  })
  spawner.localised_description = {"bp-text.spawner-description", string.format("%.0f", config.buried_nest.spawn_chance*100)}

  -- Also add a chance for some eggs to drop on any spawner kill 
  spawner.loot = spawner.spawner or {}
  table.insert(spawner.loot, {item = "bp-biter-egg", probability=0.5})
  table.insert(spawner.loot, {item = "bp-biter-egg", probability=0.1})



end