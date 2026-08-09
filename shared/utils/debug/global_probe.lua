---  ═══════════════════════════════════════════════════════════════════════════
---   Global Probe - catches variables that escaped into _G
---  ═══════════════════════════════════════════════════════════════════════════
---   In Lua, assigning to a name that is neither a local nor a parameter
---   creates a global. It is valid, it compiles, and nothing reports it - so a
---   refactor that turns a shared local into something a helper writes to ends
---   up writing to _G instead, and the caller never sees the value.
---
---   That is not hypothetical: extracting a branch out of the COR roll tracker
---   did exactly this to `is_crooked`, and Crooked Cards silently stopped
---   carrying through a Double-Up. Nothing in the compiler, the call
---   comparison or in-game play showed it - only the numbers in a message were
---   wrong.
---
---   The probe snapshots _G once the systems are up, then reports whatever
---   appeared afterwards. Anything created during play that is not declared in
---   EXPECTED is something nobody meant to create.
---
---   @file    shared/utils/debug/global_probe.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-08-09
---  ═══════════════════════════════════════════════════════════════════════════

local GlobalProbe = {}

-- Every global the project publishes on purpose, generated from the codebase:
-- each of these is written somewhere as an explicit `_G.name = ...`.
--
-- That prefix is the whole test. The bug this probe exists for is a bare
-- assignment - `is_crooked = true` inside a function that declared no such
-- local - and a bare assignment never carries `_G.`. So anything in _G that is
-- not on this list was created by accident.
--
-- Regenerate with scripts/audit (it reads the same `_G.x =` sites) after
-- adding a deliberate global.
local EXPECTED = {
    AUTOMOVE_DEBUG = true, AUTOMOVE_RUNNING = true,
    AUTO_JUMP_SEQUENCE_ACTIVE = true, AltBuffExpiry = true,
    AltBuffReporter = true, AltBuffState = true, AltCommands = true,
    AltJobState = true, AutoMedicine = true, AutoMove = true,
    BLMTPCONFIG = true, BLMTPConfig = true, BLM_ARTS_LAST_CAST = true,
    BRDSongConfig = true, BRDTPConfig = true, BRDTimingConfig = true,
    BSTBeastPetData = true, BSTTPConfig = true, BST_DEBUG_PRECAST = true,
    BluMagicConfig = true, BuffSelf = true, CORTPCONFIG = true,
    CORTPConfig = true, CastStorm = true, DETECTED_FFXI_REGION = true,
    DISABLE_AUTOMOVE = true, DNCTPConfig = true, DNCWSConfig = true,
    DNC_AUTO_WS_RECAST = true, DRESSUP_MANAGEMENT_ENABLED = true,
    DRKTPCONFIG = true, DRKTPConfig = true, DUALBOX_SYNC_HOOKS = true,
    DualBoxConfig = true, FFXI_DATA = true, GEOTPCONFIG = true,
    GEOTPConfig = true, GlobalProbe = true, JOBCHANGE_DEBUG = true,
    JobChangeManagerSTATE = true, KeybindUI = true, LagDebugger = true,
    LifecycleManager = true, LockstyleConfig = true,
    MESSAGE_ENGINE_LOADED = true, MESSAGE_SETTINGS = true,
    MIDCAST_WATCHDOG_TIMER = true, MidcastManagerDebugState = true,
    MidcastWatchdog = true, ModuleCache = true,
    PERFORMANCE_PROFILING = true, PLDTPCONFIG = true, PLDTPConfig = true,
    PUPBeastPetData = true, PUPTPConfig = true, PrecastDebugState = true,
    RDMSaboteurConfig = true, RDMTPCONFIG = true, RDMTPConfig = true,
    RECAST_CONFIG = true, RUNTPCONFIG = true, RUNTPConfig = true,
    RegionConfig = true, SAMTPConfig = true, SaveMP = true,
    SongRotationManager = true, THFTPCONFIG = true, THFTPConfig = true,
    TPBonusCalculator = true, UIConfig = true, UI_SETTINGS = true,
    UPDATE_DEBUG = true, WARP_DEBUG = true, WARP_IPC_BROADCASTING = true,
    WARP_IPC_EVENT_ID = true, WARP_IPC_REGISTERED = true,
    WARTPConfig = true, WARWSConfig = true, WHMTPConfig = true,
    WS_DATABASE = true, WardConfig = true, WeaponSkillManager = true,
    __CraftManagerState = true, __global_baseline = true,
    __require_cache = true, __require_cache_installed = true,
    __require_cache_stats = true, _automove_sequence = true,
    _macrobook_schedule_id = true, _update_sent_time = true,
    bst_hud_load_id = true, bst_rdymove_active = true, buff_sam_sub = true,
    buff_war = true, build_tp = true,
    cancel_blm_lockstyle_operations = true,
    cancel_brd_lockstyle_operations = true,
    cancel_bst_lockstyle_operations = true,
    cancel_conflicting_buffs = true,
    cancel_cor_lockstyle_operations = true,
    cancel_dnc_lockstyle_operations = true,
    cancel_drk_lockstyle_operations = true,
    cancel_geo_lockstyle_operations = true,
    cancel_pld_lockstyle_operations = true,
    cancel_pup_lockstyle_operations = true,
    cancel_rdm_lockstyle_operations = true,
    cancel_run_lockstyle_operations = true,
    cancel_sam_lockstyle_operations = true,
    cancel_smn_lockstyle_operations = true, cancel_smn_skillup_loop = true,
    cancel_thf_lockstyle_operations = true,
    cancel_war_lockstyle_operations = true,
    cancel_whm_lockstyle_operations = true, casting_impact = true,
    casting_locked_song = true, checkArts = true,
    cor_action_event_id = true, cor_active_rolls = true,
    cor_crooked_timestamp = true, cor_last_roll = true,
    cor_last_roll_display = true, cor_lockstyle_watchdog = true,
    cor_lockstyle_watchdog_active = true, cor_natural_eleven_active = true,
    cor_party_event_id = true, cor_party_jobs = true,
    cor_party_state = true, cor_pending_roll_timestamp = true,
    cor_pending_roll_value = true, customize_idle_set = true,
    customize_melee_set = true, display_current_state = true,
    dnc_climactic_timestamp = true, drk_dark_seal_pending = true,
    drk_nether_void_pending = true, geo_entrust_pending = true,
    get_dnc_movement_status = true, get_geo_movement_status = true,
    get_retaliation_status = true, get_sam_movement_status = true,
    get_thf_movement_status = true, get_war_movement_status = true,
    impact_body = true, is_on_cooldown = true, is_recast_ready = true,
    job_aftercast = true, job_buff_change = true,
    job_customize_midcast_set = true, job_get_spell_map = true,
    job_handle_equipping_gear = true, job_midcast = true,
    job_pet_midcast = true, job_pet_precast = true,
    job_post_aftercast = true, job_post_midcast = true,
    job_post_precast = true, job_precast = true, job_self_command = true,
    job_state_change = true, job_status_change = true,
    keybind_saved_settings = true, keybind_ui_display = true,
    keybind_ui_visible = true, locked_instrument = true,
    locked_song_name = true, name = true, petMagicAccMoves = true,
    petMagicAtkMoves = true, petPhysicalMoves = true,
    petPhysicalMultiMoves = true, pianissimo_in_progress = true,
    precast = true, pup_time_change_event_id = true,
    refine_various_spells = true, require = true,
    select_default_lockstyle = true, select_default_macro_book = true,
    start_pet_monitoring = true, stop_pet_monitoring = true,
    suppress_cooldown_messages = true, temp_tp_bonus_gear = true,
    thf_sa_pending = true, thf_ta_pending = true,
    toggle_retaliation_debug = true, ui_display_config = true,
    ui_manager_state = true, update_brd_song_slots = true,
    user_post_midcast = true, user_post_precast = true,
    warp_detector_callbacks = true, x = true,}

-- Names the factories build at run time, which no scan of `_G.x =` can find.
-- LockstyleManager and MacrobookManager compose them from the job code, so the
-- shape is the only thing that can be checked: get_rdm_lockstyle_info,
-- set_war_dressup_management, cancel_cor_lockstyle_operations and so on.
local GENERATED = {
    '^get_%a%a%a_lockstyle', '^set_%a%a%a_lockstyle', '^show_%a%a%a_lockstyle',
    '^cancel_%a%a%a_lockstyle', '^set_%a%a%a_dressup', '^get_%a%a%a_dressup',
    '^get_%a%a%a_movement', '^%a%a%a_lockstyle',
}

--- Is this one of the names a factory composes at run time?
--- @param name string Global name
--- @return boolean
local function is_generated(name)
    for _, pattern in ipairs(GENERATED) do
        if name:match(pattern) then
            return true
        end
    end
    return false
end

--- Remember what _G looked like once everything was loaded.
---
--- INIT_SYSTEMS defers a good deal of its work by half a second and two
--- seconds, and job modules load later still. Snapshotting at the end of the
--- synchronous part caught none of that, and every deferred module reported as
--- a leak - twenty-five of them on RDM.
--- @see INIT_SYSTEMS, which calls this on a delay for that reason
function GlobalProbe.snapshot()
    local seen = {}
    for k in pairs(_G) do
        seen[k] = true
    end
    _G.__global_baseline = seen
end

--- Globals that appeared since the snapshot and were not declared expected.
--- @return table Sorted list of names
function GlobalProbe.leaks()
    local baseline = rawget(_G, '__global_baseline')
    if not baseline then
        return nil
    end

    local found = {}
    for k, v in pairs(_G) do
        if type(k) == 'string' and not baseline[k] and not EXPECTED[k]
           and k:sub(1, 2) ~= '__' and not is_generated(k) then
            -- A job hook is created when its module loads, which can be after
            -- the snapshot on a lazy path; those are named and legitimate.
            if not k:match('^job_') and not k:match('^user_') then
                found[#found + 1] = k .. ' (' .. type(v) .. ')'
            end
        end
    end
    table.sort(found)
    return found
end

--- Hooks Mote calls by name. A refactor that renames or drops one leaves the
--- job quietly doing nothing at that point in the cycle.
local REQUIRED_HOOKS = {
    'job_precast', 'job_midcast', 'job_post_midcast', 'job_aftercast',
    'job_status_change', 'job_buff_change', 'job_self_command',
}

--- Which of the hooks this job is missing.
--- @return table Names that are not functions right now
function GlobalProbe.missing_hooks()
    local missing = {}
    for _, name in ipairs(REQUIRED_HOOKS) do
        if type(rawget(_G, name)) ~= 'function' then
            missing[#missing + 1] = name
        end
    end
    return missing
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.GlobalProbe = GlobalProbe

return GlobalProbe
