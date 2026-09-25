# Quick start

What to do in your first minutes after [installation](installation.md).

## The HUD

When a job loads, a box appears on screen with every key of the job, what it
changes and the current value (for example `^numpad9  Hybrid Mode  PDT`).

| Command | Effect |
|---|---|
| `//gs c ui` | Show / hide it (kept for next time) |
| `//gs c ui save` | Save its position after dragging it with the mouse |
| `//gs c ui help` | All HUD options (header, legend, columns, footer, font, background) |

More: [HUD](../features/ui.md).

## The keys

Mode keys live on the numeric keypad with a modifier:

- **Ctrl+Numpad** (`^numpadN`): the job's modes. On most jobs Ctrl+Numpad9 is
  Hybrid Mode and Ctrl+Numpad1 / 2 the weapons.
- **Apps+Numpad** (`#numpadN`, Apps = the menu key next to right Ctrl): extra
  modes on some jobs, and Apps+Numpad0 = Auto Medicine on every job.
- **Alt+Numpad7 / 8 / 9**: dual-box orders to your alts (follow, automation,
  mirror), on every job.

Each press moves the mode to its next value; the HUD updates at once. Your
job's page lists what each value does: [jobs](../jobs/README.md).

Examples from the templates:

| Job | Key | Mode |
|---|---|---|
| WAR | Ctrl+Numpad1 / Ctrl+Numpad9 | Main Weapon / Hybrid Mode |
| WAR | Ctrl+Numpad3 to 7 | Weaponskill slots 1 to 5 |
| PLD | Ctrl+Numpad9 / Ctrl+Numpad1 / Ctrl+Numpad2 | Hybrid Mode / Main Weapon / Phalanx SIRD |
| RDM | Ctrl+Numpad3 / Ctrl+Numpad7 | Enfeeble Mode / Nuke Mode |
| BLM | Ctrl+Numpad3 / Ctrl+Numpad1 | Main light element / Spell tier |

Keys, your own modes and temporary keys: [keybinds](../guides/keybinds.md).

## Everyday commands

Type `//gs c <command>`. `//gs c help` prints the built-in help.

| Command | Effect |
|---|---|
| `checksets` | Set items you do not have in inventory or wardrobes |
| `rf` | Restock consumables from the Mog Case / Sack (lists in `config/<job>/<JOB>_REFILL.lua`, see [configuration](../guides/configuration.md)) |
| `wo` | Wardrobe organizer: the gear of the loaded job goes to wardrobes 1-2 |
| `ls` | Lockstyle again |
| `warp`, `ret`, `esc`, `tph`... | Go home, Retrace, Escape, teleports |
| `mount` | Mount or dismount |
| `reload` | Reload the job file |

All commands: [commands](../guides/commands.md).

## What happens on each action

1. **Precast**: the action is cancelled if it cannot go off (silence,
   paralysis on a job ability, amnesia, recast not ready...). With Auto
   Medicine on, an Echo Drops, Remedy or Panacea is used when it helps.
   Weaponskills are checked for range and 1000 TP, and TP bonus gear is added.
2. **Midcast**: the set is chosen from your set file, from the most precise
   name (the exact spell) to the most general (the magic skill).
   `//gs c debugmidcast` prints which set was used.
3. **After the action**: your idle or engaged set comes back. If the game
   never confirms the end of a cast, the [midcast watchdog](../features/watchdog.md)
   puts it back after a delay.

## Changing job or subjob

A subjob change reloads the job file 0.5 s later (several quick changes give
one reload). A main job change loads the new job's file. Modes (except Auto
Medicine) restart at their
default values after each load. The macro book follows at once, the lockstyle 8 s later.
See [job changes](../features/job-change-manager.md).

## If something is wrong

| Symptom | Try |
|---|---|
| Keys do nothing | `//gs c reload`; read the chat at load for `<JOB> keybinds: ...` warnings |
| Wrong gear on a spell | `//gs c debugmidcast`, cast it, read which set was picked |
| Gear stuck after a cast | `//gs c watchdog clear` |
| A slot stays locked | `//gs c warp fix` (warp ring), `//gs c uncraft` (craft), `//gs c wo recover` (organizer) |
| Anything else | `//gs c syscheck`, then the [FAQ](../guides/faq.md) |
