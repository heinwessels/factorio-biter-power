-- This will contain the entire config of the mod
-- to make sure everything as balanced as it should be

-- African Bois
--  Killed 60 spawners
--  Pulling 18MW

-- Walvis Craft
--  Killed 250 spawners
--  Pulling 20MW

-- Fluidic Spaghetti Base
--  Killed 250 spawners
--  Pulling 600MW

-- We will go with finite buried-nests. We can dynamically allocate how
-- much eggs can be inside a nest, giving us ok control of the flow
-- of biter power.

local config = {}

config.generator = {}
config.generator.power_output = 500e3

config.biter = {}
config.biter.fuel_value = config.generator.power_output * 60 * 5
config.biter.tired_fuel_value = config.biter.fuel_value / 10
config.biter.burn_time = config.biter.fuel_value / config.generator.power_output
config.biter.egg_stack_size = 20
config.biter.egg_to_biter_ratio = 10

config.incubator = {}
config.incubator.power_usage = 75e3
config.incubator.number_per_generator = 1 / 2
config.incubator.success_rate = 0.9
config.incubator.duration = config.biter.burn_time * config.incubator.number_per_generator
config.incubator.ingredients = {
    -- {"bp-biter-egg", config.biter.egg_to_biter_ratio},
    {"bp-biter-egg", 1},
    {"bp-cage", 1}
}
config.incubator.results = {
    {
        name = "bp-caged-biter",
        probability = config.incubator.success_rate / config.biter.egg_to_biter_ratio,
        amount = 1,
    },
    {
        name = "bp-cage",
        probability = 1 - (config.incubator.success_rate / config.biter.egg_to_biter_ratio),
        amount = 1,
    }
}

config.revitalization = {}
config.revitalization.power_usage = 75e3
config.revitalization.number_per_generator = 1 / 10
config.revitalization.success_rate = 0.8
config.revitalization.egg_drop_rate = 0.1
config.revitalization.time = config.biter.burn_time * config.revitalization.number_per_generator
config.revitalization.results = {
    {
        name = "bp-caged-biter",
        probability = config.revitalization.success_rate * (1 - config.revitalization.egg_drop_rate),
        amount = 1,
    },
    {
        name = "bp-biter-egg",
        -- amount_min = 0,
        -- Equal to dropping enough eggs for one biter when `success` and but didn't drop actual biter
        -- amount_max = 2 * config.revitalization.success_rate * config.revitalization.egg_drop_rate * config.biter.egg_to_biter_ratio,
        
        -- This works better if the number is less than 1
        amount = 1,
        probability = config.revitalization.success_rate * config.revitalization.egg_drop_rate * config.biter.egg_to_biter_ratio,
    }
}
if config.revitalization.results[2].probability and config.revitalization.results[2].probability > 1 then error("Probability above 1") end
if config.revitalization.results[2].amount_max and config.revitalization.results[2].amount_max < 5 then error("Probability amount_max too small") end

-- Calculate an biter's effective fuel value if recycled
config.biter.fuel_value_net = 0
local multiplier = 1
for i = 1,50 do -- Simulate recycling loop. This will converge on a specific value
    config.biter.fuel_value_net = config.biter.fuel_value_net + multiplier * config.biter.fuel_value
    multiplier = multiplier * config.revitalization.success_rate * config.incubator.success_rate
end

config.buried_nest = {}
config.buried_nest.spawn_chance = 1 / 10
config.buried_nest.spawn_amount = 1000 * config.biter.egg_to_biter_ratio
config.buried_nest.generators_supported = 10
-- Scale the buried nest to account for productivity, and scale it so math checks out at full productivity 
config.buried_nest.productivity_scaler = 0.4 -- 40% is maximum before infinite sciences 
config.buried_nest.eggs_per_second = 
        config.generator.power_output / config.biter.fuel_value_net --  biters required per second per generator
        * config.biter.egg_to_biter_ratio * config.buried_nest.generators_supported
        / (1 + config.buried_nest.productivity_scaler)
config.buried_nest.mining_time = 1 -- Actual rate is set on drill
config.buried_nest.results = {
    -- Each unit in the resource will result in one egg. This means
    -- the results can't average more than one egg.
    {
        name = "bp-biter-egg",
        amount_min = 1,
        amount_max = 1,
        probability = 1
    },
}

config.relocation_center = {}
-- Speed is set here because it's more intuitive and
-- easy for the player to see
config.relocation_center.mining_speed = 
        config.buried_nest.eggs_per_second
        / (1 + config.buried_nest.productivity_scaler)
config.relocation_center.mining_speed = 
        tonumber(string.format("%.3f", config.relocation_center.mining_speed))

config.escapes = { }
config.escapes.escapable_machine = {
    -- The 'value' is the average time it will take 
    -- for a single escape from a single machine in ticks
    ["bp-generator"] = 60 * 60 * 60 * 2,
    ["bp-revitalization-center"] = 60 * 60 * 30,
}

return config