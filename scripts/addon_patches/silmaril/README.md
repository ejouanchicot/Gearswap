# Automation addon patch: StateReport

A small local addition to the multi-box automation addon (`addons/Silmaril/`),
not part of the addon itself. It lets GearSwap show the addon's real state
and replaces the addon's own boxes by the GearSwap alt window.

What it does (details in the file's header and in `docs/dev/systems/dualbox.md`):

- reports each box's state (actions on/off, follow and leader, mirror) to the
  whole box group on every change: `//gs c altreport ...`;
- reports a mirror in progress (step, NPC, results): `//gs c altmirror ...`;
- `//sm report` resends the state (GearSwap asks at each load);
- hides the addon's three text boxes (`HIDE_ADDON_BOXES = false` brings them back).

## Install (again after every addon update)

1. Copy `StateReport.lua` into `Windower/addons/Silmaril/lib/`.
2. Add these two lines at the end of `Windower/addons/Silmaril/Silmaril.lua`:

   ```lua
   -- Local addition: reports this box's state to GearSwap (see lib/StateReport.lua)
   require 'lib./StateReport'
   ```
3. `//lua r silmaril` on every character.

Needs the `send` addon on every character, as the GearSwap box group already does.

The copy here is the reference: after changing the file in the addon folder,
copy it back here.
