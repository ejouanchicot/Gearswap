#!/usr/bin/env python3
"""
Generate modular documentation for all GearSwap jobs.
Creates 8 markdown files per job based on code analysis.
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple, Optional

# Job definitions (job_code, full_name)
JOBS = [
    ("whm", "White Mage"),
    ("blm", "Black Mage"),
    ("geo", "Geomancer"),
    ("brd", "Bard"),
    ("cor", "Corsair"),
    ("bst", "Beastmaster"),
    ("pld", "Paladin"),
    ("dnc", "Dancer"),
    ("sam", "Samurai"),
    ("thf", "Thief"),
    ("war", "Warrior"),
    ("drk", "Dark Knight"),
]

# Base paths
BASE_DIR = Path(r"D:\Windower Tetsouo\addons\GearSwap\data")
TETSOUO_DIR = BASE_DIR / "Tetsouo"
SHARED_DIR = BASE_DIR / "shared"
DOCS_DIR = BASE_DIR / "docs" / "user" / "jobs"
TEMPLATES_DIR = BASE_DIR / "docs" / "templates" / "modular"


class JobDocGenerator:
    def __init__(self, job_code: str, job_name: str):
        self.job_code = job_code.lower()
        self.job_upper = job_code.upper()
        self.job_name = job_name
        self.data = {}

    def extract_keybinds(self) -> List[Dict]:
        """Extract keybinds from RDM_KEYBINDS.lua"""
        keybinds_file = TETSOUO_DIR / "config" / self.job_code / f"{self.job_upper}_KEYBINDS.lua"

        if not keybinds_file.exists():
            print(f"WARNING: Keybinds file not found: {keybinds_file}")
            return []

        with open(keybinds_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Extract keybind table
        keybinds = []
        pattern = r'\{\s*key\s*=\s*"([^"]+)",\s*command\s*=\s*"([^"]+)",\s*desc\s*=\s*"([^"]+)"(?:,\s*state\s*=\s*"?([^"}\s,]+)"?)?\s*\}'

        for match in re.finditer(pattern, content):
            key, command, desc, state = match.groups()
            keybinds.append({
                'key': key,
                'command': command,
                'desc': desc,
                'state': state or 'nil'
            })

        return keybinds

    def extract_states(self) -> List[Dict]:
        """Extract states from RDM_STATES.lua"""
        states_file = TETSOUO_DIR / "config" / self.job_code / f"{self.job_upper}_STATES.lua"

        if not states_file.exists():
            print(f"WARNING: States file not found: {states_file}")
            return []

        with open(states_file, 'r', encoding='utf-8') as f:
            content = f.read()

        states = []

        # Pattern 1: state.X:options('A', 'B', 'C')
        pattern1 = r"state\.(\w+):options\((.*?)\)"
        for match in re.finditer(pattern1, content, re.DOTALL):
            state_name, options_str = match.groups()
            options = [opt.strip().strip("'\"") for opt in options_str.split(',')]

            # Find default
            default_pattern = rf"state\.{state_name}:set\(['\"](\w+)['\"]\)"
            default_match = re.search(default_pattern, content)
            default = default_match.group(1) if default_match else options[0]

            states.append({
                'name': state_name,
                'options': options,
                'default': default
            })

        # Pattern 2: state.X = M{'A', 'B', 'C'}
        pattern2 = r"state\.(\w+)\s*=\s*M\s*\{[^\}]*?['\"]description['\"]\s*=\s*['\"]([^'\"]+)['\"],?\s*(.*?)\}"
        for match in re.finditer(pattern2, content, re.DOTALL):
            state_name, description, options_str = match.groups()

            options = [opt.strip().strip("'\"") for opt in re.findall(r"['\"]([^'\"]+)['\"]", options_str)]

            # Find default
            default_pattern = rf"state\.{state_name}:set\(['\"](\w+)['\"]\)"
            default_match = re.search(default_pattern, content)
            default = default_match.group(1) if default_match else (options[0] if options else 'Unknown')

            states.append({
                'name': state_name,
                'options': options,
                'default': default
            })

        return states

    def extract_lockstyle_config(self) -> Dict:
        """Extract lockstyle configuration"""
        lockstyle_file = TETSOUO_DIR / "config" / self.job_code / f"{self.job_upper}_LOCKSTYLE.lua"

        if not lockstyle_file.exists():
            print(f"WARNING: Lockstyle file not found: {lockstyle_file}")
            return {'default': 1, 'by_subjob': {}}

        with open(lockstyle_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Extract default
        default_match = re.search(r"\.default\s*=\s*(\d+)", content)
        default = int(default_match.group(1)) if default_match else 1

        # Extract by_subjob
        by_subjob = {}
        subjob_pattern = r"\['(\w+)'\]\s*=\s*(\d+)"
        for match in re.finditer(subjob_pattern, content):
            subjob, lockstyle = match.groups()
            by_subjob[subjob] = int(lockstyle)

        return {'default': default, 'by_subjob': by_subjob}

    def extract_macrobook_config(self) -> Dict:
        """Extract macrobook configuration"""
        macrobook_file = TETSOUO_DIR / "config" / self.job_code / f"{self.job_upper}_MACROBOOK.lua"

        if not macrobook_file.exists():
            print(f"WARNING: Macrobook file not found: {macrobook_file}")
            return {'default': {'book': 1, 'page': 1}, 'solo': {}}

        with open(macrobook_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Extract default
        default_match = re.search(r"\.default\s*=\s*\{book\s*=\s*(\d+),\s*page\s*=\s*(\d+)\}", content)
        default = {'book': int(default_match.group(1)), 'page': int(default_match.group(2))} if default_match else {'book': 1, 'page': 1}

        # Extract solo macrobooks
        solo = {}
        solo_pattern = r"\['(\w+)'\]\s*=\s*\{book\s*=\s*(\d+),\s*page\s*=\s*(\d+)\}"
        for match in re.finditer(solo_pattern, content):
            subjob, book, page = match.groups()
            solo[subjob] = {'book': int(book), 'page': int(page)}

        return {'default': default, 'solo': solo}

    def extract_commands(self) -> List[Dict]:
        """Extract job-specific commands from RDM_COMMANDS.lua"""
        commands_file = SHARED_DIR / "jobs" / self.job_code / "functions" / f"{self.job_upper}_COMMANDS.lua"

        if not commands_file.exists():
            print(f"WARNING: Commands file not found: {commands_file}")
            return []

        with open(commands_file, 'r', encoding='utf-8') as f:
            content = f.read()

        commands = []

        # Extract command blocks
        command_pattern = r'if command == [\'"](\w+)[\'"] then'
        for match in re.finditer(command_pattern, content):
            command_name = match.group(1)

            # Skip universal commands
            if command_name in ['debugmidcast', 'altjobupdate', 'requestjob']:
                continue

            commands.append({'name': command_name, 'desc': f'{command_name.capitalize()} action'})

        return commands

    def generate_readme(self) -> str:
        """Generate README.md content"""
        keybinds = self.data.get('keybinds', [])
        states = self.data.get('states', [])
        commands = self.data.get('commands', [])

        keybind_count = len(keybinds)
        state_count = len(states)
        command_count = len(commands) + 6  # Universal commands

        # Extract special features from states
        special_features = []
        state_names = [s['name'] for s in states]
        if 'SaboteurMode' in state_names:
            special_features.append("Auto-Saboteur automation")
        if 'Storm' in state_names:
            special_features.append("Storm spells (SCH subjob)")
        if 'MainLightSpell' in state_names:
            special_features.append("Light/Dark elemental management")
        if 'Enspell' in state_names:
            special_features.append("Enspell automation")

        features_str = "\n- ".join(special_features) if special_features else "Standard job features"

        return f"""# {self.job_name} ({self.job_upper}) - GearSwap System Documentation

**Job Code**: {self.job_upper}
**System**: Tetsouo GearSwap
**Status**: ✅ Production Ready

---

## 📚 Documentation Files

| File | Description | Lines |
|------|-------------|-------|
| [Quick Start](quick-start.md) | Load and use system | ~150 |
| [Keybinds](keybinds.md) | All keybinds reference | ~200 |
| [Commands](commands.md) | All commands reference | ~200 |
| [States](states.md) | All states/modes | ~200 |
| [Sets](sets.md) | Equipment sets structure | ~300 |
| [Configuration](configuration.md) | Config files | ~200 |
| [Troubleshooting](troubleshooting.md) | Fix common issues | ~150 |

---

## 🚀 Quick Links

**First time using {self.job_upper}?** → Start with [Quick Start](quick-start.md)

**Need to find a keybind?** → Check [Keybinds](keybinds.md)

**Looking for a command?** → See [Commands](commands.md)

**Gear not swapping?** → Try [Troubleshooting](troubleshooting.md)

---

## 📊 {self.job_upper} System Overview

**Keybinds**: {keybind_count} total
**States**: {state_count} configurable modes
**Commands**: {command_count}+ available
**Special Features**:
- {features_str}

---

## 🔗 Related Documentation

- [Equipment Validation](../../features/equipment-validation.md)
- [Auto-Tier System](../../features/auto-tier-system.md)
- [Job Change Manager](../../features/job-change-manager.md)
- [MidcastManager System](../../../technical/systems/midcast-manager.md)

---

**Version**: 1.0
**Last Updated**: 2025-10-26
"""

    def generate_all_docs(self):
        """Generate all 8 documentation files for this job"""
        # Extract data
        print(f"\nExtracting data for {self.job_upper}...")
        self.data['keybinds'] = self.extract_keybinds()
        self.data['states'] = self.extract_states()
        self.data['lockstyle'] = self.extract_lockstyle_config()
        self.data['macrobook'] = self.extract_macrobook_config()
        self.data['commands'] = self.extract_commands()

        print(f"   Keybinds: {len(self.data['keybinds'])}")
        print(f"   States: {len(self.data['states'])}")
        print(f"   Commands: {len(self.data['commands'])}")

        # Create job directory
        job_dir = DOCS_DIR / self.job_code
        job_dir.mkdir(parents=True, exist_ok=True)

        # Generate each file
        print(f"\nGenerating documentation files...")

        # 1. README.md
        readme_content = self.generate_readme()
        (job_dir / "README.md").write_text(readme_content, encoding='utf-8')
        print(f"   [OK] README.md")

        # 2-8. Other files (use templates with basic substitution for now)
        # For brevity, we'll create simplified versions
        # You can expand these later with more detailed extraction

        self.generate_quick_start(job_dir)
        self.generate_keybinds(job_dir)
        self.generate_commands_doc(job_dir)
        self.generate_states_doc(job_dir)
        self.generate_sets_doc(job_dir)
        self.generate_configuration(job_dir)
        self.generate_troubleshooting(job_dir)

        print(f"\n[DONE] {self.job_upper} documentation complete!\n")

    def generate_quick_start(self, job_dir: Path):
        """Generate quick-start.md"""
        lockstyle = self.data['lockstyle']
        macrobook = self.data['macrobook']
        states = self.data['states']

        default_subjob = list(lockstyle['by_subjob'].keys())[0] if lockstyle['by_subjob'] else 'WAR'
        default_lock = lockstyle['default']
        default_book = macrobook['default']['book']
        default_page = macrobook['default']['page']

        # Default states
        default_states = []
        for state in states[:5]:  # First 5 states
            default_states.append(f"{state['name']}: {state['default']}")

        default_states_str = "\n  - ".join(default_states) if default_states else "Default states loaded"

        content = f"""# {self.job_upper} - Quick Start Guide

## 🚀 Loading the System

1. **Change to {self.job_upper} in-game**
2. **Load GearSwap**:
   ```
   //lua load gearswap
   ```
3. **Verify loading**:
   - Look for: `[{self.job_upper}] Functions loaded successfully`
   - Keybinds auto-loaded
   - Macrobook set to Book {default_book}, Page {default_page}
   - Lockstyle #{default_lock} applied after 8 seconds

---

## ✅ Verify System Loaded

**Check keybinds loaded**:
```
→ Console shows: "{self.job_upper} SYSTEM LOADED"
```

**Check UI (if enabled)**:
```
//gs c ui
→ Shows all keybinds overlay
```

**Validate equipment**:
```
//gs c checksets
→ Shows item validation (VALID/STORAGE/MISSING)
```

---

## 🎯 First Commands to Try

```
//gs c checksets          # Validate your equipment
//gs c ui                 # Toggle keybind display
//gs reload               # Reload system
```

---

## ⚙️ Default Setup

On load, system automatically:
- ✅ Loads all {self.job_upper} keybinds ({len(self.data['keybinds'])} total)
- ✅ Sets macrobook (Book {default_book}, Page {default_page} for {default_subjob})
- ✅ Applies lockstyle #{default_lock} (after 8s delay)
- ✅ Displays UI with keybinds (if enabled)
- ✅ Sets default states:
  - {default_states_str}

---

## 📚 Next Steps

- **Learn keybinds** → [Keybinds Reference](keybinds.md)
- **Try commands** → [Commands Reference](commands.md)
- **Understand states** → [States & Modes](states.md)
- **Customize** → [Configuration](configuration.md)
"""

        (job_dir / "quick-start.md").write_text(content, encoding='utf-8')
        print(f"   [OK] quick-start.md")

    def generate_keybinds(self, job_dir: Path):
        """Generate keybinds.md"""
        keybinds = self.data['keybinds']

        # Build keybind table
        table_rows = []
        for kb in keybinds:
            key = kb['key']
            command = kb['command']
            state = kb['state']
            desc = kb['desc']

            # Convert key format
            key_display = key.replace('!', 'Alt+').replace('^', 'Ctrl+').replace('@', 'Win+').replace('#', 'App+')
            key_display = key_display.upper() if len(key_display) == 1 else key_display

            state_display = f"`state.{state}`" if state != 'nil' else "-"

            table_rows.append(f"| **{key_display}** | {command} | {state_display} | {desc} |")

        table = "\n".join(table_rows)

        content = f"""# {self.job_upper} - Keybinds Reference

**Total Keybinds**: {len(keybinds)}
**Config File**: `Tetsouo/config/{self.job_code}/{self.job_upper}_KEYBINDS.lua`

---

## 📋 All Keybinds

| Key | Function | State | Description |
|-----|----------|-------|-------------|
{table}

---

## 🔑 Modifier Keys Reference

- `!` = Alt
- `^` = Ctrl
- `@` = Windows key
- `#` = Apps key

**Example**: `!1` = Alt+1

---

## 🧪 Testing Keybinds

1. Press a keybind (e.g., `Alt+1`)
2. Check console for state change message
3. Check UI overlay updates (if enabled)
4. Watch gear swap when performing action

**Manual test**:
```
//gs c cycle [StateName]  # Should work if system loaded
```

---

## 🔧 Customization

See [Configuration](configuration.md) for how to:
- Change keybind keys
- Add new keybinds
- Remove unused keybinds
"""

        (job_dir / "keybinds.md").write_text(content, encoding='utf-8')
        print(f"   [OK] keybinds.md")

    def generate_commands_doc(self, job_dir: Path):
        """Generate commands.md"""
        commands = self.data['commands']

        # Build command table
        command_rows = []
        for cmd in commands:
            command_rows.append(f"| `{cmd['name']}` | {cmd['desc']} | `//gs c {cmd['name']}` |")

        command_table = "\n".join(command_rows) if command_rows else "| No job-specific commands | - | - |"

        content = f"""# {self.job_upper} - Commands Reference

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

---

## 🎯 {self.job_upper}-Specific Commands

**File**: `shared/jobs/{self.job_code}/functions/{self.job_upper}_COMMANDS.lua`

| Command | Description | Usage |
|---------|-------------|-------|
{command_table}

---

## 🔍 Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Show set selection logic |
| `//gs c watchdog` | Check watchdog status |
| `//gs c state [StateName]` | Show current state value |
"""

        (job_dir / "commands.md").write_text(content, encoding='utf-8')
        print(f"   [OK] commands.md")

    def generate_states_doc(self, job_dir: Path):
        """Generate states.md"""
        states = self.data['states']
        keybinds = self.data['keybinds']

        # Build state table
        state_rows = []
        for state in states:
            name = state['name']
            options = ", ".join(state['options'])
            default = state['default']

            # Find keybind
            keybind = next((kb['key'].replace('!', 'Alt+').replace('^', 'Ctrl+') for kb in keybinds if kb['state'] == name), "-")

            state_rows.append(f"| **{name}** | {options} | {default} | {keybind} | {name} mode |")

        state_table = "\n".join(state_rows) if state_rows else "| No states | - | - | - | - |"

        content = f"""# {self.job_upper} - States & Modes

**Total States**: {len(states)}

---

## 📊 What are States?

States = Configuration options you cycle through with keybinds.

**Example**:
```lua
state.HybridMode = M{{'PDT', 'Normal'}}  -- 2 options
-- Press Alt+2 to cycle: PDT → Normal → PDT
```

---

## 📋 All {self.job_upper} States

| State | Options | Default | Keybind | Description |
|-------|---------|---------|---------|-------------|
{state_table}

---

## 🔍 Checking Current State

**Method 1**: UI overlay (if enabled)
**Method 2**: Console command:
```
//gs c state [StateName]
→ Shows current value
```
"""

        (job_dir / "states.md").write_text(content, encoding='utf-8')
        print(f"   [OK] states.md")

    def generate_sets_doc(self, job_dir: Path):
        """Generate sets.md"""
        content = f"""# {self.job_upper} - Equipment Sets Reference

**File**: `shared/jobs/{self.job_code}/sets/{self.job_code}_sets.lua`

---

## 📊 Set Categories

```lua
sets.precast = {{}}        -- Fast Cast, JA, WS
sets.midcast = {{}}        -- Spell/ability midcast
sets.idle = {{}}           -- Idle (not fighting)
sets.engaged = {{}}        -- Engaged (fighting)
```

---

## ⚡ Precast Sets

### Fast Cast
```lua
sets.precast.FC = {{
    -- Fast Cast gear (target: 80% cap)
}}
```

### Job Abilities
```lua
-- Job-specific abilities
```

### Weaponskills
```lua
-- Weaponskill sets
```

---

## 🎭 Midcast Sets

**MidcastManager Fallback Chain**:
```
Priority 1: sets.midcast['Skill'].Type.Mode  (most specific)
Priority 2: sets.midcast['Skill'].Type
Priority 3: sets.midcast['Skill'].Mode
Priority 4: sets.midcast['Skill']            (guaranteed)
```

---

## 🛡️ Idle Sets

```lua
sets.idle.Normal = {{ ... }}
sets.idle.PDT = {{ ... }}
```

---

## ⚔️ Engaged Sets

```lua
sets.engaged.Normal = {{ ... }}
sets.engaged.PDT = {{ ... }}
```

---

## ✅ Validating Sets

```
//gs c checksets

→ Output:
[{self.job_upper}] ✅ 156/160 items validated (97.5%)
```

**Status meanings**:
- ✅ VALID: In inventory
- 🗄️ STORAGE: In mog house/sack
- ❌ MISSING: Not found
"""

        (job_dir / "sets.md").write_text(content, encoding='utf-8')
        print(f"   [OK] sets.md")

    def generate_configuration(self, job_dir: Path):
        """Generate configuration.md"""
        lockstyle = self.data['lockstyle']
        macrobook = self.data['macrobook']

        # Lockstyle subjobs
        lockstyle_subjobs = "\n    ".join([f"['{sub}'] = {ls}," for sub, ls in lockstyle['by_subjob'].items()])

        # Macrobook subjobs
        macrobook_subjobs = "\n    ".join([f"['{sub}'] = {{book = {mb['book']}, page = {mb['page']}}}," for sub, mb in macrobook['solo'].items()])

        content = f"""# {self.job_upper} - Configuration Files

**Location**: `Tetsouo/config/{self.job_code}/`

---

## 📁 Configuration Files

| File | Purpose |
|------|---------|
| `{self.job_upper}_KEYBINDS.lua` | Keybind definitions |
| `{self.job_upper}_LOCKSTYLE.lua` | Lockstyle per subjob |
| `{self.job_upper}_MACROBOOK.lua` | Macrobook per subjob |
| `{self.job_upper}_STATES.lua` | State definitions |

---

## 🎨 Lockstyle Config

**File**: `Tetsouo/config/{self.job_code}/{self.job_upper}_LOCKSTYLE.lua`

```lua
local {self.job_upper}LockstyleConfig = {{}}

{self.job_upper}LockstyleConfig.default = {lockstyle['default']}

{self.job_upper}LockstyleConfig.by_subjob = {{
    {lockstyle_subjobs}
}}

return {self.job_upper}LockstyleConfig
```

**How it works**: When you change subjobs, the system automatically selects the lockstyle defined for that subjob.

---

## 📖 Macrobook Config

**File**: `Tetsouo/config/{self.job_code}/{self.job_upper}_MACROBOOK.lua`

```lua
local {self.job_upper}MacroConfig = {{}}

{self.job_upper}MacroConfig.default = {{book = {macrobook['default']['book']}, page = {macrobook['default']['page']}}}

{self.job_upper}MacroConfig.solo = {{
    {macrobook_subjobs}
}}

return {self.job_upper}MacroConfig
```

**How it works**: Similar to lockstyle, macrobooks change automatically when you change subjobs.

---

## 🔧 Customization Examples

### Change lockstyle
```lua
-- Modify {self.job_upper}_LOCKSTYLE.lua
{self.job_upper}LockstyleConfig.by_subjob = {{
    ['SAM'] = 5,  -- Changed to lockstyle #5
}}
```

### Modify macrobook
```lua
-- Modify {self.job_upper}_MACROBOOK.lua
{self.job_upper}MacroConfig.solo = {{
    ['SAM'] = {{book = 2, page = 3}},  -- Changed book/page
}}
```
"""

        (job_dir / "configuration.md").write_text(content, encoding='utf-8')
        print(f"   [OK] configuration.md")

    def generate_troubleshooting(self, job_dir: Path):
        """Generate troubleshooting.md"""
        content = f"""# {self.job_upper} - Troubleshooting

---

## ❌ Keybinds Not Working

**Symptoms**: Pressing Alt+1 does nothing

**Solutions**:

1. **Check keybinds loaded**:
   ```
   Look for: "[{self.job_upper}] Keybinds loaded successfully"
   ```

2. **Manual test**:
   ```
   //gs c cycle [StateName]
   ```

3. **Reload GearSwap**:
   ```
   //gs reload
   ```

---

## ❌ Gear Not Swapping

**Symptoms**: Equipment doesn't change

**Solutions**:

1. **Check Watchdog**:
   ```
   //gs c watchdog
   → Should show: "Watchdog: ENABLED"
   ```

2. **Check items**:
   ```
   //gs c checksets
   → Look for STORAGE or MISSING items
   ```

3. **Enable debug**:
   ```
   //gs c debugmidcast
   ```

---

## ❌ Lockstyle Not Applying

**Symptoms**: Character appearance doesn't change

**Solutions**:

1. **Check DressUp addon**:
   ```
   //lua l dressup
   ```

2. **Manual trigger**:
   ```
   //gs c lockstyle
   ```

3. **Verify config**:
   Check `Tetsouo/config/{self.job_code}/{self.job_upper}_LOCKSTYLE.lua`

---

## 🔍 Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Show set selection logic |
| `//gs c watchdog` | Check watchdog status |
| `//gs c state [StateName]` | Show current state value |
| `//gs c checksets` | Validate equipment |
| `//gs c ui` | Toggle UI overlay |
| `//gs reload` | Full system reload |

---

## 🆘 Still Having Issues?

1. **Check error messages** in console carefully
2. **Verify file structure** matches [Configuration](configuration.md)
3. **Reload GearSwap** after making changes
"""

        (job_dir / "troubleshooting.md").write_text(content, encoding='utf-8')
        print(f"   [OK] troubleshooting.md")


def main():
    """Generate documentation for all jobs"""
    print("=" * 60)
    print("GearSwap Job Documentation Generator")
    print("=" * 60)

    for job_code, job_name in JOBS:
        print(f"\n{'='*60}")
        print(f"Processing: {job_name} ({job_code.upper()})")
        print(f"{'='*60}")

        generator = JobDocGenerator(job_code, job_name)
        generator.generate_all_docs()

    print("\n" + "=" * 60)
    print("ALL JOBS DOCUMENTATION COMPLETE!")
    print("=" * 60)
    print(f"\nGenerated documentation for {len(JOBS)} jobs")
    print(f"Location: {DOCS_DIR}")


if __name__ == "__main__":
    main()
