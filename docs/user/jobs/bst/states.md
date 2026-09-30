# BST — modes and keys

Beastmaster modes pick your weapons, who is protected while the pet is out, whether
the pet is sent in by itself, and which jug pet Call Beast brings.

Start page for this job (every key, command and shared feature): [README.md](README.md).
Set names and automatic gear: [sets.md](sets.md).

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. Every mode goes back to its
default at each job or subjob change.

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| Ctrl+Numpad1 `^numpad1` | `WeaponSet` | **Aymur**, Tauret | Main weapon, put on in idle and engaged gear (set named after the value) |
| Ctrl+Numpad2 `^numpad2` | `SubSet` | **Agwu's Axe**, Adapa Shield, Diamond Aspis, Kraken Club | Off-hand or shield, same way |
| Ctrl+Numpad9 `^numpad9` | `HybridMode` | **PDT**, Normal | PDT adds the `.PDT` version of the set in use (idle and engaged); Normal leaves it out. Exception: while you idle with a pet out that is not fighting, the base is a `.PDT` set whatever this says (see `PetIdleMode`) |
| Ctrl+Numpad4 `^numpad4` | `AutoPetEngage` | Off, **On** | On: once per second, if you are engaged and the pet is not fighting, `/pet "Fight" <t>` is sent. A Heel while you fight is undone within a second. Paused while `rdymove` runs |
| Ctrl+Numpad3 `^numpad3` | `PetIdleMode` | **MasterPDT**, PetPDT | You idle, pet out and **not** fighting: MasterPDT wears `sets.me.idle.PDT` (protects you), PetPDT wears `sets.pet.idle.PDT` (protects the pet). Pet fighting: `sets.pet.engaged` whatever this says |
| Ctrl+Numpad5 `^numpad5` | `Ecosystem` | **Aquan**, Beast, Amorph, Bird, Lizard, Plantoid, Vermin | Runs `//gs c ecosystem`: next ecosystem; the species list is rebuilt and the jug choice goes to that ecosystem's first pet |
| Ctrl+Numpad6 `^numpad6` | `species` | species of the current ecosystem | Runs `//gs c species`: next species; the jug of that pet is the one Call Beast / Bestial Loyalty put in the ammo slot |

The provided pet list has one pet per species, so choosing the species chooses the
pet. The list order inside an ecosystem is not the order of `BST_PET_DATA.lua`.

## Other modes (no key)

| Mode | Values | Notes |
|---|---|---|
| `FastCast` | 0 to 80 by 10, default **0** | Your Fast Cast %, used by the midcast watchdog to time a spell (`//gs c cycle FastCast`, or its default in `BST_STATES.lua`) |
| `AutoMedicine` | On / Off | Apps+Numpad0, common to every job |
| `ammoSet` | pet names | The pet whose jug Call Beast uses; set by the ecosystem and species keys, not shown in the HUD |
| `PetEngaged`, `Moving` | 'false' / 'true' | Kept up to date by the pet check (every second) and by AutoMove; not meant to be changed by hand |

Combat Mode and Treasure Mode exist on BST too, hidden until you show them
(`//gs c combatmode show`, `//gs c th show`); see [README.md](README.md#all-keys-on-this-job).

## Commands

| Command | What it does |
|---|---|
| `//gs c ecosystem` / `species` | Same as the two keys above. `species` also prints how many jugs of that species you carry (inventory and wardrobes 1-8) |
| `//gs c pet engage` / `pet disengage` | `/pet "Fight" <t>` / `/pet "Heel" <me>` |
| `//gs c rdylist` | Lists your pet's Ready moves, numbered |
| `//gs c rdymove N` | Uses Ready move N. Pet fighting: at once. Pet idle: `Fight` on a target you pick with the cursor (`<stnpc>`), the move 3.5 s later; if you were idle too, `Heel` 6 s after the start |
| `//gs c broth` (`broths`) | Counts the items with "Broth" in their name in your inventory (Crumbly Soil, Aged Humus, Gassy Sap, Windy Greens and T. Pristine Sap are not counted) |
| `//gs c debugprecast` | On BST: traces the summon and Ready precast gear (not the common precast debug) |

The Ready move list is kept 30 s: right after changing pet, `rdylist` / `rdymove`
can still show the previous pet's moves for up to 30 s.

## Notes

- AutoMove runs on BST like on every job: `Moving` adds `sets.MoveSpeed` to your idle
  gear while you move.
- Changing ecosystem or species prints "Equipping <jug> for <pet>", but nothing is
  equipped at that moment; the jug goes on only with Call Beast / Bestial Loyalty.

## Files

`<YourName>/bst/`: `BST_STATES.lua`, `BST_KEYBINDS.lua`, `BST_CUSTOM.lua` (your
own modes and keys, see [keybinds](../../guides/keybinds.md)), `BST_PET_DATA.lua`
(pets, species, jugs), `BST_LOCKSTYLE.lua` (style 6), `BST_MACROBOOK.lua` (book 12
page 1; book 13 or 14 with a GEO or COR partner while /DNC), `BST_TP_CONFIG.lua`,
`BST_HUD.lua`. `BST_ECOSYSTEM_DATA.lua` is not read by anything. Details:
[README.md](README.md#configuration-files-for-this-job).
