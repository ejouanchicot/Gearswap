---============================================================================
--- TP Piece Decision - which TP Bonus pieces a weaponskill gets, and why
---============================================================================
--- The fTP of a weaponskill rises in a straight line between its values at
--- 1000, 2000 and 3000 TP, and a TP Bonus counts as that much more TP (capped
--- at 3000): a TP piece is worth what it adds there, against the set piece it
--- replaces. Measured in game on 2026-11-11/12 (notes/docs-perso/moonshade-ftp-
--- 2026-11-11/SPEC.md): Moonshade + Boii Cuisses +3 gave Disaster +17 % under
--- 2000 TP, and -5 % at 3000.
---
--- Three ways to decide, in this order:
---   table       (first, even at 3000 TP) what the Atelier worked out with its damage engine, per
---               weaponskill, weapon and weaponskill set, by step of 50 TP
---               (<Char>/atelier/overrides/tp_pieces_<JOB>.lua, tp_pieces_table.lua): only the TP where
---               the pieces change are written.
---               Used only while the set worn is the one it was worked out for.
---   formula     no table, or the set changed: the fTP's own rise. The first
---               hit's share of the damage x (fTP(TP + bonus) - fTP(TP)) / fTP(TP),
---               less `replaces` (3 % by default) for each set piece taken off.
---               Never a piece on a weaponskill whose fTP stays the same (the TP
---               raises its critical hit rate, accuracy or a duration).
---   thresholds  fTP unknown: the rule before, reach 2000 or 3000 TP
---               (TPBonusCalculator.calculate).
---
--- Everything here is pure: no game call, testable off the game
--- (scripts/atelier/tp_decision_test.lua).
---
--- @file shared/utils/weaponskill/tp_piece_decision.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-11-12
---============================================================================

local Decision = {}

Decision.MIN_TP, Decision.MAX_TP = 1000, 3000
--- What one set piece taken off is worth, when the formula decides (`replaces` in <JOB>_TP_CONFIG.lua)
Decision.DEFAULT_REPLACES = 0.03

-- Every spelling of an ear / ring / range slot
local SLOT_CANON = {left_ear = 'ear1', lear = 'ear1', right_ear = 'ear2', rear = 'ear2', left_ring = 'ring1',
    lring = 'ring1', right_ring = 'ring2', rring = 'ring2', ranged = 'range'}

--- The page's name of a slot ('left_ear' -> 'ear1').
--- @param slot string
--- @return string
function Decision.canon(slot)
    slot = tostring(slot):lower()
    return SLOT_CANON[slot] or slot
end

local function name_of(item)
    if type(item) == 'table' then return item.name end
    return item
end

---  ─────────────────────────────────────────────────────────────────────────
---   The weaponskill's fTP
---  ─────────────────────────────────────────────────────────────────────────

--- The fTP at a TP, in a straight line between the database's 1000 / 2000 / 3000 values.
--- @param ftp table {[1000] = n, [2000] = n, [3000] = n}, all three known
--- @param tp number Clamped to 1000-3000
--- @return number
function Decision.ftp_at(ftp, tp)
    tp = math.max(Decision.MIN_TP, math.min(Decision.MAX_TP, tp))
    if tp <= 2000 then return ftp[1000] + (ftp[2000] - ftp[1000]) * (tp - 1000) / 1000 end
    return ftp[2000] + (ftp[3000] - ftp[2000]) * (tp - 2000) / 1000
end

--- What the TP does to a weaponskill, from its database entry.
--- @param info table|nil Entry of shared/data/weaponskills/*_WS_DATABASE.lua
--- @return string 'rising' (fTP goes up), 'fixed' (same fTP at every TP) or 'unknown'
function Decision.ftp_kind(info)
    local ftp = type(info) == 'table' and info.ftp
    if type(ftp) ~= 'table' or not (ftp[1000] and ftp[2000] and ftp[3000]) then return 'unknown' end
    if ftp[1000] == ftp[2000] and ftp[2000] == ftp[3000] then return 'fixed' end
    return 'rising'
end

--- Share of the damage the TP's fTP moves: 1 when every hit uses it (a replicating or a
--- magical weaponskill), else the first hit against the others at fTP 1.
--- @param info table Database entry
--- @param f number The fTP at that TP
--- @return number 0-1
function Decision.first_hit_share(info, f)
    if info.replicating or info.type == 'Magical' or info.type == 'Hybrid' then return 1 end
    local hits = tonumber(info.hits) or 1
    return f / (f + math.max(0, hits - 1))
end

--- What a TP Bonus adds to the weaponskill's damage, by the fTP alone.
--- @param info table Database entry, fTP 'rising'
--- @param real_tp number TP the weaponskill opens with
--- @param bonus number TP Bonus added
--- @return number Fraction (0.17 = +17 %)
function Decision.formula_gain(info, real_tp, bonus)
    local from = Decision.ftp_at(info.ftp, real_tp)
    local to = Decision.ftp_at(info.ftp, real_tp + bonus)
    if from <= 0 then return 0 end
    return Decision.first_hit_share(info, from) * (to - from) / from
end

---  ─────────────────────────────────────────────────────────────────────────
---   The pieces
---  ─────────────────────────────────────────────────────────────────────────

--- Every non-empty combination of the pieces, one slot each.
--- @param pieces table {{slot, name, bonus}...}
--- @return table {{gear = {slot = name}, bonus = n, count = n}...}
function Decision.combinations(pieces)
    local out = {}
    local n = math.min(#pieces, 6)
    for mask = 1, 2 ^ n - 1 do
        local gear, bonus, count, taken, ok = {}, 0, 0, {}, true
        for i = 1, n do
            if math.floor(mask / 2 ^ (i - 1)) % 2 == 1 then
                local p, slot = pieces[i], Decision.canon(pieces[i].slot)
                if taken[slot] then ok = false end
                taken[slot] = true
                gear[slot], bonus, count = p.name, bonus + p.bonus, count + 1
            end
        end
        if ok then out[#out + 1] = {gear = gear, bonus = bonus, count = count} end
    end
    return out
end

--- The best combination by the formula, or nil when none is worth its set pieces.
--- @param info table Database entry, fTP 'rising'
--- @param real_tp number TP the weaponskill opens with (its set's TP pieces counted)
--- @param pieces table Pieces still available {{slot, name, bonus}...}
--- @param replaces number|nil What one set piece taken off is worth (fraction)
--- @return table|nil gear, number gain of that gear (the best tried when nil)
function Decision.by_formula(info, real_tp, pieces, replaces)
    replaces = tonumber(replaces) or Decision.DEFAULT_REPLACES
    local best, best_net, best_gain = nil, 0, 0
    for _, c in ipairs(Decision.combinations(pieces)) do
        local gain = Decision.formula_gain(info, real_tp, c.bonus)
        local net = gain - replaces * c.count
        if net > best_net then best, best_net, best_gain = c.gear, net, gain end
    end
    return best, best_gain
end

---  ─────────────────────────────────────────────────────────────────────────
---   The Atelier's table
---  ─────────────────────────────────────────────────────────────────────────

--- Whether the set worn is the one a table variant was worked out for: each of its
--- slots holds the same piece (names; the TP pieces count like any other). A slot the
--- equip list does not hold is skipped: GearSwap leaves out a slot locked by
--- //gs disable (helper_functions.lua set_merge); at least half the set must be compared.
--- @param set table {slot = name} of the variant
--- @param worn table|nil {slot = name or item} GearSwap's equip list once the weaponskill set is on
--- @return boolean
function Decision.same_set(set, worn)
    if type(set) ~= 'table' or type(worn) ~= 'table' then return false end
    local by_slot = {}
    for slot, item in pairs(worn) do
        local name = name_of(item)
        if type(name) == 'string' then by_slot[Decision.canon(slot)] = name:lower() end
    end
    -- names compared whatever their case: a set file may write "Moonshade earring"
    local total, compared = 0, 0
    for slot, name in pairs(set) do
        local here, want = by_slot[Decision.canon(slot)], tostring(name):lower()
        total = total + 1
        if here ~= nil then
            if here ~= want and not (want == 'empty' and here == 'empty') then return false end
            compared = compared + 1
        end
    end
    return compared > 0 and compared * 2 >= total
end

--- The variant of a weaponskill and weapon whose set is the one worn.
--- @param variants table|nil {{set = {slot = name}, segments}...}
--- @param worn table|nil GearSwap's equip list
--- @return table|nil
function Decision.matching_variant(variants, worn)
    if type(variants) ~= 'table' then return nil end
    for _, v in ipairs(variants) do
        if Decision.same_set(v.set, worn) then return v end
    end
    return nil
end

--- The table's row for a TP: its pieces and gain.
--- @param variant table {segments = {{tp = 1000, p = {slot = name}, g = n}, {tp = 2000, ...}...}}: each segment
---   holds from its TP to the next one's (g: what its pieces add at its first TP). The first table the page
---   wrote (2026-11-12) had a row every `step` TP from `from` (`rows`): still read
--- @param key_tp number TP shown plus the buffs' TP Bonus (the weapon's and Fencer's are in the table)
--- @return table|nil row
function Decision.row_at(variant, key_tp)
    local segments = variant.segments
    if type(segments) == 'table' and #segments > 0 then
        local found = segments[1]
        for _, seg in ipairs(segments) do
            if (tonumber(seg.tp) or 0) <= key_tp then found = seg else break end
        end
        return found
    end
    local rows, from, step = variant.rows, tonumber(variant.from) or 1000, tonumber(variant.step) or 50
    if type(rows) ~= 'table' or #rows == 0 then return nil end
    local i = math.floor((key_tp - from) / step) + 1
    return rows[math.max(1, math.min(#rows, i))]
end

--- The row's pieces, kept to those the job's config still offers (a slot the set already
--- fills with a TP piece is not offered twice).
--- @return table|nil gear
local function row_gear(row, available)
    if type(row) ~= 'table' or type(row.p) ~= 'table' or next(row.p) == nil then return nil end
    local offered = {}
    for _, p in ipairs(available) do offered[Decision.canon(p.slot)] = p.name end
    local gear = {}
    for slot, name in pairs(row.p) do
        if offered[Decision.canon(slot)] ~= name then return nil end
        gear[Decision.canon(slot)] = name
    end
    return gear
end

---  ─────────────────────────────────────────────────────────────────────────
---   The decision
---  ─────────────────────────────────────────────────────────────────────────

--- Which TP pieces to put on, and why.
--- @param a table
---   real_tp    TP the weaponskill opens with (TPBonusCalculator.effective_tp + the set's own TP pieces)
---   key_tp     TP shown + the buffs' TP Bonus (the table's index)
---   info       database entry of the weaponskill, or nil
---   variants   the table's variants for this weaponskill and weapon, or nil
---   worn       GearSwap's equip list once the weaponskill set is on, or nil
---   available  the job's TP pieces the set does not wear already
---   replaces   `replaces` of the job's TP config
---   thresholds function() -> gear: the rule before, for an fTP unknown
--- @return table|nil gear, table why {source, gain}
function Decision.decide(a)
    -- the table first, even at 3000 TP: a piece can be worth its other stats there (Boii Cuisses' PDL over
    -- Nyame Flanchard on Disaster, +1.5 % by the engine), which the engine counted; the TP cap is in its figures
    local variant = Decision.matching_variant(a.variants, a.worn)
    if variant then
        local row = Decision.row_at(variant, a.key_tp)
        -- gain: what the segment's pieces add at its first TP (`at`), not at this TP
        return row_gear(row, a.available), {source = 'table', gain = row and tonumber(row.g) or 0, at = row and tonumber(row.tp)}
    end
    if a.real_tp >= Decision.MAX_TP then return nil, {source = 'capped', gain = 0} end
    local why = a.variants and 'formula (set changed)' or 'formula'
    local kind = Decision.ftp_kind(a.info)
    if kind == 'fixed' then return nil, {source = why .. ', fixed fTP', gain = 0} end
    if kind == 'unknown' then
        return a.thresholds and a.thresholds() or nil, {source = 'thresholds (fTP unknown)'}
    end
    local gear, gain = Decision.by_formula(a.info, a.real_tp, a.available, a.replaces)
    return gear, {source = why, gain = gain}
end

_G.TPPieceDecision = Decision

return Decision
