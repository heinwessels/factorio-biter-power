local config = require("config")

local bp_tech_1 = {
    type = "technology",
    name = "bp-biter-power-1",
    icon_size = 230,
    icon = "__biter-power__/graphics/technology/bp-tech-1.png",
    effects = {
        { type = "unlock-recipe", recipe = "bp-cage" },
        { type = "unlock-recipe", recipe = "bp-cage-trap" },
        { type = "unlock-recipe", recipe = "bp-generator" },
        { type = "unlock-recipe", recipe = "bp-incubator" },
        { type = "unlock-recipe", recipe = "bp-revitalization-center" },
        { type = "unlock-recipe", recipe = "bp-egg-extractor" },
    },
    prerequisites = {"steel-processing", "military"},
    unit = {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    order = "a-l-a"
}

local bp_tech_2 = {
  type = "technology",
  name = "bp-biter-power-2",
  icon_size = 230,
  icon = "__biter-power__/graphics/technology/bp-tech-2.png",
  effects = {
    { type = "unlock-recipe", recipe = "bp-generator-reinforced" },
  },
  prerequisites = {"bp-biter-power-1", "military-2", "sulfur-processing"},
  unit = {
    count = 100,
    ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1}
    },
    time = 30
  },
  order = "b-2-a"
}

for biter_name, biter_config in pairs(config.biter.types) do
  if biter_config.tier <= 2 then
    table.insert(bp_tech_1.effects, {type = "unlock-recipe", recipe = "bp-incubate-egg-"..biter_name})
    table.insert(bp_tech_1.effects, {type = "unlock-recipe", recipe = "bp-revitalization-"..biter_name})
  else
    table.insert(bp_tech_2.effects, {type = "unlock-recipe", recipe = "bp-incubate-egg-"..biter_name})
    table.insert(bp_tech_2.effects, {type = "unlock-recipe", recipe = "bp-revitalization-"..biter_name})
  end
end

data:extend{ bp_tech_1, bp_tech_2 }