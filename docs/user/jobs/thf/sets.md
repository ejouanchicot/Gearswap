# THF — set names and automatic gear

Every set name THF reads in `<YourName>/thf/thf_sets.lua`, and everything the
job puts on by itself. Keys and modes: [states.md](states.md). Names every job
understands (Fast Cast, subjob actions, Doom, Dual Wield, movement...):
[set names](../../guides/sets.md).

## Idle

| Set | Worn when |
|---|---|
| `sets.idle` | Standing, not fighting, when the Hybrid Mode has no idle set of its own |
| `sets.idle.PDT` | Hybrid Mode PDT (the default), outside town. Replaces `sets.idle` whole |
| `sets.idle.<Hybrid Mode>` | Any Hybrid Mode value with a set of that name (`sets.idle.Normal`: not in the provided file), outside town |
| `sets.idle.Weak` | Weakened (after a raise), outside town, only when the Hybrid Mode has no idle set (the PDT set wins) |
| `sets.idle.Town` | In a town (Dynamis excluded). Laid on top of `sets.idle` |
| `sets.Adoulin` | In Western / Eastern Adoulin, checked before `sets.idle.Town`, laid on top of `sets.idle` the same way |
| `sets.MoveSpeed` | Running, outside town only |

Your weapons (see Weapons below) go on top of every idle set, town included.
Sneak Attack, Trick Attack and Treasure Hunter gear never go on the idle set.

## Engaged

The engaged set is chosen in this order, the first that exists wins:

| Set | Worn when |
|---|---|
| `sets.engaged.PDTAFM3` | Aftermath: Lv.3 is up **and** your Main Weapon mode is Vajra. Used whatever the Hybrid Mode |
| `sets.engaged.PDT` | Hybrid Mode PDT (the default) |
| `sets.engaged.Normal` | Hybrid Mode Normal |
| `sets.engaged` | When the set above is missing (the provided file has no `sets.engaged.Normal`, so Normal wears this one) |

Then, on top, in this order (a later layer wins a slot):

1. Your weapons (Main Weapon + Sub Weapon, or the Abyssea pair).
2. The Dual Wield tier pieces (`sets.DW.*`, [set names](../../guides/sets.md)).
3. Sneak Attack / Trick Attack gear while the buff is up (see below).
4. `sets.TreasureHunter` while Treasure Hunter wants it (see below).

So a Sneak Attack, Trick Attack or Treasure Hunter piece always wins its slot over a
Dual Wield piece, as Treasure Hunter does on every job.

## Sneak Attack and Trick Attack

| Set | Worn when |
|---|---|
| `sets.precast.JA['Sneak Attack']`, `sets.precast.JA['Trick Attack']` | The moment you use the ability |
| `sets.buff['Sneak Attack']` | Engaged, from the moment you press Sneak Attack until the buff is used by your next hit or weaponskill |
| `sets.buff['Trick Attack']` | Same, for Trick Attack. Both go on together when both are up |
| `sets.precast.WS['<name>'].SA` | That weaponskill with Sneak Attack up |
| `sets.precast.WS['<name>'].TA` | That weaponskill with Trick Attack up |
| `sets.precast.WS['<name>'].SATA` | That weaponskill with both up. Missing: `.SA`, then `.TA` is used |

- The SA/TA gear goes on as soon as you press the ability, without waiting for
  the buff to show: the game is a little slow to report it. If the ability is
  refused (recast, paralysis), the gear comes off again.
- When the buff is used by a melee hit, the engaged set is rebuilt at once
  without the SA/TA gear.
- The `.SA` / `.TA` / `.SATA` versions only exist under a weaponskill that has
  its own set: a weaponskill using the plain `sets.precast.WS` gets no SA/TA
  version. The provided file has them for Rudra's Storm, Evisceration,
  Exenterator, Savage Blade, Shark Bite, Mandalic Stab and Dancing Edge.
- The `.SA` / `.TA` / `.SATA` set is a whole set: write it with
  `set_combine(sets.precast.WS['<name>'], {...})`. The Moonshade Earring
  (TP bonus) is added after it.
- In Treasure Mode SATA or Full, the Treasure Hunter versions replace
  `sets.buff[...]` on the engaged set (next section).

## Treasure Hunter

THF has its own Treasure Hunter on top of the one every job has
([set names](../../guides/sets.md)). The mode (`^numpad3`) is on by itself on
THF, starting at **Tag**. It has no Off value: `//gs c th hide` turns it off on
THF, `//gs c th show` brings it back ([commands](../../guides/commands.md)).

| Set | Worn when |
|---|---|
| `sets.TreasureHunter` | Tag / SATA: engaged, while your current target has not been hit by you yet. Full: engaged, all the time. Every mode: on a weaponskill, a job ability, a spell or a ranged attack aimed at a monster you have not tagged yet |
| `sets.TreasureHunterSA` | SATA or Full mode, engaged, Sneak Attack up: replaces `sets.buff['Sneak Attack']` |
| `sets.TreasureHunterTA` | SATA or Full mode, Trick Attack up: replaces `sets.buff['Trick Attack']` |
| `sets.TreasureHunterSATA` | SATA or Full mode, both up |

- "Tagged" means one of your actions landed on the mob: a melee hit, a ranged
  attack, a weaponskill, a spell or a job ability. The gear comes off right
  after, and goes on again when you switch to a mob not tagged yet.
- A tagged mob is forgotten when it dies, when you zone, after 3 minutes with
  no action on it, on `//gs c th clear`, and on every reload or subjob change.
- The SATA-mode versions stay on as long as SA/TA is up, even on a mob already
  tagged. If one of them is missing, `sets.buff[...]` is used instead.
- Aeolian Edge, Steal, Mug, Bully, Provoke and ranged attacks on a new mob
  get `sets.TreasureHunter` on top of their own set (the SA/TA weaponskill
  version included).

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['<name>']` | That weaponskill. The provided file has Rudra's Storm, Evisceration, Exenterator, Savage Blade, Shark Bite, Mandalic Stab, Aeolian Edge, Dancing Edge, Circle Blade |
| `.SA` / `.TA` / `.SATA` | See Sneak Attack above |

THF has no weaponskill mode. TP bonus pieces (Moonshade Earring) are added when
they reach the next TP step: [TP bonus](../war/tp-bonus.md) (`THF_TP_CONFIG.lua`:
Aeneas +500 and Centovente +1000 are counted when held, main or off hand).

## Job abilities

`sets.precast.JA['<Name>']` for any ability. The provided file has Sneak Attack,
Trick Attack, Hide, Flee, Perfect Dodge, Feint, Steal, Despoil, Collaborator,
Accomplice (same set as Collaborator), Conspirator and Provoke. Add Mug, Bully,
Assassin's Charge... the same way.

Subjob /DNC: `sets.precast.Waltz`, `sets.precast.Step` and
`sets.precast.Flourish1` are in the provided file.

## Ranged attacks

| Set | Worn when |
|---|---|
| `sets.precast.RA` | When you shoot |
| `sets.midcast.RA` | While the shot flies. In the provided file it is the same set as `sets.precast.RA` (changing one changes both) |

- Every ranged attack locks the range and ammo slots (Range Lock turns On),
  so the crossbow and bolts stay on when the idle or engaged set comes back.
  Range Lock Off (`^numpad6`) frees them. A reload, a job or subjob change, or
  `//gs c wo` frees them too.
- `//gs c range` puts on Exalted Crossbow and Acid Bolt (names written in the
  code, not a set), locks them and shoots at a target you pick.
- After a shot, the quiver of the bolts you wear (Acid Bolt -> Ac. Bolt Quiver)
  is opened from your inventory when 5 or fewer are left.

## Spells

| Set | Worn when |
|---|---|
| `sets.precast.FC`, `sets.precast.FC.Utsusemi` | Casting (/NIN) |
| `sets.midcast.FastRecast` | Laid first under every spell's midcast |
| `sets.midcast.Utsusemi` | Utsusemi (the provided file: the FastRecast set) |
| `sets.midcast.Cure` | Cure from /WHM, /RDM (empty in the provided file) |
| `sets.midcast.Ninjutsu`, `sets.midcast['Healing Magic']`, `sets.midcast['Enhancing Magic']` | Read first for those skills; none is in the provided file, so the name or family set above is used |

## Weapons

| Set | Worn when |
|---|---|
| `sets.<Main Weapon>` | Always (idle and engaged): `sets.Vajra`, `sets.TwashtarM`, `sets['Mpu Gandring']`, `sets.Tauret`, `sets.Naegling`, `sets.Malevolence`, `sets.Dagger` |
| `sets.<Sub Weapon>` | Always: `sets.Centovente`, `sets.Tanmogayi`, `sets.Kraken` |
| `sets.<Aby Weapon>` | Instead of both, while Aby Proc is On: `sets.Dagger2`, `sets.Sword`, `sets.Club`, `sets['Great Sword']`, `sets.Polearm`, `sets.Staff`, `sets.Scythe` (main and sub in one set) |

- A weapon value with no set is skipped: the weapon you hold stays.
- With `equip_without_set = true` in `<YourName>/_common/combat/WEAPON_CONFIG.lua`, a
  value that is the exact name of a weapon is equipped without any set, and a
  main-hand set chosen as the Sub Weapon only moves the off hand.
- To add a weapon: a value in `THF_STATES.lua` and a set of the same name.

## What the job does by itself

- **Sneak Attack / Trick Attack gear** stays on while engaged from the press
  until the buff is used, and the weaponskill takes its `.SA` / `.TA` / `.SATA`
  version. Remove `sets.buff['Sneak Attack']` / `['Trick Attack']` to stop the
  engaged part.
- **Treasure Hunter** on new mobs, Tag mode by default, on the engaged set and
  on the first action against a mob. Off: `//gs c th hide`.
- **Aftermath Lv.3 with Vajra** swaps the engaged base to `sets.engaged.PDTAFM3`,
  whatever the Hybrid Mode, about 0.1 s after the aftermath starts or ends (not
  while Doomed; if an action is under way, when it ends). Remove that set to stop it.
- **Range lock** after every ranged attack; **quiver opening** for the bolts you wear.
- **Weapons** re-equipped on every idle and engaged set.
- The chains `//gs c smartbuff`, `fbc` and `steal` send abilities only; their
  gear comes from `sets.precast.JA` as usual ([states.md](states.md)).

## Sets in the provided file that nothing reads

- `sets.TwashtarS`, `sets.Jugo`, `sets.Crepu`, `sets.Blurred`, `sets.Gleti`,
  `sets.Alber`: no Sub Weapon value has these names (add the value in
  `THF_STATES.lua` to use them).
- `sets.idle.Regen`: THF has no Idle Mode (only the Hybrid Mode picks an idle set).
- `sets.precast.JA['Animated Flourish']`: `sets.precast.Flourish1` is found first.
- `sets.midcast.EnhancingMagic` (the name read is `sets.midcast['Enhancing Magic']`).
- Treasure Hunter has one set, `sets.TreasureHunter`, for every case: ranged attacks,
  Aeolian Edge and other weaponskills, and the engaged set. Names like
  `sets.AeolianTH`, `sets.TreasureHunterRA`, `sets.precast.RATH`, `sets.midcast.RA.TH`
  or `sets.engaged.TH` are not read (the provided file no longer has them).

## Names the code reads that the provided file lacks

- `sets.engaged.Normal` (Hybrid Mode Normal wears `sets.engaged`), `sets.idle.Normal` (Hybrid Mode Normal wears `sets.idle`).
- `.SA` / `.TA` / `.SATA` for Aeolian Edge and Circle Blade.
- `sets.midcast.Ninjutsu`, `sets.midcast['Healing Magic']`,
  `sets.midcast['Enhancing Magic']`.
- `sets.Adoulin` and `sets.idle.Town` are in the file; `sets.DW.*` is there
  commented out, ready to fill.
