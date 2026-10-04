// the weapon groups of the weaponskill list stay as opened (toggle does not bubble: caught on the way down)
document.addEventListener('toggle', e => { const g = e.target && e.target.dataset && e.target.dataset.wsgroup;
  if (g) { S._wsOpen = S._wsOpen || {}; S._wsOpen[g] = e.target.open; }
  if (e.target && e.target.dataset && 'rdcalc' in e.target.dataset) S._rdOpen = e.target.open;
  if (e.target && e.target.dataset && 'lgfold' in e.target.dataset) S._lgOpen = e.target.open; }, true);
document.addEventListener('click', e => {
  const b = e.target.closest('[data-unslot],[data-folderno],button,[data-close],tr[data-job],[data-bfold]'); if (!b) return; const d = b.dataset;
  if (d.unslot) { setTrial(shownSet(S._cards[+d.card], +d.card), d.unslot, undefined); $('#tip').hidden = true; render(); return; }
  if (d.char) { S.char = d.char; S.job = null; closeOverlay(); render(); return; }
  if (d.lang) { S.lang = d.lang; render(); return; }
  if (d.themeSet) { S.theme = d.themeSet; render(); return; }
  if ('job' in d) { S.job = d.job || null; S.section = 'sets'; S.q = ''; render(); scrollTo({top:0}); return; }
  if (d.section) { S.section = d.section; render(); return; }
  if (d.pick) { S.sel[S.job] = +d.pick; if (d.vpick != null) S.variant[S.job+'|'+d.pick] = +d.vpick; render(); return; }
  if (d.variant) { S.variant[S.job+'|'+d.card] = +d.variant; render(); return; }
  if (d.slot) { openSlot(+d.card, d.slot); return; }
  if (d.try != null && S._drawer) { const o = S._drawOpts[+d.try], mx = e.target.closest('[data-trymax]');
    const best = o.upgrade && (mx || e.shiftKey);
    // a hand: the same choice as the weapon menus (a weaponskill's held weapon / off hand, an engaged set's forced
    // ones), never a tried piece a push could write into the set; the set's own piece back to Auto
    if (['main', 'sub'].includes(S._drawer.slot) && family(S._drawer.set.path, S._drawer.set.pieces) !== 'weapons')
      chooseHand(S._drawer.set, S._drawer.slot, best ? Object.assign({}, o.upgrade.piece) : o.orig ? null : {name: o.piece.name, augs: o.piece.augs});
    else setTrial(S._drawer.set, S._drawer.slot, best ? Object.assign({}, o.upgrade.piece) : o.orig ? undefined : Object.assign({}, o.piece));
    $('#tip').hidden = true; closeOverlay(); render(); return; }
  if ('trykeep' in d) { const s = shownSet(S._cards[S.sel[S.job]], S.sel[S.job]), k = trialKey(s), dr = S.drafts[k] = S.drafts[k] || {};
    const now = new Date(), hm = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');
    dr.kept = (dr.kept || []).concat([{name: t('keptName', {n: (dr.kept || []).length + 1, t: buffTier(), at: hm}), tr: JSON.parse(JSON.stringify(S.trial[k] || {}))}]);
    S._toastSet = s.path; S.toast = t('keptDone'); render(); return; }
  if (d.keptload != null) { const s = shownSet(S._cards[S.sel[S.job]], S.sel[S.job]), k = trialKey(s), x = ((S.drafts[k] || {}).kept || [])[+d.keptload];
    if (x) { S.trial[k] = JSON.parse(JSON.stringify(x.tr)); if (!Object.keys(S.trial[k]).length) delete S.trial[k]; }
    closeOverlay(); render(); return; }
  if (d.keptdel != null) { const s = shownSet(S._cards[S.sel[S.job]], S.sel[S.job]), dr = S.drafts[trialKey(s)] || {};
    dr.kept = (dr.kept || []).filter((_, i) => i !== +d.keptdel); render(); openCompare(s); return; }
  if ('cmpopen' in d) { openCompare(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); return; }
  if ('tryprev' in d) { const s = shownSet(S._cards[S.sel[S.job]], S.sel[S.job]), k = trialKey(s), dr = S.drafts[k] || {};
    if (dr.prev && Object.keys(dr.prev).length) S.trial[k] = dr.prev; else delete S.trial[k];
    delete dr.prev; delete dr.info; render(); return; }
  if ('veropen' in d) { openVersion(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); return; }
  if ('pushopen' in d) { openPush(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); return; }
  if ('pushgo' in d) { pushGo(); return; }
  if ('setdel' in d) { openDelete(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); return; }
  if ('delgo' in d) { delGo(); return; }
  if ('optstop' in d) { optStop(); return; }
  if ('orhide' in d) { closeOverlay(); return; }
  if (d.help) { S._help = S._help === d.help ? null : d.help; render(); return; }
  if ('tiercost' in d) { openTierCost(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); return; }
  if ('optws' in d) { S._optScratch = d.optws === 'best'; optimizeWs(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); return; }
  if ('opteng' in d) { S._optScratch = d.opteng === 'best'; optimizeEngaged(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); return; }
  if ('cmpmore' in d) { S._cmpMore = !S._cmpMore; openCompare(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); return; }
  if ('pushhist' in d) { openHistory(); return; }
  if (d.pushundo) { e.preventDefault(); pushUndo(+d.pushundo); return; }
  if ('showjunk' in d && S._drawer) { S._showJunk = !S._showJunk; openSlot(S._drawer.ci, S._drawer.slot); return; }
  if ('tryempty' in d && S._drawer) { setTrial(S._drawer.set, S._drawer.slot, null); closeOverlay(); render(); return; }
  if ('tryundo' in d) { const s = shownSet(S._cards[S.sel[S.job]], S.sel[S.job]), k = trialKey(s), dr = S.drafts[k];
    delete S.trial[k]; if (dr) { delete dr.prev; delete dr.info; } render(); return; }
  if ('trysave' in d) { const s = shownSet(S._cards[S.sel[S.job]], S.sel[S.job]); S._toastSet = s.path; saveSet(s); return; }
  if ('setrevert' in d) { const s = shownSet(S._cards[S.sel[S.job]], S.sel[S.job]); S._toastSet = s.path; revertSet(s); return; }
  if ('trylua' in d) { openLua(shownSet(S._cards[S.sel[S.job]], S.sel[S.job])); return; }
  if ('copylua' in d) { copyLua(b); return; }
  if ('folderpick' in d && S._folder) { S._folder.pick(); return; }
  if ('folderno' in d && S._folder) { S._folder.cancel(); return; }
  if (d.keyedit) { S.toast = ''; openKeyEdit(+d.keyedit); return; }
  if ('kok' in d && KEYEDIT) { setKey(data().keys[KEYEDIT.i], KEYEDIT.key); KEYEDIT = null; closeOverlay(); render(); return; }
  if ('knone' in d && KEYEDIT) { KEYEDIT.key = ''; renderKeyEdit(); return; }
  if ('kfile' in d && KEYEDIT) { KEYEDIT.key = fileKey(data().keys[KEYEDIT.i]); renderKeyEdit(); return; }
  if ('keysall' in d) { S.keysAll = !S.keysAll; render(); return; }
  if ('keyssave' in d) { saveKeys(); return; }
  if ('keysundo' in d) { delete S.keyOv[S.char]; S.keyDirty[S.char] = false; S.toast = ''; render(); return; }
  if (d.fsrc) { S.forceSrc = d.fsrc; if (d.fsrc === 'game' && !window.ATELIER_CATALOG) loadCatalog(render); save(); render(); return; }
  if (d.wmode) { const k = S.char + '|' + S.job + '|' + d.wmode; if (d.wval) S.weapons[k] = d.wval; else delete S.weapons[k]; render(); return; }
  if (d.jobkeep) { S.job = d.jobkeep; S.q = ''; render(); return; }
  if (d.simpick) { const [k, ...n] = d.simpick.split('|'); Object.assign(simState(), {kind: k, name: n.join('|')}); simRun(); return; }
  if ('statpick' in d) { openStatPick(); return; }
  if (d.statsort) { S.statSort = d.statsort; S.statPreset = ''; save(); openStatPick(); render(); return; }
  if ('statsave' in d) { const n = ($('#statpresetname') || {}).value.trim(); if (!n) return;
    S.statPresets[n] = {hide: Object.assign({}, S.statHide), sort: S.statSort, only: S.statOnlyWant}; S.statPreset = n; save(); openStatPick(); render(); return; }
  if (d.statpreset) { const f = S.statPresets[d.statpreset]; if (!f) return;
    S.statHide = Object.assign({}, f.hide); S.statSort = f.sort || 'group'; S.statOnlyWant = !!f.only; S.statPreset = d.statpreset; save(); openStatPick(); render(); return; }
  if (d.statdel) { delete S.statPresets[d.statdel]; if (S.statPreset === d.statdel) S.statPreset = ''; save(); openStatPick(); return; }
  if (d.statgroup) { const [g, on] = d.statgroup.split('|');
    document.querySelectorAll('.g-' + g + ' .statpick').forEach(x => { if (on === '1') delete S.statHide[x.dataset.stat]; else S.statHide[x.dataset.stat] = 1; });
    openStatPick(); render(); return; }
  if ('statall' in d) { S.statHide = {}; openStatPick(); render(); return; }
  if ('statnone' in d) { S.statHide = {}; document.querySelectorAll('.statpick').forEach(x => { S.statHide[x.dataset.stat] = 1; }); openStatPick(); render(); return; }
  if (d.simgroup) { S.simOpen[d.simgroup] = !S.simOpen[d.simgroup]; render(); return; }
  if (d.simopt) { const [k, v] = d.simopt.split('|'), st = simState(); st[k] = v;
    // an action the new target leaves out of the list is dropped
    const aim = S._simActions && S._simActions.list && S._simActions.list.aim || {};
    if (k === 'target' && st.name && !aimHas(aim[st.name], v)) { st.name = null; S._simResult = null; render(); return; }
    simRun(); if (!st.name) render(); return; }
  if ('gsunload' in d) { linkGearSwap('unload'); return; }
  if ('gsload' in d) { linkGearSwap('load'); return; }
  if ('livereload' in d) { liveReload(false); return; }
  if ('liverestart' in d) { liveReload(true); return; }
  if ('livejump' in d) { const L = S._live[S.char]; S.job = L.job; S.subs[S.char + '|' + L.job] = L.sub; render(); return; }
  if (d.simbuff) { const st = simState(); st.buffs = toggleBuff(st.buffs || [], d.simbuff); simRun(); return; }
  if ('wstp' in d) { S.wsTp = d.wstp ? +d.wstp : null; render(); return; }
  if ('macroalt' in d) { S.macroAlt[S.char + '|' + S.job] = d.macroalt; render(); return; }
  if (d.famall) { for (const f of S._fams || []) S.famOpen[S.job + '|' + f] = d.famall === '1'; render(); return; }
  if (d.wskill) { const k = S.job + '|' + d.wskill; S._wsList = Object.assign({}, S._wsList, {[k]: !(S._wsList || {})[k]}); render(); return; }
  if (d.stattab) { S._statTab = d.stattab; render(); return; }
  if (d.famtoggle) { const k = S.job + '|' + d.famtoggle; S.famOpen[k] = !S.famOpen[k]; render(); return; }
  if (d.fold) { S.boxOpen[d.fold] = !S.boxOpen[d.fold]; render(); return; }
  if (d.marcato != null) { const b = buffState();
    if (d.marcato === '' || b.marcato === +d.marcato) { if (b.marcato != null) delete b.marcato; else b.marcato = 0; } else b.marcato = +d.marcato;
    save(); render(); return; }
  if (d.savagery != null) { const b = buffState(); b[d.wparty ? 'pSavagery' : 'savagery'] = +d.savagery; save(); render(); return; }
  if ('agoge' in d) { const b = buffState(), k = d.wparty ? 'pNoAgoge' : 'noAgoge'; if (b[k]) delete b[k]; else b[k] = true; save(); render(); return; }
  if (d.poff) { const b = buffState(); b.off = Object.assign({}, b.off); b.off[d.poff] = !b.off[d.poff]; if (!b.off[d.poff]) delete b.off[d.poff]; save(); render(); return; }
  if (d.rolljob != null) { const b = buffState(), k = 'roll' + d.rolljob + 'job'; if (b[k]) delete b[k]; else b[k] = true; save(); render(); return; }
  if (d.rollcc != null) { const b = buffState(); if (b.rollCC != null && +b.rollCC === +d.rollcc) delete b.rollCC; else b.rollCC = +d.rollcc; save(); render(); return; }
  if (d.bfold) { S.bFold = Object.assign({}, S.bFold); S.bFold[d.bfold] = !S.bFold[d.bfold]; save(); render(); return; }
  if (d.ptab) { S._pTab = d.ptab; render(); return; }
  if (d.foetab) { S._foeTab = d.foetab; render(); return; }
  if (d.foeseg) { const b = buffState(); if (b[d.foeseg] === d.v) delete b[d.foeseg]; else b[d.foeseg] = d.v; save(); render(); return; }
  if (d.foeja) { const b = buffState(), l = new Set(b.foeJa || []);
    if (l.has(d.foeja)) l.delete(d.foeja); else { l.add(d.foeja); for (const n of elemClash(d.foeja)) l.delete(n);
      const ex = (FOE_JA_FX[d.foeja] || {}).excl;
      if (ex) for (const n of [...l]) if (n !== d.foeja && FOE_JA_FX[n] && FOE_JA_FX[n].excl === ex) l.delete(n); }
    if (l.size) b.foeJa = [...l]; else delete b.foeJa; save(); render(); return; }
  if ('tgtback' in d) { S._tgtPick = false; openBuffs(); return; }
  if ('tgtpick' in d) { S._buffDlg = false; openTargetPick(); return; }
  if ('pickenemy' in d) { const b = buffState(); if (d.pickenemy) b.enemy = d.pickenemy; else delete b.enemy; S._tgtPick = false; render(); return; }
  if (d.buffflag) { const b = buffState(); b[d.buffflag] = !b[d.buffflag]; if (!b[d.buffflag]) delete b[d.buffflag];
    const other = {auspice: 'enspell', enspell: 'auspice'}[d.buffflag];
    if (other && b[d.buffflag]) delete b[other];
    render(); return; }
  if ('buffopen' in d) { S._tgtDlg = false; openBuffs(); return; }
  if ('targetopen' in d) { openTarget(); return; }
  if ('debugcalc' in d) { openDebug(); return; }
  if ('dbgcopy' in d) { const ta = $('#dbgtext'); if (ta) { ta.select(); const done = () => { b.textContent = t('dbgCopied'); };
    const old = () => { if (document.execCommand('copy')) done(); };
    try { navigator.clipboard.writeText(ta.value).then(done, old); } catch (e) { old(); } } return; }
  if ('buffreset' in d) { S.buffs[buffKey()] = {}; render(); return; }
  // the profile's usual party buffs; what is yours (food, aftermath, target, abilities) stays
  if ('buffendgame' in d) { const old = buffState(), b = tierBuffs(buffTier());
    for (const k of PERSONAL) if (old[k] !== undefined) b[k] = old[k];
    S.buffs[buffKey()] = b; render(); return; }
  if (d.bufftier) { setBuffTier(d.bufftier); render(); return; }
  if (d.ja) { const b0 = buffState(), role = jaRole(d.ja), ja = b0[role] = b0[role] || {}, off = b0.jaOff = b0.jaOff || {};
    if (jaOn(b0, d.ja)) { delete ja[d.ja]; off[d.ja] = 1; }
    else { ja[d.ja] = 1; delete off[d.ja];
      // abilities that overwrite each other (BG Wiki: Blood Rage and Warcry): turning one on turns the others off
      const ex = (JAS[d.ja] || {}).excl;
      if (ex) for (const [n, a] of Object.entries(JAS)) if (n !== d.ja && a.excl === ex) delete ja[n]; }
    render(); return; }
  if (d.action==='add') { addStep = 0; renderAdd(); return; }
  if (d.action==='meritreset') { delete S.meritEdits[meritKey()]; render(); return; }
  if (d.addfam) { addFam = d.addfam; addStep = 1; renderAdd(); return; }
  if (d.addopen) { S.selPath[S.job] = d.addopen; S._found = null; closeOverlay(); render(); return; }
  if (d.addws) { openCreate(d.addws); return; }
  if ('creatego' in d) { createGo(); return; }
  if (d.addbase) { addBase = d.addbase; addStep = 2; renderAdd(); return; }
  if ('back' in d) { addStep = Math.max(0, addStep-1); renderAdd(); return; }
  if ('close' in d) closeOverlay();
});
document.addEventListener('input', e => {
  if (e.target.id === 'setq') { S.q = e.target.value; render(); }
  if (e.target.id === 'simq') { simState().q = e.target.value; render(); }
  if (e.target.id === 'tgtq') { const q = e.target.value.trim().toLowerCase();
    for (const r of document.querySelectorAll('.tprow')) r.hidden = !!q && !r.dataset.q.includes(q);
    for (const z of document.querySelectorAll('.tpzone')) { const any = [...z.querySelectorAll('.tprow')].some(r => !r.hidden);
      z.hidden = !any; z.open = !!q && any; } return; }
  // the picker's "every item in the game": the catalogue loads once, the drawer is drawn again
  if ('allitems' in e.target.dataset && S._drawer) { S.allItems = e.target.checked; save();
    const {ci, slot} = S._drawer, reopen = () => { openSlot(ci, slot); const q = $('#drawq'); if (q) q.focus(); };
    if (S.allItems) loadCatalog(reopen); else reopen(); return; }
  // the drawer's search: hides the pieces that do not match, nothing re-drawn
  if (e.target.id === 'drawq') { const q = e.target.value.trim().toLowerCase();
    document.querySelectorAll('.choice [data-try]').forEach(el => { el.hidden = q && !el.textContent.toLowerCase().includes(q); });
    document.querySelectorAll('.choice [data-grp]').forEach(el => { el.hidden = !!q; }); }
  // a merit level typed in the Merits tab: kept while it differs from the game's
  if (e.target.classList.contains('meritin')) {
    const m = (meritList() || []).find(x => x.key === e.target.dataset.merit), v = parseInt(e.target.value, 10);
    const edits = S.meritEdits[meritKey()] = S.meritEdits[meritKey()] || {};
    if (!m || isNaN(v)) return;
    if (v === m.level) delete edits[m.key]; else edits[m.key] = Math.max(0, Math.min(meritCap(m), v));
    render();
  }
});
document.addEventListener('change', e => {
  if (e.target.classList.contains('subsel') && e.target.value) { S.subs[S.char + '|' + S.job] = e.target.value; render(); }
  if (e.target.classList.contains('jobsel')) { S.job = e.target.value || null; S.section = 'sets'; S.q = ''; render(); }
  if (e.target.classList.contains('kmod') || e.target.classList.contains('kname')) manualKey();
  if (e.target.classList.contains('tpin')) { const v = Math.max(0, Math.min(3000, Math.round(+e.target.value || 0)));
    if (e.target.dataset.sim) { simState().tp = v || 3000; simRun(); } else { S.wsTp = v || null; render(); } return; }
  // the optimizer's settings, kept for the next run
  if (e.target.dataset && e.target.dataset.optopt) { const v = e.target.type === 'checkbox' ? e.target.checked : e.target.value;
    S.optOpts = Object.assign({}, S.optOpts, {[e.target.dataset.optopt]: v}); save();
    // the objective shows or hides the TP range; the range reads back rounded to 250
    if (['obj', 'tpFrom', 'tpTo', 'engObj', 'engAt'].includes(e.target.dataset.optopt)) render();
    return; }
  if (e.target.id === 'statonly') { S.statOnlyWant = e.target.checked; S.statPreset = ''; save(); openStatPick(); render(); return; }
  if (e.target.classList.contains('statpick')) { S.statPreset = ''; const k = e.target.dataset.stat; if (e.target.checked) delete S.statHide[k]; else S.statHide[k] = 1;
    const sc = ($('.statpickdlg .body') || {}).scrollTop; openStatPick(); const b = $('.statpickdlg .body'); if (b) b.scrollTop = sc; render(); }
  if (e.target.classList.contains('simrecasts')) { simState().recasts = e.target.checked; simRun(); }
  if (e.target.dataset && e.target.dataset.simstate) { const st = simState(); st.states = st.states || {}; st.states[e.target.dataset.simstate] = e.target.value; simRun(); }
  if (e.target.classList.contains('klayout')) { S.layout = e.target.value; renderKeyEdit(); save(); }
  if (e.target.classList.contains('fslot')) { const slot = e.target.dataset.fslot;
    if (e.target.value === 'cur') return;
    const x = e.target.value === '' ? null : forceList(slot)[+e.target.value];
    setForce(slot, x ? optPieces({[slot]: {name: x.name, augs: x.augs}})[slot] : null); save(); render(); return; }
  if (e.target.classList.contains('wmenu')) { const k = S.char + '|' + S.job + '|' + e.target.dataset.wmode;
    if (e.target.value) S.weapons[k] = e.target.value; else delete S.weapons[k]; render(); return; }
  if (e.target.classList.contains('heldsubsel') && e.target.value === 'cur') return;
  if (e.target.classList.contains('heldsubsel')) { const k = heldKey(e.target.dataset.heldws), x = e.target.value === '' ? null : forceList('sub')[+e.target.value];
    S.heldSub = Object.assign({}, S.heldSub); if (x) S.heldSub[k] = optPieces({sub: {name: x.name, augs: x.augs}}).sub; else delete S.heldSub[k];
    save(); render(); return; }
  if (e.target.classList.contains('heldsel')) { const k = heldKey(e.target.dataset.heldws);
    if (e.target.value) S.held[k] = e.target.value; else delete S.held[k]; render(); return; }
  if (e.target.classList.contains('wmore') && e.target.value) { S.weapons[S.char + '|' + S.job + '|' + e.target.dataset.wmode] = e.target.value; render(); }
  if (e.target.classList.contains('buffsel')) { const b0 = buffState(), k = e.target.dataset.buff;
    if (e.target.value === '') delete b0[k]; else b0[k] = e.target.value; render(); }
});
/* ---- the hover card of a piece: what it brings, base and augments apart ---- */
function tipHTML(card, slot){
  const s = shownSet(card.c, card.i);
  return pieceTip(withWeapons(s).pieces[slot], slot, isEmpty(s.pieces[slot]));
}
// The hover card of one piece (a set's, or one offered in the drawer)
function pieceTip(p, slot, emptied){
  const label = SLOT_NAMES[S.lang][slot];
  // a slot the set empties (sets.naked, //gs c naked) stays empty whatever the weapon modes say
  const none = emptied ? t('emptied') : slot === 'main' || slot === 'sub' ? t('emptyWeapon') : t('empty');
  if (!p) return `<div class="th">${icon(null)}<div><b>${label}</b><small>${none}</small></div></div>`;
  const r = pieceStats(p, slot);
  let body = '';
  if (r && r.known) {
    const keys = Object.keys(r.stats).filter(k => r.stats[k].v);
    const order = STAT_GROUPS.flatMap(([g]) => keys.filter(k => statGroup(k) === g).sort(statOrder));
    // The augment part in front of the total: the base is what remains
    const aug = k => r.aug[k] && r.aug[k].v ? `<i class="a">◆${fmtStat(r.aug[k])}</i>` : '';
    const attrs = order.filter(k => statGroup(k) === 'attr'), rest = order.filter(k => statGroup(k) !== 'attr');
    if (attrs.length) body += `<div class="attrs">${attrs.map(k => `<span>${esc(statLabel(k, r.stats[k]))}${aug(k)}<b>${fmtStat(r.stats[k])}</b></span>`).join('')}</div>`;
    body += `<div class="rows">${rest.map(k => `<div class="r"><span title="${esc(statLabel(k, r.stats[k]))}">${esc(statLabel(k, r.stats[k]))}</span><b>${aug(k)}${fmtStat(r.stats[k])}</b></div>`).join('')}</div>`;
    if (r.free.length) body += `<div class="k">${t('effects')}</div><ul>${r.free.map(f => `<li>${esc(f)}</li>`).join('')}</ul>`;
    if (r.cond.length) body += `<div class="k">${t('condTitle')}</div><ul>${r.cond.map(f => `<li>${esc(f)}</li>`).join('')}</ul>`;
  } else body = `<p class="muted">${t('noDesc')}</p>`;
  const weapon = r && r.weapon ? ` · ${Object.entries(r.weapon).map(([k, n]) => `${k} ${n}`).join(' · ')}` : '';
  const rank = r && r.rank != null ? ` · <span class="rk">${r.path ? `Path ${esc(r.path)} · ` : ''}${t('rankShort', {r: r.rank})}${r.rankAssumed ? ' · ' + esc(t('rankAssumed')) : ''}</span>` : '';
  // where GearSwap takes it from (bag = 'wardrobe 3') and its order in a swap (priority)
  const where = [p.bag ? t('tipBag', {b: esc(p.bag)}) : '', p.priority != null ? t('tipPriority', {n: p.priority}) : ''].filter(Boolean).join(' · ');
  return `<div class="th">${icon(p.name)}<div><b>${esc(p.name)}</b><small>${label}${weapon}${rank}${where ? ' · ' + where : ''}</small></div>${rareExHTML(p.name, r && Object.keys(r.aug).length)}</div>${body}`;
}
// Placed beside the hovered slot, on the side with room, kept inside the window
function showTip(el){
  const tip = $('#tip');
  if (el.dataset.simp != null) {
    const [i, slot] = el.dataset.simp.split('|'), p = ((S._simWorn || {})[i] || {})[slot];
    tip.innerHTML = pieceTip(p && p.name !== 'empty' ? p : null, slot);
  } else if (el.dataset.try != null) {
    const o = (S._drawOpts || [])[+el.dataset.try];
    if (!o || !o.piece) return;
    tip.innerHTML = S._shift && o.upgrade ? maxTip(o.upgrade, S._drawer.slot) : pieceTip(o.piece, S._drawer.slot) + (o.upgrade ? `<p class="tiphint">${t('maxHint')}</p>` : '');
  } else {
    const ci = +el.dataset.card, card = S._cards && S._cards[ci];
    if (!card) return;
    const piece = withWeapons(shownSet(card, ci)).pieces[el.dataset.slot], up = piece && upgradeOf(piece);
    tip.innerHTML = S._shift && up ? maxTip(up, el.dataset.slot) : tipHTML({c: card, i: ci}, el.dataset.slot) + (up ? `<p class="tiphint">${t('maxHint')}</p>` : '');
  }
  S._tipEl = el;
  tip.classList.toggle('wide', tip.querySelectorAll('.r').length > 6);
  tip.hidden = false;
  const b = el.getBoundingClientRect(), w = tip.offsetWidth, h = tip.offsetHeight;
  const left = b.right + 8 + w < innerWidth ? b.right + 8 : Math.max(8, b.left - 8 - w);
  tip.style.left = left + 'px';
  tip.style.top = Math.max(8, Math.min(b.top, innerHeight - h - 8)) + 'px';
}
// The best version's card: what is left to do, then its stats
function maxTip(up, slot){
  const todo = up.to ? (up.from != null ? t('upRank', {f: up.from, t: up.to}) : t('upRankUnknown', {t: up.to}))
    : t('upCape') + (up.missing && up.missing.length ? ' · ' + t('upMissing', {m: up.missing.join(', ')}) : '');
  return `<p class="tiphint max">${esc(todo)}</p>` + pieceTip(up.piece, slot);
}
// Shift held: the card shown turns to the best version, and back when released
for (const ev of ['keydown', 'keyup']) document.addEventListener(ev, e => {
  if (e.key !== 'Shift' || S._shift === (ev === 'keydown')) return;
  S._shift = ev === 'keydown';
  if (S._tipEl && !$('#tip').hidden && document.body.contains(S._tipEl)) showTip(S._tipEl);
});
const TIPPED = '.slot[data-slot], .choice [data-try], .slot[data-simp]';
document.addEventListener('mouseover', e => { const el = e.target.closest(TIPPED); if (el && !(el === S._tipEl && !$('#tip').hidden)) showTip(el); });
document.addEventListener('mouseout', e => { if (e.target.closest(TIPPED) && !(e.relatedTarget && e.relatedTarget.closest && e.relatedTarget.closest(TIPPED))) $('#tip').hidden = true; });
document.addEventListener('focusin', e => { const el = e.target.closest('.slot[data-slot]'); if (el) showTip(el); });
document.addEventListener('focusout', e => { if (e.target.closest('.slot[data-slot]')) $('#tip').hidden = true; });
document.addEventListener('scroll', () => { $('#tip').hidden = true; }, true);

document.addEventListener('keydown', e => {
  if ((e.key === 'Enter' || e.key === ' ') && e.target.matches && e.target.matches('span[role="button"]')) { e.preventDefault(); e.stopPropagation(); e.target.click(); return; }
  if (e.key==='Escape') { if (!$('#overlay').hidden && S._tgtPick) { S._tgtPick = false; openBuffs(); } else if (!$('#overlay').hidden) closeOverlay(); else if (e.target.id==='setq' && S.q) { S.q = ''; render(); } return; }
  const field = /^(INPUT|SELECT|TEXTAREA)$/.test(e.target.tagName) && e.target.id !== 'setq';
  if ((e.key==='ArrowDown' || e.key==='ArrowUp') && !field && S.job && S.section==='sets' && $('#overlay').hidden && S._rows && S._rows.length) {
    const ci = S.sel[S.job], cv = Math.min(S.variant[S.job+'|'+ci] ?? 0, S._cards[ci].variants.length - 1);
    const i = S._rows.findIndex(([a, b]) => a === ci && b === cv) + (e.key==='ArrowDown' ? 1 : -1);
    if (i < 0 || i >= S._rows.length) return;
    e.preventDefault(); const [a, b] = S._rows[i]; S.sel[S.job] = a; S.variant[S.job+'|'+a] = b; render();
    const cur = $('.setrow[aria-current="true"]'); if (cur) cur.scrollIntoView({block:'nearest'});
  }
});
function boot(){
  const index = window.ATELIER_INDEX || [];
  // the live link files of every character the index knows (absent when the game never opened the door)
  const chars = [...new Set(index.map(e => (e.file.match(/^([^/]+)\/saved\//) || [])[1]).filter(Boolean))];
  // the index lists the live link files that exist; an index from before lists none: ask for every character's
  const live = window.ATELIER_LIVE_FILES || chars.map(c => `atelier/live_${c}.js`).concat(chars.map(c => `atelier/link_${c}.js`));
  loadScripts(index.map(e => e.file).concat(live), () => {
    setInterval(() => { liveTick(); linkTick(); }, 2000); setTimeout(() => { liveTick(); linkTick(); }, 50);
    // the game's descriptions of every item: a piece a set names but no bag holds still has its stats
    setTimeout(() => loadCatalog(() => loadRanked(() => { canonAll(); if (window.ATELIER_CATALOG || (window.FFXI && FFXI.RANKED)) render(); })), 300);
    // <JOB>_<SUB>.js fill ATELIER_SUBS[char][job][sub]; a <JOB>.js of before 2026-10-01 fills ATELIER[char][job]
    DATA = {}; CHARS = {}; DATA_GEN++;
    const put = (c, j, d) => { if (!d || !d.sets) return; const s = d.sub || 'NONE';
      const m = ((DATA[c] = DATA[c] || {})[j] = DATA[c][j] || {});
      if (!m[s] || (m[s].at || '') < (d.at || '')) m[s] = d; };
    const legacy = window.ATELIER || {}, subs = window.ATELIER_SUBS || {};
    for (const c in legacy) for (const j in legacy[c]) put(c, j, legacy[c][j]);
    for (const c in subs) for (const j in subs[c]) for (const s in subs[c][j]) put(c, j, subs[c][j][s]);
    for (const c in DATA) CHARS[c] = {jobs: Object.keys(DATA[c])};
    if (!CHARS[S.char]) { S.char = Object.keys(CHARS)[0]; S.job = null; }
    if (!S.char) { $('#view').innerHTML = `<div class="placeholder"><p class="display" style="font-size:22px">Atelier</p><p>${t('tagline')}</p><p>${t('none')}</p></div>`; return; }
    // back where the last visit left off, when that job is still exported
    if (S.job && !(DATA[S.char] || {})[S.job]) S.job = null;
    render();
  });
}
boot();
