---============================================================================
--- Job Config - a job's own settings, and the few every job shares
---============================================================================
--- A setting that belongs to one job lives in that job's folder:
---   <Character>/<job>/combat/<JOB>_CONFIG.lua     JobConfig.get('SAM', 'idle_hp', default)
--- (BRD's are in its BRD_SONG_CONFIG.lua, with the rest of its songs). The
--- settings a subjob brings to any job, and the warp rings', are common:
---   <Character>/_common/combat/SUBJOB_CONFIG.lua  JobConfig.common('SUBJOB_CONFIG', 'waltz_from', default)
---   <Character>/_common/travel/WARP_CONFIG.lua    JobConfig.common('WARP_CONFIG', 'ring_safety', default)
---
--- The job's value is the caller's default. A table default is copied and
--- the file's keys are laid over it, so one key is enough; a value of
--- another type than the default's is ignored, inside a table too
--- (weak_below = '50' keeps the default 50). A file or a key that is missing
--- keeps the default. Read at each call: nothing is kept here.
---
--- Before 2026-10-10 these settings were in three common files (TUNING.lua,
--- AUTO_ABILITIES.lua, the war_ keys of BUFF_CONFIG.lua). A folder that was
--- not tidied since (migrate_config.py) still has them there, and what they
--- say is what its player chose: a key an old file gives is read from it
--- first (BEFORE below). Once tidied the old files are gone and the job's
--- file is the only place.
---
--- @file    shared/utils/core/job_config.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-10
---============================================================================

local JobConfig = {}

-- A job whose settings are in another file than <JOB>_CONFIG.lua
local FILE = {BRD = 'BRD_SONG_CONFIG'}

-- Where a setting was before 2026-10-10: {common file, key, key inside it}
local BEFORE = {
    SAM = {auto_hasso = {'AUTO_ABILITIES', 'sam_hasso'}, auto_third_eye_ws = {'AUTO_ABILITIES', 'sam_third_eye_ws'},
           idle_hp = {'TUNING', 'sam_idle_hp'}},
    GEO = {auto_entrust = {'AUTO_ABILITIES', 'geo_entrust'}, auto_full_circle = {'AUTO_ABILITIES', 'geo_full_circle'},
           escort_indi = {'TUNING', 'geo_escort_indi'}},
    BLU = {auto_unbridled = {'AUTO_ABILITIES', 'blu_unbridled'},
           expiacion_window = {'AUTO_ABILITIES', 'blu_expiacion_window'}},
    PLD = {auto_divine_emblem = {'AUTO_ABILITIES', 'pld_divine_emblem'}, auto_majesty = {'AUTO_ABILITIES', 'pld_majesty'}},
    BLM = {auto_dark_arts = {'AUTO_ABILITIES', 'blm_dark_arts'}, auto_klimaform = {'AUTO_ABILITIES', 'blm_klimaform'}},
    DNC = {auto_presto = {'AUTO_ABILITIES', 'dnc_presto'}},
    WAR = {retaliation_cancel = {'AUTO_ABILITIES', 'war_retaliation_cancel'}, berserk = {'BUFF_CONFIG', 'war_berserk'},
           defender = {'BUFF_CONFIG', 'war_defender'}, add_sam = {'BUFF_CONFIG', 'war_add_sam'}},
    COR = {refresh_mp_below = {'TUNING', 'refresh_mp_below', 'COR'}},
    WHM = {refresh_mp_below = {'TUNING', 'refresh_mp_below', 'WHM'}},
    SMN = {skillup = {'TUNING', 'smn_skillup'}},
    BRD = {DEBUFF_SONGS = {'TUNING', 'brd_debuff_songs'}, REFRESH_BELOW = {'TUNING', 'brd_songs_refresh_below'}},
    SUBJOB_CONFIG = {waltz_from = {'TUNING', 'waltz_from'},
                     stratagem_full_recharge = {'TUNING', 'stratagem_full_recharge'}},
    WARP_CONFIG = {ring_safety = {'TUNING', 'warp_ring_safety'}},
}

--- A character file as a table, or an empty one (missing, broken, not a table).
local function read(kind, name, job)
    local ok, cfg = pcall(function()
        return require('shared/utils/core/char_paths').optional(kind, name, job)
    end)
    return (ok and type(cfg) == 'table') and cfg or {}
end

--- The value the old common file holds for a setting, or nil.
local function before(owner, key)
    local was = (BEFORE[owner] or {})[key]
    if not was then return nil end
    local value = read('common', was[1])[was[2]]
    if was[3] then return type(value) == 'table' and value[was[3]] or nil end
    return value
end

--- `value` over `default`, by the rules of the header.
local function over(default, value)
    if value == nil then return default end
    if type(default) ~= 'table' then
        if default ~= nil and type(value) ~= type(default) then return default end
        return value
    end
    if type(value) ~= 'table' then return default end
    local merged = {}
    for k, v in pairs(default) do merged[k] = v end
    for k, v in pairs(value) do
        if default[k] == nil or type(v) == type(default[k]) then merged[k] = v end
    end
    return merged
end

--- A setting of one job.
--- @param job string Job code ('SAM')
--- @param key string Name in the job's file
--- @param default any The job's own value
--- @return any
function JobConfig.get(job, key, default)
    local value = before(job, key)
    if value == nil then value = read('job', FILE[job] or (job .. '_CONFIG'), job)[key] end
    return over(default, value)
end

--- A setting every job shares.
--- @param file string 'SUBJOB_CONFIG' or 'WARP_CONFIG'
--- @param key string Name in that file
--- @param default any
--- @return any
function JobConfig.common(file, key, default)
    local value = before(file, key)
    if value == nil then value = read('common', file)[key] end
    return over(default, value)
end

return JobConfig
