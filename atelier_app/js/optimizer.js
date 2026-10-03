// GearSwap Atelier · optimizer.js: the searches: launch, the cost of the wrong profile, the search window, the result
// (cut from atelier.html, loaded by it in order: see the list there)
// The two searches' buttons: the best set possible (from nothing, the set you start from changing nothing; slower),
// and improving the set shown (from it, quicker)
const optGoButtons = act => `<button class="btn optgo" data-${act}="best" title="${esc(t('optBestTip'))}">${t('optBest')}</button>` +
  `<button class="btn" data-${act}="improve" title="${esc(t('optImproveTip'))}">${t('optImprove')}</button>`;
// The cores a search may take: what the processor has (the browser says how many), one left free for the game and
// the page, eight at most; each worker paced to about half a core
const OPT_CORES = Math.max(1, Math.min(8, (navigator.hardwareConcurrency || 2) - 1));
const optCores = n => Math.min(n, OPT_CORES);
// The walks of a search: the ones its choices and floors call for, then shuffled ones ("mix<n>") on the cores left
function optWalks(input){
  const base = FFXI.opt.startsFor(input.choices, input.opts);
  return base.concat([...Array(Math.max(0, OPT_CORES - base.length))].map((_, i) => 'mix' + (i + 1)));
}
const walkLabel = w => /^mix\d+$/.test(w) ? t('orWalk_mix', {n: w.slice(3)}) : t('orWalk_' + w);
// Stop a search: its workers are dropped
// The search running: a new one or a stop moves it on, so what an older one sends is dropped
let OPT_SEQ = 0;
function optStop(){
  OPT_SEQ++;
  OPT_WORKERS.forEach(w => w.terminate()); OPT_WORKERS = [];
  if (OPT_PAGE_STOP) { OPT_PAGE_STOP(); OPT_PAGE_STOP = null; }
  clearInterval(OPT_RUN_CLOCK); S._optRun = null;
  if (document.querySelector('.optrun')) closeOverlay();
  S._optBusy = false; S._optProgress = null; render();
}
/* ---- the cost of the wrong set: each version of a weaponskill set under each profile's buffs ---- */
// The versions of a weaponskill set the file has (the set itself is the Full one), and the one GearSwap
// wears in each tier (shared/utils/party/support_tier.lua: Solo falls back to Group, then to the set)
function tierVersions(s){
  const base = s.path.replace(/\.(Group|Solo)$/, ''), by = S._bypath || {};
  const out = [{name: 'Full', path: base, set: by[base] || s}];
  for (const v of ['Group', 'Solo']) if (by[base + '.' + v]) out.push({name: v, path: base + '.' + v, set: by[base + '.' + v]});
  const has = v => out.some(x => x.name === v);
  const worn = {Full: 'Full', Group: has('Group') ? 'Group' : 'Full', Solo: has('Solo') ? 'Solo' : has('Group') ? 'Group' : 'Full'};
  return {base, rows: out, worn};
}
// What the table compares: a weaponskill set's average damage, an engaged set's figure for the objective
// chosen (time to the weaponskill, DPS, TP a round); low: the smaller the better
function tierMetric(s){
  if (family(s.path, s.pieces) !== 'engaged')
    return {of: (set, draft) => draft ? wsDamage(set) : withoutTrial(() => wsDamage(set)), fmt: fmtDmg, low: false};
  const obj = (S.optOpts || {}).engObj || 'tp_real';
  const pick = {tp_real: r => r.real ? r.real.time : r.time, tp_time: r => r.time, dps: r => r.dps, tp_round: r => r.tp}[obj];
  const fmt = obj === 'dps' ? fmtDmg : obj === 'tp_round' ? v => String(Math.round(v)) : v => v.toFixed(2) + ' s';
  return {of: (set, draft) => { const r = engRound(set, !draft); return r ? pick(r) : null; }, fmt, obj, low: obj === 'tp_real' || obj === 'tp_time'};
}
// Each row's figure under each profile: {row name: {tier: value}}
function tierCosts(rows, m){
  const out = {};
  for (const row of rows) {
    out[row.name] = {};
    for (const tier of TIERS) out[row.name][tier] = withTierBuffs(tier, () => m.of(row.set, row.draft));
  }
  return out;
}
function openTierCost(s){
  showDialog('cmpdlg', t('tcTitle') + ` · <code>${esc(shortPath(s.path))}</code>`, `<p class="muted">${t('tcBusy')}</p>`, '');
  setTimeout(() => {
    const {rows, worn} = tierVersions(s);
    if (trialCount(s)) rows.push({name: 'draft', set: s, draft: true, label: t('tcDraft', {p: shortPath(s.path)})});
    const m = tierMetric(s);
    showDialog('cmpdlg', t('tcTitle') + ` · <code>${esc(shortPath(s.path))}</code>`, tierCostHTML(rows, worn, tierCosts(rows, m), m), '');
  }, 30);
}
function tierCostHTML(rows, worn, dmg, m){
  const best = {}, label = r => r.label || (r.name === 'Full' ? t('tcSetItself') : '.' + r.name);
  for (const tier of TIERS) { const vals = rows.map(r => dmg[r.name][tier]).filter(v => v != null && v > 0);
    best[tier] = vals.length ? (m.low ? Math.min(...vals) : Math.max(...vals)) : null; }
  // how much worse than the tier's best, in %: slower for a time, less for the rest
  const lossOf = (v, b) => !v || !b ? 0 : m.low ? (v / b - 1) * 100 : (1 - v / b) * 100;
  const cell = (r, tier) => { const v = dmg[r.name][tier];
    if (v == null) return '<td>—</td>';
    const loss = lossOf(v, best[tier]), on = !r.draft && worn[tier] === r.name;
    return `<td class="${v === best[tier] ? 'best' : ''} ${on ? 'worn' : ''}">${on ? '● ' : ''}${m.fmt(v)}${loss > 0.05 ? `<i class="dv down">${m.low ? '+' : '−'}${loss.toFixed(1)} %</i>` : ''}</td>`; };
  const table = `<table class="cmptbl tctbl"><thead><tr><th>${t('tcSet')}</th>${TIERS.map(x => `<th>${x}</th>`).join('')}</tr></thead><tbody>` +
    rows.map(r => `<tr><th>${esc(label(r))}</th>${TIERS.map(x => cell(r, x)).join('')}</tr>`).join('') + `</tbody></table>`;
  const lines = TIERS.map(tier => {
    const w = rows.find(r => r.name === worn[tier]), top = rows.filter(r => dmg[r.name][tier] === best[tier])[0];
    const loss = lossOf(dmg[w.name][tier], best[tier]);
    return loss < 0.05 || !top ? `<li>${t('tcOk', {t: tier, s: esc(label(w))})}</li>`
      : `<li class="kwarn">${t(m.obj ? 'tcLoseEng' : 'tcLose', {t: tier, s: esc(label(w)), b: esc(label(top)), p: loss.toFixed(1)})}</li>`; }).join('');
  const why = m.obj ? t('tcWhyEng', {o: esc(t('engObj_' + m.obj))}) : t('tcWhy', {tp: S.wsTp || 3000});
  return `<p class="muted small">${why}</p>${table}<ul class="tclist">${lines}</ul><p class="muted small">${t(m.obj ? 'tcHowEng' : 'tcHow')}</p>`;
}
// The optimizer on a weaponskill set: your pieces for every slot but the weapons, the TP pieces of
// the job's config left to its rule (never in the set), at the TP chosen; the result goes to draft B
// Where the optimizer looks (S.optOpts.where): your pieces (wardrobes only when asked), your pieces at
// their best (top rank, cape materials at their maximum), or every item of the game your job wears
function optChoices(tpNames){
  const o = S.optOpts || {}, owned = ofAnySub('owned') || {}, choices = {};
  const reach = x => !o.wardOnly || !(x.where && x.where.length) || x.where.some(w => /^(Inventory|Wardrobe)/.test(w));
  for (const slot of SLOTS) if (!['main', 'sub', 'range'].includes(slot)) {
    choices[slot] = (owned[slot] || []).filter(x => !tpNames.has(x.name) && reach(x)).map(x => {
      // how many you have (an export before 2026-10-03 counts the bags they are in)
      const mine = ownRank({name: x.name, augs: x.augs, copies: x.count || (x.where || []).length, keep: true, rare: isRare(x.name)});
      const up = o.where === 'mine_max' ? upgradeOf(mine) : null;
      return up ? Object.assign({}, up.piece, {copies: mine.copies, keep: true, maxed: true, from: mine}) : mine; });
    if (o.where === 'all') choices[slot] = choices[slot].concat(gameChoices(slot, choices[slot], tpNames));
  }
  return choices;
}
// The game's items for a slot your job wears and you do not hold (level 99 or an item level), a rank
// item on each of its paths at its top rank
function gameChoices(slot, have, tpNames){
  const job = S.job.toLowerCase(), names = new Set(have.map(x => x.name)), out = [], seen = new Set();
  // a one-choice mission reward you chose already rules out the group's others (FFXI.opt.EXCLUSIVE)
  const mine = new Set(Object.values(ofAnySub('owned') || {}).flat().map(x => x.name));
  const ruledOut = name => { const g = FFXI.opt.groupOf(name); return !!g && g.items.some(n => n !== name && mine.has(n)); };
  for (const it of FFXI.CATALOG.items) {
    if (!it.slots.includes(FFXI.opt.SLOT[slot]) || !it.jobs.includes(job) || names.has(it.name) || tpNames.has(it.name) || seen.has(it.name)) continue;
    if (!(it.level >= 99 || it.ilvl > 0) || ruledOut(it.name)) continue;
    seen.add(it.name);
    const e = rankedEntry(it.name);
    if (e && e.paths) for (const path of Object.keys(e.paths)) out.push({name: it.name, augs: ['Path: ' + path], rank: e.max_rank, missing: true});
    else out.push({name: it.name, missing: true, copies: twoAllowed(it.name) ? 2 : 1, rare: isRare(it.name)});
  }
  // rings and earrings: a second copy to get of one you have once, when the game lets you hold two
  if (/^(ring|ear)[12]$/.test(slot)) for (const x of have)
    if (x.copies === 1 && !(x.augs && x.augs.length) && !x.missing && twoAllowed(x.name)) out.push({name: x.name, missing: true, copies: 2});
  return out;
}
// The optimizer on a weaponskill set: weapons kept, the TP pieces of the job's config left to its rule
// (never in the set), at the TP chosen; the result goes to draft B
// The TP the average objective covers: the range chosen (the TP you weaponskill at), every 250
function avgRange(o){
  const clamp = v => Math.min(3000, Math.max(1000, Math.round((+v || 0) / 250) * 250));
  const a = clamp(o.tpFrom || 1000), b = clamp(o.tpTo || 3000);
  return a <= b ? [a, b] : [b, a];
}
function avgTps(o){ const [a, b] = avgRange(o), out = []; for (let x = a; x <= b; x += 250) out.push(x); return out; }
async function optimizeWs(s){
  if (!engineReady()) return;
  // a weaponskill the engine does not work out (the engine leaves it out and it is not a physical one the
  // project's database can describe): said plainly rather than a search over nothing
  const ws = wsOfSet(s) || segs(s.path).pop();
  if (!FFXI.opt.defineWs(ws, wsInfoOf(ws), wsSkills()[ws])) { S._toastSet = s.path; S.toast = t('optNoWs', {ws}); render(); return; }
  // the search starts from the set itself (the file, or what is in test in game), never from a draft:
  // a draft can hold pieces this search may not use (not yours, another reward of a one-choice group)
  const k = trialKey(s), base = withoutTrial(() => { S._noTpGear = true; try { return withWeapons(s).pieces; } finally { S._noTpGear = false; } });
  S._optBusy = true; S._optProgress = null; render();
  const at = S.char + '|' + S.job, seq = OPT_SEQ;
  const r = await tpAskWait(s, base, null);
  if (!S._optBusy || seq !== OPT_SEQ || at !== S.char + '|' + S.job) { if (seq === OPT_SEQ && S._optBusy) optStop(); return; }
  const rule = r && r.piece_list ? {bonus: (r.bonus || 0) + partyTp(), pieces: r.piece_list} : null;
  const tpNames = new Set(((r && r.piece_list) || []).map(p => p.name).concat(Object.keys(ONLY_AUGS))), o = S.optOpts || {};
  // the TP config's pieces (Moonshade...) are not searched: the job's TP rule lays them at the weaponskill when
  // they help (opts.tpRule), never the set
  const start = startOf(base), choices = optChoices(tpNames);
  if (o.freeWeapons) choices.weapons = weaponPairs(base, ws);
  const input = {ctx: optContextInput(s), start, choices, prefilter: o.where === 'all' ? 25 : 0,
    opts: {tp: +(S.wsTp || 3000), tps: avgTps(o), tpRule: rule, objective: o.obj || 'damage', floor: {pdt: +o.pdt || 0, mdt: +o.mdt || 0, sb: +o.sb || 0, hit: +o.hit || 0}}};
  optLaunch(s, k, input, o);
}
// The engaged optimizer: the set as it is (weapons kept), its objective, the defense floors; no TP piece rule
// The set a search starts from: in a search of your pieces (not every item of the game), a piece of the set you do not
// hold leaves it (Revelation Gaunt. pushed from an every-item search), the search fills its slot with yours
function startOf(base){
  const start = optPieces(base), owned = ofAnySub('owned') || {};
  if ((S.optOpts || {}).where === 'all') return start;
  for (const slot of Object.keys(start)) if (!['main', 'sub', 'range'].includes(slot) && !(owned[slot] || []).some(x => x.name === start[slot].name)) delete start[slot];
  return start;
}
// Free weapons: every main hand you hold with every off hand it can take ({main, sub}, the engine's "weapons"
// choice), the pair worn now first; a copy in both hands only when you have two
function weaponPairs(base, ws){
  const owned = ofAnySub('owned') || {}, piece = x => ownRank({name: x.name, augs: x.augs, copies: x.count || (x.where || []).length, keep: true});
  // a weaponskill set: only the weapons that open that weaponskill (its combat skill; a relic or prime's own)
  const opens = ws ? new Set(heldChoices(ws)) : null;
  // a hand you chose (a weaponskill's held weapon or off hand, an engaged set's forced ones) stays: only the other is searched
  const fixMain = ws ? heldWeapon(ws) : (slotForce().main || {}).name, fixSub = ws ? ((S.heldSub || {})[heldKey(ws)] || {}).name : (slotForce().sub || {}).name;
  const mains = (owned.main || []).filter(x => (!opens || opens.has(x.name)) && (!fixMain || x.name === fixMain)).map(piece);
  const subs = (owned.sub || []).filter(x => !fixSub || x.name === fixSub).map(piece), out = [];
  const now = optPieces({main: base.main, sub: base.sub});
  if (now.main) out.push({main: now.main, sub: now.sub || null});
  for (const m of mains) {
    const fits = subs.filter(x => subFits(m, x) && !(x.name === m.name && !(m.copies > 1)));
    if (!fits.length) out.push({main: m, sub: null});
    for (const x of fits) out.push({main: m, sub: x});
  }
  return out;
}
async function optimizeEngaged(s){
  if (!engineReady()) return;
  const k = trialKey(s), o = engOpts(s), base = withoutTrial(() => withWeapons(s).pieces);
  // pieces worn for their TP Bonus only (ONLY_AUGS: Moonshade) do nothing for an engaged set
  const choices = optChoices(new Set(Object.keys(ONLY_AUGS)));
  if (o.freeWeapons) choices.weapons = weaponPairs(base);
  const input = {ctx: engContextInput(s), start: startOf(base), choices, prefilter: o.where === 'all' ? 25 : 0,
    opts: {objective: o.engObj || 'tp_real', wsAt: +o.engAt || 1000, floor: {pdt: +o.pdt || 0, mdt: +o.mdt || 0, sb: +o.sb || 0}}};
  optLaunch(s, k, input, Object.assign({}, o, {eng: true}));
}
// A search in the worker (on the page when there is none), its progress, then its result
async function optLaunch(s, k, input, o){
  S._optBusy = true; S._optProgress = null; render();
  const seq = ++OPT_SEQ, at = S.char + '|' + S.job, mine = () => seq === OPT_SEQ && S._optBusy;
  const fail = msg => { if (!mine()) return; optStop(); S._toastSet = s.path; S.toast = t('optFail', {e: msg}); render(); };
  // the walks shared among the cores, round robin
  input.opts.scratch = !!S._optScratch;
  const starts = optWalks(input), n = optCores(starts.length), shares = [...Array(n)].map(() => []);
  // smooth (25 ms of work, 25 of pause: about half a core a worker) or full speed (no pause: about twice as fast)
  input.pace = (S.optOpts || {}).fullSpeed ? {work: 50, rest: 0} : {work: 25, rest: 25};
  starts.forEach((x, i) => shares[i % n].push(x));
  optRunOpen(s, o, starts, n, input.opts.floor);
  // the end: the best walk, shown done a moment before the result comes up
  const finish = out => { optRunDone(); setTimeout(() => {
    if (!mine()) return;
    // left for another character or job meanwhile: the result is not laid on that one's sets
    if (at !== S.char + '|' + S.job) return optStop();
    optResult(s, k, out, out.gains, o); }, 500); };
  let workers;
  try { workers = shares.map(() => optWorker()); } catch (e) { workers = null; }
  if (!workers) {   // no worker (an old browser): the search runs on the page, paced so it stays usable
    OPT_WORKERS = [];
    OPT_PAGE_STOP = FFXI.opt.runPaced(Object.assign({}, input, {starts}), p => optRunStep(0, p), out => { OPT_PAGE_STOP = null; finish(out); }, e => fail(e.message), input.pace.work, input.pace.rest);
    return;
  }
  // the end: once the main walks are done, the shuffled ones still going are not waited for (more cores never make it
  // longer); the best of the walks that finished is kept
  const outs = [], left = new Set(starts.filter(x => !/^mix\d+$/.test(x)));
  const end = () => {
    const best = outs.reduce((a, b) => b.score > a.score ? b : a);
    best.evals = outs.reduce((a, b) => a + b.evals, 0);
    OPT_WORKERS.forEach(x => x.terminate()); OPT_WORKERS = [];
    finish(best);
  };
  workers.forEach((w, i) => {
    w.onerror = e => fail(e.message || 'worker');
    w.onmessage = e => {
      if (!mine()) return;
      if (e.data.progress) return optRunStep(i, e.data.progress);
      if (e.data.error) return fail(e.data.error);
      outs.push(e.data.done);
      shares[i].forEach(walk => { optRunWalkDone(walk); left.delete(walk); });
      if (!left.size || outs.length === workers.length) end();
    };
    w.postMessage(Object.assign({}, input, {starts: shares[i]}));
  });
}
/* ---- the search window: what each walk does, the best set found so far, the moves as they come ---- */
// S._optRun: {t0, cores, walks: {walk: {stage, phase, round, evals, start, best, done}}, feed: [], series: [[s, value]],
// fmt, low (a time: smaller is better), done}
function optRunOpen(s, o, starts, cores, floor){
  const eng = !!o.eng, obj = eng ? (o.engObj || 'tp_real') : (o.obj || 'damage'), time = eng && /^tp_(real|time)$/.test(obj);
  const fmt = time ? v => v.toFixed(2) + ' s' : obj === 'tp_round' || obj === 'tp_return' ? v => String(Math.round(v)) : v => fmtDmg(v);
  const objLabel = eng ? t('engObj_' + obj) : t('optObj_' + obj, {tp: S.wsTp || 3000, a: o.tpFrom || 1000, b: o.tpTo || 3000});
  const floors = floor ? [['pdt', 'DT+PDT ≤'], ['mdt', 'DT+MDT ≤'], ['sb', 'Subtle Blow ≥']].filter(([k]) => +floor[k]).map(([k, l]) => `${l} ${floor[k]}`) : [];
  S._optRun = {t0: performance.now(), cores, fmt, low: time, done: false, walks: Object.fromEntries(starts.map(w => [w, {evals: 0}])), feed: [], series: []};
  const chips = [objLabel, t('optWhere_' + ((S.optOpts || {}).where || 'mine')), ...floors].map(x => `<span class="orchip">${esc(x)}</span>`).join('');
  const cards = starts.map(w => `<div class="orwalk" data-orwalk="${w}"><div class="orwh"><i class="ordot"></i><b>${esc(walkLabel(w))}</b><span class="orstage"></span></div>` +
    `<div class="orbar"><i></i></div><div class="orws"><span class="orphase">${esc(t('orStarting'))}</span><span class="orevals"></span></div><div class="orwbest">—</div></div>`).join('');
  $('#overlay').innerHTML = `<div class="scrim"></div><div class="dialog optrun" role="dialog" aria-live="polite">` +
    `<header><div class="orhead"><div><div class="kicker">${esc(t('orKick'))}</div><h3>${esc(shortPath(s.path))}</h3></div>` +
    `<div class="orclock"><span id="orclock">0,0 s</span><small>${esc(t('orCores', {n: cores}))}</small></div></div><div class="orchips">${chips}</div></header>` +
    `<div class="body"><div class="orhero"><div><div class="orlbl">${esc(t('orBest'))}</div><div class="orbig" id="orbig">—</div><div class="orgain" id="orgain"></div></div>` +
    `<svg class="orspark" id="orspark" viewBox="0 0 240 64" preserveAspectRatio="none"><path class="area"/><path class="line"/></svg></div>` +
    `<div class="orwalks">${cards}</div><div class="orlbl">${esc(t('orFeed'))}</div><ol class="orfeed" id="orfeed"><li class="orempty">${esc(t('orFeedEmpty'))}</li></ol></div>` +
    `<footer><span class="orrate" id="orrate"></span><span class="sp"></span><button class="btn ghost" data-orhide>${t('orHide')}</button>` +
    `<button class="btn" data-optstop>${t('optStop')}</button></footer></div>`;
  $('#overlay').hidden = false;
  clearInterval(OPT_RUN_CLOCK);
  OPT_RUN_CLOCK = setInterval(optRunClock, 100);
}
let OPT_RUN_CLOCK = null;
// The clock, the tries a second, and the big number easing to the best found
function optRunClock(){
  const R = S._optRun, el = document.getElementById('orclock');
  if (!R || !el) { clearInterval(OPT_RUN_CLOCK); return; }
  const sec = (performance.now() - R.t0) / 1000, evals = optRunEvals(R);
  if (!R.done) el.textContent = sec.toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US', {minimumFractionDigits: 1, maximumFractionDigits: 1}) + ' s';
  const rate = document.getElementById('orrate');
  if (rate) rate.textContent = t('orRate', {n: evals.toLocaleString(), r: Math.round(evals / Math.max(sec, .1)).toLocaleString()});
  const best = optRunBest(R), big = document.getElementById('orbig');
  if (!big || !best) return;
  R.shown = R.shown == null ? best.raw : R.shown + (best.raw - R.shown) * .25;
  big.textContent = R.fmt(Math.abs(R.shown - best.raw) < 1e-4 ? best.raw : R.shown);
}
// The tries so far: each worker's count (it runs over all of that worker's walks)
const optRunEvals = R => Object.values(R.byWorker || {}).reduce((a, n) => a + n, 0);
// The best set found so far over every walk: one that keeps the floors (a walk with no floor does not count yet)
function optRunBest(R){
  let best = null;
  for (const w of Object.values(R.walks)) {
    if (!w.best || w.stage === 'nofloor' || w.best.miss) continue;
    if (!best || (R.low ? w.best.raw < best.raw : w.best.raw > best.raw)) best = w.best;
  }
  return best;
}
// One worker's progress: its walk's state, the moves it kept, the curve of the best found
function optRunStep(i, p){
  const R = S._optRun;
  if (!R || !p.walk) return;
  const w = R.walks[p.walk] = Object.assign(R.walks[p.walk] || {}, {stage: p.stage, phase: p.phase, round: p.round, start: p.startRaw, best: p.best});
  (R.byWorker = R.byWorker || {})[i] = p.evals;
  R.start = R.start == null ? p.startRaw : R.start;
  for (const m of p.moves || []) R.feed.unshift(Object.assign({walk: p.walk, at: (performance.now() - R.t0) / 1000}, m));
  R.feed.length = Math.min(R.feed.length, 40);
  const best = optRunBest(R);
  const last = R.series[R.series.length - 1];
  if (best && (!last || last[1] !== best.raw)) R.series.push([(performance.now() - R.t0) / 1000, best.raw]);
  // the window may be closed (Hide): the compartment's line goes on
  S._optProgress = {round: p.round, evals: optRunEvals(R), ms: performance.now() - R.t0};
  renderOptProgress();
  optRunPaint(p.walk, p.moves || []);
}
// The window drawn again where it changed: the walk's card, the new moves on top of the feed, the gain, the curve
function optRunPaint(walk, moves){
  const R = S._optRun, card = document.querySelector(`[data-orwalk="${walk}"]`);
  if (!R || !card) return;
  const w = R.walks[walk];
  card.querySelector('.orstage').textContent = w.stage ? t('orStage_' + w.stage) : '';
  card.querySelector('.orphase').textContent = (w.phase ? t('orPhase_' + w.phase) : t('orStarting')) + (w.round ? ' · ' + t('orRound', {n: w.round}) : '');
  card.querySelector('.orevals').textContent = t('orTries', {n: (w.evals || 0).toLocaleString()});
  card.querySelector('.orwbest').innerHTML = w.best ? `${esc(R.fmt(w.best.raw))}${w.best.miss ? ` <span class="ormiss">${esc(t('orUnder'))}</span>` : ''}` : '—';
  const feed = document.getElementById('orfeed');
  if (feed && moves.length) {
    feed.querySelector('.orempty')?.remove();
    // scrolled down the feed: what is read stays in place while new moves come in on top
    const top = feed.scrollTop, height = feed.scrollHeight;
    for (const m of moves) {
      const li = document.createElement('li');
      li.innerHTML = `<span class="orfval">${esc(R.fmt(m.raw))}</span><span class="orfmoves">` + m.changes.map(c =>
        `<span class="orfslot">${esc(SLOT_NAMES[S.lang][c.slot] || c.slot)}</span> <s>${esc(c.from)}</s> → <b>${esc(c.to)}</b>`).join(' · ') +
        `</span><span class="orfwalk">${esc(walkLabel(walk))}${m.stage === 'nofloor' ? ' · ' + esc(t('orStage_nofloor')) : ''}${m.miss ? ' · ' + esc(t('orUnder')) : ''}</span>`;
      feed.prepend(li);
    }
    while (feed.children.length > 40) feed.lastChild.remove();
    if (top > 0) feed.scrollTop = top + feed.scrollHeight - height;
  }
  const best = optRunBest(R), gain = document.getElementById('orgain');
  if (gain && best && R.start) {
    const d = (R.low ? R.start / best.raw - 1 : best.raw / R.start - 1) * 100;
    gain.innerHTML = `${esc(t('orFrom', {v: R.fmt(R.start)}))} <b class="${d > .05 ? 'up' : ''}">${d > 0 ? '+' : ''}${d.toFixed(1)} %</b>`;
  }
  optRunSpark(R);
}
// The best found over time, a small curve (going up when it gets better)
function optRunSpark(R){
  const svg = document.getElementById('orspark');
  if (!svg || R.series.length < 2) return;
  const xs = R.series.map(x => x[0]), ys = R.series.map(x => R.low ? -x[1] : x[1]);
  const x0 = xs[0], x1 = Math.max(xs[xs.length - 1], x0 + 1), y0 = Math.min(...ys), y1 = Math.max(...ys, y0 + 1e-9);
  const pt = (x, y) => `${((x - x0) / (x1 - x0) * 240).toFixed(1)},${(60 - (y - y0) / (y1 - y0) * 54).toFixed(1)}`;
  const line = 'M' + R.series.map((x, i) => pt(xs[i], ys[i])).join(' L');
  svg.querySelector('.line').setAttribute('d', line);
  svg.querySelector('.area').setAttribute('d', line + ` L240,64 L0,64 Z`);
}
// The search window once done: the set found against yours (the value, the pieces changed, the figures, what is still
// to get), and what to do next: Compare in detail, test it in game, push it to GearSwap
function optRunResult(s, res, tr, plain, gains){
  const R = S._optRun, dlg = document.querySelector('.optrun');
  if (!R || !dlg) return;
  // the same piece in another copy (other augments, another path or rank) said so
  const changes = Object.keys(tr).map(slot => { const from = plain[slot] && !isEmpty(plain[slot]) ? plain[slot].name : '—', to = tr[slot] ? tr[slot].name : t('empty');
    return {slot, from, to: to === from ? to + ' · ' + t('orOtherCopy') : to}; });
  const d = (R.low ? res.start.raw / res.best.raw - 1 : res.best.raw / res.start.raw - 1) * 100;
  const fig = [];
  if (res.best.round && res.start.round) for (const c of Object.values(ENG_COLS)) {
    const a = c.get(res.start.round), b = c.get(res.best.round);
    if (a != null && b != null) fig.push([c.label || t(c.key), c.fmt(a), c.fmt(b), Math.abs(a - b) < 1e-9 ? 0 : (c.low ? b < a : b > a) ? 1 : -1]);
  }
  // a weaponskill: its average damage (or TP return), then its hit rates
  if (!res.best.round) {
    fig.push([t('orObjWs'), R.fmt(res.start.raw), R.fmt(res.best.raw), Math.abs(res.best.raw - res.start.raw) < 1e-9 ? 0 : res.best.raw > res.start.raw ? 1 : -1]);
    const h0 = res.start.hits || {}, h1 = res.best.hits || {}, pc = h => h == null ? '—' : Math.floor(h) + ' %';
    for (const [k, key] of [['first', 'wsvHit1'], ['rest', 'wsvHit2']]) if (h0[k] != null || h1[k] != null)
      fig.push([t(key), pc(h0[k]), pc(h1[k]), Math.floor(h1[k] || 0) === Math.floor(h0[k] || 0) ? 0 : (h1[k] || 0) > (h0[k] || 0) ? 1 : -1]);
  }
  const sd = res.start.def || {}, bd = res.best.def || {};
  for (const [k, label, low] of [['pdt', 'DT+PDT', true], ['mdt', 'DT+MDT', true], ['sb', 'Subtle Blow', false]]) {
    // damage taken counts down to its -50 cap only: past it, no better
    const a = Math.round(sd[k] || 0), b = Math.round(bd[k] || 0), ca = low ? Math.max(a, -50) : a, cb = low ? Math.max(b, -50) : b;
    if (a || b) fig.push([label, String(a), String(b), ca === cb ? 0 : (low ? cb < ca : cb > ca) ? 1 : -1]);
  }
  const live = liveOk() && (S._live[S.char] || {}).job === S.job;
  const list = changes.map(c => `<li><span class="orfslot">${esc(SLOT_NAMES[S.lang][c.slot] || c.slot)}</span><span><s>${esc(c.from)}</s> → <b>${esc(c.to)}</b></span></li>`).join('');
  const rows = fig.map(([l, a, b, w]) => `<tr><th>${esc(l)}</th><td>${esc(a)}</td><td class="${w > 0 ? 'up' : w < 0 ? 'down' : ''}">${esc(b)}</td></tr>`).join('');
  const lack = gains.length ? `<p class="orlack">${esc(t('orLack'))} ` + gains.map(g => `<b>${esc(g.piece.name)}</b> ${g.gain >= 0 ? '+' : ''}${g.gain.toFixed(1)} %`).join(' · ') + `</p>` : '';
  // the result's own rows: the hero, the changes and figures taking what is left (scrolling inside), what is to get
  dlg.querySelector('.body').style.gridTemplateRows = 'auto minmax(0,1fr) auto';
  dlg.querySelector('.body').innerHTML = `<div class="orhero"><div><div class="orlbl">${esc(t(changes.length ? 'orFound' : 'orSame'))}</div>` +
    `<div class="orbig">${esc(R.fmt(res.best.raw))}</div><div class="orgain">${esc(t('orFrom', {v: R.fmt(res.start.raw)}))} ` +
    `<b class="${d > .05 ? 'up' : ''}">${d > 0 ? '+' : ''}${d.toFixed(1)} %</b></div></div>${dlg.querySelector('.orspark') ? dlg.querySelector('.orspark').outerHTML : ''}</div>` +
    (changes.length ? `<div class="orres"><div><div class="orlbl">${esc(t('orChanged', {n: changes.length}))}</div><ul class="orchg">${list}</ul></div>` +
      (rows ? `<div><div class="orlbl">${esc(t('orFigures'))}</div><table class="orfig"><thead><tr><th></th><th>${esc(t('rdvMine'))}</th><th>${esc(t('rdvTry'))}</th></tr></thead><tbody>${rows}</tbody></table></div>` : '') +
      `</div>` : `<p class="muted">${esc(t('orSameWhy'))}</p>`) + lack;
  dlg.querySelector('footer').innerHTML = `<button class="btn ghost" data-close>${t('close')}</button><span class="sp"></span>` +
    (changes.length ? `<button class="btn ghost" data-cmpopen>${t('orCompare')}</button>` +
      (live ? `<button class="btn ghost" data-trysave>${t('trySave')}</button>` : '') + pushButton(s, live) : '');
}
// A walk finished: its card says so
function optRunWalkDone(walk){
  const card = document.querySelector(`[data-orwalk="${walk}"]`);
  if (card) { card.classList.add('done'); card.querySelector('.orphase').textContent = t('orWalkDone'); }
}
// The whole search finished: the window shows it a moment, then the result takes its place
function optRunDone(){
  const R = S._optRun;
  if (!R) return;
  R.done = true; clearInterval(OPT_RUN_CLOCK); optRunClock();
  Object.keys(R.walks).forEach(optRunWalkDone);
  document.querySelector('.optrun')?.classList.add('finished');
  const k = document.querySelector('.optrun .kicker');
  if (k) k.textContent = t('orDone');
}
// The progress line while the worker searches (only that line is drawn again)
function renderOptProgress(){
  const el = document.querySelector('.optprog'), p = S._optProgress;
  if (el && p) el.textContent = t('optProg', {r: p.round, n: p.evals.toLocaleString(), s: (p.ms / 1000).toFixed(1)});
}
// The result into draft B (the pieces that differ from the set itself), the message, then Compare
function optResult(s, k, res, gains, o){
  const tr = {}, plain = withoutTrial(() => { S._noTpGear = true; try { return withWeapons(s).pieces; } finally { S._noTpGear = false; } });
  // a slot another piece blocks (Onca Suit: no leggear) is emptied in the draft
  const blocked = FFXI.opt.blocked(res.pieces);
  for (const slot of Object.keys(blocked)) if (plain[slot] && !isEmpty(plain[slot])) tr[slot] = null;
  for (const [slot, p] of Object.entries(res.pieces)) {
    if (['main', 'sub', 'range'].includes(slot) || !p || blocked[slot]) continue;
    const a = plain[slot], piece = {name: p.name, augs: p.augs};
    if (p.rank != null) piece.rank = p.rank;
    if (p.capeMax) piece.capeMax = true;
    // the file names the piece alone and you hold one copy of it: GearSwap wears that copy, nothing changes
    if (a && !isEmpty(a) && a.name === p.name && !(a.augs && a.augs.length) && !p.maxed && !p.missing
      && ((ofAnySub('owned') || {})[slot] || []).filter(x => x.name === p.name).length <= 1) continue;
    if (!samePiece(piece, a && !isEmpty(a) ? optPieces({x: a}).x : null)) tr[slot] = piece;
  }
  // free weapons: the pair found becomes the page's forced weapons (never written to a set)
  let weapons = '';
  const wsHeld = !o.eng && wsOfSet(s);
  if (o.freeWeapons) for (const slot of ['main', 'sub']) {
    const p = res.pieces[slot], a = plain[slot];
    if (!p || samePiece({name: p.name, augs: p.augs}, a && !isEmpty(a) ? optPieces({x: a}).x : null)) continue;
    if (!wsHeld) setForce(slot, {name: p.name, augs: p.augs});
    else if (slot === 'main') S.held = Object.assign({}, S.held, {[heldKey(wsHeld)]: p.name});
    else S.heldSub = Object.assign({}, S.heldSub, {[heldKey(wsHeld)]: {name: p.name, augs: p.augs}});
    weapons = 'set';
  }
  if (weapons) weapons = ' ' + t(wsHeld ? 'wsWeapons' : 'engWeapons', {m: (res.pieces.main || {}).name || '—', s: (res.pieces.sub || {}).name || '—'});
  // the result becomes the try, labelled (profile, time); the try it replaces stays one click away
  const now = new Date(), hm = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');
  const keep = x => ({raw: x.raw, def: x.def, hits: x.hits || null});
  S.drafts[k] = Object.assign({}, S.drafts[k], {prev: Object.assign({}, S.trial[k] || {}), info: {tier: buffTier(), at: hm},
    res: {start: keep(res.start), best: keep(res.best), obj: o.eng ? o.engObj || 'tp_real' : o.obj || 'damage', tp: +(S.wsTp || 3000), range: avgRange(o),
      floor: {pdt: o.pdt, mdt: o.mdt, sb: o.sb, hit: o.hit}}});
  if (Object.keys(tr).length) S.trial[k] = tr; else delete S.trial[k];
  const low = o.eng && /^tp_(real|time)$/.test(o.engObj || 'tp_real');
  const gain = (((low ? res.start.raw / res.best.raw : res.best.raw / res.start.raw) - 1) * 100).toFixed(1), def = res.best.def || {};
  const extra = gains.map(g => `${g.piece.name}${g.piece.rank != null ? ' R' + g.piece.rank : ''}${g.piece.capeMax ? ' (max)' : ''} ${g.gain >= 0 ? '+' : ''}${g.gain.toFixed(1)} %`);
  S._toastSet = s.path;
  // the set itself short of the floors: the result meets them, which can cost damage
  // the hit rates: the first hit (+100 accuracy), then the others (a multi-hit weaponskill's, a double / triple attack's)
  const pct = h => h == null ? '—' : Math.floor(h) + ' %', bh = res.best.hits;
  const hitTxt = bh ? ' ' + t('optHit', {f: pct(bh.first), h: pct(bh.rest), e: enemyKey(buffState().enemy)}) : '';
  const sd = res.start.def || {}, startMiss = res.start.miss ? t('optStartMiss', {p: Math.round(sd.pdt || 0), m: Math.round(sd.mdt || 0), sb: Math.round(sd.sb || 0), h: pct((res.start.hits || {}).rest)}) + ' ' : '';
  const engV = v => o.engObj === 'dps' ? fmtDmg(v) : o.engObj === 'tp_round' ? Math.round(v) : v.toFixed(2) + ' s';
  const done = o.eng ? t('engDone_' + (o.engObj || 'tp_real'), {a: engV(res.start.raw), b: engV(res.best.raw), g: (+gain > 0 ? '+' : '') + gain, n: Object.keys(tr).length,
      p: Math.round(def.pdt || 0), m: Math.round(def.mdt || 0), sb: Math.round(def.sb || 0)})
    : t(o.obj === 'tp_return' ? 'optDoneTp' : 'optDone', {g: gain, d: fmtDmg(res.best.raw), n: Object.keys(tr).length,
      p: Math.round(def.pdt || 0), m: Math.round(def.mdt || 0), sb: Math.round(def.sb || 0)});
  S.toast = `${buffTier()} · ` + startMiss + (res.best.miss ? t('optMiss') + ' ' : '') + done + weapons + hitTxt + (extra.length ? ' ' + t('optLack', {l: extra.join(' · ')}) : '');
  // nothing better found: said plainly, draft B left empty, no Compare with nothing to compare
  if (!Object.keys(tr).length) S.toast = `${buffTier()} · ` + startMiss + (o.eng ? t('engSame', {v: engV(res.best.raw)}) : t('optSame', {d: fmtDmg(res.best.raw)})) + weapons + hitTxt;
  save();
  S._optBusy = false; render();
  // the search window still open: the result in it, with what to do next; else Compare
  if (S._optRun && document.querySelector('.optrun')) optRunResult(s, res, tr, plain, gains);
  else if (Object.keys(tr).length) openCompare(s);
  S._optRun = null;
}
