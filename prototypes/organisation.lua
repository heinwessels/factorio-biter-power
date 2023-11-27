-- This file sets up some orgganisational things like item groups etc

data:extend{
    {   -- The row that the biter related machines will be, i.e. treadmill, incubator, etc.
        type = "item-subgroup",
        name = "bp-biter-machines",
        group = "production",
        order = "m"
    },
    {   -- A separate tab for all the biter information
        -- This will never be visisble, as only used for Incubator and Revitalizer
        type = "item-group",
        name = "biter-power-husbandry",
        order = "p",
        order_in_recipe = "0",
        icon = "__biter-power__/graphics/husbundry-item-group.png",
        icon_size = 128,
    },
    {
        type = "item-subgroup",
        name = "bp-husbandry-intermediates",
        group = "biter-power-husbandry",
        order = "[a]"
    },
    {   -- The row that the "peacekeeping" devices will be in the military (Defense?) tab
        type = "item-subgroup",
        name = "bp-peacekeeping",
        group = "combat",
        order = "p"
    },
}