---  ═══════════════════════════════════════════════════════════════════════════
---   TP Bonus Calculator
---  ═══════════════════════════════════════════════════════════════════════════
---   Generic TP bonus calculation system for weaponskills
---   Intelligently determines which TP bonus gear to equip based on:
---   - Current TP amount
---   - Weapon TP bonus (e.g., Chango +500, Dojikiri Yasutsuna +500)
---   - Buff TP bonus:
---     • WAR: Warcry (+500-700 with Savagery merits + Agoge Mask)
---     • SAM: Hagakure (+1000-1200 with JP Gifts)
---   - Job trait TP bonus:
---     • WAR/BST: Fencer (+200-630 when single-wielding, based on level + JP Gifts)
---   - Available TP bonus pieces (e.g., Moonshade +250, Boii +100, Mpaca's Cap +200)
---
---   Logic: Only equip TP bonus gear if it allows reaching the next TP threshold (2000 or 3000)
---   Equipment strategy: Equip the MINIMUM necessary pieces to reach threshold
---
---   @module  TP_BONUS_CALCULATOR
---   @author  Tetsouo
---   @version 1.3 - Lazy loading for MessageWeaponskill
---   @date    Created: 2025-01-02 | Updated: 2025-11-27
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
    -- TP thresholds for weaponskills
    thresholds = { 2000, 3000 },

    -- Debug mode
    debug_mode = false
}

---  ═══════════════════════════════════════════════════════════════════════════
---   Core Functions
---  ═══════════════════════════════════════════════════════════════════════════

--- Calculate which TP bonus gear to equip based on current TP and available bonuses
--- @param current_tp number Current TP amount (1000-2999)
--- @param tp_config table Job-specific TP config (pieces, weapons, buffs)
--- @param weapon_name string Current main weapon name
--- @param active_buffs table Table of active buffs (buffactive)
--- @param sub_weapon string Current sub weapon name (optional, for Fencer detection)
--- @return table|nil Table of gear to equip {ear1="...", legs="..."} or nil if none needed
--- TP the weaponskill will actually open with.
---
--- Weapon, buff and Fencer bonuses are already in effect when the skill fires,
--- so they count towards the threshold before any gear is chosen.
--- @param current_tp number TP shown right now
--- @param tp_config table Job TP config supplying the bonus lookups
--- @param weapon_name string|nil Equipped main weapon
--- @param active_buffs table|nil buffactive, or a stand-in
--- @param sub_weapon string|nil Equipped sub, which Fencer depends on
--- @return number Effective TP
local function effective_tp(current_tp, tp_config, weapon_name, active_buffs, sub_weapon)
    local weapon_bonus = 0
    if weapon_name and tp_config.get_weapon_bonus then
        weapon_bonus = tp_config.get_weapon_bonus(weapon_name)
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

    return current_tp + weapon_bonus + buff_bonus + fencer_bonus
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
--- weaponskill set.
--- @param sorted table Pieces, biggest bonus first
--- @param gap number TP still missing
--- @return table|nil slot to item name, or nil when the gap cannot be closed
local function pieces_for_gap(sorted, gap)
    for _, piece in ipairs(sorted) do
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

function TPBonusCalculator.calculate(current_tp, tp_config, weapon_name, active_buffs, sub_weapon)
    if not current_tp or not tp_config then
        if TPBonusCalculator.config.debug_mode then
            get_message_ws().show_tp_validation_failed(current_tp, tp_config)
        end
        return nil
    end

    local real_tp = effective_tp(current_tp, tp_config, weapon_name, active_buffs, sub_weapon)

    if TPBonusCalculator.config.debug_mode then
        local weapon_bonus = 0
        if weapon_name and tp_config.get_weapon_bonus then
            weapon_bonus = tp_config.get_weapon_bonus(weapon_name)
        end
        get_message_ws().show_tp_calculation(current_tp, weapon_name, weapon_bonus, real_tp)
    end

    local target_threshold = next_threshold(real_tp)
    if not target_threshold then
        if TPBonusCalculator.config.debug_mode then
            get_message_ws().show_already_at_max()
        end
        return nil
    end

    local gap = target_threshold - real_tp
    if TPBonusCalculator.config.debug_mode then
        get_message_ws().show_target_threshold(target_threshold, gap)
    end

    local sorted, total_available = ranked_pieces(tp_config)
    if not sorted then
        return nil
    end

    if gap > total_available then
        if TPBonusCalculator.config.debug_mode then
            get_message_ws().show_gap_too_large(gap, total_available)
        end
        return nil
    end

    if TPBonusCalculator.config.debug_mode then
        get_message_ws().show_total_available(total_available)
    end

    return pieces_for_gap(sorted, gap)
end

--- Get expected final TP after applying TP bonus gear
--- @param current_tp number Current TP
--- @param gear_table table Gear to equip (result from calculate())
--- @param tp_config table Job-specific TP config
--- @param weapon_name string Current main weapon
--- @param active_buffs table Active buffs
--- @return number Expected final TP
function TPBonusCalculator.get_final_tp(current_tp, gear_table, tp_config, weapon_name, active_buffs)
    local total_tp = current_tp

    -- Add weapon bonus
    if weapon_name and tp_config.get_weapon_bonus then
        total_tp = total_tp + tp_config.get_weapon_bonus(weapon_name)
    end

    -- Add buff bonuses
    -- WAR: Warcry
    if active_buffs and active_buffs['Warcry'] and tp_config.get_warcry_bonus then
        total_tp = total_tp + tp_config.get_warcry_bonus()
    end

    -- SAM: Hagakure
    if tp_config.get_hagakure_bonus then
        total_tp = total_tp + tp_config.get_hagakure_bonus()
    end

    -- Add gear bonus from TP bonus pieces
    -- Check both gear_table (dynamically equipped) and currently equipped gear
    local counted_slots = {}

    -- First, add from gear_table (Moonshade/Boii from TP bonus system)
    if gear_table then
        for slot, item_name in pairs(gear_table) do
            for _, piece in ipairs(tp_config.pieces) do
                if piece.slot == slot and piece.name == item_name then
                    total_tp = total_tp + piece.bonus
                    counted_slots[slot] = true
                    break
                end
            end
        end
    end

    -- Then check currently equipped gear for TP bonus pieces not already counted
    -- (e.g., Boii Cuisses +3 already in WS set)
    if player and player.equipment then
        for _, piece in ipairs(tp_config.pieces) do
            if not counted_slots[piece.slot] then
                local equipped_item = player.equipment[piece.slot]
                if equipped_item == piece.name then
                    total_tp = total_tp + piece.bonus
                end
            end
        end
    end

    -- Cap at 3000 TP (FFXI hard limit)
    if total_tp > 3000 then
        total_tp = 3000
    end

    return total_tp
end

-- Make globally available
_G.TPBonusCalculator = TPBonusCalculator

return TPBonusCalculator
