// GearSwap Atelier · push.js: push, delete, history, a new set
// (loaded in the order of atelier/src/legacy/files.ts)
/* ---- push: the set written into the player's set file (shared/utils/atelier/set_push.lua) ---- */
// Where a push goes. Under the Group, Solo or Trust profile, a weaponskill or engaged set's draft belongs to that profile's
// version (sets.precast.WS['X'].Solo, sets.engaged.PDT.Solo, worn by shared/utils/party/support_tier.lua): written as a new
// set_combine of the set when the file has none (create), opened to work on when it has one (exists)
function pushTarget(s){
  const tier = buffTier();
  if (tier === 'Full' || !TIERED.test(s.path) || /\.(Group|Solo|Trust)$/.test(s.path)) return {path: s.path};
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
    // Saboteur's set is equipped over the enfeeble's (RDM_MIDCAST.lua): an `empty` there would strip the
    // enfeeble's piece, so a slot emptied in it loses its line instead (push of 2026-10-16: all slots empty but hands)
    if (!target || isEmpty(target)) return {slot, kind: (base && bEmpty) || sabOverlay(s) ? 'inherit' : 'empty'};
    if (base && !bEmpty && samePiece(target, bp)) return {slot, kind: 'inherit'};
    // the only copy the player owns: its name is enough, the file's variable for it can be used
    return pushEntry(slot, target, owned);
  });
}
const pushLine = e => [e.slot, e.kind].concat(e.piece ? [e.piece.name].concat(e.kind === 'piece' ? e.piece.augs || [] : []) : []).join('\t');
function pushWarnings(s, plan, fresh){
  const owned = ownedOf() || {}, out = [];
  // a piece counted above your copy: a rank higher than the one //gs c gearscan read on it, a cape at its maximum (never
  // a rank piece at the very rank you hold: Kgt. Beads +2 R25 is yours as it is)
  const above = (slot, p) => { if (p.capeMax) return true; if (p.rank == null) return false;
    const mine = (owned[slot] || []).filter(x => x.name === p.name).map(x => ownRank({name: x.name, id: x.id, augs: x.augs}).rank).filter(r => r != null);
    return !mine.length || p.rank > Math.max(...mine); };
  for (const e of plan) if (e.piece && above(e.slot, e.piece)) out.push(t('pushNotYet', {p: esc(e.piece.name)}));
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
  if (r.error) return showDialog('pushdlg', t('pushTitle'), mogSorryHTML(esc(t('pushErr_' + r.error))), '');
  S._push.hash = r.hash;
  const warn = pushWarnings(s, plan, tg.create), any = r.changes && r.changes.length;
  // in plain words, the file's lines in a fold (atelier/src/screens/dialogs/pushview.ts)
  ATELIER_DIALOG.show({cls: 'pushdlg', titleHtml: t('pushTitle'), push: ATELIER_DIALOG.pushView(s, tg, plan, r, warn, any), buttonsHtml: any ? `<button class="btn" data-pushgo>${t('pushGo')}</button>` : ''});
  // nothing to change: the file holds these pieces already (pushed before the page kept its pushes, or written by
  // hand), so the page's copies of the set take them, the trial with them (after the window
  // is drawn: its rows say what the file held)
  if (!any && !tg.create) { pushedKeep(s, plan); delete S.trial[trialKey(s)]; save(); render(); }
}
async function pushGo(){
  const P = S._push;
  if (!P || !P.hash || P.busy) return;
  P.busy = true;
  let r;
  try { r = await liveFetch(S.char, '/push?mode=write&hash=' + encodeURIComponent(P.hash) + jobQuery(), {method: 'POST', body: P.body, timeout: 6000}); } catch (e) { r = {error: 'live'}; }
  if (r.error) return showDialog('pushdlg', t('pushTitle'), mogSorryHTML(esc(t('pushErr_' + r.error))), '');
  // the file holds the draft now; the saved pieces of that set left set_overrides.lua with it
  const s = P.s, map = setOverrides();
  delete S.trial[trialKey(s)];
  // a new version leaves the set's own pieces in test where they are (they are still not in its file)
  if (map[S.job] && !(P.tg && P.tg.create)) { delete map[S.job][s.path]; if (!Object.keys(map[S.job]).length) delete map[S.job]; }
  S.setOv[S.char].at = stamp();
  S._toastSet = s.path; S.toast = doneText('pushDone', r.entry.file);
  // the page's copies of the set take the pieces written now and after a reload, loaded job or not (pushedKeep);
  // a new version shows once that job is exported again
  if (P.tg && P.tg.create) { if (!shownJobLoaded()) S.toast += ' ' + t('pushLater', {j: S.job}); }
  else pushedKeep(s, P.plan);
  S._push = null; closeOverlay(); save();
  await reloadIfLoaded();
  render();
}
/* ---- what a push wrote, kept until that job's exports are newer (S.pushed, kept with the page's state) ---- */
// A push is seen at once and stays seen: the page lays what was written on every copy of the set (each subjob's
// export of that job) older than the push, at each read of the exports, until the game or Relire exports that job
// again. Without it a job the game had not loaded showed its old set again once the page was reloaded, its search
// offered the pieces written again and the push said "nothing to change" (Tetsouo's BLM IntEnfeebles, 2026-10-22)
function pushedKeep(s, plan){
  S.pushed = (S.pushed || []).filter(x => !(x.c === S.char && x.j === S.job && x.path === s.path));
  S.pushed.push({c: S.char, j: S.job, path: s.path, at: stamp(),
    plan: plan.map(e => ({slot: e.slot, kind: e.kind, piece: e.piece ? {name: e.piece.name, augs: e.piece.augs} : null}))});
  pushedApply();
}
// A delete kept the same way: the set and the names that went with it leave the page's copies (x.gone)
function deletedKeep(paths){
  const gone = [...new Set(paths)];
  S.pushed = (S.pushed || []).filter(x => !(x.c === S.char && x.j === S.job && gone.includes(x.path)));
  S.pushed.push({c: S.char, j: S.job, path: gone[0], at: stamp(), gone});
  pushedApply();
}
// Each kept push or delete on the exports of its job not newer than it; one every export of its job is newer than
// is dropped (the files hold it, and maybe more since)
function pushedApply(){
  if (!S.pushed || !S.pushed.length) return;
  S.pushed = S.pushed.filter(x => {
    const old = Object.values(exportsOf(x.c, x.j)).filter(d => (d.at || '') <= x.at);
    for (const d of old) {
      if (x.gone) { dropSets(d, x.gone); continue; }
      const s = (d.sets || []).find(y => y.path === x.path);
      if (s) patchSet(s, x.plan);
    }
    return old.length > 0;
  });
}
// An export's copy without the sets deleted: theirs and the names they went by
function dropSets(d, gone){
  if (!d.sets) return;
  const before = d.sets.length;
  d.sets = d.sets.filter(x => !gone.includes(x.path)).map(x => x.aliases && x.aliases.some(a => gone.includes(a))
    ? Object.assign({}, x, {aliases: x.aliases.filter(a => !gone.includes(a))}) : x);
  if (d.sets.length !== before) DATA_GEN++;
}
// The page's copy of a set given the pieces a push wrote
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
async function openDelete(s){
  S._del = {s};
  showDialog('pushdlg', t('delTitle'), `<p class="muted">${t('pushReading')}</p>`, '');
  let r;
  try { r = await liveFetch(S.char, '/delete?mode=preview' + jobQuery(), {method: 'POST', body: s.path, timeout: 6000}); } catch (e) { r = {error: 'live'}; }
  if (!S._del || S._del.s !== s) return;
  if (r.error) return showDialog('pushdlg', t('delTitle'), mogSorryHTML(t('pushErr_' + r.error, {l: esc((r.users || []).map(shortPath).join(' · '))})), '');
  S._del.hash = r.hash;
  const also = (r.removed || []).filter(x => x !== s.path && shortPath(x) !== shortPath(s.path));
  ATELIER_DIALOG.show({cls: 'pushdlg', titleHtml: t('delTitle'), push: ATELIER_DIALOG.delView(s, r, also), buttonsHtml: `<button class="btn danger" data-delgo>${t('delGo')}</button>`});
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
  if (r.error) return showDialog('pushdlg', t('delTitle'), mogSorryHTML(t('pushErr_' + r.error, {l: esc((r.users || []).map(shortPath).join(' · '))})), '');
  forgetSets((r.entry.deleted || []).concat([D.s.path]));
  // gone from the page at once and after a reload, loaded job or not (deletedKeep)
  deletedKeep([D.s.path].concat(r.entry.deleted || []));
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
  if (r.error) return showDialog('histdlg', t('histTitle'), mogSorryHTML(esc(t('pushErr_' + r.error))), '');
  // the list: drawn by the Svelte application (atelier/src/screens/dialogs/history.ts)
  ATELIER_DIALOG.show({cls: 'histdlg', titleHtml: t('histTitle'), history: ATELIER_DIALOG.historyView(r.list || [], S._histToast || '')});
  S._histToast = '';
}
let UNDO_BUSY = false;
async function pushUndo(id){
  if (UNDO_BUSY) return;
  UNDO_BUSY = true;
  let r;
  try { r = await liveFetch(S.char, '/push_undo?id=' + id, {method: 'POST', timeout: 5000}); } catch (e) { r = {error: 'live'}; }
  UNDO_BUSY = false;
  if (r.error) return showDialog('histdlg', t('histTitle'), mogSorryHTML(esc(t('pushErr_' + r.error))), '');
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
/* ---- add set (the window: add_set.js) ---- */
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
  S._create = {path, body: path + '\n'};
  showDialog('pushdlg', t('addTitle'), `<p class="muted">${t('pushReading')}</p>`, '');
  let r;
  try { r = await liveFetch(S.char, '/push?mode=preview' + jobQuery(), {method: 'POST', body: path + '\n', timeout: 6000}); } catch (e) { r = {error: 'live'}; }
  if (!S._create || S._create.path !== path) return;
  if (r.error) return showDialog('pushdlg', t('addTitle'), mogSorryHTML(esc(t('pushErr_' + r.error))), '');
  S._create.hash = r.hash;
  ATELIER_DIALOG.show({cls: 'pushdlg', titleHtml: t('addTitle'), push: ATELIER_DIALOG.addSetView(path, r), buttonsHtml: `<button class="btn" data-creatego>${t('addGo')}</button>`});
}
async function createGo(){
  const C = S._create;
  if (!C || !C.hash || C.busy) return;
  C.busy = true;
  let r;
  try { r = await liveFetch(S.char, '/push?mode=write&hash=' + encodeURIComponent(C.hash) + jobQuery(), {method: 'POST', body: C.body || C.path + '\n', timeout: 8000}); } catch (e) { r = {error: 'live'}; }
  if (r.error) return showDialog('pushdlg', t('addTitle'), mogSorryHTML(esc(t('pushErr_' + r.error))), '');
  S.selPath[S.job] = C.path; S._found = null; S._toastSet = C.path; S.toast = doneText('addDone', r.entry.file);
  S._create = null; closeOverlay(); save();
  await reloadIfLoaded();
  render();
}
