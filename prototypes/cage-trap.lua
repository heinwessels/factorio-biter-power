local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

data:extend{
    {
        type = "item",
        name = "bp-cage-trap",
        icon = "__biter-power__/graphics/cage-trap/icon.png",
        icon_size = 64,
        subgroup = "gun",
        order = "g[cage-trap]",
        place_result = "bp-cage-trap",
        stack_size = 100
    },
    {
        type = "recipe",
        name = "bp-cage-trap",
        enabled = false,
        energy_required = 5,
        ingredients =
        {
          {"bp-cage", 1},
          {"iron-gear-wheel", 20},
          {"iron-stick", 5}
        },
        result = "bp-cage-trap",
        result_count = 1
    },
    {
        type = "land-mine",
        name = "bp-cage-trap",
        icon = "__biter-power__/graphics/cage-trap/icon.png",
        icon_size = 64,
        flags = {
            "placeable-player",
            "placeable-enemy",
            "player-creation",
            "placeable-off-grid",
            "not-on-map"
        },
        minable = {mining_time = 0.5, result = "bp-cage-trap"},
        mined_sound = { filename = "__core__/sound/deconstruct-small.ogg" },
        max_health = 15,
        corpse = "land-mine-remnants",
        dying_explosion = "land-mine-explosion",
        collision_box = {{-0.9,-0.9}, {0.9, 0.9}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        damaged_trigger_effect = hit_effects.entity(),
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        picture_safe = {
            filename = "__biter-power__/graphics/cage-trap/hr-cage-trap.png",
            priority = "medium",
            width = 174,
            height = 161,
            scale = 0.5
        },
        picture_set = {
            filename = "__biter-power__/graphics/cage-trap/hr-cage-trap.png",
            priority = "medium",
            width = 174,
            height = 161,
            scale = 0.5
        },
        picture_set_enemy = {
            filename = "__biter-power__/graphics/cage-trap/hr-cage-trap.png",
            priority = "medium",
            width = 174,
            height = 161,
            scale = 0.5
        },
        trigger_radius = 3.5,
        ammo_category = "landmine",
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
                        effect_id = "bp-cage-trap-trigger"
                    },
                    {
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
    }
}