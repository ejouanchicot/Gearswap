# WAR — modes and keys

Warrior: weapon and hybrid mode, five weaponskill slots that follow your
weapon, an automatic Jump before weaponskills on /DRG, and one-key buff chains.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each
mode's current value; this page says what each value does. `#numpad0` (Auto
Medicine) and Alt+Numpad7-9 (alts) are common to every job, see
[keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Main Weapon (`MainWeapon`) | Ukonvasara, Naegling, NaeglingKC, Shining, Chango, Ikenga, Loxotic | Weapon set (`sets.<Weapon>`) in idle and engaged. No fixed default: after loading, the mode is set to the weapon you are holding (Ukonvasara if it matches no set). NaeglingKC = Naegling with Kraken Club. |
| `^numpad9` | Hybrid Mode (`HybridMode`) | **PDT**, Normal | Idle and engaged base: `sets.idle.PDT` / `sets.engaged.PDT`, or the Normal ones. |
| `^numpad2` | Jump Auto (`JumpAuto`) | **On**, Off | /DRG only. On: a weaponskill pressed under 1000 TP is held back, Jump / High Jump go out, then the weaponskill is sent again. |
| `^numpad3` … `^numpad7` | WS Slot 1-5 (`WS1` … `WS5`) | The weaponskills of your current weapon | Each slot holds one weaponskill; the key picks which. `//gs c ws1` … `ws5` fires the slot on `<t>`. The slots are rebuilt when you change weapon. |

The weaponskill list per weapon is in `WAR_WS_CONFIG.lua`. A slot past the
end of the weapon's list shows `None`.

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `FastCast` | 0 to 80 in steps of 10, default **0** | Fast Cast %, read by the midcast watchdog. |

## Commands

| Command | What it does |
|---|---|
| `//gs c ws1` … `ws5` | Uses the weaponskill in that slot on `<t>`. |
| `//gs c berserk` | Berserk, Aggressor, Retaliation, Restraint, Warcry (or Blood Rage when Warcry is down and on recast), the ready ones, 2 s apart. Defender is left out. /SAM adds Hasso and Third Eye; /DNC adds Haste Samba at 350 TP or more. |
| `//gs c defender` | Same chain with Defender instead of Berserk; /SAM adds Seigan instead of Hasso. |
| `//gs c thirdeye` | /SAM only: Hasso (or Seigan if Defender is up) and Third Eye. |
| `//gs c tp` | /SAM: Meditate. /DRG: same as `//gs c jump` (Jump or High Jump, then the other one if TP is still under 1000). Other subjobs: a warning. |
| `//gs c retalstatus` | Shows the Retaliation auto-cancel tracker. |

Abilities already up or on recast are listed in chat instead of being sent.

## Notes

- **Engaged set order** (first match wins): `sets.engaged.PDTKC` with
  NaeglingKC or Kraken Club in the off hand; `sets.engaged.PDTAFM3` under
  Aftermath: Lv.3 with Ukonvasara; `sets.engaged.<Weapon>` if it exists;
  then `sets.engaged.<HybridMode>`.
- **Retaliation auto-cancel**: if Retaliation is up and you move for 5 s while
  not engaged, it is cancelled (needs the Windower `Cancel` addon).
- Idle: town / Adoulin sets in town, `sets.MoveSpeed` while moving outside town.
- Weaponskill TP bonus gear (Moonshade, Chango, Warcry, Fencer): see
  [TP bonus](tp-bonus.md).
- Every mode goes back to its default on each job change, subjob change or
  reload (the weapon is read again from your hands).
- Tetsouo's own files differ: Hybrid Mode also has `SubtleBlow` and `Hoxne`
  (Hoxne locks the ammo slot on the Hoxne Ampulla), and his `WAR_CUSTOM.lua`
  adds a `FullEmpy` On/Off mode on `^numpad8`.

## Files

In `<Char>/config/war/`: `WAR_STATES.lua` (modes and defaults),
`WAR_KEYBINDS.lua` (keys), `WAR_WS_CONFIG.lua` (weaponskills per weapon),
`WAR_TP_CONFIG.lua` (TP bonus), `WAR_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `WAR_LOCKSTYLE.lua`, `WAR_MACROBOOK.lua`.
See [configuration](../../guides/configuration.md).
