// GearSwap Atelier · opt_all.js: every version of a weaponskill set searched in one go, and only the useful ones kept.
// A weaponskill set has a version a support profile (the set itself is the Full one, then .Group, .Solo, .Trust:
// shared/utils/party/support_tier.lua) and, on a DNC, a version a dance and Climactic Flourish (.Clim, .FanDance,
// .SaberDance, .FanDance.Clim, .SaberDance.Clim: ws_variant_selector.lua), each with its own support versions: up to
// 24 sets. Each is searched under its own buffs (the profile's, and the dance and Climactic its name says: buffs.js
// setDance, setClim), your pieces only, weapons kept, with the objective and limits of the optimizer's page. A version
// is worth writing when it does better than the set GearSwap wears without it (OA_EPS); the others are listed and
// left alone. Writing goes through the same door as a push (push.js, set_push.lua: preview, backup, history).
// Only the versions whose buffs the page counts: no .Acc (a Weaponskill Mode), no THF .SA / .TA.

Object.assign(T.fr, {oaBtn: 'Toutes les versions', oaTip: 'Cherche chaque version de cette weaponskill (profils de soutien, et sur DNC danses et Climactic) et ne garde que celles qui servent.',
  oaTitle: 'Toutes les versions', oaStep: 'Toutes les versions · {i} sur {n}', oaRuns: '{n} recherches', oaUseful: 'Versions utiles', oaVer: 'Version', oaDmg: 'Dégâts', oaVs: 'Contre le set porté sans elle',
  oaCh: 'Pièces changées', oaState: 'État', oaSelf: 'le set lui-même', oaExists: 'existe', oaNew: 'à créer', oaSkip: 'sans objet : {p} n’existe pas',
  oaSame: 'rien de mieux', oaUseless: 'inutile : fait comme {p}', oaSpare: 'fait comme {p} : une version de trop', oaFixes: 'le set actuel est sous tes limites, celui-ci les tient', oaVsNow: 'contre le set actuel', oaFail: 'échec : {e}',
  oaSum: '{n} version(s) cherchées, {u} utile(s), {x} sans intérêt.', oaGo: 'Enregistrer les {n} cochée(s)', oaNoLive: 'Le jeu ne répond pas : rien ne peut être enregistré.',
  oaWhy: 'Tes pièces seulement, armes gardées, avec l’objectif et les limites de cette page, chaque version sous ses propres buffs. Une version est utile quand elle fait mieux, d’au moins {e} %, que le set que GearSwap porte sans elle. Chaque enregistrement est annulable depuis l’historique (les 20 derniers par fichier).',
  oaWriting: 'Enregistrement {i} sur {n} : {v}', oaDone: '{n} version(s) enregistrée(s).', oaDoneErr: '{n} version(s) enregistrée(s), {x} en échec : {l}', oaNeed: 'il faut d’abord {p}'});
Object.assign(T.en, {oaBtn: 'Every version', oaTip: 'Searches each version of this weaponskill (support profiles, and on a DNC the dances and Climactic) and keeps only the useful ones.',
  oaTitle: 'Every version', oaStep: 'Every version · {i} of {n}', oaRuns: '{n} searches', oaUseful: 'Useful versions', oaVer: 'Version', oaDmg: 'Damage', oaVs: 'Against the set worn without it',
  oaCh: 'Pieces changed', oaState: 'State', oaSelf: 'the set itself', oaExists: 'exists', oaNew: 'to create', oaSkip: 'no use: {p} does not exist',
  oaSame: 'nothing better', oaUseless: 'no use: does as {p}', oaSpare: 'does as {p}: one version too many', oaFixes: 'the set as it is falls short of your limits, this one keeps them', oaVsNow: 'against the set as it is', oaFail: 'failed: {e}',
  oaSum: '{n} version(s) searched, {u} useful, {x} of no use.', oaGo: 'Save the {n} ticked', oaNoLive: 'The game does not answer: nothing can be saved.',
  oaWhy: 'Your pieces only, weapons kept, with this page’s objective and limits, each version under its own buffs. A version is useful when it does better, by {e} % at least, than the set GearSwap wears without it. Every save can be undone from the history (the last 20 a file).',
  oaWriting: 'Saving {i} of {n}: {v}', oaDone: '{n} version(s) saved.', oaDoneErr: '{n} version(s) saved, {x} failed: {l}', oaNeed: '{p} is needed first'});

// A version does better than its fallback by at least that much (%), or it is not worth a set
const OA_EPS = 0.1;
// The buff versions of a job's weaponskill sets the page can count
const OA_VARIANTS = {DNC: ['Clim', 'FanDance', 'SaberDance', 'FanDance.Clim', 'SaberDance.Clim']};
const OA_WEAPONS = ['main', 'sub', 'range'];

/* ---- the versions and what each falls back to ---- */
const oaJoin = (base, variant, tier) => base + (variant ? '.' + variant : '') + (tier === 'Full' ? '' : '.' + tier);
// The weaponskill's own set, from any of its versions
function oaBase(path){
  let p = path.replace(/\.(Group|Solo|Trust)$/, '');
  for (const v of (OA_VARIANTS[S.job] || []).slice().sort((a, b) => b.length - a.length)) if (p.endsWith('.' + v)) { p = p.slice(0, -v.length - 1); break; }
  return p;
}
// The buff versions GearSwap tries before the set itself, closest first (ws_variant_selector.lua best_variant)
function oaVariantChain(variant){
  if (!variant) return [];
  const parts = variant.split('.');
  return parts.length === 2 ? [parts[0], parts[1], ''] : [''];
}
// The support versions tried before the set itself (support_tier.lua CHAIN; Trust as tierVersions counts it)
const oaTierChain = tier => tier === 'Solo' ? ['Group', 'Full'] : tier === 'Full' ? [] : ['Full'];
function oaVersions(base){
  const out = [];
  for (const variant of [''].concat(OA_VARIANTS[S.job] || [])) for (const tier of TIERS) out.push({variant, tier, path: oaJoin(base, variant, tier), label: (variant || t('oaSelf')) + (tier === 'Full' ? '' : ' · ' + tier)});
  return out;
}
// A version is there: the file writes it, or this run keeps it
const oaThere = (R, path) => !!R.by[path] && (R.by[path].exists || R.by[path].sel);
// The set worn without that version: its support chain inside its buff version, then the buff versions before it
function oaFallback(R, v){
  for (const tier of oaTierChain(v.tier)) { const p = oaJoin(R.base, v.variant, tier); if (oaThere(R, p)) return p; }
  if (v.tier !== 'Full') return null;
  for (const variant of oaVariantChain(v.variant)) { const p = oaJoin(R.base, variant, 'Full'); if (oaThere(R, p)) return p; }
  return null;
}
// The pieces a version ends with: the search's when kept, the file's when it exists, else its fallback's
function oaFinal(R, path){
  const rec = R.by[path];
  if (!rec) return null;
  if (rec.sel && rec.res) return rec.res.pieces;
  if (rec.exists) return rec.start;
  const fb = oaFallback(R, rec.v);
  return fb ? oaFinal(R, fb) : null;
}

/* ---- one search, without the search window ---- */
function oaSearch(input, seq, show){
  return new Promise((resolve, reject) => {
    const starts = optWalks(input), n = optCores(starts.length), shares = [...Array(n)].map(() => []), outs = [];
    input.pace = (S.optOpts || {}).fullSpeed ? {work: 50, rest: 0} : {work: 25, rest: 25};
    starts.forEach((x, i) => shares[i % n].push(x));
    // the search window of a single search (optimizer.js optRunOpen: the moogle, the walks, the moves), one version a time
    if (show) show(starts, n);
    let workers;
    try { workers = shares.map(() => optWorker()); } catch (e) { return reject(e); }
    // a stop (optStop) drops the workers: nothing comes back, so the wait ends itself
    const watch = setInterval(() => { if (seq !== OPT_SEQ) { clearInterval(watch); reject(new Error('stopped')); } }, 300);
    const end = () => { clearInterval(watch); workers.forEach(w => w.terminate()); OPT_WORKERS = OPT_WORKERS.filter(w => !workers.includes(w));
      resolve(outs.reduce((a, b) => b.score > a.score ? b : a)); };
    workers.forEach((w, i) => {
      w.onerror = e => { clearInterval(watch); reject(new Error(e.message || 'worker')); };
      w.onmessage = e => { if (seq !== OPT_SEQ) return;
        if (e.data.progress) return optRunStep(i, e.data.progress);
        if (e.data.error) { clearInterval(watch); return reject(new Error(e.data.error)); }
        if (e.data.done) { outs.push(e.data.done); shares[i].forEach(optRunWalkDone); if (outs.length === workers.length) end(); } };
      w.postMessage(Object.assign({}, input, {starts: shares[i]}));
    });
  });
}
// fn() with a version's buffs: its support profile's, and the set shown being that version (its dance, Climactic)
function oaAs(s, tier, fn){
  const keep = S._curSet;
  S._curSet = s;
  try { return withTierBuffs(tier, fn); } finally { S._curSet = keep; }
}
// The file's pieces of a set, as a search reads them (no tried piece, no TP piece laid by the rule)
const oaPlain = s => withoutTrial(() => { S._noTpGear = true; try { return withWeapons(s).pieces; } finally { S._noTpGear = false; } });
// A version's set: the file's, or (not written yet) the set it falls back to under that version's name
function oaSetOf(R, v){
  if (S._bypath[v.path]) return S._bypath[v.path];
  let fb = oaFallback(R, v);
  while (fb && !S._bypath[fb]) fb = oaFallback(R, R.by[fb].v);
  return Object.assign({}, S._bypath[fb || R.base], {path: v.path});
}
const oaRaw = (ctx, pieces, opts) => { const r = pieces && FFXI.opt.value(FFXI.opt.context(ctx), pieces, opts); return r && isFinite(r.raw) ? r.raw : null; };

/* ---- the run ---- */
async function optAllOpen(shown){
  if (!engineReady() || S._optBusy) return;
  const base = oaBase(shown.path), root = S._bypath[base], ws = root && wsForSet(root);
  if (!root || !FFXI.opt.defineWs(ws, wsInfoOf(ws), wsSkills()[ws])) { S._toastSet = shown.path; S.toast = t('optNoWs', {ws: ws || shortPath(base)}); render(); return; }
  const R = S._optAll = {base, list: oaVersions(base), by: {}, done: 0, at: S.char + '|' + S.job, t0: performance.now()};
  S._optBusy = true; render();
  const seq = ++OPT_SEQ, mine = () => seq === OPT_SEQ && S._optAll === R && R.at === S.char + '|' + S.job;
  // stopped (the search window's Stop: optStop), or the page left for another job: the run is dropped
  const left = () => { if (S._optAll === R) S._optAll = null; };
  const r = await tpAskWait(root, oaPlain(root), null);
  if (!mine()) return left();
  const o = S.optOpts || {}, tpNames = new Set(((r && r.piece_list) || []).map(p => p.name).concat(Object.keys(ONLY_AUGS)));
  // your pieces only, whatever the page's "where": a version written here must be wearable as it is
  const where = o.where; S.optOpts = Object.assign({}, o, {where: 'mine'});
  let choices; try { choices = lockChoices(root, optChoices(tpNames)); } finally { S.optOpts = Object.assign({}, S.optOpts, {where}); }
  const opts = {fast: (o.search || 'fast') !== 'classic', tp: +(S.wsTp || 3000), tps: avgTps(o), tpRule: tpRuleOf(r), objective: o.obj || 'damage', scratch: false,
    floor: {pdt: +o.pdt || 0, mdt: +o.mdt || 0, sb: +o.sb || 0, hit: +o.hit || 0}};
  for (const v of R.list) {
    R.now = v;
    try { await oaOne(R, v, choices, opts, seq); } catch (e) { if (!mine()) return left(); R.by[v.path] = Object.assign(R.by[v.path] || {v}, {error: e.message, sel: false}); }
    if (!mine()) return left();
    R.done++;
  }
  // the last search's window gives way to the table of every version
  clearInterval(OPT_RUN_CLOCK); mogStop(); S._optRun = null; S._optProgress = null; searchPark().replaceChildren();
  R.now = null; R.finished = true; R.secs = (performance.now() - R.t0) / 1000; S._optBusy = false; render(); oaPaint(R);
}
// The search window opened for a version: the single search's own, its header saying which version of how many, and
// under it a mark a version (kept, of no use, the one searched, to come). Hidden by the player, it stays hidden
function oaShow(R, v, s, opts, starts, cores){
  const hidden = R.done > 0 && $('#overlay').hidden;
  optRunOpen(s, S.optOpts || {}, starts, cores, opts.floor);
  const run = S._optRun;
  if (!run) return;
  // the window draws them (atelier/src/screens/optimizer/OptRun.svelte)
  const mark = x => { const rec = R.by[x.path]; return x === v ? 'now' : !rec ? 'wait' : rec.sel ? 'on' : 'off'; };
  Object.assign(run, {kick: t('oaStep', {i: R.done + 1, n: R.list.length}), title: shortPath(R.base) + ' · ' + v.label, strip: R.list.map(x => ({cls: mark(x), title: x.label}))});
  ATELIER_RUN.changed();
  if (hidden) closeOverlay();
}
// One version: skipped when its buff version is not there, else searched and weighed against its fallback
async function oaOne(R, v, choices, opts, seq){
  const rec = R.by[v.path] = {v, exists: !!S._bypath[v.path]};
  const full = oaJoin(R.base, v.variant, 'Full');
  if (v.tier !== 'Full' && !oaThere(R, full)) { rec.skip = full; return; }
  // a dance's Climactic version is written under the dance's own: that one first
  const lead = v.variant.includes('.') ? oaJoin(R.base, v.variant.split('.')[0], 'Full') : '';
  if (lead && !oaThere(R, lead)) { rec.skip = lead; return; }
  const fb = oaFallback(R, v), s = oaSetOf(R, v);
  rec.fallback = fb;
  const own = startOf(lockedBase(s, oaPlain(s)), lockedSlots(s));
  rec.start = rec.exists ? own : oaFinal(R, fb) || own;
  rec.ctx = oaAs(s, v.tier, () => optContextInput(s));
  const res = rec.res = await oaSearch({ctx: rec.ctx, start: rec.start, choices: Object.assign({}, choices), prefilter: 0, opts: Object.assign({}, opts)}, seq,
    (starts, cores) => oaShow(R, v, s, opts, starts, cores));
  rec.opts = opts;
  rec.best = res.best.raw;
  rec.changed = oaDiff(rec.start, res.pieces).length;
  // against the set as it is (a version the file writes), and against what is worn without it
  rec.vsNow = res.start.raw ? (res.best.raw / res.start.raw - 1) * 100 : 0;
  const worn = fb ? oaRaw(rec.ctx, oaFinal(R, fb), opts) : null;
  rec.vsFallback = worn ? (res.best.raw / worn - 1) * 100 : null;
  // a set short of the page's limits (DT+PDT, DT+MDT, Subtle Blow, hit rate) that the search brings within them: kept
  // whatever it costs in damage (Shark Bite's .SaberDance.Clim stayed at -15 % of damage taken, 2026-10-12)
  rec.fixes = rec.changed > 0 && (res.start.miss || 0) > (res.best.miss || 0) + 1e-9;
  rec.sel = rec.changed > 0 && (rec.fixes || (rec.exists ? rec.vsNow >= OA_EPS : rec.vsFallback == null || rec.vsFallback >= OA_EPS));
  rec.useless = fb && rec.vsFallback != null && rec.vsFallback < OA_EPS;
}
// The slots where the search's pieces differ from a reference (both as the engine reads them): [[slot, piece | null]]
function oaDiff(ref, pieces){
  const out = [], blocked = FFXI.opt.blocked(pieces), bare = p => p ? {name: p.name, augs: p.augs} : null;
  for (const slot of SLOTS) {
    if (OA_WEAPONS.includes(slot)) continue;
    const a = ref && ref[slot], p = pieces[slot];
    if (blocked[slot]) { if (a) out.push([slot, null]); continue; }
    if (p && !samePiece(bare(p), bare(a))) out.push([slot, p]);
  }
  return out;
}

/* ---- the window ---- */
// A version's short name from its path (the weaponskill's own set: "the set itself")
const oaShort = (R, path) => path && path.length > R.base.length ? path.slice(R.base.length + 1) : t('oaSelf');
// The window: drawn by the Svelte application (atelier/src/screens/dialogs/optall.ts), drawn again in place at a tick or
// while the versions are written (the table keeps its scroll, the moogle goes on hopping)
function oaPaint(R){
  if (S._optAll !== R) return;
  const n = Object.values(R.by).filter(x => x.sel).length, first = !$('#overlay .oadlg');
  if (first) R.mogWinHtml = mogWinHTML(n > 0);
  const spec = {cls: 'oadlg', titleHtml: '', optAll: ATELIER_DIALOG.optAllView(R)};
  if (!first) return ATELIER_DIALOG.update(spec);
  ATELIER_DIALOG.show(spec);
  mogWinStart($('#overlay .oadlg'));
}
function optAllStop(){ S._optAll = null; optStop(); closeOverlay(); }
function optAllToggle(path){
  const R = S._optAll, rec = R && R.by[path];
  if (!rec || !rec.res || R.writing) return;
  rec.sel = !rec.sel; oaPaint(R);
}

/* ---- writing the ticked versions (set_push.lua, one request a set) ---- */
// The request of a version: the set's path, how it is created when the file has none, then its slots
function oaBody(R, rec){
  const v = rec.v, owned = ownedOf() || {}, full = oaJoin(R.base, v.variant, 'Full'), head = [v.path];
  let ref = rec.start;
  if (!rec.exists && v.tier !== 'Full') ref = oaFinal(R, full);        // a set_combine of its buff version (locate_base)
  else if (!rec.exists) { const fb = oaFallback(R, v); ref = oaFinal(R, fb); head.push('#create', '#base\t' + fb); }
  const lines = oaDiff(ref, rec.res.pieces).map(([slot, p]) => pushLine(p ? pushEntry(slot, {name: p.name, augs: p.augs}, owned) : {slot, kind: 'empty'}));
  return lines.length || !rec.exists ? head.concat(lines).join('\n') : null;
}
async function oaWriteOne(body){
  const ask = (q, timeout) => liveFetch(S.char, '/push?' + q + jobQuery(), {method: 'POST', body, timeout}).catch(() => ({error: 'live'}));
  const pre = await ask('mode=preview', 6000);
  if (pre.error) return pre.error;
  if (!(pre.changes && pre.changes.length)) return null;
  const done = await ask('mode=write&hash=' + encodeURIComponent(pre.hash), 8000);
  return done.error || null;
}
async function optAllGo(){
  const R = S._optAll;
  if (!R || !R.finished || R.writing || !liveWrite()) return;
  const todo = R.list.map(v => R.by[v.path]).filter(rec => rec && rec.sel && rec.res), failed = [];
  let ok = 0;
  for (const [i, rec] of todo.entries()) {
    R.writing = t('oaWriting', {i: i + 1, n: todo.length, v: rec.v.label}); oaPaint(R);
    const full = oaJoin(R.base, rec.v.variant, 'Full');
    // a support version is written under its buff version: that one must be in the file by now
    const body = rec.v.tier !== 'Full' && !R.by[full].exists ? null : oaBody(R, rec);
    const err = body == null ? t('oaNeed', {p: shortPath(full)}) : await oaWriteOne(body);
    if (err) failed.push(rec.v.label + ' (' + (T[S.lang]['pushErr_' + err] ? t('pushErr_' + err) : err) + ')'); else { ok++; rec.exists = true; rec.start = rec.res.pieces; }
  }
  S._optAll = null; closeOverlay();
  S._toastSet = R.base; S.toast = failed.length ? t('oaDoneErr', {n: ok, x: failed.length, l: failed.join(' · ')}) : t('oaDone', {n: ok});
  await reloadIfLoaded();
  render();
}
