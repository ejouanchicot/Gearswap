# Automation addon patches

Small local additions to the multi-box automation addon (`addons/Silmaril/`), not part of the addon itself.
Each one is a file put in the addon's `lib/` and one `require` line at the end of its main file; none of the
addon's own code is changed, so an addon update only removes them.

## Install (again after every addon update)

```
python scripts/addon_patches/silmaril/install.py            # copies the files, adds the require lines
python scripts/addon_patches/silmaril/install.py --check    # says what is missing, changes nothing
```

then `//lua r silmaril` on every character. It can be run twice. It refuses an addition whose hooks the
updated addon no longer has (a function renamed): read that addition's header and adapt it first.

The copies here are the reference: after changing a file in the addon folder, copy it back here.

## CastHold

No movement while the character casts a spell (2026-10-14). The desktop program stops sending run orders once
it knows the character casts, but never a stop, and a run order sent just before keeps the character running
for up to 2 seconds: the spell is interrupted (the alt's Geo- and Indi-). The file wraps the addon's
`movement` and `input_message` and reads the character's own cast packets. Checked with stand-ins outside
the game only; the Sortie log's `INTERRUPTED` lines (SortieLog) say whether the alt had moved.

## StateReport

It lets GearSwap show the addon's real state and replaces the addon's own boxes by the GearSwap alt window.
Needs the `send` addon on every character, as the GearSwap box group already does.

What it does (details in the file's header and in `docs/dev/systems/dualbox.md`):

- reports each box's state (actions on/off, follow and leader, mirror) to the
  whole box group on every change: `//gs c altreport ...`;
- reports a mirror in progress (step, NPC, results): `//gs c altmirror ...`;
- `//sm report` resends the state (GearSwap asks at each load);
- hides the addon's three text boxes (`HIDE_ADDON_BOXES = false` brings them back).
