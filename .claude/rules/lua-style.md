# Lua Code Style - GearSwap Project

## Naming
- Local variables: `snake_case` (`local my_var = {}`)
- Modules: `CamelCase` (`local MyModule = {}`)
- Mote states: `state.CamelCase = M{}` (`state.MainWeapon = M{}`)
- Functions: `snake_case` (`function job_precast()`)
- Equipment vars: `CamelCase` (`SouvHead`, `Cichol`, `MoonlightRing1`)
- Equipment variants: dot + lowercase (`Cichol.da`, `Cichol.stp`, `Cichol.ws`)
- File names: `[JOB]_UPPERCASE.lua` for function modules, `[job]_lowercase.lua` for facades/sets

## Module Pattern
- Lazy-load with `ensure_modules_loaded()` + `modules_loaded` flag
- Safe loading: `local ok, mod = pcall(require, 'path/to/module')`
- Check before use: `if Module and Module.method then`
- Always export via BOTH `_G.job_function = job_function` AND `return`

## Constraints
- Files < 600 lines, functions < 30 lines (except `job_self_command` dispatchers)
- NO `loadfile`, `setfenv`, `dofile` (nil in GearSwap sandbox)
- NO direct `add_to_chat()` - use `MessageFormatter`
- NO manual lockstyle/macrobook code - use factories
- `include()` for set files, `require()` for modules
- `set_combine()` for set inheritance (GearSwap global)

## Language
- Code comments in English
- User-facing messages can be French or English (follow existing pattern)
