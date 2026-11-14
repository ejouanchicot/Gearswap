# The Atelier page (`data/atelier.html`)

A web page that shows your character's sets, buffs, stats, bags and settings,
works out what each set gives you, searches for better sets, and writes the
changes you choose back into your GearSwap. It runs in your browser, on your
PC only: nothing is sent anywhere.

The page speaks French or English (Page > Settings > language). This page
gives the English labels; the French ones are in brackets the first time.

## Open the page

1. In game, on a job: `//gs c atelier`. It writes what the page needs for that
   job (sets, keys, modes, macro book, lockstyle, your bags and your stats as
   the game measures them).
2. Open `data/atelier.html` in your browser (Chrome or Edge: Files > Read
   needs one of them).

`//gs c atelier on` does step 1 by itself at every job load, for this
character (`//gs c atelier off` stops it). A job you never exported from the
game has no measured stats: export it once in game.

### With the game running (live link)

GearSwap opens a link to the page at every load (on 127.0.0.1, your PC only).
While it is open, the page reads the loaded job straight from the game, and
its writes (Push, Save) go through the game, which reloads
GearSwap when needed. The top bar then shows **In game · PLD/DRG** (click it to
show the job loaded in game).

- `//gs c atelier live off` closes the link for this character,
  `//gs c atelier live` opens it again.
- `//gs c atelier link` installs and loads the small **AtelierLink** addon. It
  keeps answering the page while GearSwap is unloaded: the GearSwap menu then
  says "Game connected · GearSwap unloaded" and offers **Load GearSwap**. Add
  `lua load AtelierLink` to Windower's `scripts/init.txt` to load it with the
  game.

Without the link, the GearSwap menu says "Game not connected" and everything
that writes into your GearSwap waits for the game.

### Without the game

**Files > Read** (Fichiers > Relire) reads the character shown again from your
files, without the game: only the jobs whose files changed are redone
(Shift+click: every job, with every subjob). The first time, the page asks
"Where is Windower?": pick the Windower folder (the one that holds `addons`
and `res`). What is in your bags stays as your last export in game saw it,
and the top bar says "offline". If it stops working, see the
[FAQ](../guides/faq.md#atelier-page).

For every character at once, double-click `Atelier - export all jobs.bat` in
the data folder (needs Python 3 and Lua 5.1). In game, `//gs c atelier all`
asks the open page to rebuild every other job, and `//gs c atelier tour` (Mog
House) changes to each of your jobs in turn and exports it
([commands](../guides/commands.md#information-and-diagnostics)).

## The top bar

| Part | What it holds |
|---|---|
| Character name | Its menu lists your characters: pick one to switch |
| Job and subjob | The job shown (your played jobs, by role; **Overview** for the table of all of them) and the subjob the page computes with. A dot (•) marks a subjob with its own modes or keys |
| Macro book, Lockstyle, Export | What GearSwap sets for this job and subjob, and when the job was exported (`live` while the game is linked, `offline` after Files > Read) |
| **Files** | **Read** (above); **History**: everything the page wrote into your GearSwap, with the way back |
| **GearSwap** | Linked to the game: **Reload** (`//gs reload`: your sets, settings and the code read again, quick) and **Restart** (`//lua r gearswap`: everything unloaded and loaded again, when something behaves oddly or after an update). An order shows on its button until the game has done it |
| **Page** | **Settings**: theme (Vana'diel, Grimoire, Atelier dark, Atelier light), language, animations, the sets page's view (Detailed or Simple, see [Sets](#sets)), the Moogle assistant, and the calculation engine (what it did not compute since the page opened); **Update** (below) |

## The tabs

Over the page, on a job:

| Tab | What it is for |
|---|---|
| [Sets](#sets) | Your sets: what each holds, what it gives you, and the optimizer |
| [Buffs & target](#buffs--target) (Buffs & cible) | What everything is computed with: your buffs, your target, your party |
| [My character](#my-character) (Mon perso) | Your stats measured in game, merits, Job Points, PorterPacker |
| [Bags](#bags) (Sacs) | What each bag holds, where each piece belongs, the tidy-up |
| [Configuration](#configuration) | This job's modes, keys, settings, macro book and lockstyle |
| [Simulate](#simulate) (Simuler) | What your GearSwap really equips for an action (game running) |

## Sets

The list of the job's sets is on the left, the set shown in the middle, its
figures on the right.

**The list.** A search box (set name or item), **+** to add a set, **⋯** for
the list's options (open or close everything, show the sets' names as your
GearSwap writes them, see another subjob's sets, make a group). Sets come by
category (Idle, Engaged, Weaponskills...: the weaponskills one folding group a
weapon). Hover a set to pin it to the top or put it in a group of your own;
drag to reorder. Only the sets your job can use with the subjob shown are
listed; the others are counted under the list. **Optimize all** searches
every set of the job in turn (see the [FAQ](../guides/faq.md#atelier-page)).
**Optimize all engaged** (in the list's ⋯ menu, or **Engaged only** in the
Optimize all window) ticks only each engaged mode and its Dual Wield tiers:
each mode with its goal, then each tier (`sets.DW.<tier>`, or the mode's own
`sets.DW.<Mode>.<tier>`) laid over that mode's engaged set (the common tiers
over `sets.engaged`) at the tier's magic haste (0, 15, 30 %, the cap), for
/DNC (the subjob that gives the least Dual Wield), the limits held; only the
slots that differ from the engaged set go in the tier. The Solo / Group /
Trust versions are left as they are. Nothing is written before you tick and
push.

The line over the sets says what the figures are **Calculated with**: the
situation (Full, Group, Solo, Trust), your saved profile, the target, and a
link to the Buffs & target tab.

**A set's card.**

- Its head: what the set is, its versions (Full, Group, Solo, Trust: the one
  GearSwap wears in each party situation), the weapons it is shown with (your
  weapon modes, **Auto** first). A weaponskill set also has its **Weapon** line
  (your weapon mode's by default, or another of yours that opens the
  weaponskill, best first) and its **TP** line (the steps where your TP Bonus
  reaches 2000 or 3000, or a TP of your own).
- The game's 16 equipment cells, with the item icons; hover a piece for its
  stats and augments. ◆ marks an augmented piece, R25 a piece's rank. A piece
  you do not hold is framed as *not yours*, one at the Porter Moogle and one
  below its top rank are marked too (**Legend** under the grid), and the lines
  under the grid name them ("Not in your bags", "At the Porter Moogle (to take
  out)", "To upgrade or finish").
- **Equip in game** puts the set on now, as the page shows it.
- **Delete this set…** takes a set out (refused for the job's base sets and
  for a set others are built on).
- **HP reference** (in the optimizer, under the minimums), job by job: **Ceiling**
  keeps the job's sets between the reference − 100 and it (going to it before a
  spell never cuts your HP), **Floor** keeps them at or over it, **None** sets no
  bound. The reference is the lowest Fast Cast set unless you pick another set.
  PLD and RUN start on Ceiling, the other jobs on None. An HP minimum typed on a
  set comes first.
- **Simple view** (in the set's **⋯**, or Page > Settings > Sets page) shows less
  at once, with the same figures and searches: beside the grid, the set's
  objectives and floors as small tiles, its weapons as their icons (hover one for
  its name; **Change** opens the menus) and the set's code under **Show the
  code**; each note on one line (hover it for
  the whole text), the missing pieces as one line that opens ("13 piece(s) not in
  your bags"), and in the optimizer only the minimums you set ("No minimum ·
  set" opens the others) and a stats set's result once a search has tried
  pieces. **Detailed view** puts everything back.

**Trying pieces.** Click a slot: **Choose a piece…** (your copies the job can
wear, with where they are; tick **Every item in the game** for the rest),
**Lock** (the optimizer leaves the slot alone), **Exclude from searches** (the
optimizer will not offer that piece again, for every job and set, until you
allow it again; a piece you did not hold comes back by itself once you hold
it), **Empty the slot**, **Put the set's piece back**. The pieces you change
are a try; the bar under the card offers:

| Button | What it does |
|---|---|
| **Push to GearSwap** | Writes the set into your sets, after showing its lines before and after. A copy is kept and History can undo it. Game linked; GearSwap reloads when it is the job loaded |
| **Compare** | Your set, the try and the tries you kept, side by side |
| **Keep to compare** | Sets the try aside; the optimizer and Undo all leave it alone |
| **Test in game** | Wears the tried pieces at the next `//gs reload` or job change, without changing your sets; **Back to the file** stops it |
| **Copy as Lua** | The whole set with the tried pieces, to paste yourself |
| **Back to before the optimization** | The try the optimizer replaced |
| **Undo all** | Puts the set back |

**The figures** (right column): the set's own figures (the damage of a
weaponskill set, the attack round of an engaged set, the damage taken of the
others...), then **Set stats** (what the pieces add up to, one group of stats
a tab, with **Filter stats**) and **Character** (your HP, MP, Defense, Attack,
Accuracy, Evasion and attributes with this set, and the stats the game caps).
Your stats are the ones measured in game (your stats then, less the gear you
wore, plus the set's), so a job needs one export in game first.

**+ (Add a set)** asks when you want the set, what for, then only the
questions that change the set worn, and names it for you. One you have
already is opened instead ([FAQ](../guides/faq.md#atelier-page)).

## The optimizer

**Optimize this set →** opens it in the right column, beside the set's card:
the card stays in view and shows what the search finds as a try. **← Back to
the set** closes it.

Two buttons start a search: **Best set possible** (built from nothing, longer)
and **Improve this set** (starts from the set shown, faster). **Stop** ends it;
the page stays usable meanwhile. The result becomes your try: nothing is
written until you push it.

### Weaponskill, engaged, Jump and nuke sets

One view, with what never changes in sight:

- **The figure**: the objective's value, with the change against your set and
  a verdict.
- **The objective**, as a menu:
  - a weaponskill set: **Damage at 3000 TP** (the TP is yours to set),
    **Average damage from 1000 to 3000 TP** (the range too), **TP return
    (save TP)**;
  - an engaged set: **Real time to WS** (hit by hit), **Average time**, **DPS
    (auto-attacks)**, **TP per round**, **Hit chance, then time to WS**,
    **Subtle Blow to its cap, then time to WS**. An engaged set whose name is a
    mode starts with that mode's goal and with DT+PDT ≤ -50, DT+MDT ≤ -21:
    `sets.engaged` and `.STP` the real time, `.Acc` the hit chance, `.SB`
    Subtle Blow (75 % at most, I and II 50 each), a Kraken Club set (`.PDTKC`,
    `NaeglingKC`) the real time with the club kept in the off hand; its
    Solo / Group / Trust versions the same. What you choose on such a set's page
    is kept for that set alone;
  - a Jump set: **TP per Jump**; a nuke set: its damage, with the situation of
    the fight.
- **Limits**: **DT+PDT ≤** (-50 by default), **DT+MDT ≤** (-21: -50 with Shell
  V), **Subtle Blow ≥**, and on a weaponskill **Hit rate ≥** (0: the damage
  already counts the misses). A set short of a limit always loses.
- **The try**, with its buttons.

Under them, four tabs; each says under its name what is set there:

| Tab | What it holds |
|---|---|
| **Detail** (Détail) | The result: the rounds to the weaponskill or the damage curve, the pieces changed, every figure of your set against the try (the objective first, ★), and the sum worked out step by step |
| **Pieces** (Pièces) | **Search in**: **My pieces** (Mes pièces: what you own, as it is), **My pieces at their best** (Mes pièces au max: the same at their last rank, an Ambuscade cape with each material at its maximum) or **Every item in the game** (Tous les objets du jeu: everything your job can wear, to see what you lack). Also **my wardrobes only** (leaves out what is in other bags, safes or at the Porter Moogle), **Free weapons**, the locked slots (**Unlock all**) and the pieces excluded from searches |
| **Calculation** (Calcul) | **Method**: **Fast search** or **Classic search**; **Full speed** (no pause: about twice as fast, but the PC is busy) |
| **Special** (Spéciaux) | Pieces counted only when ticked: **Hoxne Ampulla active** (its Double Attack +100 % enchantment) and **Vim Torque active** (its latent Regain; drains 50 HP a tick) |

With **Every item in the game**:

- **Ambuscade capes** you do not hold are built at each material's maximum
  (thread, dust, dye, sap, resin), the pet's options included for BST, SMN and
  PUP, so a cape counts for what it can really give.
- **Skirmish armour** (Yorium, Acro, Taeon, Telchine, Helios), **Reive capes**
  and **Oseem pieces** you do not hold are built the same way, each augment at
  its maximum; a Skirmish piece or Reive cape you hold can be shown at its
  maximum too, with the augments it lacks named.
- **Rank of the pieces to get** (Rang des pièces à avoir): the rank pieces you
  do not hold, family by family, under **Odyssey**, **Limbus** and **Nolan**.
  Each family (Nyame, Sakpata's, Sworn...) shows how many pieces your job
  wears and yours with their rank, then chips: **No** (Non: not unlocked, never
  offered) and its top ranks, the last marked "(max)". **All at max** and
  **None unlocked** set every family at once. The pieces you hold keep their
  own rank.

Weapons: a weaponskill keeps the weapon chosen for it on the set's card, and
an engaged set keeps its main hand. Under a two-handed weapon, the grip is
searched too. **Free weapons** lets the search choose the weapon among yours
(and its off hand) as well; it is never written into the set.

A prime weapon you do not hold is counted at the stage chosen in the Buffs &
target tab (your panel, **Aftermath**, **Prime stage**); one you hold, at its
own stage.

A weaponskill set has two more buttons: **By party** (the damage of each
version of the set, Full, Group, Solo and your try, under each situation's
buffs) and **Every version** (searches each version and keeps the ones that
help). An engaged set has **By party** too.

### Other sets

An idle, Fast Cast, Cure, Enmity, Phalanx or enhancing set has no damage to
work out: it is judged on its stats. Its optimizer, in the same column,
offers the objectives that mean something for the set (in order, **then, as
tiebreakers**), **Required minimums (0 = none)**, and the same search
settings (Pieces, Calculation, Special). **Back to the defaults** resets it.

Some sets start with objectives of their own:

- **BRD songs**: a buff song looks for its Song+ up to the song family's cap,
  then its length, then damage taken, and keeps the skill the song needs
  (Honor March 900...) as a floor; a debuff song looks for its accuracy first;
  a dummy song for the shortest length. The instrument is never changed.
- **GEO**: a Geo- set looks for Geomancy+, then the Geomancy + Handbell skill
  (counted up to 900 together: past it nothing more), Bagua Charm and
  Conserve MP; an Indi- set for Geomancy+, the skill and the **Indi duration**;
  an Entrust set for the Indi duration and Conserve MP (Geomancy+ does nothing
  to an entrusted Indi-). Once your own skills reach 900, the skill objective
  is left out.
- **BST Reward**: Reward potency up to its +50 % cap, then the recast down to
  23 s, then MND; the pet food in the ammo slot is never touched, and a body
  that removes the six ailments is kept.

## Buffs & target

What every figure of the page is computed with. Nothing here changes what you
wear in game.

- **Situation** (Full, Group, Solo, Trust): the kind of party, which decides
  the version of a set GearSwap wears; each keeps its own buffs. **My
  profiles** saves the whole state under a name (party, buffs, debuffs,
  target, food, abilities, situation) and loads it in one click.
- **Your party**: you, then each member as a tab saying what it gives
  (**Add** a support job: WHM, RDM, SCH, BRD, COR, GEO...). The tab chosen
  opens its panel: songs, rolls, bubbles, Haste... **You**: your food, your
  **Aftermath** (its level, and for a prime weapon its **Prime stage**), your
  job's and subjob's abilities.
- **Target**: the monster the figures are against (search, zones, levels), its Defense and
  Evasion before and after your debuffs; **Other debuffs on the target**: what
  jobs outside the party lay (Dia, Distract, Light Shot, Box Step...), one
  tab a job.
- **What it gives you**: every effect, and who gives it. **What it changes for
  your set**: the set opened, one figure a situation.
- **Typical buffs** ticks a usual endgame party's buffs; **Clear all** takes
  everything off; **↶ Undo**.

## My character

Who (the job, the Master Level, the Job Points, when the game measured the
character), then:

- **Your stats** as cards, measured in game, with the set picked in the list on
  the left.
- **PorterPacker**: what it takes out of the Porter Moogle when you switch to
  this job, against your sets; **Update the list** keeps only your sets'
  pieces.
- **Merits**: your levels read in game. Change one to test: it turns gold and
  your stats follow; **Back to the game values**. Nothing changes in game.

## Bags

Every bag of the character as the game last held it (read at each
`//gs c atelier` or job load in game), as tiles: **On you**, **Mog House**,
**Stored elsewhere** (the Porter Moogle, from your slips), **All the bags**
(each item once, with the bags it is in) and **The plan** (does it fit?). In
game, the page also shows where you stand and which bags are open there
(**Where are the moogles?** lists them by zone).

**The list.** Its filters are three labelled lines: **Search**, **Type** (All,
Weapons, Armor, Usable...) and **Use** (All, Not filed, Misplaced, Lockstyle,
In no set, One job only, Several jobs), plus **In several bags** and **Plan
category**. Click items to select them; the bar "*n* selected: file in" then
files them in a category, in three columns: **Gear**, **Items** and
**Elsewhere** (For a mule, To an NPC, On me). Each button has a short name,
the full one on hover; the selection's category now is lit. **Automatic**
forgets your choice.

**What each bag is for.** Open a bag and say what it is for (**This bag is
for**, **and also for**: up to three roles). The wardrobes start from your
`WARDROBE_CONFIG.lua`, the Mog House bags from a usual layout (Storage and Mog
Locker: what is not used). The list then marks what is misplaced, and why.

**The plan** (Le plan). One card a role: what its bags hold today, what the
tidy-up takes out and brings in, and what finds no room. Nothing moves in game.

- An item split between two bags of the same role goes to one of them (the
  game does not join part stacks).
- What another of your characters can take (in no set, and the game lets it be
  sent) is housed with what is not used, in Storage and the Mog Locker, until
  you send it. Its card offers **Bring them to the inventory**, which prepares
  that move; nothing leaves by itself.
- What an NPC keeps for you (seals, vouchers, Rem's Tales...) takes no bag: its
  card says which NPC.
- The Porter Moogle is left as it is.

**Prepare *n* move(s) for the game** shows what goes from where to where, then
**Send to the game**. In game, `//gs c bags` shows what is ready (nothing
moves), `//gs c bags go` plays it, `//gs c bags stop` stops
([commands](../guides/commands.md#gear-and-inventory)). It only moves items from
a bag to another; a worn piece, a full bag or a Mog House bag outside the Mog
House is skipped and said.

**Get the job ready**, when a Porter Moogle is within reach: PorterPacker, then
the wardrobes, the lockstyle and the refill, the same as `//gs c po`.

## Configuration

Three parts, in one frame (categories on the left, options in the middle, the
option chosen on the right, the changes waiting and **Save** at the bottom):

- **Modes & keys**: your modes with their start value and key, and every key
  (**⚠ Conflicts** first); **Change** a key by pressing it. See
  [keybinds](../guides/keybinds.md#changing-keys-from-the-atelier-page) and
  [start values](../guides/keybinds.md#a-modes-start-value-from-the-atelier).
- **Settings** (Réglages): each GearSwap module's settings, the character's and
  this job's (Auto Medicine, Refill, Dual-box, HUD...), with a search. The HUD
  preview: [HUD](ui.md#the-hud-in-the-atelier-page); the refill list (**Common
  list + my items** or **My own list**):
  [configuration](../guides/configuration.md#refill-job_refilllua).
- **Macros & lockstyle**: a tile a subjob, plus **Default**, each with − / +;
  **+ Add a subjob…** ([configuration](../guides/configuration.md#macro-book-job_macrobooklua)).

Nothing is written before **Save**. With the game linked, the game writes it (a
copy kept, History can undo it) and GearSwap reloads.

## Simulate

Game linked. Pick a spell, an ability or a weaponskill of the job on the left:
your own GearSwap runs it dry (precast, midcast, after the action) with the
target (**On the enemy**, **On me**, **On an ally**), status (**Idle**,
**Engaged**), **Respect recasts**, the TP and the modes you choose. The page
shows the gear of each step with the set it recognises, the steps compared
(HP, MP, damage taken...), an ability your GearSwap fires first, and its
messages. Nothing is cast or equipped in game. While pieces are in test and
not pushed, the action runs twice: with them, and as your sets have it.

## Update

Page > **Update** (or `//gs c upgrade` in game) shows the version installed and
the latest one published on GitHub, what installing it changes, and installs
it. Your characters, sets, keys and settings are never touched; the files it
replaces are kept, and **Go back to version ...** puts them back.

## What the page writes

All in your character's folder, never your set files unless you push:

| Where | What |
|---|---|
| `atelier/exports/<JOB>_<SUB>.js` | The exports the page reads |
| `atelier/overrides/set_overrides.lua` | The pieces in **Test in game** |
| `atelier/overrides/keybind_overrides.lua`, `mode_overrides.lua` | Keys and mode start values changed in the page |
| `atelier/overrides/list_layout.js`, `bag_plan.js` | The list's arrangement and your profiles; the bags' roles and your categories |
| `atelier/backups/`, `atelier/history.lua` | A copy of each file before the page writes it, and the History |
