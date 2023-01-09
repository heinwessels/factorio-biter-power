for index, force in pairs(game.forces) do
    force.reset_technology_effects()

    -- If player had biter-power researched previously, and have 
    -- produced or captured caged biters, then unlock first tech
    if force.technologies["bp-biter-power"].researched then
        local statistics = force.item_production_statistics
        if statistics.get_input_count("bp-caged-small-biter") > 0 then
            force.technologies["bp-biter-capture-tier-1"].researched = true
        end
    end
end

