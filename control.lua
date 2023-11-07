local config = require("config")
local lib = require("lib.lib")
local util = require("util")

if script.active_mods["debugadapter"] then require("tests.cmd") end

local function create_escapable_data(entity)
    return {
        entity = entity,
        name = entity.name,
        force = entity.force,
        position = entity.position,         -- So that cleanup is clearer when something goes wrong
        surface = entity.surface,           -- Need the surface for the previous thing. Forgot, oops.
        
        unit_number = entity.unit_number,   -- Usefull I guess

        last_escape = nil,                  -- Tick the last escape occured
        last_dice_roll = game.tick,         -- Last tick an escape was chanced
    }
end

-------------------------------------------------------------------------
-- Pre-calculate things at save loading for faster in-game processing
-------------------------------------------------------------------------

local biter_configs = config.biter.types -- Because this is used often
local fuel_to_biter_name = { }
local supported_biters = { }
local biters_in_tier = { }
for biter_name, biter_config in pairs(biter_configs) do
    fuel_to_biter_name["bp-caged-"..biter_name] = biter_name
    fuel_to_biter_name["bp-tired-caged-"..biter_name] = biter_name
    table.insert(supported_biters, biter_name)
    biters_in_tier[biter_config.tier] = biters_in_tier[biter_config.tier] or { }
    table.insert(biters_in_tier[biter_config.tier], biter_name)
end
local is_husbandry_technology = { }
for tier = 1, config.biter.max_tier do 
    is_husbandry_technology["bp-biter-capture-tier-"..tier] = true
end

-- Handle all treadmil biter derivatives
local escapable_machines = config.escapes.escapable_machine
local escapable_machine_base = { } -- For machines with derivates
for biter_name, biter_config in pairs(biter_configs) do
    escapable_machines["bp-generator-reinforced-"..biter_name] = escapable_machines["bp-generator-reinforced"]
    escapable_machine_base["bp-generator-reinforced-"..biter_name] = "bp-generator-reinforced"
    if biter_config.tier <= config.generator.normal_maximum_tier then
        escapable_machines["bp-generator-"..biter_name] = escapable_machines["bp-generator"]
        escapable_machine_base["bp-generator-"..biter_name] = "bp-generator"
    end
end
escapable_machine_base["bp-generator"] = "bp-generator"
escapable_machine_base["bp-generator-reinforced"] = "bp-generator-reinforced"
-------------------------------------------------------------------------

local function attemp_tiered_technology_unlock(tech, biter_name, force_unlock)
    if tech.researched then return end

    local prereqs_satisfied = true
    for prereq_name, prereq in pairs(tech.prerequisites) do
        if force_unlock and not prereq.researched and is_husbandry_technology[prereq_name] then
            -- We will recursively unlock earlier husbandry techs if a later
            -- tier biter is caught. This is to prevent a deadlock if a player
            -- only adds this mod in the late game. It also makes sense.
            attemp_tiered_technology_unlock(prereq, biter_name, true)
            -- This will not print the notification
        end

        -- Cannot early return here, incase we need to still check
        -- out other prereqs which might be husbandry techs
        if not prereq.researched then prereqs_satisfied = false end
    end
    if not prereqs_satisfied then return end
    
    if not force_unlock then
        local statistics = tech.force.item_production_statistics
        local biter_already_captured = false
        for _, biter_name in pairs(biters_in_tier[tech.level]) do
            -- This check isn't perfect, but will only fail if player cheated
            -- TODO could change this to a custom stored value in global
            if statistics.get_input_count("bp-caged-"..biter_name) > 0 then
                biter_already_captured = true
                goto continue
            end
        end
        
        ::continue::
        if not biter_already_captured then return end
    end

    -- If reach here then we can unlock the tech
    tech.researched = true
    if force_unlock then
        tech.force.print({"bp-text.capture-complete",
            "[technology="..tech.name.."]", biter_name}, {1, 0.75, 0.4})
    end
end

script.on_event(defines.events.on_script_trigger_effect , function(event)
    if event.effect_id ~= "bp-cage-trap-trigger" then return end
    local trap = event.source_entity -- Could also be the cage cannon
    if not trap then return end
    local biter = event.target_entity
    if not biter then return end
    local biter_config = biter_configs[biter.name]
    if not biter_config then return end  -- Will lose the cage    
    local caged_name = "bp-caged-"..biter.name
    local force = trap.force
    biter.surface.spill_item_stack(biter.position, {name=caged_name}, true, force)
    trap.force.item_production_statistics.on_flow(caged_name, 1)
    attemp_tiered_technology_unlock(force.technologies["bp-biter-capture-tier-"..biter_config.tier], biter.name, true)
    biter.destroy{raise_destroy = true}
end)

script.on_event(defines.events.on_research_started , function(event)
    local tech = event.research
    if is_husbandry_technology[tech.name] then
        -- This is so that if a player chooses to research the tech it could be unlocked
        -- if the player somehow already captured the biters before.
        -- this command will silently be ignored if the tech couldn't be researched
        attemp_tiered_technology_unlock(tech)
    end
end)

-- retuns a table of biter types found
local function get_biters_in_machine(entity)
    local biters_found = {}
    local burner = entity.burner

    local count_in_inventory = function (inventory)
        if not inventory then return 0 end
        for i = 1, #inventory do
            if inventory[i].valid_for_read and inventory[i].prototype.fuel_category == "bp-biter-power" then
                table.insert(biters_found, fuel_to_biter_name[inventory[i].name])
            end
        end
    end

    -- If this is a burner
    if burner then
        if burner.remaining_burning_fuel > 0 then
            -- There is a biter running on this treadmil!
            table.insert(biters_found, fuel_to_biter_name[burner.currently_burning.name])
        end
        count_in_inventory(burner.inventory)
    end

    -- If this is an assembler
    if entity.type == "assembling-machine" or entity.type == "furnace" then
        -- Then it's an assembler, or crafting machine at least
        if entity.crafting_progress > 0 then 
            -- assume the not-tired-biter is the first product of the current recipe
            table.insert(biters_found, fuel_to_biter_name[entity.get_recipe().products[1].name])
        end
        count_in_inventory(entity.get_output_inventory())
        count_in_inventory(entity.get_inventory(defines.inventory.assembling_machine_input))
    end

    return biters_found
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

local function escape_biters_from_entity(entity, biter_names)
    if not next(biter_names) then return { } end
    
    -- Out of the cage
    clear_all_biters_in_machine(entity)
    -- We won't update production statistics, because they are not consumed
    
    -- And into the world
    local biters = { }
    local surface = entity.surface
    for _, biter_name in pairs(biter_names) do
        local position = surface.find_non_colliding_position(
            biter_name, entity.position, 20, 0.2)
        if position then
            local biter = surface.create_entity{
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
    for machine_name, _ in pairs(escapable_machines) do
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
            if target.valid and #get_biters_in_machine(this_command.target) > 1 then
                command = this_command
                command.distraction = defines.distraction.none
                goto done
            end
        end
    end
    
    for _, machine in pairs(machines) do
        if #get_biters_in_machine(machine) > 0 then
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

local function update_escapable_derivates(entity, biters_in_machine)
    local base_name = escapable_machine_base[entity.name]
    if not base_name then return end -- Entity has no derivatives

    -- Determine the required derivative name
    local required_name = base_name
    local biter_name = biters_in_machine[1]
    if biter_name then required_name = required_name .. "-" .. biter_name end
    if entity.name == required_name then return end;    -- nothing to do

    -- TODO WHY DONT WE SEE BURNT RESULT FOR BITERS IN MACHINE?
    -- TODO HANDLE CASE WHEN MODS ARE REMOVED

    -- This entity is the wrong derivative. Let's replace it with the correct
    -- variant. I could not get the fast replace mechanism to work, so I will
    -- just manually transfer all the properties
    -- Note: Do not delete the old entities' global data because it will break
    -- the iterator. We will delete it gracefully later.
    
    local new_entity = entity.surface.create_entity {
        name = required_name,
        position = entity.position,
        force = entity.force,
        raise_built = true,
        player = entity.last_user,
        create_build_effect_smoke = false,
    }

    local function copy_inventory (source, destination)
        -- For slots in the machine, so size of 1
        destination[1].set_stack(source[1])
    end
    
    new_entity.health = entity.health
    new_entity.burner.currently_burning = entity.burner.currently_burning
    new_entity.burner.remaining_burning_fuel = entity.burner.remaining_burning_fuel
    copy_inventory(entity.burner.inventory, new_entity.burner.inventory)
    copy_inventory(entity.burner.burnt_result_inventory, new_entity.burner.burnt_result_inventory)
    
    -- Before we destroy the old entity, check if the GUI was open for any players, and then
    -- open the GUI of the new entity for those players
    local gui_was_open = { } -- array of table ids
    for _, player in pairs(game.connected_players) do
        if player.opened == entity then table.insert(gui_was_open, player) end
    end

    -- We need to prevent destruction of this entity to release biters
    global.ignore_build_destroy_events_for = entity.unit_number
    entity.destroy { raise_destroy = true }
    global.ignore_build_destroy_events = nil

    for _, player in pairs(gui_was_open) do player.opened = new_entity end
    
    -- Keep track of new entry
    global.escapables[new_entity.unit_number] = create_escapable_data(new_entity)

    return new_entity
end

local function tick_escape_for_entity(data)
    local entity = data.entity
    if not entity or not entity.valid then return nil, true end -- Delete entry
    local tick = game.tick

    -- Escape early if we already processed the entity this tick
    -- This also prevents rolling again for a derivative entity newly created
    local time_since_last_roll = tick - data.last_dice_roll
    if time_since_last_roll == 0 then return nil, nil, true end   -- Already rolled this tick
    
    -- Make sure to call this only once, because it can probably take long.
    -- TODO Cache the inventory?
    local biters_in_machine = get_biters_in_machine(entity)
    
    -- Ensure the right treadmil derivative is used. We will update it here because
    -- this function will already be called quite often.
    local new_entity = update_escapable_derivates(entity, biters_in_machine)
    local delete_current_entry = false
    if new_entity then
        -- If the entity derivative was updated to a new entity then we need
        -- to carefully delete the old one's data from global to not break
        -- the iterator.
        delete_current_entry = true
        entity = new_entity
    end

    -- Does it contain biters?
        if not next(biters_in_machine) then
        -- If it doesn't contain biters then "reset" the "timer".
        -- Otherwise when it's empty for a long time and suddenly gets a biter
        -- then the time_since_last_roll will be massive, and biter will escape!
        data.last_dice_roll = tick
        return
    end    
    
    -- The idea is that if the odds are that the biter will escape every 10 seconds,
    -- and we roll the dice every second, then each time we roll the biter has a 10% chance
    -- of escaping. I think this should work.
    local average_escape_time = 
            biter_configs[biters_in_machine[1]].escape_period      -- always use the first found biter
            * escapable_machines[entity.name]        -- the current building is a modifier
    local probability = time_since_last_roll / average_escape_time
    data.last_dice_roll = tick
    if math.random() < probability then
        entity.create_build_effect_smoke()
        local biters = escape_biters_from_entity(entity, biters_in_machine)
        rally_biters_around(entity.surface, entity.position)
        for i = 1, #biters_in_machine do
            if entity.valid then -- It might be destroyed in the loop. Only apply damage if it still exists                
                entity.damage(entity.prototype.max_health * 0.2, "enemy", "physical")
            end
        end
    end

    if delete_current_entry then return nil, true end
end

local function tick_escapes(tick)
    if tick % 60 ~= 0 then return end

    global.iterate_escapables = lib.table.for_n_of(
        global.escapables, global.iterate_escapables, 
        5, -- Machines to update per second
        tick_escape_for_entity)
end

script.on_nth_tick(10, function (event)
    -- Nests that die leaves their corpse on top of the buried biter nest
    -- so we clean it up ourselves after a while
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
    local entity = event.created_entity or event.entity or event.destination
    if not entity or not entity.valid then return end    
    if global.ignore_build_destroy_events == entity.unit_number then return end

    if escapable_machines[entity.name] then 
        global.escapables[entity.unit_number] = create_escapable_data(entity)
        return
    end

    if biter_configs[entity.name] then
        local stack = event.stack
        if stack and stack.valid_for_read and (
            stack.name:find("bp-caged-", 1, true) 
            or stack.name:find("bp-tired-caged-", 1, true)
        ) then
            -- Player released a caged biter. Captured biters aren't wild
            -- But first "consume" the item for the player's force, before
            -- making the biter wild again.
            entity.force.item_production_statistics.on_flow(stack.name, -1)
            entity.force = "enemy"
            return
        end
    end
end

script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.script_raised_built, on_built)
script.on_event(defines.events.script_raised_revive, on_built)
script.on_event(defines.events.on_entity_cloned, on_built)

script.on_event(defines.events.on_trigger_created_entity, function(event) 
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end
    if entity.name ~= "bp-buried-biter-nest" then return end
    entity.amount = config.buried_nest.spawn_amount * (math.random() + 0.5)
    -- Resources are not aligned nicely to the grid for the egg extractor
    -- resulting that it's not placeable. It's a 3x3 entity, so the middle
    -- of the resource needs to be in the middle of a tile, but for after 
    -- spawners it spawns on the edges of tiles.
    local halfify = function(value) return math.floor(value) + 0.5 end
    entity.teleport({halfify(entity.position.x), halfify(entity.position.y)})
    table.insert(global.nests_to_clean, entity)
end)

local function on_deconstructed(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end
    if global.ignore_build_destroy_events == entity.unit_number then return end
    if not escapable_machines[entity.name] then return end

    -- If this is a die event then the biters should escape!
    -- We should only reach here if entity is escapable
    if event.name == defines.events.on_entity_died then
        escape_biters_from_entity(entity, get_biters_in_machine(entity))
    end
    
    global.escapables[entity.unit_number] = nil
end

script.on_event(defines.events.on_player_mined_entity, on_deconstructed)
script.on_event(defines.events.on_robot_mined_entity, on_deconstructed)
script.on_event(defines.events.on_entity_died, on_deconstructed)
script.on_event(defines.events.script_raised_destroy, on_deconstructed)

remote.add_interface("biter-power", {
    -- This mod will prevent placement of "enemy" biters close
    -- to "player" structures. Add all biters to the whitelist
    ["aai_programmable_vehicles_non_combat_whitelist"] = function() return supported_biters end,
    
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

local function sanitize_escapables()
    -- Sanitize the escapable derivatives, because a mod might be removed which had a biter running
    -- Removing the mod should remove the items, not the machines.
    local entries_to_delete = { }
    for unit_number, entry in pairs(global.escapables) do
        if not entry.entity.valid then
            table.insert(entries_to_delete, unit_number)
            
            -- Should we spawn a new one in it's position?
            if entry.name and not escapable_machine_base[entry.name] then
                -- This machine was most likely destroyed when the mod adding the biters
                -- was removed. Let's replace it with a base machine. The player might lose
                -- items that was inside, but there is no way to recover that.
                
                local base_name -- Make sure it was actually a generator
                if entry.name:find("bp-generator-reinforced", 1, true) then
                    base_name = "bp-generator-reinforced"
                elseif entry.name:find("bp-generator", 1, true) then
                    base_name = "bp-generator"
                end 
                
                if base_name then
                    entry.surface.create_entity {
                        name = base_name,
                        position = entry.position,
                        force = entry.force,
                        create_build_effect_smoke = false,
                        raise_built = true, -- To create the new data
                    } -- If this fails then we just give up. Nothing better to do
                end
            end
        end
    end

    for _, unit_number in pairs(entries_to_delete) do
        global.escapables[unit_number] = nil
    end
end

script.on_init(function()
    global.escapables = { }
    global.nests_to_clean = { }
    global.biter_distribution_cache = { }
end)

script.on_configuration_changed(function (event)
    global.escapables = global.escapables or { }
    global.nests_to_clean = global.nests_to_clean or { }
    global.biter_distribution_cache = global.biter_distribution_cache or { }

    sanitize_escapables()

    -- Technically we don't have to do this every time, but it makes it easy.
    for _, force in pairs(game.forces) do
        force.reset_technology_effects()
    end
end)