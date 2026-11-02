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

**I want SMN.** Pick SMN in the job list when you run the clone script (or
re-run it to add SMN to an existing character). Its set file is mostly empty:
fill it with your gear ([SMN sets](../jobs/smn/sets.md)).

**Where do I start reading?**
[How it works](how-it-works.md) explains the whole flow in plain words; the
[glossary](glossary.md) explains the terms.

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
`//gs c wo recover` (wardrobe organizer). Weapons that never change: Combat
Mode is On (HUD row, or `//gs c combatmode`). While Doomed, neck, rings and
waist stay locked on purpose.

**My town set leaves odd pieces on.**
`sets.idle.Town` and `sets.Adoulin` go on top of your idle set: a slot they
leave out keeps your idle piece
([set names](sets.md#put-on-by-themselves)).

**Treasure Hunter gear never goes on.**
Treasure Mode is Off and hidden on every job but THF: `//gs c th show`, then
pick `Tag` or `Full`. The job's set file needs a `sets.TreasureHunter`.

## Lockstyle

**No lockstyle.**
It is sent 8 s after a load. Check the number in
`<job>/display/<JOB>_LOCKSTYLE.lua` exists in game (`/lockstyleset <n>` by
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

**F9 / F10 / F11 change nothing I can see.**
They are Mote-Include's keys, bound on every job but not shown in the HUD.
They cycle Mote-Include's own modes, which many jobs replace with their own:
see [keybinds](keybinds.md#mote-includes-keys) and your job's page.

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
`<JOB>_STATES.lua` (Auto Medicine: `auto_medicine_start` in
`_common/combat/AUTO_MEDICINE_CONFIG.lua`, read when the game starts).

## Atelier page

**The page asks for my Windower folder again / "Reload from files" fails.** Your
browser keeps the folder you showed it the first time, and that memory can stop
working (a browser update, a copy or restore of the folder), even with the same
path. Nothing is broken:

1. Click **⟳ Reload from files** again (or Save again).
2. When the page asks "Where is Windower?", pick your Windower folder (the one
   that holds `addons` and `res`). It is kept for the next times.

If the message says a file is **read-only or open in another program**, close
that program (or remove the file's read-only box in Windows), then try again. If
it says the browser **may not write**, try again and accept when the browser asks
to let the page edit files. The text in brackets after the message (`NotFoundError`
and the file) is for whoever helps you.

**The item icons look blurry or pixelated.** The page makes a sharper copy of
each icon by itself, the first time it shows it, from a file the game writes
beside the icon; an icon written by an older version stays as it is until the
game writes it again (`//gs c atelier` on the job).

**Create a set.** On the Sets screen, **+** (top of the list of sets) opens an assistant
that asks, one step at a time: **when** you want the set (idle, engaged, start of a spell,
when the spell lands, weaponskill, ability, cures, situations), **what** it is for (the
spells your job and your subjob cast, by school, tiers together; your weaponskills; your
abilities), then only the questions that change the set worn (**on whom**: you, or an ally
under Composure for a Red Mage; **which tier**; **which mode**; **which party profile**).
A summary says in words when the set is worn, what you wear in its place today, and the one
name it gets in your file; it starts as a copy of that set, empty, or what you wear in game.
A set you already have under another name is opened instead of a second one being made.
**See every possible name (experts)** lists every name the job's code reads, one line each,
with the other spellings GearSwap reads the same way folded under it.

**Edit a weapon cycle (order, add, take out).** A weapon set (`sets.Daybreak`) is only worn while
the weapon is in one of the job's cycles (Main Weapon, Sub Weapon...). In **Configuration**, **Modes & keys**,
**Equipment**, click Main Weapon or Sub Weapon: its cycle opens under the modes, its weapons as tiles in the order its
key goes through them (1, 2, 3, then back to 1), the one worn on load framed in gold, an empty or missing set in
orange. Drag a weapon to move it, or use its **◀ ▶**; **✕** takes it out (its set stays); **File order** puts your
states file's order back. Under them, **Add** lists the weapons you hold that the job can wear in that slot and the
cycle does not have yet (type to filter); one taken out earlier is marked "was there". A weapon whose set holds it in
another hand gets its own set: Colada added to Sub Weapon, while `sets.Colada` is its main hand, gets
`sets["Colada Sub"] = { sub = 'Colada' }`. Every change goes to `atelier/overrides/mode_overrides.lua`
(`['+SubWeapon']` added, `['-MainWeapon']` taken out, `['=MainWeapon']` the order), laid over your states file, which
is never rewritten, and GearSwap reloads. A cycle always keeps one weapon. Creating a weapon's set needs the game
linked. Deleting a weapon's set (its "⋯" menu) takes the weapon out of its cycle too.

**Optimize every set of a job at once.** On the Sets screen, **⚡ Optimize all** (**⚡ Tout
optimiser** in French, top of the list of sets) searches every set of the job shown, one after the other, each with its own
goals, limits and HP band, among your pieces only. A first window lists the sets by family,
all ticked, with the time it should take (a few seconds a stats set, about 25 s a
weaponskill or engaged set): untick what you want to keep as it is, or use **Stats sets
only**. The Fast Cast sets go first (they set the other tank sets' HP), and a set comes after
the set it is built on. **Stop** ends the run at any time. Then a summary shows each set's
goal before and after, the gain and the pieces changed: the sets that gain and hold their
limits are ticked, **Push to GearSwap** writes them one after the other (same preview,
backup and history as a single push). Without the game linked, the results stay on trial on
each set. **Undo all** puts every set back as it was before the run.

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
