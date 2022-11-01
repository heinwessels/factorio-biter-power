data:extend({
    {
        type = "item",
        name = "bp-biter-cage",
        icon = "__BiterPower__/graphics/cage/icon.png",
        icon_size = 64,
        subgroup = "bp-biters",
        order = "b[biter-cage]",
        stack_size = 20
    },
    {
        type = "recipe",
        name = "bp-biter-cage",
        icon = "__BiterPower__/graphics/cage/icon.png",
        icon_size = 64,
        ingredients = {
            {"steel-plate", 100},
            {"copper-cable", 20},
        },
        result = "bp-biter-cage"
    },
})