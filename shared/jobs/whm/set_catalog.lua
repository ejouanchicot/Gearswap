---============================================================================
--- Set Catalog (WHM) - the set names the White Mage code reads
---============================================================================
--- What WHM's own code reads on top of shared/utils/atelier/set_catalog_common.lua
--- (format: shared/utils/atelier/set_catalog.lua). The cures are dressed by
--- shared/jobs/whm/functions/WHM_MIDCAST.lua job_midcast (CureMode, Afflatus
--- Solace, CureMelee), the buff layers by its job_post_midcast. The ability
--- lines repeat common paths to say which piece gives the ability its effect
--- and when it must be worn (BG Wiki pages of each ability, read 2026-10-29).
---
--- @file    shared/jobs/whm/set_catalog.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-29
---============================================================================

return {
    ---------------------------------------------------------------- cures (WHM_MIDCAST.lua job_midcast)
    -- job_get_spell_map: a Cure under Afflatus Solace maps to CureSolace; CureMode Potency wears it
    {'midcast.CureSolace', when = 'A Cure (not a Curaga) while Afflatus Solace is up, Cure Mode Potency. Key pieces: Ebers Bliaut, Alaunus\'s Cape (Stoneskin from the Cure)', fr = 'Quand tu lances une Cure (pas une Curaga) sous Afflatus Solace, avec le Cure Mode sur Potency. Pièces qui comptent : Ebers Bliaut et Alaunus’s Cape (Stoneskin en plus de la Cure).',
        base = 'midcast.Cure',
        key = {{slot = 'body', names = {'Ebers Bliaut', 'Orison Bliaut +2', 'Orison Bliaut +1'}, en = 'up to 18 % of the Cure as Stoneskin', fr = 'jusqu’à 18 % de la Cure en Stoneskin'},
               {slot = 'back', names = {"Alaunus's Cape"}, en = '10 % of the Cure as Stoneskin', fr = '10 % de la Cure en Stoneskin'}}},
    {'midcast.CureSIRD', when = 'A Cure, Cure Mode SIRD (spell interruption down), with or without Afflatus Solace', fr = 'Quand tu lances une Cure avec le Cure Mode sur SIRD (moins d’interruptions), sous Afflatus Solace ou non.',
        base = 'midcast.Cure', needs = {'state:CureMode'}},
    {'midcast.CuragaSIRD', when = 'A Curaga, Cure Mode SIRD (spell interruption down)', fr = 'Quand tu lances une Curaga avec le Cure Mode sur SIRD (moins d’interruptions).',
        base = 'midcast.Curaga', needs = {'state:CureMode'}},
    -- job_get_spell_map: engaged, and only once the set holds gear
    {'midcast.CureMelee', when = 'A Cure or Curaga while you fight, once this set holds gear (empty: the normal cure sets)', fr = 'Quand tu lances une Cure ou une Curaga en combat, dès que ce set contient des pièces (vide : tes sets de Cure habituels).',
        base = 'midcast.Cure'},
    -- job_post_midcast -> shared/utils/whm/cure_manager.lua lay_mp_conservation (WHM_CURE_CONFIG mp_conservation_below)
    {'midcast.CureMPConservation', when = 'A Cure or Curaga (not while fighting) with your MP under mp_conservation_below of WHM_CURE_CONFIG.lua: on top of the cure set. E.g. a cheaper Cure weapon',
        fr = 'Quand tu lances une Cure ou une Curaga (hors combat) avec ton MP sous le seuil de WHM_CURE_CONFIG.lua (40 %) : mis par-dessus ton set de Cure. Par exemple une arme qui coûte moins de MP.'},

    ---------------------------------------------------------------- the versions an ability gives a spell (WHM_MIDCAST.lua version_of: by the spell, then its group)
    {'midcast.CureSIRD.Solace', when = 'A Cure (not a Curaga) under Afflatus Solace, Cure Mode SIRD. Key pieces: Ebers Bliaut, Alaunus\'s Cape (Stoneskin from the Cure)', fr = 'Quand tu lances une Cure (pas une Curaga) sous Afflatus Solace avec le Cure Mode sur SIRD. Pièces qui comptent : Ebers Bliaut et Alaunus’s Cape (Stoneskin en plus de la Cure).',
        base = 'midcast.CureSIRD', needs = {'state:CureMode'},
        key = {{slot = 'body', names = {'Ebers Bliaut', 'Orison Bliaut +2', 'Orison Bliaut +1'}, en = 'up to 18 % of the Cure as Stoneskin', fr = 'jusqu’à 18 % de la Cure en Stoneskin'},
               {slot = 'back', names = {"Alaunus's Cape"}, en = '10 % of the Cure as Stoneskin', fr = '10 % de la Cure en Stoneskin'}}},
    {'midcast.BarElement.Solace', when = 'An element Bar-spell (Barfire...) under Afflatus Solace. Key pieces: Ebers Bliaut, Alaunus\'s Cape (more MDB)', fr = 'Quand tu lances un barspell d’élément (Barfire…) sous Afflatus Solace. Pièces qui comptent : Ebers Bliaut et Alaunus’s Cape (plus de défense magique).',
        base = 'midcast.BarElement',
        key = {{slot = 'body', names = {'Ebers Bliaut', 'Orison Bliaut +2', 'Orison Bliaut +1'}, en = 'up to +18 MDB', fr = 'jusqu’à +18 de défense magique'},
               {slot = 'back', names = {"Alaunus's Cape"}, en = '+10 MDB', fr = '+10 de défense magique'}}},
    {'midcast.StatusRemoval.Caress', when = 'A -na spell (Paralyna, Silena...; not Erase, Esuna nor Sacrifice) under Divine Caress. Key pieces: Ebers Mitts, Mending Cape (more resistances), worn during the -na', fr = 'Quand tu lances un sort en -na (Paralyna, Silena… ; pas Erase, Esuna ni Sacrifice) sous Divine Caress. Pièces qui comptent : Ebers Mitts et Mending Cape (plus de résistances), pendant le -na.',
        base = 'midcast.StatusRemoval',
        key = {{slot = 'hands', names = {'Ebers Mitts', 'Orison Mitts +2', 'Orison Mitts +1'}, en = 'up to +5 resistances', fr = 'jusqu’à 5 résistances en plus'},
               {slot = 'back', names = {'Mending Cape'}, en = '+1 resistance', fr = '1 résistance en plus'}}},
    {'midcast.Banish.Misery', when = 'Banish, Banishga under Afflatus Misery. Key piece: Piety Pantaloons (Magic Attack Bonus per Animus Misery merit, value not known)', fr = 'Quand tu lances Banish ou Banishga sous Afflatus Misery. Pièce qui compte : Piety Pantaloons (bonus de dégâts selon le merit Animus Misery ; valeur inconnue).',
        base = 'midcast.Banish',
        key = {{slot = 'legs', names = {'Piety Pantaloons'}, en = 'Magic Attack Bonus on the Banish family', fr = 'bonus de dégâts sur les Banish'}}},

    ---------------------------------------------------------------- spells routed by WHM_MIDCAST.lua job_post_midcast
    {'midcast.StatusRemoval', when = 'A status removal spell (Paralyna, Cursna, Erase...)', fr = 'Quand tu lances un sort qui retire un statut (Paralyna, Cursna, Erase…).', base = 'midcast.Healing Magic'},
    -- job_get_spell_map: White Magic enfeebles -> MndEnfeebles, Black Magic ones -> IntEnfeebles
    {'midcast.MndEnfeebles', when = 'A White Magic enfeeble (Slow, Paralyze, Silence...)', fr = 'Quand tu lances un affaiblissement de magie blanche (Slow, Paralyze, Silence…).', base = 'midcast.Enfeebling Magic'},
    {'midcast.IntEnfeebles', when = 'A Black Magic enfeeble (Blind, Poison...)', fr = 'Quand tu lances un affaiblissement de magie noire (Blind, Poison…).', base = 'midcast.Enfeebling Magic'},
    -- midcast_enfeebling / Divine Magic: mode_state = CastingMode
    {'midcast.MndEnfeebles.{CastingMode~Normal}', when = 'A White Magic enfeeble with that Casting Mode', fr = 'Quand tu lances un affaiblissement de magie blanche avec ce Casting Mode.', base = 'midcast.MndEnfeebles'},
    {'midcast.IntEnfeebles.{CastingMode~Normal}', when = 'A Black Magic enfeeble with that Casting Mode', fr = 'Quand tu lances un affaiblissement de magie noire avec ce Casting Mode.', base = 'midcast.IntEnfeebles'},
    {'midcast.Divine Magic.{CastingMode~Normal}', when = 'A Divine spell (Banish, Flash...) with that Casting Mode', fr = 'Quand tu lances un sort divin (Banish, Flash…) avec ce Casting Mode.', base = 'midcast.Divine Magic'},
    {'midcast.Holy', when = 'Holy. Key piece under Afflatus Solace: Piety Duckbills (more damage)', fr = 'Quand tu lances Holy. Pièce qui compte sous Afflatus Solace : Piety Duckbills (plus de dégâts).',
        base = 'midcast.Divine Magic', key = {{slot = 'feet', names = {'Piety Duckbills', 'Clr. Duckbills +2'}, en = 'more damage under Afflatus Solace', fr = 'plus de dégâts sous Afflatus Solace'}}},
    {'midcast.Holy II', when = 'Holy II. Key piece under Afflatus Solace: Piety Duckbills (more damage)', fr = 'Quand tu lances Holy II. Pièce qui compte sous Afflatus Solace : Piety Duckbills (plus de dégâts).',
        base = 'midcast.Divine Magic', key = {{slot = 'feet', names = {'Piety Duckbills', 'Clr. Duckbills +2'}, en = 'more damage under Afflatus Solace', fr = 'plus de dégâts sous Afflatus Solace'}}},

    ---------------------------------------------------------------- idle (logic/set_builder.lua build_idle_set)
    {'latent_refresh', when = 'Idle with your MP under refresh_mp_below of WHM_CONFIG.lua (51 %): on top of the idle set', fr = 'Quand tu ne combats pas avec ton MP sous le seuil de WHM_CONFIG.lua (51 %) : mis par-dessus ton set idle.'},

    ---------------------------------------------------------------- abilities: the piece that gives each its effect (Mote precast)
    {'precast.JA.Benediction', when = 'Using Benediction. Key piece: Piety Bliaut, worn at the ability (Enmity -50 on it)', fr = 'Quand tu utilises Benediction. Pièce qui compte : Piety Bliaut, portée au lancement (Enmity −50 sur la JA).',
        key = {{slot = 'body', names = {'Piety Bliaut', 'Clr. Bliaut +2'}, en = 'Enmity -50 on Benediction', fr = 'Enmity −50 sur Benediction'}}},
    {'precast.JA.Martyr', when = 'Using Martyr. Key piece: Piety Mitts, worn at the ability (heals up to 75 % of your HP instead of 50 %). It counts your CURRENT HP: HP gear put on at the ability does not raise them, be at full HP before', fr = 'Quand tu utilises Martyr. Pièce qui compte : Piety Mitts, portées au lancement (soigne jusqu’à 75 % de tes HP au lieu de 50 %). Martyr compte tes HP actuels : des pièces HP mises au lancement ne les augmentent pas, sois au plein avant.',
        key = {{slot = 'hands', names = {'Piety Mitts', 'Clr. Mitts +2'}, en = 'heals up to 75 % of your HP instead of 50 %', fr = 'soigne jusqu’à 75 % de tes HP au lieu de 50 %'}}},
    -- the stances: no piece acts when they are used, their pieces go in the buff sets above
    {'precast.JA.Afflatus Solace', when = 'Using Afflatus Solace: no piece acts when the stance is used (its pieces go in the sets of the spells it changes: CureSolace, CureSIRD.Solace, BarElement.Solace)', fr = 'Quand tu utilises Afflatus Solace : aucune pièce n’agit au lancement (ses pièces vont dans les sets des sorts qu’elle change : CureSolace, CureSIRD.Solace, BarElement.Solace).'},
    {'precast.JA.Afflatus Misery', when = 'Using Afflatus Misery: no piece acts when the stance is used (Piety Pantaloons goes in sets.midcast.Banish.Misery)', fr = 'Quand tu utilises Afflatus Misery : aucune pièce n’agit au lancement (Piety Pantaloons va dans le set Banish.Misery).'},
    {'precast.JA.Devotion', when = 'Using Devotion. Key piece: Piety Cap, worn at the ability (up to 42.5 % of your HP as MP instead of 30 %). It counts your CURRENT HP: HP gear put on at the ability does not raise them, be at full HP before', fr = 'Quand tu utilises Devotion. Pièce qui compte : Piety Cap, portée au lancement (rend jusqu’à 42,5 % de tes HP en MP au lieu de 30 %). Devotion compte tes HP actuels : des pièces HP mises au lancement ne les augmentent pas, sois au plein avant.',
        key = {{slot = 'head', names = {'Piety Cap', 'Clr. Cap +2'}, en = 'up to 42.5 % of your HP as MP instead of 30 %', fr = 'rend jusqu’à 42,5 % de tes HP en MP au lieu de 30 %'}}},
}
