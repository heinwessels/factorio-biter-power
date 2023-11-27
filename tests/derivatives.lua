
local config = require("config")
local test_util = require("tests.util")

local derivates = { }

local function show_derivatives()
    local size = 4  -- of machines
    local offset = 3
    local x = 0
    local y = 0

    local N = #config.biter.types + 2
    local w = 10 * (offset + offset)

    local surface = test_util.get_test_surface()
    if not surface then error("Could not create surface") end

    ---@diagnostic disable-next-line: missing-fields
    surface.create_entity{name = "solar-panel", position = {0, -4.5}, force = "player" }
    local eei = surface.create_entity{name = "electric-energy-interface", position = {-7, 0}, force = "player" }
    eei.power_production = 10e3 -- For the inserters
    eei.power_usage = 1e9

    local function create_next(biter_name)
        local machine = surface.create_entity {
            name = "bp-generator-reinforced",
            position = {x, y},
            force = "player",
            raise_built = true,
        }

        biter_name = biter_name or "empty"
        rendering.draw_text {
            text = biter_name,
            target = {x - offset + 1, y + offset - 1},
            surface = surface,
            color = {r = 0.5, a = 1},
            scale = 1.5,
        }

        -- Source chest
        local chest_pos = {x - offset - 0.5, y + 0.5}
        local chest = surface.create_entity{name = "infinity-chest", position = chest_pos, force = "player" }
        chest.infinity_container_filters = { { name = "bp-caged-"..biter_name, count = 1, mode = "at-least" , index = 1} }
        surface.create_entity{name = "inserter", position = {chest_pos[1] + 1, chest_pos[2]}, direction = defines.direction.west, force = "player" }
        
        -- Electric pole
        surface.create_entity{name = "medium-electric-pole", position = {chest_pos[1], chest_pos[2] - 2}, force = "player" }
        
        -- Dump chest
        chest_pos[2] = chest_pos[2] - 1
        chest = surface.create_entity{name = "infinity-chest", position = chest_pos, force = "player" }
        chest.infinity_container_filters = { { name = "bp-tired-caged-"..biter_name, count = 1, mode = "at-most" , index = 1} }
        surface.create_entity{name = "inserter", position = {chest_pos[1] + 1, chest_pos[2]}, direction = defines.direction.east, force = "player" }    
        
        -- Update the position
        x = x + size + offset
        if x > w then x = 0; y = y + size + offset end
    end

    for biter_name, _ in pairs(config.biter.types) do
        create_next(biter_name)
    end

end

function derivates.handle_command(args)
    if args[1] == "show" then
        show_derivatives()
    end
end

return derivates