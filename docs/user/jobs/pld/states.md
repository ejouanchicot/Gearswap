# PLD — modes and keys

Paladin has one stance mode (`HybridMode`) whose list depends on your subjob, a weapon
mode, two weaponskill slots, and a few subjob-only modes.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad9` | `HybridMode` | **PDT**, MDT, Sortie. Under /SCH: DPS, **Tanking**, Hoxne | Your stance (see below) |
| `^numpad1` | `MainWeapon` | **Excalibur**, Burtgang, KC, BurtgangKC, Naegling, Shining, Malevo | Weapon set to wield. The list shrinks in Sortie and under /SCH (see below). Hidden under /SCH Tanking |
| `^numpad2` | `PhalanxSIRD` | **Off**, On | `On` = Phalanx always uses `sets.midcast.SIRDPhalanx` (spell interruption down) instead of potency. Not bound under /SCH, where it is held On |
| `^numpad5` | `WS1` | depends on the weapon | Weaponskill of `//gs c ws1` (or `ws`) |
| `^numpad6` | `WS2` | depends on the weapon | Weaponskill of `//gs c ws2` |
| `^numpad3` (/RUN) | `RuneMode` | **Ignis**, Gelus, Flabra, Tellus, Sulpor, Unda, Lux, Tenebrae | Rune used by `//gs c rune` |
| `^numpad4` (/RDM) | `Xp` | **Off**, On | `On` adds `sets.meleeXp` / `sets.idleXp` over your gear, and Phalanx uses the SIRD set |

### Stances (`HybridMode`)

| Stance | Engaged set | Idle set | Notes |
|---|---|---|---|
| PDT | `sets.engaged.PDT` | `sets.idle.PDT` | |
| MDT | `sets.engaged.MDT` | `sets.idle.MDT` | |
| Sortie | `sets.engaged.TP` | `sets.idle.MDT` | Weapons shrink to Burtgang and Naegling, the shield follows the weapon (Aegis / Blurred Shield +1), runes shrink to Ignis, Tenebrae, Sulpor, Flabra, Unda, `PhalanxSIRD` turns On |
| DPS (/SCH) | `sets.engaged.DPS` | `sets.idle.MDT` | Swings `MainWeapon` |
| Tanking (/SCH) | `sets.engaged.MDT` | `sets.idle.MDT` | Always Burtgang + Aegis, whatever `MainWeapon` says |
| Hoxne (/SCH) | `sets.engaged.Hoxne` | `sets.idle.MDT` | Swings `MainWeapon`, wears the Hoxne Ampulla and locks the ammo slot |

Under /SCH the weapon list is Naegling and Excalibur (both with Duban), and the weapon
opens on Naegling. Going back to PDT or MDT restores the full lists and turns
`PhalanxSIRD` Off.

The weaponskill slots follow the weapon in hand (`PLD_WS_CONFIG.lua`): Excalibur =
Savage Blade / Knights of Round, Burtgang = Savage Blade / Atonement, Naegling =
Savage Blade / Chant du Cygne.

## Other modes (no key)

| Mode | Values | Use |
|---|---|---|
| `Regen` (/SCH) | **Off**, On | Ctrl+Numpad2 under /SCH (the key is Phalanx SIRD on the other subjobs). `On` lays `sets.idleRegen` over your idle set. A macro can also set it: `//gs c set Regen On` / `Off`. Forced Off outside /SCH |
| `SneakInviAOE` | **On**, Off | Whether `aoe sneak` / `aoe invi` use Accession for the party. Held On under /SCH |
| `FastCast` | 0 to 80 by 10, default **80** | Your Fast Cast %, used only by the midcast watchdog |

## Commands

| Command | What it does |
|---|---|
| `//gs c ws` / `ws1` / `ws2` | Uses the weaponskill in that slot for the weapon in hand (`ws` = slot 1) |
| `//gs c rune` | Uses the `RuneMode` rune unless it is on recast |
| `//gs c aoe` | /BLU: casts the first ready spell of the Blue Magic enmity rotation (`PLD_BLU_MAGIC.lua`) on an enemy; refuses without /BLU |
| `//gs c aoe sneak` / `invi` / `erase` | /SCH: casts the spell on the party with Light Arts, Addendum: White (Erase) and Accession as charges allow |
| `//gs c lightarts` | /SCH: Light Arts, then Addendum: White on the next press |

## Notes

- All modes go back to their default on every job change, subjob change and reload.
- The Kaories overlay (`_master/Kaories/config/pld/`) keeps PDT/MDT/Sortie only and has
  no Excalibur.

## Files

In `<YourChar>/config/pld/`:

| File | Content |
|---|---|
| `PLD_STATES.lua` | Modes, their values and defaults, the Sortie and /SCH lists |
| `PLD_KEYBINDS.lua` | The keys above |
| `PLD_CUSTOM.lua` | Your own modes, keys and gear rules, without code (empty by default) |
| `PLD_WS_CONFIG.lua` | Weaponskills per weapon for the WS slots |
| `PLD_BLU_MAGIC.lua` | Blue Magic enmity rotation for `//gs c aoe` |
| `PLD_LOCKSTYLE.lua` | Lockstyle number (3 in the template) |
| `PLD_MACROBOOK.lua` | Macro book/page per subjob, and per dual-box alt job |
| `PLD_TP_CONFIG.lua` | TP-bonus pieces used for weaponskill gear |
