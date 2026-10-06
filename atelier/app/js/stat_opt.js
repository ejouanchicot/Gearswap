// GearSwap Atelier · stat_opt.js: the optimizer for the sets judged by their stats (idle, Enmity, Phalanx, Fast Cast,
// Cure, Refresh...), the PLD / RUN tank sets first. No damage engine: the page reads each piece's stats (stats.js
// pieceStats) and the search (atelier/opt.js, its "stats" mode: O.statFigures) adds them up. The figures follow the
// Paladin guide's solvers (Guide_Paladin tools/solver_common.py, solve_idle / solve_enmity / solve_phalanx / solve_fc):
// objectives in order (the first, then the next ones to part sets as good on it), and floors (DT+PDT, DT+MDT, HP between
// two values, SIRD, Fast Cast, enemy critical hit rate)
// (loaded by atelier/index.html after opt_page.js: see the list there)

Object.assign(T.fr, {
  statObj_def: 'DEF', statObj_hp: 'HP', statObj_enmity: 'Enmity', statObj_phalanx: 'Phalanx', statObj_fc: 'Fast Cast', statObj_sird: 'SIRD',
  statObj_meva: 'Évasion magique', statObj_mdb: 'Bonus déf. magique', statObj_pdtRed: 'Dégâts physiques reçus', statObj_mdtRed: 'Dégâts magiques reçus',
  statObj_ecritRed: 'Critiques ennemis', statObj_cure: 'Cure potency', statObj_refresh: 'Refresh', statObj_regen: 'Regen',
  statObj_cureEnm: 'Inimitié du Cure', statD_cureEnm: 'HP soignés × (1 + Enmity) : CE = soin × 0,231, VE = 6 × CE (guide Paladin) ; le soin et l’Enmity se départagent seuls',
  statObj_cureSelf: 'Cure IV sur toi', statD_cureSelf: 'HP vraiment soignés : la puissance du Cure (MND, VIT, skill, Cure Potency) dans l’écart de HP ouvert par le Fast Cast',
  statCure4: 'Puissance du Cure IV', statCure4Tip: 'Ce que ton Cure IV soignerait sans limite (BG Wiki, Cure Formula ; en PLD Majesty toujours compté, +25 de Cure Potency II ; +50 du gift PLD Cure Potency Bonus dès 1200 JP, vérifié en jeu : Cure IV 1332, 1245, 1114), le jour et la météo à part.',
  statObj_enhdur: 'Durée renfort', statD_enhdur: 'Enhancing magic duration : Protect, Shell, Reprisal… durent plus longtemps',
  statObj_enhSkill: 'Skill de renfort', statD_enhSkill: 'le tien + le gear : Phalanx, Stoneskin, Barspells… en dépendent',
  statObj_divSkill: 'Skill divin', statD_divSkill: 'le tien + le gear : Enlight II, Flash (Cécité), Banish, Holy',
  statObj_ceLoss: 'Perte d’inimitié réduite', statD_ceLoss: 'quand tu prends un coup : Enmity (1 % pour +2, 50 % à +100) × pièces « perte réduite » (Burtgang 20, Chev. Cuisses +3 14, 50 % au plus), 75 % en tout',
  statObj_blockGear: 'Blocage (gear)', statD_blockGear: 'skill de bouclier × 0,2325 + chance de blocage des pièces, en plus de la base du bouclier',
  statObj_statusRes: 'Résistance aux statuts', statD_statusRes: '« résistance à tous les statuts » des pièces',
  statObj_eleCover: 'Éléments couverts', statD_eleCover: 'éléments à résistance positive (sur 8) : la condition pour résister à 1/8 avec l’évasion magique (guide Paladin)',
  statObj_eleRes: 'Résistances élémentaires', statD_eleRes: 'moyenne des 8 éléments',
  statObj_stoneskin: 'Stoneskin', statD_stoneskin: 'HP absorbés : skill de renfort et MND (350 au plus), + le gear Stoneskin (475 au plus)',
  statObj_enlight: 'Enlight II', statD_enlight: 'Précision et dégâts du premier coup : skill divin, Brilliance +15 / Honorbound +7 en main',
  statObj_hpLow: 'HP les plus bas', statD_hpLow: 'Fast Cast d’un Cure sur toi : HP bas, le set de Cure les remonte et le Cure remplit l’écart',
  statKeepOwn: 'Garder la pièce de la JA ({p})', statKeepOwnTip: 'Les pièces dont la description nomme {b} restent : la recherche choisit le reste.',
  statRef: 'HP vs Fast Cast', statRefTip: 'HP du set moins ceux du Fast Cast {f} ({h} HP), le set classique le plus bas en HP, porté avant chaque sort : '
    + 'les autres sets visent entre lui et lui + 200 pour qu’un changement de set ne fasse pas perdre de HP (guide Paladin, HP Management : écart de 200 au plus).',
  statRefLine: 'HP de référence : {h} (Fast Cast {f}) · les sets tank visent {a} à {b}.',
  cyTitle: 'Cycle des HP', cyNote: 'HP max de chaque set, repos {n} ({i}) → precast → midcast → repos. Passer à un set plus bas fait tomber tes HP, '
    + 'revenir ne les rend pas : la perte, c’est ce qui manque en revenant au repos (avant tout soin). Le guide vise 200 d’écart au plus. Tes pièces à l’essai comptent.',
  cyIdleHigh: 'Ton repos est {n} au-dessus : chaque sort te coûte cette différence.', cyAct: 'Action', cyPre: 'Precast', cyMid: 'Midcast', cyLoss: 'Perte', cyOnPurpose: 'voulu', cyJa: 'JA',
  statAct: 'Inimitié de {a}', statActTip: '{a} : {ve} VE et {ce} CE de base, × (1 + Enmity / 100), Enmity du gear + Crusade + Sentinel plafonnée à +200 (guide Paladin, Enmity Generation).',
  protOther: 'Lancé par un autre', protOtherTip: 'Protect lancé par un WHM, RDM, SCH… : sans la DEF de ton bouclier (Shield Barrier ne compte que sur ton propre Protect).',
  statGap: 'HP gagnés au midcast', statGapTip: 'HP du set {m} moins ceux du Fast Cast {f} : ce qui manque au moment du Cure, donc ce qu’il peut soigner en entier (guide Paladin, CURE SELF).',
  statD_def: 'VIT × 1,5 + DEF du gear (+ bouclier sous Protect en PLD)', statD_hp: 'HP avec les HP %', statD_enmity: 'jusqu’au plafond +200, buffs compris',
  statD_phalanx: 'palier du skill de renfort + Phalanx reçu', statD_fc: 'jusqu’à 80 %', statD_sird: 'jusqu’à 102 %',
  statD_meva: 'résister aux sorts', statD_mdb: 'divise les dégâts magiques', statD_pdtRed: 'DT+PDT plafonnés à −50 %, puis PDT II',
  statD_mdtRed: 'DT+MDT (+ Shell) plafonnés, puis MDT II', statD_ecritRed: 'réduction du gear, comptée jusqu’au plancher : 10 % → 1 %, soit −9 avec tes mérites',
  statD_cure: 'jusqu’à 50 %', statD_refresh: 'MP par tick', statD_regen: 'HP par tick',
  statAssumed: 'Toujours comptés, comme dans le guide : Crusade (Enmity +30){m}.', statAssumedMaj: ', Majesty (Cure Potency II +25)',
  ownWeapon: 'arme du set (portée le temps de l’action)',
  statWeaponsNote: 'Armes libres : l’arme et le bouclier trouvés vont dans ce set, portés le temps de l’action (en idle, tes modes les remettent). Changer l’arme principale fait perdre le TP, le bouclier non.',
  statGrp_def: 'Défense', statGrp_enm: 'Inimitié', statGrp_cure: 'Soin', statGrp_magic: 'Magie', statGrp_regen: 'Récupération',
  statAll: 'Tous les objectifs (+{n})', statFewer: 'Seulement ceux de ce set',
  statKept: 'Objectifs ou planchers changés à la main sur ce set.', statReset: 'Réglages par défaut',
  subWarn: 'En jeu tu es {g}, la page montre {p} : stats de base, traits et sets sont ceux de l’autre sub.', subFix: 'Passer en /{s}',
  aliasCount: 'aussi pour {n} autre(s)', aliasTip: '{a} est le même set que {s} (une ligne « = » dans ton fichier) : le modifier modifie les deux.', statThen: 'puis, pour départager', statNone: '—', statFloors: 'Minimums obligatoires (0 = aucun)', statFloorsWhy: 'Les objectifs disent quoi maximiser, dans l’ordre. Un minimum est obligatoire : un set en dessous perd toujours. Exemple : perte d’inimitié réduite ≥ 60, puis le plus d’évasion magique possible.', statHpMin: 'HP ≥', statHpMax: 'HP ≤', statSird: 'SIRD ≥', statFc: 'Fast Cast ≥',
  statEcrit: 'Crit. ennemis ≤', statEnm: 'Enmity ≥', statPhx: 'Phalanx ≥', statCeLoss: 'Perte d’inimitié réduite ≥',
  statWhy: 'Les sets sans dégâts à calculer (repos, Enmity, Phalanx, Fast Cast, Cure…) se jugent sur leurs stats : la recherche ' +
    'additionne celles de chaque pièce, comme les solveurs du guide Paladin. Le premier objectif décide ; les suivants départagent les sets ' +
    'aussi bons sur lui. Un plancher à 0 est ignoré. DEF : ta DEF mesurée en jeu sans gear, + DEF et VIT × 1,5 du set ; en PLD sous Protect, ' +
    'la DEF du bouclier en plus (Shield Barrier, prise au moment du sort). Les dégâts physiques reçus selon l’attaque du monstre ne sont ' +
    'pas calculés : la formule des monstres n’est pas publiée (BG Wiki PDIF). Plus de DEF = moins de dégâts, sans chiffre exact.',
  statDone: 'Optimisé : {o} {a} → {b}, {n} pièce(s) changée(s) dans ton essai · DT+PDT {p} · DT+MDT {m}.',
  statSame: 'Ton set est déjà le meilleur trouvé : {o} {v}.', statThenShort: 'puis', statShield: 'dont bouclier (Shield Barrier) +{n}',
  tkBlock: 'Blocage', tkBlockTip: '{s} : {b} % de base à skill égal à celui du monstre (+0,2325 % par point d’écart), Palisade +30, Reprisal ×1,5 (×3 avec Priwen) ; un coup bloqué perd {r} % (guide Paladin).',
  tkCrit: 'Critiques ennemis', tkCritTip: '10 % au plus, 1 % au moins : mérites −{m}, gear {g}.', tkOver: '{n} de trop',
  tkCure: 'Cure IV', tkCureSelf: 'sur toi : {h} soignés', tkCureParts: 'MND {m} (sans gear {mb} + gear {mg}), VIT {v} ({vb} + {vg}), skill {s}, puissance {p}. Sans gear = ta mesure en jeu, avec les buffs choisis dans la page (une nourriture choisie mais absente en jeu fausse le chiffre).', tkLoss: 'Perte d’inimitié', tkLossTip: 'Réduction de la perte d’inimitié quand tu prends un coup, deux réserves qui se multiplient : l’Enmity (1 % pour +2, 50 % au plus) et les pièces « Reduces Enmity loss » (Burtgang 20 %, Chev. Cuisses +3 14 %, Creed Collar 5 %, 50 % au plus) ; −75 % au total au plus. Foe Sirvente (BRD) remplit la seconde, pas encore compté.'});
Object.assign(T.en, {
  statObj_def: 'DEF', statObj_hp: 'HP', statObj_enmity: 'Enmity', statObj_phalanx: 'Phalanx', statObj_fc: 'Fast Cast', statObj_sird: 'SIRD',
  statObj_meva: 'Magic evasion', statObj_mdb: 'Magic def. bonus', statObj_pdtRed: 'Physical damage taken', statObj_mdtRed: 'Magic damage taken',
  statObj_ecritRed: 'Enemy critical hits', statObj_cure: 'Cure potency', statObj_refresh: 'Refresh', statObj_regen: 'Regen',
  statObj_cureEnm: 'Cure enmity', statD_cureEnm: 'HP healed × (1 + Enmity): CE = heal × 0.231, VE = 6 × CE (Paladin guide); heal and Enmity part themselves',
  statObj_cureSelf: 'Cure IV on yourself', statD_cureSelf: 'HP really healed: the Cure’s power (MND, VIT, skill, Cure Potency) within the HP gap the Fast Cast opened',
  statCure4: 'Cure IV power', statCure4Tip: 'What your Cure IV would heal with no limit (BG Wiki, Cure Formula; on PLD Majesty always counted, Cure Potency II +25; +50 from the PLD gift Cure Potency Bonus from 1200 JP, checked in game: Cure IV 1332, 1245, 1114), day and weather aside.',
  statObj_enhdur: 'Enhancing duration', statD_enhdur: 'Enhancing magic duration: Protect, Shell, Reprisal… last longer',
  statObj_enhSkill: 'Enhancing skill', statD_enhSkill: 'yours + the gear: Phalanx, Stoneskin, Barspells… depend on it',
  statObj_divSkill: 'Divine skill', statD_divSkill: 'yours + the gear: Enlight II, Flash (Blind), Banish, Holy',
  statObj_ceLoss: 'Enmity loss cut', statD_ceLoss: 'when a hit lands: Enmity (1 % a +2, 50 % at +100) × the “reduced loss” pieces (Burtgang 20, Chev. Cuisses +3 14, 50 % at most), 75 % in all',
  statObj_blockGear: 'Block (gear)', statD_blockGear: 'shield skill × 0.2325 + the pieces’ block chance, over the shield’s base',
  statObj_statusRes: 'Status resistance', statD_statusRes: 'the pieces’ “resistance to all status ailments”',
  statObj_eleCover: 'Elements covered', statD_eleCover: 'elements with a positive resistance (of 8): what lets magic evasion reach the 1/8 resist (Paladin guide)',
  statObj_eleRes: 'Elemental resistances', statD_eleRes: 'the 8 elements’ mean',
  statObj_stoneskin: 'Stoneskin', statD_stoneskin: 'HP absorbed: enhancing skill and MND (350 at most), + the Stoneskin gear (475 at most)',
  statObj_enlight: 'Enlight II', statD_enlight: 'Accuracy and damage of the first hit: divine skill, Brilliance +15 / Honorbound +7 in hand',
  statObj_hpLow: 'Lowest HP', statD_hpLow: 'Fast Cast of a Cure on yourself: low HP, the Cure set raises them and the Cure fills the gap',
  statKeepOwn: 'Keep the ability’s piece ({p})', statKeepOwnTip: 'The pieces whose description names {b} stay: the search picks the rest.',
  statRef: 'HP vs Fast Cast', statRefTip: 'HP of the set less those of the Fast Cast {f} ({h} HP), the lowest classic set in HP, worn before every spell: '
    + 'the other sets aim between it and it + 200 so a set change loses no HP (Paladin guide, HP Management: 200 apart at most).',
  statRefLine: 'Reference HP: {h} (Fast Cast {f}) · the tank sets aim at {a} to {b}.',
  cyTitle: 'HP cycle', cyNote: 'Max HP of each set, idle {n} ({i}) → precast → midcast → idle. Going to a lower set drops your HP, coming back '
    + 'does not give them back: the loss is what is missing back at idle (before any heal). The guide aims at 200 apart at most. Your tried pieces count.',
  cyIdleHigh: 'Your idle is {n} above it: every spell costs you that difference.', cyAct: 'Action', cyPre: 'Precast', cyMid: 'Midcast', cyLoss: 'Loss', cyOnPurpose: 'on purpose', cyJa: 'JA',
  statAct: '{a} enmity', statActTip: '{a}: {ve} VE and {ce} CE at base, × (1 + Enmity / 100), the Enmity of gear + Crusade + Sentinel capped at +200 (Paladin guide, Enmity Generation).',
  protOther: 'Cast by another', protOtherTip: 'Protect cast by a WHM, RDM, SCH…: without your shield’s DEF (Shield Barrier counts on your own Protect only).',
  statGap: 'HP gained at midcast', statGapTip: 'HP of the set {m} less those of the Fast Cast {f}: what is missing when the Cure lands, so what it can heal in full (Paladin guide, CURE SELF).',
  statD_def: 'VIT × 1.5 + gear DEF (+ the shield under Protect on PLD)', statD_hp: 'HP with HP %', statD_enmity: 'up to the +200 cap, buffs in',
  statD_phalanx: 'the enhancing skill’s step + Phalanx received', statD_fc: 'up to 80 %', statD_sird: 'up to 102 %',
  statD_meva: 'resist spells', statD_mdb: 'divides magic damage', statD_pdtRed: 'DT+PDT capped at −50 %, then PDT II',
  statD_mdtRed: 'DT+MDT (+ Shell) capped, then MDT II', statD_ecritRed: 'the gear’s cut, counted down to the floor: 10 % → 1 %, so −9 with your merits',
  statD_cure: 'up to 50 %', statD_refresh: 'MP a tick', statD_regen: 'HP a tick',
  statAssumed: 'Always counted, as in the guide: Crusade (Enmity +30){m}.', statAssumedMaj: ', Majesty (Cure Potency II +25)',
  ownWeapon: 'the set’s own (worn for the action)',
  statWeaponsNote: 'Free weapons: the weapon and shield found go in this set, worn for the action (at idle your modes lay theirs back). Changing the main weapon loses the TP, the shield does not.',
  statGrp_def: 'Defense', statGrp_enm: 'Enmity', statGrp_cure: 'Healing', statGrp_magic: 'Magic', statGrp_regen: 'Recovery',
  statAll: 'All objectives (+{n})', statFewer: 'Only this set’s',
  statKept: 'Objectives or floors changed by hand on this set.', statReset: 'Back to the defaults',
  subWarn: 'In game you are {g}, the page shows {p}: base stats, traits and sets are the other subjob’s.', subFix: 'Show /{s}',
  aliasCount: 'also for {n} other(s)', aliasTip: '{a} is the same set as {s} (a “=” line in your file): changing it changes both.', statThen: 'then, to part ties', statNone: '—', statFloors: 'Required minimums (0 = none)', statFloorsWhy: 'The objectives say what to maximise, in order. A minimum is required: a set under it always loses. Example: enmity loss cut ≥ 60, then the most magic evasion.', statHpMin: 'HP ≥', statHpMax: 'HP ≤', statSird: 'SIRD ≥', statFc: 'Fast Cast ≥',
  statEcrit: 'Enemy crit ≤', statEnm: 'Enmity ≥', statPhx: 'Phalanx ≥', statCeLoss: 'Enmity loss cut ≥',
  statWhy: 'Sets with no damage to work out (idle, Enmity, Phalanx, Fast Cast, Cure…) are judged on their stats: the search adds up ' +
    'each piece’s, as the Paladin guide’s solvers do. The first objective decides; the next ones part sets as good on it. A floor at 0 is ' +
    'ignored. DEF: your DEF measured in game without gear, + the set’s DEF and VIT × 1.5; on PLD under Protect, the shield’s DEF too (Shield ' +
    'Barrier, taken when the spell is cast). Physical damage taken by the monster’s attack is not worked out: the monsters’ formula is not ' +
    'published (BG Wiki PDIF). More DEF = less damage, with no exact figure.',
  statDone: 'Optimised: {o} {a} → {b}, {n} piece(s) changed in your try · DT+PDT {p} · DT+MDT {m}.',
  statSame: 'Your set is already the best found: {o} {v}.', statThenShort: 'then', statShield: 'with the shield (Shield Barrier) +{n}',
  tkBlock: 'Block', tkBlockTip: '{s}: {b} % at the monster’s own skill (+0.2325 % a point of difference), Palisade +30, Reprisal ×1.5 (×3 with Priwen); a blocked hit loses {r} % (Paladin guide).',
  tkCrit: 'Enemy critical hits', tkCritTip: '10 % at most, 1 % at least: merits −{m}, gear {g}.', tkOver: '{n} too many',
  tkCure: 'Cure IV', tkCureSelf: 'on yourself: {h} healed', tkCureParts: 'MND {m} (no gear {mb} + gear {mg}), VIT {v} ({vb} + {vg}), skill {s}, power {p}. No gear = your measure in game, with the buffs chosen in the page (a food chosen but not on in game skews it).', tkLoss: 'Enmity lost', tkLossTip: 'Cut of the enmity lost when you take a hit, two buckets that multiply: the Enmity (1 % a +2, 50 % at most) and the “Reduces Enmity loss” pieces (Burtgang 20 %, Chev. Cuisses +3 14 %, Creed Collar 5 %, 50 % at most); −75 % in all at most. Foe Sirvente (BRD) fills the second, not counted yet.'});

const STAT_OBJS = ['def', 'hp', 'hpLow', 'cureSelf', 'enmity', 'phalanx', 'fc', 'sird', 'meva', 'mdb', 'pdtRed', 'mdtRed', 'ecritRed', 'cure', 'refresh', 'regen', 'enhdur', 'stoneskin', 'enlight', 'enhSkill', 'divSkill', 'cureEnm', 'blockGear', 'statusRes', 'eleRes', 'ceLoss', 'eleCover'];
const STAT_PCT = new Set(['fc', 'sird', 'pdtRed', 'mdtRed', 'ecritRed', 'cure', 'enhdur', 'blockGear', 'statusRes', 'eleRes', 'ceLoss']);
// a reduction of the enemy's critical hits reads as the gear says it (−7 %)
// the enmity of a Cure reads as its two parts (CE + VE, the total being 7 CE: opt.js cureEnm), not a bare figure that
// looks like HP
const statFmt = k => v => v == null ? '—' : k === 'cureEnm' ? cureEnmText(v)
  : (k === 'ecritRed' && v > 0 ? '−' : '') + ((Math.round(v * 10) / 10) || 0).toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US') + (STAT_PCT.has(k) ? ' %' : '');
const cureEnmText = v => { const ce = Math.round(v / 7), n = x => x.toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US'); return `${n(ce)} CE · ${n(Math.round(v - ce))} VE`; };
// A set the stats optimizer takes: every set but the weaponskill, engaged and Jump ones (their own optimizers), and
// the weapon sets
const statSet = s => !!s && !['ws', 'engaged', 'weapons', 'pet'].includes(family(s.path, s.pieces)) && !isJumpSet(s.path);
// What a set is for when nothing was chosen: the guide's profiles (idle DEF then Enmity then MDB; Enmity then DEF;
// Phalanx then DEF; Fast Cast then HP)
// A tank (PLD, RUN) wants Enmity on every action its set is worn for, after what the action itself needs (the
// Phalanx, the Cure...): Enmity goes second when it is not first. Not on a Fast Cast set: a spell's enmity comes at its
// midcast. A job ability's set: Enmity first, its own piece kept (keptSlots)
function statDefault(s){
  const list = withSird(s, statDefaultOf(s)), fam = family(s.path, s.pieces);
  // (the Cure's enmity counts Enmity already)
  if (!['PLD', 'RUN'].includes(S.job) || ['fc', 'idle', 'special'].includes(fam) || list.includes('enmity') || list[0] === 'cureEnm' || list[0] === 'phalanx') return list;
  if (fam === 'ja') return ['enmity', 'def', 'hp'];
  // after the set's own (and SIRD on a SIRD set), Enmity
  const lead = list[1] === 'sird' ? 2 : 1;
  return [...list.slice(0, lead), 'enmity', ...list.slice(lead).filter(k => k !== 'enmity')].slice(0, 3);
}
// A SIRD set (SIRDPhalanx, SIRDEnmity...): SIRD right after what the set is for, so the objective itself says it
// (its floor at 102 holds it too: statFloorDefault)
// Every name a set goes by (the export keeps one, the others as aliases: sets.midcast.SIRDEnmity is shared by
// Banishga, Cocoon, Foil... and may come under any of them): what it is for is read from all of them
const setNames = s => [s.path, ...(s.aliases || [])].join(' ');
function withSird(s, list){
  if (!/sird/i.test(setNames(s)) || list[0] === 'sird') return list;
  return [list[0], 'sird', ...list.slice(1).filter(k => k !== 'sird')].slice(0, 3);
}
function statDefaultOf(s){
  const p = setNames(s), fam = family(s.path, s.pieces), tank = ['PLD', 'RUN'].includes(S.job);
  // a self Cure's Fast Cast: capped, then as few HP as can be (Guide_Paladin CURE SELF: the midcast's HP open the gap);
  // a Fast Cast set first (it is named for the spells it serves: precast.FC.Phalanx)
  if (fam === 'fc' && /cure/i.test(p) && /self/i.test(p)) return ['fc', 'hpLow'];
  if (fam === 'fc') return ['fc', 'hp', 'pdtRed'];
  // Phalanx first, then the damage taken (no DT floor: the Phalanx comes before it)
  if (/phalanx/i.test(p)) return ['phalanx', 'pdtRed', 'mdtRed'];
  // a self Cure: a tank wants the most enmity from it (its HP healed x (1 + Enmity): opt.js cureEnm), then the heal itself
  if (/cur(e|a|aga)/i.test(p) && /self/i.test(p)) return tank ? ['cureEnm', 'cureSelf', 'pdtRed'] : ['cureSelf', 'pdtRed', 'hp'];
  if (/enmity|flash|crusade|provoke|foil|sird|sentinel|rampart|vallation|valiance|pflug|swordplay|battuta|liement|gambit|rayke/i.test(p)) return ['enmity', 'def', 'hp'];
  if (/cur(e|a|aga)/i.test(p)) return ['cure', 'enmity', 'hp'];
  if (/stoneskin/i.test(p) && fam !== 'fc') return ['stoneskin', 'enhSkill', 'hp'];
  // Enlight II: its bonus, then how long it lasts (enhancing duration: not confirmed by BG Wiki on this divine spell), then Enmity
  if (/enlight/i.test(p) && fam !== 'fc') return ['enlight', 'enhdur', 'enmity'];
  // an enhancing set (Protect, Shell, Reprisal...): how long they last
  if (family(s.path, s.pieces) === 'midcast' && /enhancing|protect|shell|reprisal/i.test(s.path)) return ['enhdur', 'enhSkill', 'hp'];
  if (/refresh/i.test(p)) return ['refresh', 'pdtRed', 'mdtRed'];
  if (/regen/i.test(p)) return ['regen', 'pdtRed', 'mdtRed'];
  // a magic-defense set by its name (idle.MDT, MEva): not every set with Magic in it (Enhancing Magic). Guide_Paladin
  // (Idle MDT, Magical Damage Mitigation): resist first (magic evasion and the elemental resistances move the resist
  // steps 1, 1/2, 1/4, 1/8), then the Magic Defense Bonus divides what lands; the MDT at its cap is a floor
  // (and the enmity kept when hit, as on any tank idle: Chev. Cuisses +3)
  if (/meva|mdt/i.test(p)) return ['PLD', 'RUN'].includes(S.job) ? ['eleCover', 'meva', 'ceLoss'] : ['eleCover', 'meva', 'mdb'];
  // a tank's idle (Guide_Paladin idle sets): PDT / MDT capped, the HP pool and the enemy's crits as floors; then a PLD's
  // block (the shield skill and block chance of the gear), the DEF, the magic evasion
  // (the block only with a shield that does not block every hit already: Duban and Ochain, ~108 % at base, do)
  // the enmity kept when hit (ceLoss: Enmity up to +100) second; a PLD's block first with a shield that does not block it all
  if (fam === 'idle' || fam === 'special') return S.job === 'PLD' && !shieldBlocksAll(s) ? ['blockGear', 'ceLoss', 'def'] : tank ? ['def', 'ceLoss', 'meva'] : ['pdtRed', 'mdtRed', 'hp'];
  return ['hp', 'pdtRed', 'mdtRed'];
}
// The objectives and floors kept for that set (S.optOpts.statBy[path]: {objs, floor})
function statOpts(s){
  const by = (S.optOpts || {}).statBy || {}, mine = by[s.path] || {}, objs = (mine.objs || statDefault(s)).slice(0, 3);
  return {objs, floor: Object.assign({pdt: 0, mdt: 0, hp: 0, hpMax: 0, sird: 0, fc: 0, ecrit: 0, enmity: 0, phalanx: 0, ceLoss: 0}, statFloorDefault(s, objs[0]), mine.floor || {})};
}
// The floors a tank's idle and Enmity sets start with (the guide's solve_idle / solve_enmity: DT+PDT at the -50 % cap,
// the gear's enemy critical hit rate -5 beside the -5 of the merits); 0 (no floor) elsewhere
// (SIRD sets and Cures: SIRD 102 with the merits, the guide's benchmark; a Fast Cast: capped at 80)
// A tank's other sets: their HP between the reference and 200 more (hpRef)
function statFloorDefault(s, first){
  // SIRD 102 on a set named for it, and on a tank's Cure sets (cast while taking hits)
  const fam = family(s.path, s.pieces), cureSet = fam === 'midcast' && /cur(e|a)/i.test(setNames(s)) && ['PLD', 'RUN'].includes(S.job);
  const sird = /sird/i.test(setNames(s)) || cureSet ? {sird: 102} : {};
  if (first === 'fc') return {fc: 80};
  if (!['PLD', 'RUN'].includes(S.job)) return sird;
  const ref = hpRef(s), hp = ref && !cureGap(s) ? {hp: ref.hp, hpMax: ref.hp + HP_SPREAD} : {};
  // damage taken at its cap on every tank set worn more than an instant: DT+PDT -50, DT+MDT -50 less what Shell gives
  // (Shell V -29.3 %: -21 left to the gear)
  // (not on a Phalanx set: its Phalanx comes first, the damage taken after it as objectives)
  const shell = buffTotals().shell || 0, dt = first === 'phalanx' ? {} : {pdt: -50, mdt: -Math.ceil(50 - shell / 256 * 100)};
  // the gear's cut of the enemy's crits the idle needs: 10 % to the 1 % floor is 9, less the merits (5/5: 4)
  const need = 9 - (((measuredChar() || {}).merits || {}).enemy_critical_hit_rate || 0);
  const ecrit = ['idle', 'special'].includes(fam) && need > 0 ? {ecrit: -need} : {};
  // a magic-defense idle keeps 60 % of enmity loss cut (Chev. Cuisses +3): 31 magic evasion for 8 % of enmity kept and
  // 5 MDB on Tetsouo's (2026-10-05), magic evasion after it
  if (['idle', 'special'].includes(fam) && /meva|mdt/i.test(setNames(s))) ecrit.ceLoss = 60;
  return Object.assign(dt, ecrit, sird, hp);
}
// The reference HP of a tank's sets (Guide_Paladin HP Management): the lowest of the classic Fast Cast sets
// (sets.precast.FC and its spells', not the self Cure's, low on purpose), the lowest in HP of the sets worn in the cycle
// (idle, Fast Cast, midcast or ability, idle) and worn before every spell.
// Swapping to a set with fewer max HP cuts the current HP, and swapping back does not give them back: the other sets
// keep within HP_SPREAD over it (the guide: idle 3197, Fast Cast 3044, Full Enmity 3045). Not for the Fast Cast sets
// themselves, nor the self Cure pair (its gap is on purpose: cureGap). {hp, path} or null
const HP_SPREAD = 200;
function hpRef(s){
  if (!['PLD', 'RUN'].includes(S.job) || family(s.path, s.pieces) === 'fc') return null;
  const d = data(), list = d ? d.sets.filter(x => family(x.path, x.pieces) === 'fc' && !(/cure/i.test(x.path) && /self/i.test(x.path))) : [];
  let low = null;
  for (const x of list) { const hp = statFigures(x, true).hp; if (!low || hp < low.hp) low = {hp, path: x.path}; }
  return low;
}
// A set laid over another one (sets.precast.JA.Sentinel = FullEnmity + Caballarius Leggings): its own pieces stay
// when asked (a job ability's set: on by default), only the rest is searched. The slots kept, or none
function keptSlots(s){
  const list = abilityPieces(s);
  if (!list.length) return [];
  const mine = ((S.optOpts || {}).statBy || {})[s.path] || {};
  return (mine.keepOwn != null ? mine.keepOwn : true) ? list : [];
}
// The slots of a job ability's set whose piece boosts that ability: its description or its augments name it
// (Rev. Leggings +4 "Holy Circle", Cab. Leggings "Sentinel", Chev. Sabatons "Divine Emblem"); not the set's other
// pieces, which only differ from the set it is laid over (Cryptic Earring in Holy Circle's)
function abilityPieces(s){
  if (family(s.path, s.pieces) !== 'ja') return [];
  const ja = segs(s.path).pop().toLowerCase(), cat = catalog(), out = [];
  for (const [slot, p] of Object.entries(withoutTrial(() => withWeapons(s).pieces))) {
    if (!p || isEmpty(p)) continue;
    const id = p.id || ownId(p.name, slot) || (cat && cat.id[p.name]);
    const text = ((id && (descTexts()[id] || (cat && cat.desc[id]))) || '') + ' ' + (p.augs || []).join(' ');
    if (text.toLowerCase().includes(ja)) out.push(slot);
  }
  return out;
}
// The HP a self Cure's midcast set opens over its Fast Cast (the other set of the pair: sets.precast.FC.CureSelf and
// sets.midcast.CureSelf, any names with Cure and Self), or null
function cureGap(s){
  if (!/cure/i.test(s.path) || !/self/i.test(s.path)) return null;
  const fc = family(s.path, s.pieces) === 'fc', d = data();
  const other = d && d.sets.find(x => x.path !== s.path && /cure/i.test(x.path) && /self/i.test(x.path) && (family(x.path, x.pieces) === 'fc') !== fc && family(x.path, x.pieces) !== 'ws');
  if (!other) return null;
  const hp = set => statFigures(set, true).hp;
  return {other, gap: f => fc ? hp(other) - f.hp : f.hp - hp(other), mid: fc ? other.path : s.path, pre: fc ? s.path : other.path};
}
function setStatOpts(path, patch){
  const by = Object.assign({}, (S.optOpts || {}).statBy), cur = by[path] || {};
  by[path] = Object.assign({}, cur, patch, patch.floor ? {floor: Object.assign({}, cur.floor, patch.floor)} : {});
  S.optOpts = Object.assign({}, S.optOpts, {statBy: by}); save();
}

/* ---- the objectives by kind, and the ones a set is shown ---- */
const STAT_OBJ_GROUPS = [['def', ['def', 'hp', 'pdtRed', 'mdtRed', 'ecritRed', 'blockGear', 'meva', 'mdb', 'statusRes', 'eleCover', 'eleRes']], ['enm', ['enmity', 'ceLoss', 'cureEnm']],
  ['cure', ['cureSelf', 'cure', 'hpLow']], ['magic', ['phalanx', 'stoneskin', 'enlight', 'enhdur', 'enhSkill', 'divSkill', 'fc', 'sird']],
  ['regen', ['refresh', 'regen']]];
// What a set's kind can be after (its name, as statDefaultOf reads it), its chosen objectives always in
function statRelevant(s, chosen){
  const p = setNames(s), fam = family(s.path, s.pieces), out = new Set(chosen);
  const add = list => list.forEach(k => out.add(k)), def = ['def', 'hp', 'pdtRed', 'mdtRed', 'meva', 'mdb', 'enmity'];
  if (fam === 'fc') add(/cure/i.test(p) && /self/i.test(p) ? ['fc', 'hpLow', 'hp'] : ['fc', 'hp', 'pdtRed', 'mdtRed']);
  else if (/cur(e|a)/i.test(p)) add(/self/i.test(p) ? ['cureEnm', 'cureSelf', 'enmity', 'hp', 'sird', 'pdtRed', 'mdtRed'] : ['cure', 'enmity', 'hp', 'sird', 'pdtRed', 'mdtRed']);
  else if (/phalanx/i.test(p)) add(['phalanx', 'enhSkill', 'sird', 'enmity', 'def', 'hp', 'pdtRed']);
  else if (/stoneskin/i.test(p)) add(['stoneskin', 'enhSkill', 'sird', 'enmity', 'hp', 'pdtRed']);
  else if (/enlight/i.test(p)) add(['enlight', 'enhdur', 'divSkill', 'sird', 'enmity', 'hp', 'pdtRed']);
  else if (fam === 'midcast' && /enhancing|protect|shell|reprisal/i.test(s.path)) add(['enhdur', 'enhSkill', 'sird', 'enmity', 'hp', 'pdtRed']);
  else if (fam === 'enmity' || fam === 'ja') add(['enmity', 'sird', ...def]);
  else if (fam === 'idle' || fam === 'special') add([...def, 'ceLoss', 'ecritRed', 'statusRes', 'eleCover', 'eleRes', 'refresh', 'regen', ...(S.job === 'PLD' ? ['blockGear'] : [])]);
  else add([...def, 'refresh', 'regen']);
  return out;
}

/* ---- the enmity of each action (Guide_Paladin 02 Enmity Generation: base VE / CE, before the gear) ---- */
// Final = base x (1 + Enmity / 100), the Enmity of gear + Crusade + Sentinel capped at +200 (x3)
const ACTION_ENMITY = {Invincible: [7200, 0], Palisade: [1800, 900], 'Shield Bash': [900, 450], Flash: [1280, 180], Sentinel: [900, 0],
  Majesty: [340, 0], Rampart: [320, 320], 'Divine Emblem': [320, 0], Sepulcher: [320, 0], Jettatura: [1020, 180], 'Blank Gaze': [320, 320],
  'Geist Wall': [320, 320], 'Sheep Song': [320, 320], Valiance: [900, 450], Vallation: [900, 450], Pflug: [900, 450], Foil: [880, 320],
  Swordplay: [320, 160], Provoke: [1800, 1], Warcry: [320, 0]};
// The actions a set is worn for, by its name and the names it is shared under (sets.FullEnmity: Flash, Crusade, Jettatura)
function setActions(s){
  // a Fast Cast set makes no enmity: the spell's comes at its midcast
  if (family(s.path, s.pieces) === 'fc') return [];
  const names = [s.path, ...(s.aliases || [])].map(p => segs(p).pop());
  return [...new Set(names)].filter(n => ACTION_ENMITY[n]);
}

/* ---- the pieces and the character, as plain data for the search (a worker has no page to ask) ---- */
// A piece's stats the search reads (stats.js keys), the shield flagged (Shield Barrier)
// The HP a piece adds to Stoneskin (BG Wiki Stoneskin; the game's descriptions name the effect, not always its amount;
// Stone Mufflers as its description says it, +20)
const STONESKIN_PLUS = {'Stone Gorget': 30, 'Nodens Gorget': 30, 'Stone Mufflers': 20, 'Siegel Sash': 20, 'Haven Hose': 20, 'Earthcry Earring': 10, 'Shedir Seraweels': 35};
// The pieces that cut the enmity lost when hit (Guide_Paladin, "Reduces Enmity Loss": their descriptions name the effect
// without its amount)
const ENMITY_LOSS_GEAR = {'Burtgang': 20, "Chev. Cuisses +3": 14, 'Creed Collar': 5};
// The weapons that raise Enlight's bonus, in hand (BG Wiki Enlight II)
const ENLIGHT_WEAPON = {Brilliance: 15, Honorbound: 7};
function statVec(p, slot){
  const r = p && !isEmpty(p) ? pieceStats(p, slot) : null, v = k => r && r.stats[k] ? r.stats[k].v || 0 : 0, out = {};
  if (!r) return {};
  if (r.stats['x:potency of cure effect received']) out.curerecv = r.stats['x:potency of cure effect received'].v;
  // "All magic skills" (Stikini Ring +1) counts in each magic skill read here
  const all = r.stats['x:all magic skills'] ? r.stats['x:all magic skills'].v : 0;
  if (v('skill:healing magic skill') + all) out.heal = v('skill:healing magic skill') + all;
  if (v('skill:divine magic skill') + all) out.div = v('skill:divine magic skill') + all;
  if (STONESKIN_PLUS[p.name]) out.ss = STONESKIN_PLUS[p.name];
  if (slot === 'main' && ENLIGHT_WEAPON[p.name]) out.enl = ENLIGHT_WEAPON[p.name];
  if (ENMITY_LOSS_GEAR[p.name]) out.lossRed = ENMITY_LOSS_GEAR[p.name];
  if (v('skill:shield skill')) out.shield = v('skill:shield skill');
  if (v('block')) out.block = v('block');
  const sr = v('x:resistance to all status ailments') + v('x:all status ailment resistance');
  if (sr) out.statusRes = sr;
  const er = ['fire', 'ice', 'wind', 'earth', 'lightning', 'water', 'light', 'dark'].reduce((n, e) => { if (v('res_' + e)) out['res_' + e] = v('res_' + e); return n + v('res_' + e); }, 0);
  if (er) out.eleRes = er;
  for (const k of ['hp', 'hp%', 'def', 'vit', 'mnd', 'cure2', 'dt', 'pdt', 'mdt', 'pdt2', 'mdt2', 'bdt', 'enmity', 'phalanx', 'sird', 'fc', 'meva', 'mdb', 'ecrit', 'cure', 'refresh', 'regen', 'enhdur'])
    if (v(k)) out[k] = v(k);
  if (v('skill:enhancing magic skill') + all) out.enh = v('skill:enhancing magic skill') + all;
  return out;
}
function withVec(p, slot){
  if (!p) return p;
  const q = Object.assign({}, p, {st: statVec(p, slot)});
  if (slot === 'sub') { const it = itemOf(p.name); if (it && it.Type === 'Shield') q.shield = true; }
  return q;
}
function withVecs(pieces){
  const out = {};
  for (const [slot, p] of Object.entries(pieces || {})) out[slot] = withVec(p, slot);
  return out;
}
// The character without gear: HP before the gear's HP %, DEF (Protect in), the enhancing skill, the buffs' Enmity
// and Shell; Shield Barrier when a PLD is under Protect (BG Wiki: Protect cast by a PLD adds its shield's DEF)
function statBase(s){
  const r = charStats(s, {}), b = buffState(), B = buffTotals(), c = measuredChar() || {};
  const cur = r ? r.cur : {};
  // SIRD merits: 2 % a level (Guide_Paladin solver_common: Merit_SIRD 10 at 5/5)
  // a self Cure's set: the HP its Fast Cast leaves (cureGap), MND / VIT / Healing skill for the Cure's power
  // (a PLD: Majesty's Cure Potency II +25 counted, on or not: the guide's Cure sets take it as always up)
  const pair = s && cureGap(s), pre = pair && family(s.path, s.pieces) !== 'fc' ? statFigures(pair.other, true).hp : null;
  // the enemy's critical hits the gear can still take off: 10 % to the 1 % floor, less the merits
  const ecritRoom = Math.max(0, 9 - ((c.merits || {}).enemy_critical_hit_rate || 0));
  // a PLD's job gift Cure Potency Bonus (BG Wiki Paladin: Cures heal 50 more, from 1200 job points spent), added to a
  // Cure's base (opt.js O.cureIV)
  const cureJp = S.job === 'PLD' && (c.jp_spent || 0) >= 1200 ? 50 : 0;
  // a tank (PLD, RUN): Crusade's Enmity +30 counted, on or not (the guide: "essentially always up", 5 min, refreshed in
  // the rotation), in the equipment Enmity capped at +200
  const crusade = ['PLD', 'RUN'].includes(S.job) && !jaOn(buffState(), 'Crusade') ? CRUSADE_ENMITY : 0;
  return {ecritRoom, cureJp, div: c.skills ? skillLevel(c, 'divine magic') : 0, preHp: pre, mnd: cur.mnd || 0, vit: cur.vit || 0, heal: c.skills ? skillLevel(c, 'healing magic') : 0, cure2: Math.max(B.cure2 || 0, S.job === 'PLD' ? 25 : 0),
    hp: cur.hp || 0, def: cur.def || 0, enh: c.skills ? skillLevel(c, 'enhancing magic') : 0, enmity: (B.enmity || 0) + crusade, sird: 2 * ((c.merits || {}).spell_interruption_rate || 0),
    shell: B.shell || 0, mdb: (B.mdb || 0) + (r ? traitOf('mdb', c) + giftOf('mdb', c) : 0), meva: 0,
    shieldBarrier: S.job === 'PLD' && !!PROTECT[b.protect] && !b.protectOther, shieldMul: protectGift()};
}
const statContext = s => ({mode: 'stats', job: S.job, stat: {base: statBase(s)}});
const CRUSADE_ENMITY = 30;

/* ---- the tank figures the guide adds (Guide_Paladin 03 Defense, 02 Enmity), shown in the Tanking compartment ---- */
// Shield Barrier (PLD trait): Protect cast by a PLD adds its shield's DEF (taken when cast; here the set's shield).
// Returns the buff totals with it (a copy), or as they are
// Only on a Protect you cast yourself (BG Wiki: "Protect spells cast by a Paladin"; the buffs window's Protect row says
// when another job casts it: protectOther), the gift's +10 % on it too
function shieldBarrier(B, sub){
  const b = buffState();
  if (S.job !== 'PLD' || !PROTECT[b.protect] || b.protectOther || !sub || isEmpty(sub)) return B;
  const it = itemOf(sub.name), r = it && it.Type === 'Shield' ? pieceStats(sub, 'sub') : null, def = r && r.stats.def ? Math.floor(r.stats.def.v * protectGift()) : 0;
  if (!def) return B;
  return Object.assign({}, B, {def: (B.def || 0) + def, _by: B._by.concat([{src: 'Shield Barrier · ' + sub.name, k: 'def', v: def}])});
}
// A PLD's job gift Protect Effect (BG Wiki Paladin: Protect received +10 %, from 550 job points spent): the factor on
// Protect's Defense (on the shield's part too: BG Wiki does not say, to check in game)
function protectGift(){
  const c = typeof measuredChar === 'function' ? measuredChar() : null;
  return S.job === 'PLD' && c && (c.jp_spent || 0) >= 550 ? 1.1 : 1;
}
// Whether the set's shield blocks every hit at its base already (Duban, Ochain: ~108 %): its block gains nothing more
function shieldBlocksAll(s){
  const sub = (withWeapons(s).pieces.sub || {}).name, sh = ULTIMATE_SHIELDS[sub];
  return !!sh && sh[0] >= 100;
}
// The shields the guide gives figures for: base block rate (at the attacker's skill) and the damage a block takes off
const ULTIMATE_SHIELDS = {Aegis: [50, 75], Srivatsa: [50, 75], Ochain: [108, 60], Duban: [108, 60]};
// The lines under the damage taken: block, the enemy's critical hits left, the Enmity lost on a hit
function tankExtraHTML(c, set, B, enm){
  const v = k => (set[k] || {}).v || 0, rows = [], sub = (S._curSet ? withWeapons(S._curSet).pieces.sub : null) || {};
  const sh = ULTIMATE_SHIELDS[sub.name];
  if (sh && S.job === 'PLD') {
    const mul = B.blockmul || 1;
    const rate = Math.min(100, (sh[0] + (B.block || 0)) * mul);
    rows.push(statLi(t('tkBlock'), `${Math.round(rate)} %`, `−${sh[1]} %`, '', t('tkBlockTip', {s: sub.name, b: sh[0], r: sh[1]})));
  }
  const merit = ((c.merits || {}).enemy_critical_hit_rate || 0), gear = v('ecrit');
  if (['PLD', 'RUN'].includes(S.job) || gear) {
    const left = Math.max(1, 10 - merit + gear), over = Math.max(0, 1 - (10 - merit + gear));
    rows.push(statLi(t('tkCrit'), `${left} %`, over ? t('tkOver', {n: over}) : '', '', t('tkCritTip', {m: merit, g: gear})));
  }
  // a Cure set: what its Cure IV heals (on yourself: within the HP its Fast Cast leaves)
  const cs = S._curSet;
  if (cs && /cur(e|a)/i.test(cs.path) && family(cs.path, cs.pieces) !== 'fc' && engineReady() && FFXI.opt.cureIV) {
    const f = statFigures(cs), pair = cureGap(cs);
    // the figures it is worked out with, to set beside the game's (MND / VIT measured, the page's buffs in)
    const b = statBase(cs), v = {};
    for (const [slot, p] of Object.entries(optPieces(withWeapons(cs).pieces))) { const st = withVec(p, slot).st; for (const k of ['mnd', 'vit', 'heal']) v[k] = (v[k] || 0) + (st[k] || 0); }
    const mnd = b.mnd + v.mnd, vit = b.vit + v.vit, heal = b.heal + v.heal;
    const parts = t('tkCureParts', {m: mnd, mb: b.mnd, mg: v.mnd, v: vit, vb: b.vit, vg: v.vit, s: heal, p: Math.floor(mnd / 2) + Math.floor(vit / 4) + heal});
    rows.push(statLi(t('tkCure'), `${f.cureIV} HP`, pair ? t('tkCureSelf', {h: f.cureSelf}) : '', '', parts + ' ' + t('statCure4Tip')));
  }
  if (['PLD', 'RUN'].includes(S.job)) {
    const held = S._curSet ? withWeapons(S._curSet).pieces : {};
    // Crusade counted as the optimizer counts it (statBase: always up for a tank)
    const crusade = jaOn(buffState(), 'Crusade') ? 0 : CRUSADE_ENMITY;
    const b1 = Math.max(0, Math.min(100, enm + crusade)) / 2, b2 = Math.min(50, Object.values(held).reduce((n, p) => n + (p && ENMITY_LOSS_GEAR[p.name] || 0), 0));
    const all = Math.round((1 - (1 - b1 / 100) * (1 - b2 / 100)) * 1000) / 10;
    if (all) rows.push(statLi(t('tkLoss'), `−${all} %`, `${b1} % × ${b2} %`, '', t('tkLossTip')));
  }
  return rows.join('');
}
// A set's figures (the try as shown, or plain: the file's set)
function statFigures(s, plain){
  const pieces = plain ? withoutTrial(() => withWeapons(s).pieces) : withWeapons(s).pieces;
  const v = {};
  for (const [slot, p] of Object.entries(optPieces(pieces))) v[slot] = withVec(p, slot);
  return FFXI.opt.statFigures(statContext(s).stat, v);
}

/* ---- the HP cycle (Guide_Paladin HP Management): every action's sets, idle -> precast -> midcast -> idle ---- */
// A set's max HP as shown (its tried pieces in), the character's HP without gear given
function setMaxHp(x, nakedHp){
  const v = {};
  for (const [slot, p] of Object.entries(optPieces(withWeapons(x).pieces))) v[slot] = withVec(p, slot);
  return FFXI.opt.statFigures({base: {hp: nakedHp}}, v).hp;
}
// The actions and their sets: each spell with a midcast set (its own name, or a name it shares: sets.midcast.Flash =
// sets.FullEnmity) after its Fast Cast (sets.precast.FC.<spell>, the self Cure's, else sets.precast.FC); each job
// ability's set alone. Actions with the same two sets go on one line
function hpCycleRows(){
  const by = S._bypath || {}, d = data(), fc = by['sets.precast.FC'], out = new Map();
  const pathOf = (root, name) => by[`${root}.${name}`] || by[`${root}["${name}"]`];
  const paths = new Set();
  for (const x of d.sets) for (const p of [x.path, ...(x.aliases || [])]) paths.add(p);
  for (const p of paths) {
    const sg = segs(p);
    let pre = null, mid = null, name = sg[sg.length - 1];
    if (sg[0] === 'midcast' && sg.length === 2) {
      mid = by[p];
      pre = /cur(e|a)/i.test(name) && /self/i.test(name) ? (Object.values(by).find(x => family(x.path, x.pieces) === 'fc' && /cure/i.test(x.path) && /self/i.test(x.path)) || fc) : pathOf('sets.precast.FC', name) || fc;
    } else if (sg[0] === 'precast' && sg[1] === 'JA' && sg.length === 3) pre = by[p];
    else continue;
    if (!pre && !mid) continue;
    const key = (pre ? pre.path : '') + '|' + (mid ? mid.path : '');
    if (!out.has(key)) out.set(key, {pre, mid, names: [], ja: !mid, self: !!mid && /cure/i.test(name) && /self/i.test(name)});
    out.get(key).names.push(name);
  }
  return [...out.values()];
}
function hpCycleHTML(s){
  if (!['PLD', 'RUN'].includes(S.job) || !engineReady() || !FFXI.opt.statFigures) return '';
  // the idle the cycle starts from: the set shown when it is one (idle.PDT, idle.MDT...), else sets.idle
  const idle = family(s.path, s.pieces) === 'idle' ? s : (S._bypath || {})['sets.idle'];
  if (!idle) return '';
  const r = charStats(idle, {}), naked = r ? r.cur.hp : 0, hp = x => x ? setMaxHp(x, naked) : null, top = hp(idle), ref = hpRef(idle);
  const rows = hpCycleRows().map(x => {
    const a = hp(x.pre), b = hp(x.mid), low = Math.min(top, a == null ? top : a, b == null ? top : b);
    return Object.assign(x, {a, b, loss: top - low});
  }).sort((x, y) => y.loss - x.loss || x.names[0].localeCompare(y.names[0]));
  const mine = x => [x.pre, x.mid].some(z => z && (z.path === s.path || (z.aliases || []).includes(s.path))) || x.names.some(n => s.path.endsWith('.' + n) || s.path.endsWith(`["${n}"]`));
  const cls = x => x.self ? '' : x.loss > HP_SPREAD ? 'short' : x.loss > 0 ? 'warn' : 'better';
  const names = x => (x.ja ? t('cyJa') + ' · ' : '') + x.names.sort().join(', ');
  const refLine = ref ? `<p class="note-m">${esc(t('statRefLine', {h: ref.hp, f: shortPath(ref.path), a: ref.hp, b: ref.hp + HP_SPREAD}))}${top > ref.hp + HP_SPREAD ? ' ' + esc(t('cyIdleHigh', {n: top - ref.hp})) : ''}</p>` : '';
  const body = `<p class="note-m">${esc(t('cyNote', {i: top, n: shortPath(idle.path)}))}</p>${refLine}<table class="rdvs optable hpcycle"><thead><tr><th>${t('cyAct')}</th><th>${t('cyPre')}</th><th>${t('cyMid')}</th><th>${t('cyLoss')}</th></tr></thead><tbody>` +
    rows.map(x => `<tr class="${mine(x) ? 'obj' : ''}"><th title="${esc(x.names.join(', '))}">${esc(names(x).length > 24 ? names(x).slice(0, 23) + '…' : names(x))}</th>` +
      `<td>${x.a ?? '—'}</td><td>${x.b ?? '—'}</td><td class="${cls(x)}">${x.self ? esc(t('cyOnPurpose')) : x.loss ? '−' + x.loss : '0'}</td></tr>`).join('') + `</tbody></table>`;
  // open until folded: it is what a tank checks on every set
  if (S.boxOpen.hpcycle === undefined) S.boxOpen.hpcycle = true;
  return fbox('hpcycle', 'g-tank', t('cyTitle'), body);
}

// The Compare window's lines for a set judged by its stats: its objectives and the lines shown under them (Phalanx with
// its skill step, the Cure, the HP gap, each action's enmity...) per column, the best in bold, each column's gap to the
// first (trial.js openCompare)
function statCmpRows(s, cols){
  if (!statSet(s) || !engineReady() || !FFXI.opt.statFigures) return '';
  const figs = cols.map(c => withTrialAs(s, c.tr, () => statFigures(s)));
  const rows = statRows(s).filter((r, i) => i < 3 || ['gap', 'ref', 'cure4', 'phalanx'].includes(r.id) || r.id.startsWith('act:'));
  const seen = new Set();
  return rows.filter(r => !seen.has(r.id) && seen.add(r.id)).map(r => {
    const vals = figs.map(f => f ? r.get(f) : null);
    if (vals.every(v => v == null)) return '';
    const best = r.low ? Math.min(...vals.filter(v => v != null)) : Math.max(...vals.filter(v => v != null));
    return `<tr class="want"><th ${r.tip ? `title="${esc(r.tip)}"` : ''}>${esc(r.label)}</th>` + vals.map((v, i) => {
      const dv = v != null && vals[0] != null ? v - vals[0] : 0, up = r.low ? dv < 0 : dv > 0;
      return `<td class="${v === best && vals.some(x => x !== v) ? 'best' : ''} ${r.floor && v != null && !r.floor(v) ? 'short' : ''}">${v == null ? '—' : r.fmt(v)}` +
        (i && dv ? `<i class="dv ${up ? 'up' : 'down'}">${dv > 0 ? '+' : '−'}${Math.round(Math.abs(dv) * 10) / 10}</i>` : '') + `</td>`; }).join('') + `</tr>`;
  }).join('');
}

/* ---- the search ---- */
async function optimizeStats(s){
  if (!engineReady() || !statSet(s)) return;
  const k = trialKey(s), o = Object.assign({}, S.optOpts), so = statOpts(s), base = withoutTrial(() => withWeapons(s).pieces);
  const choices = optChoices(new Set(Object.keys(ONLY_AUGS)));
  for (const slot of keptSlots(s)) delete choices[slot];
  for (const slot of Object.keys(choices)) choices[slot] = choices[slot].map(p => withVec(p, slot));
  if (o.freeWeapons && !keptSlots(s).some(x => x === 'main' || x === 'sub')) choices.weapons = weaponPairs(base).map(x => ({main: withVec(x.main, 'main'), sub: x.sub ? withVec(x.sub, 'sub') : null}));
  const start = withVecs(startOf(base));
  const input = {ctx: statContext(s), start, choices, prefilter: o.where === 'all' ? 25 : 0,
    opts: {fast: (o.search || 'fast') !== 'classic', objective: so.objs[0], then: so.objs.slice(1), floor: so.floor}};
  optLaunch(s, k, input, Object.assign({}, o, {stat: so.objs[0], statFloor: so.floor}));
}

/* ---- the page: objectives, floors, the result's lines ---- */
function statWhatHTML(s){
  const so = statOpts(s), cur = so.objs[0];
  // the objectives by kind, only the ones that mean something for this set (statRelevant) unless all are asked for
  const all = !!(S.optOpts || {}).statAll, shown = all ? new Set(STAT_OBJS) : statRelevant(s, so.objs);
  const btn = k => `<button class="opobj ${k === cur ? 'on' : ''}" role="radio" aria-checked="${k === cur}" ` +
    `data-statobj="${k}"><b>${esc(t('statObj_' + k))}</b><span>${esc(t('statD_' + k))}</span></button>`;
  const groups = STAT_OBJ_GROUPS.map(([g, keys]) => { const list = keys.filter(k => shown.has(k));
    return list.length ? `<div class="opgrp"><span class="opgrph">${esc(t('statGrp_' + g))}</span>${list.map(btn).join('')}</div>` : ''; }).join('');
  const hidden = STAT_OBJS.length - shown.size;
  const toggle = `<button class="linkbtn opallbtn" data-statobjall>${esc(all ? t('statFewer') : t('statAll', {n: hidden}))}</button>`;
  const objs = `<div class="opobjs" role="radiogroup">${groups}</div>${all || hidden ? toggle : ''}`;
  const then = i => `<select class="buffsel" data-statthen="${i}">${['', ...STAT_OBJS].filter(k => k !== cur).map(k =>
    `<option value="${k}" ${(so.objs[i] || '') === k ? 'selected' : ''}>${esc(k ? t('statObj_' + k) : t('statNone'))}</option>`).join('')}</select>`;
  const help = S._help === 'optpage' ? `<p class="wshelp">${esc(t('statWhy'))} ${esc(t('opHelp'))}</p>` : '';
  const num = (k, label) => `<label class="opf">${label} <input type="number" step="1" data-statfloor="${k}" value="${esc(so.floor[k])}"></label>`;
  // the floors of the stats this set is after (and any floor given a value), the others hidden with their objectives
  const has = (k, obj) => all || shown.has(obj) || !!+so.floor[k], opt = (k, obj, label) => has(k, obj) ? num(k, label) : '';
  // the set's own settings kept from an earlier visit: one click back to the defaults (they change as the page learns)
  const kept = ((S.optOpts || {}).statBy || {})[s.path];
  const reset = kept ? `<p class="muted small">${esc(t('statKept'))} <button class="linkbtn" data-statreset>${esc(t('statReset'))}</button></p>` : '';
  const floors = reset + `<h4 class="ophd2">${t('statFloors')}</h4><p class="muted small">${esc(t('statFloorsWhy'))}</p><div class="opparams">${num('pdt', 'DT+PDT ≤')}${num('mdt', 'DT+MDT ≤')}${num('hp', t('statHpMin'))}` +
    `${num('hpMax', t('statHpMax'))}${opt('sird', 'sird', t('statSird'))}${opt('fc', 'fc', t('statFc'))}${opt('ecrit', 'ecritRed', t('statEcrit'))}${opt('enmity', 'enmity', t('statEnm'))}${opt('phalanx', 'phalanx', t('statPhx'))}${opt('ceLoss', 'ceLoss', t('statCeLoss'))}</div>`;
  const search = opSearchHTML(S.optOpts || {}, false, true);
  const jaList = abilityPieces(s);
  const own = jaList.length ? `<div class="opparams"><label class="opf opwrap" title="${esc(t('statKeepOwnTip', {b: segs(s.path).pop()}))}"><input type="checkbox" data-statkeep ${keptSlots(s).length ? 'checked' : ''}> ` +
    `${esc(t('statKeepOwn', {p: jaList.map(sl => (withWeapons(s).pieces[sl] || {}).name || sl).join(', ')}))}</label></div>` : '';
  const ref = cureGap(s) ? null : hpRef(s);
  const refLine = ref ? `<p class="muted small">${esc(t('statRefLine', {h: ref.hp, f: shortPath(ref.path), a: ref.hp, b: ref.hp + HP_SPREAD}))}</p>` : '';
  const weaponsNote = (S.optOpts || {}).freeWeapons ? `<p class="muted small">${esc(t('statWeaponsNote'))}</p>` : '';
  const assumed = ['PLD', 'RUN'].includes(S.job) ? `<p class="muted small">${esc(t('statAssumed', {m: S.job === 'PLD' ? t('statAssumedMaj') : ''}))}</p>` : '';
  return `<h3 class="ophd">${t('opWhat')} ${helpBtn('optpage')}</h3>${help}${objs}<div class="opparams"><span class="opf">${esc(t('statThen'))}</span>${then(1)}${then(2)}</div>` +
    own + floors + refLine + assumed + search + weaponsNote;
}
// The result's lines: the objectives first, then every figure, the floors marked
function statRows(s){
  const so = statOpts(s), fl = so.floor, on = k => +fl[k];
  const rows = STAT_OBJS.map(k => ({id: k, label: t('statObj_' + k), get: f => f[k], fmt: statFmt(k)}));
  const lim = {hp: v => (!on('hp') || v >= fl.hp) && (!on('hpMax') || v <= fl.hpMax), sird: v => !on('sird') || v >= fl.sird, fc: v => !on('fc') || v >= fl.fc,
    ecritRed: v => !on('ecrit') || -v <= fl.ecrit, enmity: v => !on('enmity') || v >= fl.enmity, phalanx: v => !on('phalanx') || v >= fl.phalanx,
    ceLoss: v => !on('ceLoss') || v >= fl.ceLoss};
  for (const r of rows) if (lim[r.id]) r.floor = lim[r.id];
  rows.push({id: 'pdt', label: on('pdt') ? `DT+PDT ≤ ${fl.pdt}` : 'DT+PDT', get: f => f.pdt, fmt: v => String(Math.round(v)), low: true, floor: on('pdt') ? v => v <= fl.pdt : null},
    {id: 'mdt', label: on('mdt') ? `DT+MDT ≤ ${fl.mdt}` : 'DT+MDT', get: f => f.mdt, fmt: v => String(Math.round(v)), low: true, floor: on('mdt') ? v => v <= fl.mdt : null});
  // the enmity each action of the set makes with it (its Enmity counted, cap x3)
  for (const n of setActions(s).slice(0, 4)) { const [ve, ce] = ACTION_ENMITY[n];
    rows.push({id: 'act:' + n, label: t('statAct', {a: n}), get: f => ve * (1 + f.enmity / 100), fmt: v => `${Math.round(v)} VE · ${Math.round(v * ce / ve)} CE`,
      tip: t('statActTip', {a: n, ve, ce})}); }
  const pair = cureGap(s), ref = pair ? null : hpRef(s);
  if (pair && family(s.path, s.pieces) !== 'fc') rows.push({id: 'cure4', label: t('statCure4'), get: f => f.cureIV, fmt: v => String(Math.round(v)), tip: t('statCure4Tip')});
  if (ref) rows.push({id: 'ref', label: t('statRef'), get: f => f.hp - ref.hp, fmt: v => (v > 0 ? '+' : '') + Math.round(v), tip: t('statRefTip', {f: shortPath(ref.path), h: ref.hp}),
    floor: v => v >= 0 && v <= HP_SPREAD});
  if (pair) rows.push({id: 'gap', label: t('statGap'), get: f => pair.gap(f), fmt: v => String(Math.round(v)), tip: t('statGapTip', {m: shortPath(pair.mid), f: shortPath(pair.pre)})});
  const first = so.objs.map(k => rows.find(r => r.id === k)).filter(Boolean);
  // the gap (and the Cure's power) right under the objectives: it is what the pair of sets is for; Lowest HP only as an objective
  const near = rows.filter(r => (['gap', 'ref', 'cure4'].includes(r.id) || r.id.startsWith('act:')) && !first.includes(r));
  const rest = rows.filter(r => !first.includes(r) && !near.includes(r) && r.id !== 'hpLow');
  return first.concat(near, rest);
}
function statResultHTML(s){
  const now = statFigures(s), was = trialCount(s) ? statFigures(s, true) : null, rows = statRows(s), main = rows[0];
  const v = main.get(now), w = was ? main.get(was) : null, d = was ? v - w : null;
  const big = `<div class="opbig"><div><span class="muted small">${esc(main.label)}${was ? ' · ' + t('rdvTry') : ''}</span><div class="opval"><b>${main.fmt(v)}</b>` +
    (d ? `<em class="${d >= 0 ? 'up' : 'down'}">${d >= 0 ? '+' : '−'}${main.fmt(Math.abs(d))}</em>` : '') + `</div>` +
    (was ? `<span class="muted small">${t('opNow')} : ${main.fmt(w)}</span>` : '') +
    (now.shield && main.id === 'def' ? `<span class="muted small"> · DEF ${esc(t('statShield', {n: now.shield}))}</span>` : '') + `</div></div>`;
  const cell = (r, x, y) => { const a = r.get(x), b = y ? r.get(y) : null;
    const better = b != null && (r.low ? a < b - 1e-9 : a > b + 1e-9), bad = r.floor && !r.floor(a);
    return `<td class="${better ? 'better' : ''} ${bad ? 'short' : ''}">${r.fmt(a)}</td>`; };
  const shown = rows.filter((r, i) => i < 3 || r.get(now) || (was && r.get(was)) || r.floor);
  const table = `<table class="rdvs optable"><thead><tr><th></th>${was ? `<th>${t('rdvMine')}</th>` : ''}<th>${was ? t('rdvTry') : t('rdvMine')}</th></tr></thead><tbody>` +
    shown.map((r, i) => `<tr class="${i ? '' : 'obj'}"><th ${r.tip ? `title="${esc(r.tip)}"` : ''}>${esc(r.label)}${i ? '' : ' ★'}</th>${was ? cell(r, was, now) : ''}${cell(r, now, was)}</tr>`).join('') + `</tbody></table>`;
  return `<h3 class="ophd">${t('opResult')}</h3>${big}<div class="opres">${table}<div class="opside">${opChangesHTML(s)}</div></div>` +
    `${trialRow(s) || `<p class="muted small">${esc(t('opNoTry'))}</p>`}`;
}
// The toast once a search is done
function statDoneText(s, res, tr){
  const objs = statOpts(s).objs, k = objs[0], f = statFmt(k), def = res.best.def || {}, label = t('statObj_' + k);
  // the next objective too: it is what parts the sets as good on the first (Fast Cast capped: the lowest HP)
  const k2 = objs[1], now = k2 && statFigures(s), was = k2 && Object.keys(tr).length ? statFigures(s, true) : null;
  const then = !k2 || !now ? '' : ` ${t('statThenShort')} ${t('statObj_' + k2)} ${statFmt(k2)(now[k2])}` +
    (was && was[k2] !== now[k2] ? ` (${statFmt(k2)(was[k2])})` : '');
  return Object.keys(tr).length ? t('statDone', {o: label, a: f(res.start.raw), b: f(res.best.raw) + then, n: Object.keys(tr).length, p: Math.round(def.pdt || 0), m: Math.round(def.mdt || 0)})
    : t('statSame', {o: label, v: f(res.best.raw) + then});
}
