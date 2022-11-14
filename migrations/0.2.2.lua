-- spawners don't natively create buried nests underneath
-- them on a place on the grid where a miner can reach it
-- So we need to shift all currently generated nests
local halfify = function(value) return math.floor(value) + 0.5 end
for _, surface in pairs(game.surfaces) do
    for _, nest in pairs(surface.find_entities_filtered{
            name = "bp-buried-biter-nest"}) do
        nest.teleport({halfify(nest.position.x), halfify(nest.position.y)})
    end
end