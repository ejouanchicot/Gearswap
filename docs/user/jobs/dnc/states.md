# DNC — modes and keys

Dancer modes pick your weapons, the steps `//gs c step` uses, the dance and samba
`//gs c smartbuff` puts up, and whether Climactic Flourish and Jump fire on their own
before a weaponskill.

Start page for this job (every key, command and automatic feature): [README.md](README.md).
Set names and automatic gear: [sets.md](sets.md).

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| Ctrl+Numpad1 `^numpad1` | `MainWeapon` | Twashtar, **Mpu Gandring**, Demersal | Main weapon |
| Ctrl+Numpad2 `^numpad2` | `SubWeaponOverride` | **Off**, Blurred | Off = the off hand of the main weapon set; Blurred = the `sub` of `sets['Blurred']` (Blurred Knife +1 in the provided sets), whatever the main weapon |
| Ctrl+Numpad9 `^numpad9` | `HybridMode` | **PDT**, Normal | Idle outside town: `sets.idle.PDT` (or `sets.idle.Normal`) when it exists, else `sets.idle`; town idle does not change. Engaged: PDT: `sets.engaged.PDT`, or `sets.engaged.FanDance` while Fan Dance is up. Normal: `sets.engaged.Normal`. Under Saber Dance, `sets.engaged.SaberDance` (`.SaberDance.PDT` in PDT) wins over both |
| Ctrl+Numpad3 `^numpad3` | `MainStep` | **Box Step**, Quickstep, Feather Step | Step used by `//gs c step` |
| Ctrl+Numpad4 `^numpad4` | `AltStep` | **Quickstep**, Box Step, Feather Step | Second step when `UseAltStep` is On |
| Ctrl+Numpad5 `^numpad5` | `UseAltStep` | **On**, Off | On: `//gs c step` alternates MainStep and AltStep. Off: MainStep only |
| Ctrl+Numpad6 `^numpad6` | `ClimacticAuto` | **On**, Off | On: before a weaponskill listed in `DNC_WS_CONFIG.lua` (Rudra's Storm, Ruthless Stroke, Shark Bite), with at least 1000 TP (or the file's `min_tp` if higher), the target above 25 % HP and 3 or more Finishing Moves, Climactic Flourish is used first when it is ready and the weaponskill follows once it is up. Tried once per weaponskill |
| Ctrl+Numpad7 `^numpad7` | `JumpAuto` | **On**, Off | /DRG only: a weaponskill pressed below 1000 TP with Jump ready uses Jump first (then High Jump if still short), then the weaponskill again |
| Ctrl+Numpad8 `^numpad8` | `Dance` | **Saber Dance**, Fan Dance | Dance put up by `//gs c smartbuff` (unless already up) and `//gs c dance` (always) |
| Ctrl+Numpad0 `^numpad0` | `Samba` | **Haste Samba**, Drain Samba II, Aspir Samba | Samba put up by `//gs c smartbuff` when your TP covers it or Trance is up (never with Fan Dance) |

## Other modes (no key)

| Mode | Values | Notes |
|---|---|---|
| `FastCast` | 0 to 80 by 10, default **0** | Your Fast Cast %, used by the midcast watchdog (`//gs c cycle FastCast`, or its default in `DNC_STATES.lua`) |
| `CurrentStep` | Main, Alt | Which step `//gs c step` uses next when `UseAltStep` is On (flipped by the command, shown nowhere) |
| `CombatWeaponMode` | Normal, TPBonus, Clim, ClimTPBonus | Nothing reads it |

## Commands

| Command | What it does |
|---|---|
| `//gs c step` | Uses the step on `<t>`, with Presto first when it is ready, not already up and you are level 77+ (the step follows once Presto is up). Only a message when steps are on recast |
| `//gs c smartbuff` (`buffself`) | The selected dance, then the selected samba, then subjob buffs: /WAR Berserk, Aggressor, Warcry; /NIN Utsusemi: Ni (or Ichi); /SAM Hasso. Only what is ready and not already up, 2 s apart; the rest is listed in chat |
| `//gs c dance` (`fandance`) | The selected dance only, even if it is already up |
| `//gs c waltz` / `aoewaltz` | Curing Waltz on `<stpc>` (tier picked from the HP missing) / Divine Waltz II, else Divine Waltz. Common commands; they cancel Saber Dance first |
| `//gs c jump` | /DRG jump (common command) |

## Notes

- `fandance` runs on this character even when your dual-box partner is a DNC; use
  `//gs c alt fandance` to send the partner's.
- A waltz or samba from your own macro is sent as it is: no tier change, no "Full HP"
  block, and Saber Dance / Fan Dance are not cancelled for it (the game refuses a waltz
  under Saber Dance and a samba under Fan Dance). A samba your TP cannot pay for is
  cancelled with a message, except under Trance.
- Saber Dance and Fan Dance change your engaged gear the moment they start or end.

## Files

`<Char>/dnc/`: `DNC_STATES.lua`, `DNC_KEYBINDS.lua`, `DNC_CUSTOM.lua` (your own
modes and keys, see [keybinds](../../guides/keybinds.md)), `DNC_WS_CONFIG.lua`
(Climactic weaponskills, minimum TP, target HP), `DNC_HUD.lua` (HUD order),
`DNC_LOCKSTYLE.lua` (style 2), `DNC_MACROBOOK.lua` (book 4 page 1 by default, /WAR book
5, other books per dual-box partner job), `DNC_TP_CONFIG.lua`, and `DNC_REFILL.lua` if
you create one. What each file holds: [README.md](README.md#configuration-files-for-this-job).
