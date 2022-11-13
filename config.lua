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
config.generator.power_output = 1e6

config.biter = {}
config.biter.fuel_value = config.generator.power_output * 30
config.biter.tired_fuel_value = config.biter.fuel_value / 10
config.biter.burn_time = config.biter.fuel_value / config.generator.power_output
config.biter.egg_stack_size = 20
config.biter.egg_to_biter_ratio = 10

config.incubator = {}
config.incubator.power_usage = 200e3
config.incubator.number_per_generator = 1 / 5
config.incubator.success_rate = 1
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
config.revitalization.power_usage = 100e3
config.revitalization.number_per_generator = 1 / 10 
config.revitalization.success_rate = 0.9
config.revitalization.egg_drop_rate = 0 -- Disable it for now, it's too complicated.
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
if config.revitalization.egg_drop_rate == 0 then config.revitalization.results[2] = nil end -- Remove entry from products in tooltip if not used

-- The Factorio normal-tired-normal cycle effiency
config.biter.loop_efficiency =  config.revitalization.success_rate * (1*(1-config.revitalization.egg_drop_rate) + config.incubator.success_rate*config.revitalization.egg_drop_rate)

-- Calculate an biter's effective fuel value if recycled
-- This is approximate, as it doesn't take into account that 
-- `config.incubator.success_rate` actually plays a smaller role
config.biter.fuel_value_net = 0
local multiplier = 1
for i = 1,50 do -- Simulate recycling loop. This will converge on a specific value
    config.biter.fuel_value_net = config.biter.fuel_value_net + multiplier * config.biter.fuel_value
    multiplier = multiplier * config.biter.loop_efficiency
end

config.biter.consumed_per_watt --[[per second]] = 1 / config.biter.fuel_value   -- Not `net` value, because we're counting the life-cycle.
config.biter.loss_per_watt --[[per second]]  = config.biter.consumed_per_watt * (1 - config.biter.loop_efficiency)        

-- Incubator must keep up to supply the specified generators
config.incubator.duration = 1 / (
        (config.generator.power_output / config.incubator.number_per_generator)     -- total power that needs to be supplied
        * config.biter.loss_per_watt)                                               -- biters lost per second for number of generators
        / config.biter.egg_to_biter_ratio                                           -- scale to eggs, not biters!
        / (1 + (1 - config.incubator.success_rate))                                 -- scale for success rate
config.incubator.duration = tonumber(string.format("%.0f", config.incubator.duration))

config.buried_nest = {}
-- Scale the buried nest to account for productivity, and scale it so math checks out at full productivity 
config.buried_nest.productivity_scaler = 0.4 -- 40% is maximum before infinite sciences 
config.buried_nest.spawn_chance = 1 / 10
config.buried_nest.power_capacity = 100e6 * (3600 * 10) -- In Joule
config.buried_nest.spawn_amount = 
        config.buried_nest.power_capacity 
        / config.biter.fuel_value_net 
        * config.biter.egg_to_biter_ratio 
        / (1+config.buried_nest.productivity_scaler )
config.buried_nest.power_output = 10e6
config.buried_nest.generators_supported = config.buried_nest.power_output / config.generator.power_output
config.buried_nest.eggs_per_second = 
        (config.generator.power_output * config.buried_nest.generators_supported)   -- total power that needs to be supplied
        * config.biter.loss_per_watt                                                -- biters per second
        * config.biter.egg_to_biter_ratio                                           -- eggs per second             
        / (1 + config.buried_nest.productivity_scaler)                              -- eggs per second scaled to 40% productivity
        * (1 + (1 - config.incubator.success_rate))                                 -- scale for incubator success rate (not included in loss-per-watt)
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

config.egg_extractor = {}
-- Speed is set here because it's more intuitive and
-- easy for the player to see
config.egg_extractor.mining_speed = config.buried_nest.eggs_per_second
config.egg_extractor.mining_speed = 
        tonumber(string.format("%.3f", config.egg_extractor.mining_speed))

config.escapes = { }
config.escapes.escapable_machine = {
    -- The 'value' is the average time it will take 
    -- for a single escape from a single machine in ticks
    ["bp-generator"] = 60 * 60 * 60 * 2,
    ["bp-revitalization-center"] = 60 * 60 * 30,
}

return config