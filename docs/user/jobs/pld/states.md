# PLD — modes and keys

Paladin has one stance mode (`HybridMode`) whose list depends on your subjob, a weapon
mode, two weaponskill slots, and a few subjob-only modes.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. Every key of the job, common keys
included, is on the [PLD page](README.md).

Set names and automatic gear: [sets.md](sets.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad9` | `HybridMode` | **PDT**, MDT, Sortie. Under /SCH: DPS, **Tanking**, Hoxne | Your stance (see below) |
| `^numpad1` | `MainWeapon` | **Excalibur**, Burtgang, KC, BurtgangKC, Naegling, Shining, Malevo | Weapon set to wield. The list shrinks in Sortie and under /SCH (see below). Hidden under /SCH Tanking |
| `^numpad2` | `PhalanxSIRD` | **Off**, On. Under /SCH: Off, **On** | `On` = Phalanx always uses `sets.midcast.SIRDPhalanx` (spell interruption down) instead of potency. The same key under every subjob |
| `^numpad5` | `WS1` | depends on the weapon | Weaponskill of `//gs c ws1` (or `ws`) |
| `^numpad6` | `WS2` | depends on the weapon | Weaponskill of `//gs c ws2` |
| `^numpad3` (/RUN) | `RuneMode` | **Ignis**, Gelus, Flabra, Tellus, Sulpor, Unda, Lux, Tenebrae | Rune used by `//gs c rune` |
| `^numpad4` (/RDM) | `Xp` | **Off**, On | `On` adds `sets.meleeXp` / `sets.idleXp` over your gear, and Phalanx uses the SIRD set |

### Stances (`HybridMode`)

| Stance | Engaged set | Idle set | Shield (with the author's `PLD_WEAPONS.lua`) | Notes |
|---|---|---|---|---|
| PDT | `sets.engaged.PDT` | `sets.idle.PDT` | from the set | |
| MDT | `sets.engaged.MDT` | `sets.idle.MDT` | from the set | |
| Sortie | `sets.engaged.TP` | `sets.idle.MDT` | follows the weapon: Burtgang > Aegis, Naegling > Blurred Shield +1 | Weapons shrink to Burtgang and Naegling, runes to Ignis, Tenebrae, Sulpor, Flabra, Unda; `PhalanxSIRD` turns On, `Regen` Off. Enmity spells and abilities use `sets.EnmityMax` |
| DPS (/SCH) | `sets.engaged.DPS` | `sets.idle.MDT` | Duban | Swings `MainWeapon` |
| Tanking (/SCH) | `sets.engaged.MDT` | `sets.idle.MDT` | Aegis | Always Burtgang, whatever `MainWeapon` says (its key is hidden). Enmity spells and abilities use `sets.EnmityMax` |
| Hoxne (/SCH) | `sets.engaged.Hoxne` | `sets.idle.MDT` | Duban | Swings `MainWeapon`, wears the Hoxne Ampulla and locks the ammo slot while the stance is on |

The shields of Sortie and the /SCH stances, and Burtgang in Tanking, come from
`PLD_WEAPONS.lua` (see [sets.md](sets.md#weapons)). The provided file forces none of
them: each stance then wears the `sub` of its own set and swings `MainWeapon`, Tanking
included (its weapon key stays hidden).

A Shining One (`Shining`) always takes the Alber Strap grip, and `BurtgangKC` (or a
Kraken Club already in your off hand, when the chosen weapon set has no off hand of
its own) uses `sets.engaged.BurtgangKC` in every stance.

Under /SCH the weapon list is Naegling and Excalibur (both with Duban in the author's
`PLD_WEAPONS.lua`), the weapon
opens on Naegling and `PhalanxSIRD` starts On (Ctrl+Numpad2 turns it Off). Leaving the
Sortie stance for PDT or MDT restores the full lists and turns `PhalanxSIRD` Off;
PDT <-> MDT keeps every choice.

`//gs c sortie <target>` (Sortie orders, only on a character with a `SORTIE_CONFIG.lua`;
with Tetsouo's, the example) sets the /SCH stance for the
target (DPS or Tanking; without /SCH it only warns) and `PhalanxSIRD`: Off for `aminon`
and `aminontest` (Phalanx potency matters more there), On for every other target.

The weaponskill slots follow the weapon in hand (`PLD_WS_CONFIG.lua`): Excalibur =
Savage Blade / Knights of Round, Burtgang = Savage Blade / Atonement, Naegling =
Savage Blade / Chant du Cygne.

## Other modes (no key)

| Mode | Values | Use |
|---|---|---|
| `Regen` (/SCH) | **Off**, On | Ctrl+Numpad3 under /SCH (Rune Mode's key, which only /RUN uses). `On` lays `sets.idleRegen` over your idle set. A macro can also set it: `//gs c set Regen On` / `Off`. Forced Off outside /SCH |
| `SneakInviAOE` | **On**, Off | Whether `aoe sneak` / `aoe invi` use Accession for the party, and whether `//gs c stealth` may cover your group with Accession ([Sneak and Invisible](../../guides/stealth.md)). No key: set back On each time the /SCH setup loads; `//gs c set SneakInviAOE Off` changes it until then |
| `FastCast` | 0 to 80 by 10, default **80** | Your Fast Cast %, used only by the midcast watchdog (how long it waits for a lost aftercast) |
| `AutoMedicine` | **On**, Off | Common to every job, key Apps+Numpad0: Echo Drops / Remedy when a debuff blocks your action |

## Commands

| Command | What it does |
|---|---|
| `//gs c ws` / `ws1` / `ws2` | Uses the weaponskill in that slot for the weapon in hand, on `<t>` (`ws` = slot 1). `ws3` to `ws9` only warn |
| `//gs c rune` | Uses the `RuneMode` rune unless it is on recast (then prints the time left). Meant for /RUN; the subjob is not checked |
| `//gs c aoe` | /BLU: casts the first ready spell of the Blue Magic enmity rotation (`PLD_BLU_MAGIC.lua`) on an enemy; refuses without /BLU |
| `//gs c aoe sneak` / `invi` (`invisible`) / `erase` | /SCH: casts the spell on the party with Light Arts, Addendum: White (Erase) and Accession as charges allow. The spell leaves once the stratagems are up, and is dropped with a message if they never come |
| `//gs c lightarts` | /SCH: Light Arts, then Addendum: White on the next press |

## Notes

- Every mode except `AutoMedicine` goes back to its default on every job change,
  subjob change and reload, so a subjob change always lands on PDT (or Tanking).
- The author's alt overlay keeps PDT/MDT/Sortie only and has
  no Excalibur.

## Files

In `<YourChar>/pld/`:

| File | Content |
|---|---|
| `PLD_STATES.lua` | Modes, their values and defaults, the Sortie and /SCH lists |
| `PLD_KEYBINDS.lua` | The keys above |
| `PLD_CUSTOM.lua` | Your own modes, keys and gear rules, without code (empty by default) |
| `PLD_HUD.lua` | Order of the HUD sections and rows on PLD |
| `PLD_WS_CONFIG.lua` | Weaponskills per weapon for the WS slots |
| `PLD_WEAPONS.lua` | Shield per weapon in given stances, the weapon a stance holds, grips of two-handed weapons |
| `PLD_BLU_MAGIC.lua` | Blue Magic enmity rotation for `//gs c aoe` |
| `PLD_LOCKSTYLE.lua` | Lockstyle number (3 in the template) |
| `PLD_MACROBOOK.lua` | Macro book/page per subjob, and per dual-box alt job |
| `PLD_TP_CONFIG.lua` | TP-bonus pieces used for weaponskill gear |
