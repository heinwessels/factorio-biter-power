if not script.active_mods["debugadapter"] then return { } end
local util = require("util")

local tests = { }

--- @class HarnessData
--- @field name string?
--- @field test function?
--- @field active boolean
--- @field data table
--- @field handle_command function
--- @field events table<integer, function>

---@return HarnessData
local function create_harness(harness)
    harness.active = false
    return harness
end

---@type HarnessData[]
local harnesses = {
    create_harness(require("tests.escapables"))
}

---@param harness HarnessData
local function start_test(harness)
    harness.test()
end

---@param event EventData.on_console_command
local function handle_command(event)
    local player = game.get_player(event.player_index)
    if not player then error("Where is the player?") end

    if event.command ~= "bp" then return end

    local args = util.split_whitespace(event.parameters)
    for _, harness in pairs(harnesses) do
        if harness.name and harness.name == args[1] then
            if args[2] == "test" then
                if not harness.test then
                    player.print("Harness "..args[1].." has no tests!")
                    return
                end

                start_test(harness)
                return
            end

            -- Pop!
            table.remove(args, 1)
            harness.handle_command(args)
            return
        end
    end
    player.print("Unknown test harness "..args[1])
end

tests.events = {
    [defines.events.on_console_command] = handle_command
}


-- Add support for all events harnesses might need
local function generic_event_handler(event)
    local handlers = tests.harness_events[event.name]
    if not handlers then return end
    for harness_index, handler in pairs(handlers) do 
        if harnesses[harness_index].active then handler(event) end
    end
end

tests.harness_events = { }
for harnesses_index, harness in pairs(harnesses) do
    if harness.events then
        for event, handler in pairs(harness.events) do
            tests.harness_events[event] = tests.harness_events[event] or { }
            tests.harness_events[event][harnesses_index] = handler
            tests.events[event] = generic_event_handler -- Might override, meh
        end
    end
end

return tests