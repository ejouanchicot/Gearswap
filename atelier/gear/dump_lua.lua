-- Dump a Windower resource table as JSON (strings kept as raw UTF-8 bytes).
-- Usage: lua5.1 dump_lua.lua <res/items.lua> <out.json>
local BS = string.char(92)
local function esc(s)
  return (s:gsub('[%c"' .. BS .. BS .. ']', function(c)
    if c == '"' then return BS .. '"'
    elseif c == BS then return BS .. BS
    elseif c == '\n' then return BS .. 'n'
    elseif c == '\r' then return BS .. 'r'
    elseif c == '\t' then return BS .. 't'
    else return string.format(BS .. 'u%04x', c:byte()) end
  end))
end
local function enc(v)
  local t = type(v)
  if t == 'string' then return '"' .. esc(v) .. '"'
  elseif t == 'number' or t == 'boolean' then return tostring(v)
  elseif t == 'table' then
    local parts = {}
    local n = #v
    if n > 0 then
      for i = 1, n do parts[#parts + 1] = enc(v[i]) end
      return '[' .. table.concat(parts, ',') .. ']'
    end
    for k, x in pairs(v) do parts[#parts + 1] = '"' .. esc(tostring(k)) .. '":' .. enc(x) end
    return '{' .. table.concat(parts, ',') .. '}'
  end
  return 'null'
end
local t = dofile(arg[1])
local out = io.open(arg[2], 'wb')
out:write('{')
local first = true
for id, e in pairs(t) do
  local c = {}
  for k, x in pairs(e) do if k ~= 'ja' and k ~= 'jal' then c[k] = x end end
  out:write((first and '' or ',\n') .. '"' .. id .. '":' .. enc(c))
  first = false
end
out:write('}')
out:close()
