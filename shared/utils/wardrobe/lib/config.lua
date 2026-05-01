---  ═══════════════════════════════════════════════════════════════════════════
---   Wardrobe Organizer - Configuration Constants
---  ═══════════════════════════════════════════════════════════════════════════
---   Pure constants. No functions, no state, no FFI calls.
---
---   FFXI bag IDs:
---     0=inventory, 8=wardrobe1, 10=wardrobe2, 11..14=wardrobe3..6,
---     15=wardrobe7 (PROTECTED, craft), 16=wardrobe8.
---
---   @file shared/utils/wardrobe/lib/config.lua
---  ═══════════════════════════════════════════════════════════════════════════

local Config = {}

Config.INV_BAG = 0
Config.PRIMARY_BAGS = {8, 10} -- W1, W2 (target = active job)

-- Overflow priority (push order): W8 first, then W6 > W5 > W4 > W3.
-- Push tries each in order and stops at the first with space, so W8 fills up
-- entirely before the algorithm starts using W6 etc. This keeps the
-- "regular" wardrobes (W6-W3) cleaner. Phase 3 also iterates this list to
-- find used items needing promotion.
Config.OVERFLOW_BAGS = {16, 14, 13, 12, 11} -- W8, W6, W5, W4, W3
Config.FILL_FALLBACK = {16, 14, 13, 12, 11} -- Used items fallback: same order
Config.PROTECTED = {[15] = true} -- ONLY W7 (craft) is protected

-- All wardrobes touched by the algorithm
Config.ALL_WARDROBES = {8, 10, 11, 12, 13, 14, 16}

---  ═══════════════════════════════════════════════════════════════════════════
---   ALT MODE  (4-wardrobe characters, e.g. Kaories)
---  ═══════════════════════════════════════════════════════════════════════════
---   Uses W1-W4 as primary (where used items live) and Sack/Case/Satchel as
---   overflow (where unused items get stored). Scope is "items used by ANY job
---   in data/<charname>/sets/", not just the active job.
---
---   FFXI bag IDs: 5=satchel, 6=sack, 7=case
---   Push order Sack > Case > Satchel  (Satchel last so we don't disrupt
---   any storage slips PorterPacker might keep there).
Config.ALT_PRIMARY_BAGS  = {8, 10, 11, 12}            -- W1, W2, W3, W4
Config.ALT_OVERFLOW_BAGS = {6, 7, 5}                   -- Sack, Case, Satchel
Config.ALT_ALL_BAGS      = {8, 10, 11, 12, 6, 7, 5}    -- all bags scanned in alt mode

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
Config.SEP_LEN = 74

-- Equipment slots used by `//gs c naked` and disable/enable
Config.EQUIP_SLOTS = 'main sub range ammo head body hands legs feet neck waist back ear1 ear2 ring1 ring2'

---  ═══════════════════════════════════════════════════════════════════════════
---   PER-CHARACTER OVERRIDE  (data/<charname>/config/WARDROBE_CONFIG.lua)
---  ═══════════════════════════════════════════════════════════════════════════
---   Loaded by Config.refresh(). The char file may define any subset of:
---     PRIMARY_BAGS, OVERFLOW_BAGS, FILL_FALLBACK, PROTECTED, ALL_WARDROBES,
---     ALT_PRIMARY_BAGS, ALT_OVERFLOW_BAGS, ALT_ALL_BAGS
---   Missing keys keep their default values (defined above).
---
---   Last loaded char's name (for the chat banner / debug log).
Config.LOADED_CHAR_CONFIG = nil

--- Reload character-specific overrides from data/<charname>/config/WARDROBE_CONFIG.lua.
--- Called at the start of every public command (organize/preview/verify/etc.)
--- so a relog or job change picks up the right config without addon reload.
--- @return string|nil Path of the file actually loaded (nil if none / error)
function Config.refresh()
    local p = windower.ffxi.get_player()
    if not p or not p.name then return nil end
    local path = windower.addon_path .. 'data/' .. p.name .. '/config/WARDROBE_CONFIG.lua'
    if not windower.file_exists(path) then
        Config.LOADED_CHAR_CONFIG = nil
        return nil
    end
    local ok, char_cfg = pcall(dofile, path)
    if not ok or type(char_cfg) ~= 'table' then
        Config.LOADED_CHAR_CONFIG = nil
        return nil
    end

    -- Apply overrides (only those defined in the char file)
    if char_cfg.PRIMARY_BAGS      then Config.PRIMARY_BAGS      = char_cfg.PRIMARY_BAGS      end
    if char_cfg.OVERFLOW_BAGS     then Config.OVERFLOW_BAGS     = char_cfg.OVERFLOW_BAGS     end
    if char_cfg.FILL_FALLBACK     then Config.FILL_FALLBACK     = char_cfg.FILL_FALLBACK     end
    if char_cfg.ALL_WARDROBES     then Config.ALL_WARDROBES     = char_cfg.ALL_WARDROBES     end
    if char_cfg.ALT_PRIMARY_BAGS  then Config.ALT_PRIMARY_BAGS  = char_cfg.ALT_PRIMARY_BAGS  end
    if char_cfg.ALT_OVERFLOW_BAGS then Config.ALT_OVERFLOW_BAGS = char_cfg.ALT_OVERFLOW_BAGS end
    if char_cfg.ALT_ALL_BAGS      then Config.ALT_ALL_BAGS      = char_cfg.ALT_ALL_BAGS      end

    -- PROTECTED is given as an array in the char file; convert to set
    if char_cfg.PROTECTED then
        local set = {}
        for _, b in ipairs(char_cfg.PROTECTED) do set[b] = true end
        Config.PROTECTED = set
    end

    -- If FILL_FALLBACK was not explicitly set in the char file, mirror OVERFLOW_BAGS
    -- so push order stays consistent.
    if not char_cfg.FILL_FALLBACK then
        Config.FILL_FALLBACK = Config.OVERFLOW_BAGS
    end

    -- If ALT_ALL_BAGS was not set, derive it from ALT_PRIMARY + ALT_OVERFLOW
    if not char_cfg.ALT_ALL_BAGS and Config.ALT_PRIMARY_BAGS and Config.ALT_OVERFLOW_BAGS then
        local all = {}
        for _, b in ipairs(Config.ALT_PRIMARY_BAGS)  do table.insert(all, b) end
        for _, b in ipairs(Config.ALT_OVERFLOW_BAGS) do table.insert(all, b) end
        Config.ALT_ALL_BAGS = all
    end

    Config.LOADED_CHAR_CONFIG = path
    return path
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
