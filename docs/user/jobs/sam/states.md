# SAM — modes and keys

Samurai has two keyed modes (weapon and hybrid). Most of what SAM does
happens on its own: Third Eye before a weaponskill, and Seigan before Third Eye
when Seigan is your chosen stance.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each
mode's current value; this page says what each value does. `#numpad0` (Auto
Medicine) and Alt+Numpad7-9 (alts) are common to every job, see
[keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Main Weapon (`MainWeapon`) | **Masamune**, Kusanagi, Shining, Dojikiri, Soboro, Norifusa | Weapon equipped in idle and engaged sets (`sets.<Weapon>` from your set file). |
| `^numpad2` | Offense Mode (`OffenseMode`) | **Normal**, Mid, Acc, SuBlow | Engaged accuracy: `sets.engaged.<value>`, then `.<value>.<HybridMode>` when it exists (`sets.engaged.Acc.PDT`). A defensive HybridMode wins when the accuracy set has no variant for it (Mid + PDT = `sets.engaged.PDT`). |
| `^numpad3` | WS Mode (`WeaponskillMode`) | **Normal**, Mid, Acc | `sets.precast.WS['<name>'].<value>` when it exists (the template has Tachi: Shoha and Tachi: Rana .Mid / .Acc), else the WS set. |
| `^numpad9` | Hybrid Mode (`HybridMode`) | **PDT**, Normal, MDT | PDT: `sets.idle.PDT` on top of idle and `sets.engaged.PDT` when engaged. Normal: the Offense Mode set. MDT: `sets.engaged.MDT`. |

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `Stance` | **Hasso**, Seigan | The stance the automation keeps. Set by `//gs c hasso` / `//gs c seigan` and by any Hasso or Seigan you use. Hasso: Third Eye goes out alone, Hasso is never replaced. Seigan: Seigan goes out before Third Eye when it is down. |
| `FastCast` | 0 to 80 in steps of 10, default **0** | Your Fast Cast %, used only by the midcast watchdog to know how long a cast takes. Change the default in `SAM_STATES.lua`, or step it with `//gs c cycle FastCast`. |

## Commands

| Command | What it does |
|---|---|
| `//gs c hasso` | Uses Hasso and makes it the chosen stance (put it in a macro). |
| `//gs c seigan` | Uses Seigan and makes it the chosen stance. |

The common commands work too (see [commands](../../guides/commands.md)); two
are useful with a subjob:

| Command | What it does |
|---|---|
| `//gs c jump` | /DRG, under 1000 TP: Jump or High Jump (whichever is ready), then the other one 1 s later if TP is still under 1000. |
| `//gs c waltz` | /DNC: Curing Waltz on `<stpc>`. |

## Notes

- **Third Eye, Seigan stance, Seigan down**: the first Third Eye press is
  replaced by Seigan, then Third Eye 1 s later. The next time, Third Eye goes
  out alone (the behaviour alternates). With the Hasso stance, Third Eye always
  goes out alone.
- **Weaponskill with Third Eye ready**: the weaponskill is held back, Third Eye
  goes out first, then the weaponskill is sent again once Third Eye is up (or
  refused). Each action has its own precast: Third Eye gear, then weaponskill
  gear.
- **Seigan up while engaged**: `sets.thirdeye` in PDT, `sets.seigan` otherwise
  (empty in the template until you fill it). `sets.bow` goes on with
  Yoichinoyumi (empty too). `sets.engaged.AM3` replaces the engaged set under
  Aftermath: Lv.3 with Masamune when you define it (not in the template).
- **Idle**: `sets.idle.Weak` below 50% HP, `sets.idle.Regen` below 80%.
- Sekkanoki and Meikyo Shisui add `sets.buff.Sekkanoki` /
  `sets.buff['Meikyo Shisui']` to the weaponskill when the buff is up.
- Weaponskill TP bonus gear: see [TP bonus](../war/tp-bonus.md).
- Every mode goes back to its default on each job change, subjob change or reload.

## Files

In `<Char>/config/sam/`: `SAM_STATES.lua` (modes and defaults),
`SAM_KEYBINDS.lua` (keys), `SAM_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `SAM_LOCKSTYLE.lua`, `SAM_MACROBOOK.lua`,
`SAM_TP_CONFIG.lua`. See [configuration](../../guides/configuration.md).
