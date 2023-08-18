-- This will contain the entire config of the mod
-- to make sure everything as balanced as it should be

local util = require("util")

local config = {}

config.generator = {}
config.generator.power_output = 1e6
config.generator.emissions_per_minute = 0
config.generator.reinforced_multiplyer = 10

config.biter = {}
config.biter.fuel_value = config.generator.power_output * 2 * 60
config.biter.tired_modifier = 10
config.biter.tired_fuel_value = config.biter.fuel_value / config.biter.tired_modifier
config.biter.burn_time = config.biter.fuel_value / config.generator.power_output
config.biter.egg_stack_size = 20
config.biter.egg_to_biter_ratio = 5

config.incubator = {}
config.incubator.power_usage = 200e3
config.incubator.number_per_generator = 1 / 10
config.incubator.success_rate = 1
config.incubator.emissions_per_minute = -200 -- Note: K2 air purifier is -75, and there will be much less incubators
config.incubator.ingredients = {
    {"bp-biter-egg", 1},
    {"bp-cage", 1}
}
config.incubator.biter_birth_probability = config.incubator.success_rate / config.biter.egg_to_biter_ratio

config.revitalization = {}
config.revitalization.power_usage = 100e3
config.revitalization.number_per_generator = 1 / 20 
config.revitalization.success_rate = 0.9
config.revitalization.egg_drop_rate = 0 -- Disable it for now, it's too complicated.
config.revitalization.time = config.biter.burn_time * config.revitalization.number_per_generator
config.revitalization.emissions_per_minute = 4  -- Just like assembler 1
config.revitalization.results = {
    {
        name = "bp-caged-",
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
config.buried_nest.power_output = 20e6
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
config.egg_extractor.emmisions_equivalent_modifier = 0  -- emmision neutral for now
config.egg_extractor.emissions_per_minute = 
        (config.buried_nest.power_output) / 900e3   -- amount of steam engines
        / 2 * 30                                    -- emmisions of equivalent boilers required
        * config.egg_extractor.emmisions_equivalent_modifier    -- scale equivalent emissions
        - (config.buried_nest.generators_supported      -- account for incubators
           * config.incubator.number_per_generator      -- Number of incubators per nest
           * config.incubator.emissions_per_minute)
        - (config.buried_nest.generators_supported      -- account for revitalization
           * config.revitalization.number_per_generator -- Number of incubators per nest
           * config.revitalization.emissions_per_minute)
        - (config.buried_nest.generators_supported      -- account for generators
           * config.generator.emissions_per_minute)
        

config.escapes = { }
config.escapes.escapable_machine = {
    -- The 'value' is a multiplier for biters' escape_period
    ["bp-generator"] = 1,
    ["bp-generator-reinforced"] = 0.5,
    ["bp-revitalizer"] = 1,
}



-- We hardcode some tiers, so then it's all easier to manage. It's
-- all based on tiers anyway, and we still have the power to customise
-- individial units. We will define all here, even for modded cases
config.biter.tiers = {
    [1] = {
        energy_modifer = 0.8,
        density_modifier = 0.8,
        escape_period = 60 * 60 * 60 * 4,
    },
    [2] = {
        energy_modifer = 1,
        density_modifier = 1,
        escape_period = 60 * 60 * 60 * 3.5,
    },
    [3] = {
        energy_modifer = 2,
        density_modifier = 2,
        escape_period = 60 * 60 * 60 * 3,
    },
    [4] = {
        energy_modifer = 3,
        density_modifier = 3,
        escape_period = 60 * 60 * 60 * 2,
    },
    [5] = {
        energy_modifer = 4,
        density_modifier = 4,
        escape_period = 60 * 60 * 60 * 1,
    },
    [6] = {
        energy_modifer = 5,
        density_modifier = 5,
        escape_period = 60 * 60 * 30,
    },
    [7] = {
        energy_modifer = 6,
        density_modifier = 6,
        escape_period = 60 * 60 * 20,
    },
    [8] = {
        energy_modifer = 7,
        density_modifier = 7,
        escape_period = 60 * 60 * 15,
    },
}

-- Here we define the different biter types. All stats
-- will be relative to the base values because I don't 
-- want the calculations to be that complicated.
--  The 'escape_period' is the average time it will take 
--  for a single escape from a single machine in ticks
-- Note: tint is optional
config.biter.types = {
    ["small-biter"] = {
        tier = 1,
        tint = {r=0.9 , g=0.83, b=0.54, a=1},
    },
    ["medium-biter"] = {
        tier = 2,
        tint = {r=0.93, g=0.72, b=0.72, a=1},
    },
    ["big-biter"] = {
        tier = 3,
        tint = {r=0.55, g=0.76, b=0.75, a=1},   
    },
    ["behemoth-biter"] = {
        tier = 4,
        tint = {r = 0.657, g = 0.95, b = 0.432, a = 1.000},
    },

    -- We will copy from here on to keep changing things easy.
    ["small-spitter"] = {
        copy = "small-biter",
        tint = {r=0.91 , g=0.92 , b=0.87 , a=1 },
    },
    ["medium-spitter"] = {
        copy = "medium-biter",
        tint = {r=0.89 , g=0.84 , b=0.85 , a=1 },
    },
    ["big-spitter"] = {
        copy = "big-biter",
        tint = {r=0.8  , g=0.82 , b=0.85 , a=1 },
    },
    ["behemoth-spitter"] = {
        copy = "behemoth-biter",
        tint = {r = 0.7, g = 0.95, b = 0.4, a = 1.000},  
    },
}


-----------------------------------------------
--[[        Here we add modded biters        ]] 
-----------------------------------------------
local leviathan_tier = 4 -- Which tier leviathan is, depends on Bob.
local enabled_mods = mods or script.active_mods

if enabled_mods["bobenemies"] then
    -- We don't add Bob's biters here, because that means it's icons
    -- will be used for techs, and the icons are ugly. So if we can,
    -- rather use MFerarri's or Armoured Biter's.
    leviathan_tier = 8
end

if enabled_mods["Explosive_biters"] then
    config.biter.types["small-explosive-biter"] = {copy = "small-biter"}
    config.biter.types["medium-explosive-biter"] = {copy = "medium-biter"}
    config.biter.types["big-explosive-biter"] = {copy = "big-biter"}
    config.biter.types["behemoth-explosive-biter"] = {copy = "behemoth-biter"}
    config.biter.types["explosive-leviathan-biter"] = {tier = leviathan_tier}
    
    config.biter.types["small-explosive-spitter"] = {copy = "small-spitter"}
    config.biter.types["medium-explosive-spitter"] = {copy = "medium-spitter"}
    config.biter.types["big-explosive-spitter"] = {copy = "big-spitter"}
    config.biter.types["behemoth-explosive-spitter"] = {copy = "behemoth-spitter"}
    config.biter.types["leviathan-explosive-spitter"] = {copy = "explosive-leviathan-biter"}
end

if enabled_mods["Cold_biters"] then
    config.biter.types["small-cold-biter"] = {copy = "small-biter"}
    config.biter.types["medium-cold-biter"] = {copy = "medium-biter"}
    config.biter.types["big-cold-biter"] = {copy = "big-biter"}
    config.biter.types["behemoth-cold-biter"] = {copy = "behemoth-biter"}
    config.biter.types["leviathan-cold-biter"] = {tier = leviathan_tier}
    
    config.biter.types["small-cold-spitter"] = {copy = "small-spitter"}
    config.biter.types["medium-cold-spitter"] = {copy = "medium-spitter"}
    config.biter.types["big-cold-spitter"] = {copy = "big-spitter"}
    config.biter.types["behemoth-cold-spitter"] = {copy = "behemoth-spitter"}
    config.biter.types["leviathan-cold-spitter"] = {copy = "leviathan-cold-biter"}
end


if enabled_mods["Toxic_biters"] then
    config.biter.types["small-toxic-biter"] = {copy = "small-biter"}
    config.biter.types["medium-toxic-biter"] = {copy = "medium-biter"}
    config.biter.types["big-toxic-biter"] = {copy = "big-biter"}
    config.biter.types["behemoth-toxic-biter"] = {copy = "behemoth-biter"}
    config.biter.types["leviathan-toxic-biter"] = {tier = leviathan_tier}
    
    config.biter.types["small-toxic-spitter"] = {copy = "small-spitter"}
    config.biter.types["medium-toxic-spitter"] = {copy = "medium-spitter"}
    config.biter.types["big-toxic-spitter"] = {copy = "big-spitter"}
    config.biter.types["behemoth-toxic-spitter"] = {copy = "behemoth-spitter"}
    config.biter.types["leviathan-toxic-spitter"] = {copy = "leviathan-toxic-biter"}
end

if enabled_mods["ArmouredBiters"] then
    config.biter.types["small-armoured-biter"] = {copy = "small-biter"}
    config.biter.types["medium-armoured-biter"] = {copy = "medium-biter"}
    config.biter.types["big-armoured-biter"] = {copy = "big-biter"}
    config.biter.types["behemoth-armoured-biter"] = {copy = "behemoth-biter"}
    config.biter.types["leviathan-armoured-biter"] = {tier = leviathan_tier}
end

if enabled_mods["bobenemies"] then
    config.biter.types["behemoth-biter"].tier = 7   -- Something bob does. This will also change our biter

    config.biter.types["bob-big-piercing-biter"] =      {tier = 3}    
    config.biter.types["bob-huge-acid-biter"] =         {tier = 4}
    config.biter.types["bob-huge-explosive-biter"] =    {tier = 4}
    config.biter.types["bob-giant-fire-biter"] =        {tier = 5}
    config.biter.types["bob-giant-poison-biter"] =      {tier = 5}
    config.biter.types["bob-titan-biter"] =             {tier = 6}
    config.biter.types["bob-behemoth-biter"] =          {tier = 7}
    config.biter.types["bob-leviathan-biter"] =         {tier = leviathan_tier}

    config.biter.types["bob-big-electric-spitter"] =    {tier = 3}
    config.biter.types["bob-huge-acid-spitter"] =       {tier = 4}
    config.biter.types["bob-huge-explosive-spitter"] =  {tier = 4}
    config.biter.types["bob-giant-fire-spitter"] =      {tier = 5}
    config.biter.types["bob-giant-poison-spitter"] =    {tier = 5}
    config.biter.types["bob-titan-spitter"] =           {tier = 6}
    config.biter.types["bob-behemoth-spitter"] =        {tier = 7}
    config.biter.types["bob-leviathan-spitter"] =       {tier = leviathan_tier}
end

-----------------------------------------------

-- We can base modded biters on the vanilla variants. Here we
-- loop through the current config and see if we should handle those
-- cases now
for biter_name, biter_config in pairs(config.biter.types) do

    -- Some biter's config might be based on other's
    if biter_config.copy then
        local biter_config_to_copy = config.biter.types[biter_config.copy]
        if not biter_config_to_copy then error("Biter config to copy '"..biter_config.copy.."' does not exist!") end
        biter_config.copy = nil
        config.biter.types[biter_name] = util.merge{biter_config_to_copy, biter_config}
    end

    -- Now add all the tier information for ease-of-use
    config.biter.types[biter_name] = util.merge{config.biter.types[biter_name], config.biter.tiers[biter_config.tier]}
end


-- If we're in the data-stage then it's useful to find biter icon information here
-- because we will use it in quite a few occations.
if data and data.raw then
    for biter_name, biter_config in pairs(config.biter.types) do
        local unit = data.raw.unit[biter_name]
        if not unit then error("No '"..biter_name.."'unit found!") end
        if unit.icons then -- Takes precedence according to docs            
            biter_config.icons = util.copy(unit.icons)
            
            for _, icon in pairs(biter_config.icons) do
                -- Remove any scaling, because it doesn't
                -- look right on the item recipe's etc.
                -- Specifically Explosive Biters
                -- Might cause weird issues on weird icons, 
                -- but we don't support such biters now.
                icon.scale = 0.5 -- Not sure yet why 0.5?
            end
        else
            biter_config.icons = {
                {
                    icon = unit.icon,
                    icon_size = unit.icon_size,
                    icon_mipmaps = unit.icon_mipmaps,                    
                }
            }
        end
    end
end

-- Calculate the amount of tiers we have defined
config.biter.max_tier = 0
for biter_name, biter_config in pairs(config.biter.types) do
    if biter_config.tier > config.biter.max_tier then
        config.biter.max_tier = biter_config.tier
    end
end
if config.biter.max_tier == 0 then error("No tiers found! This should never happen") end

return config