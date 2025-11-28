---============================================================================
--- BST Ready Move Categorizer
---============================================================================
--- Categorizes pet ready moves into 4 types for midcast gear selection:
---   • Physical (single-target physical attacks)
---   • PhysicalMulti (multi-hit physical attacks)
---   • MagicAtk (magical attack moves)
---   • MagicAcc (magical accuracy/debuff moves)
---
--- @file jobs/bst/functions/logic/ready_move_categorizer.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

local ReadyMoveCategorizer = {}

---============================================================================
--- READY MOVE CATEGORIES (Using Windower S{} sets for fast lookup)
---============================================================================

--- Physical Moves (Single-hit physical attacks)
--- Use: Pet physical attack gear (Pet: Accuracy, Attack, Store TP)
ReadyMoveCategorizer.petPhysicalMoves =
    S {
    'Foot Kick',
    'Whirl Claws',
    'Big Scissors',
    'Tail Blow',
    'Blockhead',
    'Brain Crush',
    'Sensilla Blades',
    'Tegmina Buffet',
    'Lamb Chop',
    'Sheep Charge',
    'Swooping Frenzy',
    'Recoil Dive',
    'Frogkick',
    'Queasyshroom',
    'Numbshroom',
    'Shakeshroom',
    'Nimble Snap',
    'Cyclotail',
    'Somersault',
    'Spinning Top',
    'Suction',
    'Tortoise Stomp',
    'Power Attack',
    'Rhino Attack',
    'Razor Fang',
    'Claw Cyclone',
    'Sickle Slash',
    'Mandibular Bite',
    'Scythe Tail',
    'Ripper Fang',
    'Beak Lunge',
    'Spiral Spin',
    'Sudden Lunge',
    'Head Butt',
    'Wild Oats',
    'Leaf Dagger',
    'Needle Shot',
    'Disembowel',
    'Extirpating Salvo',
    'Mega Scissors',
    'Rhinowrecker',
    'Back Heel',
    'Fluid Toss',
    'Fluid Spread'
}

--- Physical Multi Moves (Multi-hit physical attacks)
--- Use: Pet multi-attack gear (Pet: Multi-Attack+, Store TP, Attack)
ReadyMoveCategorizer.petPhysicalMultiMoves =
    S {
    'Pentapeck',
    'Tickling Tendrils',
    'Wing Slap',
    'Pecking Flurry',
    'Chomp Rush',
    'Hoof Volley',
    'Sweeping Gouge',
    'Double Claw',
    'Grapple'
}

--- Magic Attack Moves (Magical attack moves - damage only)
--- Use: Pet magic attack gear (Pet: MAB, Magic Accuracy)
ReadyMoveCategorizer.petMagicAtkMoves =
    S {
    -- WARRIOR PETS
    'Venom',
    'Fireball',
    'Snow Cloud',
    'Dust Cloud',
    'Acid Spray',
    'Molting Plumage',
    'Cursed Sphere',
    'Acid Mist',
    'Purulent Ooze',
    'Stink Bomb',
    'Nectarous Deluge',
    'Charged Whisker',
    'Dark Spore',
    'Silence Gas',
    'Nepenthic Plunge',
    'Corrosive Ooze',
    -- NON-WARRIOR PETS
    'Bubble Shower',
    'Venom Shower',
    'Gloom Spray',
    'Foul Waters',
    'Pestilent Plume'
}

--- Magic Accuracy Moves (Magical accuracy/debuff moves - debuffs, steals, drains)
--- Use: Pet magic accuracy gear (Pet: Magic Accuracy, Magic Attack Bonus)
ReadyMoveCategorizer.petMagicAccMoves =
    S {
    -- TP Drain
    'Drainkiss',
    'TP Drainkiss',
    -- Sleep
    'Sheep Song',
    'Soporific',
    -- Debuffs / Stat Down
    'Scream',
    'Dream Flower',
    'Roar',
    'Spoil',
    'Noisome Powder',
    'Infrasonics',
    'Hi-Freq Field',
    'Sonic Buffet',
    -- Buffs (Self)
    'Wild Carrot',
    'Bubble Curtain',
    'Scissor Guard',
    'Metallic Body',
    'Harden Shell',
    'Secretion',
    'Rage',
    'Sheep Bleat',
    'Molting',
    'Zealous Snort',
    'Rhinocerator',
    -- Paralyze
    'Palsy Pollen',
    'Spore',
    -- Slow
    'Gloeosuccus',
    'Intimidate',
    'Spider Web',
    'Filamented Hold',
    -- Poison
    'Toxic Spit',
    'Venom Spray',
    'Infected Leech',
    'Pollen',
    -- Silence
    'Choke Breath',
    'Chaotic Eye',
    -- Blind
    'Sandblast',
    -- Bind
    'Sandpit',
    -- Stun
    'Predatory Glare',
    'Numbing Noise',
    -- Terror / Amnesia
    'Jettatura',
    -- Other
    'Blaster'
}

---============================================================================
--- CATEGORIZATION FUNCTIONS
---============================================================================

--- Get ready move category
--- @param move_name string Ready move name
--- @return string category "Physical", "PhysicalMulti", "MagicAtk", "MagicAcc", or "Default"
function ReadyMoveCategorizer.get_category(move_name)
    if not move_name then
        return 'Default'
    end

    if ReadyMoveCategorizer.petPhysicalMoves:contains(move_name) then
        return 'Physical'
    elseif ReadyMoveCategorizer.petPhysicalMultiMoves:contains(move_name) then
        return 'PhysicalMulti'
    elseif ReadyMoveCategorizer.petMagicAtkMoves:contains(move_name) then
        return 'MagicAtk'
    elseif ReadyMoveCategorizer.petMagicAccMoves:contains(move_name) then
        return 'MagicAcc'
    else
        return 'Default'
    end
end

--- Check if ready move is physical (single or multi)
--- @param move_name string Ready move name
--- @return boolean is_physical True if move is physical type
function ReadyMoveCategorizer.is_physical(move_name)
    if not move_name then
        return false
    end

    return ReadyMoveCategorizer.petPhysicalMoves:contains(move_name) or
        ReadyMoveCategorizer.petPhysicalMultiMoves:contains(move_name)
end

--- Check if ready move is magical (attack or accuracy)
--- @param move_name string Ready move name
--- @return boolean is_magical True if move is magical type
function ReadyMoveCategorizer.is_magical(move_name)
    if not move_name then
        return false
    end

    return ReadyMoveCategorizer.petMagicAtkMoves:contains(move_name) or
        ReadyMoveCategorizer.petMagicAccMoves:contains(move_name)
end

--- Get midcast set name for ready move
--- @param move_name string Ready move name
--- @return string set_name Set name for sets.midcast.Pet[set_name]
function ReadyMoveCategorizer.get_midcast_set_name(move_name)
    local category = ReadyMoveCategorizer.get_category(move_name)
    return category -- "Physical", "PhysicalMulti", "MagicAtk", "MagicAcc", or "Default"
end

---============================================================================
--- STATISTICS (Optional - for debugging)
---============================================================================

--- Get count of moves in each category
--- @return table counts {Physical, PhysicalMulti, MagicAtk, MagicAcc}
function ReadyMoveCategorizer.get_category_counts()
    local counts = {
        Physical = 0,
        PhysicalMulti = 0,
        MagicAtk = 0,
        MagicAcc = 0
    }

    -- Count moves in each set
    for _ in pairs(ReadyMoveCategorizer.petPhysicalMoves) do
        counts.Physical = counts.Physical + 1
    end

    for _ in pairs(ReadyMoveCategorizer.petPhysicalMultiMoves) do
        counts.PhysicalMulti = counts.PhysicalMulti + 1
    end

    for _ in pairs(ReadyMoveCategorizer.petMagicAtkMoves) do
        counts.MagicAtk = counts.MagicAtk + 1
    end

    for _ in pairs(ReadyMoveCategorizer.petMagicAccMoves) do
        counts.MagicAcc = counts.MagicAcc + 1
    end

    return counts
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export sets globally for compatibility with old code
_G.petPhysicalMoves = ReadyMoveCategorizer.petPhysicalMoves
_G.petPhysicalMultiMoves = ReadyMoveCategorizer.petPhysicalMultiMoves
_G.petMagicAtkMoves = ReadyMoveCategorizer.petMagicAtkMoves
_G.petMagicAccMoves = ReadyMoveCategorizer.petMagicAccMoves

return ReadyMoveCategorizer
