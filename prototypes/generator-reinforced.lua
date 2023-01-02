local config = require("config")
local util = require("util")
local lib = require("lib.lib")

local generator = data.raw["burner-generator"]["bp-generator"]
local reinforced_generator = util.table.deepcopy(generator)

reinforced_generator.name = "bp-generator-reinforced"
reinforced_generator.localised_description = {"",
  {"entity-description.bp-generator"},
  {"bp-text.escape-modifier", config.escapes.escapable_machine["bp-generator-reinforced"]},
}
reinforced_generator.icon = "__biter-power__/graphics/generator/reinforced-icon.png"
reinforced_generator.max_power_output = util.format_number(config.generator.power_output * config.generator.reinforced_multiplyer, true).."W"
reinforced_generator.minable.result = "bp-generator-reinforced"
reinforced_generator.fast_replaceable_group = "bp-generators"
reinforced_generator.burner.fuel_category = nil
reinforced_generator.burner.fuel_categories = {"bp-biter-power", "bp-biter-power-advanced"}

-- Update graphics
local mask_layer = util.table.deepcopy(reinforced_generator.animation.layers[1])
mask_layer.filename = "__biter-power__/graphics/generator/generator-reinforced-mask.png"
mask_layer.hr_version.filename = "__biter-power__/graphics/generator/generator-reinforced-mask.png"
local replace_files = {
  ["__base__/graphics/entity/transport-belt/transport-belt.png"] = 
    "__base__/graphics/entity/express-transport-belt/express-transport-belt.png",
  ["__base__/graphics/entity/transport-belt/hr-transport-belt.png"] = 
    "__base__/graphics/entity/express-transport-belt/hr-express-transport-belt.png"
}
for _, property in pairs({"idle_animation", "animation"}) do
  local layers = reinforced_generator[property].layers
  for _, layer in pairs(layers) do

    -- Change transport belts to blue ones
    local replace_file = replace_files[layer.filename]
    if replace_file then
      layer.filename = replace_file
      layer.hr_version.filename = replace_files[layer.hr_version.filename]
    end

    -- Change the tinted biter mask to blue
    if layer.tint then
      layer.tint = {0.21, 0.4, 1}
      layer.hr_version.tint = {0.21, 0.4, 1} 
    end
  end
  table.insert(layers, mask_layer)
end

-- Add the new generator
data:extend{
  reinforced_generator,
  {
    type = "item",
    name = "bp-generator-reinforced",
    icon = "__biter-power__/graphics/generator/reinforced-icon.png",
    icon_size = 64,
    subgroup = "bp-biter-machines",
    order = "c[generator]",
    place_result = "bp-generator-reinforced",
    stack_size = 20
  },
  {
    type = "recipe",
    name = "bp-generator-reinforced",
    enabled = false,
    ingredients =
    {
      {"bp-generator", 1},
      {"advanced-circuit", 3},
      {"steel-plate", 2}
    },
    result = "bp-generator-reinforced"
  },
}