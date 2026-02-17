# Equipment Validation

Checks all configured gear sets against your inventory and storage.

**Command**: `//gs c checksets`

---

## Output

```
[WAR] Validating equipment sets...
[WAR] 156/160 items validated (97.5%)

--- STORAGE ITEMS (3) ---
[STORAGE] sets.precast.WS['Upheaval'].neck: "Fotia Gorget"
[STORAGE] sets.idle.PDT.body: "Sakpata's Plate"

--- MISSING ITEMS (1) ---
[MISSING] sets.precast.WS['Savage Blade'].ring1: "Epaminondas's Ring"

[WAR] Validation complete!
```

### Status meanings

| Status | Meaning | Action |
|--------|---------|--------|
| VALID | In inventory | None |
| STORAGE | In mog house / sack / wardrobe | Move to inventory if needed |
| MISSING | Not found anywhere | Acquire the item or fix the name in sets |

Item count is **unique items only** -- the same piece appearing in 5 sets counts as 1.

---

## When to use

- After modifying gear sets (catch typos immediately)
- Before important content (confirm all gear is in inventory)
- After job change (verify sets loaded correctly -- wait 2-3 seconds first)

---

## Troubleshooting

**Item shows MISSING but you own it**: Check spelling in your sets file. Item names are case-sensitive and must match exactly (e.g., `Sakpata's Helm` not `Sakpata Helm`). Items in Porter Moogle or Delivery Box are not scanned.

**0% after job change**: Sets haven't loaded yet. Run `//lua reload gearswap`, wait 2-3 seconds, then `//gs c checksets`.
