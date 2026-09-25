# BST — modes and keys

Beastmaster modes pick your weapons, your pet's idle stance and which jug pet you call.

Keys: Ctrl = `^`, Apps = `#` (the menu key). The HUD (`//gs c ui`) shows each mode's
current value; this page says what each value does. `#numpad0` (Auto Medicine) and
Alt+Numpad7-9 (alts) are common to every job, see [keybinds](../../guides/keybinds.md).

## Keys

| Key | Mode (state) | Values (default in **bold**) | What it does |
|---|---|---|---|
| Ctrl+Numpad1 `^numpad1` | `WeaponSet` | **Aymur**, Tauret | Main weapon |
| Ctrl+Numpad2 `^numpad2` | `SubSet` | **Agwu's Axe**, Adapa Shield, Diamond Aspis, Kraken Club | Off-hand or shield |
| Ctrl+Numpad9 `^numpad9` | `HybridMode` | **PDT**, Normal | Idle and engaged: PDT adds damage-taken gear |
| Ctrl+Numpad4 `^numpad4` | `AutoPetEngage` | Off, **On** | On: while you are engaged, a pet that is not fighting is sent in (`/pet "Fight" <t>`) |
| Ctrl+Numpad3 `^numpad3` | `PetIdleMode` | **MasterPDT**, PetPDT | Idle with a pet out: protect yourself or the pet |
| Ctrl+Numpad5 `^numpad5` | `Ecosystem` | **Aquan**, Beast, Amorph, Bird, Lizard, Plantoid, Vermin | Runs `//gs c ecosystem`: next ecosystem, and rebuilds the species list |
| Ctrl+Numpad6 `^numpad6` | `species` | species of the current ecosystem | Runs `//gs c species`: next species; the jug of that pet is equipped for Call Beast |

## Other modes (no key)

| Mode | Values | Notes |
|---|---|---|
| `FastCast` | 0 to 80 by 10, default **0** | Your Fast Cast %, used by the midcast watchdog (`//gs c cycle FastCast`, or its default in `BST_STATES.lua`) |
| `PetEngaged`, `Moving` | 'false' / 'true' | Kept up to date by the job itself and by AutoMove; not meant to be changed by hand |

## Commands

| Command | What it does |
|---|---|
| `//gs c ecosystem` / `species` | Same as the two keys above |
| `//gs c pet engage` / `pet disengage` | `/pet "Fight" <t>` / `/pet "Heel" <me>` |
| `//gs c rdylist` | Lists your pet's Ready moves, numbered |
| `//gs c rdymove N` | Uses Ready move N. If the pet is idle it is sent to fight first, and when you are both idle it heels afterwards |
| `//gs c broth` (`broths`) | Counts the items with "Broth" in their name in your inventory |
| `//gs c debugprecast` | On BST: traces pet and summon precast (not the common precast debug) |

## Notes

- AutoMove runs on BST like on every job: `Moving` adds `sets.MoveSpeed` while you move.
- Tetsouo's own folder starts `Ecosystem` on Amorph.

## Files

`<Char>/config/bst/`: `BST_STATES.lua`, `BST_KEYBINDS.lua`, `BST_CUSTOM.lua` (your own
modes and keys, see [keybinds](../../guides/keybinds.md)), `BST_PET_DATA.lua` and
`BST_ECOSYSTEM_DATA.lua` (pets, species, jugs), `BST_LOCKSTYLE.lua` (style 6),
`BST_MACROBOOK.lua` (book 12 page 1 solo, other books per dual-box partner job),
`BST_TP_CONFIG.lua`.
