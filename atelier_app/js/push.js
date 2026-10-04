// GearSwap Atelier · push.js: push, delete, history, a new set
// (cut from atelier.html, loaded by it in order: see the list there)
/* ---- push: the set written into the player's set file (shared/utils/atelier/set_push.lua) ---- */
// Where a push goes. Under the Group or Solo profile, a weaponskill or engaged set's draft belongs to that profile's
// version (sets.precast.WS['X'].Solo, sets.engaged.PDT.Solo, worn by shared/utils/party/support_tier.lua): written as a new
// set_combine of the set when the file has none (create), opened to work on when it has one (exists)
function pushTarget(s){
  const tier = buffTier();
  if (tier === 'Full' || !TIERED.test(s.path) || /\.(Group|Solo)$/.test(s.path)) return {path: s.path};
  const path = s.path + '.' + tier;
  return S._bypath && S._bypath[path] ? {path, tier, exists: true} : {path, tier, create: true};
}
// One push entry: the piece, `empty`, or the name alone when it is the only copy the player owns
function pushEntry(slot, target, owned){
  if (!target || isEmpty(target)) return {slot, kind: 'empty'};
  const copies = (owned[slot] || []).filter(x => x.name === target.name);
  return {slot, kind: !(target.augs && target.augs.length) || copies.length === 1 ? 'one' : 'piece', piece: target};
}
// A new version holds the draft's pieces that differ from the set it is built on
// and from the set as the file writes it (the version is built on the file's set, so the pieces in test
// in game, s.was, are written into it too)
function versionPlan(s){
  const tr = S.trial[trialKey(s)] || {}, was = s.was || {}, owned = ownedOf() || {};
  const fileOf = slot => slot in was ? (!was[slot] || was[slot].name === 'empty' ? null : was[slot]) : (isEmpty(s.pieces[slot]) ? null : s.pieces[slot]);
  return SLOTS.filter(slot => slot in tr || slot in was).map(slot => {
    const target = slot in tr ? tr[slot] : (isEmpty(s.pieces[slot]) ? null : s.pieces[slot]);
    return samePiece(target && !isEmpty(target) ? target : null, fileOf(slot)) ? null : pushEntry(slot, target, owned);
  }).filter(Boolean);
}
// The draft carried to the profile's version, which then opens
function openVersion(s){
  const tg = pushTarget(s), tr = S.trial[trialKey(s)];
  if (!tg.exists) return;
  if (tr) S.trial[S.char + '|' + S.job + '|' + tg.path] = Object.assign({}, S.trial[S.char + '|' + S.job + '|' + tg.path], tr);
  S.selPath[S.job] = tg.path; S._found = null; save(); render();
}
// One entry per slot the draft or the saved pieces change: the piece, `empty`, or `inherit`
// (the line goes, the set takes its base's piece again)
function pushPlan(s){
  const tr = S.trial[trialKey(s)] || {}, was = s.was || {}, owned = ownedOf() || {};
  const base = s.base && S._bypath ? S._bypath[s.base] : null;
  return SLOTS.filter(slot => slot in tr || slot in was).map(slot => {
    const target = slot in tr ? tr[slot] : (isEmpty(s.pieces[slot]) ? null : s.pieces[slot]);
    const bp = base && base.pieces[slot], bEmpty = !bp || isEmpty(bp);
    if (!target || isEmpty(target)) return {slot, kind: base && bEmpty ? 'inherit' : 'empty'};
    if (base && !bEmpty && samePiece(target, bp)) return {slot, kind: 'inherit'};
    // the only copy the player owns: its name is enough, the file's variable for it can be used
    return pushEntry(slot, target, owned);
  });
}
const pushLine = e => [e.slot, e.kind].concat(e.piece ? [e.piece.name].concat(e.kind === 'piece' ? e.piece.augs || [] : []) : []).join('\t');
function pushWarnings(s, plan, fresh){
  const owned = ownedOf() || {}, out = [];
  for (const e of plan) if (e.piece && (e.piece.rank != null || e.piece.capeMax)) out.push(t('pushNotYet', {p: esc(e.piece.name)}));
  for (const e of plan) if (e.piece) {
    const copies = (owned[e.slot] || []).filter(x => x.name === e.piece.name && (e.kind === 'one' || (x.augs || []).join('|') === (e.piece.augs || []).join('|')));
    const where = [...new Set(copies.flatMap(x => x.where || []))];
    if (!copies.length) out.push(t('pushNotOwned', {p: esc(e.piece.name)}));
    else if (where.length && !where.some(w => /^(Inventory|Wardrobe)/.test(w))) out.push(t('pushOutOfReach', {p: esc(e.piece.name), w: esc(where.map(whereLabel).join(', '))}));
  }
  // the sets built from this one take the changed slots they do not write themselves
  const d = data(), changed = plan.map(e => e.slot), kids = [];
  const walk = path => { for (const x of d.sets) if (x.base === path && !kids.includes(x.path)) {
    const own = new Set(x.own || []);
    if (changed.some(slot => !own.has(slot))) kids.push(x.path);
    walk(x.path); } };
  if (!fresh) walk(s.path);
  if (kids.length) out.push(t('pushRicochet', {n: kids.length, l: esc(kids.slice(0, 8).map(shortPath).join(' · ') + (kids.length > 8 ? ' …' : ''))}));
  return out;
}
// The set's lines before and after, line by line (longest common subsequence)
function diffHTML(before, after){
  const a = before ? before.split(/\r?\n/) : [], b = after.split(/\r?\n/), L = [];
  for (let i = a.length; i >= 0; i--) { L[i] = []; for (let j = b.length; j >= 0; j--)
    L[i][j] = i === a.length || j === b.length ? 0 : a[i] === b[j] ? L[i + 1][j + 1] + 1 : Math.max(L[i + 1][j], L[i][j + 1]); }
  const out = []; let i = 0, j = 0;
  while (i < a.length || j < b.length) {
    if (i < a.length && j < b.length && a[i] === b[j]) { out.push(['same', a[i]]); i++; j++; }
    else if (j < b.length && (i === a.length || L[i][j + 1] > L[i + 1][j])) out.push(['add', b[j++]]);
    else out.push(['del', a[i++]]);
  }
  return `<div class="diff">${out.map(([k, l]) => `<div class="${k}">${k === 'add' ? '+ ' : k === 'del' ? '− ' : '  '}${esc(l)}</div>`).join('')}</div>`;
}
async function openPush(s){
  const tg = pushTarget(s);
  if (tg.exists) return openVersion(s);
  const plan = tg.create ? versionPlan(s) : pushPlan(s);
  if (!plan.length) return;
  const body = [tg.path].concat(plan.map(pushLine)).join('\n');
  S._push = {s, body, tg, plan};
  showDialog('pushdlg', t('pushTitle'), `<p class="muted">${t('pushReading')}</p>`, '');
  let r;
  try { r = await liveFetch(S.char, '/push?mode=preview' + jobQuery(), {method: 'POST', body, timeout: 6000}); } catch (e) { r = {error: 'live'}; }
  if (!S._push || S._push.body !== body) return;
  if (r.error) return showDialog('pushdlg', t('pushTitle'), `<p class="kwarn">${esc(t('pushErr_' + r.error))}</p>`, '');
  S._push.hash = r.hash;
  const warn = pushWarnings(s, plan, tg.create), any = r.changes && r.changes.length;
  showDialog('pushdlg', t('pushTitle'), `<p>${t(r.created ? 'pushWhereNew' : 'pushWhere', {f: `<code>${esc(r.file)}</code>`, v: tg.tier, p: `<code>${esc(shortPath(tg.path))}</code>`})}</p>` +
    (warn.length ? warn.map(w => `<p class="kwarn">${w}</p>`).join('') : '') + diffHTML(r.before, r.after) +
    `<p class="muted small">${any ? t('pushSafety') : t('pushErr_nothing')}</p>`, any ? `<button class="btn" data-pushgo>${t('pushGo')}</button>` : '');
}
async function pushGo(){
  const P = S._push;
  if (!P || !P.hash || P.busy) return;
  P.busy = true;
  let r;
  try { r = await liveFetch(S.char, '/push?mode=write&hash=' + encodeURIComponent(P.hash) + jobQuery(), {method: 'POST', body: P.body, timeout: 6000}); } catch (e) { r = {error: 'live'}; }
  if (r.error) return showDialog('pushdlg', t('pushTitle'), `<p class="kwarn">${esc(t('pushErr_' + r.error))}</p>`, '');
  // the file holds the draft now; the saved pieces of that set left set_overrides.lua with it
  const s = P.s, map = setOverrides();
  delete S.trial[trialKey(s)];
  // a new version leaves the set's own pieces in test where they are (they are still not in its file)
  if (map[S.job] && !(P.tg && P.tg.create)) { delete map[S.job][s.path]; if (!Object.keys(map[S.job]).length) delete map[S.job]; }
  S.setOv[S.char].at = stamp();
  S._toastSet = s.path; S.toast = doneText('pushDone', r.entry.file);
  // a job the game has not loaded: its export is not read again, the page's copy of the set takes the pieces written
  // (a new version shows once that job is loaded)
  if (!shownJobLoaded()) { if (P.tg && P.tg.create) S.toast += ' ' + t('pushLater', {j: S.job}); else patchSet(s, P.plan); }
  S._push = null; closeOverlay(); save();
  await reloadIfLoaded();
  render();
}
// The page's copy of a set given the pieces a push wrote (a job the game has not loaded: no new export of it comes)
function patchSet(s, plan){
  for (const e of plan) {
    if (e.kind === 'inherit') delete s.pieces[e.slot];
    else s.pieces[e.slot] = e.kind === 'empty' ? {name: 'empty'} : {name: e.piece.name, augs: e.piece.augs};
    if (Array.isArray(s.own)) s.own = e.kind === 'inherit' ? s.own.filter(x => x !== e.slot) : [...new Set(s.own.concat([e.slot]))];
  }
  DATA_GEN++;
}
/* ---- delete: a set and its versions taken out of the set file (set_push.lua, /delete) ---- */
// The sets a job cannot do without, never deleted (as shared/utils/atelier/set_push.lua PROTECTED)
const PROTECTED_SETS = new Set(['precast.WS', 'precast.FC', 'precast.JA', 'precast.RA', 'midcast.RA']);
function deletable(path){
  const keys = segs(path);
  return keys.length > 1 && !PROTECTED_SETS.has(keys.join('.'));
}
function delButton(s){
  if (!deletable(s.path)) return '';
  const live = liveWrite();
  return `<button class="linkbtn delset" data-setdel ${live ? '' : `disabled title="${esc(t('pushNeedsGame'))}"`}>${t('delBtn')}</button>`;
}
async function openDelete(s){
  S._del = {s};
  showDialog('pushdlg', t('delTitle'), `<p class="muted">${t('pushReading')}</p>`, '');
  let r;
  try { r = await liveFetch(S.char, '/delete?mode=preview' + jobQuery(), {method: 'POST', body: s.path, timeout: 6000}); } catch (e) { r = {error: 'live'}; }
  if (!S._del || S._del.s !== s) return;
  if (r.error) return showDialog('pushdlg', t('delTitle'), `<p class="kwarn">${t('pushErr_' + r.error, {l: esc((r.users || []).map(shortPath).join(' · '))})}</p>`, '');
  S._del.hash = r.hash;
  const also = (r.removed || []).filter(x => x !== s.path && shortPath(x) !== shortPath(s.path));
  showDialog('pushdlg', t('delTitle'), `<p>${t('delWhere', {f: `<code>${esc(r.file)}</code>`})}</p>` +
    (also.length ? `<p class="kwarn">${t('delAlso', {l: esc(also.map(shortPath).join(' · '))})}</p>` : '') +
    diffHTML(r.before, '') + `<p class="muted small">${t('delSafety')}</p>`, `<button class="btn danger" data-delgo>${t('delGo')}</button>`);
}
// The page forgets what it kept for the sets taken out (drafts, pieces in test)
function forgetSets(paths){
  const map = setOverrides();
  for (const path of paths) {
    const k = S.char + '|' + S.job + '|' + path;
    delete S.trial[k]; delete S.drafts[k];
    if (map[S.job]) delete map[S.job][path];
  }
  if (map[S.job] && !Object.keys(map[S.job]).length) delete map[S.job];
}
async function delGo(){
  const D = S._del;
  if (!D || !D.hash || D.busy) return;
  D.busy = true;
  let r;
  try { r = await liveFetch(S.char, '/delete?mode=write&hash=' + encodeURIComponent(D.hash) + jobQuery(), {method: 'POST', body: D.s.path, timeout: 6000}); } catch (e) { r = {error: 'live'}; }
  if (r.error) return showDialog('pushdlg', t('delTitle'), `<p class="kwarn">${t('pushErr_' + r.error, {l: esc((r.users || []).map(shortPath).join(' · '))})}</p>`, '');
  forgetSets((r.entry.deleted || []).concat([D.s.path]));
  if (S.setOv[S.char]) S.setOv[S.char].at = stamp();
  S.selPath[S.job] = null; S._found = null;
  S.toast = doneText('delDone', r.entry.file); S._toastSet = null;
  S._del = null; closeOverlay(); save();
  await reloadIfLoaded();
  render();
}
async function openHistory(){
  if (!liveOk()) return showDialog('histdlg', t('histTitle'), `<p class="note">${t('histNeedsGame')}</p>`, '');
  showDialog('histdlg', t('histTitle'), `<p class="muted">${t('pushReading')}</p>`, '');
  let r;
  try { r = await liveFetch(S.char, '/push_history', {timeout: 4000}); } catch (e) { r = {error: 'live'}; }
  if (r.error) return showDialog('histdlg', t('histTitle'), `<p class="kwarn">${esc(t('pushErr_' + r.error))}</p>`, '');
  const list = r.list || [];
  const state = e => e.undone ? `<span class="muted small">${esc(t('histUndone', {d: e.undone}))}</span>`
    : e.undoable ? `<button class="btn ghost" data-pushundo="${e.id}">${t('histUndo')}</button>`
    : `<span class="muted small" title="${esc(t('histLaterTip'))}">${t('histLater')}</span>`;
  // what the entry did: a set deleted, a set created, or pieces changed in a set already there
  const kind = e => e.deleted ? 'delete' : e.created ? 'create' : 'pieces';
  const tag = e => `<span class="histtag ${kind(e)}">${esc(t('histKind_' + kind(e), {n: (e.changes || []).length}))}</span>`;
  const body = list.length ? list.map(e => `<details class="histrow ${e.undone ? 'undone' : ''}"><summary class="histhead">${tag(e)}<b>${esc(e.job)}</b>` +
    `<code>${esc(shortPath(e.path))}</code><span class="muted small">${esc(e.at)}</span><span class="sp"></span>${state(e)}</summary>` +
    `<p class="muted small histfile">${esc(e.file)}</p>` +
    (e.deleted ? `<ul><li><del>${esc(e.deleted.map(shortPath).join(' · '))}</del> ${t('histDeleted')}</li></ul>` : '') +
    `<ul>${(e.changes || []).map(c => `<li><b>${SLOT_NAMES[S.lang][c.slot] || c.slot}</b> ${c.before ? `<del>${esc(c.before)}</del> → ` : '+ '}` +
      `<ins>${esc(c.after || t('histInherit'))}</ins></li>`).join('')}</ul></details>`).join('') : `<p class="muted">${t('histEmpty')}</p>`;
  showDialog('histdlg', t('histTitle'), (S._histToast ? `<p class="ok">${esc(S._histToast)}</p>` : '') + body, '');
  S._histToast = '';
}
let UNDO_BUSY = false;
async function pushUndo(id){
  if (UNDO_BUSY) return;
  UNDO_BUSY = true;
  let r;
  try { r = await liveFetch(S.char, '/push_undo?id=' + id, {method: 'POST', timeout: 5000}); } catch (e) { r = {error: 'live'}; }
  UNDO_BUSY = false;
  if (r.error) return showDialog('histdlg', t('histTitle'), `<p class="kwarn">${esc(t('pushErr_' + r.error))}</p>`, '');
  S._histToast = t('histUndoDone');
  try { await liveFetch(S.char, '/reload', {method: 'POST'}); } catch (e) {}
  // GearSwap reloads: the door comes back on the next load, the list is read again then
  setTimeout(openHistory, 2500);
}
function copyLua(btn){
  const box = $('#luabox'); if (!box) return;
  const done = () => { btn.textContent = t('copied'); };
  box.select();
  if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(box.value).then(done, () => { document.execCommand('copy'); done(); });
  else { document.execCommand('copy'); done(); }
}
/* ---- add set ---- */
let addStep = 0, addFam = null, addBase = null;
function renderAdd(){
  const cards = S._cards || buildCards(data()).cards;
  const steps = [t('step1'),t('step2'),t('step3')].map((s,i) => `<span class="${i===addStep?'on':''}">${i+1}. ${s}</span>`).join('');
  let body;
  if (addStep===0) body = [...new Set(cards.map(c => c.fam))].map(f => `<button class="opt" data-addfam="${f}"><span>${t('fam.'+f)}<small>${t('famWhen.'+f)}</small></span><span>›</span></button>`).join('');
  else if (addStep===1 && addFam === 'ws') body = addWsList(cards);
  else if (addStep===1) body = cards.filter(c => c.fam===addFam).flatMap(c => c.variants.map(v => v.set.path)).map(p =>
      `<button class="opt" data-addbase="${esc(p)}"><span style="font-family:var(--mono);font-size:13px">${esc(p)}</span><span class="state">${t('exists')}</span></button>`).join('') + `<p class="mock">${t('catalog')}</p>`;
  else body = [[t('fromEmpty'),t('fromEmptyD')],[t('fromCopy',{b:shortPath(addBase)}),t('fromCopyD')],[t('fromWorn'),t('fromWornD')]]
      .map(([a,b]) => `<button class="opt" data-close><span>${esc(a)}<small>${esc(b)}</small></span><span>›</span></button>`).join('');
  $('#overlay').innerHTML = `<div class="scrim" data-close></div><div class="dialog" role="dialog" aria-label="${t('addTitle')}"><header><h3>${t('addTitle')}</h3><div class="steps">${steps}</div></header>
    <div class="body">${body}</div><footer><button class="btn ghost" data-back ${addStep===0?'disabled':''}>${t('back')}</button><button class="btn ghost" data-close>${t('cancel')}</button></footer></div>`;
  $('#overlay').hidden = false;
}
// Every weaponskill of the job (export ws_skill): the ones with a set open it, the others can be created
// (sets.precast.WS['X'] = set_combine(sets.precast.WS, {}), written by the game: set_push.lua)
function addWsList(cards){
  const have = {};
  for (const c of cards.filter(c => c.fam === 'ws')) for (const v of c.variants) {
    const name = segs(v.set.path).pop();
    if (!have[name]) have[name] = v.set.path;
  }
  const live = liveWrite();
  const skills = wsSkills(), names = Object.keys(skills).sort((a, b) => a.localeCompare(b));
  const row = n => have[n]
    ? `<button class="opt" data-addopen="${esc(have[n])}"><span>${esc(n)}</span><span class="state">${t('exists')} ›</span></button>`
    : `<button class="opt" data-addws="${esc(n)}" ${live ? '' : `disabled title="${esc(t('pushNeedsGame'))}"`}><span>${esc(n)}</span><span class="state new">${t('addNew')}</span></button>`;
  // one folding group a weapon type: those with a set open first, in each the ones to create first
  const groups = {};
  for (const n of names) (groups[skills[n] || '—'] = groups[skills[n] || '—'] || []).push(n);
  const order = Object.keys(groups).sort((a, b) => groups[b].filter(n => have[n]).length - groups[a].filter(n => have[n]).length || a.localeCompare(b));
  return `<p class="muted small">${t('addWsWhy')}</p>` + order.map(sk => { const list = groups[sk], n = list.filter(x => have[x]).length;
    return `<details class="wsgroup" ${S._wsOpen && S._wsOpen[sk] ? 'open' : ''} data-wsgroup="${esc(sk)}"><summary><b>${esc(sk)}</b>` +
      `<span class="muted small">${t('addWsCount', {n: list.length, h: n})}</span></summary>` +
      list.filter(x => !have[x]).map(row).join('') + list.filter(x => have[x]).map(row).join('') + `</details>`; }).join('');
}
const wsPath = name => 'sets.precast.WS' + (/^[A-Za-z_]\w*$/.test(name) ? '.' + name : '["' + name.replace(/"/g, '\\"') + '"]');
// A new weaponskill set: the game shows where it goes, then writes it (same preview, backup and history as a push)
async function openCreate(name){
  const path = wsPath(name);
  S._create = {path};
  showDialog('pushdlg', t('addTitle'), `<p class="muted">${t('pushReading')}</p>`, '');
  let r;
  try { r = await liveFetch(S.char, '/push?mode=preview' + jobQuery(), {method: 'POST', body: path + '\n', timeout: 6000}); } catch (e) { r = {error: 'live'}; }
  if (!S._create || S._create.path !== path) return;
  if (r.error) return showDialog('pushdlg', t('addTitle'), `<p class="kwarn">${esc(t('pushErr_' + r.error))}</p>`, '');
  S._create.hash = r.hash;
  showDialog('pushdlg', t('addTitle'), `<p>${t('addWhere', {p: `<code>${esc(shortPath(path))}</code>`, f: `<code>${esc(r.file)}</code>`})}</p>` +
    diffHTML(r.before, r.after) + `<p class="muted small">${t('addSafety')}</p>`, `<button class="btn" data-creatego>${t('addGo')}</button>`);
}
async function createGo(){
  const C = S._create;
  if (!C || !C.hash || C.busy) return;
  C.busy = true;
  let r;
  try { r = await liveFetch(S.char, '/push?mode=write&hash=' + encodeURIComponent(C.hash) + jobQuery(), {method: 'POST', body: C.path + '\n', timeout: 6000}); } catch (e) { r = {error: 'live'}; }
  if (r.error) return showDialog('pushdlg', t('addTitle'), `<p class="kwarn">${esc(t('pushErr_' + r.error))}</p>`, '');
  S.selPath[S.job] = C.path; S._found = null; S._toastSet = C.path; S.toast = doneText('addDone', r.entry.file);
  S._create = null; closeOverlay(); save();
  await reloadIfLoaded();
  render();
}
