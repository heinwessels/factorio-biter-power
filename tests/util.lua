local util = { }

-- Based on Editor Extensions. Thanks Raiguard!
---@return LuaSurface?
function util.get_test_surface()

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
            error("Could not create test surface")
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

return util