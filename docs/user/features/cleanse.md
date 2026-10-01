# Cleanse (`//gs c cleanse`)

One command takes the debuffs off you **and** off every other character of
your box group. Each character looks at its own debuffs, most urgent first,
and uses the best way it has at that moment: its own spell, a partner's
spell, or an item.

Works for every job. With no box group (no dual-box), it covers you alone.
There is no key for it by default: put `/console gs c cleanse` in a macro, or
remove the `--` of the Alt+C line already written (commented) in
`_common/keys/COMMON_KEYBINDS.lua` ([keybinds](../guides/keybinds.md)), or bind
one with `//gs c tb`.

## Requirements

- The Windower **`send`** addon on every character of the group, as for the
  rest of the [dual-box](../guides/dualbox.md) layer.
- Items are used from the **inventory** only.
- `_common/combat/CLEANSE_CONFIG.lua` is optional: without it the defaults
  below apply. A folder cloned before 2026-10-01 does not have it: copy
  `_master/config_global/CLEANSE_CONFIG.lua` into `_common/combat/`.

## Commands

| Command | What it does |
|---|---|
| `//gs c cleanse` | You and every other character of the group |
| `//gs c cleanse self` | You only |
| `//gs c cleanse check` | What it would do now, per debuff. Nothing is used |
| `//gs c cleanse help` (or any other word) | Help |

Each character sends what it did back to the one where you typed the command,
which shows one `CLEANSE` block per character: each debuff and the way chosen
(`Paralyna`, `Paralyna from Kaories, else Remedy`, `Echo Drops`...), or
`Debuffs: none`. The block is the plan made when you press: with three
erasable debuffs it says `Panacea` three times, but only one is used (see
below).

## What each character does, per debuff

In the order of the table below (or yours, see `first`):

1. **Its own spell**, cast on itself, when it can cast it right now: spell
   learned, main or sub job with the level, enough MP, off recast, not
   silenced (Silence, Mute and Omerta stop every spell). When the spell comes
   from Scholar (SCH main, or SCH sub when the main job does not have it),
   the -na spells and Erase need **Addendum: White** up.
2. **A partner's spell**: the other characters whose job may have the spell
   (a main job that learns it; a WHM, RDM or PLD subjob when it learns it
   by level 49, never a SCH subjob; a character whose job is not known yet
   is asked too) are asked to cast it on this character. Each casts it only if it can right now.
   `partner_wait` seconds later (5), if the debuff is still on, the item
   goes.
3. **Its own item**, the first of the list it has in its inventory.
   **Doom**: Holy Water again while Doom stays, up to `doom_tries` (5) in all.
   Each new Holy Water goes right after the previous one, before the other
   debuffs.

Its own spell and its item are decided when their turn comes: if the debuff
is already gone by then (a Panacea took every erasable debuff off, an Erase
or a partner's spell landed), nothing is used for it. So one Panacea covers
all the erasable debuffs.

Asleep, petrified, stunned, terrified or charmed, a character cannot act:
only a partner can help (Cure wakes, Stona). A debuff with no spell and no item
shows `nothing removes it`.

When an item is used up and the debuff is still there (a geomancy aura keeps
it on you), that debuff is left alone (`left alone (item had no effect:
aura?)`) until it is gone, or 60 s at most. The same mark is used by
[Auto Medicine](../guides/commands.md#modes). Not for Doom: Holy Water fails
two times in three.

Actions go one after the other: each waits for the game to say the previous
one ended, plus 1 s. A spell or item the game refused as too early is sent
again (3 sends at most). `//gs c stealth` uses the same queue, so both pressed
together do not step on each other.

## Every debuff and what removes it

From `shared/data/debuffs/DEBUFF_REMOVAL.lua`. **Key** is the name used in
`CLEANSE_CONFIG.lua` (`skip`, `first`, `items`). Ids 539-567 are the same
effects from a geomancy aura.

| Key | Debuff | Buff ids | Spell | Default items |
|---|---|---|---|---|
| `doom` | Doom | 15 | Cursna | Holy Water |
| `petrification` | Petrification | 7 | Stona (partner only) | - |
| `sleep` | Sleep | 2, 19 | Cure (partner only) | - |
| `lullaby` | Lullaby | 193 | Cure (partner only) | - |
| `stun` | Stun | 10 | - (cannot act) | - |
| `terror` | Terror | 28 | - (cannot act) | - |
| `charm` | Charm | 14, 17 | - (cannot act) | - |
| `silence` | Silence | 6 | Silena (partner: you are silenced) | Echo Drops, Remedy |
| `paralysis` | Paralysis | 4, 566 | Paralyna | Remedy |
| `curse` | Curse | 9, 20 | Cursna | Holy Water |
| `amnesia` | Amnesia | 16 | - | - |
| `mute` | Mute | 29 | - | - |
| `omerta` | Omerta | 262 | - | - |
| `impairment` | Impairment | 261 | - | - |
| `muddle` | Muddle | 473 | - | - |
| `bane` | Bane | 30 | - | - |
| `plague` | Plague | 31 | Viruna | - |
| `disease` | Disease | 8 | Viruna | - |
| `blindness` | Blindness | 5 | Blindna | Eye Drops, Remedy |
| `poison` | Poison | 3, 540 | Poisona | Antidote, Remedy |
| `slow` | Slow | 13, 565 | Erase | Panacea |
| `weight` | Weight | 12, 567 | Erase | Panacea |
| `bind` | Bind | 11 | Erase | Panacea |
| `addle` | Addle | 21 | Erase | Panacea |
| `flash` | Flash | 156 | Erase | Panacea |
| `inhibit_tp` | Inhibit TP | 168 | Erase | Panacea |
| `max_hp_down` | Max HP Down | 144 | Erase | Panacea |
| `max_mp_down` | Max MP Down | 145 | Erase | Panacea |
| `max_tp_down` | Max TP Down | 189 | Erase | Panacea |
| `attack_down` | Attack Down | 147, 557 | Erase | Panacea |
| `defense_down` | Defense Down | 149, 558 | Erase | Panacea |
| `accuracy_down` | Accuracy Down | 146, 561 | Erase | Panacea |
| `evasion_down` | Evasion Down | 148, 562 | Erase | Panacea |
| `magic_atk_down` | Magic Atk. Down | 175, 559 | Erase | Panacea |
| `magic_def_down` | Magic Def. Down | 167, 560 | Erase | Panacea |
| `magic_acc_down` | Magic Acc. Down | 174, 563 | Erase | Panacea |
| `magic_eva_down` | Magic Evasion Down | 404, 564 | Erase | Panacea |
| `str_down` | STR Down | 136 | Erase | Panacea |
| `dex_down` | DEX Down | 137 | Erase | Panacea |
| `vit_down` | VIT Down | 138 | Erase | Panacea |
| `agi_down` | AGI Down | 139 | Erase | Panacea |
| `int_down` | INT Down | 140 | Erase | Panacea |
| `mnd_down` | MND Down | 141 | Erase | Panacea |
| `chr_down` | CHR Down | 142 | Erase | Panacea |
| `elegy` | Elegy | 194 | Erase | Panacea |
| `requiem` | Requiem | 192 | Erase | Panacea |
| `nocturne` | Nocturne | 223 | Erase | Panacea |
| `helix` | Helix | 186 | Erase | Panacea |
| `burn` | Burn | 128 | Erase | Panacea |
| `frost` | Frost | 129 | Erase | Panacea |
| `choke` | Choke | 130 | Erase | Panacea |
| `rasp` | Rasp | 131 | Erase | Panacea |
| `shock` | Shock | 132 | Erase | Panacea |
| `drown` | Drown | 133 | Erase | Panacea |
| `bio` | Bio | 135 | Erase | Panacea |
| `dia` | Dia | 134 | Erase | Panacea |

Who can cast each spell (levels from the game data): WHM main or sub, and
SCH under Addendum: White (a SCH subjob only for itself, never asked as a
partner). Poisona WHM 6 / SCH 10, Paralyna 9 / 12,
Blindna 14 / 17, Silena 19 / 22, Cursna 29 / 32, Erase 32 / 39, Viruna 34 /
46, Stona 39 / 50. Cure: WHM 1, RDM 3, PLD 5, SCH 5.

## Settings (`_common/combat/CLEANSE_CONFIG.lua`)

Every key and its default. A key you remove goes back to its default; the
file is read at load, so `//gs c reload` after an edit.

| Key | Default | What it does |
|---|---|---|
| `use_spells` | `true` | This character's own spell before an item |
| `ask_partner` | `true` | Ask a partner that may have the spell before using an item |
| `partner_wait` | `5` | Seconds given to the partner's spell before the item goes |
| `doom_tries` | `5` | Holy Waters in all while Doom stays |
| `skip` | `{}` | Debuffs never touched, e.g. `{'dia', 'bio'}` (keys of the table above) |
| `first` | `{}` | Debuffs taken off before the others, in this order, e.g. `{'silence'}` |
| `items` | see below | Items per debuff, tried in order |

`items` holds one list per key of the table above; `erasable` covers every
debuff whose spell is Erase. A debuff not listed uses its default items. The
template:

```lua
items = {
    doom      = {'Holy Water'},
    curse     = {'Holy Water'},
    silence   = {'Echo Drops', 'Remedy'},
    paralysis = {'Remedy'},
    blindness = {'Eye Drops', 'Remedy'},
    poison    = {'Antidote', 'Remedy'},
    erasable  = {'Panacea'},
},
```

One item can take several debuffs off: a **Remedy** removes Blind, Paralysis,
Poison and Silence at once (a Remedy Ointment only one, at random), a
**Panacea** every erasable debuff at once. When two or more debuffs a Remedy
covers are on, the Remedy of the list goes first (Silence + Paralysis: one
Remedy, not Echo Drops then Remedy); Auto Medicine does the same. With one of
them alone, the list order holds (Echo Drops for Silence alone).

## Troubleshooting

| Symptom | Try |
|---|---|
| Nothing happens on the other characters | The `send` addon on every character, and all of them in your box group ([dual-box](../guides/dualbox.md)) |
| A character does not cast its spell | `//gs c cleanse check` on it: level, MP, recast, silence, and Addendum: White for a Scholar |
| An item is not used | It must be in the inventory (not a Mog Case or wardrobe) |
| `left alone (item had no effect: aura?)` | You stand in an aura: move out, or wait up to 60 s |
| Want to see resends | `//gs c trace on`: a refused action sent again writes a `CLEANSE` line in `<YourName>/trace.log` |
