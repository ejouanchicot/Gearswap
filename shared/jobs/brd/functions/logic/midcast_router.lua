---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Midcast Router - Spell Skill Handlers
---  ═══════════════════════════════════════════════════════════════════════════
---   Per-skill handlers extracted from BRD_MIDCAST.lua. Each handler routes
---   to the appropriate logic - mostly delegating to MidcastManager, with
---   BRD-specific song handling (dummy songs, debuff songs, instrument lock).
---
---   Public API (called by BRD_MIDCAST.job_post_midcast dispatcher):
---     • handle_singing(spell, ctx)     - dummy/debuff/normal song dispatch
---     • handle_healing(spell, ctx)     - Cure / Healing Magic
---     • handle_enhancing(spell, ctx)   - Stoneskin/etc + target_func + database
---     • handle_enfeebling(spell, ctx)  - Slow/Paralyze (RDM subjob)
---     • handle_elemental(spell, ctx)   - Elemental Magic (BLM subjob)
---
---   ctx (context) table fields used by handlers:
---     • debug_enabled (boolean)
---     • message_formatter (MessageFormatter module)
---     • brd_spells (BRD_SPELL_DATABASE module or nil)
---     • brd_spells_loaded (boolean)
---     • enhancing_database (function|nil: spell_name -> spell_family)
---
---   @file    jobs/brd/functions/logic/midcast_router.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-09
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastManager = nil

local function ensure_loaded()
    if not MidcastManager then
        MidcastManager = require('shared/utils/midcast/midcast_manager')
    end
end

local Router = {}

-- Songs that don't equip weapons (use dedicated debuff sets without main/sub)
-- Lullaby and Threnody are matched by pattern (all variants)
local DEBUFF_SONGS = {
    'Battlefield Elegy',
    'Carnage Elegy',
    'Foe Requiem',
    "Maiden's Virelai",
    'Pining Nocturne',
    'Magic Finale',
}

---  ═══════════════════════════════════════════════════════════════════════════
---   PRIVATE HELPERS - Song detection
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if song is a dummy song (uses player-chosen instrument like Daurdabla)
--- Reads centralized BRDSongConfig.DUMMY_SONGS list (loaded by entry point)
local function is_dummy_song(spell_name)
    if not _G.BRDSongConfig or not _G.BRDSongConfig.DUMMY_SONGS then
        return false
    end

    for _, dummy in ipairs(_G.BRDSongConfig.DUMMY_SONGS.standard) do
        if spell_name == dummy then
            return true
        end
    end

    return false
end

--- Check if song should NOT equip weapons (debuff songs that use sets without main/sub)
local function is_no_weapon_song(spell_name)
    -- Lullaby and Threnody (all variants)
    if spell_name:match('Lullaby') or spell_name:match('Threnody') then
        return true
    end

    -- Specific debuff songs
    for _, song in ipairs(DEBUFF_SONGS) do
        if spell_name:match(song) then
            return true
        end
    end

    return false
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PRIVATE HELPERS - Singing sub-handlers
---  ═══════════════════════════════════════════════════════════════════════════

--- Detect target name + type for "Spell Activated" message.
--- Priority: party/alliance > charmed > spawn_type 16 > is_npc > .type > MONSTER
--- @return target_name string|nil, target_type string|nil
local function detect_target_info(spell)
    if not (spell.target and spell.target.name and spell.target.name ~= player.name) then
        return nil, nil
    end

    local target_name = spell.target.name
    local target_type

    if spell.target.in_party or spell.target.in_alliance then
        target_type = "PLAYER"
    elseif spell.target.charmed then
        target_type = "PLAYER"
    elseif spell.target.spawn_type == 16 then
        target_type = "MONSTER"
    elseif spell.target.is_npc then
        target_type = "NPC"
    elseif spell.target.type then
        target_type = spell.target.type
    else
        target_type = "MONSTER"
    end

    return target_name, target_type
end

--- Display "Spell Activated" message for normal (non-dummy) songs.
--- Looks up description + element from BRDSpells DB if available.
local function show_normal_song_message(spell, ctx)
    local description = nil
    local element = nil

    if ctx.brd_spells_loaded and ctx.brd_spells and ctx.brd_spells.spells[spell.english] then
        description = ctx.brd_spells.spells[spell.english].description
        element = ctx.brd_spells.spells[spell.english].element
    end

    local target_name, target_type = detect_target_info(spell)

    ctx.message_formatter.show_spell_activated(
        spell.english, description, target_name, spell.skill, element, target_type
    )
end

--- Equip dummy song set (player-chosen instrument like Daurdabla) + display message.
local function handle_dummy_song(spell, ctx)
    if not (sets.midcast and sets.midcast.DummySong) then
        return
    end

    equip(sets.midcast.DummySong)

    -- Extract instrument name from the set for display
    local instrument = sets.midcast.DummySong.range or 'Unknown'
    ctx.message_formatter.show_daurdabla_dummy(spell.english, instrument)
end

--- Equip normal song via MidcastManager + lock instrument if Honor March / Aria of Passion.
--- MidcastManager handles: exact name -> base song -> song type -> instrument -> Troubadour -> base.
local function equip_normal_song(spell, ctx)
    MidcastManager.select_set({
        skill = 'Singing',
        spell = spell,
    })

    -- CRITICAL: Instrument Lock Protection - force locked instrument AFTER MidcastManager
    -- Honor March requires Marsyas, Aria of Passion requires Loughnashade.
    -- Globals set by BRD_PRECAST.lua when starting the cast.
    if _G.casting_locked_song and spell.type == 'BardSong'
       and _G.locked_song_name == spell.english and _G.locked_instrument then
        equip({range = _G.locked_instrument})
        if ctx.debug_enabled then
            ctx.message_formatter.show_debug('BRD', 'Instrument locked: ' .. _G.locked_instrument)
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC HANDLERS
---  ═══════════════════════════════════════════════════════════════════════════

--- Singing: dispatch between dummy / debuff / normal song handling.
function Router.handle_singing(spell, ctx)
    ensure_loaded()

    local is_dummy = is_dummy_song(spell.english)

    -- Normal songs (non-dummy): show description message
    if not is_dummy and spell.english then
        show_normal_song_message(spell, ctx)
    end

    -- Dummy songs: equip DummySong set + special daurdabla message, then exit
    if is_dummy then
        handle_dummy_song(spell, ctx)
        return
    end

    -- Debuff songs (Lullaby, Threnody, Elegy, Requiem, Virelai, Nocturne, Finale):
    -- NO weapon swap - let Mote-Include equip the matching dedicated set.
    if is_no_weapon_song(spell.english) then
        return
    end

    -- Normal songs: full MidcastManager + instrument lock
    equip_normal_song(spell, ctx)
end

--- Healing Magic (Cure) - subjob delegation to MidcastManager.
function Router.handle_healing(spell, ctx)
    ensure_loaded()
    MidcastManager.select_set({skill = 'Healing Magic', spell = spell})
end

--- Enhancing Magic (Stoneskin/Phalanx/etc.) - subjob with Composure target + spell_family DB.
function Router.handle_enhancing(spell, ctx)
    ensure_loaded()
    MidcastManager.select_set({
        skill = 'Enhancing Magic',
        spell = spell,
        target_func = MidcastManager.get_enhancing_target,
        database_func = ctx.enhancing_database,
    })
end

--- Enfeebling Magic (Slow/Paralyze/etc., usually from RDM subjob) - delegation to MidcastManager.
function Router.handle_enfeebling(spell, ctx)
    ensure_loaded()
    MidcastManager.select_set({skill = 'Enfeebling Magic', spell = spell})
end

--- Elemental Magic (from BLM subjob) - delegation to MidcastManager.
function Router.handle_elemental(spell, ctx)
    ensure_loaded()
    MidcastManager.select_set({skill = 'Elemental Magic', spell = spell})
end

return Router
