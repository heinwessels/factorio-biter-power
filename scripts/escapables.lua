local config = require("config")
local lib = require("lib.lib")

--- @class Escapable
--- @field entity LuaEntity
--- @field name string                  So that cleanup is clearer when something goes wrong
--- @field force LuaForce               So that cleanup is clearer when something goes wrong
--- @field posision MapPosition         So that cleanup is clearer when something goes wrong
--- @field surface LuaSurface           So that cleanup is clearer when something goes wrong
--- @field unit_number UnitNumber       Usefull I guess
--- @field last_escape uint?            Tick the last escape occured
--- @field last_dice_roll uint          Last tick an escape was chanced

local escapables = {
    -- Map of all machines that are escapable
    ---@type table<string, boolean>
    machines = config.escapes.escapable_machine,

    -- Any escapable with derivatives' base.
    ---@type table<string, string>
    machine_base = { },

    -- Get raw biter name from a "burning fuel"
    ---@type table<string, string>
    fuel_to_biter_name = { },
}

-- Cache some useful information while the game loads
-------------------------------------------------------------------------
local biter_configs = config.biter.types
for biter_name, biter_config in pairs(config.biter.types) do
    escapables.fuel_to_biter_name["bp-caged-"..biter_name] = biter_name
    escapables.fuel_to_biter_name["bp-tired-caged-"..biter_name] = biter_name
    escapables.machines["bp-generator-reinforced-"..biter_name] = escapables.machines["bp-generator-reinforced"]
    escapables.machine_base["bp-generator-reinforced-"..biter_name] = "bp-generator-reinforced"
    if biter_config.tier <= config.generator.normal_maximum_tier then
        escapables.machines["bp-generator-"..biter_name] = escapables.machines["bp-generator"]
        escapables.machine_base["bp-generator-"..biter_name] = "bp-generator"
    end
end
escapables.machine_base["bp-generator"] = "bp-generator"
escapables.machine_base["bp-generator-reinforced"] = "bp-generator-reinforced"
-------------------------------------------------------------------------

---@param entity LuaEntity
---@return Escapable
local function create_escapable_data(entity)
    return {
        entity = entity,
        name = entity.name,
        force = entity.force,
        position = entity.position,
        surface = entity.surface,        
        unit_number = entity.unit_number,
        last_escape = nil,
        last_dice_roll = game.tick,
    }
end

---@param entity LuaEntity
---@return string[]
local function get_biters_in_machine(entity)
    local biters_found = {}
    local burner = entity.burner

    local count_in_inventory = function (inventory)
        if not inventory then return 0 end
        for i = 1, #inventory do
            if inventory[i].valid_for_read and inventory[i].prototype.fuel_category == "bp-biter-power" then
                table.insert(biters_found, escapables.fuel_to_biter_name[inventory[i].name])
            end
        end
    end

    -- If this is a burner
    if burner then
        if burner.remaining_burning_fuel > 0 then
            -- There is a biter running on this treadmil!
            table.insert(biters_found, escapables.fuel_to_biter_name[burner.currently_burning.name])
        end
        count_in_inventory(burner.inventory)
    end

    -- If this is an assembler
    if entity.type == "assembling-machine" or entity.type == "furnace" then
        -- Then it's an assembler, or crafting machine at least
        if entity.crafting_progress > 0 then 
            -- assume the not-tired-biter is the first product of the current recipe
            table.insert(biters_found, escapables.fuel_to_biter_name[entity.get_recipe().products[1].name])
        end
        count_in_inventory(entity.get_output_inventory())
        count_in_inventory(entity.get_inventory(defines.inventory.assembling_machine_input))
    end

    return biters_found
end

---@param entity LuaEntity
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

---@param entity LuaEntity
---@param biter_names string[]
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

---@param entity LuaEntity
---@param biters_in_machine string[]
local function update_escapable_derivates(entity, biters_in_machine)
    local base_name = escapables.machine_base[entity.name]
    if not base_name then return end -- Entity has no derivatives

    -- Determine the required derivative name
    local required_name = base_name
    local biter_name = biters_in_machine[1]
    if biter_name then required_name = required_name .. "-" .. biter_name end
    if entity.name == required_name then return end;    -- nothing to do

    -- TODO WHY DONT WE SEE BURNT RESULT FOR BITERS IN MACHINE?

    -- This entity is the wrong derivative. Let's replace it with the correct
    -- variant. I could not get the fast replace mechanism to work, so I will
    -- just manually transfer all the properties
    -- Note: Do not delete the old entities' global data because it will break
    -- the iterator. We will delete it gracefully later.

    ---@diagnostic disable-next-line: missing-fields
    local new_entity = entity.surface.create_entity {
        name = required_name,
        position = entity.position,
        force = entity.force,
        raise_built = true,
        player = entity.last_user,
        create_build_effect_smoke = false,
    }
    if not new_entity then return end -- Shouldn't happen, but safe to return here

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

---@param data Escapable
---@return any? 
---@return boolean?  | True if this entry in the iterator should be deleted
---@return boolean?  | True if current iteration should be aborted
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
            * escapables.machines[entity.name]        -- the current building is a modifier
    local probability = time_since_last_roll / average_escape_time
    data.last_dice_roll = tick
    if math.random() < probability then
        entity.create_build_effect_smoke()
        local biters = escape_biters_from_entity(entity, biters_in_machine)
        for i = 1, #biters_in_machine do
            if entity.valid then -- It might be destroyed in the loop. Only apply damage if it still exists                
                entity.damage(entity.prototype.max_health * 0.2, "enemy", "physical")
            end
        end
    end

    if delete_current_entry then return nil, true end
end

---@param event NthTickEventData
local function update(event)
    global.iterate_escapables = lib.table.for_n_of(
        global.escapables, global.iterate_escapables, 
        5, -- Machines to update per second
        tick_escape_for_entity)
end

local function on_constructed(event)
    local entity = event.created_entity or event.entity or event.destination
    if not entity or not entity.valid then return end    
    if global.ignore_build_destroy_events == entity.unit_number then return end

    if escapables.machines[entity.name] then 
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

local function on_deconstructed(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end
    if global.ignore_build_destroy_events == entity.unit_number then return end
    if not escapables.machines[entity.name] then return end

    -- If this is a die event then the biters should escape!
    -- We should only reach here if entity is escapable
    if event.name == defines.events.on_entity_died then
        escape_biters_from_entity(entity, get_biters_in_machine(entity))
    end

    global.escapables[entity.unit_number] = nil
end


local function sanitize_escapables()
    -- Sanitize the escapable derivatives, because a mod might be removed which had a biter running
    -- Removing the mod should remove the items, not the machines.
    local entries_to_delete = { }
    for unit_number, entry in pairs(global.escapables) do
        if not entry.entity.valid then
            table.insert(entries_to_delete, unit_number)

            -- Should we spawn a new one in it's position?
            if entry.name and not escapables.machine_base[entry.name] then
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
        else
            -- This is a perfectly normal entry. Lets just make sure the position is still correct.
            -- It might have because out-of-sync if the player has used picker dollies on the
            -- escapable machines.
            entry.position = entry.entity.position
            entry.surface = entry.entity.surface
        end
    end

    for _, unit_number in pairs(entries_to_delete) do
        global.escapables[unit_number] = nil
    end
end

escapables.on_nth_tick = { [60] = update }

escapables.events = {
    [defines.events.on_robot_built_entity] = on_constructed,
    [defines.events.on_built_entity] = on_constructed,
    [defines.events.script_raised_built] = on_constructed,
    [defines.events.script_raised_revive] = on_constructed,
    [defines.events.on_entity_cloned] = on_constructed,

    [defines.events.on_player_mined_entity] = on_deconstructed,
    [defines.events.on_robot_mined_entity] = on_deconstructed,
    [defines.events.on_entity_died] = on_deconstructed,
    [defines.events.script_raised_destroy] = on_deconstructed,
}

function escapables.on_init(event)
    ---@type table<uint, Escapable>
    global.escapables = { }
end

function escapables.on_configuration_changed(event)
    sanitize_escapables()
end

return escapables