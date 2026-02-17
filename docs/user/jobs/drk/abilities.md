# DRK - Job Abilities

Abilities with GearSwap gear set integration. The system equips ability-specific gear on precast and tracks active buffs for midcast enhancement.

---

## Precast gear sets

These abilities have dedicated `sets.precast.JA[name]` in `drk_sets.lua`:

| Ability | Level | Recast | Set slot | Effect |
|---------|-------|--------|----------|--------|
| Blood Weapon | 1 (SP) | 60 min | body | Duration (Fallen's Cuirass +3) |
| Arcane Circle | 5 | 5 min | feet | Duration + potency (Ignominy Sollerets +2) |
| Last Resort | 15 | 5 min | feet, back | Defense penalty reduction (Fallen's Sollerets +3) |
| Weapon Bash | 20 | 3 min | hands | Damage + Chainbound (Ig. Gauntlets +3) |
| Souleater | 30 | 6 min | head | HP% increase (Ignominy Burgeonet +2) |
| Dark Seal | Merit | 5 min | head | Dark Magic duration (Fallen's Burgeonet +3) |
| Diabolic Eye | Merit | 5 min | hands | Duration (Fall. Fin. Gaunt. +3) |
| Nether Void | 78 | 5 min | legs | Absorption potency (Heath. Flanchard +3) |

---

## Buff-tracked abilities

These abilities set active buff flags that modify midcast gear selection:

### Dark Seal

When active (buff ID 345), DRK_MIDCAST equips `sets.buff['Dark Seal']` (head) for Dark Magic spells. Enhances magic accuracy for the next Dark Magic cast.

### Nether Void

When active (buff ID 439), DRK_MIDCAST equips `sets.buff['Nether Void']` (legs) for Absorb, Drain, and Aspir spells. Increases absorption potency by 50% (up to 95% with Heathen's Flanchard +3 and JP).

Both abilities set a pending flag in precast (`_G.drk_dark_seal_pending`, `_G.drk_nether_void_pending`) that persists until the next Dark Magic cast.

---

## Abilities without gear sets

These are in the JA database but have no precast gear integration:

| Ability | Level | Notes |
|---------|-------|-------|
| Consume Mana | 55 | Converts MP to damage on next attack |
| Arcane Crest | 87 | Debuffs Arcana-type enemies |
| Scarlet Delirium | 95 | Channels damage taken into attack/magic attack |
| Soul Enslavement | 96 (SP) | Drains target TP with melee hits |

---

## Data files

| File | Content |
|------|---------|
| `shared/data/job_abilities/drk/drk_mainjob.lua` | Dark Seal, Diabolic Eye, Nether Void, Arcane Crest, Scarlet Delirium |
| `shared/data/job_abilities/drk/drk_sp.lua` | Blood Weapon, Soul Enslavement |
| `shared/data/job_abilities/drk/drk_subjob.lua` | Arcane Circle, Last Resort, Weapon Bash, Souleater, Consume Mana |
| `shared/jobs/drk/functions/DRK_PRECAST.lua` | Gear equip logic for JA precast |
| `shared/jobs/drk/functions/DRK_MIDCAST.lua` | Dark Seal + Nether Void buff detection |
| `_master/sets/drk_sets.lua` | Equipment sets (sets.precast.JA, sets.buff) |
