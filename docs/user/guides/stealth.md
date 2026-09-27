# Sneak and Invisible

One key puts Sneak (Alt+Z) or Invisible (Alt+X) on you **and** on every other
character of your box group. Each character picks the best way it has at that
moment, so you do not need a key per job or per subjob.

Works for every job. With no box group (no dual-box), the keys cover you
alone.

## Requirements

- The Windower **`send`** addon on every character of the group (the key is
  passed to the others through it), as for the rest of the
  [dual-box](dualbox.md) layer.
- The Windower **`Cancel`** addon: a Sneak or Invisible still up blocks a new
  one, so it is removed with `cancel Sneak` / `cancel Invisible` just before
  the new cast.
- `config/STEALTH_CONFIG.lua` in your character folder. The clone script
  copies it; without it the defaults below apply and changes made in game are
  not saved.

## Keys and commands

| Key / command | What it does |
|---|---|
| Alt+Z, `//gs c stealth sneak` | Sneak on you and on the other characters |
| Alt+X, `//gs c stealth invi` | Invisible on you and on the other characters |
| `//gs c stealth both` | Both |
| `//gs c stealth sneak self` (also `invi self`, `both self`) | You only, at once: no other character is asked, no Accession, no waiting |
| `//gs c stealth check` | What the key would do right now, and why. Nothing is cast |
| `//gs c stealth status` | The settings and the time left on each character |
| `//gs c stealth refresh <s>` | Recast only when less than `<s>` seconds are left (default 180) |
| `//gs c stealth alert <s>` | Warn `<s>` seconds before a buff wears off (default 60, 0 = never) |
| `//gs c stealth overwrite on` / `off` | `on`: cast again whatever time is left (default off) |
| `//gs c stealth alerts on` / `off` | Wear-off warnings in chat (default on) |
| `//gs c stealth delay <s>` | Pause after each action before the next one (default 3.0) |

The keys are in `config/COMMON_KEYBINDS.lua`, so every job gets them (see
[keybinds](keybinds.md#common-keys)). The five settings are saved in
`config/STEALTH_CONFIG.lua` as soon as you change them.

## What each character uses

When you press the key, each character looks at what it can do right now
(abilities known, spells learned and off recast, level, MP, items in the
inventory) and uses the first that works:

1. **Spectral Jig** (DNC main or sub): gives both buffs. A character that has
   Spectral Jig uses nothing else: when it is on recast, the key says
   `Spectral Jig : ready in m:ss, press again then` and uses no oil, powder or
   spell.
2. **The spell** on itself: Sneak or Invisible (WHM, RDM, SCH, main or sub,
   with the level).
3. **Ninjutsu** (NIN): Monomi: Ichi for Sneak, Tonko: Ni then Tonko: Ichi for
   Invisible, with the tool in the inventory (Sanjaku-Tenugui or Shinobi-Tabi,
   or Shikanofuda for both).
4. **Silent Oil** (Sneak) or **Prism Powder** (Invisible).
5. **Evanessence**: gives both buffs.
6. **A partner casts it**: a character with none of the above asks the
   others; each one that has the spell casts it on that character.

Its actions go out one after the other: the next one leaves once the game
says the previous one ended, plus the `delay` setting. If the game never says
so, the next one leaves after the cast time plus `delay`. A spell or an item the game
refused anyway (sent too soon) never starts: it is noticed 1.5 s later and sent
again, up to three times.

## One Scholar for the whole group

A character with Scholar (main or sub) and a stratagem charge left, who needs
the buff itself, covers everyone at once: Light Arts if it is not up,
Accession, then the spell. It tells the others first, and they do nothing for
that buff (a buff of their own still up is cancelled so the new one lands).
One charge per buff: with one charge, only Sneak is covered when you asked for
both.

- It casts wherever the others stand. A character out of reach simply
  presses the key again: the Scholar, now covered, stays out of it and that
  character uses its own way.
- On BLM and PLD the `SneakInviAOE` mode set to Off stops the Scholar from
  spending a stratagem on the group.
- The other characters wait half a second for the Scholar's message before
  going their own way. They do not wait when the jobs of every other
  character are known (dual-box job exchange) and none of them has Scholar.

## A buff already up

A buff with more than `refresh` seconds left is not cast again, and a chat
line says so. Spectral Jig is used only when one of the two buffs is short.
A buff you just asked for counts as up for a few seconds, so pressing the key
twice does not cast twice. `overwrite on` casts again whatever time is left
(the few seconds after a press still count).

Any action you make (spell, item, ability) takes Invisible off you. So when
you ask for Sneak while Invisible is up, you get both: Sneak first, then
Invisible again, even if Invisible still had time left.

## Timers and warnings

Each character reads the end time of its own Sneak and Invisible from the
game and sends it to the others. So:

- The [alt window](dualbox.md#the-alt-window) shows a Sneak and an Invi row
  for each alt: the time left, in yellow under one minute, `-` when not up or
  not known.
- A chat line warns `alert` seconds before a buff wears off, yours or an
  alt's: `[STEALTH] Sneak wears off in 58 s`.
- `//gs c stealth status` lists the time left on every character.

The time of a buff is known once the game has sent it, which it does when a
buff changes. Right after `//lua reload gearswap` a buff already up shows `-`
until then; it still counts as up for the key.

## Check before you press

`//gs c stealth check` prints, without casting anything:

- your jobs, the state of each buff and what the key would do for it
  (`Spectral Jig`, `Sneak`, `Silent Oil`, `Accession for the group`,
  `nothing, 4:12 left`, or `none of its own: asks the others`);
- whether Accession is possible, and if not why (no Scholar, `SneakInviAOE`
  Off, no charge);
- each other character's distance in yalms and its timers. The distance is
  measured flat, without height, the same way as the automation addon's own
  box.

## Settings (`config/STEALTH_CONFIG.lua`)

```lua
return {
    refresh_below = 180,   -- recast only when less than this is left (seconds)
    alert_before = 60,     -- warn this many seconds before it wears off (0 = never)
    overwrite = false,     -- true: cast again whatever time is left
    alerts = true,         -- false: no wear-off warning
    delay = 3.0,           -- seconds after an action ends before the next one
}
```

Edit the file and `//gs c reload`, or use the commands above: they change the
value at once and rewrite only that line of the file. A re-clone of your
character keeps this file.

## Troubleshooting

| Symptom | Try |
|---|---|
| Nothing happens on the other characters | The `send` addon must be loaded on every character, and they must be in your box group ([dual-box](dualbox.md)) |
| Second press does nothing | A buff asked for less than 12 s ago counts as coming, even with `overwrite on`; press again after that |
| The new cast does nothing while the old buff is up | Load the `Cancel` addon |
| Actions are refused as too early | They are sent again on their own; if it still happens, raise `//gs c stealth delay` (3.5 or 4) |
| `no way of your own` with `self` | That character has no Jig, spell, ninjutsu or item right now; drop `self` to let a partner cast it |
| Want to see every decision | `//gs c trace on`, press the key, then read the `STEALTH` lines of `<YourName>/trace.log` |
| Did a partner really get the buff? | With the trace on, each cast writes `Sneak landed ...: reached <names>; missed <name (distance)>`, and each box writes `buff Sneak gained` / `lost` when the game applies it |
