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

script.on_event(defines.events.on_script_trigger_effect , function(event)
    if event.effect_id ~= "bp-cage-trap-trigger" then return end
    local trap = event.source_entity
    local victim = event.target_entity
    if not victim then return end
    local whitelist = {
        ["small-biter"] = true,
        ["medium-biter"] = true,
        ["big-biter"] = true,
        ["behemoth-biter"] = true,
        
        ["small-spitter"] = true,
        ["medium-spitter"] = true,
        ["big-spitter"] = true,
        ["behemoth-spitter"] = true,
    }
    if not whitelist[victim.name] then return end -- Will lose the cage
    victim.surface.spill_item_stack(victim.position, {name="bp-caged-biter"}, true, trap.force)
    victim.destroy{raise_destroy = true}
    trap.force.item_production_statistics.on_flow("bp-caged-biter", 1)
end)

local function biter_distribution_for_evolution(evolution)
    -- Calculate the biter spawn probability for a given evolution
    -- verified with calculator in the wiki.
    -- Cool :)

    -- Currently we will only spawn biters and not spitters. 
    local result_units = game.entity_prototypes["biter-spawner"].result_units
    local distribution = { }
    local total = 0
    for _, definition in pairs(result_units) do
        local weight = 0
        for index = #definition.spawn_points, 1, -1 do
            local point_l = definition.spawn_points[index]
            if evolution >= point_l.evolution_factor then
                if index == #definition.spawn_points then
                    -- probability stays constant after last index
                    weight = point_l.weight
                else
                    -- interpolate between this index and the next
                    local point_r = definition.spawn_points[index + 1]
                    weight = point_l.weight 
                                + (evolution - point_l.evolution_factor)
                                * (point_r.weight - point_l.weight)
                                / (point_r.evolution_factor - point_l.evolution_factor)
                end
                goto done
            end
        end
        ::done::        
        total = total + weight
        table.insert(distribution, {unit=definition.unit, weight=weight})
    end

    -- Scale to one
    local correction = 1 / total
    for _, definition in pairs(distribution) do
        definition.weight = correction * definition.weight
    end

    return distribution
end

local function determine_biter_type_to_escape(entity)
    local force = entity.force

    -- Get a distribution table, maybe from the cache. We key it by force
    local cache = global.biter_distribution_cache[force.name]
    if not cache or cache.expiry_tick < game.tick then
        cache = {
            expiry_tick = game.tick + 60 * 60 * 3, -- expires after some time
            distribution = biter_distribution_for_evolution(force.evolution_factor)
        }
        global.biter_distribution_cache[force.name] = cache
    end

    -- Now roll the dice and see which biter to release!
    local roll = math.random()
    local weight = 0
    for _, entry in pairs(cache.distribution) do
        weight = weight + entry.weight
        if roll <= weight then
            return entry.unit
        end
    end
end

local function count_biters_in_machine(entity)
    local count_biters = 0
    local burner = entity.burner

    local count_in_inventory = function (inventory)
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

local function escape_biters_from_entity(entity, number_biters)
    local number_of_biters = number_of_biters or count_biters_in_machine(entity)
    if number_of_biters == 0 then return { } end
    
    -- Out of the cage
    clear_all_biters_in_machine(entity)
    -- TODO Add to item statistics? Annoying because in-progress biters are already consumed
    
    -- And into the world
    local biters = { }
    local surface = entity.surface
    for i = 1, number_of_biters do            
        local biter_name = determine_biter_type_to_escape(entity)
        local position = surface.find_non_colliding_position(
            biter_name, entity.position, 20, 0.2)
        local biter
        if position then
            biter = surface.create_entity{
                name=biter_name, position=position, 
                force="enemy", raise_built=true
            }
            if biter then table.insert(biters, biter) end
        end
    end

    return biters
end

local function rally_biters_around(surface, position)
    -- This function will rally biter around this position
    -- to attack a machine which contains other biters.
    -- Will also rallies spitters, because why not, they
    -- should also be angry
    
    local enemies = surface.find_enemy_units(position, 50, "player")
    if not enemies then return end -- No enemies found, ignore

    local machines_to_target = {}
    for machine_name, _ in pairs(config.escapes.escapable_machine) do
        table.insert(machines_to_target, machine_name)
    end
    local machines = surface.find_entities_filtered{
        position = position,
        radius = 50,
        name = machines_to_target,
        force = nil, -- Any force
    }

    
    local command 
    
    -- Loop through current biters and see if they are attacking a machine
    -- containing biters. If one is, let the other join in
    for _, enemy in pairs(enemies) do
        local this_command = enemy.command
        if this_command and this_command.name == defines.command.attack then
            local target = this_command.target
            if target.valid and  count_biters_in_machine(this_command.target) > 1 then
                command = this_command
                command.distraction = defines.distraction.none
                goto done
            end
        end
    end
    
    for _, machine in pairs(machines) do
        if count_biters_in_machine(machine) > 0 then
            command = {
                type = defines.command.attack,
                target = machine,
                radius = 30,
            }
            goto done
        end
    end

    if not command then
        command = {
            type = defines.command.attack_area,
            destination = position,
            radius = 30,
            distraction = defines.distraction.none, 
        }
    end

    ::done::
    for _, enemy in pairs(enemies) do
        enemy.set_command(command)
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
        entity.create_build_effect_smoke()
        local biters = escape_biters_from_entity(entity)
        rally_biters_around(entity.surface, entity.position)
        for i = 1, number_of_biters do
            if entity.valid then -- It might be destroyed in the loop. Only apply damage if it still exists                
                entity.damage(entity.prototype.max_health * 0.2, "enemy", "physical")
            end
        end
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
    entity.amount = config.buried_nest.spawn_amount * (math.random() + 0.5)
    table.insert(global.nests_to_clean, entity)
end)

local function on_deconstructed(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end
    if not config.escapes.escapable_machine[entity.name] then return end

    -- If this is a die event then the biters should escape!
    -- We should only reach here if entity is escapable
    if event.name == defines.events.on_entity_died then
        escape_biters_from_entity(entity)
    end
    
    global.escapables[entity.unit_number] = nil
end

script.on_event(defines.events.on_player_mined_entity, on_deconstructed)
script.on_event(defines.events.on_robot_mined_entity, on_deconstructed)
script.on_event(defines.events.on_entity_died, on_deconstructed)
script.on_event(defines.events.script_raised_destroy, on_deconstructed)

script.on_init(function()
    global.escapables = { }
    global.nests_to_clean = { }
    global.biter_distribution_cache = { }
end)

script.on_configuration_changed(function (event)
    global.escapables = global.escapables or { }
    global.nests_to_clean = global.nests_to_clean or { }
    global.biter_distribution_cache = global.biter_distribution_cache or { }
end)