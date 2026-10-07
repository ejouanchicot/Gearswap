# BRD — modes and keys

Bard sings a whole song pack with one command. The modes pick the pack, the instrument,
what replaces Victory March, and the element of Carol and Threnody.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

Start page for this job (every key, command and automatic feature): [README.md](README.md).
Set names and automatic gear: [sets.md](sets.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| Ctrl+Numpad4 `^numpad4` | `IdleMode` | Refresh, **DT**, Regen | Idle set outside town: `sets.idle.Refresh` / `.DT` / `.Regen` |
| Ctrl+Numpad5 `^numpad5` | `EngagedMode` | **STP**, Acc, DT, SB | Engaged set: `sets.engaged.STP` / `.Acc` / `.DT` / `.SB` (Store TP, accuracy, damage taken, Subtle Blow). The provided sets have no `.DT`: DT uses plain `sets.engaged`. With Kraken Club worn in the off hand, `sets.engaged.PDTKC` wins over every value |
| Ctrl+Numpad6 `^numpad6` | `SongMode` | Dirge, March, Madrigal, Minne, Etude, Tank, Healer, Carol, Scherzo, Arebati, **Ngai** | Song pack sung by `//gs c songs` (list below) |
| Ctrl+Numpad3 `^numpad3` | `MainInstrument` | **Gjallarhorn**, Daurdabla, Marsyas | Instrument for buff songs that do not need a specific one |
| Ctrl+Numpad7 `^numpad7` | `VictoryMarch` | **Madrigal**, Minuet, Etude, None | When Haste or Haste II is already on you, Victory March in the pack is replaced by Blade Madrigal, Valor Minuet III or the Etude of `EtudeType`. None keeps it |
| Ctrl+Numpad1 `^numpad1` | `MainWeapon` | Naegling, Twashtar, Carnwenhan, **Mpu Gandring** | Main weapon |
| Ctrl+Numpad2 `^numpad2` | `SubWeapon` | Kraken, Demersal, **Genmei**, Centovente | Off-hand |
| Apps+Numpad1 `#numpad1` | `EtudeType` | **STR**, DEX, VIT, AGI, INT, MND, CHR | Etude sung by `//gs c etude` and by the Etude replacement |
| Ctrl+Numpad0 `^numpad0` | `CarolElement` | **Fire**, Ice, Wind, Earth, Lightning, Water, Light, Dark | `//gs c carol` sings `<Element> Carol II` |
| Ctrl+Numpad. `^numpad.` | `ThrenodyElement` | same eight, **Fire** | `//gs c threnody` casts `<Element> Threnody II` on `<stnpc>` |
| Ctrl+Numpad8 `^numpad8` | `MarcatoSong` | **HonorMarch**, AriaPassion, Off | Marcato is used automatically before that song (then the song once Marcato is up), only on yourself, under Nightingale + Troubadour, without Soul Voice, and when Marcato is ready |
| Apps+Numpad2 `#numpad2` | `AutoNitro` | **On**, Off | On: `//gs c songs` first uses Nightingale, then Troubadour, when each is ready or already up, and starts the songs only once both are on (a refused ability is sent again; if one never goes, nothing is sung) |

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
| `//gs c songs` (`melee`, `meleesong`, `allsongs`) | Sings the pack on yourself: the songs your main instrument holds, then the dummy songs, then the rest of the pack over the dummies. How many: 2 songs, plus what your instruments add (read from the version you own: Daurdabla, Loughnashade, Terpander, Blurred Harp +1...), plus 1 under Clarion Call, never more than the pack; dummies only for slots none of your own songs holds yet. Each song goes out once the previous one is over; an interrupted or refused song is tried twice more, then skipped with a warning. When no dummy is needed (your songs are only sung again), they go **in the order they wear off**, the one with the least time left first. **Nothing is sent** (no Nightingale, no song) when every song of the pack is yours and has more than 3 minutes left: `brd_songs_refresh_below` in `_common/combat/TUNING.lua`, in seconds, 0 to always sing. A second `songs` while Nightingale / Troubadour are going out is ignored |
| `//gs c songs force` | Sings the pack even when every song has time left |
| `//gs c songs full` | The same, with every dummy song whatever is already up (another bard's songs on you) |
| `//gs c songplan` | What `songs` would do now: Clarion Call, main and dummy instrument with the extra songs each gives, songs up (yours / all), the plan |
| `//gs c songstop` | Stops a running rotation |
| `//gs c song1` … `song5` | Sings one song of the pack (after the Victory March replacement) |
| `//gs c dummy` (`dummysongs`), `dummy1`, `dummy2` | Dummy songs only: as many as your dummy harp adds over your main instrument / the first / the second of the list |
| `//gs c carol` / `etude` / `threnody` | Carol / Etude / Threnody from the modes above |
| `//gs c lullaby`, `lullaby2` (`foe`), `elegy`, `requiem` | Horde Lullaby, Foe Lullaby II, Carnage Elegy, Foe Requiem VII on `<stnpc>` (other spells: `brd_debuff_songs` in `_common/combat/TUNING.lua`) |
| `//gs c nt` | Nightingale, then Troubadour 2 s later (`BRD_TIMING_CONFIG.lua`) |
| `//gs c sv` / `ni` / `tr` / `ma` / `pi` | Soul Voice / Nightingale / Troubadour / Marcato / Pianissimo (`soul_voice`, `nightingale`, `troubadour`, `marcato`, `pianissimo` work too) |
| `//gs c forceidle` | Re-enables ring1 and puts the idle set's left ring back on |

## Notes

- A song aimed at another player gets Pianissimo automatically.
- A debuff song still on cooldown is sung at another tier (`SONG_REFINE` in
  `BRD_SONG_CONFIG.lua`): `lullaby` can become Horde Lullaby II, `lullaby2` Foe
  Lullaby, `elegy` Battlefield Elegy, `requiem` Foe Requiem VI, a Threnody II its
  Threnody.
- Combat Mode (hidden on BRD) also locks the instrument slot: see
  [README.md](README.md#shared-features-on-this-job) before showing it.
- **Next song as a dummy** (optional switch): add to your `BRD_CUSTOM.lua`

  ```lua
  { state = 'DummySong', desc = 'Dummy Song', key = '!numpad5', values = 'onoff' },
  ```

  (any free key; no gear block). While it is On, your next buff song is sung in
  `sets.midcast.DummySong`, dummy instrument included and weapons unchanged: a
  short-timer copy that overwrites the same song already up, so the game replaces
  that one first. The switch turns itself Off once the song landed (it stays On
  if the song was interrupted). Honor March, Aria of Passion, debuff songs and
  your listed dummy songs are never changed by it.
- The HUD shows the five songs of the current pack (`BRDSong1`-`5`, display only),
  after the Victory March swap.
- `FastCast` (default 80, no key) is your Fast Cast %, used by the midcast watchdog (`//gs c cycle FastCast`, or its default in `BRD_STATES.lua`).
- The author's own files change the defaults: SongMode Madrigal, VictoryMarch Etude,
  MainWeapon list Mpu Gandring / Naegling, SubWeapon list Kraken / Centovente / Genmei
  (default Kraken).

## Files

`<Char>/brd/`: `BRD_STATES.lua`, `BRD_KEYBINDS.lua`, `BRD_CUSTOM.lua` (your own
modes and keys, see [keybinds](../../guides/keybinds.md)), `BRD_SONG_CONFIG.lua` (packs,
dummy songs, tier fallback), `BRD_TIMING_CONFIG.lua` (gap between songs), `BRD_HUD.lua`
(HUD order), `BRD_LOCKSTYLE.lua` (style 7), `BRD_MACROBOOK.lua` (book 40 page 1 by
default, other books per subjob and per dual-box partner job), `BRD_TP_CONFIG.lua`, and
`BRD_REFILL.lua` (every line commented at first: the common refill list applies). What each file holds:
[README.md](README.md#configuration-files-for-this-job).
