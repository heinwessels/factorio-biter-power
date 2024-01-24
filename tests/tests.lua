local test_suite = require("tests.test-suite")

local STATUS = test_suite.STATUS

local module = { }

local data_key = "__tests"
local data = {
    status = STATUS.WAITING,

    current_suite_name = nil,
    suites_executed = 0,
    tests_executed = 0,

    tick_started = nil
}

---@type SuiteData[]
local suites = { }

local function add_suite(required_suite)
    local suite = required_suite.suite
    suites[suite.name] = suite
end

add_suite(require("tests.escapables"))
add_suite(require("tests.treadmill"))
add_suite(require("tests.cannon"))
-- add_suite(require("tests.escapables-period")) -- This test takes a loooong time

module.events = {
    [defines.events.on_tick] = function()
        if not data.current_suite_name then return end
        local suite = suites[data.current_suite_name]

        if suite.status == STATUS.DONE then
            -- This suite has completed all tests.
            data.suites_executed = data.suites_executed + 1
            data.tests_executed = data.tests_executed + suite.tests_executed
            game.print("[TESTS] Finished "..suite.tests_executed.." tests in '"..suite.name.."' suite.")

            -- Start the next one
            data.current_suite_name, suite = next(suites, data.current_suite_name)
            if not data.current_suite_name then
                -- DONE! All tests passed successfully.
                data.status = STATUS.DONE

                -- Calculate duration
                local seconds = (game.tick - data.tick_started) / 60
                seconds = tonumber(string.format("%.2f", seconds))

                game.print("[TESTS] Success! Executed "..data.tests_executed.." tests across "..data.suites_executed.." suites in " .. seconds .. " seconds.")

                return
            end
        end

        -- Tick the suite. This will also start the suite if it hasn't been started yet
        test_suite.tick(suite)
    end,
}

function module.add_commands()
    commands.add_command("bp-test", nil, function(command)
        if game.is_multiplayer() then error("Test suite is not MP safe") end
        game.reload_script()
        -- game.speed = 1000

        data.status = STATUS.ACTIVE
        data.suites_executed = 0
        data.tests_executed = 0
        data.tick_started = game.tick

        -- Find the first test suite to execute
        data.current_suite_name = next(suites)
        if not data.current_suite_name then error("To tests to execute!") end
    end)
end

function module.initialize(event_handler)
    event_handler.add_lib(module)
    for _, suite in pairs(suites) do
        test_suite.initalize(suite, event_handler)
    end
end

function module.on_init()
    global[data_key] = global[data_key] or data
    data = global[data_key]
end
module.on_load = function() data = global[data_key] or data end

return module