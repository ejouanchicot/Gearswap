// GearSwap Atelier · opt_sets.js: "Tout optimiser": every set of the job shown searched one after the other, each by its
// own optimizer with its own goals, limits and HP band, then a summary where the player ticks what goes to the file
// (notes/docs-perso/tout-optimiser-2026-11-01/SPEC.md). The window: atelier/src/screens/dialogs/optsets.ts.
// (loaded in the order of atelier/src/legacy/files.ts)
Object.assign(T.fr, {osBtn: 'Tout optimiser', osBtnTip: 'Optimise tous les sets de ce job l’un après l’autre, chacun avec ses objectifs et ses seuils, puis te montre ce qui change avant d’écrire quoi que ce soit.',
  osTitle: 'Tout optimiser', osPick: '{n} set(s) coché(s) · environ {d}', osOnlyStat: 'Sets de stats seulement', osAll: 'Tout', osNone: 'Rien',
  osScratch: 'Repartir de zéro (plus long, parfois meilleur)', osMine: 'Dans tes pièces seulement : un set écrit doit être portable tel quel.',
  osGo: 'Lancer ({n})', osStep: 'Set {i} / {n}', osSkip: 'non calculé : {e}', osSame: 'rien de mieux', osMiss: 'seuils non tenus',
  osSumTitle: 'Tout optimiser · résultat', osSum: '{u} set(s) à écrire sur {n} · {s}', osStopped: 'arrêté au set {i} / {n}',
  osHeadSet: 'Set', osHeadObj: 'Objectif', osHeadVs: 'Avant → après', osHeadGain: 'Gain', osHeadN: 'Pièces',
  osWrite: 'Pousser dans GearSwap ({n})', osWriting: 'Écriture {i} / {n} : {p}', osUndo: 'Tout annuler',
  osNoLive: 'Le jeu n’est pas connecté : les résultats restent à l’essai sur chaque set, à pousser plus tard.',
  osDone: '{n} set(s) écrit(s).', osDoneErr: '{n} set(s) écrit(s), {x} en échec : {l}', osVersion: 'version de profil, à pousser depuis le set',
  osUndone: 'Tous les sets remis comme avant la course.', osSec: '{n} s', osMin: '{n} min'});
Object.assign(T.en, {osBtn: 'Optimize all', osBtnTip: 'Optimizes every set of this job one after the other, each with its own goals and limits, then shows what changes before anything is written.',
  osTitle: 'Optimize all', osPick: '{n} set(s) ticked · about {d}', osOnlyStat: 'Stats sets only', osAll: 'All', osNone: 'None',
  osScratch: 'Start from scratch (longer, sometimes better)', osMine: 'Your pieces only: a set written must be wearable as it is.',
  osGo: 'Start ({n})', osStep: 'Set {i} / {n}', osSkip: 'not computed: {e}', osSame: 'nothing better', osMiss: 'limits not held',
  osSumTitle: 'Optimize all · result', osSum: '{u} set(s) to write out of {n} · {s}', osStopped: 'stopped at set {i} / {n}',
  osHeadSet: 'Set', osHeadObj: 'Goal', osHeadVs: 'Before → after', osHeadGain: 'Gain', osHeadN: 'Pieces',
  osWrite: 'Push to GearSwap ({n})', osWriting: 'Writing {i} / {n}: {p}', osUndo: 'Undo all',
  osNoLive: 'The game is not linked: the results stay on trial on each set, to push later.',
  osDone: '{n} set(s) written.', osDoneErr: '{n} set(s) written, {x} failed: {l}', osVersion: 'a profile version, to push from the set',
  osUndone: 'Every set put back as it was before the run.', osSec: '{n} s', osMin: '{n} min'});

// The optimizer a set gets, as its card picks it (atelier/src/screens/sets/card.ts optable / statOnly): its kind, or
// null when it has none (weapon sets, a job ability no piece can boost, a weaponskill the engine does not know)
function osKind(s){
  if (family(s.path, s.pieces) === 'weapons' || (S.job === 'PLD' && s.path === 'sets.idle')) return null;
  // a Dual Wield tier: searched over its mode's engaged set (eng_modes.js)
  if (dwTierOf(s.path)) return 'dw';
  const wsName = family(s.path, s.pieces) === 'ws' && (wsOfSet(s) || genericWsOf(s));
  if (wsName) return FFXI.opt.knowsWs(wsForSet(s)) ? 'ws' : null;
  if (isNukeSet(s.path)) return 'nuke';
  if (roundSet(s)) return 'eng';
  if (statSet(s)) return jaOverlayBase(s) && !jaBoostable(s) ? null : 'stat';
  return null;
}
const OS_RUN = {stat: s => optimizeStats(s), ws: s => optimizeWs(s), nuke: s => optimizeNuke(s), eng: s => optimizeEngaged(s), dw: s => optimizeDwTier(s)};
// Seconds a search takes, by kind: a first guess, then what this page measured
const OS_TIMES = {stat: 5, ws: 25, nuke: 20, eng: 25, dw: 25};
// The run's order: the Fast Cast sets first (they set every tank set's HP band: stat_opt.js hpRef), then each set after
// the set it is built on (sets.precast.JA before the abilities' sets, sets.Cure before Cure Self), then the list's order
function osOrder(list){
  const by = new Map(list.map(x => [x.s.path, x])), out = [], seen = new Set();
  const add = x => { if (seen.has(x.s.path)) return; seen.add(x.s.path);
    // (a Dual Wield tier after the engaged set it is laid on: searched over that set's new pieces)
    const over = jaOverlayBase(x.s), dwOn = dwTierOf(x.s.path) && dwBaseSet(x.s), base = by.get(x.s.base) || (over && by.get(over.path)) || (dwOn && by.get(dwOn.path));
    if (base) add(base);
    out.push(x); };
  list.filter(x => family(x.s.path, x.s.pieces) === 'fc').forEach(add);
  list.forEach(add);
  return out;
}
// The sets of the job shown, in the list's order and family (S._cards), each with its kind
function osSets(){
  const out = [];
  for (const card of S._cards || []) for (const v of card.variants || []) {
    const kind = osKind(v.set);
    if (kind) out.push({s: v.set, kind, fam: card.fam});
  }
  return out;
}
// "Engaged only": each engaged mode (its set itself, not its Solo / Group / Trust versions, which follow the support)
// and the Dual Wield tiers (eng_modes.js engModeOf, dwTierOf)
const osEngaged = x => x.kind === 'dw' || (x.kind === 'eng' && !!engModeOf(x.s.path) && !/\.(Group|Solo|Trust)$/.test(x.s.path));
const osDur = n => n < 90 ? t('osSec', {n: Math.round(n)}) : t('osMin', {n: Math.round(n / 60)});

/* ---- the start window ---- */
// preset 'eng': the engaged sets with a mode by their name and the Dual Wield tiers ticked, the others not
function optSetsOpen(preset){
  if (!engineReady() || S._optBusy) return;
  const list = osOrder(osSets());
  S._optSets = {at: S.char + '|' + S.job, list, on: Object.fromEntries(list.map(x => [x.s.path, preset === 'eng' ? osEngaged(x) : true])), scratch: false};
  osPaint();
}
function osPaint(){
  const R = S._optSets;
  if (!R) return;
  const spec = {cls: 'osdlg', titleHtml: '', optSets: ATELIER_DIALOG.optSetsView(R)};
  if ($('#overlay .osdlg')) ATELIER_DIALOG.update(spec); else ATELIER_DIALOG.show(spec);
}
const osEstimate = R => R.list.filter(x => R.on[x.s.path]).reduce((n, x) => n + OS_TIMES[x.kind] * (R.scratch ? 2 : 1), 0);
// The start window's clicks: a set, a family, the shortcuts, starting from scratch
function optSetsClick(d){
  const R = S._optSets;
  if (!R || R.running) return;
  if (d.osset != null) R.on[d.osset] = !R.on[d.osset];
  if (d.osfam != null) { const fam = R.list.filter(x => x.fam === d.osfam), on = !fam.every(x => R.on[x.s.path]); fam.forEach(x => { R.on[x.s.path] = on; }); }
  if (d.osonly != null) R.list.forEach(x => { R.on[x.s.path] = d.osonly === 'all' || (d.osonly === 'stat' && x.kind === 'stat') || (d.osonly === 'eng' && osEngaged(x)); });
  if ('osscratch' in d) R.scratch = !R.scratch;
  osPaint();
}

/* ---- the run ---- */
// The search under way in a run: optResult (optimizer.js) hands it its result, optStop its stop, optLaunch a failure
let OS_DONE = null;
function osSearchEnd(info){ const f = OS_DONE; OS_DONE = null; if (f) f(info); return !!f; }
// One set: its own optimizer, waited for. A search that never started (a case the engine does not compute) says why
async function osOne(R, x, i, todo){
  const done = new Promise(res => { OS_DONE = res; });
  S._optScratch = R.scratch; S.toast = '';
  await OS_RUN[x.kind](x.s);
  if (OS_DONE && !S._optBusy) { OS_DONE = null; return {error: S.toast || '?'}; }
  // the search window says which set of how many (atelier/src/screens/optimizer/OptRun.svelte)
  const run = S._optRun;
  if (run) { const mark = y => y === x ? 'now' : !R.by[y.s.path] ? 'wait' : R.by[y.s.path].sel ? 'on' : 'off';
    Object.assign(run, {kick: t('osStep', {i: i + 1, n: todo.length}), title: shortPath(x.s.path), strip: todo.map(y => ({cls: mark(y), title: shortPath(y.s.path)}))});
    ATELIER_RUN.changed(); }
  return done;
}
async function optSetsGo(){
  const R = S._optSets;
  if (!R || R.running || R.finished) return;
  const todo = R.list.filter(x => R.on[x.s.path]);
  if (!todo.length) return;
  closeOverlay();
  Object.assign(R, {running: true, by: {}, before: {}, todo, t0: performance.now()});
  const keep = {where: (S.optOpts || {}).where, fullSpeed: (S.optOpts || {}).fullSpeed};
  // your pieces only, at full speed (the player's choice, SPEC); each set's other settings are its own
  S.optOpts = Object.assign({}, S.optOpts, {where: 'mine', fullSpeed: true});
  S._optChain = true;
  try {
    for (const [i, x] of todo.entries()) {
      if (S._optSets !== R || R.at !== S.char + '|' + S.job) break;
      const k = trialKey(x.s), t1 = performance.now();
      R.before[k] = S.trial[k] ? Object.assign({}, S.trial[k]) : null;
      R.i = i;
      const out = await osOne(R, x, i, todo);
      if (out.stopped) { R.stopped = i; break; }
      if (!out.error) OS_TIMES[x.kind] = (OS_TIMES[x.kind] + (performance.now() - t1) / 1000 / (R.scratch ? 2 : 1)) / 2;
      R.by[x.s.path] = osRecord(x, out);
    }
  } finally {
    S.optOpts = Object.assign({}, S.optOpts, keep);
    S._optChain = false; S._optScratch = false;
  }
  if (S._optSets !== R) return;
  clearInterval(OPT_RUN_CLOCK); mogStop(); S._optRun = null; S._optProgress = null; searchPark().replaceChildren(); closeOverlay();
  // what a push's preview would warn of (push.js pushWarnings: a piece not held, out of reach, the sets built on it), no
  // preview window being shown in a run: said on the set's line
  for (const rec of Object.values(R.by)) if (rec.n) { try { const s = rec.x.s; rec.warn = pushWarnings(s, pushPlan(s), false).map(w => w.replace(/<[^>]+>/g, '')); } catch (e) { rec.warn = []; } }
  Object.assign(R, {running: false, finished: true, secs: (performance.now() - R.t0) / 1000});
  save(); render(); osPaint();
}
// A set's line in the summary: its goal before and after, the gain, its limits held, the slots changed; ticked when it
// gains and holds its limits
function osRecord(x, out){
  if (out.error) return {x, error: out.error, sel: false};
  const {res, tr, o} = out, eng = !!o.eng, obj = o.stat || (eng ? (o.engObj || 'tp_real') : o.nuke ? 'nuke' : (o.obj || 'damage'));
  const time = eng && /^tp_(real|time)$/.test(obj), low = time || obj === 'hpLow';
  const fmt = o.stat ? statFmt(obj) : time ? v => v.toFixed(2) + ' s' : eng && engObjFmt(obj) ? engObjFmt(obj) : obj === 'tp_round' || obj === 'tp_return' ? v => String(Math.round(v)) : v => fmtDmg(v);
  const label = o.stat ? t('statObj_' + obj) : o.nuke ? t(isBurstSet(x.s.path) ? 'nukeObjMb' : 'nukeObj') : eng ? t('engObj_' + obj) : t('optObj_' + obj, {tp: S.wsTp || 3000, a: 1000, b: 3000});
  const g = (low ? res.start.raw / res.best.raw : res.best.raw / res.start.raw) - 1, n = Object.keys(tr).length, miss = !!res.best.miss;
  return {x, label, from: fmt(res.start.raw), to: fmt(res.best.raw), gain: isFinite(g) ? g * 100 : 0, n, miss, sel: n > 0 && !miss};
}
function optSetsTick(path){
  const R = S._optSets, rec = R && R.by[path];
  if (!rec || !R.finished || R.writing || rec.error || !rec.n) return;
  rec.sel = !rec.sel; osPaint();
}
// Every set run put back as it was before the run: its trial then, or none
function optSetsUndo(){
  const R = S._optSets;
  if (!R || !R.finished || R.writing) return;
  for (const x of R.todo) { const k = trialKey(x.s);
    if (!(k in R.before)) continue;
    if (R.before[k]) S.trial[k] = R.before[k]; else delete S.trial[k];
    if (S.drafts[k]) { delete S.drafts[k].prev; delete S.drafts[k].info; } }
  S._optSets = null; closeOverlay(); S.toast = t('osUndone'); save(); render();
}

/* ---- writing the ticked sets (set_push.lua, one request a set, in the run's order: a base before its sets) ---- */
// GearSwap reloaded after a set written, and waited for: with the job loaded, set_push.lua reads the loaded sets to name
// a piece by the file's variable (variables, loaded_piece). Left on the sets before the write, the next set could be
// given another piece's variable, silently (ingame-risk-reviewer, 2026-11-01). Its door is back when /ping says a new
// load (version) or a new start (boot), or answers again after 3 s; 15 s at most
async function osReloadWait(){
  if (!shownJobLoaded()) return;
  let was = null;
  try { const p0 = await liveFetch(S.char, '/ping', {timeout: 1500}); was = p0.boot + '|' + p0.version; } catch (e) {}
  await reloadIfLoaded();
  const t0 = Date.now();
  while (Date.now() - t0 < 15000) {
    await new Promise(r => setTimeout(r, 500));
    // (a gs reload raises `version`; `boot` moves only when the addon restarts: atelier_live.lua)
    try { const p = await liveFetch(S.char, '/ping', {timeout: 1500}); if (p.boot + '|' + p.version !== was || Date.now() - t0 > 3000) return; } catch (e) {}
  }
}
async function optSetsWrite(){
  const R = S._optSets;
  if (!R || !R.finished || R.writing || !liveWrite()) return;
  const todo = R.todo.filter(x => (R.by[x.s.path] || {}).sel), failed = [];
  let ok = 0;
  for (const [i, x] of todo.entries()) {
    R.writing = t('osWriting', {i: i + 1, n: todo.length, p: shortPath(x.s.path)}); osPaint();
    const s = (S._bypath || {})[x.s.path] || x.s, tg = pushTarget(s);
    // a profile's version (Group, Solo, Trust) is written from its set's page, which shows where it goes
    if (tg.path !== s.path) { failed.push(shortPath(s.path) + ' (' + t('osVersion') + ')'); continue; }
    const plan = pushPlan(s);
    if (!plan.length) continue;
    const err = await oaWriteOne([tg.path].concat(plan.map(pushLine)).join('\n'));
    if (err) { failed.push(shortPath(s.path) + ' (' + (T[S.lang]['pushErr_' + err] ? t('pushErr_' + err) : err) + ')'); continue; }
    // as a push alone does (push.js pushGo): the trial goes, the page's copies take the pieces written
    const map = setOverrides();
    delete S.trial[trialKey(s)];
    if (map[S.job]) { delete map[S.job][s.path]; if (!Object.keys(map[S.job]).length) delete map[S.job]; }
    if (S.setOv[S.char]) S.setOv[S.char].at = stamp();
    pushedKeep(s, plan); ok++;
    if (i < todo.length - 1) await osReloadWait();
  }
  S._optSets = null; closeOverlay(); save();
  S.toast = failed.length ? t('osDoneErr', {n: ok, x: failed.length, l: failed.join(' · ')}) : t('osDone', {n: ok});
  await reloadIfLoaded();
  render();
}
