---============================================================================
--- Text Join - table.concat that stays linear in game
---============================================================================
--- In game, `table` is shared with the GearSwap addon, and Windower's
--- libs/tables.lua replaces table.concat with a loop that adds one piece at a
--- time (`res = res .. tostring(value)`): every piece copies all the text built
--- so far, so the cost grows with the square of the text. Measured 2026-11-13:
--- the Atelier export's catalog of Kaories RDM/WHM (1 102 entries, 300 KB of
--- JSON) took 315 MB of Lua memory and 162 ms in game, against 4 MB and 27 ms
--- with Lua's own table.concat (scripts/atelier/text_join_test.lua replays it).
---
--- join() merges the pieces two by two, so each byte is copied about log2(n)
--- times, whatever table.concat is. Use it for any text built from many pieces
--- (JSON, files); a handful of short pieces can keep table.concat.
---
--- @file    shared/utils/core/text_join.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-11-13
---============================================================================

local TextJoin = {}

--- Concatenate a list of strings with a separator, in about n log n copies.
--- @param parts table Array of strings (numbers are written as tostring would)
--- @param sep string|nil Put between two pieces ('' when nil)
--- @return string
function TextJoin.join(parts, sep)
    sep = sep or ''
    local level, n = parts, #parts
    if n == 0 then return '' end
    if n == 1 then return tostring(level[1]) end
    while n > 1 do
        local merged = {}
        for i = 1, n, 2 do
            if i < n then
                merged[#merged + 1] = tostring(level[i]) .. sep .. tostring(level[i + 1])
            else
                merged[#merged + 1] = tostring(level[i])
            end
        end
        level, n = merged, #merged
    end
    return level[1]
end

_G.TextJoin = TextJoin

return TextJoin
