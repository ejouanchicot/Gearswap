---============================================================================
--- BST Ecosystem Correlation Database
---============================================================================
--- Monster ecosystem correlation data (strengths and weaknesses).
--- Not loaded by any file today (no require of BST_ECOSYSTEM_DATA).
---
--- @file config/bst/BST_ECOSYSTEM_DATA.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

local BSTEcosystemData = {}

---============================================================================
--- ECOSYSTEM CORRELATION MATRIX
---============================================================================

--- Monster correlation (who intimidates whom), checked 2026-10-27 on BG-Wiki's eleven
--- "<Family> Killer" pages ("All Beasts have this trait" on Lizard Killer...) and the
--- JP wiki's chart (wiki.ffo.jp/html/3253.html):
---   Beast >> Lizard >> Vermin >> Plantoid >> Beast   (four, circular)
---   Bird >> Aquan >> Amorph >> Bird                  (three, circular)
---   Undead <> Arcana, Demon <> Dragon                (each strong AND weak against the other)
--- The same family: neither. Luminian / Luminion, elementals, beastmen: none.
--- (Until 2026-10-27 this table had Lizard >> Plantoid and no relation for Vermin.)
BSTEcosystemData.correlation_matrix = {
    -- Beast >> Lizard >> Vermin >> Plantoid >> Beast
    ["Beast"]    = { strong_against = { "Lizard" },   weak_to = { "Plantoid" }, cycle_type = "circular", group = 1 },
    ["Lizard"]   = { strong_against = { "Vermin" },   weak_to = { "Beast" },    cycle_type = "circular", group = 1 },
    ["Vermin"]   = { strong_against = { "Plantoid" }, weak_to = { "Lizard" },   cycle_type = "circular", group = 1 },
    ["Plantoid"] = { strong_against = { "Beast" },    weak_to = { "Vermin" },   cycle_type = "circular", group = 1 },

    -- Bird >> Aquan >> Amorph >> Bird
    ["Bird"]     = { strong_against = { "Aquan" },    weak_to = { "Amorph" },   cycle_type = "circular", group = 2 },
    ["Aquan"]    = { strong_against = { "Amorph" },   weak_to = { "Bird" },     cycle_type = "circular", group = 2 },
    ["Amorph"]   = { strong_against = { "Bird" },     weak_to = { "Aquan" },    cycle_type = "circular", group = 2 },

    -- each pair strong and weak against the other
    ["Undead"]   = { strong_against = { "Arcana" },   weak_to = { "Arcana" },   cycle_type = "reciprocal", group = 3 },
    ["Arcana"]   = { strong_against = { "Undead" },   weak_to = { "Undead" },   cycle_type = "reciprocal", group = 3 },
    ["Demon"]    = { strong_against = { "Dragon" },   weak_to = { "Dragon" },   cycle_type = "reciprocal", group = 4 },
    ["Dragon"]   = { strong_against = { "Demon" },    weak_to = { "Demon" },    cycle_type = "reciprocal", group = 4 },
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if ecosystem A is strong against ecosystem B
--- @param eco_a string Ecosystem A
--- @param eco_b string Ecosystem B
--- @return boolean is_strong True if A is strong against B
function BSTEcosystemData.is_strong_against(eco_a, eco_b)
    if not BSTEcosystemData.correlation_matrix[eco_a] then
        return false
    end

    local strengths = BSTEcosystemData.correlation_matrix[eco_a].strong_against
    if not strengths then
        return false
    end

    for _, eco in ipairs(strengths) do
        if eco == eco_b then
            return true
        end
    end

    return false
end

--- Check if ecosystem A is weak to ecosystem B
--- @param eco_a string Ecosystem A
--- @param eco_b string Ecosystem B
--- @return boolean is_weak True if A is weak to B
function BSTEcosystemData.is_weak_to(eco_a, eco_b)
    if not BSTEcosystemData.correlation_matrix[eco_a] then
        return false
    end

    local weaknesses = BSTEcosystemData.correlation_matrix[eco_a].weak_to
    if not weaknesses then
        return false
    end

    for _, eco in ipairs(weaknesses) do
        if eco == eco_b then
            return true
        end
    end

    return false
end

--- Get ecosystem correlation group (1, 2, or 3)
--- @param ecosystem string Ecosystem name
--- @return number group Group number (1-4) or nil if not found
function BSTEcosystemData.get_correlation_group(ecosystem)
    if not BSTEcosystemData.correlation_matrix[ecosystem] then
        return nil
    end

    return BSTEcosystemData.correlation_matrix[ecosystem].group
end

--- Get ecosystem cycle type ("circular" or "reciprocal")
--- @param ecosystem string Ecosystem name
--- @return string cycle_type "circular", "reciprocal", or nil
function BSTEcosystemData.get_cycle_type(ecosystem)
    if not BSTEcosystemData.correlation_matrix[ecosystem] then
        return nil
    end

    return BSTEcosystemData.correlation_matrix[ecosystem].cycle_type
end

---============================================================================
--- ECOSYSTEM ADVANTAGE CALCULATOR
---============================================================================

--- Calculate advantage/disadvantage between two ecosystems
--- @param attacker_eco string Attacker's ecosystem
--- @param defender_eco string Defender's ecosystem
--- @return string advantage "strong", "weak", "neutral", or "unknown"
function BSTEcosystemData.calculate_advantage(attacker_eco, defender_eco)
    if not attacker_eco or not defender_eco then
        return "unknown"
    end

    if attacker_eco == defender_eco then
        return "neutral"
    end

    if BSTEcosystemData.is_strong_against(attacker_eco, defender_eco) then
        return "strong"
    end

    if BSTEcosystemData.is_weak_to(attacker_eco, defender_eco) then
        return "weak"
    end

    return "neutral"
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BSTEcosystemData
