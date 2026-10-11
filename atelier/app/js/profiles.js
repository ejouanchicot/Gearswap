// GearSwap Atelier · profiles.js: what the page computes with, as profiles one switches, saves and loads fast.
// Two things, shown together:
//   the SITUATION (Full, Group, Solo, Trust): the kind of party, which decides the version of a set GearSwap wears;
//     each has its own buffs, kept as they were left (buffs.js);
//   the player's PROFILES: a whole state under a name (the party and its buffs, the debuffs on the target, the
//     target, the food, the abilities, the situation it was saved in). One click loads it, one click saves the
//     changes made since, a new one is named on the spot.
// profBar() is the full bar of the "Buffs & target" tab; profCompact() its short form in the line over the sets, so
// that a profile is changed without leaving the set looked at.
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
function profSituationsHTML(big){
  const cur = buffTier();
  return TIERS.map(x => { let sum = '', party = '';
    try { const st = x === cur ? buffState() : tierBuffsOf(x); sum = profSummary(st);
      // who is in it: you, then the members its buffs come from (a job has one card: party_builder.js pbShown)
      // an emblem takes the colour of its job's role (tank, healer, support, damage)
      const role = j => ROLE_COLOR[(JOBS.find(x => x[0] === j) || [])[2]] || 'var(--accent)';
      party = [S.job].concat(pbShown(st)).map(j => `<span class="prem" title="${esc(j)}" style="--role:${role(j)}">${emblem(j)}</span>`).join(''); } catch (e) {}
    return `<button class="prsit ${big ? 'big' : ''}" data-bufftier="${x}" aria-pressed="${x === cur}" title="${esc(t('tier' + x + 'Tip'))}"><b>${x}</b>` +
      (big ? `<span class="prparty">${party}</span><small>${esc(t('prWhat_' + x))}</small>${sum ? `<i>${esc(sum)}</i>` : ''}` : '') + `</button>`; }).join('');
}
// The picker: every profile, found fast. Favourites first, then this job's, then the others; in each, the last used
// on top. The search and the situation filter hide rows in place (no redraw while typing).
const PROF_FAVS = 6;
const profSorted = names => names.slice().sort((a, b) => String(profAll()[b]._used || profAll()[b]._at || '').localeCompare(String(profAll()[a]._used || profAll()[a]._at || '')) || a.localeCompare(b));
function profRowHTML(n){
  const p = profAll()[n], on = n === profActive();
  if (S._profEdit === 'rename:' + n) return `<div class="prrow2 edit"><input class="listname prname" data-profname="rename:${esc(n)}" value="${esc(n)}" placeholder="${esc(t('prName'))}" maxlength="40" autocomplete="off" spellcheck="false"></div>`;
  return `<div class="prrow2 ${on ? 'on' : ''}" data-q="${esc((n + ' ' + (p._job || '') + ' ' + (p._tier || '')).toLowerCase())}" data-tier="${esc(p._tier || '')}">` +
    `<button class="ract prstar" data-proffav="${esc(n)}" aria-pressed="${!!p._fav}" title="${esc(t(p._fav ? 'prUnfav' : 'prFav'))}">${p._fav ? '★' : '☆'}</button>` +
    `<button class="prgo" data-profload="${esc(n)}" title="${esc(t('prLoad', {n, d: (p._tier ? p._tier + ' · ' : '') + profSummary(p)}))}"><b>${esc(n)}</b>` +
    `<small>${esc([p._job, p._tier].filter(Boolean).join(' · '))}</small><i>${esc(profSummary(p))}</i></button>` +
    `<span class="practs"><button class="ract" data-profedit="rename:${esc(n)}" title="${esc(t('prRename'))}">✎</button><button class="ract" data-profdel="${esc(n)}" title="${esc(t('prDelete'))}">×</button></span></div>`;
}
function profPanelHTML(){
  const all = profAll(), names = Object.keys(all);
  const favs = profSorted(names.filter(n => all[n]._fav)), rest = names.filter(n => !all[n]._fav);
  const mine = profSorted(rest.filter(n => all[n]._job === S.job)), others = profSorted(rest.filter(n => all[n]._job && all[n]._job !== S.job)), old = profSorted(rest.filter(n => !all[n]._job));
  const sec = (label, list) => list.length ? `<div class="prsec"><h5>${esc(label)}<span>${list.length}</span></h5>${list.map(profRowHTML).join('')}</div>` : '';
  const tiers = ['', ...TIERS].map(x => `<button data-proftier="${x}" aria-pressed="${(S._profTier || '') === x}">${esc(x || t('prAllTiers'))}</button>`).join('');
  return `<div class="prpanel" role="dialog"><div class="prtools"><input id="profq" class="prq" type="search" placeholder="${esc(t('prSearch'))}" value="${esc(S._profQ || '')}" autocomplete="off" spellcheck="false">` +
    `<div class="seg prtiers" role="group">${tiers}</div></div><div class="prlist">${sec(t('prFavs'), favs)}${sec(t('prThisJob', {j: S.job}), mine)}${sec(t('prOthers'), others)}${sec(t('prOld'), old)}` +
    `<p class="muted small prnomatch" hidden>${esc(t('prNoMatch'))}</p></div><div class="prfoot muted small">${esc(t('prCount', {n: names.length}))}</div></div>`;
}
// the rows the search and the situation leave: hidden in place, a section with none left too
function profFilter(){
  const panel = document.querySelector('.prpanel');
  if (!panel) return;
  const q = (S._profQ || '').trim().toLowerCase(), tier = S._profTier || '';
  let left = 0;
  panel.querySelectorAll('.prrow2[data-q]').forEach(r => { const ok = (!q || r.dataset.q.includes(q)) && (!tier || r.dataset.tier === tier); r.hidden = !ok; if (ok) left++; });
  panel.querySelectorAll('.prsec').forEach(sec => { sec.hidden = !sec.querySelector('.prrow2:not([hidden])'); });
  const none = panel.querySelector('.prnomatch'); if (none) none.hidden = left > 0;
}
// The button that says the profile in use and opens the picker, what to do when it was changed, a new one, then the
// favourites as quick buttons
function profPickerHTML(compact){
  const all = profAll(), names = Object.keys(all), on = profActive(), mod = on ? profChanged(on) : false;
  const open = S._profOpen === (compact ? 'compact' : 'full');
  const btn = `<button class="prpickbtn ${on ? 'set' : ''} ${mod ? 'mod' : ''}" data-profopen="${compact ? 'compact' : 'full'}" aria-expanded="${open}" title="${esc(t('prOpenTip', {n: names.length}))}">` +
    `<span>${esc(on || t(compact ? 'prShort' : 'prChoose'))}</span>${on && mod ? `<em>${esc(t('prMod'))}</em>` : ''}<i>▾</i></button>`;
  const update = on && mod ? `<button class="btn prupd" data-profupdate="${esc(on)}" title="${esc(t('prUpdate', {n: on}))}">⟳${compact ? '' : ' ' + esc(t('prUpdate', {n: on}))}</button>` : '';
  if (compact) return `<span class="prpickwrap">${btn}${open ? profPanelHTML() : ''}</span>${update}`;
  const add = S._profEdit === 'new' ? `<input class="listname prname" data-profname="new" placeholder="${esc(t('prName'))}" maxlength="40" autocomplete="off" spellcheck="false">`
    : `<button class="btn ${on && mod ? 'ghost' : ''} prnew" data-profedit="new" title="${esc(t('prNewTip'))}">${esc(t(on ? 'prNewAs' : 'prNew'))}</button>`;
  const favs = profSorted(names.filter(n => all[n]._fav)).slice(0, PROF_FAVS).map(n => `<button class="chip prfav ${n === on ? 'on' : ''}" data-profload="${esc(n)}" ` +
    `title="${esc(t('prLoad', {n, d: (all[n]._tier ? all[n]._tier + ' · ' : '') + profSummary(all[n])}))}">★ ${esc(n)}</button>`).join('');
  return `<span class="prpickwrap">${btn}${open ? profPanelHTML() : ''}</span>${update}${add}${favs ? `<span class="prfavs">${favs}</span>` : ''}` +
    (names.length ? '' : `<span class="muted small prnone">${esc(t('prNone'))}</span>`);
}
// The "Buffs & target" tab: the player's profiles in a bar of their own; the four situations are the tabs of the
// party's box (profSituationTabs: a situation IS a party, its members are the tabs under it)
function profBar(){
  return `<section class="profbar"><div class="prrow"><span class="kicker">${esc(t('prMine'))}</span><div class="prchips">${profPickerHTML(false)}</div></div></section>`;
}
const profSituationTabs = () => `<div class="prsits sittabs" role="tablist" aria-label="${esc(t('prSit'))}">${profSituationsHTML(true)}</div>`;
// The short form (the line over the sets): the situation as a row of buttons, the same picker
function profCompact(){
  return `<span class="prsits compact" role="group">${profSituationsHTML(false)}</span>${profPickerHTML(true)}`;
}

/* ---- clicks, names typed ---- */
function profFocus(){ setTimeout(() => { const el = document.querySelector('input[data-profname]'); if (el) { el.focus(); el.select(); } }, 0); }
document.addEventListener('click', e => {
  const b = e.target.closest && e.target.closest('button'), d = b ? b.dataset : {};
  // a click outside the picker closes it
  if (S._profOpen && !(e.target.closest && e.target.closest('.prpickwrap'))) { S._profOpen = false; S._profEdit = null; render(); }
  if (!b) return;
  if (d.profopen) { S._profOpen = S._profOpen === d.profopen ? false : d.profopen; render(); if (S._profOpen) setTimeout(() => { const q = document.getElementById('profq'); if (q) q.focus(); profFilter(); }, 0); return; }
  if (d.proftier != null && b.closest('.prtiers')) { S._profTier = d.proftier; for (const x of b.parentElement.children) x.setAttribute('aria-pressed', String(x === b)); return profFilter(); }
  if (d.proffav) { profFav(d.proffav); render(); return profFilter(); }
  if (d.profload) { profLoad(d.profload); return render(); }
  if (d.profupdate) { profSave(d.profupdate); return render(); }
  if (d.profedit) { S._profEdit = d.profedit; render(); profFilter(); return profFocus(); }
  if (d.profdel) { if (confirm(t('prDeleteAsk', {n: d.profdel}))) { profDelete(d.profdel); render(); profFilter(); } return; }
});
document.addEventListener('input', e => {
  if (e.target && e.target.id === 'profq') { S._profQ = e.target.value; profFilter(); }
});
document.addEventListener('keydown', e => {
  const el = e.target;
  if (!el || !el.dataset || !el.dataset.profname) return;
  if (e.key === 'Enter') { e.preventDefault(); e.stopPropagation(); const what = el.dataset.profname; S._profEdit = null;
    if (what === 'new') profSave(el.value); else profRename(what.slice(7), el.value);
    render(); profFilter(); }
  else if (e.key === 'Escape') { e.preventDefault(); e.stopPropagation(); S._profEdit = null; render(); profFilter(); }
  else e.stopPropagation();
}, true);
