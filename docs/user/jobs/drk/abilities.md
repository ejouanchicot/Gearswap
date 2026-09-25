# DRK — job abilities

Which DRK abilities get their own gear, and how Dark Seal and Nether Void change the
gear that follows them. Set names below are the ones in the template set file
(`_master/sets/drk_sets.lua`); the items are the template's, put your own.

## Ability gear (precast)

Worn for the instant the ability goes off (`sets.precast.JA['<Name>']`):

| Ability | Template piece |
|---|---|
| Blood Weapon | body: Fallen's Cuirass +3 |
| Arcane Circle | feet: Ignominy Sollerets +2 |
| Last Resort | feet: Fallen's Sollerets +3, back: Ankou's Mantle (STP) |
| Weapon Bash | hands: Ig. Gauntlets +3 |
| Souleater | head: Ignominy Burgeonet +2 |
| Dark Seal | head: Fallen's Burgeonet +3 |
| Diabolic Eye | hands: Fall. Fin. Gaunt. +3 |
| Nether Void | legs: Heath. Flanchard +3 |
| Jump, High Jump (/DRG) | your engaged set |

An ability with no `sets.precast.JA` entry simply keeps your current gear.

## Dark Seal and Nether Void

Both buffs are used up by the next dark spell, so the project follows them closely:

- **Dark Magic midcast.** While the Dark Seal buff is on, `sets.buff['Dark Seal']`
  (template: head) goes on for every Dark Magic spell. While Nether Void is on,
  `sets.buff['Nether Void']` (template: legs) goes on for Absorb, Drain and Aspir
  spells only (not Dread Spikes). This reads the real buff list.
- **Engaged gear.** The buff reaches GearSwap's buff list a moment after the ability
  goes out. To bridge that gap, using Dark Seal or Nether Void raises a "pending" flag
  at once. The flag is confirmed when the ability completes, dropped if it was
  interrupted, and cleared when the buff wears off. While the buff or its flag is on,
  pieces from `sets.engaged.<Weapon>.<PDT|Accu>.DarkSealNetherVoid` (both buffs),
  `.DarkSeal` or `.NetherVoid` are added on top of your engaged set, if you defined them.
  Without these variants nothing changes.

## Where it lives

| File | Role |
|---|---|
| `<YourChar>/sets/drk_sets.lua` | `sets.precast.JA`, `sets.buff['Dark Seal']`, `sets.buff['Nether Void']`, engaged variants |
| `shared/jobs/drk/functions/DRK_PRECAST.lua` | Raises the pending flags |
| `shared/jobs/drk/functions/DRK_AFTERCAST.lua` | Confirms or drops them |
| `shared/jobs/drk/functions/DRK_BUFFS.lua` | Clears them when the buff wears |
| `shared/jobs/drk/functions/DRK_MIDCAST.lua` | Dark Seal / Nether Void midcast pieces |
| `shared/jobs/drk/functions/logic/drk_buff_anticipation.lua` | Engaged variants |
