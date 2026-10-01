# BST — Beastmaster

The page to open first when you play Beastmaster. It lists every key, every
command and every shared feature that works on BST, and where your files are.

- What each mode does, value by value: [states.md](states.md).
- Every set name the job reads, and the gear it puts on by itself: [sets.md](sets.md).

Keys are written Ctrl = `^`, Alt = `!`, Apps (the menu key) = `#`, Win = `@`.
Everything below comes from the provided template. After cloning, your own copies
live in `<YourName>/bst/`: if you changed them, your files win.

## Overview

- **Pet-aware gear.** Your idle and engaged gear is picked from two groups of
  sets: `sets.me` (you) and `sets.pet` (your pet). Which one depends on whether a
  pet is out, whether it is fighting, and the Pet Idle Mode you chose.
- **Pet watched every second.** From about 3 seconds after the job loads, the job
  checks your pet once per second. When the pet starts or stops fighting, your
  gear is refreshed.
- **Pet sent in by itself.** With Auto Pet Engage On (the default), when you are
  fighting and your pet is not, the job sends `/pet "Fight" <t>` (your current
  target). It repeats every second until the pet fights, so a Heel while you are
  engaged is undone within a second. Turn it Off to control the pet by hand.
- **Jugs by ecosystem and species.** Two keys pick an ecosystem, then a species.
  The jug (broth) of that pet goes into the ammo slot when you use Call Beast or
  Bestial Loyalty. The provided pet list holds 25 jug pets (see
  [Jug pets](#jug-pets)).
- **Ready moves.** Every Ready move puts on the Ready recast set first, with no
  recast check (the game counts the charges). When the order goes through, the pet
  damage set of the move's category (physical, multi-hit, magical attack, magical
  accuracy) stays on until the pet has finished the move. `//gs c rdylist` and
  `//gs c rdymove N` list and use the moves by number.
- **Town set.** In a town (Adoulin included, Dynamis excluded) the whole
  `sets.me.idle.Town` goes on while you are idle, pet out or not (`sets.Adoulin`
  instead in Adoulin, if you define one).
- **BST-HUD.** Loading BST unloads and reloads the separate `BST-HUD` addon (about
  3.5 s after the load); leaving BST unloads it. Nothing happens if you do not
  have that addon; `['bst-hud'] = false` in `_common/display/ADDONS_CONFIG.lua` leaves it alone.

Modes go back to their defaults at every job or subjob change: the ecosystem
starts again on **Aquan**, Auto Pet Engage on **On**.

## All keys on this job

| Key | What it does | Shown / active |
|---|---|---|
| Ctrl+Numpad1 | Main weapon: Aymur, Tauret (`WeaponSet`) | Always |
| Ctrl+Numpad2 | Off-hand or shield: Agwu's Axe, Adapa Shield, Diamond Aspis, Kraken Club (`SubSet`) | Always |
| Ctrl+Numpad3 | Pet Idle Mode: MasterPDT / PetPDT, who is protected while the pet is out and idle (`PetIdleMode`) | Always |
| Ctrl+Numpad4 | Auto Pet Engage: On / Off (`AutoPetEngage`) | Always |
| Ctrl+Numpad5 | Next ecosystem, rebuilds the species list (`//gs c ecosystem`) | Always |
| Ctrl+Numpad6 | Next species of the ecosystem; its jug is used by Call Beast (`//gs c species`) | Always |
| Ctrl+Numpad9 | Hybrid Mode: PDT / Normal (`HybridMode`) | Always |
| Apps+Numpad0 | Auto Medicine on / off (Echo Drops, Remedy... used when a debuff blocks your action) | Always (common key) |
| Alt+Numpad7 | Your other boxes follow you (press again to stop) | Always (common key) |
| Alt+Numpad8 | Your other boxes' automation on / off | Always (common key) |
| Alt+Numpad9 | Your other boxes mirror you | Always (common key) |
| Alt+Z | Sneak on you and every other box | Always (common key) |
| Alt+X | Invisible on you and every other box | Always (common key) |
| Alt+Numpad0 | Combat Mode on / off: keeps your weapons in place | **Hidden** until `//gs c combatmode show` |
| Alt+Numpad. (decimal) | Treasure Mode: Off / Tag / Full | **Hidden** until `//gs c th show`; the provided sets have no `sets.TreasureHunter`, so it equips nothing until you add one |
| Ctrl+F9 | Hybrid Mode, like Ctrl+Numpad9, with a chat line | Always (GearSwap's Mote library) |
| F12 | Refresh your gear now and print the current modes | Always (Mote) |
| F9, Alt+F9, Win+F9, Ctrl+F11, Ctrl+F12 | Mote's Offense / Ranged / Weaponskill / Casting / Idle modes | Always bound, but BST has only the `Normal` value for these: no effect |
| F10, F11, Ctrl+F10, Alt+F12, Alt+F10 | Mote's defense modes and Kiting | Always bound, but no effect on BST: the job builds its idle and engaged gear from `sets.me` / `sets.pet` and leaves Mote's defense and kiting layers out |
| Ctrl+- / Ctrl+= | Mote's target helpers (select NPC targets, party target mode) | Always (Mote) |
| Ctrl+F1-F8, Alt+F1-F8 | Temporary keys you make with `//gs c tb` | When you make one |
| Your choice | Your own modes from `BST_CUSTOM.lua` | The provided file adds none |

BST has no key that depends on the subjob: the same keys are bound with every
subjob. The HUD (`//gs c ui`) shows the keyed modes and their current values. When
two things want the same key, the chat says so at load; `//gs c kc` lists every
possible conflict.

## All commands on this job

Type them as `//gs c <command>`. Full list of the shared ones:
[commands guide](../../guides/commands.md).

**BST commands**

| Command | Effect |
|---|---|
| `ecosystem` | Next ecosystem; the species list and the jug choice restart on its first pet |
| `species` | Next species of the current ecosystem; prints how many of its jugs you carry (inventory and wardrobes) |
| `broth` (`broths`) | Counts, in your inventory only, the items with "Broth" in their name (jugs named Soil, Humus, Sap or Greens are not counted) |
| `pet engage` | `/pet "Fight" <t>` |
| `pet disengage` | `/pet "Heel" <me>` |
| `rdylist` | Your pet's Ready moves, numbered |
| `rdymove N` | Uses Ready move N. Pet fighting: the move at once. Pet idle and you fighting: `Fight` on a target you pick with the cursor (`<stnpc>`), the move 3.5 s later. Both idle: the same, then `Heel` 6 s after the start |
| `debugprecast` | On BST: turns on / off a trace of the summon and Ready precast gear (not the shared precast trace) |

**Shared commands that work here**

| Command | Effect |
|---|---|
| `ui` (and `ui save`, `ui theme`...) | Keybind HUD |
| `cyclestate <Mode>` / `cycle`, `set`, `toggle`, `reset` | Change a mode |
| `update` | Refresh your gear |
| `am [on/off]` | Auto Medicine |
| `checksets` | Set items you do not have with you |
| `wa` / `wo` | Wardrobe audit / wardrobe organizer |
| `rf` | Refill consumables from your Mog Case, Sack and Satchel (the common list, plus or instead of your `BST_REFILL.lua`) |
| `naked` | Remove every piece |
| `reload` | Reload the job file |
| `ls` / `dressup` | Lockstyle again / DressUp handling |
| `craft`, `fish`, `uncraft` | Crafting / fishing sets (your own set files) |
| `warp`, `w2`, `tph`, `rj`, `sd`... and `<command>all` | Warp spells, rings and destination items |
| `mount` | Random mount, or dismount |
| `stealth sneak / invi / both` | Sneak and Invisible on every box |
| `waltz` / `aoewaltz` | Curing / Divine Waltz, with /DNC only |
| `lightarts`, `darkarts`, `aoe sneak` / `aoe invi` / `aoe erase` | /SCH: Light / Dark Arts then the Addendum on the next press; Sneak / Invisible / Erase on the party with Accession |
| `smartbuff` | By default /WAR: Berserk, Aggressor, Warcry. /SAM: Hasso (two-handed weapon only) and Third Eye. /NIN: Utsusemi: Ni, else Ichi. /DNC: Haste Samba (350 TP). Only what is ready and not already up, 2 s apart; the rest is listed in chat. Other subjobs: a warning. The lists are yours to change: `subjob` in `_common/combat/SMARTBUFF_CONFIG.lua` ([configuration](../../guides/configuration.md)) |
| `!numpad-` | Jump Auto on / off, shown on /DRG only (see [commands](../../guides/commands.md#combat-helpers)) |
| `jump` | /DRG jumps |
| `dw [auto / none / haste / haste2 / max]` | Dual Wield tier (with /NIN or /DNC; needs `sets.DW` in your sets) |
| `belt` | Obi / Orpheus status (used on Primal Rend and Cloudsplitter) |
| `th [show / hide / key]` | Treasure Mode on BST |
| `combatmode [show / hide / key]` | Combat Mode on BST |
| `tb` | Temporary keys |
| `kc` | Every key conflict of this job |
| `watchdog` | Midcast watchdog |
| `debugmidcast` | Show which midcast set each subjob spell uses |
| `info <name>` | Details of an ability, spell or weaponskill |
| `jamsg` / `spellmsg` / `wsmsg` | How much chat each action prints |
| `alts ...`, `main`, `altcmds`, `alt <name>` | Dual-box orders |
| `syscheck`, `fulltest`, `trace`, `help`, `commands` | Checks and help |

## Shared features on this job

| Feature | On BST |
|---|---|
| Movement speed (AutoMove) | `sets.MoveSpeed` goes on while you run, idle only, outside town |
| Town set (BST's own) | `sets.me.idle.Town` in towns (`sets.Adoulin` in Adoulin if defined), idle only, on top of the pet or master set, under your weapons |
| Action guard | An action you cannot do (silenced, amnesia, stunned...) is stopped before any gear swaps |
| Auto Medicine | Uses the right remedy item when a debuff blocks your action, if the mode is On |
| Recast check | An ability or spell still on recast is stopped with the time left. Ready moves are never checked |
| Weaponskills | Stopped under 1000 TP. Moonshade Earring goes on by itself when it carries your TP to the next step (from `BST_TP_CONFIG.lua`, Fencer counted) |
| Obi / Orpheus | Put on by themselves for Primal Rend and Cloudsplitter when you own them and the belt system is on |
| Doom | `sets.buff.Doom` goes on while you are doomed |
| Subjob magic | Healing, Enhancing, Enfeebling, Elemental and Blue Magic use the shared midcast rules; any other skill (Ninjutsu, Dark Magic...) is sent to the same rules afterwards. The provided sets have no midcast sets, so nothing changes until you add some |
| Midcast watchdog | Puts your normal gear back if a spell's end is lost. Set your Fast Cast % in `BST_STATES.lua` (`FastCast`) for its timing |
| Dual Wield tiers | Off until you add `sets.DW` (an example is commented in the provided sets) |
| Treasure Mode | Hidden and Off; needs `sets.TreasureHunter` |
| Combat Mode | Hidden and Off; when shown and On, main, sub and range stay in place |
| Your own modes and rules | `BST_CUSTOM.lua` (empty in the template) |
| Lockstyle | Style 6 about 8 s after the load, for every subjob |
| Macro book | Book 12 page 1. With a dual-box partner on GEO and you /DNC: book 13; partner on COR and /DNC: book 14 |
| Dual-box | Your job and your other box's job are exchanged at each load (macro book above, alt commands) |
| Warp, mount, stealth, refill, wardrobe tools | As on every job |
| Keys re-sent | Your keys are sent again 2 s after each load, in case the first bind was lost |

## Jug pets

The provided `BST_PET_DATA.lua` knows these pets (ecosystem, species, jug). Only
pets in this list can be chosen with the keys. The order inside an ecosystem is
not the order of the file.

| Ecosystem | Species | Pet | Jug |
|---|---|---|---|
| Aquan | Crab | Jovial Edwin | Pungent Broth |
| Aquan | Fish | Amiable Roche | Airy Broth |
| Amorph | Acuex | Fluffy Bredo | Venomous Broth |
| Amorph | Slime | Sultry Patrice | Putrescent Broth |
| Amorph | Leech | Fatso Fargann | C. Plasma Broth |
| Amorph | Slug | Generous Arthur | Dire Broth |
| Beast | Tiger | Blackbeard Randy | Meaty Broth |
| Beast | Sheep | Rhyming Shizuna | Lyrical Broth |
| Beast | Rabbit | Pondering Peter | Vis. Broth |
| Beast | Raaz | Vivacious Vickie | Tant. Broth |
| Bird | Colibri | Choral Leera | Glazed Broth |
| Bird | Hippogryph | Daring Roland | Feculent Broth |
| Bird | Tulfaire | Swooping Zhivago | Windy Greens |
| Lizard | Lizard | Warlike Patrick | Livid Broth |
| Lizard | Eft | Suspicious Alice | Furious Broth |
| Plantoid | Funguar | Brainy Waluis | Crumbly Soil |
| Plantoid | Mandragora | Sweet Caroline | Aged Humus |
| Vermin | Chapuli | Bouncing Bertha | Bubbly Broth |
| Vermin | Ladybug | Threestar Lynn | Muddy Broth |
| Vermin | Fly | Headbreaker Ken | Blackwater Broth |
| Vermin | Beetle | Energized Sefina | Gassy Sap |
| Vermin | Diremite | Anklebiter Jedd | Crackling Broth |
| Vermin | Mosquito | Left-Handed Yoko | Heavenly Broth |
| Vermin | Antlion | Cursed Annabelle | Creepy Broth |
| Vermin | Weevil | Weevil Familiar | T. Pristine Sap |

To add a pet: add it to `BST_PET_DATA.lua` and give it a set named after it with
its jug, `sets['Name (Species)'] = {ammo = '<jug>'}`, in your sets file.

## Configuration files for this job

All in `<YourName>/bst/` (plain Lua files; `//gs c reload` after an edit).

| File | What it holds |
|---|---|
| `BST_STATES.lua` | Modes, their values and defaults (weapons, Hybrid Mode, Pet Idle Mode, Auto Pet Engage, starting ecosystem, Fast Cast %) |
| `BST_KEYBINDS.lua` | The job keys above |
| `BST_CUSTOM.lua` | Your own modes, keys and gear rules ([keybinds guide](../../guides/keybinds.md)) |
| `BST_PET_DATA.lua` | The jug pet list (pet, jug, species, ecosystem) |
| `BST_TP_CONFIG.lua` | TP bonus pieces (Moonshade Earring) and your Fencer job point gifts |
| `BST_LOCKSTYLE.lua` | Lockstyle number, per subjob if you want |
| `BST_MACROBOOK.lua` | Macro book and page, per subjob and per dual-box partner job |
| `BST_HUD.lua` | Order of the HUD sections and rows on BST |
| `BST_REFILL.lua` | What `//gs c rf` restocks on BST on top of or in place of the common list (every line commented in the generic template: the common list) |
| `BST_ECOSYSTEM_DATA.lua` | Ecosystem strengths and weaknesses. Nothing reads it today |

Your sets are in `<YourName>/bst/bst_sets.lua`. Files shared by every job
(common keys, Combat Mode, Treasure Mode, belts, Dual Wield...) are in
`<YourName>/_common/`: see the [configuration guide](../../guides/configuration.md).

## See also

- [states.md](states.md): each mode and value in detail.
- [sets.md](sets.md): set names and automatic gear.
- [Keybinds guide](../../guides/keybinds.md), [commands guide](../../guides/commands.md),
  [set names guide](../../guides/sets.md).
