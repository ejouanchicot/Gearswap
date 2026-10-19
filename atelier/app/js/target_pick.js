// GearSwap Atelier · target_pick.js: the target, as a monster's card and a picker one enjoys using.
// The card (the "Buffs & target" tab): who it is, your chance to hit it with the set opened, its Defense and Evasion
// as gauges that show what the debuffs take off, its VIT and HP, what it resists.
// The picker: every monster as a card in a grid, by zone; a search, the zones as a filter, favourites and the last
// ones chosen on top. A monster's levels are buttons on its card, each in the colour of your chance to hit it at
// that level with the set opened (green, amber, red): the difficulty is read before choosing.
// The data: atelier/targets.js (TARGETS). S.tgtFav[char] the favourites, S.tgtRecent[char] the last chosen.

Object.assign(T.fr, {tgChange: 'Changer de cible', tgHit: 'Tu la touches', tgHitTip: 'Ta précision avec le set ouvert ({a}) contre son évasion une fois les debuffs comptés ({e}). Plafond {c} %.',
  tgNoAcc: 'ouvre un set Engaged pour voir ton taux de toucher', tgDefTip: 'Sa défense : {a} au départ, {b} une fois Dia, Frailty et les autres debuffs comptés. Plus elle est basse, plus tu frappes fort.',
  tgEvaTip: 'Son évasion : {a} au départ, {b} une fois Distract et les autres debuffs comptés. Plus elle est basse, plus tu touches.',
  tgRes: 'Résistances', tgNoRes: 'aucune résistance connue', tgEst: 'Estimé : {l}. Ces chiffres ne sont pas mesurés.', tgRef: 'Une cible de référence, pas un monstre : les valeurs qu’utilisent les guides.',
  tgAllZones: 'Toutes', tgFavs: 'Favoris', tgRecent: 'Récents', tgFav: 'Mettre en favori', tgUnfav: 'Retirer des favoris', tgNone: 'Aucun monstre ne correspond.',
  tgLvTip: '{k} : Déf {d} · Éva {e}{h}', tgLvHit: ' · tu la touches à {p} %', tgSort: 'Trier', tgSort_zone: 'par zone', tgSort_lv: 'par niveau', tgSort_hit: 'du plus facile au plus dur',
  tgRes_slash: 'Tranchant', tgRes_pierce: 'Perçant', tgRes_blunt: 'Contondant', tgRes_ranged: 'Distance', tgRes_magic: 'Magie', tgRes_breath: 'Souffle', tgCount: '{n} monstre(s), {z} zone(s)'});
Object.assign(T.en, {tgChange: 'Change target', tgHit: 'You hit it', tgHitTip: 'Your accuracy with the set opened ({a}) against its evasion once the debuffs are counted ({e}). Cap {c} %.',
  tgNoAcc: 'open an Engaged set to see your hit rate', tgDefTip: 'Its defense: {a} at first, {b} once Dia, Frailty and the other debuffs are counted. The lower, the harder you hit.',
  tgEvaTip: 'Its evasion: {a} at first, {b} once Distract and the other debuffs are counted. The lower, the more you hit.',
  tgRes: 'Resistances', tgNoRes: 'no known resistance', tgEst: 'Estimated: {l}. These figures are not measured.', tgRef: 'A reference target, not a monster: the values the guides use.',
  tgAllZones: 'All', tgFavs: 'Favourites', tgRecent: 'Recent', tgFav: 'Make it a favourite', tgUnfav: 'Take out of the favourites', tgNone: 'No monster matches.',
  tgLvTip: '{k}: Def {d} · Eva {e}{h}', tgLvHit: ' · you hit it {p} % of the time', tgSort: 'Sort', tgSort_zone: 'by zone', tgSort_lv: 'by level', tgSort_hit: 'easiest first',
  tgRes_slash: 'Slashing', tgRes_pierce: 'Piercing', tgRes_blunt: 'Blunt', tgRes_ranged: 'Ranged', tgRes_magic: 'Magic', tgRes_breath: 'Breath', tgCount: '{n} monster(s), {z} zone(s)'});

/* ---- your chance to hit, with the set opened ---- */
// {acc, cap, down}: the set's accuracy, the cap of its weapon (95 % two-handed, 99 %), the Evasion the debuffs take
// off; null when the page cannot tell (no set opened, no stats measured)
function tgYou(){
  try { const s = S._curSet, r = s && charStats(s);
    if (!r || !r.cur || r.cur.acc == null) return null;
    return {acc: r.cur.acc, cap: r.cur.wskill && TWO_HANDED.test(r.cur.wskill) ? 95 : 99, down: (r.B && r.B.eeva) || 0};
  } catch (e) { return null; }
}
const tgRate = (you, eva) => you ? Math.floor(Math.max(20, Math.min(you.cap, 75 + 0.5 * (you.acc - Math.max(0, eva - you.down))))) : null;
const tgTone = p => p == null ? '' : p >= 90 ? 'easy' : p >= 70 ? 'mid' : 'hard';

/* ---- the card: drawn by atelier/src/screens/combat/targetcard.ts (tgYou, tgRate and tgTone above are its) ---- */

/* ---- the picker ---- */
const tgFavs = () => { S.tgtFav = S.tgtFav || {}; return S.tgtFav[S.char] = S.tgtFav[S.char] || []; };
const tgRecents = () => { S.tgtRecent = S.tgtRecent || {}; return S.tgtRecent[S.char] = S.tgtRecent[S.char] || []; };
// the monsters, one a name and a zone, with their levels
function tgMonsters(){
  const out = new Map();
  for (const x of Object.values(TARGETS)) { if (x.key === DEFAULT_ENEMY) continue;
    const id = x.zone + '|' + x.name;
    if (!out.has(id)) out.set(id, {id, name: x.name, zone: x.zone, job: x.job, est: x.est || [], levels: []});
    out.get(id).levels.push(x); }
  return [...out.values()];
}
// The picker: drawn by the Svelte application (atelier/src/screens/dialogs/target.ts), its search, zone and order from
// S._tgtQ, S._tgtZone, S._tgtSort; typing and a zone draw it again in place
function openTargetPick(){
  S._tgtPick = true;
  ATELIER_DIALOG.show({cls: 'tgdlg', titleHtml: '', target: ATELIER_DIALOG.targetView()});
  const q = $('#tgq'); if (q) q.focus();
}
const tgRedraw = () => ATELIER_DIALOG.update({cls: 'tgdlg', titleHtml: '', target: ATELIER_DIALOG.targetView()});
document.addEventListener('click', e => {
  const b = e.target.closest && e.target.closest('button'), d = b ? b.dataset : {};
  if (!b || !b.closest('.tgdlg')) return;
  if (d.tgtgo != null) { const st = buffState(); if (d.tgtgo) st.enemy = d.tgtgo; else delete st.enemy;
    if (d.tgtgo) { const r = tgRecents(); S.tgtRecent[S.char] = [d.tgtgo].concat(r.filter(k => k !== d.tgtgo)).slice(0, 12); }
    S._tgtPick = false; S._globals = null; save(); closeOverlay(); return render(); }
  if (d.tgtfav) { const f = tgFavs(), i = f.indexOf(d.tgtfav); if (i < 0) f.push(d.tgtfav); else f.splice(i, 1); save(); return openTargetPick(); }
  if (d.tgtzone != null) { S._tgtZone = d.tgtzone; return tgRedraw(); }
});
document.addEventListener('input', e => { if (e.target && e.target.id === 'tgq') { S._tgtQ = e.target.value; tgRedraw(); } });
document.addEventListener('change', e => { if (e.target && e.target.dataset && 'tgtsort' in e.target.dataset) { S._tgtSort = e.target.value; openTargetPick(); } });
