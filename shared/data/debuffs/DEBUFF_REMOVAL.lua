---============================================================================
--- Debuff Removal - every debuff, its buff ids, and what takes it off
---============================================================================
--- Read by //gs c cleanse (shared/utils/debuff/cleanse.lua). The order of
--- the list is the default order of removal (most urgent first); the
--- player's _common/combat/CLEANSE_CONFIG.lua can change the order, the
--- items, or leave a debuff out.
---
--- Per debuff:
---   ids        buff ids (Windower res/buffs.lua). Ids 539-567 are the
---              effects of a geomancy aura (they follow the GEO spell order;
---              Silmaril names them "Geomancy ..."): an item or a spell may
---              not take them off while you stand in the aura
---              (uncurable_debuffs.lua notices it).
---   spell      the spell that takes it off (WHM, or SCH under Addendum:
---              White), cast by this character on itself or by a partner
---   items      default items, tried in order
---   no_action  the character cannot act at all (asleep, petrified,
---              stunned, terrified): only a partner can help
---
--- Sources (checked 2026-10-01):
---   BG-Wiki item pages: Remedy (Blind, Paralyze, Poison, Silence), Echo
---     Drops (silence), Eye Drops (blindness), Antidote (poison), Holy Water
---     (curse; Doom 33 % per use), Panacea (erasable ailments; not Curse,
---     Doom, Poison, Disease, Blindness, Silence or Paralysis).
---   BG-Wiki Erase: Bio, Dia, Gravity, Flash, Addle, Slow, Elegy, Requiem,
---     Helix, elemental debuffs, attribute / status Down; not Terror,
---     Amnesia, Muddle; nothing another spell covers (Poison...).
---   HealBot (lorand-ffxi, HealBot_statics.lua debuff_map) for the spell of
---     each debuff, and Cure to wake a sleeping member.
---
--- @file shared/data/debuffs/DEBUFF_REMOVAL.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-01
---============================================================================

local ERASABLE_ITEMS = {'Panacea'}

return {
    -- Cannot act at all: a partner only
    {key = 'doom',          name = 'Doom',          ids = {15},       spell = 'Cursna',  items = {'Holy Water'}},
    {key = 'petrification', name = 'Petrification', ids = {7},        spell = 'Stona',   no_action = true},
    {key = 'sleep',         name = 'Sleep',         ids = {2, 19},    spell = 'Cure',    no_action = true},
    {key = 'lullaby',       name = 'Lullaby',       ids = {193},      spell = 'Cure',    no_action = true},
    {key = 'stun',          name = 'Stun',          ids = {10},       no_action = true},
    {key = 'terror',        name = 'Terror',        ids = {28},       no_action = true},
    {key = 'charm',         name = 'Charm',         ids = {14, 17},   no_action = true},

    -- Block actions
    {key = 'silence',       name = 'Silence',       ids = {6},        spell = 'Silena',  items = {'Echo Drops', 'Remedy'}},
    {key = 'paralysis',     name = 'Paralysis',     ids = {4, 566},   spell = 'Paralyna', items = {'Remedy'}},
    {key = 'curse',         name = 'Curse',         ids = {9, 20},    spell = 'Cursna',  items = {'Holy Water'}},
    {key = 'amnesia',       name = 'Amnesia',       ids = {16}},
    {key = 'mute',          name = 'Mute',          ids = {29}},
    {key = 'omerta',        name = 'Omerta',        ids = {262}},
    {key = 'impairment',    name = 'Impairment',    ids = {261}},
    {key = 'muddle',        name = 'Muddle',        ids = {473}},
    {key = 'bane',          name = 'Bane',          ids = {30}},

    -- Ailments with their own spell
    {key = 'plague',        name = 'Plague',        ids = {31},       spell = 'Viruna'},
    {key = 'disease',       name = 'Disease',       ids = {8},        spell = 'Viruna'},
    {key = 'blindness',     name = 'Blindness',     ids = {5},        spell = 'Blindna', items = {'Eye Drops', 'Remedy'}},
    {key = 'poison',        name = 'Poison',        ids = {3, 540},   spell = 'Poisona', items = {'Antidote', 'Remedy'}},

    -- Erasable (Erase, Panacea)
    {key = 'slow',          name = 'Slow',          ids = {13, 565},  spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'weight',        name = 'Weight',        ids = {12, 567},  spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'bind',          name = 'Bind',          ids = {11},       spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'addle',         name = 'Addle',         ids = {21},       spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'flash',         name = 'Flash',         ids = {156},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'inhibit_tp',    name = 'Inhibit TP',    ids = {168},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'max_hp_down',   name = 'Max HP Down',   ids = {144},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'max_mp_down',   name = 'Max MP Down',   ids = {145},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'max_tp_down',   name = 'Max TP Down',   ids = {189},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'attack_down',   name = 'Attack Down',   ids = {147, 557}, spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'defense_down',  name = 'Defense Down',  ids = {149, 558}, spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'accuracy_down', name = 'Accuracy Down', ids = {146, 561}, spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'evasion_down',  name = 'Evasion Down',  ids = {148, 562}, spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'magic_atk_down', name = 'Magic Atk. Down', ids = {175, 559}, spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'magic_def_down', name = 'Magic Def. Down', ids = {167, 560}, spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'magic_acc_down', name = 'Magic Acc. Down', ids = {174, 563}, spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'magic_eva_down', name = 'Magic Evasion Down', ids = {404, 564}, spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'str_down',      name = 'STR Down',      ids = {136},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'dex_down',      name = 'DEX Down',      ids = {137},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'vit_down',      name = 'VIT Down',      ids = {138},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'agi_down',      name = 'AGI Down',      ids = {139},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'int_down',      name = 'INT Down',      ids = {140},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'mnd_down',      name = 'MND Down',      ids = {141},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'chr_down',      name = 'CHR Down',      ids = {142},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'elegy',         name = 'Elegy',         ids = {194},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'requiem',       name = 'Requiem',       ids = {192},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'nocturne',      name = 'Nocturne',      ids = {223},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'helix',         name = 'Helix',         ids = {186},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'burn',          name = 'Burn',          ids = {128},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'frost',         name = 'Frost',         ids = {129},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'choke',         name = 'Choke',         ids = {130},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'rasp',          name = 'Rasp',          ids = {131},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'shock',         name = 'Shock',         ids = {132},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'drown',         name = 'Drown',         ids = {133},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'bio',           name = 'Bio',           ids = {135},      spell = 'Erase', items = ERASABLE_ITEMS},
    {key = 'dia',           name = 'Dia',           ids = {134},      spell = 'Erase', items = ERASABLE_ITEMS},
}
