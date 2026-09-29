# Set names

Your gear lives in `<YourName>/sets/<job>_sets.lua`. GearSwap picks a set by its
**name**: write a set under the right name and it is used, with no code to touch.
A set left out is simply not worn (the set above it stays on).

This page lists the names every job understands: the ones for any action,
the ones for your subjob's actions (Utsusemi, Waltz, Cure...), and the ones
the shared systems put on by themselves (movement, Doom, Dual Wield,
Treasure Hunter). Each job's own names (weapons, modes, job abilities with
special handling) are on its page: [jobs](../jobs/README.md).

To see which set was chosen for a spell: `//gs c debugmidcast`, then cast.

## How a name is chosen

Every action has two moments:

- **precast**: when you press it. For a spell, this is the cast start: wear
  Fast Cast (shorter casting). For a weaponskill or an ability, the effect
  happens right away, so this set is the one that counts.
- **midcast**: while the spell is being cast, the set that boosts its effect
  (healing, damage, accuracy...). Also used for ranged attacks.

In each family, the most precise name wins. For a spell, from the most precise
to the least:

1. its exact name: `sets.midcast['Cure III']`
2. its name without the tier: `sets.midcast.Cure` (for Cure, Cure II, Cure III...)
3. what the job's own code adds (the target, a mode, a spell family: see the
   job's page)
4. its family name when it has one: `sets.midcast.Utsusemi` (Ichi, Ni, San),
   `sets.midcast.BarElement` (Barfire, Barblizzard...), `sets.midcast.Storm`
5. its magic skill: `sets.midcast['Healing Magic']`, `sets.midcast.Ninjutsu`...

Precast works the same way under `sets.precast.FC`: `sets.precast.FC['Cure III']`,
then `sets.precast.FC.Cure`, then the skill
`sets.precast.FC['Healing Magic']`, then `sets.precast.FC` itself.

A set can also depend on a mode (for example `sets.precast.WS['Savage Blade'].Acc`
while the weaponskill mode is Acc): the job's page says which modes it has.

## Any job

| Set | Worn when |
|---|---|
| `sets.idle` | Standing, not fighting (the job's page gives its modes: `sets.idle.PDT`...). On DNC, DRK, THF and WAR, outside town, `sets.idle.<Hybrid Mode>` replaces it when it exists (`sets.idle.PDT` in PDT) |
| `sets.engaged` | Weapon out, fighting (modes on the job's page) |
| `sets.precast.FC` | Casting any spell (Fast Cast). Also forced on warp spells (Warp, Retrace, Escape, Teleport-*, Recall-*) |
| `sets.precast.JA['Name']` | Using the job ability `Name`: `sets.precast.JA['Provoke']`, `sets.precast.JA.Berserk` |
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Name']` | That weaponskill: `sets.precast.WS['Savage Blade']` |
| `sets.precast.RA` / `sets.midcast.RA` | Ranged attack: when you shoot / while the shot flies |
| `sets.midcast['Skill']` | Any spell of that skill (list below) |
| `sets.midcast['Name']` | That spell |
| `sets.midcast.FastRecast` | Put on **first** at the start of every spell's midcast, before the spell's own set. A spell set that leaves a slot out keeps the FastRecast piece there (Mote-Include's global midcast layer) |
| `sets.resting` | Resting (`/heal`). `sets.resting.<RestingMode>` when the job has a Resting Mode |

Magic skills: `Healing Magic`, `Enhancing Magic`, `Enfeebling Magic`,
`Elemental Magic`, `Dark Magic`, `Divine Magic`, `Ninjutsu`, `Blue Magic`,
`Singing`, `Geomancy`, `Summoning Magic`.

### Casting Mode `.Resistant` children

On a job with a Casting Mode (the key is on the job's page), the value
`Resistant` picks a `.Resistant` child of the set that was chosen, when you
define one: `sets.precast.FC.Resistant`, `sets.midcast['Elemental Magic'].Resistant`,
`sets.midcast['Enfeebling Magic'].Resistant`. No child: the set itself is
used. Some jobs look for more `.Resistant` names in their own order (BLU,
WHM, SMN): see the job's page.

### Mote-Include's layers: defense, Kiting, weakness

Mote-Include (the library under every job file) has three more names. They
work only on jobs that keep the idle / engaged set Mote-Include builds and add
to it. A job that builds its idle or engaged set from its own modes ignores
them. The job's set page says which case applies; when it says nothing about
them, do not count on them.

| Set | Worn when | Default key (Mote-Include) |
|---|---|---|
| `sets.defense.PDT` | Defense Mode Physical: on top of the idle and engaged set | F10 on, Alt+F12 off |
| `sets.defense.MDT` | Defense Mode Magical: same | F11 on, Alt+F12 off |
| `sets.Kiting` | Kiting on: on top of the idle and engaged set | Alt+F10 (toggle) |
| `sets.idle.Weak` | Weakened after a Raise (the `Weakness` status), in place of `sets.idle` | - |

Documented today: they work on BLU and WHM (outside a city), DRK and THF read
`sets.idle.Weak`, RDM ignores all of them. SAM wears `sets.idle.Weak` also
below 50 % HP (see [SAM](../jobs/sam/sets.md)).

## Your subjob's actions

These names work on every job. None exists in the provided sets of a job that
does not use it: add the ones you want.

| Subjob | Action | Set names |
|---|---|---|
| /NIN | Utsusemi | Precast: `sets.precast.FC.Utsusemi` (or `sets.precast.FC.Ninjutsu`, or plain `sets.precast.FC`). Midcast: `sets.midcast.Utsusemi` (Fast Cast again, so the next one is ready sooner; Utsusemi has no potency) |
| /NIN | Other ninjutsu (Monomi, Tonko) | `sets.midcast.Ninjutsu` |
| /DNC | Curing Waltz, Divine Waltz | `sets.precast.Waltz` (Waltz potency, CHR, VIT) |
| /DNC | Steps (Box Step, Quickstep...) | `sets.precast.Step` (accuracy) |
| /DNC | Flourishes | `sets.precast.Flourish1` (Violent / Animated...), `Flourish2` (Reverse...), `Flourish3` (Climactic...) |
| /DNC | Samba, Jig | `sets.precast.Samba`, `sets.precast.Jig` |
| /WHM, /RDM, /SCH | Cure | `sets.precast.FC.Cure` (Cure spellcasting time), `sets.midcast.Cure` (cure potency). Curaga: `sets.midcast.Curaga` |
| /WHM, /RDM | Enhancing (Haste, Refresh, Protect...) | `sets.midcast['Enhancing Magic']`, or one spell: `sets.midcast.Refresh`, `sets.midcast.Haste` |
| /WHM | Poisona, Paralyna... | `sets.midcast.StatusRemoval` |
| /RDM, /BLM | Enfeebling (Slow, Paralyze, Sleep...) | `sets.midcast['Enfeebling Magic']` (magic accuracy) |
| /BLM, /RDM, /SCH | Nukes | `sets.midcast['Elemental Magic']` |
| /DRK, /BLM, /RDM, /SCH | Drain, Aspir, Stun | `sets.midcast['Dark Magic']`, or `sets.midcast.Stun`, `sets.midcast.Drain`, `sets.midcast.Aspir` |
| /SCH | Stratagems, Sublimation | `sets.precast.JA.Sublimation`; the stratagems (Light Arts, Penury...) by name under `sets.precast.JA` |
| /SCH | Storms, Helix | `sets.midcast.Storm`, `sets.midcast.Helix` |
| /WAR, /SAM, /PLD, /RUN... | Job abilities | `sets.precast.JA['Name']` (Provoke, Berserk, Meditate, Sentinel, Swordplay...) |
| /COR | Rolls, Quick Draw | `sets.precast.CorsairRoll`, `sets.precast.CorsairShot` |
| /RUN | Runes, Wards, Effusions | `sets.precast.Rune`, `sets.precast.Ward`, `sets.precast.Effusion` (or by name under `sets.precast.JA`) |

A name above that your job's page gives differently: the job's page wins
(PLD, RUN and WHM build their own Cure sets, for example).

## Put on by themselves

These sets are worn without any action from you, when they exist:

| Set | When | Notes |
|---|---|---|
| `sets.MoveSpeed` | You are running and not fighting, outside a town | Movement speed gear, on top of the idle set. Movement is not tracked while you are engaged, so it never goes on the engaged set. Exceptions below |
| `sets.idle.Town` | Idle in a town (Dynamis excluded) | Laid on top of the idle set of your Idle Mode: slots it leaves out keep your idle pieces |
| `sets.Adoulin` | Idle in Western / Eastern Adoulin | Checked before `sets.idle.Town`, laid on top of the idle set the same way |
| `sets.buff.Doom` | You are Doomed | Doom removal gear (Nicander's Necklace, Purity Ring...). Neck, both rings and belt stay locked until Doom is gone |
| `sets.DW.NoHaste`, `.Haste`, `.HasteII`, `.MaxHaste` | Two weapons held, fighting | Dual Wield pieces by your magic haste ([configuration](configuration.md), `DW_CONFIG.lua`, `//gs c dw`) |
| `sets.SingleWield` | A weapon set (`MainWeapon` / `SubWeapon`) carries an off-hand weapon and you cannot dual wield: main job not NIN, DNC, THF or BLU, and no /NIN at level 10+ or /DNC at level 20+ (a subjob at level 0, as in Sheol Gaol, counts as none) | Only its `sub` is read, e.g. `sets.SingleWield = { sub = "Nusku Shield" }`; it replaces the off-hand weapon. Without the set, the off hand is left out. Shields and grips in weapon sets are kept. Every job whose weapons come from weapon modes, except PLD and BST |
| `sets.CombatMode` | You turn Combat Mode On (not during a craft) | Put on just before the weapon lock, then held by it. Without the set, what you wear is locked. Only the BLM file provides one |
| `sets.TreasureHunter` | Treasure Mode on, against a mob not tagged yet | [commands](commands.md) `//gs c th`. Off on every job but THF until `//gs c th show` |

Jobs that differ from the table above (details on each job's set page):

| Job | Difference |
|---|---|
| WHM | `sets.MoveSpeed` goes on in town too |
| BST | `sets.idle.Town` is not used: in a town the whole `sets.me.idle.Town` goes on top of the pet or master idle (`sets.Adoulin` instead in Adoulin, if you have one), then your weapons, and no `sets.MoveSpeed`. Idle only: nothing of this while engaged |
| GEO | In the provided file `sets.idle.Town` is the same set as `sets.me.idle.Town` |
| PLD, RUN, WAR, COR, DRK, SAM | In town: the town set plus your weapon, nothing else (no mode set, no `sets.MoveSpeed`; on SAM no `sets.idle.Weak`, `.Regen` or `.PDT`). On WAR, the Hoxne stance also keeps its Hoxne Ampulla in town |

Hachirin-no-Obi and Orpheus's Sash need no set: they go on by themselves on
elemental damage when they help ([configuration](configuration.md),
`ELEMENTAL_BELT.lua`, `//gs c belt`).

Your own conditions (a piece at low HP, a ring at night, a state of your own)
go in `<JOB>_CUSTOM.lua`, not in a set: see [keybinds](keybinds.md). They are
put on last and win over everything above.

## Check your sets

- `//gs c checksets`: pieces of your sets you do not have in your inventory or wardrobes.
- `//gs c debugmidcast`: for each spell, the set chosen and why.
- `//gs c wa`: pieces in your wardrobes that no set file uses.
