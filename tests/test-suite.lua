--[[
    This is an suite that would allow tests to be run across multiple ticks!
    That would be cool, heh?
]]

local util = require("util")

local module = {
    ---@enum Status
    STATUS = {
        WAITING  = 0,
        ACTIVE   = 1,
        DONE     = 2,
    }

}
local STATUS = module.STATUS


---@class SuiteTestProperties
---@field setup fun(data:table)?
---@field cleanup fun(data:table)?
---@field events table<uint32, fun(event:table, data:SuiteTestProperties)>? to hook into regular events
---@field at_tick table<uint32, fun(data:SuiteTestProperties)>?             optional convenience function
---@field stages table<fun(data:SuiteTestProperties)>?              optional convenience function

---@class SuiteTestData : SuiteTestProperties
---@field name string
---@field status Status
---@field events table?
---@field timeout_override uint32?
---@field tick_started uint32?
---@field tick_ended uint32?
---@field data table                            Some storage that the test can use

---@class SuiteData
---@field name string
---@field status Status
---@field current_test_name string          the test currently being executed
---@field tests table<string, SuiteTestData>
---@field event_handler unknown
---@field test_event_handlers table         Keeping track of events that all tests need
---@field events table                      For subscribing to event handler
---@field timeout uint32
---@field tests_executed integer

---@param name string
---@return SuiteData
function module.create(name)
    return {
        name = name,
        status = STATUS.WAITING,
        tests = { },

        test_event_handlers = { },
        events = { },

        current_test_name = nil,
        tests_executed = 0,

        timeout = 5 * 60,
    }
end

-- Add support for all events suites might need
local function propgating_event_handler(suite)
   return function(event)
        for test_name, handler in pairs(suite.test_event_handlers[event.name]) do
            local test = suite.tests[test_name]
            if test.status == STATUS.ACTIVE then handler(event, test) end
        end
    end
end

---@param suite SuiteData
---@param test SuiteTestData
local function register_test_events(suite, test)
    if test.events then
        for event, handler in pairs(test.events) do
            -- Create custom handler table that we can look up later
            suite.test_event_handlers[event] = suite.test_event_handlers[event] or { }
            suite.test_event_handlers[event][test.name] = handler

            -- Subscribe this suite to that event if it hasn't been subscribed already
            if not suite.events[event] then
                suite.events[event] = propgating_event_handler(suite)
            end
        end
    end
end

---@param suite SuiteData
---@param event_handler unknown
function module.initalize(suite, event_handler)
    for _, test in pairs(suite.tests) do
        register_test_events(suite, test)
    end
    event_handler.add_lib(suite)
end

---@param suite SuiteData
---@param name string
---@param properties SuiteTestProperties
function module.create_test(suite, name, properties)
    if properties.at_tick and properties.at_tick[0] then
        error("Don't use at_tick[0]. Just put it in setup.") -- Off-by-one errors scare me
    end

    if suite.tests[name] then error("Test with name '"..name.."' already exists!") end

    local test = util.merge{properties, {
        name = name,
        status = STATUS.WAITING,
    }}

    suite.tests[test.name] = test
end

---@param suite SuiteData
---@param test_name string
local function start_test(suite, test_name)
    local test = suite.tests[test_name]
    if not test then error("Harness '"..suite.name.."' has no test '"..test_name.."'") end
    if test.status ~= STATUS.WAITING then error("Test '"..test_name.."' (Harness '"..suite.name.."') already started!") end

    -- Prepare the test
    test.tick_started = game.tick
    test.status = STATUS.ACTIVE
    test.data = { } -- Reset it's data
    suite.current_test_name = test_name
    suite.tests_executed = suite.tests_executed + 1

    -- Start the test
    if test.setup then test.setup(test) end
    if not (test.events or test.at_tick) then
        -- We assume this test executed immediatelly
        test.status = STATUS.DONE
    end
end

---@param suite SuiteData
function module.tick(suite)
    if suite.status == STATUS.DONE then return end

    if suite.status == STATUS.WAITING then
        -- Haven't started a test yet. Do it now
        suite.status = STATUS.ACTIVE
        suite.tests_executed = 0
        local test_name = next(suite.tests)
        start_test(suite, test_name)
        return -- We can check again next tick
    end

    local test = suite.tests[suite.current_test_name]
    if test.status == STATUS.WAITING then error("Test '"..test.name.."' (Harness '"..suite.name.."') has not been started!") end
    if test.status == STATUS.ACTIVE then
        -- Still busy

        if test.at_tick then
            -- This is a convenience handler for easier testing
            local tick_delta = game.tick - test.tick_started
            local tick_handler = test.at_tick[tick_delta]
            if tick_handler then tick_handler(test) end
        end

        -- Has this test timed out?
        local timeout = test.timeout_override or suite.timeout
        if game.tick > test.tick_started + timeout then
            error("Test '"..test.name.."' (Suite '"..suite.name.."') timed out!")
        end
        return
    end
    if test.status ~= STATUS.DONE then error("Test '"..test.name.."' (Suite '"..suite.name.."') has unexpected status "..test.status) end

    -- If we are here then the current test is done, and we should start a new one. Or end the suite
    test.data = { } -- Some garbage collection
    local test_name = next(suite.tests, suite.current_test_name)
    if test_name then
        start_test(suite, test_name)
        return
    end

    -- If we are here then we've completed all tests in this suite
    suite.status = STATUS.DONE
end

return module