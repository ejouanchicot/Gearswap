---============================================================================
--- Key Overrides - keys changed in the Atelier page, laid over the key files
---============================================================================
--- The Atelier page (data/atelier.html, Keys tab) writes the keys a player
--- changes into <Char>/saved/keybind_overrides.lua. The key files themselves
--- (<job>/keys/<JOB>_KEYBINDS.lua, _common/keys/COMMON_KEYBINDS.lua...) are
--- never rewritten: deleting that file brings every key back.
---
--- Format of the file:
---   return {
---       common = { ['state:AutoMedicine'] = '#numpad1' },        -- every job
---       PLD    = { ['state:HybridMode'] = '^numpad8',
---                  ['cmd:stealth sneak'] = '' },                 -- '' = no key
---   }
--- A key is found by its state ('state:<State>'), else by its command
--- ('cmd:<command>'), then '@<SUB>' or '@-<SUB>' when the key is for (or
--- not for) some subjobs only. Keys of COMMON_KEYBINDS take the `common` table, the
--- others the job's. Key names are Windower's: physical key positions named
--- as on a US keyboard ('a' is the key right of Caps Lock, printed Q on AZERTY).
---
--- @file shared/utils/keybinds/key_overrides.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local KeyOverrides = {}

local FILE = 'keybind_overrides.lua'

local function subjobs(value)
    if type(value) == 'string' then return value end
    if type(value) == 'table' then return table.concat(value, '/') end
    return nil
end

--- The id an override names a key by: its state, else its command, then the
--- subjobs it is for. One state can hold two keys (PLD's Phalanx SIRD:
--- ^numpad2 but on /SCH, ^numpad3 on /SCH): 'state:PhalanxSIRD@-SCH' and
--- 'state:PhalanxSIRD@SCH' keep them apart.
--- @param bind table A key entry (key, command, state, subjob, exclude_subjob...)
--- @return string
function KeyOverrides.id_of(bind)
    local id = (type(bind.state) == 'string' and bind.state ~= '') and ('state:' .. bind.state)
        or ('cmd:' .. tostring(bind.command or ''))
    local only, but = subjobs(bind.subjob), subjobs(bind.exclude_subjob)
    if only then return id .. '@' .. only end
    if but then return id .. '@-' .. but end
    return id
end

--- The overrides file of the character, read now, or nil when there is none.
--- @return table|nil {common = {id = key}, <JOB> = {id = key}}
function KeyOverrides.read()
    local ok, CharPaths = pcall(require, 'shared/utils/core/char_paths')
    local path = ok and CharPaths and CharPaths.file('saved', FILE)
    if not path then return nil end
    local ok_load, data = pcall(dofile, path)
    return (ok_load and type(data) == 'table') and data or nil
end

--- Lay the overrides over a job's key list, once per list (the HUD requires
--- the key file a second time). The key a file gave is kept in
--- `file_key` for the Atelier export.
--- @param job string Job code ("PLD")
--- @param binds table The list KeybindManager.create assembled
function KeyOverrides.apply(job, binds)
    if type(binds) ~= 'table' or binds._overrides_applied then return end
    binds._overrides_applied = true
    local data = KeyOverrides.read()
    if not data then return end
    local mine, common = type(data[job]) == 'table' and data[job] or {}, type(data.common) == 'table' and data.common or {}
    for _, bind in ipairs(binds) do
        if type(bind) == 'table' then
            local key = (bind._common and common or mine)[KeyOverrides.id_of(bind)]
            if type(key) == 'string' then
                bind.file_key = bind.key
                bind.key = key
            end
        end
    end
end

return KeyOverrides
