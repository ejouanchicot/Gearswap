---============================================================================
--- Wardrobe Organizer - Configuration Constants
---============================================================================
--- Defaults for the organizer, plus Config.refresh() which reads the
--- character's _common/inventory/WARDROBE_CONFIG.lua (see the file template,
--- _master/config_global/WARDROBE_CONFIG.lua, for every key). Bags are given
--- by name ('wardrobe 2', 'case') or by FFXI id:
---   0=inventory, 5=satchel, 6=sack, 7=case, 8=wardrobe1, 10=wardrobe2,
---   11..16=wardrobe3..8.
---
--- Without a config the layout follows the wardrobes the character has
--- unlocked: W1 and W2 hold the used gear, the other unlocked wardrobes the
--- rest, nothing is protected.
---
--- @file shared/utils/wardrobe/lib/config.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-05-01
---============================================================================

local Config = {}

Config.INV_BAG = 0

---   What `//gs c wo` should consider "used", which is the real difference
---   between the two flows:
---     'active_job' - only the job currently loaded. Suits a character with
---                    more jobs than wardrobes: re-run it on each job change
---                    and the active job's gear rotates into the primary bags.
---     'all_jobs'   - every job with a set file under data/<char>/sets/. Suits
---                    a character whose whole collection fits at once: run it
---                    when the gear changes, not when the job does.
---   Set per character in WARDROBE_CONFIG.lua. The default keeps the original
---   behaviour for any character without a config.
Config.SCOPE = 'active_job'

---   Items to treat as used even though no gear set names them, so they stay
---   in the primary bags. The warp and teleport rings are added automatically
---   from the warp database; this is for anything else - a Nexus Cape, craft
---   gear, whatever a feature needs but no set mentions.
---
---   It matters most for a character whose overflow bags are Sack/Case/Satchel:
---   FFXI cannot equip from those, so an item filed there is out of reach, not
---   merely out of the way.
Config.KEEP_ITEMS = {}

-- Bag lists the phases read. Config.refresh() sets them from the character's
-- config, else from the wardrobes the character has unlocked:
--   PRIMARY_BAGS   where the used gear goes, in fill order        (USED)
--   OVERFLOW_BAGS  where the rest goes, in push order             (UNUSED)
--   FILL_FALLBACK  where used gear waits when the primary is full
--   PROTECTED      {[bag] = true}, never touched                  (NEVER_TOUCH)
--   ALL_WARDROBES  every bag the organizer scans
--   ALT_*          the same for //gs c wo alt (every job at once)
Config.PRIMARY_BAGS = {8, 10}
Config.OVERFLOW_BAGS = {11, 12, 13, 14, 15, 16}
Config.FILL_FALLBACK = {11, 12, 13, 14, 15, 16}
Config.PROTECTED = {}
Config.ALL_WARDROBES = {8, 10, 11, 12, 13, 14, 15, 16}
Config.ALT_PRIMARY_BAGS  = {8, 10, 11, 12}
Config.ALT_OVERFLOW_BAGS = {13, 14, 15, 16}
Config.ALT_ALL_BAGS      = {8, 10, 11, 12, 13, 14, 15, 16}

-- Placement rules of the character's config (Config.refresh):
--   place       {[item lower] = {bag, ...}}   PLACE
--   jobs        {[JOB] = {bag, ...}}          JOBS
--   types       {[type] = {bag, ...}}         TYPES (weapons, ammo, armor, accessories)
--   never_move  {[item lower] = true}         NEVER_MOVE
Config.RULES = {place = {}, jobs = {}, types = {}, never_move = {}}

-- Bags the rules send gear to that are in neither USED nor UNUSED: Phase 3
-- also scans them, so what does not belong there comes out.
Config.RULE_BAGS = {}

-- Slot keys whose values are item names in sets tables
Config.SLOT_KEYS = {
    main = true,
    sub = true,
    range = true,
    ammo = true,
    head = true,
    body = true,
    hands = true,
    legs = true,
    feet = true,
    neck = true,
    waist = true,
    back = true,
    left_ear = true,
    right_ear = true,
    ear1 = true,
    ear2 = true,
    left_ring = true,
    right_ring = true,
    ring1 = true,
    ring2 = true,
    name = true
}

-- Bag-name >> bag-id (for sets with `bag = 'wardrobe N'` constraints)
Config.BAG_NAME_TO_ID = {
    ['inventory'] = 0,
    ['wardrobe'] = 8,
    ['wardrobe 1'] = 8,
    ['wardrobe1'] = 8,
    ['wardrobe 2'] = 10,
    ['wardrobe2'] = 10,
    ['wardrobe 3'] = 11,
    ['wardrobe3'] = 11,
    ['wardrobe 4'] = 12,
    ['wardrobe4'] = 12,
    ['wardrobe 5'] = 13,
    ['wardrobe5'] = 13,
    ['wardrobe 6'] = 14,
    ['wardrobe6'] = 14,
    ['wardrobe 7'] = 15,
    ['wardrobe7'] = 15,
    ['wardrobe 8'] = 16,
    ['wardrobe8'] = 16
}

-- Timing
Config.MOVE_DELAY = 0.35 -- seconds between FFXI move packets
Config.PHASE_DELAY = 1.5 -- seconds between phases (server sync window)
Config.UNEQUIP_DELAY = 2.0 -- seconds after //gs c naked
Config.POST_BURST_DELAY = 3.0 -- after a 30-packet burst (server processes ~10/s)
Config.SETTLE_DELAY = 2.0 -- before final state snapshot in finish_run

-- Burst & retry tuning
Config.BURST_SIZE = 30 -- max moves per burst (capped at runtime by inv_free)
Config.STUCK_LIMIT = 4 -- give up after this many no-progress bursts
Config.MAX_STEPS = 200 -- absolute cap on burst-steps per phase
Config.MAX_OUTER_ITERATIONS = 12 -- auto-retry whole flow up to this many times
Config.CLEANUP_MAX_PASSES = 3 -- Phase 4 internal retry passes
Config.RETRY_DELAY = 2.5 -- seconds between outer-loop retries (let FFXI settle)
Config.TRULY_STUCK_THRESHOLD = 4 -- consecutive iters with same misplaced count = give up

-- Walking sets recursively
Config.MAX_WALK_DEPTH = 50

-- Debug logging
Config.DEBUG_LOG = true
Config.LOG_PATH = windower.addon_path .. 'data/wardrobe_debug.log'

-- In-game chat formatting
Config.CHAT_TAG = 'Wardrobe'
Config.SEP_CHAR = '='
Config.SEP_LEN = 69  -- same as MessageCore.SEPARATOR_WIDTH

-- Equipment slots used by `//gs c naked` and disable/enable
Config.EQUIP_SLOTS = 'main sub range ammo head body hands legs feet neck waist back ear1 ear2 ring1 ring2'

---  ═══════════════════════════════════════════════════════════════════════════
---   PER-CHARACTER CONFIG  (<Char>/_common/inventory/WARDROBE_CONFIG.lua)
---  ═══════════════════════════════════════════════════════════════════════════
---   Keys (every one optional; the template explains each with examples):
---     SCOPE        'active_job' | 'all_jobs'
---     USED         bags for the used gear, in fill order
---     UNUSED       bags for the rest, in push order (wardrobes or Sack/Case/Satchel)
---     NEVER_TOUCH  bags the organizer never touches
---     KEEP         items counted as used although no set names them
---     NEVER_MOVE   items left where they are
---     PLACE        {['Item'] = bag or {bags}}   an item always in these bags
---     JOBS         {WAR = {bags}}               a job's gear in these bags
---     TYPES        {weapons = {bags}}           used gear of a type in these bags
---     USED_WHEN_ALL / UNUSED_WHEN_ALL           bags for //gs c wo alt
---   The names of the first version still work: PRIMARY_BAGS (USED),
---   OVERFLOW_BAGS (UNUSED), PROTECTED (NEVER_TOUCH), KEEP_ITEMS (KEEP),
---   FILL_FALLBACK, ALL_WARDROBES, ALT_PRIMARY_BAGS, ALT_OVERFLOW_BAGS,
---   ALT_ALL_BAGS.

local BAG_IDS = {
    inventory = 0, satchel = 5, sack = 6, case = 7,
    wardrobe = 8, wardrobe1 = 8, wardrobe2 = 10, wardrobe3 = 11, wardrobe4 = 12,
    wardrobe5 = 13, wardrobe6 = 14, wardrobe7 = 15, wardrobe8 = 16,
    w1 = 8, w2 = 10, w3 = 11, w4 = 12, w5 = 13, w6 = 14, w7 = 15, w8 = 16,
}
local WARDROBES = {8, 10, 11, 12, 13, 14, 15, 16}
local TYPE_NAMES = {weapons = true, ammo = true, armor = true, accessories = true}

--- Snapshot of the defaults, put back before each character config is read.
local DEFAULTS = {}
for _, key in ipairs({'SCOPE', 'KEEP_ITEMS', 'PRIMARY_BAGS', 'OVERFLOW_BAGS', 'FILL_FALLBACK',
        'PROTECTED', 'ALL_WARDROBES', 'ALT_PRIMARY_BAGS', 'ALT_OVERFLOW_BAGS', 'ALT_ALL_BAGS'}) do
    DEFAULTS[key] = Config[key]
end

--- Messages about the config (unknown bag names...), shown by the organizer.
Config.WARNINGS = {}

--- Bag id of a name ('wardrobe 2', 'W2', 'case') or of an id.
--- @param v string|number
--- @return number|nil
function Config.bag_id(v)
    if type(v) == 'number' then return v end
    if type(v) ~= 'string' then return nil end
    local id = BAG_IDS[v:lower():gsub('[%s_]', '')]
    if not id then Config.WARNINGS[#Config.WARNINGS + 1] = 'unknown bag: ' .. v end
    return id
end

--- A bag, or a list of bags, as a list of ids (unknown names dropped).
--- @return table|nil nil when `v` is nil
local function bag_list(v)
    if v == nil then return nil end
    if type(v) ~= 'table' then v = {v} end
    local out, seen = {}, {}
    for _, b in ipairs(v) do
        local id = Config.bag_id(b)
        if id and not seen[id] then seen[id] = true; out[#out + 1] = id end
    end
    return out
end

--- Wardrobes the character has unlocked (all of them when the game does not say).
local function unlocked_wardrobes()
    local out = {}
    for _, id in ipairs(WARDROBES) do
        local bag = windower.ffxi.get_items and windower.ffxi.get_items(id)
        if not bag or bag.enabled ~= false then out[#out + 1] = id end
    end
    return out
end

local function contains(list, v)
    for _, x in ipairs(list or {}) do if x == v then return true end end
    return false
end

--- `list` followed by the items of `more` it does not have yet.
local function union(list, more)
    local out = {}
    for _, b in ipairs(list or {}) do if not contains(out, b) then out[#out + 1] = b end end
    for _, b in ipairs(more or {}) do if not contains(out, b) then out[#out + 1] = b end end
    return out
end

--- The placement rules of the config, names lower-cased and bags as ids.
local function read_rules(cfg)
    local rules = {place = {}, jobs = {}, types = {}, never_move = {}}
    for name, bags in pairs(type(cfg.PLACE) == 'table' and cfg.PLACE or {}) do
        local list = bag_list(bags)
        if list and #list > 0 then rules.place[tostring(name):lower()] = list end
    end
    for job, bags in pairs(type(cfg.JOBS) == 'table' and cfg.JOBS or {}) do
        local list = bag_list(bags)
        if list and #list > 0 then rules.jobs[tostring(job):upper()] = list end
    end
    for kind, bags in pairs(type(cfg.TYPES) == 'table' and cfg.TYPES or {}) do
        local list = bag_list(bags)
        kind = tostring(kind):lower()
        if not TYPE_NAMES[kind] then
            Config.WARNINGS[#Config.WARNINGS + 1] = 'unknown type: ' .. kind .. ' (weapons, ammo, armor, accessories)'
        elseif list and #list > 0 then
            rules.types[kind] = list
        end
    end
    for _, name in ipairs(type(cfg.NEVER_MOVE) == 'table' and cfg.NEVER_MOVE or {}) do
        rules.never_move[tostring(name):lower()] = true
    end
    return rules
end

--- Bags the rules send gear to.
local function rule_bags(rules)
    local out = {}
    for _, group in ipairs({rules.place, rules.jobs, rules.types}) do
        for _, list in pairs(group) do out = union(out, list) end
    end
    return out
end

--- Take every PROTECTED bag out of the bag lists and the rules.
local function strip_protected()
    for _, key in ipairs({'PRIMARY_BAGS', 'OVERFLOW_BAGS', 'FILL_FALLBACK', 'ALL_WARDROBES',
            'ALT_PRIMARY_BAGS', 'ALT_OVERFLOW_BAGS', 'ALT_ALL_BAGS'}) do
        local kept = {}
        for _, bag in ipairs(Config[key] or {}) do
            if not Config.PROTECTED[bag] then kept[#kept + 1] = bag end
        end
        Config[key] = kept
    end
    for _, group in pairs({Config.RULES.place, Config.RULES.jobs, Config.RULES.types}) do
        for key, list in pairs(group) do
            local kept = {}
            for _, bag in ipairs(list) do
                if not Config.PROTECTED[bag] then kept[#kept + 1] = bag end
            end
            group[key] = #kept > 0 and kept or nil
        end
    end
end

-- Path of the last loaded char config (for the chat banner / debug log).
Config.LOADED_CHAR_CONFIG = nil

--- The character's config file as a table ({} when there is none).
local function read_char_config()
    local p = windower.ffxi.get_player()
    if not p or not p.name then return {}, nil end
    local path = require('shared/utils/core/char_paths').file('common', 'WARDROBE_CONFIG.lua', nil, p.name)
    if not (path and windower.file_exists(path)) then return {}, nil end
    local ok, cfg = pcall(dofile, path)
    if not ok or type(cfg) ~= 'table' then
        Config.WARNINGS[#Config.WARNINGS + 1] = 'WARDROBE_CONFIG.lua could not be read: ' .. tostring(cfg)
        return {}, nil
    end
    return cfg, path
end

--- Read the character's WARDROBE_CONFIG.lua over the defaults. Called at the
--- start of every public command (organize/preview/verify/etc.), so a relog
--- or job change picks up the right config without an addon reload.
--- @return string|nil Path of the file read (nil if none / error)
function Config.refresh()
    Config.WARNINGS = {}
    for key, value in pairs(DEFAULTS) do Config[key] = value end
    local cfg, path = read_char_config()
    local unlocked = unlocked_wardrobes()

    Config.SCOPE = cfg.SCOPE or DEFAULTS.SCOPE
    Config.KEEP_ITEMS = cfg.KEEP or cfg.KEEP_ITEMS or {}
    Config.RULES = read_rules(cfg)

    local protected = bag_list(cfg.NEVER_TOUCH or cfg.PROTECTED) or {}
    Config.PROTECTED = {}
    for _, b in ipairs(protected) do Config.PROTECTED[b] = true end

    -- Used gear: the config's bags, else W1 and W2 when unlocked
    local used = bag_list(cfg.USED or cfg.PRIMARY_BAGS)
    if not used then
        used = {}
        for _, b in ipairs({8, 10}) do if contains(unlocked, b) then used[#used + 1] = b end end
    end
    -- The rest: the config's bags, else every other unlocked wardrobe not
    -- reserved by a rule (a JOBS / TYPES / PLACE bag keeps its own gear)
    local reserved = rule_bags(Config.RULES)
    local unused = bag_list(cfg.UNUSED or cfg.OVERFLOW_BAGS)
    if not unused then
        unused = {}
        for _, b in ipairs(unlocked) do
            if not contains(used, b) and not contains(reserved, b) then unused[#unused + 1] = b end
        end
    end
    Config.PRIMARY_BAGS, Config.OVERFLOW_BAGS = used, unused
    Config.FILL_FALLBACK = bag_list(cfg.FILL_FALLBACK) or unused
    Config.ALL_WARDROBES = bag_list(cfg.ALL_WARDROBES) or union(union(used, unused), reserved)

    -- //gs c wo alt: its own bags when given, else the same as //gs c wo
    Config.ALT_PRIMARY_BAGS = bag_list(cfg.USED_WHEN_ALL or cfg.ALT_PRIMARY_BAGS) or used
    Config.ALT_OVERFLOW_BAGS = bag_list(cfg.UNUSED_WHEN_ALL or cfg.ALT_OVERFLOW_BAGS) or unused
    Config.ALT_ALL_BAGS = bag_list(cfg.ALT_ALL_BAGS)
        or union(union(Config.ALT_PRIMARY_BAGS, Config.ALT_OVERFLOW_BAGS), reserved)

    strip_protected()
    Config.RULE_BAGS = {}
    for _, b in ipairs(rule_bags(Config.RULES)) do
        if not contains(Config.PRIMARY_BAGS, b) and not contains(Config.OVERFLOW_BAGS, b) then
            Config.RULE_BAGS[#Config.RULE_BAGS + 1] = b
        end
    end
    Config.LOADED_CHAR_CONFIG = path
    return path
end

--- For //gs c wo alt: every job at once, on the ALT bag lists. Call after
--- refresh().
function Config.use_all_jobs_layout()
    Config.SCOPE = 'all_jobs'
    Config.PRIMARY_BAGS = Config.ALT_PRIMARY_BAGS
    Config.OVERFLOW_BAGS = Config.ALT_OVERFLOW_BAGS
    Config.FILL_FALLBACK = Config.ALT_OVERFLOW_BAGS
    Config.ALL_WARDROBES = Config.ALT_ALL_BAGS
    local kept = {}
    for _, b in ipairs(rule_bags(Config.RULES)) do
        if not contains(Config.PRIMARY_BAGS, b) and not contains(Config.OVERFLOW_BAGS, b) then kept[#kept + 1] = b end
    end
    Config.RULE_BAGS = kept
    Config.ALL_WARDROBES = union(Config.ALL_WARDROBES, kept)
end

-- Bag id -> human label (used by Log.bag_name and chat)
Config.BAG_LABELS = {
    [0]  = 'inv',
    [5]  = 'Satchel',
    [6]  = 'Sack',
    [7]  = 'Case',
    [8]  = 'W1',
    [10] = 'W2',
    [11] = 'W3',
    [12] = 'W4',
    [13] = 'W5',
    [14] = 'W6',
    [15] = 'W7',
    [16] = 'W8',
}

return Config
