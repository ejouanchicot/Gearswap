// GearSwap Atelier · stat_help.js: what each stat does, in one plain sentence: the tooltip of a stat's row (stats.js
// statLi, cappedLi) and of a stat in a piece's card. A tooltip that only said the row's own name again taught
// nothing. Keyed like STAT_DEF (stats.js); the rows that add stats up (DT+PDT...) have their own lines.
// Only what the page itself shows is given as a figure (the -50 % cap, the +25 % of gear haste, the +50 % of Subtle Blow).

const STAT_HELP = {
  fr: {hp: 'Tes points de vie maximum.', mp: 'Tes points de magie maximum.', def: 'Ta défense : elle réduit les dégâts physiques que tu reçois.',
    dt: 'Réduit tous les dégâts reçus, physiques comme magiques. S’ajoute à PDT et à MDT.',
    pdt: 'Réduit les dégâts physiques reçus. Compté avec DT, le tout arrêté à −50 %.',
    mdt: 'Réduit les dégâts magiques reçus. Compté avec DT et Shell, le tout arrêté à −50 %.',
    pdt2: 'Une seconde réduction des dégâts physiques, qui continue après le plafond de −50 % (jusqu’à −87,5 % en tout).',
    mdt2: 'Une seconde réduction des dégâts magiques, qui continue après le plafond de −50 % (jusqu’à −87,5 % en tout).',
    bdt: 'Réduit les dégâts des souffles. Compté avec DT, le tout arrêté à −50 %.',
    eva: 'Fait rater les attaques physiques de l’ennemi.', meva: 'Aide à résister aux sorts et aux effets magiques de l’ennemi.',
    mdb: 'Réduit les dégâts des sorts que tu reçois, en plus de MDT.', block: 'Chance de bloquer une attaque avec ton bouclier.',
    sdb: 'Améliore ce que ton bouclier arrête quand il bloque.', ecrit: 'Réduit la chance que l’ennemi te porte un coup critique.',
    enmity: 'L’hostilité que tes actions créent : en plus pour un tank, en moins pour les autres.', phalanx: 'S’ajoute aux dégâts que Phalanx retire à chaque coup reçu.',
    str: 'Force : augmente tes dégâts physiques au corps à corps.', dex: 'Dextérité : aide à toucher et à porter des coups critiques.',
    vit: 'Vitalité : réduit les dégâts physiques que tu reçois.', agi: 'Agilité : aide à esquiver, et sert aux attaques à distance.',
    int: 'Intelligence : puissance et précision de la magie élémentaire.', mnd: 'Esprit : puissance des soins et précision de la magie blanche.',
    chr: 'Charisme : sert aux chants, aux familiers et à certaines weaponskills.',
    acc: 'Ta chance de toucher au corps à corps.', atk: 'Augmente les dégâts de tes coups physiques.',
    haste: 'Réduit le délai entre deux attaques. L’équipement compte jusqu’à +25 %.',
    da: 'Chance d’attaquer deux fois au lieu d’une.', ta: 'Chance d’attaquer trois fois au lieu d’une.', qa: 'Chance d’attaquer quatre fois au lieu d’une.',
    stp: 'Augmente le TP gagné à chaque coup : ta weaponskill revient plus vite.', crit: 'Ta chance de porter un coup critique.',
    critdmg: 'Augmente les dégâts de tes coups critiques.', wsd: 'Augmente les dégâts de tes weaponskills.',
    tpb: 'Compte comme du TP en plus au moment de la weaponskill.', dw: 'Avec deux armes : réduit le délai entre tes attaques.',
    sb: 'Réduit le TP que l’ennemi gagne quand tu le frappes. Compte jusqu’à +50 %.', sb2: 'Une seconde réduction du TP donné à l’ennemi, qui s’ajoute à Subtle Blow.',
    scb: 'Augmente les dégâts de tes skillchains.', pdl: 'Relève le plafond de tes dégâts physiques : utile quand ton attaque dépasse de loin la défense de la cible.',
    regain: 'Te donne du TP à chaque tick, même sans frapper.', counter: 'Chance de contre-attaquer quand l’ennemi te frappe.',
    racc: 'Ta chance de toucher à distance.', ratk: 'Augmente les dégâts de tes tirs.', fc: 'Réduit le temps d’incantation de tes sorts.',
    macc: 'La chance que tes sorts ne soient pas résistés.', mab: 'Augmente les dégâts de tes sorts.', mdmg: 'S’ajoute aux dégâts de base de tes sorts.',
    mbd: 'Augmente les dégâts d’un magic burst.', mbd2: 'Une seconde augmentation des magic bursts, qui s’ajoute à la première.',
    cure: 'Augmente les HP rendus par tes sorts de soin.', cure2: 'Une seconde augmentation des soins, qui s’ajoute à la première.',
    curecast: 'Réduit le temps d’incantation de tes Cures.', cmp: 'Chance de dépenser moins de MP en lançant un sort.',
    sird: 'Réduit la chance qu’un coup reçu interrompe ton sort.', enhdur: 'Allonge la durée de tes sorts de renfort.',
    refresh: 'Te rend des MP à chaque tick.', regen: 'Te rend des HP à chaque tick.', move: 'Te fait courir plus vite.',
    th: 'Améliore les chances de butin sur les ennemis que tu as touchés.', res: 'Aide à résister aux sorts et aux effets de cet élément.',
    pdtRow: 'Ce que tu retires vraiment d’un coup physique : DT + PDT, arrêté à −50 %.',
    mdtRow: 'Ce que tu retires vraiment d’un sort : DT + MDT (et Shell s’il est compté), arrêté à −50 %.',
    bdtRow: 'Ce que tu retires vraiment d’un souffle : DT + BDT, arrêté à −50 %.', here: 'Ici : {d}',
    physRow: 'Ce qu’il reste d’un coup physique de 1000 une fois toutes tes réductions comptées.',
    breathRow: 'Ce qu’il reste d’un souffle de 1000 une fois toutes tes réductions comptées.',
    flashRow: 'L’inimitié que Flash te donne avec ce set : celle qui reste (CE), puis celle qui retombe vite (VE).',
    hitsRow: 'Le nombre de coups qu’il te faut pour atteindre 1000 TP, d’après ton TP par coup.',
    roundRow: 'Le temps entre deux rounds d’attaque avec ce set, délai de l’arme et Haste comptés.',
    multiRow: 'Tes chances d’attaquer deux, trois ou quatre fois dans un round : Double, Triple et Quadruple Attack.',
    critRow: 'Ta chance totale de porter un coup critique avec ce set.'},
  en: {hp: 'Your maximum hit points.', mp: 'Your maximum magic points.', def: 'Your defense: it lowers the physical damage you take.',
    dt: 'Lowers all damage taken, physical and magical. Adds to PDT and to MDT.',
    pdt: 'Lowers physical damage taken. Counted with DT, the whole stopping at −50 %.',
    mdt: 'Lowers magical damage taken. Counted with DT and Shell, the whole stopping at −50 %.',
    pdt2: 'A second cut of physical damage, which goes on past the −50 % cap (down to −87.5 % in all).',
    mdt2: 'A second cut of magical damage, which goes on past the −50 % cap (down to −87.5 % in all).',
    bdt: 'Lowers breath damage. Counted with DT, the whole stopping at −50 %.',
    eva: 'Makes the enemy’s physical attacks miss.', meva: 'Helps resist the enemy’s spells and magical effects.',
    mdb: 'Lowers the damage of the spells you take, on top of MDT.', block: 'Chance to block an attack with your shield.',
    sdb: 'Improves what your shield stops when it blocks.', ecrit: 'Lowers the chance the enemy lands a critical hit on you.',
    enmity: 'The hate your actions make: more for a tank, less for the others.', phalanx: 'Adds to the damage Phalanx takes off each hit you receive.',
    str: 'Strength: raises your physical damage in melee.', dex: 'Dexterity: helps to hit and to land critical hits.',
    vit: 'Vitality: lowers the physical damage you take.', agi: 'Agility: helps to evade, and serves ranged attacks.',
    int: 'Intelligence: power and accuracy of elemental magic.', mnd: 'Mind: power of cures and accuracy of white magic.',
    chr: 'Charisma: serves songs, pets and some weaponskills.',
    acc: 'Your chance to hit in melee.', atk: 'Raises the damage of your physical hits.',
    haste: 'Shortens the delay between two attacks. Gear counts up to +25 %.',
    da: 'Chance to attack twice instead of once.', ta: 'Chance to attack three times instead of once.', qa: 'Chance to attack four times instead of once.',
    stp: 'Raises the TP gained with each hit: your weaponskill comes back sooner.', crit: 'Your chance to land a critical hit.',
    critdmg: 'Raises the damage of your critical hits.', wsd: 'Raises the damage of your weaponskills.',
    tpb: 'Counts as extra TP at the moment of the weaponskill.', dw: 'With two weapons: shortens the delay between your attacks.',
    sb: 'Lowers the TP the enemy gains when you hit it. Counts up to +50 %.', sb2: 'A second cut of the TP given to the enemy, which adds to Subtle Blow.',
    scb: 'Raises the damage of your skillchains.', pdl: 'Raises the cap of your physical damage: of use when your attack is far above the target’s defense.',
    regain: 'Gives you TP at each tick, even without hitting.', counter: 'Chance to counter when the enemy hits you.',
    racc: 'Your chance to hit at range.', ratk: 'Raises the damage of your shots.', fc: 'Shortens the casting time of your spells.',
    macc: 'The chance your spells are not resisted.', mab: 'Raises the damage of your spells.', mdmg: 'Adds to the base damage of your spells.',
    mbd: 'Raises the damage of a magic burst.', mbd2: 'A second raise of magic bursts, which adds to the first.',
    cure: 'Raises the HP your cure spells give back.', cure2: 'A second raise of cures, which adds to the first.',
    curecast: 'Shortens the casting time of your Cures.', cmp: 'Chance to spend less MP when casting a spell.',
    sird: 'Lowers the chance a hit taken interrupts your spell.', enhdur: 'Lengthens your enhancing spells.',
    refresh: 'Gives you MP back at each tick.', regen: 'Gives you HP back at each tick.', move: 'Makes you run faster.',
    th: 'Improves the odds of loot from the enemies you have hit.', res: 'Helps resist the spells and effects of this element.',
    pdtRow: 'What you really take off a physical hit: DT + PDT, stopped at −50 %.',
    mdtRow: 'What you really take off a spell: DT + MDT (and Shell when it is counted), stopped at −50 %.',
    bdtRow: 'What you really take off a breath: DT + BDT, stopped at −50 %.', here: 'Here: {d}',
    physRow: 'What is left of a physical hit of 1000 once all your cuts are counted.',
    breathRow: 'What is left of a breath of 1000 once all your cuts are counted.',
    flashRow: 'The enmity Flash gives you with this set: the one that stays (CE), then the one that drops fast (VE).',
    hitsRow: 'How many hits you need to reach 1000 TP, from your TP per hit.',
    roundRow: 'The time between two attack rounds with this set, the weapon’s delay and Haste counted.',
    multiRow: 'Your chances to attack twice, three or four times in a round: Double, Triple and Quadruple Attack.',
    critRow: 'Your total chance to land a critical hit with this set.'}};

// A row's name (as the page writes it, in either language) to its stat
let STAT_HELP_BY = null;
function statHelpIndex(){
  const by = {};
  for (const [k, def] of Object.entries(STAT_DEF)) { by[def[1]] = k; by[def[2]] = k; }
  Object.assign(by, {'Défense': 'def', Defense: 'def'});
  for (const lang of ['fr', 'en']) for (const [name, k] of [['pdtEff', 'pdtRow'], ['pdtTotal', 'pdtRow'], ['mdtEff', 'mdtRow'], ['mdtShell', 'mdtRow'], ['mdtTotal', 'mdtRow'], ['bdtEff', 'bdtRow'],
    ['physHit', 'physRow'], ['breathHit', 'breathRow'], ['flashLbl', 'flashRow'], ['hitsTo', 'hitsRow'], ['roundLbl', 'roundRow'], ['multiLbl', 'multiRow'], ['critLbl', 'critRow']])
    if (T[lang][name]) by[T[lang][name]] = k;
  return by;
}
const statHelpPlain = s => String(s).replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#39;/g, '\'').replace(/ %$/, '').trim();
// The tooltip of a stat's row: what the stat does, then (`detail`) how this set gets its figure. '' when the stat is
// not known here: no tooltip is better than one that repeats the row
function statHelp(label, detail){
  const by = STAT_HELP_BY || (STAT_HELP_BY = statHelpIndex()), H = STAT_HELP[S.lang === 'en' ? 'en' : 'fr'];
  const k = by[statHelpPlain(label)], what = k ? H[k] || (k.startsWith('res_') ? H.res : '') : '';
  // a row with its own full sentence and no stat known here (total accuracy, hit rate...): that sentence alone
  return what ? [what, detail ? H.here.replace('{d}', detail) : ''].filter(Boolean).join('\n') : detail || '';
}
