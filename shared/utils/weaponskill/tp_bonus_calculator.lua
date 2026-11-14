---  ═══════════════════════════════════════════════════════════════════════════
---   TP Bonus Calculator
---  ═══════════════════════════════════════════════════════════════════════════
---   Generic TP bonus calculation system for weaponskills
---   Intelligently determines which TP bonus gear to equip based on:
---   - Current TP amount
---   - Weapon TP bonus, main, sub and ranged (e.g., Chango +500, Anarchy +2 +1000; read by weapon_tp_bonus.lua
---     when the job's TP config does not list the weapon: description, augments, path rank)
---   - Buff TP bonus:
---     • WAR: Warcry (+500-700 with Savagery merits + Agoge Mask)
---     • SAM: Hagakure (+1000-1200 with JP Gifts)
---   - Job trait TP bonus:
---     • WAR/BST: Fencer (+200-630 when single-wielding, based on level + JP Gifts)
---   - Available TP bonus pieces (e.g., Moonshade +250, Boii +100, Mpaca's Cap +200)
---
---   decide(): the pieces worth their gain at that TP (tp_piece_decision.lua: the Atelier's table, else the
---   fTP's rise, else the thresholds below). calculate(): the thresholds rule, kept for a weaponskill whose
---   fTP is unknown: only equip TP bonus gear if it reaches the next TP threshold (2000 or 3000), the
---   MINIMUM necessary pieces.
---
---   @file    shared/utils/weaponskill/tp_bonus_calculator.lua
---   @author  ejouanchicot
---   @version 1.4 - decide(): table / formula / thresholds
---   @date    Created: 2025-01-02 | Updated: 2026-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   LAZY LOADING - MessageWeaponskill loaded only in debug mode
---  ═══════════════════════════════════════════════════════════════════════════

local MessageWeaponskill = nil

local function get_message_ws()
    if not MessageWeaponskill then
        MessageWeaponskill = require('shared/utils/messages/formatters/combat/message_weaponskill')
    end
    return MessageWeaponskill
end

local TPBonusCalculator = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   Configuration
---  ═══════════════════════════════════════════════════════════════════════════
TPBonusCalculator.config = {
    thresholds = { 2000, 3000 },
    debug_mode = false
}

---  ═══════════════════════════════════════════════════════════════════════════
---   Core Functions
---  ═══════════════════════════════════════════════════════════════════════════

--- The TP Bonus the weaponskill opens with besides the TP shown, in its three parts.
---
--- Weapon, buff and Fencer bonuses are already in effect when the skill fires,
--- so they count before any gear is chosen.
--- @param tp_config table Job TP config supplying the bonus lookups
--- @param weapon_name string|nil Equipped main weapon
--- @param active_buffs table|nil buffactive, or a stand-in
--- @param sub_weapon string|nil Equipped sub (its own TP Bonus, and Fencer)
--- @param range_weapon string|nil Equipped ranged weapon (its own TP Bonus)
--- @return number weapons, number buffs, number Fencer
local function tp_parts(tp_config, weapon_name, active_buffs, sub_weapon, range_weapon)
    -- the weapon's TP Bonus: the job's config when it lists the weapon, else read from the game and
    -- your gear scan (shared/utils/weaponskill/weapon_tp_bonus.lua: Ikenga's Axe R23 gives 200)
    local WeaponTP = require('shared/utils/weaponskill/weapon_tp_bonus')
    local weapon_bonus = WeaponTP.of(weapon_name, tp_config)
    -- An off-hand TP Bonus weapon counts too (Centovente on THF/DNC is always
    -- the sub): without it, 2750-2999 TP looked short of the cap and Moonshade
    -- replaced an earring for nothing. Same weapon in both hands: counted once.
    if sub_weapon and sub_weapon ~= weapon_name then
        weapon_bonus = weapon_bonus + WeaponTP.of(sub_weapon, tp_config)
    end
    -- The ranged weapon's too, on any weaponskill (COR: Anarchy +2 gives its
    -- +1000 to Savage Blade). Left out, Moonshade went on at 2750 TP for a
    -- weaponskill already at 3000.
    if range_weapon and range_weapon ~= weapon_name and range_weapon ~= sub_weapon then
        weapon_bonus = weapon_bonus + WeaponTP.of(range_weapon, tp_config)
    end

    local buff_bonus = 0
    if active_buffs and active_buffs['Warcry'] and tp_config.get_warcry_bonus then
        buff_bonus = buff_bonus + tp_config.get_warcry_bonus()
    end
    if tp_config.get_hagakure_bonus then
        buff_bonus = buff_bonus + tp_config.get_hagakure_bonus()
    end

    local fencer_bonus = 0
    if weapon_name and tp_config.get_fencer_bonus then
        fencer_bonus = tp_config.get_fencer_bonus(weapon_name, sub_weapon)
    end

    return weapon_bonus, buff_bonus, fencer_bonus
end

--- TP the weaponskill will actually open with: the TP shown plus weapon, buff and Fencer bonuses.
--- @param current_tp number TP shown right now
--- @return number Effective TP
local function effective_tp(current_tp, tp_config, weapon_name, active_buffs, sub_weapon, range_weapon)
    local weapons, buffs, fencer = tp_parts(tp_config, weapon_name, active_buffs, sub_weapon, range_weapon)
    return current_tp + weapons + buffs + fencer
end

--- The next TP threshold worth reaching for.
--- @param real_tp number Effective TP
--- @return number|nil Threshold, or nil when already past the last one
local function next_threshold(real_tp)
    for _, threshold in ipairs(TPBonusCalculator.config.thresholds) do
        if real_tp < threshold then
            return threshold
        end
    end
    return nil
end

--- Job TP pieces, biggest bonus first, with the total they add up to.
--- @param tp_config table Job TP config
--- @return table|nil pieces sorted descending, number total bonus
local function ranked_pieces(tp_config)
    if not tp_config.pieces or type(tp_config.pieces) ~= 'table' then
        return nil, 0
    end

    local sorted = {}
    local total = 0
    for _, piece in ipairs(tp_config.pieces) do
        table.insert(sorted, piece)
        total = total + piece.bonus
    end
    table.sort(sorted, function(a, b) return a.bonus > b.bonus end)
    return sorted, total
end

--- Fewest pieces that close the gap.
---
--- One piece is preferred over several even when a combination would be a
--- tighter fit: every extra slot spent here is a slot taken from the
--- weaponskill set. Of the single pieces that close it, the smallest: a gap of
--- 100 takes Boii Cuisses (+100), not Moonshade (+250), whose ear stays the set's.
--- @param sorted table Pieces, biggest bonus first
--- @param gap number TP still missing
--- @return table|nil slot to item name, or nil when the gap cannot be closed
local function pieces_for_gap(sorted, gap)
    for i = #sorted, 1, -1 do
        local piece = sorted[i]
        if TPBonusCalculator.config.debug_mode then
            get_message_ws().show_checking_piece(piece.name, piece.slot, piece.bonus, gap)
        end
        if piece.bonus >= gap then
            if TPBonusCalculator.config.debug_mode then
                get_message_ws().show_equipping_piece(piece.slot, piece.name, piece.bonus, gap)
            end
            return {[piece.slot] = piece.name}
        end
    end

    local gear_to_equip = {}
    local current_bonus = 0
    for _, piece in ipairs(sorted) do
        if current_bonus < gap then
            gear_to_equip[piece.slot] = piece.name
            current_bonus = current_bonus + piece.bonus
        end
    end

    if current_bonus >= gap then
        return gear_to_equip
    end
    return nil
end

--- A debug line of the weaponskill messages, only when TPBonusCalculator.config.debug_mode is on.
local function debug(what, ...)
    if TPBonusCalculator.config.debug_mode then get_message_ws()[what](...) end
end

-- Every spelling of an ear / ring / range slot, as the config and GearSwap's equip list write them
local SLOT_CANON = {left_ear = 'ear1', lear = 'ear1', right_ear = 'ear2', rear = 'ear2', left_ring = 'ring1',
    lring = 'ring1', right_ring = 'ring2', rring = 'ring2', ranged = 'range'}
local function canon(slot)
    slot = tostring(slot):lower()
    return SLOT_CANON[slot] or slot
end

--- The TP pieces the weaponskill set wears already ({slot = name or item}): their
--- bonus counts as there, and they leave the list of pieces to add (their slot is taken).
--- @return number bonus already worn, table pieces still available
local function split_worn(pieces, worn)
    if type(worn) ~= 'table' then return 0, pieces end
    local by_slot = {}
    for slot, item in pairs(worn) do
        local name = type(item) == 'table' and item.name or item
        if type(name) == 'string' then by_slot[canon(slot)] = name end
    end
    local already, left = 0, {}
    for _, piece in ipairs(pieces) do
        if by_slot[canon(piece.slot)] == piece.name then already = already + piece.bonus
        else table.insert(left, piece) end
    end
    return already, left
end

--- Calculate which TP bonus gear to equip based on current TP and available bonuses
--- @param current_tp number Current TP amount (1000-2999)
--- @param tp_config table Job-specific TP config (pieces, weapons, buffs)
--- @param weapon_name string Current main weapon name
--- @param active_buffs table Table of active buffs (buffactive)
--- @param sub_weapon string Current sub weapon name (optional, for Fencer detection)
--- @param worn table|nil What the weaponskill set puts on ({slot = name or item}): its TP pieces count
--- @param range_weapon string|nil Current ranged weapon name (its TP Bonus counts)
--- @return table|nil Table of gear to equip {ear1="...", legs="..."} or nil if none needed
function TPBonusCalculator.calculate(current_tp, tp_config, weapon_name, active_buffs, sub_weapon, worn, range_weapon)
    if not current_tp or not tp_config then
        debug('show_tp_validation_failed', current_tp, tp_config)
        return nil
    end
    local sorted_all = ranked_pieces(tp_config)
    local already, available = split_worn(sorted_all or {}, worn)
    local real_tp = effective_tp(current_tp, tp_config, weapon_name, active_buffs, sub_weapon, range_weapon) + already
    debug('show_tp_calculation', current_tp, weapon_name,
        weapon_name and tp_config.get_weapon_bonus and tp_config.get_weapon_bonus(weapon_name) or 0, real_tp)
    local target_threshold = next_threshold(real_tp)
    if not target_threshold then
        debug('show_already_at_max')
        return nil
    end
    local gap = target_threshold - real_tp
    debug('show_target_threshold', target_threshold, gap)
    if not sorted_all then return nil end
    local total_available = 0
    for _, piece in ipairs(available) do total_available = total_available + piece.bonus end
    if gap > total_available then
        debug('show_gap_too_large', gap, total_available)
        return nil
    end
    debug('show_total_available', total_available)
    return pieces_for_gap(available, gap)
end

--- The weaponskill's database entry (shared/data/weaponskills/), or nil.
local function ws_info(ws, skill)
    if not ws then return nil end
    local ok, Universal = pcall(require, 'shared/data/weaponskills/UNIVERSAL_WS_DATABASE')
    return ok and Universal and Universal.resolve(ws, skill) or nil
end

--- The Atelier's worked-out variants for this weaponskill and weapon, or nil.
local function table_variants(job, ws, weapon)
    local ok, Table = pcall(require, 'shared/utils/weaponskill/tp_pieces_table')
    return ok and Table and Table.variants(job, ws, weapon) or nil
end

--- Which TP pieces a weaponskill gets, and why (tp_piece_decision.lua: the Atelier's table while the set
--- worn is the one it was worked out for, else the fTP's rise, never on a fixed fTP, the thresholds for an
--- fTP unknown).
--- @param a table {tp = TP shown, config = job TP config, main, sub, range, buffs = buffactive,
---   worn = GearSwap's equip list once the weaponskill set is on (or nil), ws = name, skill = spell.skill,
---   job = main job}
--- @return table|nil gear {slot = name}, table why {source, gain, real_tp, key_tp}
function TPBonusCalculator.decide(a)
    if not a.tp or not a.config then return nil, {source = 'no TP config'} end
    local already, available = split_worn(ranked_pieces(a.config) or {}, a.worn)
    local weapons, buffs, fencer = tp_parts(a.config, a.main, a.buffs, a.sub, a.range)
    local real_tp, key_tp = a.tp + weapons + buffs + fencer + already, a.tp + buffs
    local Decision = require('shared/utils/weaponskill/tp_piece_decision')
    local gear, why = Decision.decide({real_tp = real_tp, key_tp = key_tp, info = ws_info(a.ws, a.skill),
        variants = table_variants(a.job, a.ws, a.main), worn = a.worn, available = available,
        replaces = a.config.replaces, thresholds = function()
            return TPBonusCalculator.calculate(a.tp, a.config, a.main, a.buffs, a.sub, a.worn, a.range)
        end})
    why.real_tp, why.key_tp = real_tp, key_tp
    return gear, why
end

--- TP the weaponskill opens with: the TP shown plus weapon, buff and Fencer bonuses.
--- Read by the Atelier page (shared/utils/atelier/atelier_sim.lua) to place its TP steps.
TPBonusCalculator.effective_tp = effective_tp

_G.TPBonusCalculator = TPBonusCalculator

return TPBonusCalculator
