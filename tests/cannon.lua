local config = require("config")
local test_suite = require("tests.test-suite")
local test_util = require("tests.test-util")

local STATUS = test_suite.STATUS
local module = {
    suite = test_suite.create("cannon"),
}
local suite = module.suite

test_suite.create_test(suite, "can-catch-all-biters", {
    setup = function(test)
        local surface = test_util.reset_surface()

        -- Lets get the maximum distance away we can place a biter
        test.data.range = 15 -- Copied from prototype.

        test.data.cannon = surface.create_entity{
            name = "bp-cage-cannon",
            position = {0, 0},
            force = "player",
            direction = defines.direction.east,
        }
        test_util.assert_valid_entity(test.data.cannon)
        test.data.cannon.get_inventory(defines.inventory.turret_ammo).insert{name="bp-cage-projectile"}

        -- Create first biter
        test.data.victim_name = next(config.biter.types)
        test_util.assert_not_nil(test.data.victim_name)

        test.data.victim = surface.create_entity{
            name = test.data.victim_name,
            position = {test.data.range, 0},
            force = "enemy",
        }
        test_util.assert_valid_entity(test.data.victim)
    end,
    events = {[defines.events.script_raised_destroy] = function(event, test)
        -- There is no event for when items are spilled on the ground.
        -- But by the time the entity is dead the items should be created already
        local victim = event.entity
        if not (victim and victim.valid) then return end
        if victim.name ~= test.data.victim_name then return end -- Rely on timeout

        local surface = victim.surface
        local spilled_items = surface.find_entities_filtered{
            position = victim.position,
            radius = 2,
        }
        local count = 0
        for _, item in pairs(spilled_items) do
            if item.name == "item-on-ground" and item.stack.name == "bp-caged-"..test.data.victim_name then
                count = count + 1
                item.destroy()
            end
        end
        test_util.assert_equal(count, 1)

        -- SUCCESS! Now try the next one.
        -- We will create a new cannon to circumvent the cooldown
        test.data.cannon.destroy{raise_restroy = false } --
        test.data.cannon = surface.create_entity{
            name = "bp-cage-cannon",
            position = {0, 0},
            force = "player",
            direction = defines.direction.east,
        }
        test_util.assert_valid_entity(test.data.cannon)
        test.data.cannon.get_inventory(defines.inventory.turret_ammo).insert{name="bp-cage-projectile"}

        -- Find the next biter to spawn and create it
        test.data.victim_name = next(config.biter.types, test.data.victim_name)
        if not test.data.victim_name then
            -- Wait! We tested all the biters! we are done
            test.status = STATUS.DONE
            return
        end

        test.data.victim = surface.create_entity{
            name = test.data.victim_name,
            position = {test.data.range, 0},
            force = "enemy",
        }
        test_util.assert_valid_entity(test.data.victim)
    end}
})


return module