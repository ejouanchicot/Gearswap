---============================================================================
--- Dual Wield Tiers - less Dual Wield gear as magic haste goes up
---============================================================================
--- Attack delay cannot go under 20 %: (1 - DW) x (1 - total haste) >= 0.2.
--- With gear haste capped (25 %), the Dual Wield needed falls with magic
--- haste: 74 % with none, 67 % at 15 %, 56 % at 30 %, 36 % at the 43.75 %
--- cap (job trait included). Four tiers, each the player's DW pieces laid
--- on top of the engaged set while two weapons are held:
---   sets.DW.NoHaste    magic haste under 15 %
---   sets.DW.Haste      15 % or more   (Haste, one March, Mighty Guard)
---   sets.DW.HasteII    30 % or more   (Haste II, Geo-Haste, two Marches)
---   sets.DW.MaxHaste   43.75 % (cap)  (Haste II + a March...)
--- A missing or empty tier falls back to the one below (more Dual Wield: too
--- much only costs a little damage, too little slows every attack). No tier
--- filled: nothing happens.
---
--- Tiers by engaged mode: the job's set builder says which engaged set it took
--- (DualWield.note_mode: BRD's STP, Acc, SB, PDTKC); sets.DW.<Mode>.<Tier>
--- (sets.DW.SB.MaxHaste) then comes before sets.DW.<Tier>, for that mode only.
--- The mode's own tiers are tried first, from the tier down; none filled at or
--- below it: the common ones, from the tier down. A job that says nothing, or
--- a mode with no tiers of its own, keeps the common ones
--- (SPEC notes/docs-perso/engaged-par-mode-2026-11-06).
---
--- Magic haste is estimated from the buffs up (read from the game) and the
--- spells that gave them (the action packet: Haste or Haste II, which March):
--- values in <Character>/_common/gear/DW_CONFIG.lua, the nominal ones (Haste
--- 15 %: the game's 150/1024 is 14.65 %, so a hair high, under one point of
--- Dual Wield; the Marches depend on the Bard's gear).
--- //gs c dw shows the estimate; //gs c dw none|haste|haste2|max forces a
--- tier, //gs c dw auto goes back to the estimate. (Not "haste": that name
--- is the alt command that casts Haste.)
--- "Auto DW" job by job: DW_CONFIG's jobs = {BRD = false, ...} turns the tiers
--- off on that job alone (a job left out is on); enabled = false turns them off
--- on every job (SPEC notes/docs-perso/dual-wield-tous-jobs-2026-11-06).
---
--- @file    shared/utils/equipment/dual_wield.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-28
---============================================================================

local DualWield = {}

local CAP = 43.75
local TIERS = {'NoHaste', 'Haste', 'HasteII', 'MaxHaste'}   -- low to high
local FORCE_NAMES = {none = 'NoHaste', haste = 'Haste', haste2 = 'HasteII', max = 'MaxHaste'}

local BUFF_HASTE, BUFF_MARCH, BUFF_GEO, BUFF_GUARD, BUFF_EMBRAVA = 33, 214, 580, 604, 228
local WATCHED_BUFFS = {[33] = true, [214] = true, [580] = true, [604] = true, [228] = true}

local DEFAULTS = {
    enabled = true,
    haste = 15, haste2 = 30, geo_haste = 30, mighty_guard = 15, embrava = 25,
    honor_march = 13, victory_march = 15, advancing_march = 10, unknown_march = 10,
}

-- Spell id -> what it gives when it lands on this character
local HASTE_SPELLS = {[57] = 'haste', [511] = 'haste2', [710] = 'haste2'}   -- Erratic Flutter = Haste II level
local MARCH_SPELLS = {[417] = 'honor_march', [420] = 'victory_march', [419] = 'advancing_march'}

---============================================================================
--- SETTINGS AND TRACKING
---============================================================================

--- The character's settings, read once per load.
function DualWield.settings()
    local cached = rawget(_G, '_dual_wield_settings')
    if cached then return cached end
    local settings = {}
    for k, v in pairs(DEFAULTS) do settings[k] = v end
    local path = player and player.name and require('shared/utils/core/char_paths').file('common', 'DW_CONFIG.lua')
    local file = path and io.open(path, 'r')
    if file then
        file:close()
        local ok, loaded = pcall(dofile, path)
        for k, v in pairs(ok and type(loaded) == 'table' and loaded or {}) do
            if k == 'enabled' then settings.enabled = v == true
            elseif k == 'jobs' and type(v) == 'table' then
                settings.jobs = {}
                for job, on in pairs(v) do settings.jobs[tostring(job):upper()] = on ~= false end
            elseif DEFAULTS[k] ~= nil then settings[k] = tonumber(v) or settings[k] end
        end
    end
    _G._dual_wield_settings = settings
    return settings
end

--- What landed on this character last: kept on `windower`, it outlives a reload.
local function tracked()
    windower._dw_tracked = windower._dw_tracked or {haste = nil, marches = {}}
    return windower._dw_tracked
end

--- Buff ids up now, read from the game (GearSwap's buffactive lags in raw events).
local function buff_counts()
    local counts = {}
    local ok, me = pcall(windower.ffxi.get_player)
    for _, id in ipairs(ok and me and me.buffs or {}) do counts[id] = (counts[id] or 0) + 1 end
    return counts
end

--- Estimated magic haste %, and the sources counted.
--- @return number percent (capped), table list of "source value" strings
function DualWield.magic_haste()
    local settings, counts, seen = DualWield.settings(), buff_counts(), tracked()
    local total, parts = 0, {}
    local function add(label, value)
        total = total + value
        parts[#parts + 1] = ('%s %d'):format(label, value)
    end
    if counts[BUFF_HASTE] then
        local kind = seen.haste or 'haste'
        add(kind == 'haste2' and 'Haste II' or 'Haste', settings[kind])
    end
    if counts[BUFF_GEO] then add('Geo-Haste', settings.geo_haste) end
    if counts[BUFF_GUARD] then add('Mighty Guard', settings.mighty_guard) end
    if counts[BUFF_EMBRAVA] then add('Embrava', settings.embrava) end
    for i = 1, math.min(counts[BUFF_MARCH] or 0, 2) do
        local kind = seen.marches[i] or 'unknown_march'
        add((kind:gsub('_', ' ')), settings[kind])
    end
    return math.min(total, CAP), parts
end

--- The tier the estimate (or the forced one) gives.
--- @return string tier, boolean forced
function DualWield.tier()
    if windower._dw_forced then return windower._dw_forced, true end
    local haste = DualWield.magic_haste()
    if haste >= CAP then return 'MaxHaste', false end
    if haste >= 30 then return 'HasteII', false end
    if haste >= 15 then return 'Haste', false end
    return 'NoHaste', false
end

---============================================================================
--- EQUIP
---============================================================================

--- Whether two weapons are held: the sub slot's item, read from the game by
--- its id in GearSwap's already loaded res, is a weapon with a combat skill
--- (a shield or grip has none). No walk of the whole item list.
local function dual_wielding()
    local ok, eq = pcall(windower.ffxi.get_items, 'equipment')
    if not ok or type(eq) ~= 'table' or not eq.sub or eq.sub == 0 then return false end
    local ok_item, item = pcall(windower.ffxi.get_items, eq.sub_bag, eq.sub)
    local gs = rawget(_G, 'gearswap')
    local resources = rawget(_G, 'res') or (gs and gs.res)
    local data = ok_item and type(item) == 'table' and item.id and resources and resources.items[item.id]
    return data ~= nil and data.category == 'Weapon' and (data.skill or 0) > 0
end

--- The engaged set the job's set builder took last ('STP', 'Acc', 'SB',
--- 'PDTKC'...; nil: the base set, or a job that does not say). Per load: the
--- builder runs before every engaged equip, so it is always the current one.
--- @param mode string|nil
function DualWield.note_mode(mode)
    _G._dual_wield_mode = type(mode) == 'string' and mode or nil
end

--- @return string|nil the engaged mode noted last
function DualWield.mode()
    return rawget(_G, '_dual_wield_mode')
end

--- In one table of tiers, the tier asked or the closest one below it with pieces.
--- @return table|nil set, string|nil tier name
local function filled_from(dw, index)
    for i = index, 1, -1 do
        -- (an empty tier, as the job templates declare them, is one not filled yet: the one below it, the safe side)
        if type(dw[TIERS[i]]) == 'table' and next(dw[TIERS[i]]) ~= nil then return dw[TIERS[i]], TIERS[i] end
    end
    return nil
end

--- The tier's set, or the closest one below it with pieces (more Dual Wield):
--- the engaged mode's own tiers first (sets.DW.<Mode>), then the common ones.
--- @param tier string
--- @param mode string|nil Engaged mode (DualWield.mode())
--- @return table|nil set, string|nil name ('MaxHaste', or 'SB.MaxHaste' for a mode's own)
local function tier_set(tier, mode)
    local dw = sets and sets.DW
    if type(dw) ~= 'table' then return nil end
    local index = 1
    for i, name in ipairs(TIERS) do if name == tier then index = i end end
    -- (a mode named as a tier would read a set as a table of tiers: never taken as a mode's)
    local own = mode and type(dw[mode]) == 'table' and dw[mode] or nil
    for _, name in ipairs(TIERS) do if mode == name then own = nil end end
    if own then
        local set, name = filled_from(own, index)
        if set then return set, mode .. '.' .. name end
    end
    return filled_from(dw, index)
end

--- Write the set chosen to the trace when it changed (TraceLog is a no-op while off).
local function trace_choice(tier, mode, name)
    local key = tostring(mode) .. '|' .. tostring(name)
    if windower._dw_traced == key then return end
    windower._dw_traced = key
    pcall(function()
        require('shared/utils/debug/trace_log').log('DW', 'mode %s, tier %s -> %s', tostring(mode or 'base'), tostring(tier),
            name and ('sets.DW.' .. name) or 'none')
    end)
end

--- Auto DW on for the job played: the character's switch, then the job's own
--- (DW_CONFIG jobs; a job not listed is on).
--- @return boolean
function DualWield.on_for_job()
    local s = DualWield.settings()
    if not s.enabled then return false end
    local job = player and player.main_job
    return not (s.jobs and job and s.jobs[job] == false)
end

--- Lay the tier's Dual Wield pieces on the engaged set (after Mote and the job).
--- @param status string Player status
function DualWield.apply(status)
    if (status or (player and player.status)) ~= 'Engaged' then return end
    if not DualWield.on_for_job() or not dual_wielding() then return end
    -- A COR roll holds the gear until it lands (roll_hold.lua): leave it be
    if require('shared/utils/core/gear_hold').active() then return end
    local tier, mode = (DualWield.tier()), DualWield.mode()
    local set, name = tier_set(tier, mode)
    trace_choice(tier, mode, name)
    if set then
        equip(set)
        windower._dw_last_tier = name
    end
end

---============================================================================
--- EVENTS
---============================================================================

--- A spell landed: remember which Haste / March this character got.
local function on_action(act)
    if not (act and act.category == 4) then return end
    local haste, march = HASTE_SPELLS[act.param], MARCH_SPELLS[act.param]
    if not (haste or march) then return end
    local ok, me = pcall(windower.ffxi.get_player)
    if not (ok and me) then return end
    for _, target in ipairs(act.targets or {}) do
        if target.id == me.id then
            local seen = tracked()
            if haste then seen.haste = haste end
            if march then
                table.insert(seen.marches, 1, march)
                seen.marches[3] = nil
            end
            return
        end
    end
end

--- A haste buff came or went: re-dress when the tier changed.
local function on_buff(id)
    if not WATCHED_BUFFS[id] then return end
    local token = (windower._dw_update_token or 0) + 1
    windower._dw_update_token = token
    coroutine.schedule(function()
        if windower._dw_update_token ~= token then return end
        local ok, me = pcall(windower.ffxi.get_player)
        if not (ok and me and me.status == 1) then return end
        -- (re-dress only for a tier that lays pieces, on a job with Auto DW on and two weapons held: with no tier
        -- filled, every Haste or March gained or lost sent an update, which re-dresses mid-cast)
        if not DualWield.on_for_job() or not dual_wielding() then return end
        local _, name = tier_set((DualWield.tier()), DualWield.mode())
        if name and name ~= windower._dw_last_tier then send_command('gs c update') end
    end, 0.3)
end

--- Wrap handle_equipping_gear and listen for haste, once per sandbox.
function DualWield.install()
    if rawget(_G, '_dual_wield_installed') then return end
    local original = rawget(_G, 'handle_equipping_gear')
    if type(original) ~= 'function' then return end
    _G._dual_wield_installed = true
    _G.handle_equipping_gear = function(status, pet_status)
        local result = original(status, pet_status)
        pcall(DualWield.apply, status)
        return result
    end
    require('shared/utils/core/action_listener').on('dual_wield', on_action)
    windower.raw_register_event('gain buff', function(id) pcall(on_buff, id) end)
    windower.raw_register_event('lose buff', function(id) pcall(on_buff, id) end)
end

---============================================================================
--- COMMAND
---============================================================================

--- //gs c dw [auto|none|haste|haste2|max]
--- @param args table Words after "dw"
--- @return boolean true (handled)
function DualWield.command(args)
    local word = args and args[1] and args[1]:lower()
    if word == 'auto' then windower._dw_forced = nil
    elseif word and FORCE_NAMES[word] then windower._dw_forced = FORCE_NAMES[word] end
    if word then send_command('gs c update') end
    local haste, parts = DualWield.magic_haste()
    local tier, forced = DualWield.tier()
    local mode = DualWield.mode()
    local _, used = tier_set(tier, mode)
    local fields = {
        {'Auto DW', DualWield.on_for_job() and 'ON' or ('OFF' .. (DualWield.settings().enabled and ' (this job: DW_CONFIG jobs)' or '')), DualWield.on_for_job() and 'good' or 'bad'},
        {'Magic haste', ('%.2f %% (%s)'):format(haste, #parts > 0 and table.concat(parts, ', ') or 'none')},
        {'Engaged mode', mode or 'base set (or not told by the job)'},
        {'Tier', tier .. (forced and ' (forced: //gs c dw auto to undo)' or ' (estimated)')},
        {'Set used', used and ('sets.DW.' .. used) or 'none (no sets.DW here)', used and 'good' or 'warn'},
        {'Two weapons', dual_wielding() and 'yes' or 'no'},
    }
    require('shared/utils/messages/info_block').show({tag = 'HASTE', title = 'Dual Wield tier', fields = fields})
    return true
end

return DualWield
