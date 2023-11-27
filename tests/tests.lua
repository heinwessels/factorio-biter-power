if not script.active_mods["debugadapter"] then return { } end
local util = require("util")

local derivatives = require("tests.derivatives")

local tests = {
    commands = {
        ["derivatives"] = derivatives.handle_command
    }
}

---@param event EventData.on_console_command
local function handle_command(event)
    local player = game.get_player(event.player_index)
    if not player then error("Where is the player?") end

    if event.command ~= "bp" then return end

    local args = util.split_whitespace(event.parameters)
    local handler = tests.commands[args[1]]
    if not handler then player.print("Unknown test group "..args[1]) return end

    table.remove(args, 1)
    handler(args)
end

tests.events = {
    [defines.events.on_console_command] = handle_command
}

return tests