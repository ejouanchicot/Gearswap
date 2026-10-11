// GearSwap Atelier · guide_context.js: what the moogle says about the page AS IT IS NOW.
// The help of a page (guide.js guideHelp) starts with these lines: read from the state, not written in advance.
// The set opened lacks a piece, pieces are on trial, the game plays another subjob than the page shows, another
// engine answered for this set... each with what to do about it, and "Show me" when an element of the page is the
// answer. A line marked `warn` puts a dot on the moogle's button: something deserves a look.
//
//   guideContext(page) -> [{text, sel (the element "Show me" lights), warn}], the most useful first
//
// Texts in both languages here (they hold figures and names of the moment); nothing is said that the page does
// not know for sure.

Object.assign(T.fr, {gcNow: 'En ce moment', gcShow: 'Montre-moi', gcTips: 'À savoir',
  gcSub: 'En jeu tu es {g}, mais la page calcule en {p} : stats, traits et sets ne sont pas ceux que tu joues. Le bouton en haut de la page passe sur ton sub du jeu.',
  gcMiss: 'Il te manque {n} pièce(s) de ce set dans tes sacs : {l}. Le set ne les portera pas en jeu.',
  gcPorter: '{n} pièce(s) de ce set sont chez le Porter Moogle : {l}.',
  gcTrial: 'Tu as {n} pièce(s) à l’essai dans ce set. Rien n’est écrit : compare, teste en jeu, puis « Pousser » l’écrit dans ton fichier (avec retour en arrière).',
  gcEmpty: 'Ce set est écrit mais vide. Clique une case pour y mettre une pièce, ou laisse-moi le remplir avec « Optimiser ce set ».',
  gcBase: 'Ce set reprend {b} et n’y change que {n} pièce(s) : les cases grisées viennent du set repris.',
  gcVers: 'Ce set existe en {n} versions ({l}). Tu regardes {v} : c’est celle que GearSwap porte avec ce type de groupe.',
  gcHidden: '{n} set(s) ne sont pas listés : ils servent à un autre sub que {s}. Le compte et le lien pour les revoir sont en bas de la liste.',
  gcFell: 'Pour ce que tu regardes, c’est wsdist qui calcule et pas le moteur de l’Atelier ({w}). Les chiffres peuvent différer un peu des autres sets.',
  gcOld: 'Tu calcules avec wsdist : il ne compte que ses propres options (pas le Warcry d’un allié, ni les résistances de la cible, ni tes stats mesurées en jeu).',
  gcOffline: 'Le jeu n’est pas connecté : tu peux tout essayer et comparer, mais « Équiper en jeu » et « Simuler » attendent qu’il le soit.',
  gcPin: 'Astuce : passe la souris sur un set que tu ouvres souvent et clique l’étoile. Il restera tout en haut de la liste.',
  gcOpt: 'Ce set peut être optimisé : je cherche dans tes sacs la meilleure combinaison pour ce qu’il doit faire.',
  gcOptWith: 'Je vais chercher avec les buffs « {t} » contre {e}. Si ce n’est pas ton combat, change-les dans l’onglet Combat avant de lancer.',
  gcOptLocks: '{n} case(s) sont verrouillées : je n’y toucherai pas.', gcOptExcl: '{n} pièce(s) sont écartées de mes recherches (tu peux les remettre dans la liste des pièces écartées).',
  gcOptNoGame: 'Le jeu n’est pas connecté : je cherche dans les sacs du dernier export, pas dans ce que tu as ramassé depuis.'});
Object.assign(T.en, {gcNow: 'Right now', gcShow: 'Show me', gcTips: 'Good to know',
  gcSub: 'In game you are {g}, but the page computes as {p}: stats, traits and sets are not the ones you play. The button at the top of the page switches to your game subjob.',
  gcMiss: '{n} piece(s) of this set are not in your bags: {l}. The set will not wear them in game.',
  gcPorter: '{n} piece(s) of this set are at the Porter Moogle: {l}.',
  gcTrial: 'You have {n} piece(s) on trial in this set. Nothing is written: compare, test in game, then "Push" writes it to your file (with a way back).',
  gcEmpty: 'This set is written but empty. Click a cell to put a piece in it, or let me fill it with "Optimize this set".',
  gcBase: 'This set takes {b} and changes only {n} piece(s) of it: the greyed cells come from the set it takes.',
  gcVers: 'This set has {n} versions ({l}). You are looking at {v}: the one GearSwap wears with that kind of party.',
  gcHidden: '{n} set(s) are not listed: they serve another subjob than {s}. Their count and the link to see them again are at the bottom of the list.',
  gcFell: 'For what you are looking at, wsdist computes and not the Atelier’s engine ({w}). The figures may differ a little from the other sets.',
  gcOld: 'You compute with wsdist: it counts its own options only (not an ally’s Warcry, nor the target’s resistances, nor your stats measured in game).',
  gcOffline: 'The game is not connected: you can try and compare everything, but "Equip in game" and "Simulate" wait for it.',
  gcPin: 'Tip: hover a set you open often and click the star. It will stay at the very top of the list.',
  gcOpt: 'This set can be optimized: I look in your bags for the best combination for what it must do.',
  gcOptWith: 'I will search with the "{t}" buffs against {e}. If that is not your fight, change them in the Combat tab before starting.',
  gcOptLocks: '{n} cell(s) are locked: I will not touch them.', gcOptExcl: '{n} piece(s) are kept out of my searches (you can put them back in the list of excluded pieces).',
  gcOptNoGame: 'The game is not connected: I search the bags of the last export, not what you picked up since.'});

// The set shown and its card, or null on a page without one
function gcSet(){
  const cards = S._cards || [], i = (S.sel || {})[S.job], card = cards[i];
  return card && S._curSet ? {card, i, s: S._curSet} : null;
}
const gcList = (names, max = 4) => names.slice(0, max).join(', ') + (names.length > max ? '…' : '');
const gcLive = () => { try { return liveOk(S.char); } catch (e) { return false; } };

// Each rule answers one line or nothing; a rule that throws says nothing (the help must always open)
const GC_RULES = {
  sets: [
    () => { const L = (S._live || {})[S.char], d = data();
      return L && L.ok && L.job === S.job && d && L.sub && L.sub !== 'NONE' && L.sub !== d.sub ? {text: t('gcSub', {g: L.job + '/' + L.sub, p: S.job + '/' + d.sub}), sel: '.ctxbar .subwarn', warn: true} : null; },
    () => { const c = gcSet(); if (!c) return null;
      const eff = withWeapons(c.s).pieces, miss = [], porter = [];
      for (const slot of SLOTS) { const st = eff[slot] && holdState(slot, eff[slot]); if (st === 'missing' && !miss.includes(eff[slot].name)) miss.push(eff[slot].name); if (st === 'porter' && !porter.includes(eff[slot].name)) porter.push(eff[slot].name); }
      return miss.length ? {text: t('gcMiss', {n: miss.length, l: gcList(miss)}), sel: '.detail .slots', warn: true} : porter.length ? {text: t('gcPorter', {n: porter.length, l: gcList(porter)}), sel: '.detail .slots'} : null; },
    () => { const c = gcSet(), n = c ? trialCount(c.s) : 0; return n ? {text: t('gcTrial', {n}), sel: '.detail .trybar'} : null; },
    () => { const c = gcSet(); return c && !Object.keys(c.s.pieces || {}).length && !trialCount(c.s) ? {text: t('gcEmpty'), sel: '.detail .slots'} : null; },
    () => { const e = window.FFXI && FFXI.engine, fell = e && e.name === 'own' ? Object.keys(e.fell || {}) : [];
      return fell.length ? {text: t('gcFell', {w: gcList(fell, 2)})} : e && e.name === 'old' ? {text: t('gcOld')} : null; },
    () => { const c = gcSet(); if (!c) return null;
      const groups = [...variantGroups(c.card).groups.values()], vi = Math.min(S.variant[S.job + '|' + c.i] ?? 0, c.card.variants.length - 1);
      const cur = groups.find(g => g.main === vi || g.subs.some(x => x.i === vi));
      if (!cur || !cur.subs.length || !document.querySelector('.setvers .verseg')) return null;
      const names = (cur.main != null ? ['Full'] : []).concat(cur.subs.map(x => x.label)), shown = vi === cur.main ? 'Full' : (cur.subs.find(x => x.i === vi) || {}).label;
      return cur.subs.every(x => TIER_LABELS.includes(x.label)) ? {text: t('gcVers', {n: names.length, l: names.join(', '), v: shown || names[0]}), sel: '.setvers .verseg'} : null; },
    () => { const c = gcSet(); if (!c || !c.s.base) return null;
      const own = new Set(c.s.own || Object.keys(c.s.pieces)), n = [...own].filter(x => c.s.pieces[x]).length;
      return {text: t('gcBase', {b: shortPath(c.s.base), n}), sel: '.detail .slots'}; },
    () => { const n = (S._cards || []).reduce((m, c) => m + (cardUsable(c) ? 0 : c.variants.length), 0);
      return n && !S._listAll ? {text: t('gcHidden', {n, s: S.job + '/' + ((data() || {}).sub || '?')}), sel: '.setlist .acchid'} : null; },
    () => gcLive() ? null : {text: t('gcOffline'), sel: '#top [data-livejump]'},
    () => document.querySelector('.detail [data-optview]') ? {text: t('gcOpt'), sel: '.detail [data-optview]'} : null,
    () => listPrefs().pins.length || listPrefs().groups.length ? null : {text: t('gcPin'), sel: '.setlist .scroll'}],
  opt: [
    () => ({text: t('gcOptWith', {t: buffTier(), e: enemyKey(buffState().enemy)}), sel: '.ctxbar, .oppage .opwhere'}),
    () => { const c = gcSet(), n = c ? lockedSlots(c.s).length : 0; return n ? {text: t('gcOptLocks', {n})} : null; },
    () => { const n = Object.keys(excludedOf() || {}).length; return n ? {text: t('gcOptExcl', {n})} : null; },
    () => { const e = window.FFXI && FFXI.engine; return e && e.name === 'old' ? {text: t('gcOld')} : null; },
    () => gcLive() ? null : {text: t('gcOptNoGame')}]};
// The lines of a page, the ones that ask for a look first; five at most (a help that says everything says nothing)
function guideContext(page){
  const out = [];
  for (const rule of GC_RULES[page] || []) { let got = null; try { got = rule(); } catch (e) { got = null; }
    if (got && got.text) out.push(got); }
  return out.sort((a, b) => !!b.warn - !!a.warn).slice(0, 5);
}
