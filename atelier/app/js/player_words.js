// GearSwap Atelier · player_words.js: the job's settings in a player's words (SPEC notes/docs-perso/maquette-config-2026-10-30):
// for a mode, its name, its icon, what it does in a sentence, and its values when the code names them its own way
// (Potency, SIRD). A mode without words keeps the page's other texts and waits under "More modes". '*': the modes every
// job has; a job's own entry wins.
// icon: 'gi:<name>' an icon of game-icons.net (game_icons.js), a number an item of the game (atelier/icons/<id>.bmp),
// 'value' the item the value names (a weapon: its real item), or {value: icon} one per value.
// group: the theme a mode is shown under (PLAYER_GROUPS, in their order).
// (loaded after state_help_fr.js: see atelier/src/legacy/files.ts)

// The themes the modes are ranged in, in order: [id, icon, French, English]
const PLAYER_GROUPS = [['heal', 'gi:heart-plus', 'Soins', 'Healing'], ['gear', 'gi:armor-vest', 'Équipement', 'Gear'],
  ['fight', 'gi:crossed-swords', 'Combat', 'Fighting'], ['magic', 'gi:magic-swirl', 'Magie', 'Magic'],
  ['macro', 'gi:tied-scroll', 'Sorts de tes commandes', 'Your commands’ spells'], ['auto', 'gi:gears', 'Automatismes', 'Automation'],
  ['tech', 'gi:hourglass', 'Technique', 'Technical'], ['other', 'gi:cog', 'Autres modes', 'Other modes']];

const PLAYER_WORDS = {modes: {
  '*': {
    AutoMedicine: {group: 'auto', icon: 'gi:silenced', fr: ['Soigner Silence et Paralysie avec un objet', 'Silencée ou paralysée, un objet de soin (Echo Drops, Remedy…) est utilisé tout seul juste avant ton action.'],
      en: ['Cure Silence and Paralysis with an item', 'Silenced or paralysed, a cure item (Echo Drops, Remedy…) is used by itself right before your action.']},
    CombatMode: {group: 'gear', icon: 'gi:padlock', fr: ['Garder mes armes en main', 'Tes armes ne changent plus pendant le combat : ton TP n’est jamais perdu par un changement d’équipement.'],
      en: ['Keep my weapons in hand', 'Your weapons no longer change while you fight: your TP is never lost to a gear swap.']},
    TreasureMode: {group: 'auto', icon: 'gi:open-treasure-chest', fr: ['Treasure Hunter', 'Ton équipement Treasure Hunter sur le premier coup donné à un monstre, ou tout le temps, pour plus de butin.'],
      en: ['Treasure Hunter', 'Your Treasure Hunter gear on the first hit on a monster, or all the time, for more loot.'],
      vals: {Off: ['Non', 'Off'], Tag: ['Premier coup', 'First hit'], Full: ['Tout le temps', 'All the time']}},
    JumpAuto: {group: 'auto', icon: 'gi:jump-across', fr: ['Jump avant la weaponskill (sub DRG)', 'Avec le sub Dragoon, un Jump part tout seul quand il manque du TP pour ta weaponskill.'],
      en: ['Jump before the weaponskill (DRG sub)', 'With the Dragoon subjob, a Jump goes by itself when your weaponskill lacks TP.']},
    MainWeapon: {group: 'gear', icon: 'value', fr: ['Arme principale', 'L’arme que tu portes au repos et en combat.'], en: ['Main weapon', 'The weapon you hold at rest and in a fight.'],
      vals: {Free: ['Ne pas changer', 'Leave as it is']}},
    SubWeapon: {group: 'gear', icon: 'value', fr: ['Main gauche', 'Le bouclier ou l’arme de ta main gauche.'], en: ['Off hand', 'The shield or weapon in your off hand.'],
      vals: {Free: ['Ne pas changer', 'Leave as it is']}},
    Kiting: {group: 'gear', icon: 'gi:sprint', fr: ['Courir vite même à l’arrêt', 'Tes pièces de vitesse restent sur toi même immobile : pour fuir ou promener un monstre.'],
      en: ['Run fast even standing still', 'Your speed pieces stay on even standing still: to flee or kite a monster.']},
    DefenseMode: {group: 'gear', icon: {None: 'gi:shield', Physical: 'gi:shield', Magical: 'gi:magic-shield'}, fr: ['Tout mettre en défense', 'Ton équipement de défense reste sur toi quoi que tu fasses, jusqu’à ce que tu l’enlèves.'],
      en: ['Everything on defense', 'Your defense gear stays on whatever you do, until you take it off.'],
      vals: {None: ['Non', 'No'], Physical: ['Contre les coups', 'Against hits'], Magical: ['Contre la magie', 'Against magic']}},
    FastCast: {group: 'tech', icon: 'gi:hourglass', fr: ['Fast Cast total de ton équipement', 'Le total de Fast Cast de ton équipement : GearSwap s’en sert pour savoir quand un sort aurait dû finir.'],
      en: ['Your gear’s total Fast Cast', 'The Fast Cast total of your gear: GearSwap uses it to know when a spell should have ended.']},
    HybridMode: {group: 'gear', icon: 'gi:shield-reflect', fr: ['Posture', 'La version de ton équipement au repos et en combat : PDT ou DT pour encaisser, Normal pour tes sets de base.'],
      en: ['Stance', 'The version of your gear at rest and in a fight: PDT or DT to take hits, Normal for your base sets.'],
      vals: {PDT: ['Moins de dégâts physiques', 'Less physical damage'], MDT: ['Moins de dégâts magiques', 'Less magic damage'], DT: ['Moins de dégâts', 'Less damage'], Normal: ['Sets de base', 'Base sets']}},
    IdleMode: {group: 'gear', icon: 'gi:checked-shield', fr: ['Équipement au repos', 'La version de ce que tu portes quand tu ne fais rien.'], en: ['Gear at rest', 'The version of what you wear doing nothing.']},
    OffenseMode: {group: 'fight', icon: 'gi:crossed-swords', fr: ['Équipement en combat', 'La version de ton équipement quand tu tapes. Acc : plus de précision, si tu as ce set.'],
      en: ['Gear in a fight', 'The version of your gear when you hit. Acc: more accuracy, if you have that set.'], vals: {Acc: ['Plus de précision', 'More accuracy']}},
    WeaponskillMode: {group: 'fight', icon: 'gi:sword-brandish', fr: ['Équipement des weaponskills', 'La version de tes sets de weaponskill. Acc : la version précision, si elle existe.'],
      en: ['Weaponskill gear', 'The version of your weaponskill sets. Acc: the accuracy one, if it exists.'], vals: {Acc: ['Plus de précision', 'More accuracy']}},
    RangedMode: {group: 'fight', icon: 'gi:bullseye', fr: ['Équipement du tir', 'La version de tes sets de tir à distance. Acc : plus de précision.'],
      en: ['Ranged gear', 'The version of your ranged sets. Acc: more accuracy.'], vals: {Acc: ['Plus de précision', 'More accuracy']}},
    CastingMode: {group: 'magic', icon: 'gi:on-target', fr: ['Contre un monstre qui résiste', 'Resistant : tes sorts prennent la version précision magique de leur set, si elle existe.'],
      en: ['Against a monster that resists', 'Resistant: your spells take the magic accuracy version of their set, if it exists.'], vals: {Resistant: ['Plus de précision', 'More accuracy']}},
    RangeWeapon: {group: 'gear', icon: 'value', fr: ['Arme à distance', 'Ton arme à distance, équipée dès que tu la changes.'], en: ['Ranged weapon', 'Your ranged weapon, equipped as soon as you change it.']},
    SneakInviAOE: {group: 'macro', icon: 'gi:invisible', fr: ['Sneak / Invisible sur tout le groupe', 'Pour ta commande aoe sneak / aoe invi : allumé, Accession puis le sort sur tout le groupe ; éteint, une seule cible.'],
      en: ['Sneak / Invisible on the whole party', 'For your aoe sneak / aoe invi command: on, Accession then the spell on the whole party; off, one target.']},
    RuneMode: {group: 'macro', icon: 'gi:rune-stone', fr: ['Rune de ta commande', 'La rune que lance ta commande rune.'], en: ['Your command’s rune', 'The rune your rune command uses.']},
  },
  WHM: {
    IdleMode: {group: 'gear', icon: {PDT: 'gi:checked-shield', Refresh: 'gi:magic-potion'}, fr: ['Équipement au repos', 'Ce que tu portes quand tu ne fais rien : de quoi encaisser les coups, ou de quoi récupérer ton MP.'],
      en: ['Gear at rest', 'What you wear doing nothing: gear to take hits, or gear that brings your MP back.'],
      vals: {PDT: ['Défense', 'Defense'], Refresh: ['Récupérer le MP', 'Recover MP']}},
    CureMode: {group: 'heal', icon: {Potency: 'gi:heart-plus', SIRD: 'gi:meditation'}, fr: ['Équipement pour les Cure', 'Le Cure le plus fort possible, ou un équipement qui t’évite d’être interrompue quand un monstre te tape.'],
      en: ['Gear for Cures', 'The strongest Cure possible, or gear that keeps you from being interrupted when a monster hits you.'],
      vals: {Potency: ['Soin le plus fort', 'Strongest heal'], SIRD: ['Ne pas être interrompue', 'Not interrupted']}},
    CureAutoTier: {group: 'heal', icon: 'gi:heart-bottle', fr: ['Choisir le Cure selon les HP manquants', 'Ta macro Cure lance le Cure juste assez fort pour les HP qui manquent à la cible : pas de MP gaspillé.'],
      en: ['Pick the Cure by the HP missing', 'Your Cure macro casts the Cure just strong enough for the HP the target misses: no MP wasted.']},
    AfflatusMode: {group: 'heal', icon: {Solace: 'gi:angel-wings', Misery: 'gi:sunbeams'}, fr: ['Afflatus lancé par ta macro', 'L’Afflatus que lance ta macro : Solace pour mieux soigner, Misery pour taper plus fort.'],
      en: ['Afflatus your macro casts', 'The Afflatus your macro casts: Solace to heal better, Misery to hit harder.'],
      vals: {Solace: ['Solace (soigner)', 'Solace (heal)'], Misery: ['Misery (taper)', 'Misery (hit)']}},
    CastingMode: {group: 'fight', icon: 'gi:on-target', fr: ['Contre un monstre qui résiste', 'Si un monstre résiste à tes sorts, ton équipement passe sur la précision magique.'],
      en: ['Against a monster that resists', 'If a monster resists your spells, your gear goes for magic accuracy.'],
      vals: {Normal: ['Normal', 'Normal'], Resistant: ['Plus de précision', 'More accuracy']}},
    OffenseMode: {group: 'fight', icon: 'gi:crossed-swords', fr: ['Se battre au corps à corps', 'Oui : tes armes restent en main pour taper toi aussi.'], en: ['Fight in melee', 'Yes: your weapons stay in hand to hit too.'],
      vals: {None: ['Non', 'No'], 'Melee ON': ['Oui', 'Yes']}},
  },
  PLD: {
    HybridMode: {group: 'gear', icon: 'gi:shield-reflect', fr: ['Posture de tank', 'Ta posture de tank : PDT contre les coups, MDT contre la magie ; en /SCH et /RUN : DPS, Tanking ou Hoxne.'],
      en: ['Tank stance', 'Your tank stance: PDT against hits, MDT against magic; in /SCH and /RUN: DPS, Tanking or Hoxne.'],
      vals: {PDT: ['Contre les coups', 'Against hits'], MDT: ['Contre la magie', 'Against magic']}},
    PhalanxSIRD: {group: 'magic', icon: 'gi:meditation', fr: ['Phalanx sans interruption', 'Allumé : Phalanx prend toujours ton set anti-interruption au lieu de ton set de puissance.'],
      en: ['Phalanx without interruption', 'On: Phalanx always takes your anti-interruption set instead of your potency set.']},
    Xp: {group: 'gear', icon: 'gi:upgrade', fr: ['Équipement XP', 'Allumé : ton équipement d’XP se pose par-dessus le reste, et Phalanx prend le set anti-interruption.'],
      en: ['XP gear', 'On: your XP gear goes over the rest, and Phalanx takes the anti-interruption set.']},
  },
  COR: {
    MainRoll: {group: 'macro', icon: 'gi:rolling-dices', fr: ['Premier roll', 'Le roll que lance ta commande roll1.'], en: ['First roll', 'The roll your roll1 command casts.']},
    SubRoll: {group: 'macro', icon: 'gi:dice-six-faces-six', fr: ['Deuxième roll', 'Le roll que lance ta commande roll2.'], en: ['Second roll', 'The roll your roll2 command casts.']},
    QuickDraw: {group: 'macro', icon: 'gi:revolver', fr: ['Élément du Quick Draw', 'L’élément que tire ta commande shot.'], en: ['Quick Draw element', 'The element your shot command fires.']},
    LuzafRing: {group: 'gear', icon: 'gi:ring', fr: ['Luzaf’s Ring sur les rolls', 'ON : Luzaf’s Ring est porté sur un roll (portée 16 yalms). OFF : un autre anneau, portée 8 yalms.'],
      en: ['Luzaf’s Ring on rolls', 'ON: Luzaf’s Ring is worn on a roll (16 yalms reach). OFF: another ring, 8 yalms reach.']},
    HybridMode: {group: 'gear', icon: 'gi:shield-reflect', fr: ['Posture', 'PDT : ton équipement de défense en combat et au repos hors ville.'], en: ['Stance', 'PDT: your defense gear in a fight and at rest out of town.'],
      vals: {PDT: ['Défense', 'Defense'], Normal: ['Sets de base', 'Base sets']}},
  },
  GEO: {
    MainIndi: {group: 'macro', icon: 'gi:crystal-ball', fr: ['Indi de ta commande', 'Le sort que lancent tes commandes indi et entrust.'], en: ['Your command’s Indi', 'The spell your indi and entrust commands cast.']},
    MainGeo: {group: 'macro', icon: 'gi:orb-wand', fr: ['Geo de ta commande', 'Le sort que lance ta commande geo.'], en: ['Your command’s Geo', 'The spell your geo command casts.']},
    MainLightSpell: {group: 'macro', icon: 'gi:sun', fr: ['Nuke clair', 'L’élément de ta commande lightspell.'], en: ['Light nuke', 'The element of your lightspell command.']},
    MainDarkSpell: {group: 'macro', icon: 'gi:moon', fr: ['Nuke sombre', 'L’élément de ta commande darkspell.'], en: ['Dark nuke', 'The element of your darkspell command.']},
    SpellTier: {group: 'macro', icon: 'gi:stairs-goal', fr: ['Tier des nukes', 'Le tier des nukes sur une cible (I = le sort de base).'], en: ['Nuke tier', 'The tier of single-target nukes (I = the base spell).']},
    MainLightAOE: {group: 'macro', icon: 'gi:sun', fr: ['Nuke -ra clair', 'Le sort de ta commande lightaoe.'], en: ['Light -ra nuke', 'The spell of your lightaoe command.']},
    MainDarkAOE: {group: 'macro', icon: 'gi:moon', fr: ['Nuke -ra sombre', 'Le sort de ta commande darkaoe.'], en: ['Dark -ra nuke', 'The spell of your darkaoe command.']},
    AOETier: {group: 'macro', icon: 'gi:stairs-goal', fr: ['Tier des nukes -ra', 'Le tier des nukes de zone.'], en: ['-ra nuke tier', 'The tier of area nukes.']},
    HybridMode: {group: 'gear', icon: 'gi:shield-reflect', fr: ['Équipement sans luopan', 'La base de ton équipement au repos et en combat quand aucun luopan n’est posé.'],
      en: ['Gear without a luopan', 'The base of your gear at rest and in a fight when no luopan is out.'], vals: {PDT: ['Défense', 'Defense'], Normal: ['Sets de base', 'Base sets']}},
    LuopanMode: {group: 'gear', icon: 'gi:magic-portal', fr: ['Équipement avec luopan', 'Ton équipement en combat quand un luopan est posé : DT pour le protéger, DPS pour taper.'],
      en: ['Gear with a luopan', 'Your gear in a fight when a luopan is out: DT to protect it, DPS to hit.'], vals: {DT: ['Défense', 'Defense'], DPS: ['Dégâts', 'Damage']}},
    IndicolureMode: {group: 'tech', icon: 'gi:crystal-ball', fr: ['Indicolure (affichage)', 'Affiché dans le HUD seulement : rien ne le lit aujourd’hui.'], en: ['Indicolure (display)', 'Shown in the HUD only: nothing reads it today.']},
  },
  RDM: {
    EngagedMode: {group: 'fight', icon: 'gi:crossed-swords', fr: ['Équipement en combat', 'Ton équipement quand tu tapes : DT pour encaisser, Acc pour la précision, TP pour le TP, Enspell pour les dégâts d’Enspell.'],
      en: ['Gear in a fight', 'Your gear when you hit: DT to take hits, Acc for accuracy, TP for TP, Enspell for Enspell damage.'],
      vals: {DT: ['Défense', 'Defense'], Acc: ['Précision', 'Accuracy'], TP: ['Faire du TP', 'Build TP'], Enspell: ['Dégâts d’Enspell', 'Enspell damage']}},
    IdleMode: {group: 'gear', icon: {Refresh: 'gi:magic-potion', DT: 'gi:checked-shield'}, fr: ['Équipement au repos', 'Ce que tu portes quand tu ne fais rien : de quoi récupérer ton MP, ou de quoi encaisser.'],
      en: ['Gear at rest', 'What you wear doing nothing: gear that brings your MP back, or gear to take hits.'], vals: {Refresh: ['Récupérer le MP', 'Recover MP'], DT: ['Défense', 'Defense']}},
    CureAutoTier: {group: 'heal', icon: 'gi:heart-bottle', fr: ['Choisir le Cure selon les HP manquants', 'Ta macro Cure lance le Cure juste assez fort pour les HP qui manquent à la cible.'],
      en: ['Pick the Cure by the HP missing', 'Your Cure macro casts the Cure just strong enough for the HP the target misses.']},
    EnfeebleMode: {group: 'magic', icon: 'gi:poison-bottle', fr: ['Équipement des affaiblissements', 'Auto : chaque affaiblissement prend le set de son type. Potency, Skill ou Duration : ce set pour tous.'],
      en: ['Enfeebling gear', 'Auto: each enfeeble takes the set of its kind. Potency, Skill or Duration: that set for all.'],
      vals: {Auto: ['Selon le sort', 'By the spell'], Potency: ['Puissance', 'Potency'], Skill: ['Skill', 'Skill'], Duration: ['Durée', 'Duration']}},
    EnfeebleTier: {group: 'magic', icon: 'gi:stairs-goal', fr: ['Descendre de tier si en recast', 'Allumé : un affaiblissement en recast ou sans MP descend au tier inférieur. Éteint : il est annulé.'],
      en: ['Step down a tier on recast', 'On: an enfeeble on recast or without MP steps down a tier. Off: it is cancelled.']},
    NukeMode: {group: 'magic', icon: 'gi:lightning-helix', fr: ['Équipement des nukes', 'Ton set de nuke normal, ou sa version Magic Burst.'], en: ['Nuke gear', 'Your normal nuke set, or its Magic Burst version.'],
      vals: {FreeNuke: ['Nuke normal', 'Normal nuke']}},
    SaboteurMode: {group: 'magic', icon: 'gi:magic-palm', fr: ['Saboteur automatique', 'Allumé : les sorts listés dans tes réglages Saboteur lancent Saboteur d’abord quand il est prêt.'],
      en: ['Automatic Saboteur', 'On: the spells listed in your Saboteur settings cast Saboteur first when it is ready.']},
    NukeTier: {group: 'macro', icon: 'gi:stairs-goal', fr: ['Tier des nukes', 'Le tier de tes commandes de nuke (I = le sort de base).'], en: ['Nuke tier', 'The tier of your nuke commands (I = the base spell).']},
    EnSpell: {group: 'macro', icon: 'gi:fire-ray', fr: ['Enspell de ta commande', 'Le sort de tes commandes castenspell et buff.'], en: ['Your command’s Enspell', 'The spell of your castenspell and buff commands.']},
    GainSpell: {group: 'macro', icon: 'gi:muscle-up', fr: ['Gain de ta commande', 'Le sort de tes commandes castgain et buff.'], en: ['Your command’s Gain', 'The spell of your castgain and buff commands.']},
    Barspell: {group: 'macro', icon: 'gi:magic-shield', fr: ['Bar-élément de ta commande', 'Le sort de ta commande castbar.'], en: ['Your command’s Bar-element', 'The spell of your castbar command.']},
    BarAilment: {group: 'macro', icon: 'gi:poison-bottle', fr: ['Bar-statut de ta commande', 'Le sort de ta commande castbarailment.'], en: ['Your command’s Bar-ailment', 'The spell of your castbarailment command.']},
    Spike: {group: 'macro', icon: 'gi:spiked-shell', fr: ['Spikes de ta commande', 'Le sort de ta commande castspike.'], en: ['Your command’s Spikes', 'The spell of your castspike command.']},
    Storm: {group: 'macro', icon: 'gi:tornado', fr: ['Tempête de ta commande', 'Le sort de ta commande caststorm (en /SCH seulement).'], en: ['Your command’s storm', 'The spell of your caststorm command (/SCH only).']},
    MainLightSpell: {group: 'macro', icon: 'gi:sun', fr: ['Nuke clair', 'L’élément de ta commande castlight.'], en: ['Light nuke', 'The element of your castlight command.']},
    SubLightSpell: {group: 'macro', icon: 'gi:sun', fr: ['Nuke clair 2', 'L’élément de ta commande castsublight.'], en: ['Light nuke 2', 'The element of your castsublight command.']},
    MainDarkSpell: {group: 'macro', icon: 'gi:moon', fr: ['Nuke sombre', 'L’élément de ta commande castdark.'], en: ['Dark nuke', 'The element of your castdark command.']},
    SubDarkSpell: {group: 'macro', icon: 'gi:moon', fr: ['Nuke sombre 2', 'L’élément de ta commande castsubdark.'], en: ['Dark nuke 2', 'The element of your castsubdark command.']},
  },
}};

// The words of a mode for the job shown: {name, desc, icon, vals: {value: label}} or null
function playerMode(name, job){
  const w = (PLAYER_WORDS.modes[job] || {})[name] || PLAYER_WORDS.modes['*'][name];
  if (!w) return null;
  const l = S.lang === 'en' ? 1 : 0, vals = {};
  for (const [v, labels] of Object.entries(w.vals || {})) vals[v] = labels[l];
  return {name: (l ? w.en : w.fr)[0], desc: (l ? w.en : w.fr)[1], icon: w.icon, vals, group: w.group || 'tech'};
}
// An icon of the options screen: 'gi:<name>' one of game-icons.net (game_icons.js, drawn in the page's gold), a number
// an item of the game (atelier/icons, written by the export: the weapons); an empty frame without one
function playerIcon(id){
  const s = id == null ? '' : String(id), gi = s.startsWith('gi:') && GAME_ICONS.icons[s.slice(3)];
  const inner = gi ? `<svg class="gi" viewBox="0 0 ${GAME_ICONS.size} ${GAME_ICONS.size}">${gi}</svg>`
    : /^\d+$/.test(s) ? itemImg(s) : '';
  return `<span class="ico${gi ? ' gico' : ''}" aria-hidden="true">${inner}</span>`;
}
