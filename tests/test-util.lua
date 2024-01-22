local test_util = { }

local pre = "Assertion failed: "

---@return LuaSurface
function test_util.get_surface() return game.surfaces.nauvis end

---@return LuaSurface
function test_util.reset_surface()
    local surface = test_util.get_surface()

    -- Clear the surface. Can't use surface.clear because that removes the chunks
    -- as well, which acts weird when placing entities on them now.
    for _, entity in pairs(surface.find_entities_filtered{}) do
        entity.destroy { raise_destroy = true }
    end

    return surface
end

---Used to mainly force the debug assert to act as if not debugging
---@param enable boolean? if we should mock release
function test_util.mock_release(enable)
    if enable == nil then enable = true end
    global.__testing_release = enable
end

function test_util.assert_true(a)
    if a ~= true then error(pre.."Value is not true") end
end

function test_util.assert_false(a)
    if a ~= false then error(pre.."Value is not false") end
end

function test_util.assert_falsy(a)
    if a then error(pre.."Value is not falsy") end
end

function test_util.assert_not_nil(a)
    if a == nil then error(pre.. a .." is nil") end
end

function test_util.assert_nil(a)
    if a ~= nil then error(pre.. a .." is not nil") end
end

function test_util.assert_equal(a, b)
    if a ~= b then error(pre .. a .. " ~= " .. b) end
end

function test_util.assert_table_equal(a, b)
    test_util.assert_not_nil(a)
    test_util.assert_not_nil(b)
    if type(a) ~= "table" then error(pre.. a .. " is not a table!") end
    if type(b) ~= "table" then error(pre.. b .. " is not a table!") end
    if not util.table.compare(a, b) then
        error(pre .. "tables are not equal: "..serpent.block(a) .. " vs " .. serpent.block(b))
    end
end

function test_util.assert_table_not_equal(a, b)
    test_util.assert_not_nil(a)
    test_util.assert_not_nil(b)
    if type(a) ~= "table" then error(pre.. a .. " is not a table!") end
    if type(b) ~= "table" then error(pre.. b .. " is not a table!") end
    if util.table.compare(a, b) then
        error(pre .. "tables are equal: "..serpent.block(a) .. " vs " .. serpent.block(b))
    end
end

function test_util.assert_string_equal(a, b)
    test_util.assert_not_nil(a)
    test_util.assert_not_nil(b)
    if type(a) ~= "string" then a = tostring(a) end
    if type(b) ~= "string" then b = tostring(b) end
    if a ~= b then error(pre .. "'" .. a .. "'" .. " ~= " .. "'" .. b .. "'") end
end

---@param entity LuaEntity?
function test_util.assert_valid_entity(entity)
    if not entity then
        error(pre .. "Entity is nil")
    elseif not entity.valid then
        error(pre .. "Entity is not valid")
    end
end

--- Assert if the function called with given arguments
--- do not error with a message that matches the pattern
---@param fn fun(...) to call
---@param args table of arguments to pass to function
---@param pattern string? to match error message to
function test_util.assert_death(fn, args, pattern)
    local no_crash, message = pcall(fn, table.unpack(args))
    if no_crash then error(pre .. "Function didn't error!") end
    if pattern then if string.match(message, pattern) == nil then
        error(pre .. "Error message '"..message.."' do not match pattern '"..pattern.."'")
    end end
end

return test_util