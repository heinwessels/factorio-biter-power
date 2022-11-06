local lib = { table = { } }

function lib.formattime(ticks)
  local seconds = ticks / 60
  local minutes = math.floor((seconds)/60)
  seconds = math.floor(seconds - 60*minutes)
  local hours = math.floor((minutes)/60)
  minutes = math.floor(minutes - 60*hours)
  local str = ""
  for key, value in pairs({
    ["h"] = hours,
    ["m"] = minutes,
    ["s"] = seconds,
  }) do
    if str ~= "" then str=str.." " end
    str = str..string.format("%d"..key, value)
  end
  return str
end


-- This function is pulled from flib. Thanks Raiguard, this is an epic function!
--- Call the given function on a set number of items in a table, returning the next starting key.
---
--- Calls `callback(value, key)` over `n` items from `tbl`, starting after `from_k`.
---
--- The first return value of each invocation of `callback` will be collected and returned in a table keyed by the
--- current item's key.
---
--- The second return value of `callback` is a flag requesting deletion of the current item.
---
--- The third return value of `callback` is a flag requesting that the iteration be immediately aborted. Use this flag to
--- early return on some condition in `callback`. When aborted, `for_n_of` will return the previous key as `from_k`, so
--- the next call to `for_n_of` will restart on the key that was aborted (unless it was also deleted).
---
--- **DO NOT** delete entires from `tbl` from within `callback`, this will break the iteration. Use the deletion flag
--- instead.
---
--- # Examples
---
--- ```lua
--- local extremely_large_table = {
---   [1000] = 1,
---   [999] = 2,
---   [998] = 3,
---   ...,
---   [2] = 999,
---   [1] = 1000,
--- }
--- event.on_tick(function()
---   global.from_k = table.for_n_of(extremely_large_table, global.from_k, 10, function(v) game.print(v) end)
--- end)
--- ```
--- @param tbl table The table to iterate over.
--- @param from_k any The key to start iteration at, or `nil` to start at the beginning of `tbl`. If the key does not exist in `tbl`, it will be treated as `nil`, _unless_ a custom `_next` function is used.
--- @param n number The number of items to iterate.
--- @param callback function Receives `value` and `key` as parameters.
--- @param _next? function A custom `next()` function. If not provided, the default `next()` will be used.
--- @return any? next_key Where the iteration ended. Can be any valid table key, or `nil`. Pass this as `from_k` in the next call to `for_n_of` for `tbl`.
--- @return table rsults The results compiled from the first return of `callback`.
--- @return boolean reached_end Whether or not the end of the table was reached on this iteration.
function lib.table.for_n_of(tbl, from_k, n, callback, _next)
  -- Bypass if a custom `next` function was provided
  if not _next then
    -- Verify start key exists, else start from scratch
    if from_k and not tbl[from_k] then
      from_k = nil
    end
    -- Use default `next`
    _next = next
  end

  local delete
  local prev
  local abort
  local result = {}

  -- Run `n` times
  for _ = 1, n, 1 do
    local v
    if not delete then
      prev = from_k
    end
    from_k, v = _next(tbl, from_k)
    if delete then
      tbl[delete] = nil
    end

    if from_k then
      result[from_k], delete, abort = callback(v, from_k)
      if delete then
        delete = from_k
      end
      if abort then
        break
      end
    else
      return from_k, result, true
    end
  end

  if delete then
    tbl[delete] = nil
    from_k = prev
  elseif abort then
    from_k = prev
  end
  return from_k, result, false
end

return lib