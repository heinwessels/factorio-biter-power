local config = require("config")

-- Based on Editor Extensions. Thanks Raiguard!
local function get_test_surface()

    local empty_map_gen_settings = {
        default_enable_all_autoplace_controls = false,
        property_expression_names = { cliffiness = 0 },
        autoplace_settings = {
              tile = { settings = { ["out-of-map"] = { frequency = "normal", size = "normal", richness = "normal" } } },
        },
        starting_area = "none",
        width = 0,
        height = 0,
    }
      
    
    local surface_name = "bp-test-surface"
    local surface = game.get_surface(surface_name)
    if not surface then
        surface = game.create_surface(surface_name, empty_map_gen_settings)
        if not surface then
            player.print("Could not create test surface")
            return
        end

        surface.generate_with_lab_tiles = true
        surface.freeze_daytime = true
        surface.show_clouds = false
        surface.daytime = 0
    end

    -- Clear the surface. Can't use surface.clear because that removes the chunks
    -- as well, which acts weird when placing entities on them now.
    for _, entity in pairs(surface.find_entities_filtered{force = "player"}) do
        entity.destroy { raise_destroy = true }
    end

    rendering.clear("biter-power")

    -- Move the players there. All of them. I don't care. This is a test!
    for _, player in pairs(game.connected_players) do
        player.teleport({-10, -10}, surface)
    end

    return surface
end

local function show_derivatives()
    local size = 4  -- of machines
    local offset = 3
    local x = 0
    local y = 0

    local N = #config.biter.types + 2
    local w = 10 * (offset + offset)

    local surface = get_test_surface()

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

-- Urgh, need to be smarter here
-- remote.add_interface("biter-power", {

--     -- /c remote.call("biter-power", "show-derivates")
--     ["show-derivates"] = show_derivatives
-- })