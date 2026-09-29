# BRD — set names and automatic gear

Every set name the Bard code reads, and everything it does with your gear on its own.
Mode meanings and keys: [states.md](states.md). Names shared by every job (Fast Cast,
subjob actions, movement, Doom, Dual Wield tiers, Treasure Hunter, Obi/Orpheus):
[set names](../../guides/sets.md).

An "instrument" here is the item in your `range` slot while you sing (Gjallarhorn,
Marsyas, Daurdabla, Loughnashade...). Songs are the one place where the Bard code
changes your `range` slot by itself, so most of this page is about it.

## Weapons

Your weapons are sets named after the value of the `MainWeapon` and `SubWeapon` modes.
They are put on top of your idle **and** engaged gear every time it is rebuilt,
in town too.

| Set | Worn when |
|---|---|
| `sets['Naegling']`, `sets['Twashtar']`, `sets['Carnwenhan']`, `sets['Mpu Gandring']` | `MainWeapon` has that value (a `main` piece) |
| `sets['Kraken']`, `sets['Demersal']`, `sets['Genmei']`, `sets['Centovente']` | `SubWeapon` has that value (a `sub` piece) |

- Add a weapon: add its name to `MainWeapon` or `SubWeapon` in `BRD_STATES.lua` and a
  set with that exact name.
- A value with no set of that name forces no weapon. If your
  `config/WEAPON_CONFIG.lua` has `equip_without_set = true`, a value that is an exact
  weapon name is put in its hand without a set.
- Buff songs swap your weapons (see [Songs](#songs)); the weapon sets come back as soon
  as the song is over and your idle or engaged gear is put back.

## Idle

| Set | Worn when |
|---|---|
| `sets.idle.Refresh`, `sets.idle.DT`, `sets.idle.Regen` | `IdleMode` has that value, outside town |
| `sets.idle` | The set of the current `IdleMode` does not exist |
| `sets.idle.Town` | Idle in a town (Dynamis excluded). Laid on top of the Idle Mode set: the slots it leaves out keep your idle pieces. The provided file builds it from `sets.idle.DT` plus `sets.MoveSpeed`, so every slot is set |
| `sets.Adoulin` | Idle in Western / Eastern Adoulin, checked before `sets.idle.Town`, laid on top of the Idle Mode set the same way. The provided file builds it from `sets.idle`, `sets.MoveSpeed` and Councilor's Garb |
| `sets.MoveSpeed` | Running, outside town |

Then the weapon sets.

## Engaged

The first line that matches wins:

| Set | Worn when |
|---|---|
| `sets.engaged.PDTKC` | Kraken Club is the off-hand you **wear** right now, whatever `EngagedMode` says |
| `sets.engaged.STP`, `.Acc`, `.DT`, `.SB` | `EngagedMode` has that value |
| `sets.engaged` | The set of the current mode does not exist |

Then the weapon sets (`sets.MoveSpeed` is asked for too, but in practice not added: see
[What the job does by itself](#what-the-job-does-by-itself)), then the common Dual Wield
tier pieces when your off-hand is a weapon.

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS['Name']` | That weaponskill: the provided file has `Savage Blade`, `Evisceration`, `Rudra's Storm`, `Mordant Rime`, `Ruthless Stroke` |
| `sets.precast.WS` | Any other weaponskill |

On top, Moonshade Earring goes in `ear1` when its +250 TP reaches the next step (2000
or 3000 TP). Aeneas and Centovente count as TP bonus when held, in either hand. The
list lives in `BRD_TP_CONFIG.lua`; how it works: [TP bonus gear](../war/tp-bonus.md).

## Job abilities

| Set | Worn when |
|---|---|
| `sets.precast.JA.Nightingale` | Nightingale (also when `//gs c songs` fires it through AutoNitro) |
| `sets.precast.JA.Troubadour` | Troubadour (same) |
| `sets.precast.JA['Soul Voice']` | Soul Voice |
| `sets.precast.JA.Marcato`, `sets.precast.JA.Pianissimo`, `sets.precast.JA['Clarion Call']`, `sets.precast.JA.Tenuto` | Those abilities, including the Marcato and Pianissimo the job sends by itself. None is in the provided file |

## Songs

### When you press the song (precast)

| Set | Worn when |
|---|---|
| `sets.precast.FC['Song name']` | That song: `sets.precast.FC['Honor March']` |
| `sets.precast.FC.<Family>` | Its family, as the game library groups songs: `sets.precast.FC.Lullaby`, `.Minuet`, `.March`, `.Madrigal`, `.Etude`, `.Carol`, `.Threnody`, `.Elegy`, `.Requiem`, `.Ballad`, `.Paeon`, `.Minne`, `.Mambo`, `.Prelude`, `.Mazurka` |
| `sets.precast.FC.Singing` or `sets.precast.FC.BardSong` | Any song (Singing is checked first) |
| `sets.precast.FC` | None of the above exists |

Honor March and Aria of Passion get their instrument (Marsyas / Loughnashade) put in
`range` by the job at this moment. If the Fast Cast set you wear for them has a
`range` piece of its own, that piece wins here; the instrument comes back while the
song is being sung.

### While the song is sung (midcast): buff songs

The first name that exists wins, from the most precise:

1. the exact name: `sets.midcast['Valor Minuet V']`, `sets.midcast["Army's Paeon"]`
2. the name without spaces: `sets.midcast.HonorMarch` (for Honor March; without it,
   Honor March takes `sets.midcast.March`)
3. the name without its tier: `sets.midcast['Valor Minuet']` (for Valor Minuet I to V)
4. the family, the last word of the name: `sets.midcast.Minuet`, `.March`,
   `.Madrigal`, `.Minne`, `.Etude`, `.Ballad`, `.Paeon`, `.Scherzo`, `.Carol`,
   `.Mambo`, `.Prelude`, `.Mazurka`, `.Hymnus`, `.Dirge`, `.Sirvente`...
5. the first word of the name, for a song whose family has no set:
   `sets.midcast.Aria` (Aria of Passion, whose last word is Passion)
6. `sets.midcast.BardSong`: every song with none of the above

Then, added on top of the set chosen:

| Set | Added when |
|---|---|
| `sets.midcast.Songs.Marsyas` | Honor March (the whole set goes on top). In the provided file it is only the instrument (`range`), so no Honor March piece is covered |
| `sets.midcast.Songs.Loughnashade` | Aria of Passion (same rule) |
| `sets.midcast.Songs.Duration` | Troubadour is up: song duration gear, on top of every song |
| `range` of `sets.midcast.Songs.<MainInstrument>` | Every buff song except Honor March and Aria of Passion: only the `range` piece of `sets.midcast.Songs.Gjallarhorn`, `.Daurdabla` or `.Marsyas`, following `MainInstrument` |

Last, Honor March always ends in Marsyas and Aria of Passion in Loughnashade, whatever
the sets say: without it the song fails.

### Dummy songs

Dummy songs are cheap songs sung only to open an extra song slot with a harp, then
overwritten by real songs. The list is in `BRD_SONG_CONFIG.lua` (`DUMMY_SONGS`): Gold
Capriccio, Goblin Gavotte, Fowl Aubade, Herb Pastoral, Shining Fantasia.

| Set | Worn when |
|---|---|
| `sets.midcast.DummySong` | Singing any song of that list |
| `sets.midcast['Gold Capriccio']`, `['Goblin Gavotte']`, `['Fowl Aubade']`, `['Herb Pastoral']`, `['Shining Fantasia']` | Not needed: `sets.midcast.DummySong` stays for the whole dummy song (the provided file keeps these copies; they are harmless) |

The `range` of `sets.midcast.DummySong` is also what `//gs c songs` and `//gs c dummy`
use to count slots: if that instrument, in the version you own, grants extra songs,
dummies are sung to open them. Name a harp you do not own, or no `range`, and no dummy
is sung.

### Debuff songs

Lullaby, Threnody, Elegy, Requiem, Virelai, Nocturne and Finale do **not** get the
main instrument of buff songs: each keeps the instrument of its own set. Keep `main`
and `sub` out of these sets, so your weapons (and TP) stay where they are.

| Set | Worn when |
|---|---|
| `sets.midcast['Foe Lullaby II']`, `['Horde Lullaby']`... | That song by exact name |
| `sets.midcast.Lullaby`, `.Threnody`, `.Elegy`, `.Requiem`... | Its family as the GearSwap library names it (Foe Requiem I to VII are `Requiem`, Ltng. Threnody II is a `Threnody`) |
| `sets.midcast.BardSong` | Nothing above exists. BardSong holds your song weapons: avoid landing here |

These songs keep that first choice for the whole cast: no instrument and no
`sets.midcast.Songs.Duration` layer on top, even under Troubadour (until
2026-09-28 a shared step re-picked them and added the Duration layer).

The provided file builds `sets.midcast.DebuffSong` as a base and copies it into
`Pining Nocturne`, `Magic Finale`, both Elegies, `Foe Requiem VII`, `Requiem` (every tier), `Maiden's
Virelai` and `Threnody`: the name `DebuffSong` itself is never picked.

### Other magic (subjob)

Healing, Enhancing, Enfeebling and Elemental spells follow the common names
([set names](../../guides/sets.md)). The provided file has `sets.midcast['Enhancing
Magic']` as an empty set and none of the other three.

## What the job does by itself

- **Weapons swapped for buff songs.** `sets.midcast.BardSong` (and every song set made
  from it) holds a `main` and `sub` (Carnwenhan / Kali in the provided file). Singing a
  buff song while fighting takes your melee weapons off, and TP with them. Leave `main`
  and `sub` out of the song sets, or turn Combat Mode on, to keep them.
- **Main instrument.** Every buff song except Honor March and Aria of Passion is sung
  with the instrument of `MainInstrument` (`^numpad3`): the job takes only the `range`
  piece of `sets.midcast.Songs.<value>`, so the family pieces of the song set stay. No
  such set, or no `range` in it: the song keeps its own instrument.
- **Instrument lock for Honor March and Aria of Passion.** Marsyas (Honor March) and
  Loughnashade (Aria of Passion) are put on when you press the song, forced again while
  it is sung, and forced again if your gear is refreshed during the song. The lock ends
  with the next finished action; a chat line confirms the release. The two songs are
  written in the job's code, not in a file.
- **Automatic Pianissimo.** A song aimed at another player (not charmed) without Pianissimo up is cancelled, Pianissimo is used, and the song is sung
  again once Pianissimo is on (`sets.precast.JA.Pianissimo` if you have one).
- **Automatic Marcato.** Before the song chosen by `MarcatoSong` (Honor March or Aria
  of Passion), when Nightingale and Troubadour are both up, Soul Voice is not, Marcato
  is not already up and is ready: Marcato is used first, then the song 2 seconds later.
  `MarcatoSong` Off turns it off.
- **AutoNitro.** `//gs c songs` opens with Nightingale then Troubadour when both are
  ready and Nightingale is not up (their JA sets are worn). The `AutoNitro` mode Off
  turns it off.
- **Song tier fallback.** A debuff song still on cooldown is replaced by another tier
  (Foe Lullaby II to Foe Lullaby, Carnage Elegy to Battlefield Elegy, Foe Requiem VII
  to VI, Threnody II to Threnody; Horde Lullaby goes **up** to Horde Lullaby II). The
  new song takes its own set: give the family names (`sets.midcast.Requiem`...) so it
  does not fall to `BardSong`. The provided file has `sets.midcast.Requiem` (the debuff
  set, no weapons) for every Foe Requiem tier. The list is `SONG_REFINE` in `BRD_SONG_CONFIG.lua`
  (`enabled = false` turns it off).
- **Kraken Club.** While the off-hand you wear is Kraken Club, the engaged set is
  `sets.engaged.PDTKC`, even in `EngagedMode` DT. It is read from what you wear, so
  the first rebuild after choosing `Kraken` still uses the mode's set.
- **Movement speed while fighting: in practice no.** BRD's engaged builder does ask for
  `sets.MoveSpeed` when you are moving, but movement is not tracked while you are
  engaged (the running flag is cleared), so it is not added. One exception: if you
  engage while running, the engaged set built at that moment can keep `sets.MoveSpeed`
  until the next gear change (your next action).
- **Weapon sets on idle.** The weapon sets go on idle as well, town included.
- **TP bonus earring.** Moonshade Earring in `ear1` on weaponskills when it reaches the
  next TP step ([Weaponskills](#weaponskills)).
- **Combat Mode.** When shown on BRD and On, it locks `main`, `sub` **and `range`**: no
  instrument can change, so songs keep whatever instrument you wear and Honor March /
  Aria of Passion fail without theirs. See
  [keybinds](../../guides/keybinds.md#combat-mode-every-job).

## Sets in the provided file that nothing reads

- `sets.midcast.AriaPassion`: the name tried for Aria of Passion is
  `sets.midcast.AriaofPassion` (name without spaces), then `sets.midcast.Aria`.
- `sets.midcast.DebuffSong` as a name (see [Debuff songs](#debuff-songs)).
- `sets.midcast.Songs.Gjallarhorn` / `.Daurdabla`: only their `range` piece is used
  (main instrument). `Songs.Marsyas` is only its instrument.

## Names the code reads that the provided file lacks

| Set | What it would do |
|---|---|
| `sets.midcast.Songs.Loughnashade` | Added on top of Aria of Passion |
| `sets.midcast.Songs.Duration` | Duration gear on every song under Troubadour |
| `sets.midcast.Prelude`, `.Mazurka`, `.Hymnus`, `.Sirvente`... | Families with no set of their own (they use `BardSong`) |
| `sets.precast.FC.BardSong` | Fast Cast for songs only (precast reads under `sets.precast.FC`, never `sets.precast.BardSong`) |
| `sets.precast.JA.Marcato`, `.Pianissimo`, `['Clarion Call']`, `.Tenuto` | Those abilities |

Check which set a song picked: `//gs c debugmidcast`, then sing.
