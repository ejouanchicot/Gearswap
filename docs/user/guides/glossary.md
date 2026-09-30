# Glossary

Words used in these docs, in alphabetical order. FFXI terms are the game's;
GearSwap terms are the addon's or this setup's. For the whole flow, read
[how it works](how-it-works.md).

| Term | Meaning |
|---|---|
| **Aftercast** | The moment after an action ends. Your idle or engaged set comes back. See [how it works](how-it-works.md#3-aftercast-back-to-normal) |
| **Aftermath** | FFXI: a buff given by a weaponskill of a Relic, Mythic, Empyrean or Aeonic weapon. Some jobs change their engaged set while it is up (`AM3` = Aftermath: Lv.3) |
| **Alt** | In a [dual-box](dualbox.md), the character driven from the main: it receives alt commands and `alts` orders. The opposite of **main** |
| **Alt command** | A short `//gs c <name>` typed on the main that the alt performs (`//gs c haste`). Listed by `//gs c altcmds` |
| **Augments** | FFXI: extra stats on a piece of gear. A set must give them exactly (`augments = {...}`) for GearSwap to pick the right copy |
| **Auto Medicine** | This setup: an Echo Drops, Remedy or Panacea used for you when a debuff blocks your action. `//gs c am`, Apps+Numpad0 |
| **Bag** | FFXI: an inventory container. Gear can be worn from the inventory and the 8 wardrobes only, not from the Mog Safe, Storage, Locker, Satchel, Sack or Case |
| **Box**, **box group** | One game window (one character). The box group is every character of your dual-box setup (`group` in `DUALBOX_CONFIG.lua`) |
| **Casting Mode** | A Mote-Include mode. Its value `Resistant` picks the `.Resistant` child of a spell set ([set names](sets.md#casting-mode-resistant-children)) |
| **Clone script** | `clone_character.py` (`CLONE_CHARACTER.bat`): builds your `<YourName>/` folder from the templates ([installation](../getting-started/installation.md)) |
| **Combat Mode** | This setup: On keeps your weapons where they are (no set swaps them), so you keep your TP. `//gs c combatmode` |
| **Cooldown**, **recast** | FFXI: the wait before an ability or spell can be used again. An action on recast is cancelled before any gear moves |
| **CUSTOM file** | `<job>/keys/<JOB>_CUSTOM.lua`: your own modes, keys and gear rules without code. Its gear goes on last ([keybinds](keybinds.md#your-own-modes-job_customlua)) |
| **Debuff** | FFXI: a harmful status (Silence, Paralysis, Doom...). Some block actions: see [how it works](how-it-works.md#1-precast-checks-then-the-start-set) |
| **Doom** | FFXI: a countdown that kills when it ends. `sets.buff.Doom` goes on and neck, rings and waist stay locked until it is gone |
| **Dual-box** | Playing two (or more) characters on one PC. This setup exchanges jobs, sends alt commands and group orders ([dual-box](dualbox.md)) |
| **DW** (Dual Wield) | FFXI: the trait that lets you hold a weapon in each hand; its gear lowers the delay. With enough haste you need less of it: `sets.DW.<tier>` picks the pieces by your magic haste (`//gs c dw`) |
| **Engaged** | FFXI: your weapon is out and you are fighting. The engaged set is worn |
| **FC** (Fast Cast) | FFXI: gear stat that shortens casting time, capped at 80 %. Worn at precast, in `sets.precast.FC` |
| **Fast Recast** | Gear worn during a spell to shorten the next recast. `sets.midcast.FastRecast` goes on under every spell set |
| **HUD** | The on-screen box listing the job's keys and the current value of each mode. `//gs c ui` ([HUD](../features/ui.md)) |
| **Hybrid Mode** | The usual name of a job's damage-taken mode: `PDT` (defensive) or an offensive value (the job's page lists them). Ctrl+Numpad9 on most jobs |
| **Idle** | FFXI: standing, weapon sheathed. The idle set is worn |
| **JA** (Job Ability) | FFXI: an ability (Provoke, Berserk, Phantom Roll...). Its set is `sets.precast.JA['Name']` |
| **Job file**, **entry file** | `<YourName>/<YourName>_<JOB>.lua`, the file GearSwap loads for your current job |
| **Keybind** | A key that sends a command. Keys are bound when the job loads ([keybinds](keybinds.md)) |
| **Lockstyle** | FFXI: `/lockstyleset <n>`, shows a saved outfit whatever you really wear. Sent 8 s after each load, again with `//gs c ls` |
| **Macro book** | FFXI: a book of macro pages. The job's `<JOB>_MACROBOOK.lua` picks the book and page for your subjob (and your partner's job) |
| **Main** | 1. Main job: your job, as opposed to the subjob. 2. In a dual-box, the character you play, which drives the alts. `//gs c main` makes a character the main |
| **MB** (Magic Burst) | FFXI: a nuke cast on a skillchain, for extra damage. Mage jobs have a mode for their burst set |
| **Midcast** | While a spell is being cast (or a ranged shot flies): the set that boosts its effect goes on. See [how it works](how-it-works.md#2-midcast-the-effect-set-spells-and-ranged-attacks) |
| **Mode**, **state** | A choice with a few values (a weapon, Hybrid Mode, a nuke element) that decides which set is worn. Cycled by a key or `//gs c cyclestate <Mode>` |
| **Mote**, **Mote-Include** | The GearSwap library (by Motenten) every job file of this setup is built on: it picks sets by name and provides modes and F9-F12 keys |
| **Obi**, **Orpheus** | Hachirin-no-Obi and Orpheus's Sash: belts that raise elemental damage (by day / weather, or by distance). Put on by themselves when they help (`//gs c belt`) |
| **Precast** | The moment you press an action: checks, then the start set (Fast Cast for spells, the ability or weaponskill set). See [how it works](how-it-works.md#1-precast-checks-then-the-start-set) |
| **Refill** | `//gs c rf`: consumables taken from the Mog Case / Sack / Satchel up to a target count, the surplus put back |
| **Set** | A table of gear, one item per slot, under a name (`sets.idle`, `sets.precast.WS['Savage Blade']`). A slot a set leaves out keeps what you wear. See [set names](sets.md) |
| **`set_combine`** | Builds a set from another: `set_combine(sets.idle, { feet = "..." })` = the idle set with other feet |
| **Slot** | One of the 16 gear places: main, sub, range, ammo, head, neck, ear1, ear2, body, hands, ring1, ring2, back, waist, legs, feet |
| **Slot lock** | A slot GearSwap leaves alone whatever the set says (Combat Mode, Doom, craft...) |
| **Subjob** | FFXI: your second job (`/NIN`, `/SAM`...). A subjob change reloads the job file 0.5 s later |
| **Tag** | Treasure Hunter: a mob is tagged once one of your actions lands on it with TH gear on; after that your normal gear can come back |
| **Template** | The files in `_master/` the clone script copies from. The game reads them only for the alt commands, when your `_common/dualbox/alt/` lacks a file |
| **TH** (Treasure Hunter) | FFXI: raises the drop rate of the mob it is applied to. `sets.TreasureHunter` and Treasure Mode (`//gs c th`) |
| **Town set** | `sets.idle.Town` (or `sets.Adoulin`), worn idle in a town on top of the idle set |
| **TP** (Tactical Points) | FFXI: built by fighting, spent by weaponskills (1000 minimum, 3000 maximum). TP bonus gear adds to the TP a weaponskill counts |
| **Wardrobe** | FFXI: the 8 bags you can wear gear from, besides the inventory. `//gs c wo` sorts them |
| **Watchdog** | This setup: puts your gear back when the game never confirms the end of a cast ([watchdog](../features/watchdog.md)) |
| **WS** (Weaponskill) | FFXI: a special attack that uses TP. Its set is `sets.precast.WS['Name']` |
| **`//gs c`** | Sends a command to GearSwap's job file (`//gs c reload`). In a macro: `/console gs c reload` |

Key notation: `^` Ctrl, `!` Alt, `@` Windows, `#` Apps (menu key), `~` Shift;
`^numpad1` = Ctrl+Numpad1.
