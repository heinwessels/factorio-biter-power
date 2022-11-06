local config = require("config")
local lib = require("lib.lib")
local util = require("util")

local function create_escapable_data(entity)
    return {
        entity = entity,
        position = entity.position,         -- So that cleanup is clearer when something goes wrong
        unit_number = entity.unit_number,   -- Usefull I guess

        last_escape = nil,                  -- Tick the last escape occured
        last_dice_roll = game.tick,         -- Last tick an escape was chanced
    }
end

local function rally_biters_around(position)

end

local function on_built(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end
    
    if config.escapes.escapable_machine[entity.name] then 
        global.escapables[entity.unit_number] = create_escapable_data(entity)
    end
end

script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.script_raised_built, on_built)
script.on_event(defines.events.script_raised_revive, on_built)

script.on_event(defines.events.on_trigger_created_entity, function(event) 
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end
    if entity.name ~= "bp-buried-biter-nest" then return end
    table.insert(global.nests_to_clean, entity)
end)

local function on_deconstructed(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end
    if not config.escapes.escapable_machine[entity.name] then return end

    global.escapables[entity.unit_number] = nil
end

script.on_event(defines.events.on_player_mined_entity, on_deconstructed)
script.on_event(defines.events.on_robot_mined_entity, on_deconstructed)
script.on_event(defines.events.on_entity_died, on_deconstructed)
script.on_event(defines.events.script_raised_destroy, on_deconstructed)

local function determine_biter_type_to_escape(entity)
    return "small-biter"
end

local function count_biters_in_machine(entity)
    local count_biters = 0
    local burner = entity.burner

    count_in_inventory = function (inventory)
        if not inventory then return 0 end
        local _count = 0 -- Don't know how the scopes work here.
        for i = 1, #inventory do
            if inventory[i].valid_for_read and inventory[i].prototype.fuel_category == "bp-biter-power" then
                -- If we can read it we assume it's fuel
                _count = _count + inventory[i].count
            end
        end
        return _count
    end

    -- If this is a burner
    if burner then
        if burner.remaining_burning_fuel > 0 then
            -- There is a biter running on this treadmil!
            count_biters = count_biters + 1
        end
        count_biters = count_biters + count_in_inventory(burner.inventory)
    end

    -- If this is an assembler
    if entity.type == "assembling-machine" or entity.type == "furnace" then
        -- Then it's an assembler, or crafting machine at least
        if entity.crafting_progress > 0 then count_biters = count_biters + 1 end
        count_biters = count_biters + count_in_inventory(entity.get_output_inventory())
        count_biters = count_biters + count_in_inventory(entity.get_inventory(defines.inventory.assembling_machine_input))
    end

    return count_biters
end

local function clear_all_biters_in_machine(entity)
    local burner = entity.burner
    if burner then
        burner.inventory.clear()
        burner.currently_burning = nil  -- Voids the currently burning item.
    elseif entity.type == "assembling-machine" or entity.type == "furnace" then
        entity.crafting_progress = 0
        entity.get_output_inventory().clear()
        entity.get_inventory(defines.inventory.assembling_machine_input).clear()
    end
end

local function tick_escape_for_entity(data)
    local entity = data.entity
    if not entity or not entity.valid then return nil, true end -- Delete entry
    local tick = game.tick
    
    -- Does it contain biters?
    local number_of_biters = count_biters_in_machine(entity)
    if number_of_biters == 0 then
        -- If it doesn't contain biters then "reset" the "timer".
        -- Otherwise when it's empty for a long time and suddenly gets a biter
        -- then the time_since_last_roll will be massive, and biter will escape!
        data.last_dice_roll = tick
        return
    end    
    
    -- The idea is that if the odds are that the biter will escape every 10 seconds,
    -- and we roll the dice every second, then each time we roll the biter has a 10% chance
    -- of escaping. I think this should work.
    local time_since_last_roll = tick - data.last_dice_roll
    if time_since_last_roll == 0 then return nil, nil, true end   -- Already rolled this tick
    local average_escape_time = config.escapes.escapable_machine[entity.name]
    if not average_escape_time then return nil, true end -- This machine isn't escapable. Something went wrong. Delete!
    local probability = time_since_last_roll / average_escape_time
    data.last_dice_roll = tick
    if math.random() < probability then

        -- First remove all biters. Otherwise if the entity is destroyed with damage
        -- then the destroyed_handler must not be able to release anything else.
        clear_all_biters_in_machine(entity)
        
        -- Release the amount of biters thats inside the machine, applying damage for each one.
        local surface = entity.surface
        local entity_position = util.table.deepcopy(entity.position) -- The entity might become invalid in this operation
        local biter_name = determine_biter_type_to_escape(entity)
        entity.create_build_effect_smoke()
        for i = 1, number_of_biters do            
            local position = surface.find_non_colliding_position(
                biter_name, entity_position, 20, 0.2)
            local biter
            if position then
                -- Only spawn biter if there's a spot to spawn. Will always damage though
                biter = surface.create_entity{
                    name=biter_name, position=position, 
                    force="enemy", raise_built=true}
            end

            if entity.valid then -- It might be destroyed in the loop. Only apply damage if it still exists                
                entity.damage(entity.prototype.max_health * 0.2, "enemy", "physical", biter) -- biter can be nil
            end
        end
        rally_biters_around(entity_position)    -- Will make them attack similar structures to release more biters
    end
end

local function tick_escapes(tick)
    if tick % 60 ~= 0 then return end

    global.from_k = lib.table.for_n_of(
        global.escapables, global.from_k, 
        10, -- Machines to update per second
        tick_escape_for_entity)
end

script.on_nth_tick(10, function (event) 
    for _, nest in pairs(global.nests_to_clean) do
        if nest.valid then 
            for _, entity in pairs(nest.surface.find_entities_filtered{
                type = "corpse",
                area = {{nest.position.x - 2, nest.position.y - 2},
                        {nest.position.x + 2, nest.position.y + 2}}
            }) do
                entity.destroy{ raise_destroy = true }
            end
        end
    end
    global.nests_to_clean = {}

    tick_escapes(event.tick)
end)

script.on_init(function()
    global.escapables = { }
    global.nests_to_clean = { }
end)

script.on_configuration_changed(function (event)
    global.escapables = global.escapables or { }
    global.nests_to_clean = global.nests_to_clean or { }
end)