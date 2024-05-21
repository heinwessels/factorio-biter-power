local config = require("config")
local technology = require("scripts.technology")

local trapping = { }
local biter_configs = config.biter.types

---This function is called by the Cage Trap and Cage Cannon
---@param event EventData.on_script_trigger_effect
local function attempt_trapping_biter(event)
    if event.effect_id ~= "bp-cage-trap-trigger" then return end
    local trap = event.source_entity -- Could also be the cage cannon
    if not trap then return end
    local biter = event.target_entity
    if not biter then return end
    local biter_config = biter_configs[biter.name]
    if not biter_config then return end  -- Will lose the cage shooting at other things

    --- If this biter still has enough health to fight it has a chance of not being caught.
    --- At this point the damage from the projectile is not applied yet, which is a little
    --- wonky. But it leaves the possibiliy that the biter might die which is cool.
    if biter.get_health_ratio() > 0.25 and math.random() > biter_config.trapping_chance then
        -- This biter successfully escaped!
        return
    end

    local caged_name = "bp-caged-"..biter.name
    local force = trap.force ---@cast force LuaForce
    biter.surface.spill_item_stack(biter.position, {name=caged_name}, true, force)
    trap.force.item_production_statistics.on_flow(caged_name, 1)
    technology.attemp_tiered_technology_unlock(force.technologies["bp-biter-capture-tier-"..biter_config.tier], biter.name, true)
    biter.destroy{raise_destroy = true}
end

trapping.events = {
    [defines.events.on_script_trigger_effect] = attempt_trapping_biter,
}

return trapping