local config = require("config")

local function create_escapable_data(entity)
    return {
        entity = entity,
        position = entity.position,         -- So that cleanup is clearer when something goes wrong
        unit_number = entity.unit_number,   -- Usefull I guess

        last_escape = nil,                  -- Tick the last escape occured
    }
end

local function on_built(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end
    if not config.escapes.machine_whitelist[entity.name] then return end

    global.escapables[entity.unit_number] = create_escapable_data(entity)
end

script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.script_raised_built, on_built)
script.on_event(defines.events.script_raised_revive, on_built)

local function on_deconstructed(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end
    if not config.escapes.machine_whitelist[entity.name] then return end

    global.escapables[entity.unit_number] = nil
end

script.on_event(defines.events.on_player_mined_entity, on_deconstructed)
script.on_event(defines.events.on_robot_mined_entity, on_deconstructed)
script.on_event(defines.events.on_entity_died, on_deconstructed)
script.on_event(defines.events.script_raised_destroy, on_deconstructed)


script.on_init(function()
    global.escapables = { }
end)

script.on_configuration_changed(function (event)
    global.escapables = global.escapables or { }
end)