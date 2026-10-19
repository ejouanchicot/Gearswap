// GearSwap Atelier · profiles.js: what the page computes with, as profiles one switches, saves and loads fast.
// Two things, shown together:
//   the SITUATION (Full, Group, Solo, Trust): the kind of party, which decides the version of a set GearSwap wears;
//     each has its own buffs, kept as they were left (buffs.js);
//   the player's PROFILES: a whole state under a name (the party and its buffs, the debuffs on the target, the
//     target, the food, the abilities, the situation it was saved in). One click loads it, one click saves the
//     changes made since, a new one is named on the spot.
// They are drawn by the Svelte application (atelier/src/screens/profiles): the full bar of the "Buffs & target" tab,
// and its short form in the line over the sets, so that a profile is changed without leaving the set looked at.
// A player may keep a hundred profiles: they are not laid in a row. One button says the profile in use and opens a
// picker (search, the situations as a filter, favourites first, then this job's, then the others, the last used on
// top); the favourites alone are quick buttons beside it.
//
// S.pbPresets[char][name] = the state (every key of buffState(), and about the profile itself: `_tier` the
// situation, `_job` the job it was saved on, `_at` when, `_used` when it was last loaded, `_fav`); the saved buffs of
// before 2026-10-11 held the party only and keep working. S.pbActive[char] = the profile loaded last.
// Kept in the browser and, with the list of sets' arrangement, in <Char>/atelier/overrides/list_layout.js.

Object.assign(T.fr, {prSit: 'Situation', prMine: 'Mes profils', prNone: 'Aucun profil enregistré : règle tes buffs et ta cible, puis « + Enregistrer ».',
  prNew: '+ Enregistrer', prNewAs: '+ Nouveau profil', prNewTip: 'Garde tout ce qui est réglé ici (groupe, buffs, debuffs, cible, nourriture, abilities, situation) sous un nom.',
  prName: 'Nom du profil, puis Entrée', prLoad: 'Charger « {n} » : {d}', prUpdate: 'Enregistrer les changements dans « {n} »', prRename: 'Renommer', prDelete: 'Supprimer ce profil',
  prDeleteAsk: 'Supprimer le profil « {n} » ?', prMod: 'modifié', prModTip: 'Tu as changé quelque chose depuis le chargement de « {n} ». Le bouton ⟳ l’enregistre dedans.',
  prSaved: 'Profil « {n} » enregistré.', prLoaded: 'Profil « {n} » chargé.', prPick: 'Profil…', prPickTip: 'Charger un de tes profils enregistrés sans quitter cette page.',
  prSum: '{n} buff(s) · {e}', prSumNone: 'aucun buff · {e}',
  prWhat_Full: 'COR + BRD + GEO, RDM, WHM', prWhat_Group: 'BRD + COR + RDM', prWhat_Solo: 'toi et un RDM', prWhat_Trust: 'toi et tes Trusts',
  prChoose: 'Choisir un profil…', prOpenTip: 'Tes profils enregistrés ({n}) : cherche, filtre, charge d’un clic.', prSearch: 'Chercher un profil…', prAllTiers: 'Tous',
  prFavs: 'Favoris', prThisJob: 'Ce job ({j})', prOthers: 'Autres jobs', prOld: 'Sans job', prNoMatch: 'Aucun profil ne correspond.',
  prFav: 'Mettre en favori : il aura son bouton à côté du menu', prUnfav: 'Retirer des favoris', prCount: '{n} profil(s)', prShort: 'Profil'});
Object.assign(T.en, {prSit: 'Situation', prMine: 'My profiles', prNone: 'No profile saved: set your buffs and your target, then "+ Save".',
  prNew: '+ Save', prNewAs: '+ New profile', prNewTip: 'Keeps everything set here (party, buffs, debuffs, target, food, abilities, situation) under a name.',
  prName: 'Profile name, then Enter', prLoad: 'Load "{n}": {d}', prUpdate: 'Save the changes into "{n}"', prRename: 'Rename', prDelete: 'Delete this profile',
  prDeleteAsk: 'Delete the profile "{n}"?', prMod: 'changed', prModTip: 'You changed something since "{n}" was loaded. The ⟳ button saves it into it.',
  prSaved: 'Profile "{n}" saved.', prLoaded: 'Profile "{n}" loaded.', prPick: 'Profile…', prPickTip: 'Load one of your saved profiles without leaving this page.',
  prSum: '{n} buff(s) · {e}', prSumNone: 'no buff · {e}',
  prWhat_Full: 'COR + BRD + GEO, RDM, WHM', prWhat_Group: 'BRD + COR + RDM', prWhat_Solo: 'you and a RDM', prWhat_Trust: 'you and your Trusts',
  prChoose: 'Choose a profile…', prOpenTip: 'Your saved profiles ({n}): search, filter, load in one click.', prSearch: 'Find a profile…', prAllTiers: 'All',
  prFavs: 'Favourites', prThisJob: 'This job ({j})', prOthers: 'Other jobs', prOld: 'No job', prNoMatch: 'No profile matches.',
  prFav: 'Make it a favourite: it gets its button beside the menu', prUnfav: 'Take out of the favourites', prCount: '{n} profile(s)', prShort: 'Profile'});

/* ---- the profiles ---- */
const profAll = () => { S.pbPresets = S.pbPresets || {}; return S.pbPresets[S.char] = S.pbPresets[S.char] || {}; };
const profActive = () => { const n = (S.pbActive || {})[S.char]; return n && profAll()[n] ? n : null; };
// the state as a profile keeps it: every choice (not what the page works out on the way, the `_` keys)
function profSnapshot(){
  const b = buffState(), out = {_tier: buffTier(), _job: S.job};
  for (const k of Object.keys(b)) if (!k.startsWith('_') && b[k] != null) out[k] = JSON.parse(JSON.stringify(b[k]));
  return out;
}
// two states hold the same choices (what a profile says about itself, its `_job`, `_at`, `_used`, `_fav`, is not a choice)
const PROF_META = ['_job', '_at', '_used', '_fav'];
const profChoices = a => JSON.stringify(Object.keys(a).filter(k => !PROF_META.includes(k)).sort().map(k => [k, a[k]]));
const profSame = (a, b) => profChoices(a) === profChoices(b);
// the profile loaded last no longer says what the page computes with
const profChanged = name => { const p = profAll()[name]; return !!p && p._tier !== undefined && !profSame(p, profSnapshot()); };
function profTouch(){ S.listPrefs = S.listPrefs || {}; (S.listPrefs[S.char] = S.listPrefs[S.char] || {at: '', jobs: {}}).at = new Date().toISOString(); save(); listSaveSoon(); }
function profSave(name){
  name = String(name || '').trim().slice(0, 40);
  if (!name) return;
  const was = profAll()[name] || {}, now = new Date().toISOString();
  profAll()[name] = Object.assign(profSnapshot(), {_at: now, _used: now}, was._fav ? {_fav: true} : {});
  S.pbActive = Object.assign({}, S.pbActive, {[S.char]: name});
  S.toast = t('prSaved', {n: name}); profTouch();
}
function profLoad(name){
  const p = profAll()[name];
  if (!p) return;
  if (p._tier && p._tier !== buffTier()) setBuffTier(p._tier);
  const b = buffState();
  // a profile of before held the party only: what it does not name stays
  if (p._tier !== undefined) for (const k of Object.keys(b)) if (!k.startsWith('_') && !(k in p)) delete b[k];
  for (const k of Object.keys(p)) if (!k.startsWith('_')) b[k] = JSON.parse(JSON.stringify(p[k]));
  p._used = new Date().toISOString();
  S.pbActive = Object.assign({}, S.pbActive, {[S.char]: name});
  S._globals = null; S._profOpen = false; S.toast = t('prLoaded', {n: name}); profTouch();
}
function profRename(from, to){
  to = String(to || '').trim().slice(0, 40);
  const all = profAll();
  if (!to || to === from || !all[from]) return;
  // the order of the profiles is the order they were made in: the new name takes the old one's place
  const next = {};
  for (const k of Object.keys(all)) next[k === from ? to : k] = all[k];
  S.pbPresets[S.char] = next;
  if ((S.pbActive || {})[S.char] === from) S.pbActive[S.char] = to;
  profTouch();
}
function profFav(name){ const p = profAll()[name]; if (!p) return; if (p._fav) delete p._fav; else p._fav = true; profTouch(); }
function profDelete(name){ delete profAll()[name]; if ((S.pbActive || {})[S.char] === name) delete S.pbActive[S.char]; profTouch(); }

/* ---- what a situation or a profile holds, in a few words ---- */
const PROF_COUNT = ['food', 'protect', 'shell', 'haste', 'storm', 'song0', 'song1', 'song2', 'song3', 'song4', 'roll0', 'roll1', 'indi', 'geo', 'entrust', 'dia', 'distract'];
function profSummary(b){
  if (!b) return '';
  const n = PROF_COUNT.filter(k => b[k]).length + Object.values(b.ja || {}).filter(Boolean).length + (b.foeJa || []).length + (b.am ? 1 : 0);
  let enemy = ''; try { enemy = enemyKey(b.enemy); } catch (e) { enemy = b.enemy || ''; }
  return t(n ? 'prSum' : 'prSumNone', {n, e: enemy});
}

/* ---- the bar ---- */
// the favourites that get a quick button beside the picker (atelier/src/screens/profiles/profiles.ts)
const PROF_FAVS = 6;

/* ---- clicks, names typed ---- */
function profFocus(){ setTimeout(() => { const el = document.querySelector('input[data-profname]'); if (el) { el.focus(); el.select(); } }, 0); }
document.addEventListener('click', e => {
  const b = e.target.closest && e.target.closest('button'), d = b ? b.dataset : {};
  // a click outside the picker closes it
  if (S._profOpen && !(e.target.closest && e.target.closest('.prpickwrap'))) { S._profOpen = false; S._profEdit = null; render(); }
  if (!b) return;
  if (d.profopen) { S._profOpen = S._profOpen === d.profopen ? false : d.profopen; render(); if (S._profOpen) setTimeout(() => { const q = document.getElementById('profq'); if (q) q.focus(); }, 0); return; }
  // the search and the situation filter: the picker hides its rows from them (atelier/src/screens/profiles/profiles.ts)
  if (d.proftier != null && b.closest('.prtiers')) { S._profTier = d.proftier; return render(); }
  if (d.proffav) { profFav(d.proffav); return render(); }
  if (d.profload) { profLoad(d.profload); return render(); }
  if (d.profupdate) { profSave(d.profupdate); return render(); }
  if (d.profedit) { S._profEdit = d.profedit; render(); return profFocus(); }
  if (d.profdel) { if (confirm(t('prDeleteAsk', {n: d.profdel}))) { profDelete(d.profdel); render(); } return; }
});
document.addEventListener('input', e => {
  if (e.target && e.target.id === 'profq') { S._profQ = e.target.value; render(); }
});
document.addEventListener('keydown', e => {
  const el = e.target;
  if (!el || !el.dataset || !el.dataset.profname) return;
  if (e.key === 'Enter') { e.preventDefault(); e.stopPropagation(); const what = el.dataset.profname; S._profEdit = null;
    if (what === 'new') profSave(el.value); else profRename(what.slice(7), el.value);
    render(); }
  else if (e.key === 'Escape') { e.preventDefault(); e.stopPropagation(); S._profEdit = null; render(); }
  else e.stopPropagation();
}, true);
