# FFXI Attack/PDL System - Documentation Technique

## Formule de dégâts physiques

```
Ratio = Attack / Defense
pDIF = f(Ratio) → cappé selon le type d'arme
Damage = Base × pDIF × autres multiplicateurs
```

**Principe:** Quand le ratio Attack/Defense atteint le cap, ajouter +Attack devient inutile.
Il faut alors privilégier **PDL** (Physical Damage Limit) qui augmente le plafond du pDIF.

---

## Caps pDIF par type d'arme

| Type d'arme | Cap pDIF | Ratio pour cap |
|-------------|----------|----------------|
| Dagger | 3.25 | ~2.5 |
| Sword | 3.25 | ~2.5 |
| Katana | 3.25 | ~2.5 |
| Axe/Club | 3.25 | ~2.5 |
| Great Katana | 3.50 | ~2.75 |
| Hand-to-Hand | 3.50 | ~2.75 |
| Great Sword | 3.75 | ~3.0 |
| Polearm/Staff | 3.75 | ~3.0 |
| Great Axe | 3.75 | ~3.0 |
| Scythe | 4.00 | ~3.25 |

---

## Defense des mobs par niveau

| Niveau | Defense | Exemple |
|--------|---------|---------|
| LV135 | ~1338 | Mobs standards |
| LV140 | ~1530 | Mobs difficiles |
| LV145 | ~1704 | Boss Sortie |

---

## Valeurs des buffs (testées in-game)

### BRD - Bonus FLAT (additif)

**Setup testé:** Gjallarhorn + Moonbow+1 + Fili Hongreline (+8 song)
**Songs:** Honor March + Minuet V + Minuet IV

| Mode | Bonus Attack |
|------|--------------|
| Marcato | **+826** |
| Soul Voice (2hr) | **+1416** |

> Note: Soul Voice ≈ 2× Marcato

### COR - Bonus % (multiplicatif)

**Setup testé:** Rostam (+8 Phantom Roll), proc DRK via Lanun Tricorne

| Roll | Multiplicateur |
|------|----------------|
| Chaos Roll 11 | **×1.56 (+56%)** |

### GEO - Bonus % (multiplicatif)

**Setup testé:** Idris (+10 Geomancy)

| Buff | Multiplicateur |
|------|----------------|
| Fury | **×1.62 (+62%)** |

---

## Formule de stacking (confirmée in-game)

```lua
attack_finale = (base_attack + brd_flat) × cor_mult × geo_mult
```

Les buffs s'appliquent dans cet ordre:

1. **BRD (flat)** - S'ajoute à la base
2. **COR (%)** - Multiplie le total
3. **GEO (%)** - Multiplie le total

### Exemples de calcul

```lua
-- Base BRD: 1224 Attack
-- Boss Sortie: 1704 Defense

-- Avec Marcato + COR + GEO
attack = (1224 + 826) × 1.56 × 1.62 = 5181
ratio = 5181 / 1704 = 3.04 → CAPPÉ

-- Avec Soul Voice + COR + GEO
attack = (1224 + 1416) × 1.56 × 1.62 = 6672
ratio = 6672 / 1704 = 3.91 → TRÈS CAPPÉ
```

---

## Tests réels par job

### BRD (base: 941-1224 Attack)

| Situation | Attack | Ratio (vs 1704) | Cappé? |
|-----------|--------|-----------------|--------|
| Base | 941 | 0.55 | |
| + BRD Soul Voice | 2357 | 1.38 | |
| + BRD Marcato + COR | 2760 | 1.62 | |
| + BRD Marcato + GEO | 3323 | 1.95 | |
| + BRD Soul Voice + COR | 3912 | 2.30 | |
| + **BRD + COR + GEO** | **~5181** | **3.04** | |

### WAR (base: 2563 Attack)

| Situation | Attack | Ratio (vs 1704) | Cappé? |
|-----------|--------|-----------------|--------|
| Base | 2563 | 1.50 | |
| + BRD Marcato | 3389 | 1.99 | |
| + BRD Soul Voice | 3979 | 2.33 | |
| + BRD Marcato + COR | 5287 | 3.10 | |
| + BRD Marcato + GEO | 5490 | 3.22 | |
| + **BRD + COR + GEO** | **~8565** | **5.03** | OVERKILL |

---

## Règle simplifiée pour GearSwap

### Par nombre de sources

| Sources de buff | Recommandation |
|-----------------|----------------|
| 0 (Solo) | Attack focus |
| 1 (BRD seul) | Attack focus |
| 2 (BRD + COR ou BRD + GEO) | Attack focus |
| **3 (BRD + COR + GEO)** | **PDL focus** |

### Exception

- BRD Soul Voice + COR peut capper sur jobs haute Attack
- Mais Soul Voice = 2hr, donc rare

---

## Implémentation GearSwap

### Détection des buffs

```lua
-- Détectable via buffactive
local has_brd = buffactive['Minuet'] or buffactive['March']
local has_cor = buffactive['Chaos Roll']
local has_geo = buffactive['Attack Boost']  -- Fury donne ce buff

-- NON détectable
-- Soul Voice (buff sur le BRD, pas sur nous)
-- Numéro exact du roll
-- Potency exacte des songs/bubbles
```

### Fonction de comptage des sources

```lua
local function count_buff_sources()
    local sources = 0

    -- BRD
    if buffactive['Minuet'] or buffactive['March'] then
        sources = sources + 1
    end

    -- COR
    if buffactive['Chaos Roll'] then
        sources = sources + 1
    end

    -- GEO
    if buffactive['Attack Boost'] then  -- Fury
        sources = sources + 1
    end

    return sources
end
```

### Sélection du set WS

```lua
local function select_ws_set(base_set)
    local sources = count_buff_sources()

    -- 3 sources = cappé = PDL
    if sources >= 3 then
        if sets.precast.WS[spell.english] and sets.precast.WS[spell.english].PDL then
            return sets.precast.WS[spell.english].PDL
        end
    end

    return base_set
end
```

### Structure des sets recommandée

```lua
-- Set standard (Attack focus)
sets.precast.WS["Rudra's Storm"] = {
    -- Gear avec +Attack
}

-- Set PDL (quand cappé)
sets.precast.WS["Rudra's Storm"].PDL = {
    -- Gear avec PDL:
    -- Nyame (PDL sur toutes les pièces)
    -- Gorget/Earring avec PDL
    -- etc.
}
```

---

## Notes importantes

### Facteurs qui facilitent le cap

- Debuffs Defense (Dia, Box Step, Ageha) → Réduisent Def ennemie
- Food Attack (Red Curry Bun, etc.)
- Job traits (WAR, DRK ont plus d'Attack naturel)

### Facteurs qui compliquent le cap

- Contenu difficile (Odyssey V25) → Mobs haute Defense
- Jobs support (BRD, COR, GEO) → Base Attack basse
- Absence de debuffs

### Adaptation nécessaire

Ces valeurs sont basées sur du gear BIS ou proche BIS.
Adapter les constantes selon votre propre équipement:

- Si votre BRD a moins de skill → réduire les valeurs flat
- Si votre COR/GEO a moins de skill → réduire les multiplicateurs

---

## Références

- [BG-Wiki: PDIF](https://www.bg-wiki.com/ffxi/PDIF)
- [BG-Wiki: Physical Damage Limit](https://www.bg-wiki.com/ffxi/Physical_Damage_Limit)
- [wsdist calculator](https://github.com/Kastra/wsdist_beta)

---

_Document créé le 2025-11-26_
_Données testées in-game sur serveur retail_
