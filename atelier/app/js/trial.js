// GearSwap Atelier · trial.js: pieces tried, Compare
// (cut from atelier.html, loaded by it in order: see the list there)
/* ---- pieces tried in the page ---- */
const trialKey = s => S.char + '|' + S.job + '|' + s.path;
const trialCount = s => Object.entries(S.trial[trialKey(s)] || {}).filter(([slot, p]) => !heldAlready(s, slot, p)).length;
// A hand chosen for a set (main or sub; null: back to Auto): a weaponskill's set holds it for that weaponskill, any other
// set has it forced in the page, the menus of the set's top following
function chooseHand(s, slot, piece){
  const ws = wsOfSet(s);
  setTrial(s, slot, undefined);
  if (!ws) return setForce(slot, piece ? optPieces({[slot]: piece})[slot] : null);
  const k = heldKey(ws);
  if (slot === 'main') { S.held = Object.assign({}, S.held); if (piece) S.held[k] = piece.name; else delete S.held[k]; }
  else { S.heldSub = Object.assign({}, S.heldSub); if (piece) S.heldSub[k] = optPieces({sub: piece}).sub; else delete S.heldSub[k]; }
  save();
}
function setTrial(s, slot, piece){
  const k = trialKey(s), tr = S.trial[k] = S.trial[k] || {}, dr = S.drafts[k];
  if (dr && dr.info) dr.info.edited = true;
  if (piece === undefined) delete tr[slot]; else tr[slot] = piece;
  if (!Object.keys(tr).length) delete S.trial[k];
}
// The same set without the tried pieces (what the differences compare to)
function withoutTrial(fn){ S._noTrial = true; try { return fn(); } finally { S._noTrial = false; } }
function trialBar(s){
  const row = trialRow(s);
  return row ? `<div class="trybar">${row}</div>` : '';
}
// The pieces tried on a set (by hand or by the optimizer): what they change, then what to do with them
function trialRow(s){
  const n = trialCount(s), changed = Object.keys(s.was || {}), dr = S.drafts[trialKey(s)] || {};
  const toast = S.toast && S._toastSet === s.path ? S.toast : '';
  const kept = (dr.kept || []).length;
  if (!n && !changed.length && !dr.info && !toast && !kept) return '';
  const saved = n > 0 && trialSaved(s), live = liveWrite();
  const msg = n ? (saved ? t('trySaved', {n: `<b>${n}</b>`}) : t('tryBar', {n: `<b>${n}</b>`}))
    : changed.length ? t('setChanged', {s: changed.map(x => SLOT_NAMES[S.lang][x] || x).join(', ')}) : '';
  const by = dr.info ? `<span class="tryby">${esc(t('tryOptBy', {t: dr.info.tier, at: dr.info.at}) + (dr.info.edited ? ' · ' + t('tryEdited') : ''))}</span>` : '';
  const btns = [n || changed.length ? pushButton(s, live) : '',
    n || changed.length || kept ? `<button class="btn ghost" data-cmpopen>${t('cmpBtn')}${kept ? ` <small>${t('keptN', {n: kept})}</small>` : ''}</button>` : '',
    n ? `<button class="btn ghost" data-trykeep title="${esc(t('keepTip'))}">${t('keepBtn')}</button>` : '',
    n && !saved ? `<button class="btn ghost" data-trysave>${t('trySave')}</button>` : ''].join('');
  const links = [n ? `<button class="linkbtn" data-trylua>${t('tryLua')}</button>` : '',
    dr.info && dr.prev ? `<button class="linkbtn" data-tryprev>${t('tryPrev')}</button>` : '',
    n ? `<button class="linkbtn" data-tryundo>${t('tryUndo')}</button>` : changed.length ? `<button class="linkbtn" data-setrevert>${t('setRevert')}</button>` : '']
    .filter(Boolean).join('<span>·</span>');
  return `<div class="tryrow ${saved || (!n && changed.length) ? 'saved' : ''}"><p class="tryline">${by}${msg}${n ? draftGainHTML(s) : ''}</p>` +
    `<div class="dacts">${btns}<span class="sp"></span><span class="dlinks">${links}</span></div>` + (toast ? `<p class="dtoast">${esc(toast)}</p>` : '') + `</div>`;
}
// On a weaponskill set, the damage with the try against your file's set (the engine present)
function draftGainHTML(s){
  if (!wsOfSet(s)) return '';
  const was = withoutTrial(() => wsDamage(s)), now = wsDamage(s);
  if (was == null || now == null || !was) return '';
  const d = (now / was - 1) * 100;
  return ` · ${t('draftGain', {a: fmtDmg(was), b: `<b>${fmtDmg(now)}</b>`})} <span class="${d >= 0 ? 'up' : 'down'}">(${d >= 0 ? '+' : ''}${d.toFixed(1)} %)</span>`;
}
// The push button: to the set, to the profile's new version, or opening the version the file has
function pushButton(s, live){
  const tg = pushTarget(s);
  if (tg.exists) return `<button class="btn" data-veropen title="${esc(t('pushVerOpenTip', {v: tg.tier}))}">${t('pushVerOpen', {v: tg.tier})}</button>`;
  // Full is the weaponskill set itself (GearSwap reads no .Full): said on the button
  const full = buffTier() === 'Full' && TIERED.test(s.path) && !/\.(Group|Solo|Trust)$/.test(s.path);
  const label = tg.create ? t('pushToVer', {v: tg.tier}) : full ? t('pushToFull') : t('pushBtn');
  // the game writes into the files of the job it has loaded: another job there is said, not "the game is off"
  const tip = !live ? t('pushNeedsGame') : tg.create ? t('pushToVerTip', {v: tg.tier}) : full ? t('pushToFullTip') : '';
  return `<button class="btn" data-pushopen ${live ? '' : 'disabled'} ${tip ? `title="${esc(tip)}"` : ''}>${label}</button>`;
}
// The tried pieces as a set_combine to paste in the sets file
function trialLua(s){
  const q = v => '"' + String(v).replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"';
  const tr = S.trial[trialKey(s)] || {};
  const lines = SLOTS.filter(slot => slot in tr).map(slot => { const p = tr[slot];
    return `    ${slot} = ${!p ? 'empty' : p.augs && p.augs.length ? `{ name = ${q(p.name)}, augments = { ${p.augs.map(q).join(', ')} } }` : q(p.name)},`; });
  return `-- Tried in the Atelier\n${s.path} = set_combine(${s.path}, {\n${lines.join('\n')}\n})\n`;
}
function openLua(s){
  $('#overlay').innerHTML = `<div class="scrim" data-close></div><div class="dialog" role="dialog" aria-label="${t('luaTitle')}"><header><h3>${t('luaTitle')}</h3></header>
    <div class="body"><textarea class="luabox" id="luabox" readonly spellcheck="false">${esc(trialLua(s))}</textarea></div>
    <footer><button class="btn ghost" data-close>${t('close')}</button><button class="btn" data-copylua>${t('copy')}</button></footer></div>`;
  $('#overlay').hidden = false;
}
// The set with other tried pieces for a moment (a draft, the file's pieces, none)
function withTrialAs(s, tr, fn){
  const k = trialKey(s), keep = S.trial[k];
  S.trial[k] = tr;
  try { return fn(); } finally { if (keep === undefined) delete S.trial[k]; else S.trial[k] = keep; }
}
// The columns: your file, what the game wears when the page saved pieces, then each draft
function compareColumns(s){
  const cols = [], was = s.was || {};
  if (Object.keys(was).length) {
    const file = {};
    for (const [slot, p] of Object.entries(was)) file[slot] = !p || p.name === 'empty' ? null : p;
    cols.push({label: t('cmpFile'), tr: file}, {label: t('cmpTest'), tr: {}});
  } else cols.push({label: t('cmpFile'), tr: {}});
  if (trialCount(s)) cols.push({label: t('cmpTry'), tr: S.trial[trialKey(s)] || {}});
  ((S.drafts[trialKey(s)] || {}).kept || []).forEach((x, i) => cols.push({label: x.name, tr: x.tr, kept: i}));
  return cols.map(c => withTrialAs(s, c.tr, () => Object.assign(c, {pieces: withWeapons(s).pieces, stats: setStats(s).total})));
}
function openCompare(s){
  const cols = compareColumns(s), ref = cols[0], num = (c, k) => (c.stats[k] || {}).v || 0;
  const slots = SLOTS.filter(slot => cols.some(c => !samePiece(c.pieces[slot], ref.pieces[slot])));
  // the stats the set is after first (always shown, by weight), then the others that differ
  const {want} = setWants(s), all = [...new Set(cols.flatMap(c => Object.keys(c.stats)))];
  const stats0 = Object.assign({}, ...cols.map(c => c.stats)), sorter = S.statSort === 'name' ? statSorter(s, stats0) : null;
  // damage taken goes on two lines of its own (physical, magic), each part shown
  const isDt = k => DT_KEYS.includes(baseKey(k));
  const wanted = all.filter(k => !isDt(k) && wantOf(want, k) >= 0.3 && statVisible(k, s)).sort(sorter || ((a, b) => wantOf(want, b) - wantOf(want, a) || statOrder(a, b)));
  const keys = all.filter(k => !isDt(k) && !wanted.includes(k) && statVisible(k, s) && cols.some(c => num(c, k) !== num(ref, k))).sort(sorter || statOrder);
  const head = `<tr><th></th>${cols.map(c => `<th>${esc(c.label)}${c.kept != null ? `<span class="keptacts"><button class="linkbtn" data-keptload="${c.kept}">${t('keptLoad')}</button>` +
    `<button class="linkbtn" data-keptdel="${c.kept}" aria-label="${esc(t('keptDel'))}">×</button></span>` : ''}</th>`).join('')}</tr>`;
  const piece = p => p ? esc(p.name) + (p.rank != null ? ` <span class="rk">R${p.rank}</span>` : '') + (p.capeMax ? ` <span class="rk">max</span>` : '') +
    (p.augs && p.augs.length ? `<small>${esc(p.augs.join(' · '))}</small>` : '') : '—';
  const pieceRows = slots.map(slot => `<tr><th>${SLOT_NAMES[S.lang][slot] || slot}</th>` +
    cols.map((c, i) => `<td class="${i && !samePiece(c.pieces[slot], ref.pieces[slot]) ? 'chg' : ''}">${piece(c.pieces[slot])}</td>`).join('') + `</tr>`).join('');
  const rowsOf = (list, cls) => list.map(k => { const e = (cols.find(c => c.stats[k]) || ref).stats[k];
    // the better column for that stat in bold (less is better for damage taken)
    const vals = cols.map(c => num(c, k)), better = GOOD_DOWN.has(baseKey(k)) ? Math.min(...vals) : Math.max(...vals);
    return `<tr class="${cls}"><th>${esc(statLabel(k, e))}</th>` + cols.map((c, i) => { const v = vals[i], dv = v - vals[0];
      return `<td class="${v === better && vals.some(x => x !== v) ? 'best' : ''}">${fmtStat({v, unit: e.unit})}${i && dv ? `<i class="dv ${(GOOD_DOWN.has(baseKey(k)) ? -dv : dv) > 0 ? 'up' : 'down'}">${fmtStat({v: dv, unit: e.unit})}</i>` : ''}</td>`; }).join('') + `</tr>`; }).join('');
  // DT + PDT and DT + MDT (Shell included, as under the set): the total against the -50 % cap, then each part
  const B = buffTotals(), shell = B.shell ? Math.round(-B.shell / 256 * 1000) / 10 : 0;
  const dtRow = (label, part, extra) => {
    const parts = cols.map(c => { const v = k => num(c, k), list = [['DT', v('dt')], [part.toUpperCase(), v(part)]].concat(extra(c)).filter(x => x[1]);
      return {sum: list.reduce((a, x) => a + x[1], 0), list}; });
    if (!parts.some(x => x.sum) || !statVisible('dt', s)) return '';
    const eff = x => Math.max(x.sum, -50), best = Math.min(...parts.map(eff));
    return `<tr class="want"><th>${esc(label)}</th>` + parts.map((x, i) => { const dv = eff(x) - eff(parts[0]), r1 = n => Math.round(n * 10) / 10;
      return `<td class="${eff(x) === best && parts.some(y => eff(y) !== eff(x)) ? 'best' : ''}">${signed(r1(eff(x)))} %` +
        (x.sum < -50 ? ` <span class="overl">${t('cmpOver', {n: r1(-50 - x.sum)})}</span>` : '') +
        (i && dv ? `<i class="dv ${dv < 0 ? 'up' : 'down'}">${signed(r1(dv))} %</i>` : '') +
        `<small>${x.list.map(([n, v]) => `${n} ${signed(r1(v))}`).join(' · ')}</small></td>`; }).join('') + `</tr>`;
  };
  const dtRows = dtRow(t('pdtEff'), 'pdt', c => [['PDT II', num(c, 'pdt2')]]) +
    dtRow(shell ? t('mdtShell') : t('mdtEff'), 'mdt', c => [['MDT II', num(c, 'mdt2')], ['Shell', shell]]);
  // the weaponskill's average damage per column (the engine, atelier/engine/)
  const dmg = cols.map(c => withTrialAs(s, c.tr, () => wsDamage(s)));
  const dmgRow = dmg.some(v => v != null) ? `<tr class="want dmgrow"><th>${t('cmpDmg', {tp: S.wsTp || 3000})}</th>` + dmg.map((v, i) => {
    const dv = v != null && dmg[0] != null ? (v / dmg[0] - 1) * 100 : 0, best = Math.max(...dmg.filter(x => x != null));
    return `<td class="${v === best && dmg.some(x => x !== v) ? 'best' : ''}">${v == null ? '—' : fmtDmg(v)}${i && dv ? `<i class="dv ${dv > 0 ? 'up' : 'down'}">${dv > 0 ? '+' : ''}${dv.toFixed(1)} %</i>` : ''}</td>`; }).join('') + `</tr>` : '';
  // what the set is after: the stats that differ shown, the ones every column has alike folded with the rest
  const differs = k => cols.some(c => num(c, k) !== num(ref, k)), wantedDiff = wanted.filter(differs), wantedSame = wanted.filter(k => !differs(k));
  const wantRows = dmgRow + engCmpRows(s, cols) + dtRows + rowsOf(wantedDiff, 'want'), statRows = rowsOf(wantedSame, '') + rowsOf(keys, '');
  const folded = wantedSame.length + keys.length, cols1 = cols.length + 1;
  // two panes side by side for two or three columns: the pieces that differ, the figures; one under the other past that
  const pieces = pieceRows ? `<section><div class="kicker">${t('cmpPieces')}</div><table class="cmptbl"><thead>${head}</thead><tbody>${pieceRows}</tbody></table></section>` : '';
  const figures = wantRows || statRows ? `<section><div class="kicker">${t('cmpWanted')}</div><table class="cmptbl"><thead>${head}</thead><tbody>${wantRows}` +
    (statRows ? `<tr class="sec"><td colspan="${cols1}"><button class="linkbtn foldbtn" data-cmpmore>${S._cmpMore ? '▾' : '▸'} ${t('cmpStats')} · ${folded}</button></td></tr>` +
      (S._cmpMore ? statRows : '') : '') + `</tbody></table></section>` : '';
  const body = slots.length || keys.length || wanted.length
    ? `<p class="muted small">${t('cmpWhy')}</p><div class="cmpgrid ${cols.length <= 3 && pieces && figures ? 'two' : ''}">${pieces}${figures}</div>`
    : `<p class="muted">${t('cmpSame')}</p>`;
  showDialog('cmpdlg', `${t('cmpTitle')} · <code>${esc(shortPath(s.path))}</code> ${statPickBtn()}`, body, '');
}
// An engaged set's round per column: real time, the engine's average, rounds, DPS, TP a round, the best in bold and each
// column's gap to the first
function engCmpRows(s, cols){
  if (family(s.path, s.pieces) !== 'engaged') return '';
  const rr = cols.map(c => withTrialAs(s, c.tr, () => engRound(s)));
  if (!rr.some(Boolean)) return '';
  const row = (label, get, fmt, low) => { const v = rr.map(r => r ? get(r) : null), ok = v.filter(x => x != null), best = low ? Math.min(...ok) : Math.max(...ok);
    return `<tr class="want"><th>${esc(label)}</th>` + v.map((x, i) => { const dv = x != null && v[0] ? (x / v[0] - 1) * 100 : 0;
      return `<td class="${x === best && ok.some(y => y !== x) ? 'best' : ''}">${x == null ? '—' : fmt(x)}` +
        (i && Math.abs(dv) > .05 ? `<i class="dv ${(low ? -dv : dv) > 0 ? 'up' : 'down'}">${dv > 0 ? '+' : ''}${dv.toFixed(1)} %</i>` : '') + `</td>`; }).join('') + `</tr>`; };
  const at = (S.optOpts || {}).engAt || 1000, sec = x => x.toFixed(2) + ' s';
  return row(t('cmpEngReal', {at}), r => r.real ? r.real.time : r.time, sec, true) + row(t('cmpEngAvg'), r => r.time, sec, true) +
    row(t('rdvRounds'), r => r.real ? r.real.rounds : null, x => x.toFixed(2), true) + row('DPS', r => r.dps, fmtDmg, false) + row(t('cmpEngTp'), r => r.tp, x => Math.round(x), false) +
    row(t('rdvAttacks'), r => r.attacks ? r.attacks.swings : null, x => x.toFixed(2), false) + row(t('rdvLanded'), r => r.attacks ? r.attacks.hits : null, x => x.toFixed(2), false);
}
// A dialog over the page: title, body, the buttons beside Close
function showDialog(cls, title, body, buttons){
  $('#overlay').innerHTML = `<div class="scrim" data-close></div><div class="dialog ${cls}" role="dialog"><header><h3>${title}</h3></header>
    <div class="body">${body}</div><footer><button class="btn ghost" data-close>${t('close')}</button>${buttons}</footer></div>`;
  $('#overlay').hidden = false;
}

/* ---- tried pieces saved ---- */
// The tried pieces of a set are the ones saved for it (waiting for a reload in game)
function trialSaved(s){
  const tr = S.trial[trialKey(s)] || {}, saved = ((setOverrides()[S.job] || {})[s.path]) || {};
  const asPiece = v => v === 'empty' ? null : typeof v === 'string' ? {name: v} : {name: v.name, augs: v.augments};
  return Object.keys(tr).length > 0 && Object.entries(tr).every(([slot, p]) => slot in saved && samePiece(p, asPiece(saved[slot])));
}
