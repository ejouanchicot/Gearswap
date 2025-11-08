# Job Documentation Index

**Tetsouo GearSwap System**
**Last Updated**: 2025-10-26

---

## 📚 Available Jobs

This section contains modular documentation for all 13 supported jobs in the Tetsouo GearSwap system.

Each job has **8 dedicated documentation files**:

- **README.md** - Job overview and navigation
- **quick-start.md** - Loading and first steps
- **keybinds.md** - All keybinds reference
- **commands.md** - All commands reference
- **states.md** - All states and modes
- **sets.md** - Equipment sets structure
- **configuration.md** - Configuration files
- **troubleshooting.md** - Fix common issues

---

## 🎯 Mage Jobs

| Job | Full Name | Keybinds | States | Special Features |
|-----|-----------|----------|--------|------------------|
| [RDM](rdm/README.md) | Red Mage | 32 | 20 | Enfeebling, Nuking, Light/Dark elements, Auto-Saboteur |
| [WHM](whm/README.md) | White Mage | 9 | 6 | Healing, Buffs, Regen |
| [BLM](blm/README.md) | Black Mage | 14 | 1 | Nuking, Magic Burst, Elemental Magic |
| [GEO](geo/README.md) | Geomancer | 13 | 0 | Geomancy, Indicolure, Luopan |

---

## 🎵 Support Jobs

| Job | Full Name | Keybinds | States | Special Features |
|-----|-----------|----------|--------|------------------|
| [BRD](brd/README.md) | Bard | 23 | 0 | Songs, Instruments, Rotation |
| [COR](cor/README.md) | Corsair | 8 | 0 | Rolls, Phantom Roll, Quick Draw |

---

## 🛡️ Tank Jobs

| Job | Full Name | Keybinds | States | Special Features |
|-----|-----------|----------|--------|------------------|
| [PLD](pld/README.md) | Paladin | 3 | 1 | Shields, Cures, Enmity |

---

## ⚔️ Melee Jobs

| Job | Full Name | Keybinds | States | Special Features |
|-----|-----------|----------|--------|------------------|
| [WAR](war/README.md) | Warrior | 3 | 0 | Melee DPS, Berserk, Warcry |
| [SAM](sam/README.md) | Samurai | 5 | 1 | Melee DPS, Skillchains, TP |
| [DNC](dnc/README.md) | Dancer | 11 | 0 | Melee DPS, Waltzes, Steps |
| [THF](thf/README.md) | Thief | 6 | 0 | Melee DPS, Steal, Treasure Hunter |
| [DRK](drk/README.md) | Dark Knight | 3 | 1 | Melee DPS, Dark Magic, Absorbs |

---

## 🦁 Pet Jobs

| Job | Full Name | Keybinds | States | Special Features |
|-----|-----------|----------|--------|------------------|
| [BST](bst/README.md) | Beastmaster | 11 | 0 | Pet commands, Jug Pets, Ready abilities |

---

## 🔗 Quick Links

**New to Tetsouo GearSwap?**

- Start with [RDM](rdm/quick-start.md) for a complete example
- All jobs follow the same structure

**Looking for specific info?**

- Keybinds >> `[job]/keybinds.md`
- Commands >> `[job]/commands.md`
- States >> `[job]/states.md`
- Troubleshooting >> `[job]/troubleshooting.md`

**System Documentation**:

- [Equipment Validation](../features/equipment-validation.md)
- [Job Change Manager](../features/job-change-manager.md)
- [MidcastManager System](../../technical/systems/midcast-manager.md)

---

## 📊 Documentation Statistics

| Metric | Count |
|--------|-------|
| **Total Jobs** | 13 |
| **Total Files** | 104 (8 per job) |
| **Total Keybinds** | 129 |
| **Average Keybinds per Job** | ~10 |
| **Jobs with 10+ Keybinds** | 5 (RDM, BLM, GEO, BRD, BST, DNC) |

---

## 🆕 Recent Changes

**2025-10-26**:

- ✅ Migrated from monolithic `guide.md` to modular 8-file structure
- ✅ Automated documentation generation via Python script
- ✅ Extracted keybinds, states, commands from actual code
- ✅ Standardized structure across all 13 jobs
- ✅ Removed old `guide.md` files

---

## 📝 Maintenance Notes

**Adding a New Job**:

1. Create config files in `Tetsouo/config/[job]/`
2. Create job modules in `shared/jobs/[job]/`
3. Run `python generate_job_docs.py` to auto-generate documentation
4. Review and enhance generated documentation as needed

**Updating Documentation**:

1. Modify source config/code files
2. Re-run `python generate_job_docs.py`
3. Review changes in `docs/user/jobs/[job]/`

---

**Version**: 1.0
**System**: Tetsouo GearSwap Production-Ready (9.8/10)
