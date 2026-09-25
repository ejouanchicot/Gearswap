# FAQ

## Loading

**Nothing loads when I log in.**
GearSwap must be loaded (`//lua load gearswap`), and your folder must be
`data/<YourName>/` with `<YourName>_<JOB>.lua` inside, with your exact
in-game name. Create it with the clone script
([installation](../getting-started/installation.md)).

**Lua error at load.**
The message names the file and line. Most often a set or config file you
edited has a syntax error (a missing comma or brace).

**PUP does not load.** Known: see [PUP](../jobs/pup/README.md).

**I want SMN.** It ships only with the Tetsouo template; the clone script does
not deploy it for another name.

**How do I update?**
Download the new version and copy `shared/`, `_master/` and the scripts over
the old ones. Your `<YourName>/` folder is not touched. New options in the
templates are not added to your own config files: compare with `_master/` if
you want them.

## Gear

**Gear does not change on a spell.**
`//gs c debugmidcast`, cast the spell, and read which set was picked. Then
check that set's items with `//gs c checksets`.

**An item I own is reported MISSING.**
The name or the `augments` in the set file do not match the game exactly.

**Gear stuck in midcast after a cast.**
The [midcast watchdog](../features/watchdog.md) puts it back after a delay;
`//gs c watchdog clear` does it now.

**A slot stays locked.**
`//gs c warp fix` (warp ring), `//gs c uncraft` (craft set),
`//gs c wo recover` (wardrobe organizer). While Doomed, neck, rings and waist
stay locked on purpose.

## Lockstyle

**No lockstyle.**
It is sent 8 s after a load. Check the number in
`config/<job>/<JOB>_LOCKSTYLE.lua` exists in game (`/lockstyleset <n>` by
hand). `//gs c ls` sends it again.

**DressUp gets unloaded and loaded.**
That is the default, around each lockstyle. `//gs c dressup` turns it off.

**The lockstyle ignores my subjob.**
The job's `_LOCKSTYLE.lua` needs a `get_style` function for `by_subjob` to
count ([configuration](configuration.md#lockstyle-job_lockstylelua)).

## Keys and HUD

**Keys do nothing.**
`//gs c reload`, then read the chat: a `<JOB> keybinds: ...` line names a bad
entry. Mode keys need a modifier: Ctrl+Numpad, Apps+Numpad, Alt+Numpad.

**What do `^ ! @ # ~` mean?**
Ctrl, Alt, Windows, Apps (menu key), Shift.

**A key does something else.**
Two entries use the same key: the last one wins (your `_CUSTOM.lua` keys come
after the job's). The chat warning at load says which.

**No HUD.** `//gs c ui on`.

**HUD position lost after a reload.** Drag it, then `//gs c ui save`.

**A mode is missing from the HUD.** Only keys listed in the keybind file for
your current subjob have a row. A key with `key = ""` gives a row without a
key.

## Dual-box

**How do I set it up?** [Dual-box guide](dualbox.md).

**Alt commands are unknown.** The alt must have sent its job (2 s after its
load) and the `send` addon must be loaded on both characters.

## Jobs

**DNC: Waltz tier too high.** Target the party member before pressing, so
their missing HP can be read ([auto-tier](../features/auto-tier-system.md)).

**BST: Ready moves.** `//gs c rdylist` lists your pet's Ready moves with a
number; `//gs c rdymove <n>` uses one (it sends Fight first if the pet is
idle). See [BST](../jobs/bst/states.md).

**Why does my mode reset?** Every mode goes back to its default on each job
or subjob change, except Auto Medicine. Change the default in
`<JOB>_STATES.lua`.

## Quick table

| Problem | Command |
|---|---|
| Reload the job | `//gs c reload` |
| Reload everything | `//lua reload gearswap` |
| Missing gear | `//gs c checksets` |
| Wrong spell set | `//gs c debugmidcast` |
| Stuck gear | `//gs c watchdog clear` |
| Health check | `//gs c syscheck` |
| Help | `//gs c help` |

More: [commands](commands.md), [configuration](configuration.md),
[keybinds](keybinds.md).
