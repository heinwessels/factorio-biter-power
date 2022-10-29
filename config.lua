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
config.biter = {
    fuel_value = "100MJ",
    tired_fuel_value = "10MJ",

    egg_stack_size = 50,
    egg_to_biter_ratio = 100,
}

config.generator = {
    power_output = "2MW"
}

config.incubator = {
    success_rate = 0.9,
    duration = 60*10,
}

config.revitalization = {
    success_rate = 0.8,
    time = 60,
    egg_drop_rate = 0.1,
}


-- Each unit in the resource will result in one egg. This means
-- the results can't average more than one egg.
config.buried_nest = {}
config.buried_nest.eggs_per_second = 5 / 60 -- Results in sustained 20MW currently
config.buried_nest.productivity_scaler = 0.4 -- 40% is maximum before infinite sciences
 -- Actual rate is set on drill
config.buried_nest.mining_time = 1
config.buried_nest.results = {
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
        
return config