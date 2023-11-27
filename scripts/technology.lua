local config = require("config")

local technology = {
    ---@type table<string, boolean>
    is_husbandry_technology = { },

    ---@type table<integer, string[]>
    biters_in_tier = { },
}

-- Cache some useful information while the game loads
-------------------------------------------------------------------------
for biter_name, biter_config in pairs(config.biter.types) do
    technology.biters_in_tier[biter_config.tier] =
            technology.biters_in_tier[biter_config.tier] or { }
    table.insert(technology.biters_in_tier[biter_config.tier], biter_name)
end

for tier = 1, config.biter.max_tier do 
    technology.is_husbandry_technology["bp-biter-capture-tier-"..tier] = true
end
-------------------------------------------------------------------------

--- @param tech LuaTechnology
--- @param biter_name string?
--- @param force_unlock boolean?
function technology.attemp_tiered_technology_unlock(tech, biter_name, force_unlock)
    if tech.researched then return end

    local prereqs_satisfied = true
    for prereq_name, prereq in pairs(tech.prerequisites) do
        if force_unlock and not prereq.researched and technology.is_husbandry_technology[prereq_name] then
            -- We will recursively unlock earlier husbandry techs if a later
            -- tier biter is caught. This is to prevent a deadlock if a player
            -- only adds this mod in the late game. It also makes sense.
            technology.attemp_tiered_technology_unlock(prereq, biter_name, true)
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
        for _, biter_name in pairs(technology.biters_in_tier[tech.level]) do
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

--- @param event EventData.on_research_cancelled
local function on_research_started(event)
    local tech = event.research
    if technology.is_husbandry_technology[tech.name] then
        -- This is so that if a player chooses to research the tech it could be unlocked
        -- if the player somehow already captured the biters before.
        -- this command will silently be ignored if the tech couldn't be researched
        technology.attemp_tiered_technology_unlock(tech)
    end
end


technology.events = {
    [defines.events.on_research_started] = on_research_started,
}

return technology