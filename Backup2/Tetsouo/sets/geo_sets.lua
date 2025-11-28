---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Equipment Sets - Ultimate Geomancer Bubble Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Complete equipment configuration for Geomancer support role with optimized
---   Luopan (pet bubble) survivability and geomancy effectiveness.
---   Features:
---     • Luopan survivability (Pet: DT-, Pet: Regen maximization with Telchine +3)
---     • Dual configuration system (sets.me.* vs sets.luopan.* for pet/no-pet)
---     • Geomancy skill maximization (Azimuth +3, Bagua +3, Idris relic club)
---     • Fast Cast optimization (Merlinic full set with FC+7 augments)
---     • Bolster enhancement (Bagua Tunic relic)
---     • Cure potency support (Daybreak main, Azimuth set)
---     • Elemental Magic Burst (Nantosuelta cape, Metamorph Ring +1)
---     • Movement speed optimization (Geomancy Sandals +3)
---    Architecture:
---     • Equipment definitions (Chirich rings, wardrobe management)
---     • Weapon sets (Idris club, Dunna bell, Genmei Shield)
---     • Idle sets (sets.me.idle, sets.luopan.idle with Pet gear)
---     • Engaged sets (sets.me.engaged, sets.luopan.engaged DT/DPS modes)
---     • Precast sets (Fast Cast, Job Abilities)
---     • Midcast sets (Geomancy, Cure, Enhancing, Enfeebling, Elemental)
---     • Weaponskill sets (Nyame full set for magic WS)
---     • Movement sets (Base speed, Adoulin)
---     • Buff sets (Doom resistance)
---   @file    jobs/geo/sets/geo_sets.lua
---   @author  Kaories
---   @version 3.0 - Standardized Organization
---   @date    Updated: 2025-11-10
---  ═════════════════════════════════════════════════════════════════════════
sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- EQUIPMENT DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Chirich Rings in different wardrobes (prevents "already equipped" errors)
ChirichRing1 = {
    name = 'Chirich Ring +1',
    bag = 'wardrobe 1'
}
ChirichRing2 = {
    name = 'Chirich Ring +1',
    bag = 'wardrobe 2'
}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Main Weapon Set (Idris only for now)
sets['Idris'] = {
    main = 'Idris', -- Best-in-slot Club (main weapon)
    range = 'Dunna' -- Bell (range instrument)
}

-- • Sub Weapon Sets (Shield - Genmei Shield only for now)
sets['Genmei Shield'] = {
    sub = 'Genmei Shield' -- Physical damage taken -5%
}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • ME Sets (No Luopan active)
sets.me = {}

sets.me.idle = {
    -- • No pet active - Focus on refresh, defense, regen
    range = 'Dunna',
    head = 'Azimuth Hood +3',
    body = 'Azimuth Coat +3',
    hands = 'Azimuth Gloves +3',
    legs = 'Nyame Flanchard',
    feet = 'Azimuth Gaiters +3',
    neck = 'Elite Royal Collar',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Regal Earring',
    right_ear = 'Azimuth Earring +1',
    left_ring = 'Woltaris Ring',
    right_ring = "Gurebu's Ring",
    back = "Aurist's Cape +1"
}

-- • LUOPAN Sets (Luopan active - Pet survival priority)
sets.luopan = {}

sets.luopan.idle = {
    -- • Pet active - Focus on Pet: Damage Taken -, Pet: Regen
    main = 'Idris',
    range = 'Dunna',
    head = 'Azimuth Hood +3',
    body = 'Adamantite Armor',
    hands = {
        name = 'Telchine Gloves',
        augments = {'Pet: Mag. Evasion+11', 'Pet: "Regen"+3', 'Pet: Damage taken -4%'}
    },
    legs = {
        name = 'Telchine Braconi',
        augments = {'Pet: Evasion+20', 'Pet: "Regen"+3', 'Pet: Damage taken -4%'}
    },
    feet = 'Bagua Sandals +3',
    neck = 'Bagua Charm +2',
    waist = 'Isa Belt',
    left_ear = 'Regal Earring',
    right_ear = 'Azimuth Earring +1',
    left_ring = 'Defending Ring',
    right_ring = "Gurebu's Ring",
    back = {
        name = "Nantosuelta's Cape",
        augments = {'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', 'Pet: "Regen"+10', 'Pet: "Regen"+5'}
    }
}

-- • Legacy idle sets for compatibility (point to new structure)
sets.idle = {}
sets.idle.Normal = sets.me.idle
sets.idle.PDT = sets.me.idle -- GEO uses same for now
sets.idle.Pet = sets.luopan.idle

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • ME Engaged (No Luopan active)
sets.me.engaged = {
    head = 'Azimuth Hood +3',
    body = 'Nyame Mail',
    hands = 'Geo. Mitaines +4',
    legs = 'Jhakri Slops +2',
    feet = 'Azimuth Gaiters +3',
    neck = 'Null Loop',
    waist = 'Null Belt',
    left_ear = 'Dedition Earring',
    right_ear = 'Crep. Earring',
    left_ring = 'Crepuscular Ring',
    right_ring = 'Chirich Ring +1',
    back = 'Null Shawl'
}

-- • LUOPAN Engaged (Luopan active - varies by LuopanMode state)
sets.luopan.engaged = {}

-- • DT Mode - Full Luopan protection (Pet: DT -, Pet: Regen priority)
sets.luopan.engaged.DT = {
    head = 'Azimuth Hood +3',
    body = 'Adamantite Armor',
    hands = {
        name = 'Telchine Gloves',
        augments = {'Pet: Mag. Evasion+11', 'Pet: "Regen"+3', 'Pet: Damage taken -4%'}
    },
    legs = {
        name = 'Telchine Braconi',
        augments = {'Pet: Evasion+20', 'Pet: "Regen"+3', 'Pet: Damage taken -4%'}
    },
    feet = 'Bagua Sandals +3',
    neck = 'Bagua Charm +2',
    waist = 'Isa Belt',
    left_ear = 'Regal Earring',
    right_ear = 'Azimuth Earring +1',
    left_ring = 'Defending Ring',
    right_ring = "Gurebu's Ring",
    back = {
        name = "Nantosuelta's Cape",
        augments = {'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', 'Pet: "Regen"+10', 'Pet: "Regen"+5'}
    }
}

-- • DPS Mode - DPS focus perso (less pet gear, more melee stats)
sets.luopan.engaged.DPS = {
    head = 'Azimuth Hood +3',
    body = 'Nyame Mail',
    hands = 'Geo. Mitaines +4',
    legs = 'Jhakri Slops +2',
    feet = 'Azimuth Gaiters +3',
    neck = 'Null Loop',
    waist = 'Null Belt',
    left_ear = 'Dedition Earring',
    right_ear = 'Crep. Earring',
    left_ring = 'Crepuscular Ring',
    right_ring = 'Chirich Ring +1',
    back = 'Null Shawl'
}

-- • Legacy engaged sets for compatibility (point to new structure)
sets.engaged = {}
sets.engaged.Normal = sets.me.engaged
sets.engaged.PDT = sets.me.engaged -- GEO uses same for now

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}

-- • Fast Cast (Mote uses this)
sets.precast.FC = {
    sub = 'Ammurapi Shield',
    range = {
        name = 'Dunna',
        augments = {'MP+20', 'Mag. Acc.+10', '"Fast Cast"+3'}
    },
    head = {
        name = 'Merlinic Hood',
        augments = {'Mag. Acc.+1', '"Fast Cast"+7', 'CHR+2', '"Mag.Atk.Bns."+1'}
    },
    body = {
        name = 'Merlinic Jubbah',
        augments = {'Accuracy+11', '"Fast Cast"+7', 'INT+7'}
    },
    hands = {
        name = 'Merlinic Dastanas',
        augments = {'Mag. Acc.+10', '"Fast Cast"+7'}
    },
    legs = {
        name = 'Merlinic Shalwar',
        augments = {'Mag. Acc.+15', '"Fast Cast"+7'}
    },
    feet = {
        name = 'Merlinic Crackows',
        augments = {'"Fast Cast"+7', 'INT+2', 'Mag. Acc.+1', '"Mag.Atk.Bns."+10'}
    },
    neck = 'Voltsurge Torque',
    waist = 'Embla Sash',
    left_ear = 'Loquac. Earring',
    right_ear = 'Malignance Earring',
    left_ring = 'Prolix Ring',
    right_ring = 'Kishar Ring',
    back = {
        name = 'Lifestream Cape',
        augments = {'Geomancy Skill +10', 'Indi. eff. dur. +20', 'Pet: Damage taken -3%'}
    }
}

-- • Cure Fast Cast
sets.precast.FC.Cure = set_combine(sets.precast.FC, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.JA = {}

-- • Bolster (+100% Geomancy effectiveness)
sets.precast.JA['Bolster'] = {
    body = 'bagua tunic'
}

-- • Life Cycle (Convert pet HP to user HP)
sets.precast.JA['Life Cycle'] = {
    body = 'geomancy tunic +2',
    back = "Nantosuelta's Cape"
}

-- • Blaze of Glory (+50% effectiveness, consumes HP)
sets.precast.JA['Blaze of Glory'] = {
    feet = 'Bagua Sandals +3'
}

-- • Dematerialization (Teleport to Luopan)
sets.precast.JA['Dematerialization'] = {
    legs = 'Bagua Pants +3'
}

-- • Entrust (Indi spell on party member)
sets.precast.JA['Entrust'] = {
    legs = 'Bagua Pants +3'
}

-- • Ecliptic Attrition (Damage Luopan for player)
sets.precast.JA['Ecliptic Attrition'] = {
    head = 'Bagua Galero +3'
}

-- • Radial Arcana (Restore MP + Luopan HP)
sets.precast.JA['Radial Arcana'] = {
    feet = 'Bagua Sandals +3'
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}

-- • Geomancy (Indi + Geo spells)
sets.midcast.Geomancy = sets.luopan.idle

-- • Indi spells (self bubble)
sets.midcast.Indi = sets.luopan.idle

-- • Indi via Entrust (on party member - max duration/potency)
-- When using Entrust + Indi on someone else, prioritize effect duration
sets.midcast.Indi.Entrust = set_combine(sets.midcast.Indi, {
    main = "Gada",
    sub = "Genmei Shield",
    range = "Dunna",
    head = "Azimuth Hood +3",
    body = "Azimuth Coat +3",
    hands = "Geo. Mitaines +4",
    legs = "Bagua Pants +3",
    feet = "Azimuth Gaiters +3",
    neck = "Bagua Charm +2",
    waist = "Plat. Mog. Belt",
    left_ear = "Regal Earring",
    right_ear = "Azimuth Earring +1",
    left_ring = "Woltaris Ring",
    right_ring = "Gurebu's Ring",
    back = "Lifestream Cape",
})

-- • Geo spells (Luopan bubble)
sets.midcast.Geo = set_combine(sets.midcast.Geomancy, {})

-- • Cure spells
sets.midcast.Cure = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    range = {
        name = 'Dunna',
        augments = {'MP+20', 'Mag. Acc.+10', '"Fast Cast"+3'}
    },
    head = 'Azimuth Hood +3',
    body = 'Azimuth Coat +3',
    hands = "Revealer's Mitts",
    legs = 'Azimuth Tights +3',
    feet = 'Azimuth Gaiters +3',
    neck = 'Elite Royal Collar',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Regal Earring',
    right_ear = 'Azimuth Earring +1',
    left_ring = "Naji's Loop",
    right_ring = "Gurebu's Ring",
    back = {
        name = "Aurist's Cape +1",
        augments = {'Path: A'}
    }
}

-- • Enhancing Magic
sets.midcast['Enhancing Magic'] = {}

-- • Enfeebling Magic
sets.midcast['Enfeebling Magic'] = {}

-- • Elemental Magic
sets.midcast['Elemental Magic'] = {
    main = 'Idris',
    sub = 'Ammurapi Shield',
    range = 'Dunna',
    head = 'Azimuth Hood +3',
    body = 'Azimuth Coat +3',
    hands = 'Geomancy Mitaines +4',
    legs = 'Azimuth Tights +3',
    feet = 'Azimuth Gaiters +3',
    neck = 'Bagua Charm +2',
    waist = 'Isa Belt',
    left_ear = 'Regal Earring',
    right_ear = 'Azimuth Earring +1',
    left_ring = {
        name = 'Metamor. Ring +1',
        augments = {'Path: A'}
    },
    right_ring = 'Freke Ring',
    back = {
        name = "Nantosuelta's Cape",
        augments = {'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Pet: Damage taken -5%'}
    }
}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPONSKILL SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Default WS (Magic damage)
sets.precast.WS = {
    head = 'Nyame Helm',
    body = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Rep. Plat. Medal',
    waist = "Cornelia's Belt",
    left_ear = 'Regal Earring',
    right_ear = 'Ishvara Earring',
    left_ring = "Epaminondas's Ring",
    right_ring = 'Metamor. Ring +1',
    back = {
        name = "Nantosuelta's Cape",
        augments = {'STR+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%'}
    }
}

-- • Exudation (Club magic WS)
sets.precast.WS['Exudation'] = set_combine(sets.precast.WS, {
    ammo = 'Crepuscular Pebble',
    head = 'Nyame Helm',
    body = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    ear1 = 'Malignance Earring',
    ear2 = 'Regal Earring',
    ring1 = 'Metamor. Ring +1',
    ring2 = "Epaminondas's Ring",
    back = "Nantosuelta's Cape"
})

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Movement Speed
sets.MoveSpeed = {
    feet = 'Geo. Sandals +4' -- Movement +18%
}

-- • Town Idle (Movement speed)
sets.me.idle.Town = set_combine(sets.me.idle, {
    feet = 'Geo. Sandals +4'
})

sets.idle.Town = sets.me.idle.Town

-- • Adoulin Movement (City-specific speed boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {
    body = "Councilor's Garb"
})

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.buff = {}

-- • Doom removal
sets.buff.Doom = {}

print('[GEO] Equipment sets loaded')
