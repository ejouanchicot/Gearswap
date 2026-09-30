# How it works

What this GearSwap setup does for you, in plain words: what happens when you
press an action, when your gear changes by itself, what the HUD and the chat
lines mean, which files are yours and when to reload. No code needed to read
it. Words you do not know are in the [glossary](glossary.md).

## The big picture

GearSwap is a Windower addon that changes your equipment for you. It reads
one file per job, `<YourName>/<YourName>_<JOB>.lua`, which loads:

- **your files** in `<YourName>/`: your gear (`<job>/sets/<job>_sets.lua`) and your
  settings (`config/`);
- **the shared code** in `shared/`, the same for every character and every
  job: it decides which of your sets to wear, and when.

You describe gear by giving sets the right **names**
([set names](sets.md)); the shared code picks the set by its name at the right
moment. You never write code to get a set worn.

## When you press an action

Every spell, job ability, weaponskill, ranged attack or item goes through up
to three steps. GearSwap changes your gear at each one, then the game carries
out the action.

```
 you press        precast            midcast              aftercast
 the action  -->  (checks, then  --> (spells and     -->  (idle or engaged
                  the start set)     ranged shots:        set comes back)
                                     the effect set)
```

### 1. Precast: checks, then the start set

Before any gear moves, the action is checked. When a check fails, the action
is **cancelled**: no gear moves and a chat line says why.

1. **Can you act at all?** Silence, Mute or Omerta block spells; Amnesia or
   Impairment block abilities and weaponskills; Paralysis blocks abilities
   (not weaponskills: the game rolls for those); Stun, Sleep, Petrification
   and Terror block everything. With [Auto Medicine](commands.md#modes) on,
   an Echo Drops or Remedy is used for Silence before a spell, a Remedy or
   Panacea for Paralysis before an ability.
2. **Is it ready?** An ability or spell still on recast is cancelled with the
   time left. A recast of 2 s or less counts as ready (the game and GearSwap
   do not agree to the tenth of a second: `common/RECAST_CONFIG.lua`).
   Some jobs step a spell down instead of cancelling it: a Cure, a nuke or an
   enfeeble on recast (or too expensive) becomes a lower tier
   ([auto-tier](../features/auto-tier-system.md)).
3. **Weaponskills**: the target must be in range and you need 1000 TP.
   Then the TP bonus pieces are chosen (a Moonshade Earring when its
   extra TP helps, for example: [TP bonus](../jobs/war/tp-bonus.md)).
4. **The precast set goes on**: `sets.precast.FC` (Fast Cast) for a spell,
   `sets.precast.JA['Name']` for an ability, `sets.precast.WS['Name']` for a
   weaponskill. For an ability or a weaponskill this is the set that counts:
   the effect happens now.
5. **Last layers**, in this order: the Obi / Orpheus belt when it helps
   (elemental weaponskills), Treasure Hunter gear on a mob not yet tagged,
   then your own `<JOB>_CUSTOM.lua` rules, which win over everything.

Some jobs also fire a job ability for you just before the action (for
example Entrust before an Indi- spell on a party member). Most of these are
off until you turn them on in `common/AUTO_ABILITIES.lua`.

### 2. Midcast: the effect set (spells and ranged attacks)

While a spell is being cast, the set that boosts its effect goes on:

1. `sets.midcast.FastRecast` first, if you have one, under everything else;
2. the most precise set your file has for this spell: its exact name, then
   the name without the tier, then the job's own variants (a mode, the
   target), then its family, then its magic skill
   ([how a name is chosen](sets.md#how-a-name-is-chosen));
3. the same last layers as precast: belt, Treasure Hunter, your CUSTOM rules.

`//gs c debugmidcast`, then cast: the chat says which set was chosen and why.

Job abilities and weaponskills have no midcast: they go straight from precast
to aftercast.

### 3. Aftercast: back to normal

When the game says the action is over, your normal set comes back: the idle
set if you are standing, the engaged set if your weapon is out. If the game
never says so (packet loss in a laggy zone), the
[midcast watchdog](../features/watchdog.md) puts it back after the cast time
plus 1.5 s.

## How the idle and engaged sets are built

Your "normal" set is rebuilt from pieces each time it goes on:

1. the base: `sets.idle` or `sets.engaged`, or the variant of your current
   mode (`sets.idle.PDT`, `sets.engaged.Acc`...: the job's page lists its
   modes). On DNC, DRK, THF and WAR, the idle variant outside town follows
   the Hybrid Mode: `sets.idle.PDT` in PDT when that set exists;
2. the town set in a town (`sets.idle.Town`, `sets.Adoulin`), on top of the
   idle set;
3. your weapons, from the weapon modes;
4. the job's own layers (a buff up, Aftermath, a pet...);
5. `sets.MoveSpeed` while you run, idle only;
6. Dual Wield pieces, engaged with two weapons (`sets.DW...`, by your haste);
7. Treasure Hunter gear while a mob is not tagged, if Treasure Mode is on;
8. your `<JOB>_CUSTOM.lua` rules, last.

Each job has its own order and exceptions: see its `sets.md` page.

## When your gear changes by itself

Besides your actions, the normal set is rebuilt when:

| Event | What changes |
|---|---|
| You draw or sheathe your weapon, or rest | Engaged, idle or resting set. If it happens during an action (a roll, a spell), it waits for the action to end, 3 s at most |
| You start or stop running | `sets.MoveSpeed` on or off (idle only; movement is not tracked while engaged) |
| You zone or teleport | The set is rebuilt at once (town or field set) |
| A mode changes (key, `cyclestate`, `set`, `toggle`) | The set of the new value |
| A buff comes or goes | Doom: `sets.buff.Doom`, with neck, rings and waist locked until it is gone. Haste changes: a new Dual Wield tier. Each job has its own (Aftermath, Hasso, a pet...) |
| A mob you tagged dies, or you zone | Treasure Hunter tags are forgotten |
| The job loads | Everything, from zero (see below) |

`//gs c update` (or F12) rebuilds the normal set whenever you want.

Some slots stay **locked**, whatever the set says: your weapons with Combat
Mode On, Doom slots while Doomed, the craft set, a warp ring while it is used,
all slots while the wardrobe organizer runs. See the
[FAQ](faq.md#gear) to unlock them.

## Modes and keys

A **mode** is a choice with a few values (Hybrid Mode: `PDT` / `Normal`, a
weapon, a nuke element...). Sets are chosen by the mode's current value. Each
job's modes are on its page ([jobs](../jobs/README.md)).

- Keys cycle modes: Ctrl+Numpad for the job's modes, Apps+Numpad for extra
  ones, Alt+Numpad7-9 for dual-box orders, Alt+Z / Alt+X for Sneak and
  Invisible ([keybinds](keybinds.md)).
- A key sends a GearSwap command (`//gs c cyclestate HybridMode`): anything a
  key does, you can type or put in a macro (`/console gs c ...`).
- Every mode goes back to its default on each load (job change, subjob
  change, reload), except Auto Medicine. Change a default in
  `<job>/<JOB>_STATES.lua`.
- Your own modes, with their own key and gear, go in `<JOB>_CUSTOM.lua`
  ([keybinds](keybinds.md#your-own-modes-job_customlua)).

## The HUD

The box on screen lists every key of the current job, what it changes and the
current value (`^numpad9  Hybrid Mode  PDT`). It updates as soon as a mode
changes. It shows only the keys that apply to your current subjob. A key shown
in red conflicts with another action on the same key (`//gs c kc` explains).
`//gs c ui` shows or hides it; everything else is on the
[HUD page](../features/ui.md).

## The chat lines

Everything the setup prints goes through one message system, in the same
format (a `[JOB]` tag, coloured values, separators that follow your chat
width):

| You see | Means |
|---|---|
| A block at load (`WAR SYSTEM LOADED`) | The job loaded, with its keys |
| The name of a job ability, spell or weaponskill, with details | What you just used. `//gs c jamsg` / `spellmsg` / `wsmsg` `full`, `on` (name only) or `off` choose how much, per character |
| A line with a time (`ready in 0:42`) | The action was refused on recast |
| A line naming a debuff | The action was blocked (silence, amnesia...), and what Auto Medicine did |
| `Not enough TP` | A weaponskill below 1000 TP was cancelled |
| A `KEYS` block | Two actions share a key on this job / subjob / partner job |
| A `<JOB> keybinds: ...` or `<JOB>_CUSTOM: ...` line | A mistake in your keybind or custom file, with the entry |
| `GearSwap has detected an error in the user function` | A Lua error, usually in a file you edited: the line is named |

## Your files and the shared code

| Folder | Whose | Changed by |
|---|---|---|
| `<YourName>/` | **Yours**: entry files, `sets/`, `config/` | You, and a few commands that save settings (`ui`, `jamsg`, `combatmode`, `th`, `stealth`, `tb`...) |
| `shared/` | The shared code, the same for everyone | An update of the setup only |
| `_master/` | The templates the clone script copies from | An update only. In game only the alt-command files are read from there, when yours are missing |

Edit only `<YourName>/`. An update replaces `shared/` and `_master/` and does
not touch your folder (new options in the templates are not added to your
files: compare them with `_master/` if you want them). The clone script
builds `<YourName>/` once; running it again keeps a backup of the old folder
([installation](../getting-started/installation.md)). What each file of
`config/` does: [configuration](configuration.md).

## Loads and reloads

| What you did | Do this |
|---|---|
| Edited a set file, a keybind, states, CUSTOM or config file | `//gs c reload` (reloads the job file) |
| Changed subjob | Nothing: the job file reloads by itself 0.5 s later |
| Changed main job | Nothing: GearSwap loads the new job's file |
| Something is stuck, or you updated the setup | `//lua reload gearswap` (reloads the whole addon) |

On every load: the job's keys are bound (and sent again 2 s later, in case the
game dropped some), the HUD is drawn after a few seconds, the macro book is
set about 1.5 s later and the lockstyle 8 s later, and every mode goes back to
its default. Details: [job changes](../features/job-change-manager.md).

`//lua reload gearswap` also forgets what survives an ordinary reload: debug
switches, a forced Dual Wield tier, Auto Medicine's value. Your temporary keys
(`//gs c tb`) are kept. Watchdog settings changed with `//gs c watchdog` last
until the next load of any kind.

## Where to go next

- [Commands](commands.md) and [keybinds](keybinds.md) for everything you can
  type or press.
- [Set names](sets.md) to fill your set file.
- Your job's page: [jobs](../jobs/README.md).
- [FAQ](faq.md) when something is wrong.
