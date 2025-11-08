# RDM - Commands Reference

---

## 🌐 Universal Commands

These work on **all jobs**:

| Command | Description |
|---------|-------------|
| `//gs c checksets` | Validate equipment |
| `//gs c reload` | Full system reload |
| `//gs c lockstyle` | Reapply lockstyle |
| `//gs c ui` | Toggle UI overlay |
| `//gs c debugmidcast` | Toggle midcast debug |
| `//gs c watchdog` | Check watchdog status |

---

## 🎯 RDM-Specific Commands

**File**: `shared/jobs/rdm/functions/RDM_COMMANDS.lua`

### Job Abilities

| Command | Description | Usage |
|---------|-------------|-------|
| `convert` | Quick Cast Convert | `//gs c convert` |
| `chainspell` | Quick Cast Chainspell | `//gs c chainspell` |
| `saboteur` | Quick Cast Saboteur | `//gs c saboteur` |
| `composure` | Quick Cast Composure | `//gs c composure` |

### Elemental Spells

| Command | Description | Usage |
|---------|-------------|-------|
| `castlight` | Cast Main Light spell + tier | `//gs c castlight` |
| `castsublight` | Cast Sub Light spell + tier | `//gs c castsublight` |
| `castdark` | Cast Main Dark spell + tier | `//gs c castdark` |
| `castsubdark` | Cast Sub Dark spell + tier | `//gs c castsubdark` |

**Example**:

```
// If MainLightSpell = Fire, NukeTier = V
//gs c castlight
>> Casts "Fire V" on target
```

### Enhancement Spells

| Command | Description | Usage |
|---------|-------------|-------|
| `refresh` | Cast Refresh | `//gs c refresh [target]` |
| `phalanx` | Cast Phalanx on self | `//gs c phalanx` |
| `haste` | Cast Haste | `//gs c haste [target]` |

**Example**:

```
//gs c refresh <stpc>  # Cast Refresh on party member
//gs c haste <me>      # Cast Haste on self
```

### Enspell & Buffs

| Command | Description | Usage |
|---------|-------------|-------|
| `enspell [element]` | Cast specific enspell | `//gs c enspell fire` |
| `castenspell` | Cast current selected enspell | `//gs c castenspell` |
| `castgain` | Cast current Gain spell | `//gs c castgain` |
| `castbar` | Cast current Bar Element | `//gs c castbar` |
| `castbarailment` | Cast current Bar Ailment | `//gs c castbarailment` |
| `castspike` | Cast current Spike spell | `//gs c castspike` |

**Example**:

```
//gs c enspell fire      # Cast Enfire
//gs c enspell blizzard  # Cast Enblizzard
//gs c castenspell       # Cast current selected (from state.Enspell)
```

### Storm Spells (SCH Subjob Only)

| Command | Description | Usage |
|---------|-------------|-------|
| `cyclestorm` | Cycle Storm spell | `//gs c cyclestorm` |
| `caststorm` | Cast current Storm | `//gs c caststorm` |

**Note**: These commands only work with SCH subjob.

---

## 📝 Command Examples

### Example 1: Quick Cast Convert

```
//gs c convert

>> Casts Convert job ability
>> Swaps HP/MP
```

### Example 2: Cast Light Nuke

```
// Setup:
Alt+8 (cycle MainLightSpell to Fire)
Ctrl+= (cycle NukeTier to VI)

// Cast:
Ctrl+8 (castlight)

>> Casts "Fire VI" on target
```

### Example 3: Auto-Saboteur Enfeeble

```
// Setup:
Alt+P (cycle SaboteurMode to On)

// Cast:
/ma "Gravity" <t>

>> System auto-casts Saboteur (if ready)
>> Waits 2 seconds
>> Casts Gravity with Saboteur active
```

### Example 4: Cast Specific Enspell

```
//gs c enspell thunder

>> Casts "Enthunder" on self
```

### Example 5: Refresh Party Member

```
//gs c refresh <stpc>

>> Casts Refresh on party member
```

---

## 🔍 Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Show set selection logic (toggle) |
| `//gs c watchdog` | Check watchdog status (should show ENABLED) |
| `//gs c state MainWeapon` | Show current MainWeapon value |
| `//gs c state EnfeebleMode` | Show current EnfeebleMode value |

**Example Debug Session**:

```
//gs c debugmidcast
>> Toggles debug ON

/ma "Gravity" <t>
>> Shows in console:
[MIDCAST] Skill: Enfeebling Magic
[MIDCAST] Type: mnd_potency
[MIDCAST] Mode: Potency
[MIDCAST] Selected: sets.midcast['Enfeebling Magic'].mnd_potency.Potency

//gs c debugmidcast
>> Toggles debug OFF
```

---

## 🎮 State Cycling Commands

All states can be cycled via `//gs c cycle [StateName]`:

```
//gs c cycle MainWeapon     # Cycle main weapon
//gs c cycle EnfeebleMode   # Cycle enfeeble mode
//gs c cycle NukeMode       # Cycle nuke mode
//gs c cycle IdleMode       # Cycle idle mode
//gs c cycle EngagedMode    # Cycle engaged mode
// ... etc.
```

**Tip**: These are easier accessed via keybinds (Alt+1, Alt+5, etc.)
