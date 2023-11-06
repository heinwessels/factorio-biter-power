if not config then error("No config found!") end

local bp_tech = {
    type = "technology",
    name = "bp-biter-power",
    icon_size = 230,
    icon = "__biter-power__/graphics/technology/bp-tech-1.png",
    effects = {
        { type = "unlock-recipe", recipe = "bp-cage" },
        { type = "unlock-recipe", recipe = "bp-cage-trap" },
        { type = "unlock-recipe", recipe = "bp-generator" },
        { type = "unlock-recipe", recipe = "bp-incubator" },
        { type = "unlock-recipe", recipe = "bp-revitalizer" },
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

local bp_tech_advanced = {
  type = "technology",
  name = "bp-biter-power-advanced",
  icon_size = 230,
  icon = "__biter-power__/graphics/technology/bp-tech-2.png",
  effects = {
    { type = "unlock-recipe", recipe = "bp-generator-reinforced" },
    { type = "unlock-recipe", recipe = "bp-cage-projectile" },
    { type = "unlock-recipe", recipe = "bp-cage-cannon" },
  },
  prerequisites = {"bp-biter-power", "military-2", "sulfur-processing"},
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

data:extend{ bp_tech, bp_tech_advanced }

data:extend{
  {
    type = "tool",
    name = "bp-capture",
    order = "z",
    icon = "__biter-power__/graphics/cage-trap/icon.png",
    icon_size = 64,
    subgroup = "bp-husbandry-intermediates",
    stack_size = 1,
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value"
  }
}

local function generate_tech_tier(tier)
  local tech = {
    type = "technology",
    name = "bp-biter-capture-tier-"..tier,
    icons = {
      {
        icon = "__biter-power__/graphics/cage/icon.png",
        icon_size = 64,
      },
    },
    icon_size = 230,
    effects = { },
    prerequisites = { },
    unit = {
      count = 1,
      ingredients = { {"bp-capture", 1}, },
      time = 1
    },
    order = "b-2-a-"..tier
  }

  for biter_name, biter_config in pairs(config.biter.types) do
    if biter_config.tier == tier then
      table.insert(tech.effects, {type = "unlock-recipe", recipe = "bp-incubate-egg-"..biter_name})
      table.insert(tech.effects, {type = "unlock-recipe", recipe = "bp-revitalization-"..biter_name})

      -- Only add the icon if we haven't already handled this tier.
      if #tech.icons == 1 then
        for _, icon in pairs(biter_config.icons) do
          -- Scale each icon to the cage icon
          local icon_copy = util.copy(icon)
          icon_copy.scale = icon_copy.scale or 1
          icon_copy.scale = icon_copy.scale * (64 / icon_copy.icon_size)
          table.insert(tech.icons, icon_copy)
        end
      end
    end
  end

  return tech
end

for tier = 1, config.biter.max_tier do
  local tech = generate_tech_tier(tier)
  if tier > 1 then
    table.insert(tech.prerequisites, "bp-biter-capture-tier-"..(tier - 1))
    if tier == 3 then
      -- Everything from tier three requires advanced biter power. We
      -- only have to add it once though
      table.insert(tech.prerequisites, "bp-biter-power-advanced")
    end
  else
    table.insert(tech.prerequisites, "bp-biter-power")
  end
  data:extend{ tech }
end
