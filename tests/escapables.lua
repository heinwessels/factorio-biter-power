
local config = require("config")
local test_suite = require("tests.test-suite")
local test_util = require("tests.test-util")
local script = require("scripts.escapables")

local escapables = {
    suite = test_suite.create("escapables"),
}

local suite = escapables.suite

test_suite.create_test(suite, "get-biters-in-inventory-generator-empty", {
    setup = function (test)
        local surface = test_util.reset_surface()
        local generator = surface.create_entity{
            name = "bp-generator",  -- Derivative already to prevent it being changed
            position = {0, 0},
            force = "player",
            raise_built = false, -- To disable the escape mechanism
        }
        test_util.assert_valid_entity(generator)
        local biters = script.get_biters_in_machine(generator)
        test_util.assert_equal(#biters, 0)
    end
})

test_suite.create_test(suite, "get-biters-in-inventory-generator-input", {
    setup = function (test)
        local surface = test_util.reset_surface()
        local generator = surface.create_entity{
            name = "bp-generator",  -- Derivative already to prevent it being changed
            position = {0, 0},
            force = "player",
            raise_built = false, -- To disable the escape mechanism
        }
        test_util.assert_valid_entity(generator)

        local inventory = generator.burner.inventory
        inventory.insert{name="bp-caged-small-biter"}

        local biters = script.get_biters_in_machine(generator)
        test_util.assert_equal(#biters, 1)
        test_util.assert_equal(biters[1], "small-biter")
    end
})

test_suite.create_test(suite, "get-biters-in-inventory-generator-burning", {
    setup = function (test)
        local surface = test_util.reset_surface()
        local generator = surface.create_entity{
            name = "bp-generator",  -- Derivative already to prevent it being changed
            position = {0, 0},
            force = "player",
            raise_built = false, -- To disable the escape mechanism
        }
        test_util.assert_valid_entity(generator)

        generator.burner.currently_burning = game.item_prototypes["bp-caged-big-biter"]
        generator.burner.remaining_burning_fuel = 100

        local biters = script.get_biters_in_machine(generator)
        test_util.assert_equal(#biters, 1)
        test_util.assert_equal(biters[1], "big-biter")
    end
})

test_suite.create_test(suite, "get-biters-in-inventory-generator-burning-zero", {
    setup = function (test)
        local surface = test_util.reset_surface()
        local generator = surface.create_entity{
            name = "bp-generator",  -- Derivative already to prevent it being changed
            position = {0, 0},
            force = "player",
            raise_built = false, -- To disable the escape mechanism
        }
        test_util.assert_valid_entity(generator)

        generator.burner.currently_burning = game.item_prototypes["bp-caged-big-biter"]
        generator.burner.remaining_burning_fuel = 0

        local biters = script.get_biters_in_machine(generator)
        test_util.assert_equal(#biters, 1)
        test_util.assert_equal(biters[1], "big-biter")
    end
})

test_suite.create_test(suite, "get-biters-in-inventory-generator-output", {
    setup = function (test)
        local surface = test_util.reset_surface()
        local generator = surface.create_entity{
            name = "bp-generator",  -- Derivative already to prevent it being changed
            position = {0, 0},
            force = "player",
            raise_built = false, -- To disable the escape mechanism
        }
        test_util.assert_valid_entity(generator)

        local inventory = generator.burner.burnt_result_inventory
        inventory.insert{name="bp-caged-medium-biter"}

        local biters = script.get_biters_in_machine(generator)
        test_util.assert_equal(#biters, 1)
        test_util.assert_equal(biters[1], "medium-biter")
    end
})

test_suite.create_test(suite, "get-biters-in-inventory-generator-input-burning-output", {
    setup = function (test)
        local surface = test_util.reset_surface()
        local generator = surface.create_entity{
            name = "bp-generator",  -- Derivative already to prevent it being changed
            position = {0, 0},
            force = "player",
            raise_built = false, -- To disable the escape mechanism
        }
        test_util.assert_valid_entity(generator)

        local inventory = generator.burner.inventory
        inventory.insert{name="bp-caged-small-biter"}

        generator.burner.currently_burning = game.item_prototypes["bp-caged-big-biter"]
        generator.burner.remaining_burning_fuel = 100

        local inventory = generator.burner.burnt_result_inventory
        inventory.insert{name="bp-caged-medium-biter"}

        local biters = script.get_biters_in_machine(generator)
        test_util.assert_equal(#biters, 3)
        local found = {["small-biter"]=false, ["medium-biter"]=false, ["big-biter"]=false}
        for _, biter in pairs(biters) do
            if found[biter] ~= nil then found[biter] = true end
        end
        for biter_name, found_biter in pairs(found) do
            if not found_biter then error("Didn't find "..biter_name) end
        end
    end
})

return escapables