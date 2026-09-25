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

Reads the set files of every job of your character (`<YourName>/sets/`, as
text) and lists the items in your wardrobes that no set file names. The report
is written to `data/wardrobe_audit.txt`. Nothing is moved.

## `//gs c wo` - wardrobe organizer

Moves the gear you use into the first wardrobes (the game reads them first) and
the rest into overflow bags. It unequips everything and locks your slots while
it runs, then releases them and applies your lockstyle and refill. Default:
the loaded job's gear in wardrobes 1-2, the rest pushed to wardrobes 8, 6, 5,
4, 3; wardrobe 7 is never touched. Run it again after a job change.

| Command | Effect |
|---|---|
| `wo` | Organize |
| `wo preview` | Show what would move, move nothing |
| `wo alt` | For a character with 4 wardrobes: every job's sets count, wardrobes 1-4 are the main bags, Sack / Case / Satchel the overflow |
| `wo verify` | Report what is out of place, move nothing |
| `wo keep` | Items kept in the main bags although no set names them (warp rings and `KEEP_ITEMS`) |
| `wo scan` | Record which warp items you own |
| `wo recover` | Release the slots after an interrupted run |

Type the words in lowercase: anything it does not recognise (even `Preview`)
runs a full organize. The bags are set in `config/WARDROBE_CONFIG.lua`, see
[configuration](../guides/configuration.md#wardrobes-wardrobe_configlua-optional).

## `//gs c rf` - refill

Tops up the consumables in your inventory from the Mog Case and Mog Sack, and
puts the surplus back. The list comes from
`config/<job>/<JOB>_REFILL.lua` (you write it; see
[configuration](../guides/configuration.md#refill-job_refilllua)). `rf` is
also sent to your other GearSwap instances.

## When to use them

- After editing a set file: `//gs c checksets`.
- Before an event: `//gs c checksets` then `//gs c rf`.
- To clean up wardrobes: `//gs c wa`, then `//gs c wo preview`, then `//gs c wo`.
