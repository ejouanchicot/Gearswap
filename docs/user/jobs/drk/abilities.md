# Dark Knight - Job Abilities Reference

Complete reference for Dark Knight job abilities, equipment modifiers, and mechanics.

---

## Blood Weapon (SP Ability)

**Level:** 1
**Type:** SP Ability
**Duration:** 30 seconds
**Recast:** 60 minutes
**Command:** `/ja "Blood Weapon" <me>`

### Description

Allows you to drain your target's HP with your melee attacks. Drains target HP with melee attacks (amount drained = damage dealt).

### Notes

- HP returned is reduced on mobs with Shell or Phalanx
- Often combined with Souleater for maximum effect

### Job Points (20 ranks)

**Blood Weapon Effect:** Increases the amount of HP absorbed by 2% per rank.

### Equipment Modifiers

- **Absorbent Cuirass +2** (Body, Lv90): Duration +10 seconds
- **Fallen's Cuirass** (Body, Lv99): Duration +10 seconds
- **Fallen's Cuirass +1/+2/+3** (Body, Lv99): Duration +10 seconds

---

## Arcane Circle

**Level:** 5
**Type:** Job Ability
**Duration:** 3 minutes
**Recast:** 5 minutes (base)
**Command:** `/ja "Arcane Circle" <me>`

### Description

Grants resistance against arcana to party members within area of effect.

### Notes

- Gives party members in range the effect of Arcana Killer
- Main job gives unique 15% damage bonus against arcana, 15% damage resistance from arcana, and likely +15% Arcana Killer
- When subbed, gives 5% of these bonuses
- Only one Circle may be active at any given time

### Merit Points (5 ranks)

Reduces recast time by 10 seconds per merit point.

### Job Points (20 ranks)

**Arcane Circle Effect:** Reduces damage taken by 1% per rank.

### Equipment Modifiers

- **Chaos Sollerets** (Feet, Lv52): Duration +50%, potency +2%
- **Chaos Sollerets +1** (Feet, Lv74): Duration +50%, potency +2%
- **Ignominy Sollerets** (Feet, Lv99): Duration +50%, potency +2%
- **Ignominy Sollerets +1/+2/+3** (Feet, Lv99): Duration +50%, potency +2%

---

## Last Resort

**Level:** 15
**Type:** Job Ability
**Duration:** 3 minutes
**Recast:** 5 minutes (base)
**Command:** `/ja "Last Resort" <me>`

### Description

Enhances attacks but weakens defense.

### Notes

- Increases attack by 25% (64/256) and reduces defense by 25% (64/256)
- With 5/5 Last Resort Effect merits: +34.77% (89/256) attack, -34.77% (89/256) defense
- Up to +25% Job Ability Haste can be added via Desperate Blows merits
- Base of +15% (Desperate Blows) at level 45
- Only one instance of the ability is active at a time

### Merit Points (5 ranks each)

1. Reduces recast time by 10 seconds per merit point
2. Increases attack bonus and defense penalty by 2% (5/256) per merit point

### Job Points (20 ranks)

**Last Resort Effect:** Increases physical attack by 2 per rank.

### Equipment Modifiers

- **Abyss Sollerets** (Feet, Lv71): Reduces defense penalty by 10%
- **Abyss Sollerets +1/+2** (Feet, Lv75/90): Reduces defense penalty by 10%
- **Fallen's Sollerets** (Feet, Lv99): Reduces defense penalty by 10%
- **Fallen's Sollerets +1/+2/+3** (Feet, Lv99): Reduces defense penalty by 10%
- **Ankou's Mantle** (Back, Lv99): Duration +15 seconds (worn for activation)

---

## Weapon Bash

**Level:** 20
**Type:** Job Ability
**Recast:** 3 minutes (base)
**Command:** `/ja "Weapon Bash" <stnpc>`

### Description

Delivers an attack that can stun the target. Two-handed weapon required.

### Notes

- Goes through shadows
- Stun rate is near 100% and lasts a long time
- Instant ability - very effective for interrupting enemy TP moves
- At level 75, unenhanced Weapon Bash deals 21 blunt damage
- Damage formula: FLOOR((Level + 11) / 4 + Equipment Bonus)
- Damage scales with Dark Knight level - lower if subbed
- Equipping Ignominy Gauntlets +2/+3 grants skillchain properties, allowing self-skillchains

### Skillchain Combos (for Drain)

- Weapon Bash > Nightmare Scythe = Compression
- Weapon Bash > Insurgency = Compression
- Weapon Bash > Infernal Scythe = Compression
- Weapon Bash > Upheaval = Compression
- Weapon Bash > Keen Edge = Compression

### Merit Points (5 ranks)

Reduces recast by 6 seconds per merit point.

### Job Points (20 ranks)

**Weapon Bash Effect:** Increases damage dealt by 10 per rank.

### Equipment Modifiers

- **Smiting Scythe** (Main, Lv54): Bash Damage +8
- **Smiting Scythe +1** (Main, Lv54): Bash Damage +10
- **Slayer's Ring** (Ring, Lv50): Latent Effect (HP<75%, TP<100): Bash Damage +10
- **Chaos Gauntlets** (Hands, Lv54): Bash Damage +10
- **Chaos Gauntlets +1** (Hands, Lv74): Bash Damage +10
- **Knightly Earring** (Ear, Lv59): Bash Damage +10
- **Crude Sword** (Main, Lv70): Bash Damage +15
- **Sigma Earring** (Ear, Lv75): Bash Damage +10 (Salvage)
- **Mekosuchus Blade** (Main, Lv99): Bash Damage +30
- **Ignominy Gauntlets** (Hands, Lv99): Bash Damage +12
- **Ignominy Gauntlets +1** (Hands, Lv99): Bash Damage +12
- **Ignominy Gauntlets +2** (Hands, Lv99): Bash Damage +14, adds Chainbound
- **Ignominy Gauntlets +3** (Hands, Lv99): Bash Damage +16, adds Chainbound

---

## Souleater

**Level:** 30
**Type:** Job Ability
**Duration:** 1 minute
**Recast:** 6 minutes (base)
**Command:** `/ja "Souleater" <me>`

### Description

Consumes 10% of your HP to enhance attacks.

### Notes

- Consumes and converts 10% of current HP directly into physical damage added to melee hits
- As a sub job, consumes 10% HP but only 5% is converted into bonus damage
- Bonus damage from HP sacrifice is affected by Damage Type
- For Weapon Skills: bonus damage is boosted by Weapon Skill Damage stat (not PDIF or FTP)
- Enhances accuracy by +25 while active
- Muted Soul merit: reduces enmity by -10 per rank during activation and duration
- Certain monsters (e.g., Absolute Virtue) resist Souleater effects
- Commonly combined with Blood Weapon and Haste buffs for high burst damage
- Attacking targets with Phalanx or Souleater resistance can cause rapid HP loss
- Multiple 12% gear pieces do not stack, except for Dweomer Scythe which does
- Wearing multiple percentage-increasing items will cap at the highest modifier, not cumulative

### Merit Points (5 ranks)

Reduces recast time by 12 seconds per merit point.

### Job Points (20 ranks)

**Souleater Effect:** Increases duration by 1 second per rank.

### Equipment Modifiers

- **Gloom Breastplate** (Body, Lv50): 12% HP used (instead of 10%)
- **Sable Cuisses** (Legs, Lv50): 12% HP used (instead of 10%)
- **Chaos Burgeonet** (Head, Lv60): 12% HP used (instead of 10%)
- **Moliones's Ring + Moliones's Sickle** (Set, Lv70): 12% HP used (instead of 10%)
- **Chaos Burgeonet +1** (Head, Lv74): 12% HP used (instead of 10%)
- **Dweomer Scythe** (Main, Lv75): Souleater +1-2% (stacks with other modifiers)
- **Ignominy Burgeonet** (Head, Lv99): 12% HP used (instead of 10%)
- **Ignominy Burgeonet +1** (Head, Lv99): 12% HP used (instead of 10%)
- **Ignominy Burgeonet +2** (Head, Lv99): 14% HP used (instead of 10%)
- **Ignominy Burgeonet +3** (Head, Lv99): 16% HP used (instead of 10%)
- **Brutality** (Main, Lv99): 12% HP used (instead of 10%)
- **Agwu's Scythe** (Main, Lv99): 30% HP used (instead of 10%)
- **Dacnomania** (Main, Lv99): 45% HP used (instead of 10%)
- **Final Sickle** (Main, Lv99): No HP consumption; duration extends +1 second per WS used

---

## Consume Mana

**Level:** 55
**Type:** Job Ability
**Duration:** 1 minute (or until next attack)
**Recast:** 1 minute
**Command:** `/ja "Consume Mana" <me>`

### Description

Converts all MP into damage for the next attack.

### Notes

- Consumes all MP upon the next attack or weaponskill after use
- Adds +1 base damage for every 10 MP consumed

---

## Dark Seal (Merit Ability)

**Type:** Merit Ability
**Duration:** 1 minute or until first spell cast
**Recast:** 5 minutes
**Command:** `/ja "Dark Seal" <me>`

### Description

Enhances the accuracy of your next Dark Magic spell.

### Notes

- Enhances Magic Accuracy for the next Dark Magic spell cast
- Has no effect on spell potency
- Effect expires after one spell or 1 minute, whichever comes first

### Merit Points (5 ranks)

Each merit level after the first reduces Dark Magic casting time by 10%.

### Equipment Modifiers

- **Abyss Burgeonet +2** (Head, Lv90): Dark Magic duration +10% per merit level
- **Fallen's Burgeonet** (Head, Lv99): Dark Magic duration +10% per merit level
- **Fallen's Burgeonet +1/+2/+3** (Head, Lv99): Dark Magic duration +10% per merit level

(Affects Dread Spikes, Absorb Spells, and Drain III)

---

## Diabolic Eye (Merit Ability)

**Type:** Merit Ability
**Duration:** 3 minutes
**Recast:** 5 minutes
**Command:** `/ja "Diabolic Eye" <me>`

### Description

Reduces maximum HP while increasing accuracy.

### Notes

- Grants Accuracy +20 (base) and reduces maximum HP by 15% while active
- Gear with HP-based activation thresholds (e.g., Parade Gorget at 85%) may not activate properly when this ability is active
- Effect persists for 3 minutes or until manually canceled

### Merit Points (5 ranks)

Increases Accuracy by +5 for each rank beyond the first.

### Equipment Modifiers

- **Abyss Gauntlets +2** (Hands, Lv90): Duration +6 seconds per merit
- **Fallen's Fin. Gaunt.** (Hands, Lv99): Duration +6 seconds per merit
- **Fallen's Fin. Gaunt. +1/+2/+3** (Hands, Lv99): Duration +6 seconds per merit

---

## Nether Void

**Level:** 78
**Type:** Job Ability
**Duration:** 1 minute or until next Dark Magic cast
**Recast:** 5 minutes
**Command:** `/ja "Nether Void" <me>`

### Description

Increases the absorption potency of your next Dark Magic spell.

### Notes

- Increases the potency of the next Absorb or Drain Dark Magic spell by 50%
- Does not affect Absorb-TP
- Effect expires after 1 minute or after casting one applicable spell
- Highly synergistic with Absorb-Attri and Drain III
- Primarily used to maximize stat absorption or HP drain efficiency

### Job Points (20 ranks)

**Nether Void Effect:**

- Increases the amount absorbed by 2% per rank
- Increases the number of statuses absorbed by Absorb-Attri by 1 per 10 Job Points

### Equipment Modifiers

- **Bale Flanchard +1** (Legs, Lv83): Nether Void bonus +15% (total 65%)
- **Bale Flanchard +2** (Legs, Lv83): Nether Void bonus +25% (total 75%)
- **Heathen's Flanchard** (Legs, Lv99): Nether Void bonus +30% (total 80%)
- **Heathen's Flanchard +1** (Legs, Lv99): Nether Void bonus +35% (total 85%)
- **Heathen's Flanchard +2** (Legs, Lv99): Nether Void bonus +40% (total 90%)
- **Heathen's Flanchard +3** (Legs, Lv99): Nether Void bonus +45% (total 95%)

---

## Arcane Crest

**Level:** 87
**Type:** Job Ability
**Duration:** 3 minutes
**Range:** 12'
**Recast:** 5 minutes
**Command:** `/ja "Arcane Crest" <t>`

### Description

Lowers accuracy, evasion, magic accuracy, magic evasion, and TP gain for arcana-type enemies.

### Notes

- Only affects targets of the Arcana family - has no effect on other monster types
- Applies a flat -20 penalty to the target's Accuracy, Evasion, Magic Accuracy, Magic Evasion, and Store TP
- Cannot stack with other Circle-type abilities
- Useful for weakening Arcana enemies in both physical and magical combat

### Job Points (20 ranks)

**Arcane Crest Effect:** Increases duration by 1 second per rank.

---

## Scarlet Delirium

**Level:** 95
**Type:** Job Ability
**Duration:** 90 seconds
**Recast:** 90 seconds
**Command:** `/ja "Scarlet Delirium" <me>`

### Description

Channels damage taken into enhanced attack and magic attack.

### Notes

- Upon activation, the ability waits for the next incoming attack within 90 seconds
- The first hit received determines the power of the buff, based on the HP percentage lost
- Increases both physical and magical damage proportional to half the HP% lost (rounded down)
- Example: Losing 50% HP grants +25% attack and magic attack bonus
- The damage multiplier effect lasts for 90 seconds after being triggered
- Highly effective when intentionally timed with strong incoming attacks for maximum boost

### Job Points (20 ranks)

**Scarlet Delirium Effect:** Increases duration by 1 second per rank.

---

## Soul Enslavement (SP Ability)

**Level:** 96
**Type:** SP Ability
**Duration:** 30 seconds
**Recast:** 60 minutes
**Command:** `/ja "Soul Enslavement" <me>`

### Description

Melee attacks absorb the target's TP.

### Notes

- Drains the target's TP with each melee hit for the duration
- The amount of TP drained per swing scales with weapon delay (higher delay = higher TP drain cap)
- Example: Foenaria scythe (513 delay) drains up to 666 TP per swing; Ternion Dagger +1 (175 delay) drains up to 270 TP
- Multi-attack procs reduce the TP drain on subsequent hits (e.g., 666 > 366 > 168 TP for Foenaria)
- Still drains TP even if the Dark Knight is at 3000 TP (the log may show 0 TP drained, but the target continues to lose TP)
- Removes Endark, Endark II, or Auspice effects from the player upon activation
- Does NOT stack with Blood Weapon - Blood Weapon's HP drain takes precedence and disables TP drain
- Best used when Blood Weapon is inactive to maximize efficiency

### Job Points (20 ranks)

**Soul Enslavement Effect:** Increases amount of TP absorbed by 1% per rank.

### TP Drain Mechanics

**Formula:** DrainCap = WeaponDelay x 1.3 (approximation)

**Examples:**

- Foenaria Scythe (513 delay): Max drain 666 TP
- Ternion Dagger +1 (175 delay): Max drain 270 TP

**Multi-hit Adjustment:**

- First hit: 100% of cap
- Second hit: ~55% of cap
- Third hit: ~40% of cap

---

_Document generated for Tetsouo GearSwap System_
_Last updated: 2025-10-23_
