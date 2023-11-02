local sounds = require("__base__.prototypes.entity.sounds")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local util = require("util")

-- TODO Should only target biters!
-- TODO HR graphics
-- TODO Cannon shadow?
-- TODO Base shadow?

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
            target_type = "entity",
            action = {
                -- Action is the same as the cage trap

                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        {
                            -- Cannot drop item-on-ground with triggers.
                            -- Also would need a custom collision to only trigger for biters
                            -- So handling by script. Should be fine though, not doing much,
                            -- and currently not allowing placing this as a ghost
                            type = "script",
                            effect_id = "bp-cage-trap-trigger",
                            affects_target = true,
                        },
                        {
                            -- TODO Can this be better? I only want the particle effects, not
                            -- the explosion itself.
                            type = "create-entity",
                            entity_name = "electric-mining-drill-explosion"
                        },
                        {
                            type = "damage",
                            damage = { amount = 100, type = "physical"}
                        }
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
}

local cannon_scale = 0.62
local cannon_shift = {0, -0.25}

local function create_stripes(names)
    stripes = { }
    for _, name in pairs(names) do
        table.insert(stripes, {
            filename = name,
            width_in_frames = 4,
            height_in_frames = 4,
        })
    end
    return stripes
end

data:extend{
    {
        name = "bp-cage-cannon",
        type = "ammo-turret",
        icon = "__base__/graphics/icons/gun-turret.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"placeable-player", "player-creation"},
        minable = {mining_time = 0.5, result = "gun-turret"},
        max_health = 400,
        corpse = "gun-turret-remnants",
        dying_explosion = "gun-turret-explosion",
        collision_box = {{-0.7, -0.7 }, {0.7, 0.7}},
        selection_box = {{-1, -1 }, {1, 1}},
        damaged_trigger_effect = hit_effects.entity(),
        rotation_speed = 0.004,
        inventory_size = 1,
        automated_ammo_count = 10,
        alert_when_attacking = true,
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        folded_animation = { layers = {
            {
                width = 180,
                height = 136,
                line_length = 4,
                lines_per_file = 4,
                direction_count = 256,
                scale = cannon_scale,
                shift =  util.add_shift(util.mul_shift(util.by_pixel(0, -40), cannon_scale), cannon_shift),
                stripes = create_stripes{
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-1.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-2.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-3.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-4.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-5.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-6.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-7.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-8.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-9.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-10.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-11.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-12.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-13.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-14.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-15.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-16.png"
                }
            },
            {
                priority = "very-low",
                width = 238,
                height = 170,
                direction_count = 256,
                line_length = 4,
                lines_per_file = 4,                
                draw_as_shadow = true,
                scale = cannon_scale,
                shift = util.add_shift(util.mul_shift(util.by_pixel(54+58, -1+46), cannon_scale), cannon_shift),
                stripes = create_stripes{
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-1.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-2.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-3.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-4.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-5.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-6.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-7.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-8.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-9.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-10.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-11.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-12.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-13.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-14.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-15.png",
                    "__base__/graphics/entity/artillery-wagon/artillery-wagon-cannon-base-shadow-16.png"
                }
            },
        }},
        base_picture = { layers = {
            {
                filename = "__base__/graphics/entity/gun-turret/gun-turret-base.png",
                priority = "high",
                width = 76,
                height = 60,
                axially_symmetrical = false,
                direction_count = 1,
                frame_count = 1,
                shift = util.by_pixel(1, -1),
                hr_version = {
                    filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-base.png",
                    priority = "high",
                    width = 150,
                    height = 118,
                    axially_symmetrical = false,
                    direction_count = 1,
                    frame_count = 1,
                    shift = util.by_pixel(0.5, -1),
                    scale = 0.5
                }
            },
            -- {
            --     filename = "__base__/graphics/entity/gun-turret/gun-turret-base-shadow.png",
            --     line_length = 1,
            --     width = 78,
            --     height = 62,
            --     axially_symmetrical = false,
            --     direction_count = 1,
            --     frame_count = 1,
            --     shift = util.by_pixel(5, 3),
            --     draw_as_shadow = true,
            --     hr_version = {
            --         filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-base-shadow.png",
            --         line_length = 1,
            --         width = 154,
            --         height = 122,
            --         axially_symmetrical = false,
            --         direction_count = 1,
            --         frame_count = 1,
            --         shift = util.by_pixel(5, 2.5),
            --         draw_as_shadow = true,
            --         scale = 0.5
            --     }
            -- },
            {
                filename = "__base__/graphics/entity/gun-turret/gun-turret-base-mask.png",
                flags = { "mask", "low-object" },
                line_length = 1,
                width = 62,
                height = 52,
                axially_symmetrical = false,
                direction_count = 1,
                frame_count = 1,
                shift = util.by_pixel(0, -4),
                tint = {107, 102, 80, 128},
                hr_version = {
                    filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-base-mask.png",
                    flags = { "mask", "low-object" },
                    line_length = 1,
                    width = 122,
                    height = 102,
                    axially_symmetrical = false,
                    direction_count = 1,
                    frame_count = 1,
                    shift = util.by_pixel(0, -4.5),
                    tint = {107, 102, 80, 128},
                    scale = 0.5
                }
            }
        }},
        vehicle_impact_sound = sounds.generic_impact,

        attack_parameters = {
            type = "projectile",
            ammo_category = "bp-cage-projectile",
            cooldown = 6,
            projectile_creation_distance = 1.39375,
            projectile_center = {0, -0.0875}, -- same as gun_turret_attack shift
            shell_particle = {
                name = "shell-particle",
                direction_deviation = 0.1,
                speed = 0.1,
                speed_deviation = 0.03,
                center = {-0.0625, 0},
                creation_distance = -1.925,
                starting_frame_speed = 0.2,
                starting_frame_speed_deviation = 0.1
            },
            range = 18,
            sound = sounds.gun_turret_gunshot
        },

        call_for_help_radius = 40,
        water_reflection = {
            pictures = {
                filename = "__base__/graphics/entity/gun-turret/gun-turret-reflection.png",
                priority = "extra-high",
                width = 20,
                height = 32,
                shift = util.by_pixel(0, 40),
                variation_count = 1,
                scale = 5
            },
            rotate = false,
            orientation_to_variation = false
        }
    },
}
