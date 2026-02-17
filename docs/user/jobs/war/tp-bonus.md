# TP BONUS REFERENCE - Unimplemented Jobs

**Reference file** containing all TP Bonus data for future jobs.
**Date:** 2025-10-26
**Status:** Documentation for future development

---

## JOBS ALREADY IMPLEMENTED 

### **WAR (Warrior)**

- **Config:** `config/war/WAR_TP_CONFIG.lua` 
- **Weapons:** Chango +500 TP
- **Armor:** Boii Cuisses +3 +100 TP, Moonshade Earring +250 TP
- **Buffs:** Warcry +700 TP (5/5 merits + Agoge Mask), Fencer +860 TP (20/20 JP)
- **Functions:** get_weapon_bonus(), get_warcry_bonus(), get_fencer_bonus()
- **Centralized System:** Uses `TPBonusHandler` (utils/precast/tp_bonus_handler.lua) for calculation/application

### **PLD (Paladin)**

- **Status:** IMPLEMENTED (v3.0)
- **Weapons:** Sequence +500 TP
- **Armor:** Moonshade Earring +250 TP
- **Config:** Not required (primarily tank/support job)

### **DNC (Dancer)**

- **Status:** IMPLEMENTED (v2.0)
- **Weapons:** Aeneas +500 TP
- **Armor:** Moonshade Earring +250 TP
- **Config:** Not created (simple weapon bonus)

### **THF (Thief)**

- **Status:** IMPLEMENTED (v2.0)
- **Weapons:** Aeneas +500 TP
- **Armor:** Moonshade Earring +250 TP
- **Config:** Not created (simple weapon bonus)

### **COR (Corsair)**

- **Status:** IMPLEMENTED (v2.0)
- **Weapons:** Fomalhaut +500 TP
- **Armor:** Moonshade Earring +250 TP
- **Config:** Not created (simple weapon bonus)

### **GEO (Geomancer)**

- **Status:** IMPLEMENTED (v2.0)
- **Weapons:** Tishtrya +500 TP
- **Armor:** Moonshade Earring +250 TP
- **Config:** Not required (primarily support job)

### **BRD (Bard)**

- **Status:** IMPLEMENTED (v2.0)
- **Weapons:** Aeneas +500 TP
- **Armor:** Moonshade Earring +250 TP
- **Config:** Not required (primarily support job)

### **RDM (Red Mage)**

- **Status:** IMPLEMENTED (v2.0)
- **Weapons:** Sequence +500 TP
- **Armor:** Moonshade Earring +250 TP
- **Config:** Not required (hybrid magic/melee job)

### **BLM (Black Mage)**

- **Status:** IMPLEMENTED (v3.0)
- **Weapons:** Khatvanga +500 TP
- **Armor:** Moonshade Earring +250 TP
- **Config:** Not required (pure caster job)

---

## JOBS TO IMPLEMENT (BY PRIORITY)

### **MNK (Monk)**

#### Weapons with TP Bonus

- Godhands: +500 TP
  - DMG:+197 Delay:+138 Hand-to-Hand skill +269
  - "Store TP"+10 "TP Bonus"+500
  - "Shijin Spiral" Aftermath
- Chastisers: +300 TP
  - DMG:+148 Delay:+90 STR+20 Attack+33
  - Hand-to-Hand skill +242 "Triple Attack"+3%
  - "TP Bonus"+300

#### Armor with TP Bonus

- Mpaca's Cap: +200 TP
  - DEF:143 HP+61 STR+33 DEX+30 VIT+26 AGI+24
  - Accuracy+40 Attack+40 Haste+6%
  - "Triple Attack"+3% Critical hit rate +4%
  - "TP Bonus"+200 Physical damage taken -7%
- Moonshade Earring: +250 TP

**Config to create:** `config/mnk/MNK_TP_CONFIG.lua`

#### Functions needed

```lua
function MNKTPConfig.get_weapon_bonus(weapon_name)
    -- Godhands: +500, Chastisers: +300
end
```

---

### **SAM (Samurai)**

#### Weapons with TP Bonus

- Dojikiri Yasutsuna: +500 TP
  - DMG:315 Delay:450 Great Katana skill +269
  - "Store TP"+10 "TP Bonus"+500
  - "Tachi: Shoha" Aftermath
- Hangaku-no-Yumi (Ranged): +1000 TP
  - DMG:251 Delay:600 Archery skill +242
  - Ranged Accuracy+15 Ranged Attack+25
  - "True Shot"+2 "TP Bonus"+1000

#### Armor with TP Bonus

- Mpaca's Cap: +200 TP (same stats as MNK)
- Moonshade Earring: +250 TP

**Config to create:** `config/sam/SAM_TP_CONFIG.lua`

#### Functions needed

```lua
function SAMTPConfig.get_weapon_bonus(weapon_name)
    -- Dojikiri: +500, Hangaku-no-Yumi: +1000
end
```

**Note:** SAM can use ranged weapons (Hangaku-no-Yumi) - plan for ranged WS support

---

### **NIN (Ninja)**

#### Weapons with TP Bonus

- Heishi Shorinken: +500 TP
  - DMG:159 Delay:227 Katana skill +269
  - "Store TP"+10 "TP Bonus"+500
  - "Blade: Shun" Aftermath

#### Armor with TP Bonus

- Mpaca's Cap: +200 TP (same stats as MNK)
- Moonshade Earring: +250 TP

**Config to create:** `config/nin/NIN_TP_CONFIG.lua`

#### Functions needed

```lua
function NINTPConfig.get_weapon_bonus(weapon_name)
    -- Heishi Shorinken: +500
end
```

---

### **PUP (Puppetmaster)**

#### Weapons with TP Bonus

- Godhands: +500 TP (shared with MNK)
- Chastisers: +300 TP (shared with MNK)

#### Armor with TP Bonus (Player)

- Mpaca's Cap: +200 TP (same stats as MNK)
- Moonshade Earring: +250 TP

#### Armor with TP Bonus (Automaton - SKIP for now)

- Kara. Cappello +2: Automaton "TP Bonus"+575
- Kara. Cappello +3: Automaton "TP Bonus"+600

**Config to create:** `config/pup/PUP_TP_CONFIG.lua`

#### Functions needed

```lua
function PUPTPConfig.get_weapon_bonus(weapon_name)
    -- Godhands: +500, Chastisers: +300
end
```

**Note:** Pet TP Bonus (Kara. Cappello) = skip for now (concerne l'Automaton, pas le joueur)

---

### **DRK (Dark Knight)**

#### Weapons with TP Bonus

- Anguta: +500 TP
  - DMG:370 Delay:528 Scythe skill +269
  - "Store TP"+10 "TP Bonus"+500
  - "Entropy" Aftermath

#### Armor with TP Bonus

- Moonshade Earring: +250 TP

**Config to create:** `config/drk/DRK_TP_CONFIG.lua`

#### Functions needed

```lua
function DRKTPConfig.get_weapon_bonus(weapon_name)
    -- Anguta: +500
end
```

---

### **DRG (Dragoon)**

#### Weapons with TP Bonus

- Trishula: +500 TP
  - DMG:345 Delay:492 Polearm skill +269
  - "Store TP"+10 "TP Bonus"+500
  - "Stardiver" Aftermath
- Rhomphaia: +50 TP
  - DMG:268 Delay:492 Polearm skill +242
  - Attack+20 "Dragon Killer"+10
  - Jump: "Double Attack"+7% "TP Bonus"+50

#### Armor with TP Bonus

- Moonshade Earring: +250 TP

**Config to create:** `config/drg/DRG_TP_CONFIG.lua`

#### Functions needed

```lua
function DRGTPConfig.get_weapon_bonus(weapon_name)
    -- Trishula: +500, Rhomphaia: +50
end
```

---

### **RNG (Ranger)**

#### Weapons with TP Bonus

- Fail-Not: +500 TP
  - DMG:330 Delay:600 Archery skill +269
  - "Store TP"+10 "TP Bonus"+500
  - "Apex Arrow" Aftermath
- Fomalhaut: +500 TP
  - DMG:167 Delay:600 Marksmanship skill +269
  - "Store TP"+10 "TP Bonus"+500
  - "Last Stand" Aftermath
- Hangaku-no-Yumi: +1000 TP
  - DMG:251 Delay:600 Archery skill +242
  - Ranged Accuracy+15 Ranged Attack+25
  - "True Shot"+2 "TP Bonus"+1000

#### Reives Weapons (SKIP - situational)

- Homestead Bow: +1000 TP (Reives only)
- Home. Bowgun: +1000 TP (Reives only)
- Homestead Gun: +1000 TP (Reives only)

#### Armor with TP Bonus

- Moonshade Earring: +250 TP

**Config to create:** `config/rng/RNG_TP_CONFIG.lua`

#### Functions needed

```lua
function RNGTPConfig.get_weapon_bonus(weapon_name)
    -- Fail-Not: +500, Fomalhaut: +500, Hangaku-no-Yumi: +1000
end
```

**Note:** RNG utilise range weapons - adapter logique pour range slot au lieu de main

---

### **BST (Beastmaster)**

#### Weapons with TP Bonus

- Tri-edge: +500 TP
  - DMG:202 Delay:288 Axe skill +269
  - "Store TP"+10 "TP Bonus"+500
  - "Ruinator" Aftermath
- Arasy Tabar +1: +150 TP
  - DMG:149 Delay:280 Axe skill +242
  - STR+11 DEX+11 AGI+11 Accuracy+15
  - "TP Bonus"+150 Pet: Accuracy+15
- Arasy Tabar: +100 TP
  - DMG:148 Delay:288 Axe skill +242
  - STR+6 DEX+6 AGI+6 Accuracy+10
  - "TP Bonus"+100 Pet: Accuracy+10

#### Armor with TP Bonus

- Moonshade Earring: +250 TP

**Config to create:** `config/bst/BST_TP_CONFIG.lua`

#### Functions needed

```lua
function BSTTPConfig.get_weapon_bonus(weapon_name)
    -- Tri-edge: +500, Arasy Tabar +1: +150, Arasy Tabar: +100
end
```

---

### **RUN (Rune Fencer)**

#### Weapons with TP Bonus

- Lionheart: +500 TP
  - DMG:336 Delay:480 Great Sword skill +269
  - "Store TP"+10 "TP Bonus"+500
  - "Resolution" Aftermath

#### Armor with TP Bonus

- Moonshade Earring: +250 TP

**Config to create:** `config/run/RUN_TP_CONFIG.lua`

#### Functions needed

```lua
function RUNTPConfig.get_weapon_bonus(weapon_name)
    -- Lionheart: +500
end
```

---

### **BLU (Blue Mage)**

#### Weapons with TP Bonus

- Sequence: +500 TP (shared with PLD/RDM)

#### Armor with TP Bonus

- Moonshade Earring: +250 TP

**Config to create:** `config/blu/BLU_TP_CONFIG.lua`

#### Functions needed

```lua
function BLUTPConfig.get_weapon_bonus(weapon_name)
    -- Sequence: +500
end
```

---

### **WHM (White Mage)**

#### Weapons with TP Bonus

- Tishtrya: +500 TP
  - DMG:185 Delay:264 Club skill +269
  - "Store TP"+10 "TP Bonus"+500
  - "Realmrazer" Aftermath

#### Armor with TP Bonus

- Moonshade Earring: +250 TP

**Config to create:** `config/whm/WHM_TP_CONFIG.lua`

#### Functions needed

```lua
function WHMTPConfig.get_weapon_bonus(weapon_name)
    -- Tishtrya: +500
end
```

---

### **SMN (Summoner)**

#### Weapons with TP Bonus

- Khatvanga: +500 TP
  - DMG:268 Delay:402 Staff skill +269
  - "Occult Acumen"+30 "TP Bonus"+500
  - "Shattersoul" Aftermath

#### Armor with TP Bonus (Player)

- Moonshade Earring: +250 TP

#### Armor with TP Bonus (Avatar - SKIP for now)

- Beck. Spats +2: Avatar "TP Bonus"+650
- Beck. Spats +3: Avatar "TP Bonus"+700

**Config to create:** `config/smn/SMN_TP_CONFIG.lua`

#### Functions needed

```lua
function SMNTPConfig.get_weapon_bonus(weapon_name)
    -- Khatvanga: +500
end
```

**Note:** Pet TP Bonus (Beckoner's Spats) = skip for now (concerne l'Avatar, pas le joueur)

---

### **SCH (Scholar)**

#### Weapons with TP Bonus

- Khatvanga: +500 TP (shared with BLM/SMN)

#### Armor with TP Bonus

- Moonshade Earring: +250 TP

**Config to create:** `config/sch/SCH_TP_CONFIG.lua`

#### Functions needed

```lua
function SCHTPConfig.get_weapon_bonus(weapon_name)
    -- Khatvanga: +500
end
```

---

## SUMMARY BY CATEGORY

### **Jobs with Mpaca's Cap (+200 TP):**

- MNK, SAM, NIN, PUP

### **Jobs sharing weapons:**

#### Aeneas (+500 TP)

- THF, BRD, DNC

#### Sequence (+500 TP)

- RDM, PLD, BLU

#### Tishtrya (+500 TP)

- WHM, GEO

#### Khatvanga (+500 TP)

- BLM, SMN, SCH

#### Godhands (+500 TP) / Chastisers (+300 TP)

- MNK, PUP

#### Fomalhaut (+500 TP)

- RNG, COR

---

## FUTURE IMPLEMENTATION WORKFLOW

#### For each new job

1. **Create config/[job]/[JOB]_TP_CONFIG.lua**
   - Table `pieces` (armor avec TP Bonus)
   - Table `weapons` (armes avec TP Bonus)
   - Function `get_weapon_bonus(weapon_name)`
   - Functions buffs si nécessaire (rare - seulement WAR a Warcry/Fencer)

2. **Modify jobs/[job]/functions/[JOB]_PRECAST.lua**
   - Require config: `local JobTPConfig = require('config/[job]/[JOB]_TP_CONFIG')`
   - Include calculator: `include('utils/weaponskill/tp_bonus_calculator.lua')`
   - Appeler dans `job_precast()` avant WS
   - Appeler dans `job_post_precast()` pour afficher TP final

3. **DO NOT MODIFY utils/**
   - `tp_bonus_calculator.lua` >> Already 100% generic
   - `weaponskill_manager.lua` >> No TP Bonus logic

---

## IMPORTANT NOTES

### **Reives Weapons (SKIP):**

Homestead series weapons (+1000 TP) only work in Reives zones - skip for simplification.

### **Pet TP Bonus (SKIP for now):**

Some equipment gives TP Bonus to pets (Automaton, Avatar):

- Kara. Cappello +2/+3 (PUP): Automaton TP +575/+600
- Beck. Spats +2/+3 (SMN): Avatar TP +650/+700

>> Concerns PETS, not the player. Skip until advanced pet system implementation.

### **Ranged Weapons (RNG/SAM/COR):**

Some jobs use range slot for TP Bonus:

- RNG: Fail-Not, Fomalhaut, Hangaku-no-Yumi
- COR: Fomalhaut
- SAM: Hangaku-no-Yumi (ranged subjob)

>> Adapt logic `get_weapon_bonus()` to check `player.equipment.range` in addition to `main`

---

**Last updated:** 2025-10-16
**Maintained by:** Claude (assistant IA)
**Implemented jobs:** 9/22 (WAR, PLD, DNC, THF, COR, GEO, BRD, RDM, BLM)
