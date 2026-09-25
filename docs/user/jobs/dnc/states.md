# DNC — modes and keys

Dancer modes pick your weapons, the steps `//gs c step` uses, the dance and samba
`//gs c smartbuff` puts up, and whether Climactic Flourish and Jump fire on their own
before a weaponskill.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| Ctrl+Numpad1 `^numpad1` | `MainWeapon` | Twashtar, **Mpu Gandring**, Demersal | Main weapon |
| Ctrl+Numpad2 `^numpad2` | `SubWeaponOverride` | **Off**, Blurred | Off = the sub from the weapon set; Blurred = force Blurred Knife +1 |
| Ctrl+Numpad9 `^numpad9` | `HybridMode` | **PDT**, Normal | Idle and engaged: PDT adds damage-taken gear |
| Ctrl+Numpad3 `^numpad3` | `MainStep` | **Box Step**, Quickstep, Feather Step | Step used by `//gs c step` |
| Ctrl+Numpad4 `^numpad4` | `AltStep` | **Quickstep**, Box Step, Feather Step | Second step when `UseAltStep` is On |
| Ctrl+Numpad5 `^numpad5` | `UseAltStep` | **On**, Off | On: `//gs c step` alternates MainStep and AltStep. Off: MainStep only |
| Ctrl+Numpad6 `^numpad6` | `ClimacticAuto` | **On**, Off | On: before a weaponskill listed in `DNC_WS_CONFIG.lua`, with enough TP and the target above the HP threshold, Climactic Flourish is used first and the weaponskill follows |
| Ctrl+Numpad7 `^numpad7` | `JumpAuto` | **On**, Off | /DRG only: when TP is short for a weaponskill and a jump is ready, jump first |
| Ctrl+Numpad8 `^numpad8` | `Dance` | **Saber Dance**, Fan Dance | Dance put up by `//gs c smartbuff` and `//gs c dance` |
| Ctrl+Numpad0 `^numpad0` | `Samba` | **Haste Samba**, Drain Samba II, Aspir Samba | Samba put up by `//gs c smartbuff` when your TP covers it (never with Fan Dance) |

## Other modes (no key)

| Mode | Values | Notes |
|---|---|---|
| `FastCast` | 0 to 80 by 10, default **0** | Your Fast Cast %, used by the midcast watchdog (`//gs c cycle FastCast`, or its default in `DNC_STATES.lua`) |

## Commands

| Command | What it does |
|---|---|
| `//gs c step` | Uses the step on `<t>`, with Presto first when it is ready (level 77+). Does nothing but a message when steps are on recast |
| `//gs c smartbuff` (`buffself`) | The selected dance, then the selected samba, then subjob buffs: /WAR Berserk, Aggressor, Warcry; /NIN Utsusemi: Ni (or Ichi); /SAM Hasso |
| `//gs c dance` (`fandance`) | The selected dance only |
| `//gs c waltz` / `aoewaltz` | Curing Waltz on `<stpc>` (tier picked from the HP missing) / Divine Waltz. Common command; cancels Saber Dance first |
| `//gs c jump` | /DRG jump (common command) |

## Notes

- `fandance` runs on this character even when your dual-box partner is a DNC; use
  `//gs c alt fandance` to send the partner's.

## Files

`<Char>/config/dnc/`: `DNC_STATES.lua`, `DNC_KEYBINDS.lua`, `DNC_CUSTOM.lua` (your own
modes and keys, see [keybinds](../../guides/keybinds.md)), `DNC_WS_CONFIG.lua`
(Climactic weaponskills, minimum TP, target HP), `DNC_LOCKSTYLE.lua` (style 2),
`DNC_MACROBOOK.lua` (book 4 page 1 by default, /WAR book 5, other books per dual-box
partner job), `DNC_TP_CONFIG.lua`.
