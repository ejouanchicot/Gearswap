---============================================================================
--- THF (Thief) - your own modes and gear rules - Gabvanstronger
---============================================================================
--- Everything here is optional. Save, then //gs reload: mistakes are
--- reported in the chat, with what to fix.
---
--- Your pieces go on LAST, on top of what the job picked. Only the slots
--- you list change; everything else stays as the job chose.
---
--- There are two kinds of block.
---
--- 1) A MODE: a key that cycles values, shown in the HUD.
---
---    {
---        state   = 'TPMode',               one word: letters, digits, _
---        desc    = 'TP Mode',              label in the HUD
---        key     = '^numpad0',            ^ Ctrl  ! Alt  @ Win  # Apps  ~ Shift
---        values  = {'Normal', 'Acc'},      the first value is the default
---               -- or 'onoff'              a simple on/off switch
---        section = 'mode',                 HUD section: mode, spell, ability, weapon
---        subjob  = 'SAM',                  optional: key only with this subjob
---                                          (exclude_subjob = never with it)
---        Acc = {                           gear for the value "Acc"
---            engaged = { head = "..." },
---            when    = { ... },            optional: only if (see below)
---        },
---    },
---
---    A mode the job already has works too: name it (state = 'HybridMode')
---    without values or key, and give gear to one of its values.
---
--- 2) A RULE: gear that goes on by itself when conditions hold.
---
---    { when = { buff = 'Aftermath: Lv.3' }, engaged = { ring1 = "..." } },
---
--- WHEN - the gear is used at these moments:
---    idle         standing, not fighting
---    engaged      fighting
---    weaponskill  weaponskills
---    ability      job abilities (Provoke, Berserk...)
---    precast      spells, while casting starts (fast cast)
---    midcast      spells, when they land (potency)
---    all          every moment above
---    A moment holds pieces { head = "...", ring1 = "..." } or the name of
---    one of your sets: 'sets.engaged.Acc'. Slots: main sub range ammo head
---    neck ear1 ear2 body hands ring1 ring2 back waist legs feet.
---
--- IF - conditions (when = {...}). All must hold. A list = any of them:
---    buff = 'Haste' / {'Haste', 'Haste II'}   buff active
---    no_buff = 'Doom'                     buff NOT active
---    weapon = 'Naegling'                  main weapon (also the job's weapon choice)
---    sub / range / ammo = '...'           item in that slot
---    subjob = 'NIN' / no_subjob = 'NIN'
---    mode = { HybridMode = 'PDT' }        a mode's current value
---    hp_below = 50 / hp_above = 50        HP percent
---    mp_below = 50 / mp_above = 50        MP percent
---    tp_below = 1000 / tp_above = 2000    TP
---    spell = 'Cure IV' / 'Cure*'          action name, * = "starts with"
---    skill = 'Enfeebling Magic'           magic skill
---    spell_type = 'WhiteMagic'            WhiteMagic BlackMagic BardSong Ninjutsu
---                                         WeaponSkill JobAbility ...
---    element = 'Fire'                     spell element
---    day_weather = true                   spell element = day or weather (Obi)
---    target = 'self' / 'other' / 'enemy'  who the action is on
---    distance_below = 5                   yalms to the target (Orpheus)
---    town = true / moving = true / pet = true
---    engaged = true / false               fighting or not (Phantom Roll out of combat...)
---    zone = 'Walk of Echoes [P1]'
---    Spell conditions only hold during an action, never idle/engaged.
---
--- ORDER: blocks further down win when two touch the same slot.
---
--- LEFT ALONE automatically, so a rule can't break them:
---    nothing is changed while Doomed, resting, for pet moves, ranged
---    attacks and items; Impact keeps its body/head, songs their
---    instrument, Phantom Roll its rings, Dispelga its weapon, call beast
---    its jug, the Hoxne stance its ammo, Treasure Hunter its pieces; a
---    slot the job has locked stays locked.
---    Anything else, your piece wins: a rule that replaces your Moonshade,
---    Obi or TH piece removes that effect.
---
--- Buff conditions are re-checked when the buff comes or goes. HP/MP/TP
--- conditions are checked at every gear change (action, engage, reload).

return {

    -- His ranged weapon choice (RangedSet, key @` in his BindManager).
    -- Pull: his check_rangedset equipped sets.Pull (Antitail +1) and locked
    -- range + ammo. Ammo: the slots free again, nothing equipped (his
    -- check_rangedset equipped {range = 'Ammo'}, which is no item).
    {
        state   = 'RangedSet',
        desc    = 'Ranged Weapon',
        key     = '@`',
        values  = {'Ammo', 'Pull'},
        section = 'weapon',
        Pull    = {
            all  = 'sets.Pull',
            lock = {'range', 'ammo'},
        },
    },

    -- Capacity Point cape (sets.CP = CAPACITY.Cape). His THF had the CP state
    -- but never called check_cpmode, so it did nothing there; this is his
    -- RDM version. No key in his binds: //gs c cyclestate CP.
    {
        state  = 'CP',
        desc   = 'CP Cape',
        values = 'onoff',
        On     = {
            all  = 'sets.CP',
            lock = {'back'},
        },
    },

    -- His customize_idle_set: extra regen below 80% HP
    { when = { hp_below = 80 }, idle = 'sets.ExtraRegen' },

    -- His job_post_precast: TH gear on Aeolian Edge in every TH mode but None
    {
        when        = { spell = 'Aeolian Edge', mode = { TreasureMode = {'Tag', 'SATA', 'Full'} } },
        weaponskill = 'sets.TreasureHunter',
    },

    -- His job_post_precast: TH gear on every weaponskill and on Sneak Attack /
    -- Trick Attack in SATA and Full (his Fulltime)
    {
        when        = { mode = { TreasureMode = {'SATA', 'Full'} } },
        weaponskill = 'sets.TreasureHunter',
    },
    {
        when    = { spell = {'Sneak Attack', 'Trick Attack'}, mode = { TreasureMode = {'SATA', 'Full'} } },
        ability = 'sets.TreasureHunter',
    },

}
