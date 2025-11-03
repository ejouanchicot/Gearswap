# RDM - Troubleshooting

---

## ❌ Keybinds Not Working

**Symptoms**: Pressing Alt+1 does nothing

**Solutions**:

1. **Check keybinds loaded**:

   ```
   Look for: "RDM SYSTEM LOADED" in console
   ```

2. **Check for conflicts**:

   ```
   //bind  # Shows all current binds
   ```

   Look for conflicts with your Alt+1, Alt+2, etc.

3. **Manual test**:

   ```
   //gs c cycle MainWeapon  # Test if command system works
   ```

4. **Verify config file exists**:

   ```
   Check: Tetsouo/config/rdm/RDM_KEYBINDS.lua
   ```

5. **Reload GearSwap**:

   ```
   //gs reload
   ```

---

## ❌ Gear Not Swapping

**Symptoms**: Equipment doesn't change when casting/engaging

**Solutions**:

1. **Check Watchdog status**:

   ```
   //gs c watchdog
   → Should show: "Watchdog: ENABLED"
   ```

2. **Check item availability**:

   ```
   //gs c checksets
   → Look for STORAGE or MISSING items
   ```

3. **Enable debug mode**:

   ```
   //gs c debugmidcast
   → Cast a spell and check console output
   ```

4. **Check CombatMode**:

   ```
   If weapons not swapping, check:
   Alt+0 (cycle CombatMode to Off)
   → CombatMode: On locks weapon slots
   ```

5. **Full reload**:

   ```
   //gs reload
   ```

---

## ❌ Wrong Set Equipped for Enfeebles

**Symptoms**: Wrong gear for Gravity, Slow, etc.

**Solutions**:

1. **Enable midcast debug**:

   ```
   //gs c debugmidcast
   /ma "Gravity" <t>
   → Shows which set was selected and why
   ```

2. **Check EnfeebleMode state**:

   ```
   //gs c state EnfeebleMode
   → Shows: "EnfeebleMode: Potency" (or Skill/Duration)
   ```

3. **Check spell database**:
   - RDM uses `RDM_SPELL_DATABASE` to classify enfeebles
   - Gravity = mnd_accuracy type
   - Slow = mnd_potency type
   - Debug will show which type was detected

4. **Check set exists**:

   ```lua
   -- In rdm_sets.lua, verify:
   sets.midcast['Enfeebling Magic'].mnd_accuracy.Potency = { ... }
   ```

5. **Understand fallback chain**:
   - If `mnd_accuracy.Potency` missing → tries `mnd_accuracy`
   - If `mnd_accuracy` missing → tries `Potency`
   - If `Potency` missing → uses base `sets.midcast['Enfeebling Magic']`

---

## ❌ Auto-Saboteur Not Working

**Symptoms**: Saboteur doesn't trigger before enfeebles

**Solutions**:

1. **Check SaboteurMode**:

   ```
   Press Alt+P
   → Should show: "SaboteurMode: On"
   ```

2. **Check spell in config**:

   ```lua
   -- In RDM_SABOTEUR_CONFIG.lua:
   RDMSaboteurConfig.auto_trigger_spells = {
       'Slow II',  -- Must be in this list
       'Paralyze II',
       -- ...
   }
   ```

3. **Check Saboteur ready**:

   ```
   Saboteur must be off cooldown
   System will NOT trigger if on cooldown
   ```

4. **Check console for errors**:

   ```
   Look for: "Saboteur not ready" or similar messages
   ```

5. **Manual test**:

   ```
   //gs c saboteur  # Test if Saboteur command works
   ```

---

## ❌ Elemental Spells Not Casting

**Symptoms**: Ctrl+8 doesn't cast Fire spell

**Solutions**:

1. **Check states configured**:

   ```
   //gs c state MainLightSpell
   → Should show: "MainLightSpell: Fire" (or Aero/Thunder)

   //gs c state NukeTier
   → Should show: "NukeTier: V" (or VI/IV/etc.)
   ```

2. **Check spell name construction**:

   ```
   MainLightSpell: Fire + NukeTier: V
   → Should cast "Fire V"

   MainLightSpell: Thunder + NukeTier: VI
   → Should cast "Thunder VI"
   ```

3. **Manual cast test**:

   ```
   /ma "Fire V" <t>  # Test if spell exists/castable
   ```

4. **Check command in RDM_COMMANDS.lua**:

   ```lua
   -- Verify castlight command exists:
   elseif command == 'castlight' then
       -- Cast Main Light elemental spell with tier
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

3. **Check cooldown**:
   Wait 15 seconds between lockstyle changes (cooldown protection).

4. **Verify config**:

   ```lua
   -- Check Tetsouo/config/rdm/RDM_LOCKSTYLE.lua
   RDMLockstyleConfig.by_subjob = {
       ['NIN'] = 1,  -- Valid lockstyle number
       -- ...
   }
   ```

5. **Check subjob**:

   ```
   //gs c state MainJob
   → If subjob not in config, uses default
   ```

---

## ❌ Storm Spells Not Available

**Symptoms**: F5 doesn't cycle Storm spells

**Solutions**:

1. **Check subjob**:

   ```
   Storm spells require SCH subjob
   → Change to RDM/SCH
   ```

2. **Verify state created**:

   ```
   //gs c state Storm
   → If no SCH subjob: "State not found"
   → With SCH subjob: "Storm: Firestorm"
   ```

3. **Check job_sub_job_change**:

   ```lua
   -- In TETSOUO_RDM.lua:
   -- Storm state is conditionally created when SCH subjob detected
   ```

---

## ❌ Weapons Not Switching

**Symptoms**: Alt+1/Alt+2 don't change weapons

**Solutions**:

1. **Check CombatMode**:

   ```
   Press Alt+0
   → CombatMode: Off (weapons can swap)
   → CombatMode: On (weapons LOCKED)
   ```

2. **Check state cycling**:

   ```
   //gs c cycle MainWeapon
   → Should show: "MainWeapon: Naegling/Colada/Daybreak"
   ```

3. **Check weapon in inventory**:

   ```
   //gs c checksets
   → Verify weapon items not MISSING
   ```

4. **Check RDM_ENGAGED module**:

   ```lua
   -- In RDM_ENGAGED.lua:
   -- Weapons equipped based on state.MainWeapon.value
   ```

5. **Force equipment update**:

   ```
   //gs c reload
   Press Alt+1 (cycle MainWeapon)
   ```

---

## ❌ Job Change Errors

**Symptoms**: Errors when changing jobs

**Solutions**:

1. **Wait for debounce**:
   JobChangeManager has 3.0s debounce. Wait 3 seconds after job change before reloading.

2. **Manual cleanup**:

   ```
   //lua unload gearswap
   //lua load gearswap
   ```

3. **Check console**:
   Look for error messages and file paths that failed to load.

4. **Verify all modules loaded**:

   ```
   Look for: "[RDM] Functions loaded successfully"
   ```

---

## ❌ UI Not Showing

**Symptoms**: UI overlay doesn't appear

**Solutions**:

1. **Check UI enabled**:

   ```lua
   -- In Tetsouo/config/UI_CONFIG.lua:
   UIConfig.enabled = true  -- Must be true
   ```

2. **Manual toggle**:

   ```
   //gs c ui
   → Toggles UI visibility
   ```

3. **Check UI_MANAGER loaded**:

   ```
   Look for: "[RDM] Initializing UI..." in console
   ```

4. **Reload GearSwap**:

   ```
   //gs reload
   ```

5. **Check position**:

   ```lua
   -- In UI_CONFIG.lua:
   UIConfig.default_position = { x = 1600, y = 300 }
   -- Adjust x/y if UI off-screen
   ```

---

## 🔍 Debug Commands

| Command | Purpose |
|---------|---------|
| `//gs c debugmidcast` | Toggle midcast debug (shows set selection) |
| `//gs c watchdog` | Check watchdog status (should be ENABLED) |
| `//gs c state [StateName]` | Show current value of a state |
| `//gs c checksets` | Validate equipment (shows VALID/STORAGE/MISSING) |
| `//gs c ui` | Toggle UI overlay (shows keybinds) |
| `//gs reload` | Full system reload |

---

## 🆘 Still Having Issues?

1. **Check error messages** in console carefully
2. **Compare with working job** (e.g., WHM, BLM)
3. **Verify file structure** matches [Configuration](configuration.md)
4. **Check for typos** in config files (case-sensitive!)
5. **Reload GearSwap** after making changes
6. **Check RDM_SPELL_DATABASE** for spell classifications
7. **Enable debugmidcast** to see set selection logic

**Common Mistakes**:

- Typo in state name: `state.EnfeebleMode` vs `state.enfeeblemode` (case matters!)
- Missing set: `sets.midcast['Enfeebling Magic'].mnd_potency.Potency` not defined
- Wrong spell type in database: Spell classified as wrong type
- CombatMode ON: Weapons locked, can't swap
- SaboteurMode ON but spell not in config list
