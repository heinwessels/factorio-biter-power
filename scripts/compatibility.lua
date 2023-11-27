local config = require("config")

local compatibility = {
    --- @type string[]
    supported_biters = { }
}

-- Cache some useful information while the game loads
-------------------------------------------------------------------------
for biter_name, _ in pairs(config.biter.types) do
    table.insert(compatibility.supported_biters, biter_name)
end
-------------------------------------------------------------------------

compatibility.add_remote_interface = function()
    remote.add_interface("PipeVisualizer", {
        -- This mod will prevent placement of "enemy" biters close
        -- to "player" structures. Add all biters to the whitelist
        ["aai_programmable_vehicles_non_combat_whitelist"] = function() return compatibility.supported_biters end,

        -- Add some custom milestones, cause that's cool
        ["milestones_preset_addons"] = function()
            return {
                ["biter-power"] = {
                    required_mods = {"biter-power"},
                    milestones = {
                        {type="group", name="Kills"},
                        {type="item",  name="bp-biter-egg", quantity=1, next="x100"},
                        {type="item",  name="bp-cage", quantity=1, next="x100"},
                    }
                },
            }
        end
    })
end


local function handle_picker_dollies(event)
    if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), function(event)
            ---@diagnostic disable-next-line: undefined-field
            local entity = event.moved_entity
            if not entity or not entity.valid then return end
            local escapable_data = global.escapables[entity.unit_number]
            if not escapable_data then return end
            escapable_data.position = entity.position
        end)
    end
end

compatibility.on_init = handle_picker_dollies

function compatibility.on_configuration_changed(event)
    handle_picker_dollies()

    -- Technically we don't have to do this every time, but it makes it easy.
    for _, force in pairs(game.forces) do
        force.reset_technology_effects()
    end
end

return compatibility