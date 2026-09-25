# THF — modes and keys

Thief: weapons, Treasure Hunter, Sneak/Trick Attack gear, a ranged lock, and
one-key ability chains (`smartbuff`, `fbc`, `steal`).

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each
mode's current value; this page says what each value does. `#numpad0` (Auto
Medicine) and Alt+Numpad7-9 (alts) are common to every job, see
[keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| `^numpad1` | Main Weapon (`MainWeapon`) | **Vajra**, TwashtarM, Mpu Gandring, Tauret, Naegling, Malevolence, Dagger | Main hand (`sets.<Weapon>` from your set file). |
| `^numpad2` | Sub Weapon (`SubWeapon`) | **Centovente**, Tanmogayi, Kraken | Off hand. Tetsouo's own file adds Telop Knife. |
| `^numpad9` | Hybrid Mode (`HybridMode`) | **PDT**, Normal | Engaged set: `sets.engaged.PDT` or `sets.engaged.Normal`. |
| `^numpad3` | TH Mode (`TreasureMode`) | **Tag**, SATA, Full | See Treasure Hunter below. |
| `^numpad4` | Aby Proc (`AbyProc`) | **Off**, On | /WAR only. On: the Aby Weapon set replaces your main and sub weapons (Abyssea weapon-type procs). |
| `^numpad5` | Aby Weapon (`AbyWeapon`) | Dagger2, **Sword**, Club, Great Sword, Polearm, Staff, Scythe | /WAR only. The weapon pair used when Aby Proc is On (`sets.<Name>`). |
| `^numpad6` | Range Lock (`RangeLock`) | **Off**, On | On locks the range and ammo slots so ranged gear stays on. |

## Other modes (no key)

| Mode | Values | What it does |
|---|---|---|
| `FastCast` | 0 to 80 in steps of 10, default **0** | Your Fast Cast %, used only by the midcast watchdog. Change the default in `THF_STATES.lua`, or step it with `//gs c cycle FastCast`. |

## Commands

| Command | What it does |
|---|---|
| `//gs c smartbuff` | By subjob. /DNC: Haste Samba if it is down, ready and you have 350 TP. /WAR: Berserk, Aggressor, Warcry (the ready ones, 2 s apart). /NIN: Utsusemi: Ni, else Ichi. |
| `//gs c fbc` | Feint, Bully, Conspirator: the ones that are ready (and whose buff is not already up), 1 s apart. |
| `//gs c steal` | Steal, Mug, Despoil (the ready ones) on your target. Does nothing unless the target is a living monster. |
| `//gs c range` | Equips Exalted Crossbow and Acid Bolt (names fixed in the code), locks range and ammo, then shoots `/ra <stnpc>`. |

## Notes

- **Treasure Hunter.** Tag: `sets.TreasureHunter` goes on while engaged until
  the current target has been hit once by you (tagged), then comes off. SATA:
  same, and under Sneak/Trick Attack the `TreasureHunterSA` / `TA` / `SATA`
  sets are used. Full: `sets.TreasureHunter` stays on all the time, with the
  SATA sets. A tagged mob is forgotten when it dies, when you zone, or after
  180 s with no action on it.
- **Sneak Attack / Trick Attack.** While the buff is up and you are engaged,
  `sets.buff['Sneak Attack']` / `['Trick Attack']` go on top; they come off
  when the buff is used.
- **Aftermath Lv.3 with Vajra**: the engaged set becomes `sets.engaged.PDTAFM3`.
- **Range lock.** Any ranged attack turns Range Lock On by itself. A reload, a
  job or subjob change, or `//gs c wo` releases the lock and sets it back to Off.
- After a ranged attack with Acid Bolt equipped, an Ac. Bolt Quiver from your
  inventory is opened when 5 bolts or fewer are left.
- Idle: town and Adoulin sets in town, `sets.MoveSpeed` while moving outside town.
- Weaponskill TP bonus gear: see [TP bonus](../war/tp-bonus.md).
- Every mode goes back to its default on each job change, subjob change or reload.

## Files

In `<Char>/config/thf/`: `THF_STATES.lua` (modes and defaults),
`THF_KEYBINDS.lua` (keys), `THF_CUSTOM.lua` (your own modes and gear, see
[keybinds](../../guides/keybinds.md)), `THF_LOCKSTYLE.lua`, `THF_MACROBOOK.lua`,
`THF_TP_CONFIG.lua`. See [configuration](../../guides/configuration.md).
