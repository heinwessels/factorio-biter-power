local config = require("config")
local test_suite = require("tests.test-suite")
local test_util = require("tests.test-util")

local module = {
    suite = test_suite.create("treadmills"),
}
local suite = module.suite

test_suite.create_test(suite, "treadmil-can-burn-lower-tier", {
    setup = function (test)
        --[[
            So to test this we have to be a little smart. We can set the fuel in a burner by
            writing to `currently_burning`, but this allows us to set it to _any_ fuel, regardlees
            of category. And we want to this test to include the category. Instead, we will try
            place the biter in the input slot. Fuels of the wrong category is silently ignored
            it seems.
        ]]

        local surface = test_util.reset_surface()
        local generator = surface.create_entity{
            name = "bp-generator",
            position = {0, 0},
            force = "player",
            raise_built = false, -- To disable the escape mechanism
        }
        test_util.assert_valid_entity(generator)

        local burner = generator.burner
        local inventory = burner.inventory

        ---@param fuel string name of the fuel
        ---@return boolean true if the fuel stayed in the slot 
        local function fuel_is_a_valid_input(fuel)
            inventory.clear()
            inventory.insert{name=fuel}
            return inventory.get_item_count(fuel) > 0
        end

        -- First ensure it breaks if we try put in something it shouldn't burn
        test_util.assert_false(fuel_is_a_valid_input("wood"))

        -- Now loop through all our biter types and see if we can
        local max_tier = config.generator.normal_maximum_tier
        for biter_name, biter_config in pairs(config.biter.types) do
            if biter_config.tier <= max_tier then
                test_util.assert_true(fuel_is_a_valid_input("bp-caged-"..biter_name))
                test_util.assert_true(fuel_is_a_valid_input("bp-tired-caged-"..biter_name))
            end
        end
    end,
})

test_suite.create_test(suite, "reinforced-treadmil-can-burn-all", {
    setup = function (test)
        --[[
            So to test this we have to be a little smart. We can set the fuel in a burner by
            writing to `currently_burning`, but this allows us to set it to _any_ fuel, regardlees
            of category. And we want to this test to include the category. Instead, we will try
            place the biter in the input slot. Fuels of the wrong category is silently ignored
            it seems.
        ]]

        local surface = test_util.reset_surface()
        local generator = surface.create_entity{
            name = "bp-generator-reinforced",
            position = {0, 0},
            force = "player",
            raise_built = false, -- To disable the escape mechanism
        }
        test_util.assert_valid_entity(generator)

        local burner = generator.burner
        local inventory = burner.inventory

        ---@param fuel string name of the fuel
        ---@return boolean true if the fuel stayed in the slot 
        local function fuel_is_a_valid_input(fuel)
            inventory.clear()
            inventory.insert{name=fuel}
            return inventory.get_item_count(fuel) > 0
        end

        -- First ensure it breaks if we try put in something it shouldn't burn
        test_util.assert_false(fuel_is_a_valid_input("wood"))

        -- Now loop through all our biter types and see if we can
        for biter_name, _ in pairs(config.biter.types) do
            test_util.assert_true(fuel_is_a_valid_input("bp-caged-"..biter_name))
            test_util.assert_true(fuel_is_a_valid_input("bp-tired-caged-"..biter_name))
        end
    end,
})


return module