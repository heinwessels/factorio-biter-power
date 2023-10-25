local sounds = require("__base__.prototypes.entity.sounds")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local util = require("util")

-- TODO Should only target biters!

data:extend {
    {
        type = "item",
        name = "bp-cage-cannon",
        icon = "__base__/graphics/icons/gun-turret.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "bp-biter-machines",
        order = "a[biter-egg-extractor]",
        place_result = "bp-cage-cannon",
        stack_size = 10
    },
    {
        type = "recipe",
        name = "bp-cage-cannon",
        ingredients = {
            {"steel-plate", 8},
            {"stone-brick", 5},
            {"iron-gear-wheel", 10},
        },
        result = "bp-egg-extractor",
    },
    {
        type = "ammo-category",
        name = "bp-cage-projectile",
    },
    {
        type = "ammo",
        name = "bp-cage-projectile",
        icon = "__biter-power__/graphics/cage/icon.png",
        subgroup = "bp-biter-machines",
        icon_size = 64,
        magazine_size = 1,
        stack_size = 1,
        ammo_type = {
            category = "bp-cage-projectile",
            target_type = "position",
            action = {
                type = "direct",
                action_delivery = {
                    type = "artillery",
                    projectile = "artillery-projectile",
                    starting_speed = 1,
                    direction_deviation = 0,
                    range_deviation = 0,
                    source_effects = {
                        type = "create-explosion",
                        entity_name = "artillery-cannon-muzzle-flash"
                    }
                }
            }
        },
    },
    {
        type = "recipe",
        name = "bp-cage-projectile",
        enabled = false,
        energy_required = 5,
        ingredients = {
          {"bp-cage", 1},
          -- Something needed here
        },
        result = "bp-cage-projectile",
        result_count = 1
    },
    -- {
    --     name = "bp-cage-cannon",
    --     type = "ammo-turret",
    --     icon = "__base__/graphics/icons/gun-turret.png",
    --     icon_size = 64, icon_mipmaps = 4,
    --     flags = {"placeable-player", "player-creation"},
    --     minable = {mining_time = 0.5, result = "gun-turret"},
    --     max_health = 400,
    --     corpse = "gun-turret-remnants",
    --     dying_explosion = "gun-turret-explosion",
    --     collision_box = {{-0.7, -0.7 }, {0.7, 0.7}},
    --     selection_box = {{-1, -1 }, {1, 1}},
    --     damaged_trigger_effect = hit_effects.entity(),
    --     rotation_speed = 0.015,
    --     preparing_speed = 0.08,
    --     preparing_sound = sounds.gun_turret_activate,
    --     folding_sound = sounds.gun_turret_deactivate,
    --     folding_speed = 0.08,
    --     inventory_size = 1,
    --     automated_ammo_count = 10,
    --     attacking_speed = 0.5,
    --     alert_when_attacking = true,
    --     open_sound = sounds.machine_open,
    --     close_sound = sounds.machine_close,
    --     folded_animation = {
    --         layers = {
    --             -- gun_turret_extension{frame_count=1, line_length = 1},
    --             -- gun_turret_extension_mask{frame_count=1, line_length = 1},
    --             -- gun_turret_extension_shadow{frame_count=1, line_length = 1}
    --         }
    --     },
    --     preparing_animation = {
    --         layers = {
    --             -- gun_turret_extension{},
    --             -- gun_turret_extension_mask{},
    --             -- gun_turret_extension_shadow{}
    --         }
    --     },
    --     -- prepared_animation = gun_turret_attack{frame_count=1},
    --     -- attacking_animation = gun_turret_attack{},
    --     folding_animation = {
    --         layers = {
    --             -- gun_turret_extension{run_mode = "backward"},
    --             -- gun_turret_extension_mask{run_mode = "backward"},
    --             -- gun_turret_extension_shadow{run_mode = "backward"}
    --         }
    --     },
    --     base_picture = {
    --         layers = {
    --             {
    --                 filename = "__base__/graphics/entity/gun-turret/gun-turret-base.png",
    --                 priority = "high",
    --                 width = 76,
    --                 height = 60,
    --                 axially_symmetrical = false,
    --                 direction_count = 1,
    --                 frame_count = 1,
    --                 shift = util.by_pixel(1, -1),
    --                 hr_version = {
    --                     filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-base.png",
    --                     priority = "high",
    --                     width = 150,
    --                     height = 118,
    --                     axially_symmetrical = false,
    --                     direction_count = 1,
    --                     frame_count = 1,
    --                     shift = util.by_pixel(0.5, -1),
    --                     scale = 0.5
    --             }
    --             },
    --             --{
    --             --  filename = "__base__/graphics/entity/gun-turret/gun-turret-base-shadow.png",
    --             --  line_length = 1,
    --             --  width = 78,
    --             --  height = 62,
    --             --  axially_symmetrical = false,
    --             --  direction_count = 1,
    --             --  frame_count = 1,
    --             --  shift = util.by_pixel(5, 3),
    --             --  draw_as_shadow = true,
    --             --  hr_version =
    --             --  {
    --             --    filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-base-shadow.png",
    --             --    line_length = 1,
    --             --    width = 154,
    --             --    height = 122,
    --             --    axially_symmetrical = false,
    --             --    direction_count = 1,
    --             --    frame_count = 1,
    --             --    shift = util.by_pixel(5, 2.5),
    --             --    draw_as_shadow = true,
    --             --    scale = 0.5
    --             --  }
    --             --},
    --             {
    --                 filename = "__base__/graphics/entity/gun-turret/gun-turret-base-mask.png",
    --                 flags = { "mask", "low-object" },
    --                 line_length = 1,
    --                 width = 62,
    --                 height = 52,
    --                 axially_symmetrical = false,
    --                 direction_count = 1,
    --                 frame_count = 1,
    --                 shift = util.by_pixel(0, -4),
    --                 apply_runtime_tint = true,
    --                 hr_version = {
    --                     filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-base-mask.png",
    --                     flags = { "mask", "low-object" },
    --                     line_length = 1,
    --                     width = 122,
    --                     height = 102,
    --                     axially_symmetrical = false,
    --                     direction_count = 1,
    --                     frame_count = 1,
    --                     shift = util.by_pixel(0, -4.5),
    --                     apply_runtime_tint = true,
    --                     scale = 0.5
    --                 }
    --             }
    --         }
    --     },
    --     vehicle_impact_sound = sounds.generic_impact,

    --     attack_parameters = {
    --         type = "projectile",
    --         ammo_category = "bullet",
    --         cooldown = 6,
    --         projectile_creation_distance = 1.39375,
    --         projectile_center = {0, -0.0875}, -- same as gun_turret_attack shift
    --         shell_particle = {
    --             name = "shell-particle",
    --             direction_deviation = 0.1,
    --             speed = 0.1,
    --             speed_deviation = 0.03,
    --             center = {-0.0625, 0},
    --             creation_distance = -1.925,
    --             starting_frame_speed = 0.2,
    --             starting_frame_speed_deviation = 0.1
    --         },
    --         range = 18,
    --         sound = sounds.gun_turret_gunshot
    --     },

    --     call_for_help_radius = 40,
    --     water_reflection = {
    --         pictures = {
    --             filename = "__base__/graphics/entity/gun-turret/gun-turret-reflection.png",
    --             priority = "extra-high",
    --             width = 20,
    --             height = 32,
    --             shift = util.by_pixel(0, 40),
    --             variation_count = 1,
    --             scale = 5
    --         },
    --         rotate = false,
    --         orientation_to_variation = false
    --     }
    -- },
}


local cannon = table.deepcopy(data.raw["ammo-turret"]["gun-turret"])
if not cannon then error("Couldn't find turret") end
cannon.name = "bp-cage-cannon"
cannon.attack_parameters.ammo_category = "bp-cage-projectile"

data:extend { cannon }
