
local config = require("config")
local test_util = require("tests.util")
local script = require("scripts.escapables")

local escapables = {
    name = "escapables-period",

    number_of_biters = 1000,
    ticks_to_run = 60 * 60 * 60,
    game_speed = 1000,
    tick_started = nil,

    ---@type float percentage of escaped biters 
    tolerance = 0.10,

    biter_name = "behemoth-biter",
    machine_name = "bp-generator-reinforced",

    expected_escapes = nil,
    escaped_biters = 0,
}

---@param biter_names string[]
local function create_setup(biter_names)
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
    eei.power_production = 10e6 -- For the inserters
    eei.power_usage = 1e9

    ---@param biter_name string
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

    for _, biter_name in pairs(biter_names) do
        create_next(biter_name)
    end

end

function escapables.handle_command(args)
    if args[1] == "show" then
        local biter_names = {}
        for biter_name, _ in pairs(config.biter.types) do
            table.insert(biter_names, biter_name)
        end
        create_setup(biter_names)
    end
end

function escapables.test()

    -- Calculate how many biters we expect to escape
    local average_escape_time = math.floor(script.calculate_average_escape_time(
        escapables.biter_name,
        escapables.machine_name
    ))
    escapables.expected_escapes =
        escapables.ticks_to_run
        / average_escape_time
        * escapables.number_of_biters

    -- Create the setup
    local biter_names = { }
    for _=1,escapables.number_of_biters do
        table.insert(biter_names, escapables.biter_name)
    end
    create_setup(biter_names)

    -- Reset the counter
    escapables.escaped_biters = 0
    escapables.tick_started = game.tick
    game.speed = escapables.game_speed
    escapables.active = true
end

escapables.events = {
    ---@param event EventData.script_raised_built
    [defines.events.script_raised_built] = function(event)
        local entity = event.entity
        if entity.name ~= escapables.biter_name then return end

        -- Reset all machines in the vicinity to maximum health
        -- This won't prevent it from being damaged because it's applied
        -- only after this is called. However, this will restore it enough
        -- so that it is never destroyed.
        for _, machine in pairs(entity.surface.find_entities_filtered{
            position = entity.position,
            radius = 4,
            type = "burner-generator"
        }) do
            ---@cast machine LuaEntity
            machine.destructible = false
        end

        -- Handle!
        escapables.escaped_biters = escapables.escaped_biters + 1
        entity.die()
    end,

    ---@param event EventData.on_tick
    [defines.events.on_tick] = function (event)
        if game.tick > escapables.tick_started + escapables.ticks_to_run then
            -- Test is done!
            game.speed = 1

            local err = math.abs(escapables.expected_escapes - escapables.escaped_biters)
                    / escapables.expected_escapes
            local msg = "Escapables: Expected: "..escapables.expected_escapes.." Counted: "..escapables.escaped_biters.." (Error: "..math.floor(err*100).."%)"
            game.print(msg)
            if err > escapables.tolerance then error(msg) end

            escapables.active = false
        end
    end,
}

return escapables