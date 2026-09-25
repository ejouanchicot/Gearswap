# BRD — modes and keys

Bard sings a whole song pack with one command. The modes pick the pack, the instrument,
what replaces Victory March, and the element of Carol and Threnody.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| Ctrl+Numpad4 `^numpad4` | `IdleMode` | Refresh, **DT**, Regen | Idle set |
| Ctrl+Numpad5 `^numpad5` | `EngagedMode` | **STP**, Acc, DT, SB | Engaged set (Store TP, accuracy, damage taken, Subtle Blow) |
| Ctrl+Numpad6 `^numpad6` | `SongMode` | Dirge, March, Madrigal, Minne, Etude, Tank, Healer, Carol, Scherzo, Arebati, **Ngai** | Song pack sung by `//gs c songs` (list below) |
| Ctrl+Numpad3 `^numpad3` | `MainInstrument` | **Gjallarhorn**, Daurdabla, Marsyas | Instrument for buff songs that do not need a specific one |
| Ctrl+Numpad7 `^numpad7` | `VictoryMarch` | **Madrigal**, Minuet, Etude, None | When you already have Haste, Victory March in the pack is replaced by Blade Madrigal, Valor Minuet III or the Etude of `EtudeType`. None keeps it |
| Ctrl+Numpad1 `^numpad1` | `MainWeapon` | Naegling, Twashtar, Carnwenhan, **Mpu Gandring** | Main weapon |
| Ctrl+Numpad2 `^numpad2` | `SubWeapon` | Kraken, Demersal, **Genmei**, Centovente | Off-hand |
| Apps+Numpad1 `#numpad1` | `EtudeType` | **STR**, DEX, VIT, AGI, INT, MND, CHR | Etude sung by `//gs c etude` and by the Etude replacement |
| Ctrl+Numpad0 `^numpad0` | `CarolElement` | **Fire**, Ice, Wind, Earth, Lightning, Water, Light, Dark | `//gs c carol` sings `<Element> Carol II` |
| Ctrl+Numpad. `^numpad.` | `ThrenodyElement` | same eight, **Fire** | `//gs c threnody` casts `<Element> Threnody II` on `<stnpc>` |
| Ctrl+Numpad8 `^numpad8` | `MarcatoSong` | **HonorMarch**, AriaPassion, Off | Marcato is used automatically before that song, only under Nightingale + Troubadour, without Soul Voice, and when Marcato is ready |

BRD has no `HybridMode` key: Ctrl+Numpad9 is left free.

## Song packs

Defined in `BRD_SONG_CONFIG.lua` (edit it to change a pack):

| Pack | Songs |
|---|---|
| Dirge | Honor March, Valor Minuet V, Valor Minuet IV, Adventurer's Dirge, Victory March |
| March | Honor March, Valor Minuet V, Valor Minuet IV, Victory March, Sentinel's Scherzo |
| Madrigal | Honor March, Valor Minuet V, Valor Minuet IV, Blade Madrigal, Victory March |
| Minne | Honor March, Valor Minuet V, Valor Minuet IV, Knight's Minne V, Victory March |
| Etude | Honor March, Valor Minuet V, Valor Minuet IV, Herculean Etude, Victory March |
| Tank / Healer | Victory March, Knight's Minne V, Mage's Ballad III, Mage's Ballad II, Sentinel's Scherzo |
| Carol | Honor March, Valor Minuet V, Valor Minuet IV, Fire Carol II, Victory March |
| Scherzo | Honor March, Valor Minuet V, Valor Minuet IV, Sentinel's Scherzo, Victory March |
| Arebati | Adventurer's Dirge, Honor March, Valor Minuet V, Valor Minuet IV, Knight's Minne V |
| Ngai | Honor March, Valor Minuet V, Water Carol II, Knight's Minne V, Sentinel's Scherzo |

## Commands

| Command | What it does |
|---|---|
| `//gs c songs` (`melee`, `meleesong`, `allsongs`) | Sings the pack on yourself: real songs, two dummy songs, then the last real songs over the dummies. 4 songs, or 5 under Clarion Call |
| `//gs c song1` … `song5` | Sings one song of the pack (after the Victory March replacement) |
| `//gs c dummy` (`dummysongs`), `dummy1`, `dummy2` | Dummy songs only |
| `//gs c carol` / `etude` / `threnody` | Carol / Etude / Threnody from the modes above |
| `//gs c lullaby`, `lullaby2` (`foe`), `elegy`, `requiem` | Horde Lullaby, Foe Lullaby II, Carnage Elegy, Foe Requiem VII on `<stnpc>` |
| `//gs c nt` | Nightingale, then Troubadour |
| `//gs c sv` / `ni` / `tr` / `ma` / `pi` | Soul Voice / Nightingale / Troubadour / Marcato / Pianissimo (`soul_voice`, `nightingale`, `troubadour`, `marcato`, `pianissimo` work too) |
| `//gs c forceidle` | Re-enables ring1 and puts the idle set's left ring back on |

## Notes

- A song aimed at another player gets Pianissimo automatically.
- The HUD shows your five current songs (`BRDSong1`-`5`, display only).
- `FastCast` (default 80, no key) is your Fast Cast %, used by the midcast watchdog (`//gs c cycle FastCast`, or its default in `BRD_STATES.lua`).
- Tetsouo's own folder changes the defaults: SongMode Madrigal, VictoryMarch Etude,
  MainWeapon list Mpu Gandring / Naegling, SubWeapon list Kraken / Centovente / Genmei
  (default Kraken).

## Files

`<Char>/config/brd/`: `BRD_STATES.lua`, `BRD_KEYBINDS.lua`, `BRD_CUSTOM.lua` (your own
modes and keys, see [keybinds](../../guides/keybinds.md)), `BRD_SONG_CONFIG.lua` (packs,
dummy songs), `BRD_TIMING_CONFIG.lua`, `BRD_LOCKSTYLE.lua` (style 7), `BRD_MACROBOOK.lua`
(book 40 page 1 by default, other books per subjob and per dual-box partner job),
`BRD_TP_CONFIG.lua`.
