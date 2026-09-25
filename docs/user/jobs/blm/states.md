# BLM — modes and keys

Black Mage picks its nukes from modes: an element per "slot" (main/sub, light/dark,
single/AOE) plus a tier, then one command casts the result on your target.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| Ctrl+Numpad3 `^numpad3` | `MainLightSpell` | **Fire**, Aero, Thunder | Element cast by `//gs c light` |
| Apps+Numpad3 `#numpad3` | `SubLightSpell` | **Thunder**, Fire, Aero | Element cast by `//gs c sublight` |
| Ctrl+Numpad4 `^numpad4` | `MainDarkSpell` | Blizzard, **Stone**, Water | Element cast by `//gs c dark` |
| Apps+Numpad4 `#numpad4` | `SubDarkSpell` | Water, **Blizzard**, Stone | Element cast by `//gs c subdark` |
| Ctrl+Numpad5 `^numpad5` | `MainLightAOE` | **Firaga**, Aeroga, Thundaga | Spell cast by `//gs c aoelight` |
| Apps+Numpad5 `#numpad5` | `SubLightAOE` | **Thundaga**, Firaga, Aeroga | Spell cast by `//gs c subaoelight` |
| Ctrl+Numpad6 `^numpad6` | `MainDarkAOE` | Blizzaga, **Stonega**, Waterga | Spell cast by `//gs c aoedark` |
| Apps+Numpad6 `#numpad6` | `SubDarkAOE` | **Blizzaga**, Stonega, Waterga | Spell cast by `//gs c subaoedark` |
| Ctrl+Numpad1 `^numpad1` | `SpellTier` | **VI**, V, IV, III, II, I | Tier of the single-target nukes. `I` is the base spell (`Fire`, not `Fire I`) |
| Ctrl+Numpad2 `^numpad2` | `AOETier` | **Aja**, III, II, I | Tier of the AOE nukes. `Aja` turns the -ga spell into its -ja (Firaga → Firaja) |
| Ctrl+Numpad7 `^numpad7` | `Storm` | **Firestorm**, Sandstorm, Thunderstorm, Hailstorm, Rainstorm, Windstorm, Voidstorm, Aurorastorm | Storm cast by `//gs c storm` (/SCH) |
| Ctrl+Numpad9 `^numpad9` | `HybridMode` | PDT, **Normal** | Idle/engaged gear: PDT = damage taken down, Normal = damage |
| Ctrl+Numpad8 `^numpad8` | `CombatMode` | **Off**, On | On equips Bunzi's Rod, Ammurapi Shield, Sroda Tathlum and locks main/sub/range/ammo. Off unlocks them (unless a craft set is active) |
| Ctrl+Numpad0 `^numpad0` | `MagicBurstMode` | Off, **On**, Acc | Elemental midcast: Off = normal nuke set, On = Magic Burst set, Acc = Magic Burst accuracy set |
| Apps+Numpad7 `#numpad7` | `DeathMode` | **Off**, On | Shown in the HUD; no code reads it today |
| Apps+Numpad8 `#numpad8` | `SneakInviAOE` | **On**, Off | `//gs c aoe sneak/invi`: On = Accession and cast on yourself (whole party), Off = single target |
| Apps+Numpad9 `#numpad9` | `KlimaformAOE` | **On**, Off | `//gs c klima`: On = Manifestation first (if a stratagem charge is left) |

## Other modes (no key)

| Mode | Values | Notes |
|---|---|---|
| `FastCast` | 0 to 80 by 10, default **80** | Your total Fast Cast %, used by the midcast watchdog to know how long a cast lasts. Change it with `//gs c cycle FastCast` or its default in `BLM_STATES.lua` |
| `MainWeapon` / `SubWeapon` | Hvergelmir / Alber Strap | One value each |

## Commands

| Command | What it does |
|---|---|
| `//gs c light` / `dark` / `sublight` / `subdark` | Casts element + `SpellTier` on `<stnpc>` |
| `//gs c aoelight` / `aoedark` / `subaoelight` / `subaoedark` | Casts the AOE spell + `AOETier` on `<stnpc>` |
| `//gs c cyclemainlight` / `cyclemaindark` / `cyclesublight` / `cyclesubdark` | Cycles that element with a coloured chat line |
| `//gs c storm` | Casts the `Storm` spell on yourself, with Klimaform first when Klimaform is ready and not up. If Klimaform is neither up nor ready, shows its recast and casts nothing |
| `//gs c klima` (`klimaform`) | Dark Arts if it is down and ready, Manifestation if `KlimaformAOE` is On and a charge is left, then Klimaform |
| `//gs c buff` (`buffs`, `buffself`, `selfbuff`) | Casts Stoneskin, Blink, Aquaveil, Ice Spikes when missing, skipping those on recast |
| `//gs c lightarts` / `darkarts` | Light / Dark Arts, then the Addendum on the next press (/SCH) |
| `//gs c aoe sneak` / `aoe invi` / `aoe erase` | Sneak / Invisible / Erase through Light Arts and Addendum/Accession as charges allow (/SCH) |
| `//gs c dispel` | /RDM: Dispel on `<stnpc>`. /SCH: Addendum: Black (and Dark Arts) first. Other subjobs: a warning |

## Notes

- A tiered nuke steps down to the next lower tier that is off recast and affordable
  (a -ja falls back to -ga III, II, then the base -ga).
- With `MagicBurstMode` On, an elemental nuke also posts `Casting: [<spell>] => Nuke` in
  party chat (at most once every 2.5 s).
- Every mode goes back to its default on each job change, subjob change or reload.

## Files

`<Char>/config/blm/`: `BLM_STATES.lua` (modes), `BLM_KEYBINDS.lua` (keys), `BLM_CUSTOM.lua`
(your own modes and keys, see [keybinds](../../guides/keybinds.md)), `BLM_LOCKSTYLE.lua`
(style 5), `BLM_MACROBOOK.lua` (book 8 page 1 by default, other books per subjob and per
dual-box partner job), `BLM_TP_CONFIG.lua`, `BLM_MP_CONFIG.lua`, `BLM_ELEMENTAL_CONFIG.lua`.
