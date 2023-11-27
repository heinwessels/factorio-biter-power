data:extend({
    {
        type = "item",
        name = "bp-cage",
        icon = "__biter-power__/graphics/cage/icon.png",
        icon_size = 64,
        subgroup = "bp-peacekeeping",
        order = "b[biter-cage]",
        stack_size = 20
    },
    {
        type = "recipe",
        name = "bp-cage",
        icon = "__biter-power__/graphics/cage/icon.png",
        icon_size = 64,
        ingredients = {
            {"steel-plate", 20},
            {"copper-cable", 20},
        },
        result = "bp-cage"
    },
})