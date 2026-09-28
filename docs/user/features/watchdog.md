# Midcast watchdog

Puts your normal gear back when the game never confirms the end of a cast.

## Why

When you cast a spell, GearSwap puts on the midcast set and waits for the
server's "action finished" message to put your idle or engaged set back
(aftercast). In laggy zones (Odyssey, Dynamis-Divergence...) that message is
sometimes lost, and you would stay in the midcast set until your next action.

## How it works

Each spell and each usable item (Warp Ring...) you start is noted with a
time limit. Every 0.5 s the watchdog checks it; when the limit passes with no
aftercast, it clears the note and sends `//gs c update`, which puts your idle
or engaged set back. Job abilities, waltzes, steps and weaponskills are not
watched (they have no cast time).

The limit is the cast time plus a 1.5 s safety buffer:

- **Spells**: the cast time computed from the Fast Cast gear of the precast
  set that was really sent (Fast Cast and casting-time reductions of the
  spell's kind, capped at 80 %, Red Mage's Fast Cast trait, Nightingale /
  Troubadour on songs, Celerity / Alacrity). When that estimate is not
  available, the base cast time minus the job's `FastCast` mode, if it has
  one.
- **Items**: the item's use time, with no Fast Cast.
- **Unknown action**: 5.0 s (the fallback).

| Example | Cast time used | Limit |
|---|---|---|
| Cure IV (2.0 s) with 40 % Fast Cast | 1.2 s | 2.7 s |
| Stoneskin (7.0 s) with no Fast Cast | 7.0 s | 8.5 s |
| Warp Ring (10 s use time) | 10.0 s | 11.5 s |

The watchdog starts by itself 2 s after each job load.

## Commands

| Command | Effect |
|---|---|
| `//gs c watchdog` | Status: on or off, buffer, fallback, the action being watched |
| `//gs c watchdog on` / `off` / `toggle` | Turn it on / off |
| `//gs c watchdog clear` | Put your gear back now and forget the watched action |
| `//gs c watchdog buffer <s>` | Safety buffer, 0 to 10 s (default 1.5) |
| `//gs c watchdog fallback <s>` | Limit for an unknown action, above 0 and up to 30 s (default 5.0) |
| `//gs c watchdog stats` | Detailed statistics |
| `//gs c watchdog test [name] [spell id]` | Simulate a stuck cast: the aftercast is ignored so you can watch the recovery. Without arguments the timing is Warp II's (id 262) under the label Teleport-Holla |
| `//gs c watchdog debug` | Verbose output (turn it off after testing) |
| `//gs c watchdog help` | Help (any word it does not know shows it too). Words are lowercase only |

`buffer` and `fallback` values last until the next job load (job change,
subjob change, reload): they go back to 1.5 s and 5.0 s then. A value that is
not a number is ignored without a message.

## Troubleshooting

| Symptom | Try |
|---|---|
| Your gear comes back in the middle of a long cast | `//gs c watchdog buffer 2.5`. If the job has a `FastCast` mode, check it matches your real Fast Cast |
| Gear stays stuck | `//gs c watchdog` must say it is on; `//gs c watchdog clear` for now |
| `//gs c watchdog` answers nothing | It starts 2 s after a load. Look for a Lua error in the chat, then `//gs c reload`; `//gs c syscheck` checks it too |

Source: `shared/utils/core/midcast_watchdog.lua` (developer page:
[core-lifecycle](../../dev/systems/core-lifecycle.md)).
