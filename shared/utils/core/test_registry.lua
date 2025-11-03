-- Test script to find command_registry

add_to_chat(158, '=== Testing command_registry locations ===')

-- Test 1: _G.command_registry
if _G.command_registry then
    add_to_chat(158, 'FOUND: _G.command_registry')
else
    add_to_chat(167, 'NOT FOUND: _G.command_registry')
end

-- Test 2: command_registry (direct)
if command_registry then
    add_to_chat(158, 'FOUND: command_registry (direct)')
else
    add_to_chat(167, 'NOT FOUND: command_registry (direct)')
end

-- Test 3: Look for it in package.loaded
for k, v in pairs(package.loaded) do
    if type(v) == 'table' and v.command_registry then
        add_to_chat(158, 'FOUND in package.loaded["' .. k .. '"].command_registry')
    end
end

-- Test 4: Check gearswap namespace
if gearswap then
    add_to_chat(158, 'gearswap table exists')
    if gearswap.command_registry then
        add_to_chat(158, 'FOUND: gearswap.command_registry')
    end
end

-- Test 5: List all globals with 'command' or 'registry'
add_to_chat(158, '=== Searching globals for command/registry ===')
for k, v in pairs(_G) do
    local name = tostring(k):lower()
    if name:find('command') or name:find('registry') then
        add_to_chat(158, 'Global: ' .. tostring(k) .. ' = ' .. type(v))
    end
end

add_to_chat(158, '=== Test complete ===')
