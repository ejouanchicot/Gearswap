# BST — set names and automatic gear

Every set name the Beastmaster code reads, and everything the job puts on by itself.
Modes and keys: [states.md](states.md). Names shared by every job (subjob actions,
`sets.MoveSpeed`, `sets.buff.Doom`, Dual Wield tiers, Treasure Hunter, elemental
belts): [set names](../../guides/sets.md). They all work on BST; this page only
repeats one when BST handles it differently.

BST does not use the flat `sets.idle` / `sets.engaged` like most jobs. Its gear is
split in two groups: `sets.me` (you) and `sets.pet` (your pet). The job picks the
group from whether a pet is out and what it is doing.

## Idle

Picked every time your gear is refreshed while you are not fighting.

| Set | Worn when |
|---|---|
| `sets.me.idle` | No pet out. With Hybrid Mode on PDT, `sets.me.idle.PDT` goes on top |
| `sets.me.idle.PDT` | A pet is out, not fighting, and Pet Idle Mode is **MasterPDT** (whatever Hybrid Mode says) |
| `sets.pet.idle.PDT` | A pet is out, not fighting, and Pet Idle Mode is **PetPDT** (whatever Hybrid Mode says). Falls back to `sets.pet.idle` if missing |
| `sets.pet.engaged` | Your pet is fighting and you are not. With Hybrid Mode on PDT, `sets.pet.engaged.PDT` goes on top |
| `sets.me.idle.Town` | In a town (Adoulin included, Dynamis excluded): **only its feet** are used, on top of whichever set above, pet out or not |

Then, on top of all of them, in this order:

1. your weapons (see [Weapons](#weapons));
2. `sets.MoveSpeed` while you are running;
3. the feet of `sets.me.idle.Town` in a town.

Two catch-all names are also read: `sets.me.PDT` and `sets.pet.PDT`. When Hybrid
Mode is PDT and a situation has no `.PDT` of its own (for example no
`sets.pet.engaged.PDT`), the catch-all of its group is laid on top instead.

Differences with the common names:

- `sets.idle.Town` and `sets.Adoulin` are **not used** on BST. Town gear is the
  feet of `sets.me.idle.Town`, nothing else.
- `sets.idle` is only a last resort, worn when `sets.me.idle` does not exist.
  The provided file defines it as a copy of `sets.me.idle`.

## Engaged

Picked while you are fighting.

| Set | Worn when |
|---|---|
| `sets.me.engaged` | You fight, and there is no pet or your pet is not fighting. With Hybrid Mode on PDT, `sets.me.engaged.PDT` on top |
| `sets.pet.engagedBoth` | You and your pet both fight. With Hybrid Mode on PDT, `sets.pet.engagedBoth.PDT` on top. Falls back to `sets.me.engaged` if missing |

Your weapons go on top. `sets.MoveSpeed` and the town feet are never added while
engaged. `sets.engaged` is only a last resort when `sets.me.engaged` does not
exist (the provided file makes it a copy). Dual Wield tier pieces (`sets.DW...`,
see the common page) are added while engaged with two weapons, for example an
axe in each hand under /NIN or /DNC.

"Your pet is fighting" is read from the game once per second (see
[What the job does by itself](#what-the-job-does-by-itself)), so the switch
between these sets can lag by up to a second.

## Weapons

| Set | Worn when |
|---|---|
| `sets['Aymur']`, `sets['Tauret']` | The main weapon mode (`WeaponSet`, Ctrl+Numpad1) has that value |
| `sets["Agwu's Axe"]`, `sets['Adapa Shield']`, `sets['Diamond Aspis']`, `sets['Kraken Club']` | The off-hand mode (`SubSet`, Ctrl+Numpad2) has that value |

The set name is exactly the mode's value. If you change the values in
`BST_STATES.lua`, name your sets after the new values. The weapon sets go on top
of every idle and engaged set.

## Calling a pet

| Set | Worn when |
|---|---|
| `sets.precast.JA['Call Beast']` | Using **Call Beast** or **Bestial Loyalty** |
| `sets.precast.JA['Bestial Loyalty']` | Using Bestial Loyalty, on top of the Call Beast set |
| `sets['<Pet name (Species)>']` | Only its `ammo` is used: it is the jug put in the ammo slot for Call Beast / Bestial Loyalty |

Which jug: the pet chosen with the Ecosystem and Species modes (Ctrl+Numpad5 /
Ctrl+Numpad6). There must be one set per pet, named exactly like the pet in
`BST_PET_DATA.lua`, holding only the jug:

```lua
sets['Warlike Patrick (Lizard)'] = {ammo = 'Livid Broth'}
```

The provided file has all 25 pets of `BST_PET_DATA.lua`:
Amiable Roche (Fish), Jovial Edwin (Crab), Fluffy Bredo (Acuex),
Sultry Patrice (Slime), Fatso Fargann (Leech), Generous Arthur (Slug),
Blackbeard Randy (Tiger), Rhyming Shizuna (Sheep), Pondering Peter (Rabbit),
Vivacious Vickie (Raaz), Choral Leera (Colibri), Daring Roland (Hippogryph),
Swooping Zhivago (Tulfaire), Warlike Patrick (Lizard), Suspicious Alice (Eft),
Brainy Waluis (Funguar), Sweet Caroline (Mandragora), Bouncing Bertha (Chapuli),
Threestar Lynn (Ladybug), Headbreaker Ken (Fly), Energized Sefina (Beetle),
Anklebiter Jedd (Diremite), Left-Handed Yoko (Mosquito),
Cursed Annabelle (Antlion), Weevil Familiar (Weevil).

A pet you add to `BST_PET_DATA.lua` needs its own set here, or no jug is put on
(and changing species prints "No equipment set found").

**Never put an `ammo` in the Call Beast or Bestial Loyalty set.** Those sets are
put on again after the jug, so their ammo would replace it and call the wrong
pet (or none). The provided sets have no ammo.

## Ready moves

A Ready move goes through three steps, each with its own gear:

| Step | Set | Worn when |
|---|---|---|
| 1. You give the order | `sets.precast.JA['Sic']` | Any Ready move the job knows (and Sic itself). Ready recast gear goes here |
| 2. The order is accepted | the category set below | From the moment the game accepts your order until your pet has finished the move |
| 3. The move is done | idle / engaged | Your normal gear comes back when the pet's move ends |

The category set, by the kind of move:

| Set | Moves |
|---|---|
| `sets.midcast.pet_physical_moves` | Single-hit physical moves |
| `sets.midcast.pet_physicalMulti_moves` | Multi-hit physical moves |
| `sets.midcast.pet_magicAtk_moves` | Magic damage moves |
| `sets.midcast.pet_magicAcc_moves` | Debuffs, drains and the pet's own buffs |

While **you** are engaged, the name with `_ww` at the end is used instead:
`sets.midcast.pet_physical_moves_ww`, `pet_physicalMulti_moves_ww`,
`pet_magicAtk_moves_ww`, `pet_magicAcc_moves_ww`. If the `_ww` set is missing,
the plain one is used. In the provided file each `_ww` set is the same as the
plain one.

Moves in each category (the list the job uses; the lists written in the sets
file are not read, see below):

- **Physical** (47): Foot Kick, Whirl Claws, Big Scissors, Tail Blow, Blockhead,
  Brain Crush, Sensilla Blades, Tegmina Buffet, Lamb Chop, Sheep Charge,
  Swooping Frenzy, Recoil Dive, Frogkick, Queasyshroom, Numbshroom, Shakeshroom,
  Nimble Snap, Cyclotail, Somersault, Spinning Top, Suction, Tortoise Stomp,
  Power Attack, Rhino Attack, Razor Fang, Claw Cyclone, Sickle Slash,
  Mandibular Bite, Scythe Tail, Ripper Fang, Beak Lunge, Spiral Spin,
  Sudden Lunge, Head Butt, Wild Oats, Leaf Dagger, Needleshot, ??? Needles,
  Disembowel, Extirpating Salvo, Mega Scissors, Rhinowrecker, Back Heel,
  Fluid Toss, Fluid Spread, Fantod, Crossthrash.
- **PhysicalMulti** (9): Pentapeck, Tickling Tendrils, Wing Slap,
  Pecking Flurry, Chomp Rush, Hoof Volley, Sweeping Gouge, Double Claw, Grapple.
- **MagicAtk** (22): Venom, Fireball, Snow Cloud, Dust Cloud, Acid Spray,
  Molting Plumage, Cursed Sphere, Acid Mist, Purulent Ooze, Stink Bomb,
  Nectarous Deluge, Charged Whisker, Dark Spore, Silence Gas, Nepenthic Plunge,
  Corrosive Ooze, Bubble Shower, Venom Shower, Gloom Spray, Foul Waters,
  Pestilent Plume, Aqua Breath.
- **MagicAcc** (42): Drainkiss, TP Drainkiss, Sheep Song, Soporific, Scream,
  Dream Flower, Roar, Spoil, Noisome Powder, Infrasonics, Hi-Freq Field,
  Geist Wall, Nihility Song, Digest, Wild Carrot, Bubble Curtain, Scissor Guard,
  Metallic Body, Harden Shell, Secretion, Rage, Frenzied Rage, Zealous Snort,
  Rhino Guard, Water Wall, Palsy Pollen, Spore, Gloeosuccus, Intimidate,
  Spider Web, Filamented Hold, Toxic Spit, Venom Spray, Infected Leech,
  Choke Breath, Chaotic Eye, Sandblast, Sandpit, Predatory Glare, Numbing Noise,
  Jettatura, Blaster.

A move in none of these lists (one added to the game later) gets neither the Sic
set nor a category set: only your normal gear.

A move the game refuses or interrupts (no charge, pet too far...) does not keep
the category set: your normal gear comes back at once.

### Other names read during a Ready move

The underlying library also looks these up. None exists in the provided file;
add one only if you mean it:

| Set | Worn when | Beware |
|---|---|---|
| `sets.precast.JA['<move name>']`, e.g. `sets.precast.JA['Foot Kick']` | Step 1 for that move, on top of the Sic set | Its pieces replace the Ready recast pieces in the same slots |
| `sets.precast.JA.Monster` | Step 1 for every move without a set of its own, on top of the Sic set | Same |
| `sets.midcast['<move name>']` or `sets.midcast.Monster` | Between step 1 and step 2, for a moment | Replaces the Sic pieces before the order is sent |
| `sets.midcast.Pet`, or per move `sets.midcast.Pet['<move name>']` | When your pet starts the move, on top of the category set | Its slots replace the category set's pieces for the rest of the move |

## Other job abilities

Any job ability or pet command uses `sets.precast.JA['Name']` (common rule). The
provided file has:

| Set | Worn when |
|---|---|
| `sets.precast.JA['Reward']` | Reward. The game needs Pet Food in the ammo slot: the provided set holds `Pet Food Theta` |
| `sets.precast.JA['Killer Instinct']` | Killer Instinct. The provided set also changes your off-hand to Diamond Aspis; your off-hand set comes back afterwards, but changing the off-hand costs your TP |
| `sets.precast.JA['Spur']` | Spur |
| `sets.precast.JA['Sic']` | Sic, and every Ready move (above) |
| `sets.precast.JA['Ready']` | Only if an action named "Ready" is used. Ready moves use the Sic set, not this one (the provided file makes it a copy of Sic) |

Any other ability works the same way if you add its set: Charm (CHR),
`Tame`, `Feral Howl`, `Familiar`, `Unleash`, `Snarl`, `Run Wild`, and pet
commands such as `Fight`, `Heel`, `Stay`, `Leave`.

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Primal Rend']`, `['Decimation']`, `['Bora Axe']`, `['Calamity']` | That weaponskill (provided). Any other weaponskill by its name |

BST has no weaponskill mode, so only these plain names are read. A weaponskill
under 1000 TP is cancelled with a message.

**TP bonus earring, by itself:** when a Moonshade Earring would carry your TP to
the next step (2000 or 3000), it is put in the left ear on top of the weaponskill
set. The piece and its bonus come from `BST_TP_CONFIG.lua` (`pieces`), which also
counts your Fencer bonus (`fencer_jp_gifts`). No set is needed for this.

## Subjob magic

BST sends your subjob's Healing, Enhancing, Enfeebling, Elemental and Blue Magic
to the common rules (`sets.midcast['Healing Magic']`, `sets.midcast.Cure`...), and
Fast Cast to `sets.precast.FC`. The provided file has none of these: add the ones
you want (see the common page).

## What the job does by itself

- **Pet status check, every second.** As long as you are on BST, the job looks at
  your pet once per second. When the pet starts or stops fighting, your gear is
  refreshed (pet sets above). Nothing to turn on or off.
- **Pet sent in automatically.** With Auto Pet Engage **On** (the default,
  Ctrl+Numpad4), when you are fighting and your pet is not, the job sends
  `/pet "Fight" <t>` (your current target), and keeps sending it every second
  until the pet fights. A Heel while you are engaged is therefore undone within a
  second. Turn Auto Pet Engage Off to control the pet yourself. It pauses while a
  `//gs c rdymove` sequence runs.
- **Ready gear held until the move lands.** After a Ready order, the category set
  stays on until your pet has finished the move, then your normal gear returns.
  A refused or interrupted move returns your normal gear at once.
- **Ready recast gear.** Every known Ready move puts on `sets.precast.JA['Sic']`
  first, without any cooldown check (the game checks the charges itself).
- **Jug put in by itself.** Call Beast and Bestial Loyalty put the jug of the
  selected pet in the ammo slot, after their own set.
- **Jug message on mode change.** Changing ecosystem or species prints
  "Equipping <jug> for <pet>". Nothing is actually equipped at that moment: the
  jug only goes on when you use Call Beast / Bestial Loyalty.
- **Pet appears or disappears.** Your gear is refreshed (pet sets or master sets).
- **Town feet.** In a town, the feet of `sets.me.idle.Town` go on while idle, even
  with a pet out.
- **BST-HUD addon.** Loading BST unloads and reloads the `BST-HUD` addon (about
  3.5 s after the load); leaving BST unloads it.

## Sets in the provided file that nothing reads

- `sets['Blur Knife']`: not a value of the off-hand mode. Add `Blur Knife` to
  `SubSet` in `BST_STATES.lua` to use it.
- `sets.precast.JA['Misc Idle']` and `sets.precast.JA['Default']`.
- `sets.precast.WS.TPBonus` and the four `sets.precast.WS['<name>'].TPBonus`:
  the TP bonus earring is put on by itself (see Weaponskills), these sets are
  never picked.
- The four Ready move lists at the top of the file (`petPhysicalMoves`,
  `petPhysicalMultiMoves`, `petMagicAtkMoves`, `petMagicAccMoves`): the job uses
  its own lists (above). Editing them changes nothing.
- `sets.me.idle.Town`: every slot except the feet.

## Names the code reads that the provided file lacks

- `sets.me.PDT`, `sets.pet.PDT` (catch-all PDT pieces, see Idle).
- `sets.precast.FC` and the subjob magic sets (see Subjob magic).
- `sets.precast.JA` for Charm, Tame, Feral Howl, Familiar, Unleash, Snarl,
  Run Wild and the pet commands.
- `sets.DW.NoHaste` / `.Haste` / `.HasteII` / `.MaxHaste` (written as a comment
  at the end of the file) and `sets.TreasureHunter` (common page).
- The optional Ready names in [Other names read during a Ready move](#other-names-read-during-a-ready-move).
