---============================================================================
--- Test of the PLD stances each subjob gets (PLD_STATES.lua)
---============================================================================
--- The Sortie stance (sets.engaged.TP) is gone (2026-10-31): no //gs c sortie
--- target took it. Every subjob gets PDT, MDT and DPS (the TP build); /SCH and
--- /RUN also the Sortie setup's Tanking and Hoxne. Kaories' file: PDT and MDT
--- and DPS (Naegling) on every subjob. The stance profile: DPS, Tanking and Hoxne narrow the weapon
--- list, PDT and MDT restore it; Burtgang is the default weapon. Played with a
--- small Mote mode (M) and the real files.
---
--- Run from data/: lua5.1 scripts/atelier/pld_stances_test.lua
---
--- @file scripts/atelier/pld_stances_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-31
---============================================================================

local done, failed = 0, 0
local function check(what, got, want)
    done = done + 1
    if got ~= want then
        failed = failed + 1
        print(('FAILED %s: got %s, wanted %s'):format(what, tostring(got), tostring(want)))
    end
end

-- Mote's mode (libs/Modes.lua), what PLD_STATES.lua uses of it
function M(t)
    local m = {_list = {}, description = t.description}
    for _, v in ipairs(t) do m._list[#m._list + 1] = v end
    m.value, m.current = m._list[1], m._list[1]
    function m:options(...) self._list = {...}; self.value = self._list[1]; self.current = self.value end
    function m:set(v) self.value = v; self.current = v end
    function m:contains(v) for _, x in ipairs(self._list) do if x == v then return true end end return false end
    return m
end
package.loaded['shared/utils/debuff/auto_medicine'] = {init = function() end}
table.unpack = table.unpack or unpack   -- GearSwap's sandbox has it (Lua 5.2 name)

local function stances(file, sub)
    player = {sub_job = sub, main_job = 'PLD'}
    state = {HybridMode = M({'Normal'})}
    local S = dofile(file)
    S.configure()
    return table.concat(state.HybridMode._list, ' '), S
end

for _, file in ipairs({'_master/config/pld/PLD_STATES.lua', '_master/Tetsouo/config/pld/PLD_STATES.lua'}) do
    local tag = file:match('_master/(.-)/') == 'config' and 'template' or 'Tetsouo'
    check(tag .. ' /NIN stances', (stances(file, 'NIN')), 'PDT MDT DPS')
    check(tag .. ' /SCH stances', (stances(file, 'SCH')), 'PDT MDT DPS Tanking Hoxne')
    -- DPS on a classic subjob: the TP build's two weapons, nothing of the Sortie setup (Phalanx SIRD stays Off)
    local wlist, W = stances(file, 'WAR')
    check(tag .. ' /WAR stances', wlist, 'PDT MDT DPS')
    check(tag .. ' /WAR default weapon Burtgang', state.MainWeapon.value, 'Burtgang')
    state.HybridMode:set('DPS'); W.apply_hybrid_profile('DPS')
    check(tag .. ' /WAR DPS: Naegling or Excalibur', table.concat(state.MainWeapon._list, ' '), 'Naegling Excalibur')
    check(tag .. ' /WAR DPS: Phalanx SIRD stays off', state.PhalanxSIRD.value, 'Off')
    state.HybridMode:set('PDT'); W.apply_hybrid_profile('PDT')
    check(tag .. ' /WAR back to PDT: full weapon list', #state.MainWeapon._list, 7)
    check(tag .. ' /WAR back to PDT: Burtgang in hand again', state.MainWeapon.value, 'Burtgang')
    check(tag .. ' Idle Defense, MDT first', state.IdleDefense and state.IdleDefense.value, 'MDT')
    local list, S = stances(file, 'RUN')
    check(tag .. ' /RUN stances', list, 'PDT MDT DPS Tanking Hoxne')
    -- entering a Sortie setup stance narrows the weapons; PDT gives the full list back
    state.HybridMode:set('DPS'); S.apply_hybrid_profile('DPS')
    check(tag .. ' /RUN DPS: the /SCH weapon list', table.concat(state.MainWeapon._list, ' '), 'Naegling Excalibur')
    check(tag .. ' /RUN DPS: Phalanx SIRD on', state.PhalanxSIRD.value, 'On')
    state.HybridMode:set('PDT'); S.apply_hybrid_profile('PDT')
    check(tag .. ' /RUN back to PDT: full weapon list', #state.MainWeapon._list, 7)
    check(tag .. ' /RUN back to PDT: Phalanx SIRD off', state.PhalanxSIRD.value, 'Off')
    check(tag .. ' /RUN back to PDT: Burtgang in hand again', state.MainWeapon.value, 'Burtgang')
    -- PDT <-> MDT keeps the weapon chosen
    state.MainWeapon:set('Malevo'); state.HybridMode:set('MDT'); S.apply_hybrid_profile('MDT')
    check(tag .. ' PDT -> MDT keeps the weapon', state.MainWeapon.value, 'Malevo')
end

for _, file in ipairs({'_master/Kaories/config/pld/PLD_STATES.lua', 'Kaories/pld/keys/PLD_STATES.lua'}) do
    local tag = file:find('_master', 1, true) and 'Kaories overlay' or 'Kaories live'
    check(tag .. ' /WAR stances', (stances(file, 'WAR')), 'PDT MDT DPS')
    local list, S = stances(file, 'SCH')
    check(tag .. ' /SCH stances', list, 'PDT MDT DPS')
    check(tag .. ' Idle Defense, MDT first', state.IdleDefense and state.IdleDefense.value, 'MDT')
    check(tag .. ' full weapon list', #state.MainWeapon._list, 6)
    state.HybridMode:set('MDT'); S.apply_hybrid_profile('MDT')
    check(tag .. ' MDT keeps the full weapon list', #state.MainWeapon._list, 6)
    state.HybridMode:set('DPS'); S.apply_hybrid_profile('DPS')
    check(tag .. ' DPS: Naegling', table.concat(state.MainWeapon._list, ' ') .. '/' .. state.MainWeapon.value, 'Naegling/Naegling')
    state.HybridMode:set('PDT'); S.apply_hybrid_profile('PDT')
    check(tag .. ' back to PDT: Burtgang, full list', state.MainWeapon.value .. '/' .. #state.MainWeapon._list, 'Burtgang/6')
end

-- the keys each stance gets (PLD_KEYBINDS.lua, its visible rules): Ctrl+Numpad1 the weapon mode, or the Tanking
-- stance's weapon in Tanking; Ctrl+Numpad0 the shield everywhere; Ctrl+Numpad8 Idle Defense in DPS and Hoxne
package.loaded['shared/utils/keybinds/keybind_manager'] = {create = function(_, m) return m end}
for _, file in ipairs({'_master/config/pld/PLD_KEYBINDS.lua', 'Tetsouo/pld/keys/PLD_KEYBINDS.lua'}) do
    local K = dofile(file)
    local function keys(stance)
        player = {sub_job = 'RUN'}
        state = {HybridMode = {value = stance}}
        local out = {}
        for _, b in ipairs(K.binds) do
            local sub_ok = not b.subjob or b.subjob == 'RUN' or (type(b.subjob) == 'table' and (b.subjob[1] == 'RUN' or b.subjob[2] == 'RUN'))
            if sub_ok and (not b.visible or b.visible()) then out[b.key] = (out[b.key] and out[b.key] .. '+' or '') .. b.command end
        end
        return out
    end
    local tag = file:find('_master', 1, true) and 'template keys' or 'Tetsouo keys'
    local pdt, tank, dps = keys('PDT'), keys('Tanking'), keys('DPS')
    check(tag .. ' PDT: Ctrl+Numpad1 the weapon mode', pdt['^numpad1'], 'cyclestate MainWeapon')
    check(tag .. ' Tanking: Ctrl+Numpad1 the Tanking weapon', tank['^numpad1'], 'cyclestate StanceWeapon')
    check(tag .. ' every stance: Ctrl+Numpad0 the shield', (pdt['^numpad0'] or '') .. '|' .. (tank['^numpad0'] or '') .. '|' .. (dps['^numpad0'] or ''),
        'cyclestate Shield|cyclestate Shield|cyclestate Shield')
    check(tag .. ' DPS: Ctrl+Numpad8 Idle Defense', dps['^numpad8'], 'cyclestate IdleDefense')
    check(tag .. ' PDT: no Ctrl+Numpad8', pdt['^numpad8'], nil)
end

print(('%d checks, %d failed'):format(done, failed))
os.exit(failed == 0 and 0 or 1)
