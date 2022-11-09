local bp_tech = {
    type = "technology",
    name = "bp-biter-power",
    icon_size = 230,
    icon = "__biter-power__/graphics/technology/bp-tech.png",
    effects = {
        { type = "unlock-recipe", recipe = "bp-cage" },
        { type = "unlock-recipe", recipe = "bp-cage-trap" },
        { type = "unlock-recipe", recipe = "bp-generator" },
        { type = "unlock-recipe", recipe = "bp-incubator" },
        { type = "unlock-recipe", recipe = "bp-revitalization-center" },
        { type = "unlock-recipe", recipe = "bp-relocation-center" },
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

data:extend{ bp_tech }