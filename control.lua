local handler = require("__core__/lualib/event_handler")

handler.add_libraries({
    require("scripts.escapables"),
    require("scripts.trapping"),
    require("scripts.nests"),
    require("scripts.technology"),
    require("scripts.compatibility"),
})

if script.active_mods["debugadapter"] then
    require("tests.tests").initialize(handler)
end