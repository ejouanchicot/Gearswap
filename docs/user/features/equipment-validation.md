# Equipment validation and inventory tools

## `//gs c checksets`

Walks every set of the loaded job and reports each set slot whose item you
cannot equip right now. Sets where everything is reachable print nothing.

```
[MISSING] [ring1] Epaminondas's Ring
  Set: sets.precast.WS['Savage Blade']
[STORAGE] [neck] Fotia Gorget - Found in Sack
  Set: sets.precast.WS['Upheaval']
```

followed by a summary: how many sets are complete, how many items need to be
retrieved, how many were not found.

| Status | Meaning |
|---|---|
| (not shown) | In your inventory or one of the 8 wardrobes: equippable |
| `STORAGE` | Found, but in a bag you cannot equip from (Mog Safe, Storage, Locker, Satchel, Sack, Case) or in a Porter Moogle storage slip |
| `MISSING` | Found nowhere |

Storage slips are read through Windower's `slips` library (shipped with
Windower); the Delivery Box is not scanned.

**An item you own shows `MISSING`**: its name in the set file does not match
the game's exactly, or its `augments` do not.

## `//gs c wa` - wardrobe audit

Reads the set files of every job of your character (as text) and lists the
items in your wardrobes that no set file names. The report is written to
`data/wardrobe_audit.txt`. Nothing is moved. It follows your
`WARDROBE_CONFIG.lua`: a wardrobe in `NEVER_TOUCH` is counted but not judged
(the report says "not judged - NEVER_TOUCH in WARDROBE_CONFIG.lua"), and the
items in `KEEP` or `NEVER_MOVE` count as used.

## `//gs c wo` - wardrobe organizer

Moves the gear your sets use into the bags the game reads first, the rest into
your other bags, and follows the rules of your `WARDROBE_CONFIG.lua` (an item,
a job or a kind of gear in the bag you choose). It unequips everything and
locks your slots while it runs, then releases them and applies your lockstyle
and refill. Without a config: the loaded job's gear goes to wardrobes 1-2, the
rest to your other unlocked wardrobes, and every wardrobe may be touched. Run
it again after a job change. When you own several copies of a used item
without augments (two Chirich Ring +1...), it puts one in each used bag, so
each side of the pair keeps its own copy at every gear change.

| Command | Effect |
|---|---|
| `wo` | Organize |
| `wo preview` | Show what would move, move nothing |
| `wo alt` | Same, with every job's gear counted as used, on the `USED_WHEN_ALL` / `UNUSED_WHEN_ALL` bags of your config (your usual bags if it has none) |
| `wo verify` | Report what is out of place, move nothing |
| `wo keep` | Items kept in the used bags although no set names them (`KEEP`, and your warp rings when your other bags include Sack / Case / Satchel) |
| `wo scan` | Record which warp items you own |
| `wo recover` | Release the slots after an interrupted run |
| `wo reset` | Clear a run left stuck after a crash, and release the slots |

The start of a run shows what it uses: `Gear of` (the job loaded or every
job), `Used` and `Unused` (your bags by name), `Never touched`, and a
`Config:` line for anything in your file it did not understand (a misspelt bag
name, for instance). The end shows the free slots of your used bags and of the
other bags.

Type the words in lowercase: anything it does not recognise (even `Preview`)
runs a full organize. The bags and rules are set in
`_common/inventory/WARDROBE_CONFIG.lua`, see
[configuration](../guides/configuration.md#wardrobes-wardrobe_configlua).

## `//gs c rf` - refill

Tops up the consumables in your inventory from the Mog Case, Mog Sack and Mog
Satchel (in that order), and
puts the surplus back. The list is the common one of
`_common/inventory/REFILL_CONFIG.lua` (`default_list`, six medicines on a new
character), which each job's `<job>/inventory/<JOB>_REFILL.lua` can add to or
replace (every line commented at first; see
[configuration](../guides/configuration.md#refill-job_refilllua)). `rf` is
also sent to the other characters of your dual-box group.

## When to use them

- After editing a set file: `//gs c checksets`.
- Before an event: `//gs c checksets` then `//gs c rf`.
- To clean up wardrobes: `//gs c wa`, then `//gs c wo preview`, then `//gs c wo`.
