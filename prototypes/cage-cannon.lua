if not config then error("No config found!") end
local sounds = require("__base__.prototypes.entity.sounds")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local util = require("util")

local min_range = 2
local max_range = 15
local cooldown = 120

data:extend {
    {
        type = "item",
        name = "bp-cage-cannon",
        icon = "__biter-power__/graphics/cage-cannon/icon.png",
        icon_size = 64,
        subgroup = "bp-husbandry-intermediates",
        order = "e[cage-cannon]",
        place_result = "bp-cage-cannon",
        stack_size = 10
    },
    {
        type = "recipe",
        name = "bp-cage-cannon",
        energy_required = 10,
        ingredients = {
            {"steel-plate", 8},
            {"stone-brick", 5},
            {"iron-gear-wheel", 10},
        },
        result = "bp-cage-cannon",
    },
    {
        type = "ammo-category",
        name = "bp-cage-projectile",
    },
    {
        type = "recipe",
        name = "bp-cage-projectile",
        enabled = false,
        energy_required = 5,
        ingredients = {
          {"bp-cage", 1},
          {"explosives", 1}
        },
        result = "bp-cage-projectile",
        result_count = 1
    },
    {
        -- We need this to only shoot at biters that can be caged.
        -- And more importantly, not the nests.
        type = "trigger-target-type",
        name = "bp-cagable",
    },
    {
        type = "ammo",
        name = "bp-cage-projectile",
        icons = {
            {
                icon = "__biter-power__/graphics/cage/icon.png",
                icon_size = 64,
            },
            {
                icon = "__base__/graphics/icons/explosives.png",
                icon_size = 64, icon_mipmaps = 4,
                scale = 0.35, shift = { -7, -7 },
            },
        },
        subgroup = "bp-husbandry-intermediates",
        order = "d[cage-cannon-projectile]",
        magazine_size = 1,
        stack_size = 5,
        reload_time = cooldown,
        ammo_type = {
            cooldown = cooldown,
            category = "bp-cage-projectile",
            action = {
                type = "direct",
                action_delivery = {
                    type = "projectile",
                    projectile = "bp-cage-projectile-entity",
                    starting_speed = 0.8,
                    min_range = min_range,
                    max_range = max_range,
                    source_effects = {
                        type = "create-entity",
                        entity_name = "explosion-hit"
                    }
                }
            }
        },
    },
    {
        type = "projectile",
        name = "bp-cage-projectile-entity",
        flags = {"not-on-map"},
        acceleration = 0,
        rotatable = true,
        -- Technically we don't want this, but I got it in weird positions
        -- where it would continually miss a biter standing still while attacking
        -- a wall. The projectile still moves so fast though that you barely see
        -- the homing behaviour, so meh. Keeping this.
        turn_speed = 0.005,
        action = {
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
        },
        animation = {
            filename = "__biter-power__/graphics/cage/icon.png",
            draw_as_glow = true,
            frame_count = 1,
            line_length = 1,
            width = 64,
            height = 64,
            scale = 0.3,
            shift = {0, 0},
            priority = "high"
        },
        shadow =  {
            filename = "__biter-power__/graphics/cage/icon.png",
            draw_as_shadow = true,
            frame_count = 1,
            line_length = 1,
            width = 64,
            height = 64,
            scale = 0.3,
            shift = {0, 0},
            priority = "high"
        },
        smoke = {{
            name = "smoke-fast",
            deviation = {0.15, 0.15},
            frequency = 1,
            position = {0, 1},
            slow_down_factor = 1,
            starting_frame = 3,
            starting_frame_deviation = 5,
            starting_frame_speed = 0,
            starting_frame_speed_deviation = 5
        }}
    },
}

local cannon_scale = 0.65
local cannon_shift = {0, -0.5}
local cannon_shadow_shift = util.add_shift(cannon_shift, {-0.5, -0.5})

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
        minable = {mining_time = 0.5, result = "bp-cage-cannon"},
        max_health = 400,
        is_military_target = true, -- So that biters attack it!
        corpse = "gun-turret-remnants",
        dying_explosion = "gun-turret-explosion",
        collision_box = {{-0.7, -0.7 }, {0.7, 0.7}},
        selection_box = {{-1, -1 }, {1, 1}},
        damaged_trigger_effect = hit_effects.entity(),
        rotation_speed = 0.004,
        inventory_size = 1,
        automated_ammo_count = 2, -- Prevents the intermittent out-of-ammo icon
        attack_target_mask = {"bp-cagable"},
        alert_when_attacking = true,
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        folded_animation = { layers = {
            -- We don't need HR resolution, because the artillery-cannon will basically be HR
            -- already, because I need to almost scale it to half it's resolution. Now it actually
            -- looks a little weird with normal resolution because the cage-cannon's turret is
            -- higher resolution than the other sprites.
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
                shift = util.add_shift(util.mul_shift(util.by_pixel(54+58, -1+46), cannon_scale), cannon_shadow_shift),
                stripes = create_stripes{
                    -- Technically the in these shadow sprites the barrel is too long. 
                    -- Doubt anyone will notice though, so will keep it like this for now.
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
            {
                filename = "__biter-power__/graphics/cage-cannon/base-shadow.png",
                width = 126,
                height = 62,
                shift = util.by_pixel(19, 2),
                axially_symmetrical = false,
                draw_as_shadow = true,
                hr_version = {
                    filename = "__biter-power__/graphics/cage-cannon/hr-base-shadow.png",
                    width = 250,
                    height = 124,
                    shift = util.by_pixel(19, 2.5),
                    axially_symmetrical = false,
                    draw_as_shadow = true,
                    scale = 0.5
                }
            },
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
            cooldown = cooldown,
            projectile_creation_distance = 1.8,
            projectile_center = {0, -0.25},
            min_range = min_range,
            range = max_range,
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

-- We need to add the target mask to all the biters we support.
for biter_name, biter_config in pairs(config.biter.types) do
    local unit = data.raw.unit[biter_name]
    if not unit then error("No '"..biter_name.."' unit found!") end
    unit.trigger_target_mask = {"bp-cagable"}
end