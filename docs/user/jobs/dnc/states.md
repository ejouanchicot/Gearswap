# DNC - States & Modes

States control gear set selection and behavior toggles. Cycle them with keybinds or `//gs c cycle [StateName]`.

---

## States

### HybridMode

Controls the balance between offense and defense during melee combat.

| Option | Description |
|--------|-------------|
| `PDT` | Physical Damage Taken reduction (defensive mode) |
| `Normal` | Full offense, maximum DPS |

**Default**: `PDT`
**Keybind**: Alt+2

---

### MainWeapon

Selects the primary weapon. Sub weapon is automatically selected based on main weapon choice.

| Option | Description |
|--------|-------------|
| `Twashtar` | Relic dagger |
| `Mpu Gandring` | Relic dagger |
| `Demersal` | Demersal Degen (alternative) |

**Default**: `Mpu Gandring`
**Keybind**: Alt+1

---

### SubWeaponOverride

Overrides the automatic sub weapon selection.

| Option | Description |
|--------|-------------|
| `Off` | Use sub weapon from weapon set (default behavior) |
| `Blurred` | Force Blurred Knife +1 regardless of main weapon |

**Default**: `Off`
**Keybind**: Ctrl+1

---

### MainStep

Selects the primary step ability used with `//gs c step`.

| Option | Description |
|--------|-------------|
| `Box Step` | Defense down (party benefit) |
| `Quick Step` | Evasion down (DPS boost) |
| `Feather Step` | Critical hit rate boost |

**Default**: `Box Step`
**Keybind**: Alt+3

---

### AltStep

Selects the alternative step ability used in rotation when UseAltStep is enabled.

| Option | Description |
|--------|-------------|
| `Quick Step` | Evasion down |
| `Box Step` | Defense down |
| `Feather Step` | Critical hit rate boost |

**Default**: `Quick Step`
**Keybind**: Alt+4

---

### UseAltStep

Enables or disables alternate step rotation. When on, the step command alternates between MainStep and AltStep.

| Option | Description |
|--------|-------------|
| `On` | Use both Main and Alt steps in rotation |
| `Off` | Use only Main step |

**Default**: `On`
**Keybind**: Alt+5

---

### CurrentStep

Tracks which step to use next in the rotation. Managed automatically by the step system.

| Option | Description |
|--------|-------------|
| `Main` | Next step will be MainStep |
| `Alt` | Next step will be AltStep |

**Default**: `Main`

---

### ClimacticAuto

Controls automatic Climactic Flourish trigger before configured weaponskills.

| Option | Description |
|--------|-------------|
| `On` | Auto-trigger Climactic Flourish before WS |
| `Off` | Manual Climactic Flourish only |

**Default**: `On`
**Keybind**: Alt+6

---

### JumpAuto

Controls automatic Jump trigger before weaponskills (DRG subjob only). Uses Jump to build TP when under 1000.

| Option | Description |
|--------|-------------|
| `On` | Auto-trigger Jump before WS if TP < 1000 |
| `Off` | Manual Jump only |

**Default**: `On`
**Keybind**: Alt+7

---

### CombatWeaponMode

TP bonus optimization mode. Determines which gear variant to use for weaponskills. Auto-managed by the WS system based on active buffs and current TP.

| Option | Description |
|--------|-------------|
| `Normal` | No special buffs, standard WS gear |
| `TPBonus` | Use TP bonus gear (Moonshade Earring) |
| `Clim` | Climactic Flourish active (Climactic WS set) |
| `ClimTPBonus` | Climactic + TP bonus (both optimizations) |

**Default**: `Normal`

---

### Dance

Selects which dance to activate with the `//gs c dance` command.

| Option | Description |
|--------|-------------|
| `Saber Dance` | Offensive dance (+accuracy, +attack speed) |
| `Fan Dance` | Defensive dance (+evasion) |

**Default**: `Saber Dance`
**Keybind**: Alt+8 (cycle), Ctrl+8 (activate)

---

### FastCast

Internal numeric state used by the midcast watchdog system. Represents your total Fast Cast percentage from gear and traits, used to calculate adjusted cast times. Not typically cycled manually.

| Option | Description |
|--------|-------------|
| `0` through `80` | Fast Cast percentage (increments of 10) |

**Default**: `0`

---

## Quick Reference

| State | Options | Default | Keybind |
|-------|---------|---------|---------|
| HybridMode | PDT / Normal | PDT | Alt+2 |
| MainWeapon | Twashtar / Mpu Gandring / Demersal | Mpu Gandring | Alt+1 |
| SubWeaponOverride | Off / Blurred | Off | Ctrl+1 |
| MainStep | Box Step / Quick Step / Feather Step | Box Step | Alt+3 |
| AltStep | Quick Step / Box Step / Feather Step | Quick Step | Alt+4 |
| UseAltStep | On / Off | On | Alt+5 |
| CurrentStep | Main / Alt | Main | -- |
| ClimacticAuto | On / Off | On | Alt+6 |
| JumpAuto | On / Off | On | Alt+7 |
| CombatWeaponMode | Normal / TPBonus / Clim / ClimTPBonus | Normal | -- |
| Dance | Saber Dance / Fan Dance | Saber Dance | Alt+8 |
| FastCast | 0 - 80 | 0 | -- |
