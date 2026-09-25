# SAM — modes and keys

Samurai has two keyed modes (weapon and hybrid). Most of what SAM does
happens on its own: Seigan before Third Eye, Third Eye before a weaponskill.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each
mode's current value; this page says what each value does. `#numpad0` (Auto
Medicine) and Alt+Numpad7-9 (alts) are common to every job, see
[keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Main Weapon (`MainWeapon`) | **Masamune**, Kusanagi, Shining, Dojikiri, Soboro, Norifusa | Weapon equipped in idle and engaged sets (`sets.<Weapon>` from your set file). |
| `^numpad9` | Hybrid Mode (`HybridMode`) | **PDT**, Normal | PDT: `sets.idle.PDT` on top of idle and `sets.engaged.PDT` when engaged. Normal: `sets.engaged.Normal`. |

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `FastCast` | 0 to 80 in steps of 10, default **0** | Your Fast Cast %, used only by the midcast watchdog to know how long a cast takes. Change the default in `SAM_STATES.lua`, or step it with `//gs c cycle FastCast`. |

## Commands

SAM has no job command of its own. The common commands work
(see [commands](../../guides/commands.md)); two are useful with a subjob:

| Command | What it does |
|---|---|
| `//gs c jump` | /DRG, under 1000 TP: Jump or High Jump (whichever is ready), then the other one 1 s later if TP is still under 1000. |
| `//gs c waltz` | /DNC: Curing Waltz on `<stpc>`. |

## Notes

- **Third Eye with Seigan down**: the first Third Eye press is replaced by
  Seigan, then Third Eye 1 s later. The next time, Third Eye goes out alone
  (the behaviour alternates).
- **Weaponskill with Third Eye ready**: the weaponskill is held back, Third Eye
  goes out first, then the weaponskill is sent again.
- **Seigan up while engaged**: `sets.thirdeye` in PDT, `sets.seigan` in Normal.
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
