# SMN GearSwap Lua — Spec complète pour Claude Code

Personnage : Tetsouo
Job : SMN (Summoner)
Subjobs : /WHM, /SCH, /RDM, /BLM
Arme principale : Grioavolr (staff)
Tous les avatars sont utilisés.
Avatar par défaut au load : Carbuncle.
Pas d'automation Apogee/Astral Conduit (pas d'auto-trigger, ce sont des SP ou très spécifiques).
Pas de smartbuff chain.
Sets en squelette vide (empty strings) — l'utilisateur remplira lui-même.

---

## 1. Sets équipement

Tous les sets doivent être déclarés avec les 16 slots vides :
```lua
main="", sub="", range="", ammo="",
head="", neck="", ear1="", ear2="",
body="", hands="", ring1="", ring2="",
back="", waist="", legs="", feet=""
```

### Master sets

| Set | Usage |
|---|---|
| `sets.idle.Normal` | Idle standard : refresh, DT, perpetuation cost reduction |
| `sets.idle.DT` | Idle full DT |
| `sets.idle.Avatar` | Avatar's Favor actif : BP timer-, pet stats+, perpetuation- |
| `sets.engaged` | Melee (si jamais, sinon copie idle) |

### Precast

| Set | Usage |
|---|---|
| `sets.precast.FC` | Fast Cast général |
| `sets.precast.FC.SummoningMagic` | FC pour invocations (Glyphic Horn etc.) |
| `sets.precast.FC.HealingMagic` | FC Cure (/WHM) |
| `sets.precast.FC.EnhancingMagic` | FC Enhancing (/WHM /RDM /SCH) |

### Midcast master magic

| Set | Usage |
|---|---|
| `sets.midcast.SummoningMagic` | Summoning Skill+ (réduit pact delay) |
| `sets.midcast.ElementalSiphon` | Summoning Skill+ / Elemental Siphon+ |
| `sets.midcast.Cure` | Cure potency (/WHM /RDM /SCH) |
| `sets.midcast.Enhancing` | Enhancing skill / duration |
| `sets.midcast.Stoneskin` | Stoneskin potency |
| `sets.midcast.Phalanx` | Phalanx potency |
| `sets.midcast.Refresh` | Refresh potency (/RDM /SCH) |
| `sets.midcast.Haste` | Fast Cast / recast (Haste est instacast mais set utile) |

### Pet midcast — Blood Pact sets (le cœur du job)

| Set | Usage |
|---|---|
| `sets.pet_midcast.BPRage.Physical` | Physical BP : pet ATK, pet Acc, BP damage |
| `sets.pet_midcast.BPRage.Magical` | Magical BP : pet MAB, pet macc, BP damage |
| `sets.pet_midcast.BPRage.Hybrid` | Hybrid BP (Flaming Crush, Burning Strike) : mix phys+mag |
| `sets.pet_midcast.BPRage.AstralFlow` | Astral Flow 2h pacts |
| `sets.pet_midcast.BPWard.Buff` | Ward buffs (Hastega, Crimson Howl, etc.) : BP duration, skill |
| `sets.pet_midcast.BPWard.Debuff` | Ward debuffs (Diamond Storm, Sleepga, etc.) : pet macc, skill |
| `sets.pet_midcast.BPWard.Heal` | Ward heals (Healing Ruby, Spring Water, etc.) : healing skill |

### JA sets

| Set | Usage |
|---|---|
| `sets.JA['Astral Flow']` | SP ability |
| `sets.JA['Astral Conduit']` | SP ability (lv96) — reduces BP recast to 0 for 30s |
| `sets.JA['Apogee']` | JA lv70 — next BP recast to 0, +50% MP cost |
| `sets.JA['Elemental Siphon']` | MP recovery from avatar |
| `sets.JA['Mana Cede']` | Transfer MP to avatar TP |
| `sets.JA["Avatar's Favor"]` | Toggle buff |
| `sets.JA['Release']` | Release avatar |

### Pet engaged

| Set | Usage |
|---|---|
| `sets.pet.Engaged` | Avatar en auto-attack : pet DT, pet acc, pet TP |

---

## 2. States (Mote)

```lua
state.IdleMode = M{'Normal', 'DT', 'Avatar'}
state.CastingMode = M{'Normal', 'Resistant'}
state.AvatarFavor = M(false, 'Avatar Favor') -- toggle pour set idle Avatar
```

Quand `state.AvatarFavor` est ON, `sets.idle.Avatar` remplace l'idle actif.

---

## 3. Keybinds

Standard comme les autres Lua du projet (F9/F10/F11/F12 pattern).

---

## 4. Macrobook par subjob

| Subjob | Macro book | Page |
|---|---|---|
| /WHM | À définir | 1 |
| /SCH | À définir | 1 |
| /RDM | À définir | 1 |
| /BLM | À définir | 1 |

---

## 5. Lockstyle

Un set lockstyle par subjob (IDs à définir par l'utilisateur).

---

## 6. Commandes custom

Aucune automation spéciale demandée.
Juste les cycles de state standard (IdleMode, CastingMode, AvatarFavor toggle).

---

## 7. Classification complète des Blood Pacts

Référence pour le routing pet_midcast dans le Lua.
Toutes les commandes utilisent `/pet "<Name>" <t>` (Rage) ou `/pet "<Name>" <me>` (Ward buff/heal).

### Blood Pact: Rage — Physical

Ces pacts utilisent le set `BPRage.Physical`.

| Name | Avatar | Lvl | Dmg Type | Skillchain |
|---|---|---|---|---|
| Punch | Ifrit | 1 | H2H | Liquefaction |
| Rock Throw | Titan | 1 | Slashing | Scission |
| Barracuda Dive | Leviathan | 1 | Slashing | Reverberation |
| Claw | Garuda | 1 | Piercing | Detonation |
| Welt | Siren | 1 | Slashing | Scission |
| Axe Kick | Shiva | 1 | H2H | Induration |
| Shock Strike | Ramuh | 1 | Blunt | Impaction |
| Camisado | Diabolos | 1 | Blunt | Compression |
| Regal Scratch | Cait Sith | 1 | Slashing | Scission |
| Poison Nails | Carbuncle | 5 | Piercing | Transfixion |
| Moonlit Charge | Fenrir | 5 | Blunt | Compression |
| Crescent Fang | Fenrir | 10 | Piercing | Transfixion |
| Rock Buster | Titan | 21 | Blunt | Reverberation |
| Roundhouse | Siren | 25 | H2H | Detonation |
| Tail Whip | Leviathan | 26 | Blunt | Detonation |
| Double Punch | Ifrit | 30 | Blunt | Compression |
| Megalith Throw | Titan | 35 | Slashing | Induration |
| Double Slap | Shiva | 50 | H2H | Scission |
| Eclipse Bite | Fenrir | 65 | Slashing | Gravitation / Scission |
| Mountain Buster | Titan | 70 | Blunt | Gravitation / Induration |
| Spinning Dive | Leviathan | 70 | Slashing | Distortion / Detonation |
| Predator Claws | Garuda | 70 | Slashing | Fragmentation / Scission |
| Rush | Shiva | 70 | H2H | Distortion / Scission |
| Chaotic Strike | Ramuh | 70 | Blunt | Fragmentation / Transfixion |
| Volt Strike | Ramuh | 99 | Blunt | Fragmentation / Scission |
| Hysteric Assault | Siren | 99 | Piercing | Fragmentation / Transfixion |
| Crag Throw | Titan | 99 | Slashing | Gravitation / Scission |
| Blindside | Diabolos | 99 | Slashing | Gravitation / Transfixion |
| Regal Gash | Cait Sith | 99 | Slashing | Distortion / Detonation |

Lua lookup set:
```lua
physical_blood_pacts = S{
    'Punch','Rock Throw','Barracuda Dive','Claw','Welt','Axe Kick',
    'Shock Strike','Camisado','Regal Scratch','Poison Nails','Moonlit Charge',
    'Crescent Fang','Rock Buster','Roundhouse','Tail Whip','Double Punch',
    'Megalith Throw','Double Slap','Eclipse Bite','Mountain Buster',
    'Spinning Dive','Predator Claws','Rush','Chaotic Strike',
    'Volt Strike','Hysteric Assault','Crag Throw','Blindside','Regal Gash'
}
```

### Blood Pact: Rage — Hybrid

Ces pacts utilisent le set `BPRage.Hybrid`.

| Name | Avatar | Lvl | Dmg Type | Skillchain |
|---|---|---|---|---|
| Burning Strike | Ifrit | 23 | Hybrid (H2H + Fire) | Impaction / Fire |
| Flaming Crush | Ifrit | 70 | Hybrid (Blunt + Fire) | Fusion / Reverberation / Fire |

Lua lookup set:
```lua
hybrid_blood_pacts = S{
    'Burning Strike','Flaming Crush'
}
```

### Blood Pact: Rage — Magical

Ces pacts utilisent le set `BPRage.Magical`.

| Name | Avatar | Lvl | Element |
|---|---|---|---|
| Fire II | Ifrit | 10 | Fire |
| Stone II | Titan | 10 | Earth |
| Water II | Leviathan | 10 | Water |
| Aero II | Garuda | 10 | Wind |
| Blizzard II | Shiva | 10 | Ice |
| Thunder II | Ramuh | 10 | Thunder |
| Thunderspark | Ramuh | 19 | Thunder |
| Meteorite | Carbuncle | 55 | Light |
| Fire IV | Ifrit | 60 | Fire |
| Stone IV | Titan | 60 | Earth |
| Water IV | Leviathan | 60 | Water |
| Aero IV | Garuda | 60 | Wind |
| Blizzard IV | Shiva | 60 | Ice |
| Thunder IV | Ramuh | 60 | Thunder |
| Sonic Buffet | Siren | 65 | Wind |
| Nether Blast | Diabolos | 65 | Dark (Breath) |
| Meteor Strike | Ifrit | 75 (Merit) | Fire |
| Geocrush | Titan | 75 (Merit) | Earth |
| Grand Fall | Leviathan | 75 (Merit) | Water |
| Wind Blade | Garuda | 75 (Merit) | Wind |
| Tornado II | Siren | 75 | Wind |
| Heavenly Strike | Shiva | 75 (Merit) | Ice |
| Thunderstorm | Ramuh | 75 (Merit) | Thunder |
| Level ? Holy | Cait Sith | 75 | Light |
| Holy Mist | Carbuncle | 76 | Light |
| Lunar Bay | Fenrir | 78 | Dark |
| Night Terror | Diabolos | 80 | Dark |
| Conflag Strike | Ifrit | 99 | Fire (Breath) |
| Impact | Fenrir | 99 | Dark |

Lua lookup set:
```lua
magical_blood_pacts = S{
    'Fire II','Stone II','Water II','Aero II','Blizzard II','Thunder II',
    'Thunderspark','Meteorite','Fire IV','Stone IV','Water IV','Aero IV',
    'Blizzard IV','Thunder IV','Sonic Buffet','Nether Blast',
    'Meteor Strike','Geocrush','Grand Fall','Wind Blade','Tornado II',
    'Heavenly Strike','Thunderstorm','Level ? Holy','Holy Mist',
    'Lunar Bay','Night Terror','Conflag Strike','Impact'
}
```

### Blood Pact: Rage — Astral Flow (2h)

Ces pacts utilisent le set `BPRage.AstralFlow`.

| Name | Avatar | Element |
|---|---|---|
| Searing Light | Carbuncle | Light |
| Inferno | Ifrit | Fire |
| Earthen Fury | Titan | Earth |
| Tidal Wave | Leviathan | Water |
| Aerial Blast | Garuda | Wind |
| Diamond Dust | Shiva | Ice |
| Judgment Bolt | Ramuh | Thunder |
| Howling Moon | Fenrir | Dark |
| Ruinous Omen | Diabolos | Dark |
| Clarsach Call | Siren | Wind |
| Zantetsuken | Odin | Dark |

Lua lookup set:
```lua
astral_flow_pacts = S{
    'Searing Light','Inferno','Earthen Fury','Tidal Wave','Aerial Blast',
    'Diamond Dust','Judgment Bolt','Howling Moon','Ruinous Omen',
    'Clarsach Call','Zantetsuken'
}
```

### Blood Pact: Ward — Buff (target: <me>)

Ces pacts utilisent le set `BPWard.Buff`.

| Name | Avatar | Lvl | Effect |
|---|---|---|---|
| Shining Ruby | Carbuncle | 24 | Shellra |
| Glittering Ruby | Carbuncle | 44 | Protectra |
| Aerial Armor | Garuda | 25 | Blink |
| Frost Armor | Shiva | 28 | Ice Spikes |
| Rolling Thunder | Ramuh | 31 | Enthunder |
| Katabatic Blades | Siren | 31 | Enwind |
| Ecliptic Growl | Fenrir | 43 | STR/DEX/VIT |
| Lightning Armor | Ramuh | 42 | Shock Spikes |
| Noctoshield | Diabolos | 49 | Phalanx |
| Ecliptic Howl | Fenrir | 54 | AGI/INT/MND/CHR |
| Dream Shroud | Diabolos | 56 | MAB/MDB |
| Reraise II | Cait Sith | 30 | Reraise |
| Crimson Howl | Ifrit | 38 | Warcry |
| Hastega | Garuda | 48 | Haste |
| Earthen Ward | Titan | 46 | Stoneskin |
| Earthen Armor | Titan | 82 | Damage reduction |
| Fleet Wind | Garuda | 86 | Movement speed |
| Inferno Howl | Ifrit | 88 | Enfire |
| Wind's Blessing | Siren | 88 | Heal/Buff |
| Diamond Storm | Shiva | 90 | Evasion down (debuff mais Ward) |
| Pacifying Ruby | Carbuncle | 99 | Buff |
| Heavenward Howl | Fenrir | 96 | Buff |
| Hastega II | Garuda | 99 | Haste II |
| Crystal Blessing | Shiva | 99 | Heal/Buff |

Lua lookup set:
```lua
ward_buff_pacts = S{
    'Shining Ruby','Glittering Ruby','Aerial Armor','Frost Armor',
    'Rolling Thunder','Katabatic Blades','Ecliptic Growl','Lightning Armor',
    'Noctoshield','Ecliptic Howl','Dream Shroud','Reraise II',
    'Crimson Howl','Hastega','Earthen Ward','Earthen Armor',
    'Fleet Wind','Inferno Howl','Wind\'s Blessing',
    'Pacifying Ruby','Heavenward Howl','Hastega II','Crystal Blessing'
}
```

### Blood Pact: Ward — Heal (target: <me>)

Ces pacts utilisent le set `BPWard.Heal`.

| Name | Avatar | Lvl |
|---|---|---|
| Healing Ruby | Carbuncle | 1 |
| Whispering Wind | Garuda | 36 |
| Spring Water | Leviathan | 47 |
| Healing Ruby II | Carbuncle | 65 |
| Chinook | Siren | 42 |
| Soothing Ruby | Carbuncle | 94 |
| Soothing Current | Leviathan | 99 |
| Altana's Favor | Cait Sith | 1 (SP) |

Lua lookup set:
```lua
ward_heal_pacts = S{
    'Healing Ruby','Whispering Wind','Spring Water','Healing Ruby II',
    'Chinook','Soothing Ruby','Soothing Current','Altana\'s Favor'
}
```

### Blood Pact: Ward — Debuff (target: <t>)

Ces pacts utilisent le set `BPWard.Debuff`.

| Name | Avatar | Lvl | Effect |
|---|---|---|---|
| Lunatic Voice | Siren | 15 | Dispel |
| Somnolence | Diabolos | 20 | Gravity |
| Lunar Cry | Fenrir | 21 | Acc/Eva down |
| Mewing Lullaby | Cait Sith | 25 | Lullaby |
| Nightmare | Diabolos | 29 | Sleep + Bio |
| Lunar Roar | Fenrir | 32 | Dispel |
| Slowga | Leviathan | 33 | Slow |
| Ultimate Terror | Diabolos | 37 | Multi-stat down |
| Sleepga | Shiva | 39 | AoE Sleep |
| Bitter Elegy | Siren | 50 | Slow |
| Eerie Eye | Cait Sith | 55 | Silence |
| Tidal Roar | Leviathan | 84 | ATK down |
| Shock Squall | Ramuh | 92 | Debuff |
| Pavor Nocturnus | Diabolos | 98 | Debuff |
| Deconstruction | Atomos | 75 | Debuff |
| Chronoshift | Atomos | 75 | Debuff |

Note : Diamond Storm (Shiva lv90, Evasion down) est classée Ward mais est un debuff — la router vers `BPWard.Debuff`.

Lua lookup set:
```lua
ward_debuff_pacts = S{
    'Lunatic Voice','Somnolence','Lunar Cry','Mewing Lullaby','Nightmare',
    'Lunar Roar','Slowga','Ultimate Terror','Sleepga','Bitter Elegy',
    'Eerie Eye','Tidal Roar','Shock Squall','Pavor Nocturnus',
    'Deconstruction','Chronoshift','Diamond Storm'
}
```

### Raise (target: <stpc>)

| Name | Avatar | Lvl |
|---|---|---|
| Raise II | Cait Sith | 15 |

---

## 8. Job Abilities

| JA | Lvl | Type | Recast | Command | Notes |
|---|---|---|---|---|---|
| Astral Flow | 1 | SP (2h) | 1h | `/ja "Astral Flow" <me>` | Enables Astral Flow pacts |
| Elemental Siphon | 50 | JA | 5min | `/ja "Elemental Siphon" <me>` | Recover MP from avatar |
| Mana Cede | 55 | JA | 5min | `/ja "Mana Cede" <me>` | Give MP → avatar TP |
| Avatar's Favor | 55 | JA | 5min | `/ja "Avatar's Favor" <me>` | Toggle: party buff based on avatar |
| Apogee | 70 | JA | 3min | `/ja "Apogee" <me>` | Next BP: recast 0, +50% MP cost, -25% Ward duration |
| Astral Conduit | 96 | SP | 1h | `/ja "Astral Conduit" <me>` | 30s: all BP recast 0, full MP restore |
| Release | 1 | JA | — | `/ja "Release" <me>` | Dismiss avatar |
| Assault | 1 | JA | — | `/ja "Assault" <t>` | Send avatar to attack |
| Retreat | 1 | JA | — | `/ja "Retreat" <me>` | Call avatar back |

---

## 9. Summon commands

```lua
summon_spells = {
    ['Carbuncle']   = '/ma "Carbuncle" <me>',
    ['Ifrit']       = '/ma "Ifrit" <me>',
    ['Shiva']       = '/ma "Shiva" <me>',
    ['Garuda']      = '/ma "Garuda" <me>',
    ['Titan']       = '/ma "Titan" <me>',
    ['Ramuh']       = '/ma "Ramuh" <me>',
    ['Leviathan']   = '/ma "Leviathan" <me>',
    ['Fenrir']      = '/ma "Fenrir" <me>',
    ['Diabolos']    = '/ma "Diabolos" <me>',
    ['Cait Sith']   = '/ma "Cait Sith" <me>',
    ['Siren']       = '/ma "Siren" <me>',
    ['Atomos']      = '/ma "Atomos" <me>',
    ['Alexander']   = '/ma "Alexander" <me>',
    ['Odin']        = '/ma "Odin" <me>',
}
```

---

## 10. Weapon

```lua
sets.weapons = {
    main  = "Grioavolr",
    sub   = "", -- à remplir
}
```

---

## 11. Notes pour Claude Code

- Structure identique aux autres Lua du projet (Tetsouo, pattern Mote).
- Tous les sets sont en squelette vide — l'utilisateur remplit slot par slot.
- Le routing pet_midcast est la partie critique : détecter le spell name du Blood Pact et équiper le bon set (Physical / Magical / Hybrid / AstralFlow / Ward Buff / Ward Debuff / Ward Heal).
- Pas d'automation Apogee/AC. Juste les sets JA classiques.
- Avatar par défaut au load : Carbuncle (`/ma "Carbuncle" <me>` en get_sets).
- Keybinds standard du projet.
- Fichier de référence Blood Pact complet : `SMN_BLOOD_PACTS_REFERENCE.md` (dans outputs).
