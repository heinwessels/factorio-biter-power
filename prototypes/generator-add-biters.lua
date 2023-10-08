-- Add a new generator version for each supported biter. It will look really cool

local config = require("config")
local util = require("util")

local function get_biter_run_animation(biter)
    local layers = util.table.deepcopy(biter.run_animation.layers)
    local has_hr = layers[1].hr_version ~= nil
    
    -- These animations are for all for directions. Extract only
    -- the one that runs to the right, which is number 2
    local index = 2
    for _, layer in pairs(layers) do
        layer.filename = layer.filenames[index]

        if has_hr then 
            layer.hr_version.filename = layer.hr_version.filenames[index]
        end

        for _, field in pairs{
            "filenames", 
            "lines_per_file",
            "direction_count", 
            "slice",
        } do
            layer[field] = nil
            if has_hr then layer.hr_version[field] = nil end
        end
    end

    -- Likely one of these layers are a shadow layer. 
    --  Remove the draw_as_shadow so it's drawn in order
    --  Ensure that layer is drawn at the bottom.
    local shadow_layer = nil
    for layer_index, layer in pairs(layers) do
        if layer.draw_as_shadow then
            shadow_layer = layer
            layers[layer_index] = nil -- Remove from here
            break
        end
    end
    if shadow_layer then
        table.insert(layers, 1, shadow_layer)
    end

    -- Make shadow slightly opague
    local tint = {r=0,g=0,b=0,a=0.5}
    shadow_layer.tint = tint
    shadow_layer.draw_as_shadow = nil
    if has_hr then
        shadow_layer.hr_version.tint = tint
        shadow_layer.hr_version.draw_as_shadow = nil
    end

    return layers
end

local function shift_layer_with_scale(layer, scale, shift)
    local old_scale = layer.scale or 1
    local normalized_shift = util.mul_shift(layer.shift, 1 / old_scale)
    layer.scale = scale * old_scale
    layer.shift = util.mul_shift(normalized_shift, layer.scale)
    layer.shift = util.add_shift(layer.shift, shift)
end

local function determine_scale(layers)
    -- All biters will be at least this amount smaller
    local base_scale = 0.5

    local biter_scale = layers[1].scale
    -- Determine roughly the width of the biter
    local biter_width = 0
    for _, layer in pairs(layers) do
        biter_width = biter_width + layer.width
    end
    biter_width = (biter_width / #layers) * biter_scale

    local maximum_width = 80 -- This is how big the gap is roughly
    if biter_width * base_scale > maximum_width then
        -- Clip the biter size at the maximum
        return maximum_width / biter_width
    else
        -- Keep biter the same size
        return base_scale
    end
end

local function create_variant(base_name, biter_name)
    local generator = util.table.deepcopy(data.raw["burner-generator"][base_name])
    if not generator then error("Generator '"..base_name.."' not found!") end
    local biter = data.raw.unit[biter_name]
    if not biter then error("Unit '"..biter_name.."' not found!") end

    generator.name = base_name.."-"..biter_name
    generator.localised_name = {"entity-name."..base_name}
    
    -- Get biter animations and adjust them
    local biter_shift = {-0.45, -0.1}
    local layers_to_add = get_biter_run_animation(biter)
    local biter_scale = determine_scale(layers_to_add)
    for _, layer in pairs(layers_to_add) do
        shift_layer_with_scale(layer, biter_scale, biter_shift)
        if layer.hr_version then
            shift_layer_with_scale(layer.hr_version, biter_scale, biter_shift)
        end
    end
    
    -- Add biter animations to generator
    for _, property in pairs({"idle_animation", "animation"}) do
        local base_layers = generator[property].layers

        -- Take off cover
        local cover_layer = base_layers[#base_layers]
        base_layers[#base_layers] = nil       

        -- Add biter
        for _, layer in pairs(layers_to_add) do
            table.insert(base_layers, layer)
        end

        -- Add cover back on
        table.insert(base_layers, cover_layer)
    end

    data:extend{ generator }
end

for biter_name, biter_config in pairs(config.biter.types) do
    create_variant("bp-generator", biter_name)
    create_variant("bp-generator-reinforced", biter_name)
end