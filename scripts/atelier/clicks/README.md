# Click tests of the Atelier page

Each `<name>_clicks.js` opens the page in Chrome (Puppeteer), clicks through one part of it and prints what a
player would read there, then `errors [...]`, the errors the page threw. They were written during the move to
Svelte (2026-10-19 to 2026-10-20) to compare the old page and the new one, and stay as the page's regression tests.

Run them with `scripts/atelier/atelier_clicks_test.js`:

```bash
node scripts/atelier/atelier_clicks_test.js                # all of them, 4 at a time: no page error
node scripts/atelier/atelier_clicks_test.js tip push       # two of them
node scripts/atelier/atelier_clicks_test.js --compare      # last commit vs now: the same output, line for line
```

`run_tests.py --full` runs them all; `scripts/atelier/cycle.sh` runs them compared (`full`, or the ones named
after `--` in `quick`).

## Writing one

- Start from a test of the same part of the page; keep the first lines (Puppeteer, Chrome, `PAGE_URL`).
- Print what the player reads (texts, chosen options, pressed buttons, titles), not the HTML: Svelte and the old
  page write attributes in another order and Svelte leaves empty comments.
- Set `S.motion = false` before reading a figure: a number that rolls is read before it lands.
- A `<select>` redrawn by the old page is a new element after each change: query it again after each event.
- The page reads the game's data when it is linked: compare old and new in the same run (`--compare`), never two
  outputs taken minutes apart.

| Test | What it goes through |
|---|---|
| `amroll`, `wsam`, `wsam2` | aftermath and roll buttons, Warcry / Samba of the party |
| `as`, `create`, `del`, `card`, `title` | adding a set, creating and deleting one, a set's card and title |
| `bd` | where a piece goes in the bags (placement window) |
| `bstpet` | a BST's pet engaged sets: their optimizer, objectives, pet figures, a stats search to its end |
| `bstcharm` | a BST's Charm set: laid in the page if the export has none, its objectives (CHR, then Charm+), figures, a stats search to its end |
| `sm`, `sp`, `gp` | the slot menu, the stat picker, the piece picker |
| `mp`, `chiprows`, `modctl`, `numcol` | the Modules: their pickers (weaponskills, abilities, modules) and controls |
| `longname` | a piece found by its long name (Clr. Torque +2 by "cleric"), also among the pieces of no use |
| `rfsub` | the refill card's lists by subjob: one added and edited before any save, Shihei in the window of items |
| `combat`, `panel`, `foe`, `tcard`, `tg`, `selreset`, `pb` | Buffs & target: panels, the foe, the target card and picker, a buff menu reset, the party |
| `dlg`, `oa`, `run`, `search`, `opt`, `statopt` | the compare window, optimize-all and its Lua, the search window, both optimizers |
| `enfround`, `nuke`, `fight`, `fightnomo`, `hpcyc`, `luopan`, `tankx`, `glob`, `globals`, `sheet` | the figures of a set and their folded blocks |
| `push`, `trialbar` | the push button, the trial's bar |
| `home`, `nx`, `settings`, `pkg`, `sim`, `prof` | home, a job with no export, settings, packages, simulate, buff profiles |
| `lh`, `list`, `sw` | the list of sets and its head menu, the subjob warning |
| `tip`, `weap`, `wshead` | the hover card, the weapon menus, a weaponskill set's head (the longest: 2 to 6 min) |
