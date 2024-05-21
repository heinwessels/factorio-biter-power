if not config then error("No config found!") end
local sounds = require("__base__/prototypes/entity/sounds")

local pulping_crafting_categories = {}

-- create recipes for revitilization
for tier = 1, config.biter.max_tier do
    table.insert(pulping_crafting_categories, "bp-pulping-tier-"..tier)

    data:extend{
        {
            type = "recipe-category",
            name = "bp-pulping-tier-"..tier,
        },
        {
            type = "item-subgroup",
            name = "bp-pulping-tier-"..tier,
            group = "biter-power-husbandry",
            order = "[b]-[tier-"..tier.."]-[b]"
        }
    }
end

data:extend({
    {
        type = "item",
        name = "bp-pulper",
        icon = "__biter-power__/graphics/pulper/icon.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "bp-biter-machines",
        order = "d[biter-pulper]",
        place_result = "bp-pulper",
        stack_size = 20
    },
    {
        type = "recipe",
        name = "bp-pulper",
        icon_size = 64, icon_mipmaps = 4,
        energy_required = 5,
        ingredients = {
            {"electric-engine-unit", 30},
            {"advanced-circuit", 10},
            {"iron-gear-wheel", 15},
        },
        enabled = false,
        result = "bp-pulper"
    },
    {
        name = "bp-pulper",
        type = "assembling-machine",
        localised_description = {"",
            {"entity-description.bp-pulper"},
            {"bp-text.escape-modifier", config.escapes.escapable_machine["bp-pulper"]},
        },
        icon = "__biter-power__/graphics/pulper/icon.png",
        icon_size = 64,
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {
            mining_time = 0.5,
            result = "bp-pulper"
        },
        max_health = 300,
        is_military_target = true, -- So that biters attack it!
        corpse = "big-remnants",
        dying_explosion = "medium-explosion",
        collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        crafting_categories = pulping_crafting_categories,
        crafting_speed = 1,
        energy_source = {
            type = 'electric',
            usage_priority = 'secondary-input',
        },
        energy_usage = config.pulper.power_usage .. "W",
        animation = {
            filename = "__biter-power__/graphics/pulper/pulper.png",
            size = {512,512},
            width = 512,
            height = 512,
            shift = {0,-0.2},
	        scale = 0.44/2,
            line_length = 1,
            frame_count = 1,
        },
        fast_replaceable_group = "ei_crusher",
        allowed_effects = {"speed", "productivity", "consumption", "pollution"},
        -- module_specification = {
        --     module_slots = 2
        -- },
        fluid_boxes = {
            {
                production_type = "output",
                pipe_picture = assembler3pipepictures(),
                pipe_covers = pipecoverspictures(),
                base_area = 10,
                base_level = 1,
                pipe_connections = {{ type="output", position = {0, 2} }},
                secondary_draw_orders = { north = -1 }
            },
        },
        working_visualisations = {
            {
              animation =  {
                filename = "__biter-power__/graphics/pulper/pulper-animation.png",
                size = {512,512},
                width = 512,
                height = 512,
                shift = {0,-0.2},
	            scale = 0.44/2,
                line_length = 4,
                lines_per_file = 4,
                frame_count = 16,
                animation_speed = 0.3,
                run_mode = "backward",
              }
            },
            {
                light = {
                    type = "basic",
                    intensity = 1,
                    size = 15
                }
            }
        },
        working_sound =
        {
            sound = {filename = "__base__/sound/electric-mining-drill.ogg", volume = 0.8},
            apparent_volume = 0.3,
        },
    },
})

---@param name string
---@param args {biter_config:table, unit:data.UnitPrototype, energy_required:int, icons:data.IconData}
---@param tired boolean?
---@return data.RecipePrototype
local function create_pulping_recipe(name, args, tired)
    local tier = args.biter_config.tier
    local caged_name = (tired and "tired-" or "").."caged-"..name
    local item = data.raw.item["bp-"..caged_name] --[[@as data.ItemPrototype? ]]
    assert(item, "Item for '".."bp-"..caged_name.."' not found!")
    return {
        type = "recipe",
        name = "bp-pulping-"..caged_name,
        localised_name = {"bp-text.pulping", tired and {"bp-text.tired-biter", {"entity-name."..name}} or {"entity-name."..name}},
        icons = args.icons,
        hide_from_player_crafting = true,
        show_amount_in_title = false,
        always_show_products = true,
        subgroup = "bp-pulping-tier-"..tier,
        category =  "bp-pulping-tier-"..tier,
        order = "c[pulping]-["..args.unit.order:sub(-1).."]-["..name.."]",
        ingredients = {{"bp-"..caged_name, 1}},
        energy_required = math.ceil(5 * math.sqrt(tier) + 1),
        results = {
            { type = "fluid", name = "heavy-oil", amount = math.ceil((0.8 * tier + 5) * 5 )},
            { type = "item", name = "bp-cage", amount = 1 },
        },
        crafting_machine_tint = {
            primary = args.biter_config.tint,
        },
        enabled = false,
    } --[[@as data.RecipePrototype ]]
end

for biter_name, biter_config in pairs(config.biter.types) do
    local unit = data.raw.unit[biter_name] -- Should exist, have checked already

    local icons = util.copy(biter_config.icons)
    table.insert(icons, 1, {
        icon = "__biter-power__/graphics/pulper/icon.png",
        icon_size = 64, icon_mipmaps = 4,
    })

    local config = {
        biter_config = biter_config,
        unit = unit,
        icons = icons,
    }

    data:extend{ create_pulping_recipe(biter_name, config) }
    data:extend{ create_pulping_recipe(biter_name, config, true) }
end
