# Auto-tier: WHM Cures, DNC Waltzes, BLM, RDM and GEO spells

Two kinds of automatic tier choice:

- **Heals** (WHM Cure, DNC Waltz): the tier is picked from the HP the target
  is missing, so you can put one macro on the top tier and spend less MP or TP.
- **Step-down** (BLM, RDM, GEO): a spell on recast or too expensive is
  replaced by the next lower tier that can go.

## WHM: Cure and Curaga

Macro the tier you like (Cure VI, Curaga V...). Before it goes off:

- **Auto-tier** (mode `CureAutoTier`, key Ctrl+Numpad4, On / Off): the
  smallest tier that covers the missing HP replaces it.
- **Recast fallback** (always on, even with auto-tier Off): if the tier is on
  recast, the next ready one is used, lower tiers first, then higher.

Missing HP: exact for yourself; for a party or alliance member it is estimated
from their HP % as if they had 2000 max HP. 50 HP are added as a safety
margin before the lookup.

Tiers, from `<YourName>/whm/WHM_CURE_CONFIG.lua` (edit them there):

| Missing HP | Cure | | Missing HP | Curaga |
|---|---|---|---|---|
| 0-200 | Cure | | 0-300 | Curaga |
| 200-400 | Cure II | | 300-600 | Curaga II |
| 400-700 | Cure III | | 600-1000 | Curaga III |
| 700-1100 | Cure IV | | 1000-1400 | Curaga IV |
| 1100-1600 | Cure V | | 1400+ | Curaga V |
| 1600+ | Cure VI | | | |

The thresholds are fixed numbers; they do not follow your Cure Potency gear.
The `auto_tier_enabled` line of that file is not what turns auto-tier on or
off: the `CureAutoTier` mode is.

## DNC: `//gs c waltz` and `//gs c aoewaltz`

Both need DNC as main job or subjob, and cancel Saber Dance first.

- `//gs c waltz` sends Curing Waltz on `<stpc>` (you pick the target with the
  cursor). The tier is chosen from the missing HP of your **current target**
  when it is you or a party / alliance member (exact for you, estimated from
  HP % for others); with no target it is sized for you; with a monster
  targeted, the HP cannot be known and the highest usable tier is tried first.
  If that tier is on recast or you lack the TP, the other tiers you know are
  tried.
- `//gs c aoewaltz` sends Divine Waltz II, or Divine Waltz when II is not
  available.

| Tier | TP | Missing HP | Level |
|---|---|---|---|
| Curing Waltz | 200 | under 200 | 15 |
| Curing Waltz II | 350 | 200-599 | 35 |
| Curing Waltz III | 500 | 600-1099 | 45 |
| Curing Waltz IV | 650 | 1100-1499 | 70 |
| Curing Waltz V | 800 | 1500+ | 87 |
| Divine Waltz | 400 | | 40 |
| Divine Waltz II | 800 | | 78 |

Levels are your DNC level, main or sub. These values are in
`shared/utils/dnc/waltz_manager.lua`.

## BLM, RDM and GEO: nukes, enfeebles, Aspir

Macro the tier you want. If it is on recast or you lack the MP, the next
lower tier that can go is cast instead (Fire V -> Fire IV -> ... -> Fire).
A tier you have not learned is skipped. When none can go, the cast is
cancelled and the recast of every tier is shown.

| Job | Spells |
|---|---|
| BLM | Nukes (Fire VI down to Fire), -ga III down to base, a -ja falls back to -ga III, Sleep, Sleepga, Bind, Bio, Poison, Drain, Aspir, Breakga to Break |
| RDM | Nukes (Fire to Water, V down to base). Dia, Bio, Distract, Frazzle, Blind, Slow, Paralyze, Poison, Addle, Sleep, Gravity, only while `EnfeebleTier` is On (Ctrl+Numpad9) |
| GEO | Nukes, -ra nukes (III down to base), Aspir (III down to Aspir) |

Enhancing spells never step down. The tier lists are in
`shared/data/spells/NUKE_TIERS.lua` and `RDM_ENFEEBLE_TIERS.lua` (RDM, GEO)
and `shared/jobs/blm/functions/logic/refiner/correspondence.lua` (BLM).

## Troubleshooting

- **Cure always casts what you macro'd**: check `CureAutoTier` in the HUD
  (Ctrl+Numpad4 to switch it On).
- **A party member's Cure is too small or too big**: their HP is an estimate
  (2000 max HP assumed). Raise or lower the thresholds in
  `WHM_CURE_CONFIG.lua`.
- **`//gs c waltz` says it needs DNC**: DNC must be your main job or subjob.
- **Waltz tier too high**: target the party member (F2-F6, or click) before
  pressing, so their missing HP can be read.
