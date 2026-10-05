// GearSwap Atelier · sets_view.js: rendering: the side, the set list, a set's card, the Macro / Functions tabs, the job list
// (cut from atelier.html, loaded by it in order: see the list there)
/* ---- render ---- */
// The top bar: character, job (by role, the played ones) and subjob menus, the job's macro book,
// lockstyle and export, language and theme
function renderSide(){
  const dark = S.theme ? S.theme==='dark' : matchMedia('(prefers-color-scheme: dark)').matches;
  document.documentElement.lang = S.lang;
  if (S.theme) document.documentElement.setAttribute('data-theme', S.theme);
  const d = data(), job = S.job && JOBS.find(x => x[0] === S.job);
  const chars = `<div class="seg" role="group">${Object.keys(CHARS).map(c => `<button aria-pressed="${c===S.char}" data-char="${esc(c)}">${esc(c)}</button>`).join('')}</div>`;
  const opt = ([c, name]) => { const ml = masterOf(c); return `<option value="${c}" ${S.job===c?'selected':''}>${c} · ${name}${ml ? ' · ML' + ml : ''}</option>`; };
  const jg = jobGroups();
  const groups = jg[0].label !== null ? jg.map(g => `<optgroup label="${g.label}">${g.jobs.map(opt).join('')}</optgroup>`).join('') : ROLES.map(r => { const played = JOBS.filter(j => j[2]===r && plays(j[0]));
    return played.length ? `<optgroup label="${t('roles.'+r)}">${played.map(([c, name]) => `<option value="${c}" ${S.job===c?'selected':''}>${c} · ${name}</option>`).join('')}</optgroup>` : ''; }).join('');
  const icon = job ? `<span style="--role:${ROLE_COLOR[job[2]]}">${emblem(job[0])}</span>`
    : `<span class="homeic"><svg width="16" height="16" viewBox="0 0 26 26" aria-hidden="true"><path d="M13 1 L22 10 L13 25 L4 10 Z" fill="currentColor"/></svg></span>`;
  const jobPick = `<div class="jobpick">${icon}<label class="pick"><small>${t('colJob')}</small><select class="topsel jobsel">` +
    `<option value="" ${!S.job?'selected':''}>${t('overview')}</option>${groups}</select></label>${d ? subPicker() : ''}</div>`;
  const facts = d ? `<dl class="mini"><div><dt>${t('macro')}</dt><dd>${bookOf(d)}</dd></div><div><dt>${t('lockstyle')}</dt><dd>${styleOf(d)}</dd></div>` +
    `<div><dt>${t('colExport')}</dt><dd>${d.live ? `<span class="liveword">${t('liveData')}</span>` : esc(d.at||'—')}${d.offline ? ` <span class="muted">· ${t('offline')}</span>` : ''}${!d.live && (d.export_version || 1) < EXPORT_VERSION ? ` <span class="oldexport" title="${esc(t('oldExportHow'))}">· ${t('oldExport')}</span>` : ''}</dd></div></dl>` : '';
  const prefs = `<div class="prefs"><div class="seg" role="group" aria-label="Language"><button data-lang="fr" aria-pressed="${S.lang==='fr'}">FR</button><button data-lang="en" aria-pressed="${S.lang==='en'}">EN</button></div>` +
    `<div class="seg" role="group"><button data-theme-set="light" aria-pressed="${!dark}" aria-label="${S.lang==='fr'?'Mode jour':'Light mode'}"><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><circle cx="7" cy="7" r="3" fill="currentColor"/><g stroke="currentColor" stroke-width="1.3"><path d="M7 0.5v2M7 11.5v2M0.5 7h2M11.5 7h2M2.4 2.4l1.4 1.4M10.2 10.2l1.4 1.4M2.4 11.6l1.4-1.4M10.2 3.8l1.4-1.4"/></g></svg></button>` +
    `<button data-theme-set="dark" aria-pressed="${dark}" aria-label="${S.lang==='fr'?'Mode nuit':'Dark mode'}"><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><path d="M9.8 1.2a6 6 0 1 0 3 9.6A5 5 0 0 1 9.8 1.2z" fill="currentColor"/></svg></button></div></div>`;
  const brand = `<div class="brand"><svg width="22" height="22" viewBox="0 0 26 26" aria-hidden="true"><path d="M13 1 L22 10 L13 25 L4 10 Z" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M4 10 H22 M13 1 L9 10 L13 25 L17 10 Z" fill="none" stroke="currentColor" stroke-width=".9" opacity=".6"/></svg><b>Atelier</b></div>`;
  $('#top').innerHTML = `${brand}${chars}<span class="tsep"></span>${jobPick}${facts ? `<span class="tsep"></span>${facts}` : ''}<span class="sp"></span>${liveBadge()}${prefs}`;
}
function counts(c){ const d = recordOf(S.char, c); return d ? {sets:d.sets.length, keys:keysShown(d).length} : null; }
function renderHome(){
  const groups = jobGroups(), jobs = groups.flatMap(g => g.jobs); let totS = 0, totK = 0;
  const dim = new Set(groups.filter(g => g.label !== null && !g.master).flatMap(g => g.jobs.map(j => j[0])));
  for (const [c] of jobs) { const n = counts(c); totS += n.sets; totK += n.keys; }
  const rows = jobs.map(([c,name,r]) => { const d = recordOf(S.char, c), n = counts(c);
    return `<tr data-job="${c}" class="${dim.has(c) ? 'dim' : ''}" style="--role:${ROLE_COLOR[r]}"><td><span class="jobcell">${emblem(c)}<b>${c}</b><span class="muted">${name}</span>${jobBadge(c)}</span></td>
      <td><span class="role">${t('roles.'+r)}</span></td><td class="sub">${esc(d.sub||'—')}</td><td class="num r">${n.sets}</td><td class="num r">${n.keys}</td>
      <td class="num">${bookOf(d)}</td><td class="num">${styleOf(d)}</td><td class="num muted">${esc(d.at||'—')}${d.offline?' · '+t('offline'):''}</td></tr>`; }).join('');
  return `<header class="pagehead"><div class="kicker">${t('overview')}</div><h1 class="display">${esc(S.char)}</h1><p class="lede">${t('summary',{j:jobs.length,s:totS,k:totK})}</p></header>
    <div class="pane"><div class="tblwrap"><table class="tbl click"><thead><tr><th>${t('colJob')}</th><th>${t('colRole')}</th><th>${t('colSub')}</th><th class="r">${t('colSets')}</th><th class="r">${t('colKeys')}</th>
    <th>${t('macro')}</th><th>${t('lockstyle')}</th><th>${t('colExport')}</th></tr></thead><tbody>${rows}</tbody></table></div><p class="note-foot">${t('mock')}</p></div>`;
}
// Whether you hold a piece the set shows (any bag, slips and the Mog House included): 'missing' when you
// do not, 'short' when yours is below what the page counts (a lower rank than the one counted, a cape
// counted with its materials at their maximum), '' when yours is it or the page knows no bags (no export yet)
function holdState(slot, p){
  if (!p || isEmpty(p) || ['main', 'sub', 'range'].includes(slot)) return '';
  const owned = ownedOf() || {};
  if (!Object.keys(owned).length) return '';
  const mine = (owned[slot] || []).filter(x => x.name === p.name);
  if (!mine.length) return 'missing';
  if (mine.every(atPorter)) return 'porter';
  if (p.capeMax) return 'short';
  if (p.rank != null && !mine.some(x => { const r = ownRank({name: x.name, augs: x.augs}).rank; return r == null || r >= p.rank; })) return 'short';
  return '';
}
function slotHTML(s, ci, slot, own, q, eff){
  const p = eff.pieces[slot], label = SLOT_NAMES[S.lang][slot], tried = eff.tried[slot];
  const reset = tried ? `<span class="unslot" role="button" tabindex="0" data-unslot="${slot}" data-card="${ci}" title="${t('tryReset')}">↺</span>` : '';
  if (!p) return `<button class="slot empty ${tried?'tried':''}" data-card="${ci}" data-slot="${slot}" aria-label="${label} : —">${reset}<span class="elbl">${label}</span></button>`;
  const weap = eff.from[slot], inh = !weap && s.base && !own.has(slot), hit = q && p.name.toLowerCase().includes(q);
  const r = pieceStats(p, slot), augmented = r && Object.keys(r.aug).length;
  // the name, its stats, base and augments are in the hover card (showTip)
  const hold = holdState(slot, p);
  return `<button class="slot ${inh?'inh':''} ${weap?'weap':''} ${hit?'hit':''} ${tried?'tried':''} ${hold ? 'own-' + hold : ''}" data-card="${ci}" data-slot="${slot}" aria-label="${label} : ${esc(p.name)}${hold ? ' · ' + t('lg_' + hold) : ''}">` +
    `${reset}${icon(p.name)}${augmented?'<span class="mk">◆</span>':''}${r && r.rank != null ? `<span class="rk">R${r.rank}</span>` : ''}</button>`;
}
// The variants of a card, laid out like the weapon rows: a label, then its buttons. A variant with
// its own variants (Savage Blade · TPBonus) keeps them stuck to it; weaponskills go one row per
// combat skill (export ws_skill), the others in one row
// A card's variants by what leads them: {head, main (its own index), subs [{label, i}]}
function variantGroups(card){
  const groups = new Map(), skills = card.fam === 'ws' ? wsSkills() : {};
  card.variants.forEach((x, i) => { const parts = x.label.split(' · ');
    // the weaponskill leads its group wherever it sits in the path (sets.precast.WS.SCH["Knights of Round"])
    // a weaponskill variant naming no weaponskill (sets.precast.WS.TPBonus) is a variant of the base set
    const found = parts.findIndex(p => skills[p]), ws = card.fam === 'ws' && found < 0 && parts[0] !== 'Base';
    const at = Math.max(0, found), head = ws ? 'Base' : parts[at], tail = ws ? parts : parts.filter((_, k) => k !== at);
    if (!groups.has(head)) groups.set(head, {head, main: null, subs: []});
    const g = groups.get(head); if (tail.length) g.subs.push({label: tail.join(' · '), i}); else g.main = i; });
  return {groups, skills};
}
// What brings a spell to a family or mode set under a skill (MidcastManager, shared/utils/midcast/
// midcast_manager.lua): sets.midcast['Enfeebling Magic'].duration is the family "duration" of the
// spell database (Sleep, Bind...), .Duration the EnfeebleMode value, used by spells of no family.
// The families come from the game (window.ATELIER_FAMILIES, shared/utils/atelier/atelier_families.lua)
// Variants named by a condition rather than a family: the target (target_func Composure / Self /
// Other), Magic Burst (BLM, SCH, NIN mode_value), RDM's Saboteur overlay
const STATIC_NOTES = {Composure: 'famComposure', Self: 'famSelf', Other: 'famOther', MagicBurst: 'famMB', Saboteur: 'famSabo'};
function familyNote(s){
  const all = window.ATELIER_FAMILIES || {}, parts = segs(s.path), last = parts[parts.length - 1];
  if (parts.length > 2 && STATIC_NOTES[last]) return t(STATIC_NOTES[last]);
  const modeOf = v => data().modes.find(m => m.values.includes(v) && /mode/i.test(m.name));
  // the deepest parent whose next step is one of its families, or a mode value
  // (sets.midcast.IntEnfeebles.duration, sets.midcast['Blue Magic'].Magical, sets.midcast.Minne)
  for (let i = parts.length - 2; i >= 0; i--) {
    const fams = all[parts[i]], key = parts[i + 1], next = parts[i + 2];
    if (!fams) continue;
    if (fams[key]) { const sub = next && modeOf(next);
      return t('famSpells', {f: esc(key), s: fams[key].map(esc).join(', ')}) + (sub ? ' ' + t('famMode', {m: esc(sub.desc || sub.name), v: esc(next)}) : ''); }
    const mode = modeOf(key);
    if (mode && parts[i] !== 'midcast') return t('modeNoFamily', {m: esc(mode.desc || mode.name), v: esc(key)});
  }
  // the skill's own set: the last step, for a spell no other set catches
  if (all[last] && last !== 'midcast') return t('famBase', {k: esc(last)});
  return '';
}
// The note's room is kept on every variant of a card that has one: switching variants moves nothing
// The title of a weaponskill set: its weapon, its name and version, what it uses (type, attributes, hits,
// fTP by TP, critical hits, fTP on every hit: the weaponskill database, exported as ws_info), the set's path
function wsTitleHTML(s, acts = ''){
  const ws = wsOfSet(s);
  // the common set is one of the job's base sets: never deleted from the page (set_push.lua PROTECTED)
  if (!ws) return `<div class="settitle"><span class="kicker">${t('wsKick')}</span><h2>${t('wsCommon')}</h2><code class="path wspath">${esc(s.path)}</code>${acts}</div>`;
  const info = wsInfoOf(ws), version = segs(s.path).slice(segs(s.path).lastIndexOf(ws) + 1).join(' · ');
  const n = v => (+v).toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US', {minimumFractionDigits: 1, maximumFractionDigits: 3});
  const mods = typeof info.mods === 'string' ? [info.mods] : Object.entries(info.mods || {}).map(([k, v]) => `${v} % ${k}`);
  const ftp = info.ftp && info.ftp['1000'] != null ? 'fTP ' + ['1000', '2000', '3000'].map(k => info.ftp[k] != null ? n(info.ftp[k]) : '—').join(' / ') : '';
  const facts = [info.type ? t('wsType_' + info.type) : '', mods.join(' + '), info.hits ? t(info.hits > 1 ? 'wsHitN' : 'wsHit1', {n: info.hits}) : '', ftp,
    info.crit ? t('wsCritTag') : '', info.replicating ? t('wsReplTag') : '', info.element ? info.element : ''].filter(Boolean);
  return `<div class="settitle"><span class="kicker">${esc((wsSkills()[ws] || '') + ' · ' + t('wsKickOne'))}</span>` +
    `<h2>${esc(ws)}${version ? ` <span class="wsver">· ${esc(version)}</span>` : ''}</h2>` +
    (facts.length ? `<span class="wsfacts">${facts.map(f => `<span>${esc(f)}</span>`).join('')}</span>` : '') + `<code class="path wspath">${esc(s.path)}</code>${acts}</div>`;
}
// The top of a set other than a weaponskill's: what it is on the left (its family, when it is worn, its
// name and variant, its path), its variants and the weapons it is shown with on the right
function setHeadHTML(card, ci, vi, s, acts){
  const when = t('famWhen.' + card.fam), label = card.variants[vi].label;
  const fam = t('fam.' + card.fam), name = niceName(card);
  // what the set is, on the whole width in one or two lines: its family, name and variant, when it is worn, its path
  const title = `<div class="settitle">${fam !== name ? `<span class="kicker">${esc(fam)}</span>` : ''}<h2>${esc(name)}` +
    `${label && label !== 'Base' ? ` <span class="wsver">· ${esc(label)}</span>` : ''}</h2>` +
    (when ? `<span class="muted small setwhen">${esc(when)}</span>` : '') + `<code class="path wspath">${esc(s.path)}</code>${acts}</div>` + familyNoteHTML(card, s);
  const line = (lbl, body) => `<div class="wsline"><span class="wslbl">${esc(lbl)}</span><div class="wsval">${body}</div></div>`;
  // the weapons' menus side by side under the variants, a label over each
  const pick = (lbl, body) => `<div class="wpick"><span class="wslbl">${esc(lbl)}</span><div class="wsval">${body}</div></div>`;
  const btn = (i, txt) => `<button aria-pressed="${i === vi}" data-card="${ci}" data-variant="${i}">${esc(txt)}</button>`;
  const groups = [...variantGroups(card).groups.values()];
  const cur = groups.find(g => g.main === vi || g.subs.some(x => x.i === vi));
  // the set's own versions only (Full / Group / Solo, .Acc...): the other sets of its family are in the set list
  let ctl = '';
  const tiers = cur && cur.subs.some(x => /^(Group|Solo|Trust)$/.test(x.label));
  if (cur && cur.subs.length) ctl += line(t('subVarLbl'), (cur.main != null ? btn(cur.main, tiers ? 'Full' : t('verSet')) : '') + cur.subs.map(x => btn(x.i, x.label)).join(''));
  const menus = weaponMenus(s);
  const picks = (menus ? pick(t('weaponsLbl'), menus) : '') + (family(s.path, s.pieces) !== 'weapons' ? forceLines(s, pick) : '');
  // a job with a stance or a switch on its weapons keeps the full weapon picker
  const picker = menus === null ? weaponPicker(s) : '';
  const bar = ctl || picks || picker ? `<div class="setctl">${ctl ? `<div class="wshead">${ctl}</div>` : ''}${picks ? `<div class="wpicks">${picks}</div>` : ''}${picker}</div>` : '';
  return `<div class="settop">${title}${bar}</div>`;
}
function familyNoteHTML(card, s){
  if (!card.variants.some(v => familyNote(v.set))) return '';
  const text = familyNote(s);
  return `<p class="famnote ${text ? '' : 'none'}">${text}</p>`;
}
function cardHTML(card, ci, bypath, q){
  const vi = Math.min(S.variant[S.job+'|'+ci] ?? 0, card.variants.length-1);
  const s = card.variants[vi].set; const base = s.base ? bypath[s.base] : null;
  // the set every figure of the card reads (aftermath, the abilities a family of sets offers): this one, not the last one
  S._curSet = s;
  const own = new Set(s.own || Object.keys(s.pieces)), eff = withWeapons(s);
  const slots = SLOTS.map(slot => slotHTML(s, ci, slot, base ? own : new Set(SLOTS), q, eff)).join('');
  const foot = [];
  if (base) { const n = [...own].filter(x => s.pieces[x]).length; foot.push(`${t('inherits',{b:'<b>'+esc(shortPath(s.base))+'</b>'})} · ${n?t('changed',{n}):t('nothingChanged')}`); }
  else foot.push(Object.keys(s.pieces).length ? t('defined',{n:'<b>'+Object.keys(s.pieces).length+'</b>'}) : t('emptySet'));
  if (s.aliases && s.aliases.length) foot.push(`<details><summary>${t('sharedCount', {n: s.aliases.length})}</summary><p>${s.aliases.map(a => esc(shortPath(a))).join(' · ')}</p></details>`);
  const holds = {missing: [], short: [], porter: []};
  for (const slot of SLOTS) { const st = holdState(slot, eff.pieces[slot]); if (st && !holds[st].includes(eff.pieces[slot].name)) holds[st].push(eff.pieces[slot].name); }
  // at the Porter Moogle: which slip, to take it out
  const slipOf = n => [...new Set(Object.values(ownedOf()).flat().filter(x => x.name === n).flatMap(x => x.where || []))].map(w => w.replace(/^Slip/, 'slip')).join(', ');
  if (holds.porter.length) foot.push(`<span class="holdporter">${t('holdPorter', {l: esc(holds.porter.map(n => n + ' (' + slipOf(n) + ')').join(', '))})}</span>`);
  if (holds.missing.length) foot.push(`<span class="holdmiss">${t('holdMissing', {l: esc(holds.missing.join(', '))})}</span>`);
  if (holds.short.length) foot.push(`<span class="holdshort">${t('holdShort', {l: esc(holds.short.join(', '))})}</span>`);
  // the legend folded by default (its state kept), the hint of the cells with it
  const legend = `<details class="lgfold" data-lgfold ${S._lgOpen ? 'open' : ''}><summary>${t('lgTitle')}</summary><div class="legend mini"><span><i></i>${t('lgOwn')}</span><span><i class="inh"></i>${t('lgInh')}</span><span><i class="weap"></i>${t('lgWeap')}</span><span><i class="try"></i>${t('lgTry')}</span>${holds.missing.length ? `<span><i class="miss"></i>${t('lg_missing')}</span>` : ''}${holds.short.length ? `<span><i class="short"></i>${t('lg_short')}</span>` : ''}${holds.porter.length ? `<span><i class="porter"></i>${t('lg_porter')}</span>` : ''}</div><p class="eqhint">${t('lgHint')}</p></details>`;
  const ws = card.fam === 'ws' && family(s.path, s.pieces) === 'ws', head = ws ? wsTitleHTML(s) : '';
  // the page in three bands: what the set is (a weaponskill set: the weaponskill, what its figures are worked out with),
  // the equipment beside its stats, then the optimizer on the whole width
  const optable = (ws && wsOfSet(s)) || roundSet(s) || statSet(s);
  if (optable && optPageOpen(s)) return optPageHTML(s, ws && wsOfSet(s));
  // its actions on the title line: the optimizer, then deleting it
  const acts = `<span class="setacts">${optable && engineReady() ? `<button class="btn" data-optview>${t('optOpenBtn')}</button>` : ''}${ws && !wsOfSet(s) ? '' : delButton(s)}</span>`;
  const top = ws ? `<div class="settop">${wsTitleHTML(s, acts)}${familyNoteHTML(card, s)}` +
      (wsOfSet(s) ? `<div class="setctl">${wsHeadHTML(card, ci, vi, s)}</div>` : '') + `</div>`
    : setHeadHTML(card, ci, vi, s, acts);
  return `<article class="detail"><header>${top}${trialBar(s)}</header>
    <div class="dbody"><div class="eqcol"><div class="slots">${slots}</div><footer>${foot.map(f => '<span>'+f+'</span>').join('')}</footer>${legend}</div>${setStatsHTML(s)}</div>
    <div class="globals-inline">${(S._globals = {s, html: globalsHTML(s)}).html}</div></article>`;
}
const famOpen = (fam, q) => !!q || !!S.famOpen[S.job + '|' + fam];
function renderSets(d){
  const {cards, bypath} = buildCards(d); S._cards = cards; S._bypath = bypath;
  const q = S.q.trim().toLowerCase();
  const vis = cards.map((c,i) => i).filter(i => cardMatch(cards[i], q)); S._vis = vis;
  const want = S.selPath[S.job];
  const found = S.char + '|' + S.job + '|' + ((data() || {}).sub || '') + '|';
  if (want && S._found !== found + want) {
    cards.forEach((c, i) => c.variants.forEach((v, k) => { if (v.set.path === want || (v.set.aliases || []).includes(want)) { S.sel[S.job] = i; S.variant[S.job + '|' + i] = k; } }));
    S._found = found + want;
  }
  if (!vis.includes(S.sel[S.job])) S.sel[S.job] = vis[0];
  const sel = S.sel[S.job];
  if (cards[sel]) { S.selPath[S.job] = shownSet(cards[sel], sel).path; S._found = found + S.selPath[S.job]; }
  tierFollowsSet(S.selPath[S.job], bypath);
  subFollowsSet(S.selPath[S.job], bypath);
  objFollowsSet(S.selPath[S.job], bypath);
  // one row per set: the set, then its variants (idle.Town, each weaponskill) indented under it
  const vi = i => Math.min(S.variant[S.job + '|' + i] ?? 0, cards[i].variants.length - 1);
  const rows = S._rows = [];
  let list = '', fam = null;
  for (const i of vis) { const c = cards[i];
    if (c.fam !== fam) { fam = c.fam;
      const n = vis.filter(k => cards[k].fam===fam).reduce((m, k) => m + cards[k].variants.length, 0);
      list += `<button class="fam ${cards[sel] && cards[sel].fam === fam ? 'here' : ''}" data-famtoggle="${fam}" aria-expanded="${famOpen(fam, q)}"><span>${t('fam.'+fam)}</span><span>${n}</span></button>`; }
    // a category is closed until opened (a search opens them all)
    if (!famOpen(c.fam, q)) continue;
    const row = (v, k) => {
      if (q && k > 0 && !cardMatch({variants: [v]}, q)) return;
      const cur = i === sel && k === vi(i), main = k === 0;
      rows.push([i, k]);
      list += `<button class="setrow ${main ? '' : 'var'}" data-pick="${i}" data-vpick="${k}" aria-current="${cur}">` +
        `<b>${main ? esc(niceName(c)) + (v.label !== 'Base' ? ` · ${esc(v.label)}` : '') : esc(v.label)}</b><code>${esc(v.set.path)}</code></button>`;
    };
    if (c.fam !== 'ws') { c.variants.forEach(row); continue; }
    // weaponskills: the common set, then one folding group a weapon (closed until opened, a search opens them)
    row(c.variants[0], 0);
    const bySkill = new Map();
    c.variants.forEach((v, k) => { if (!k) return; const sk = wsSkills()[wsOfSet(v.set)] || t('varOther');
      if (!bySkill.has(sk)) bySkill.set(sk, []); bySkill.get(sk).push([v, k]); });
    for (const [sk, items] of [...bySkill].sort((a, b) => a[0].localeCompare(b[0]))) {
      const open = !!q || !!(S._wsList || {})[S.job + '|' + sk], here = i === sel && items.some(([, k]) => k === vi(i));
      list += `<button class="wskill ${here ? 'here' : ''}" data-wskill="${esc(sk)}" aria-expanded="${open}"><span>${esc(sk)}</span><span>${items.length}</span></button>`;
      if (open) items.forEach(([v, k]) => row(v, k));
    }
  }
  if (!vis.length) list = `<p class="empty-list">${t('noMatch')}</p>`;
  S._fams = [...new Set(vis.map(i => cards[i].fam))];
  // open or close every category at once
  const tools = vis.length && !q ? `<div class="listtools"><button class="linkbtn" data-famall="1">${t('openAll')}</button>` +
    `<span>·</span><button class="linkbtn" data-famall="0">${t('closeAll')}</button>` +
    `<span>·</span><button class="linkbtn" data-pushhist>${t('histBtn')}</button></div>` : '';
  return `<div class="setsx"><aside class="setlist"><div class="search"><input id="setq" type="search" placeholder="${t('search')}" value="${esc(S.q)}" autocomplete="off" spellcheck="false">` +
    `<button class="btn ghost" data-action="add" title="${t('add')}">${t('addShort')}</button></div>${tools}<div class="scroll">${list}</div><div class="hint">${t('navHint')}</div></aside>` +
    `${vis.length ? cardHTML(cards[sel], sel, bypath, q) : ''}${vis.length ? `<aside class="globalcol">${(sv => S._globals && S._globals.s === sv ? S._globals.html : globalsHTML(sv))(shownSet(cards[sel], sel))}</aside>` : ''}</div>`;
}
// The variant of a card shown in its detail
function shownSet(card, ci){ return card.variants[Math.min(S.variant[S.job + '|' + ci] ?? 0, card.variants.length - 1)].set; }

function renderMacro(d){
  const m = d.macro || {}, l = d.lockstyle || {};
  const rows = (obj, fmt) => Object.entries(obj||{}).map(([k,v]) => `<tr><td class="sub">${esc(k)}</td><td>${fmt(v)}</td></tr>`).join('');
  const bp = v => v && v.book ? t('bookPage',{b:v.book,p:v.page}) : Object.entries(v||{}).map(([s,x]) => `${s === 'default' ? t('byDefault') : '/' + esc(s)} ${x.book}·${x.page}`).join(' &nbsp; ');
  const table = (title, obj, fmt) => obj && Object.keys(obj).length ? `<div class="subh">${title}</div><table class="tbl in"><tbody>${rows(obj, fmt)}</tbody></table>` : '';
  // the values in force for the subjob shown (and the alt chosen): its own entry, else the default
  const alt = macroAlt(d), book = bookFor(d), style = (l.by_subjob || {})[d.sub] ?? l.default ?? d.lockstyle_fallback;
  const du = alt && (m.dualbox || {})[alt], why = du && (du[d.sub] || du.default) ? t('bookAlt', {a: esc(alt)}) + (du[d.sub] ? '' : ' (' + t('byDefault') + ')')
    : (m.solo || {})[d.sub] ? '/' + esc(d.sub) : m.default || (m.solo || {}).default ? t('byDefault') : t('bookFactory');
  const whose = own => ' · ' + (own ? '/' + esc(d.sub) : style === d.lockstyle_fallback && l.default == null ? t('bookFactory') : t('byDefault'));
  const head = (big, line) => `<div class="bighead"><span class="big">${big}</span><p>${line}</p></div>`;
  const alts = Object.keys(m.dualbox || {}).sort();
  const altPick = alts.length ? `<div class="variants" role="group"><span class="simtplbl">${t('bookAltPick')}</span>` +
    [['', t('bookNoAlt')], ...alts.map(a => [a, a])].map(([v, label]) => `<button data-macroalt="${v}" aria-pressed="${(alt || '') === v}">${esc(label)}</button>`).join('') + `</div>` : '';
  return `<div class="boxgrid cols">` +
    box('g-tank', t('macro'), altPick + head(bookOf(d), book ? t('bookPage',{b:book.book,p:book.page}) + ' · ' + why : '') + table(t('bySub'), m.solo, bp) + table(t('byDual'), m.dualbox, bp)) +
    box('g-buff', t('lockstyle'), head(styleOf(d), style != null ? t('style',{s:esc(style)}) + whose((l.by_subjob || {})[d.sub] != null) : '') + table(t('bySub'), l.by_subjob, v => t('style',{s:v}))) +
    `</div>`;
}
function renderFunctions(d){
  const keyOf = keyOfState(d);
  const bools = d.modes.filter(m => m.values.length===2 && ((m.values.includes('on') && m.values.includes('off')) || (m.values.includes('On') && m.values.includes('Off'))) && !modeHidden(m) && !stateElsewhere(d, m.name));
  return `<div class="boxgrid narrow">` + box('g-mag', t('sectionsFunctions'), `<table class="tbl in"><tbody>` +
    bools.map(m => { const on = m.current.toLowerCase()==='on';
      return `<tr><td class="swcol"><span class="sw ${on?'on':''}" aria-hidden="true"></span></td><td><b>${esc(m.desc||m.name)}</b><span class="state">state.${esc(m.name)}</span></td><td>${on?t('on'):t('off')}</td><td class="r">${keyLabel(keyOf[m.name])}</td></tr>`; }).join('') +
    `</tbody></table>`, `<span class="meta">${bools.length}</span>`) + `</div>`;
}
// The exported subjobs of the job: one button each, the shown one pressed
// A dot marks a subjob that shows something else than the main one (its own modes...)
function subPicker(){
  const subs = subsOf(S.char, S.job), cur = subOf(S.char, S.job), m = exportsOf(S.char, S.job), main = defaultSub(S.char, S.job);
  const label = s => s === 'NONE' ? '—' : esc(s);
  const twins = sameAsOf(S.char, S.job), own = s => s !== main && (m[s] || (twins[s] && twins[s] !== main));
  const others = allSubs(S.char, S.job).filter(s => !subs.includes(s));
  const opt = s => `<option value="${esc(s)}" ${s===cur?'selected':''}>${label(s)}${own(s)?' •':''}</option>`;
  return `<label class="pick" title="${t('subOwn')} : •"><small>${t('colSub')}</small><select class="topsel subsel">` +
    `<optgroup label="${t('subMine')}">${subs.map(opt).join('')}</optgroup>` +
    (others.length ? `<optgroup label="${t('subOther')}">${others.map(opt).join('')}</optgroup>` : '') + `</select></label>`;
}
// The played jobs by role, the shown one marked: a click changes job and keeps the tab
// Every job's level and master level, from the game (char.jobs of the latest in-game export of the
// character: packet 0x01B), or null before any
function jobLevels(c = S.char){
  let best = null;
  for (const subs of Object.values(DATA[c] || {})) for (const d of Object.values(subs))
    if (d && d.char && d.char.jobs && (!best || (d.char.at || d.at || '') > best.at)) best = {at: d.char.at || d.at || '', jobs: d.char.jobs};
  return best && best.jobs;
}
const masterOf = c => { const L = jobLevels(); return L && L[c] ? L[c].ml || 0 : null; };
// The played jobs split: the ones with master levels first (highest first), then the others, by role
function jobGroups(){
  const played = JOBS.filter(j => plays(j[0])), L = jobLevels();
  if (!L) return [{label: null, jobs: played}];
  const ml = j => (L[j[0]] || {}).ml || 0, order = j => ROLES.indexOf(j[2]);
  const mastered = played.filter(j => ml(j) > 0).sort((a, b) => ml(b) - ml(a) || order(a) - order(b));
  const others = played.filter(j => ml(j) === 0).sort((a, b) => order(a) - order(b));
  return [{label: t('jobsMaster'), jobs: mastered, master: true}, {label: t('jobsOther'), jobs: others}].filter(g => g.jobs.length);
}
const jobBadge = c => { const L = jobLevels(), j = L && L[c];
  return j ? (j.ml ? `<span class="mlbadge" title="${t('mlTip', {n: j.ml})}">ML${j.ml}</span>` : `<span class="lvbadge">${j.level}</span>`) : ''; };
function jobListHTML(){
  const groups = jobGroups();
  const row = ([c, name, r], dim) => `<button class="setrow jobrow ${dim ? 'dim' : ''}" data-jobkeep="${c}" aria-current="${S.job===c}" style="--role:${ROLE_COLOR[r]}">` +
    `${emblem(c)}<b>${c}</b><small>${name}</small>${jobBadge(c)}</button>`;
  const rows = groups[0].label === null
    ? ROLES.map(r => { const played = groups[0].jobs.filter(j => j[2] === r);
        return played.length ? `<div class="fam static" style="--role:${ROLE_COLOR[r]}"><span>${t('roles.'+r)}</span><span>${played.length}</span></div>` + played.map(j => row(j)).join('') : ''; }).join('')
    : groups.map(g => `<div class="fam static ${g.master ? 'mastergrp' : ''}"><span>${g.label}</span><span>${g.jobs.length}</span></div>` + g.jobs.map(j => row(j, !g.master)).join('')).join('');
  return `<aside class="setlist joblist"><div class="scroll">${rows}</div></aside>`;
}
function renderJob(){
  const c = S.job, d = data();
  let body, sections = '';
  if (!d) body = `<div class="placeholder"><p><b>${c}</b> : ${plays(c)?t('placeholder'):t('notPlayed',{c:S.char})}</p>${otherChar()?`<button class="btn ghost" data-char="${otherChar()}">${t('seeOther',{c:otherChar()})}</button>`:''}</div>`;
  else {
    const list = [['sets',t('sectionsSets'),d.sets.length],['keys',t('sectionsKeys'),keysShown(d).length],['modes',t('sectionsModes'),''],['macro',t('sectionsMacro'),''],['functions',t('sectionsFunctions'),''],['merits',t('sectionsMerits'),''],['sim',t('sectionsSim'),'']];
    sections = `<nav class="sections" role="tablist">${list.map(([k,l,n]) => `<button role="tab" aria-selected="${S.section===k}" data-section="${k}">${l}${n!==''?'<span class="count">'+n+'</span>':''}</button>`).join('')}</nav>`;
    body = {sets:renderSets, keys:renderKeys, modes:renderModes, macro:renderMacro, functions:renderFunctions, merits:renderMerits, sim:renderSim,}[S.section](d);
  }
  // every tab but Sets: the played jobs on the left, to change job and stay on the tab
  if (d && S.section !== 'sets' && S.section !== 'sim') body = `<div class="tabx">${jobListHTML()}<div class="tabmain">${body}</div></div>`;
  return `${sections}<div class="pane ${d ? 'split' : ''}">${body}</div>`;
}
// Re-render, keeping the focus of the search box and the scroll of each block
// while the view stays the same (the set detail goes back to its top for another set)
const SCROLLERS = ['.pane', '.setlist .scroll', '.detail'];
function render(){
  const view = [S.char, S.job, S.section].join('|'), set = view + '|' + S.sel[S.job];
  const tops = SCROLLERS.map(q => { const el = $(q); return el ? el.scrollTop : 0; });
  const a = document.activeElement, id = a && a.id, pos = a && a.selectionStart;
  renderSide(); $('#view').innerHTML = S.job ? renderJob() : renderHome(); save();
  SCROLLERS.forEach((q, i) => { const el = $(q);
    if (el && S._view === view && (q !== '.detail' || S._set === set)) el.scrollTop = tops[i]; });
  S._view = view; S._set = set;
  if (id) { const el = document.getElementById(id); if (el) { el.focus(); if (pos != null && el.setSelectionRange) el.setSelectionRange(pos, pos); } }
  if (S._buffDlg && !$('#overlay').hidden && $('.buffdlg')) openBuffs();
  if (S._tgtDlg && !$('#overlay').hidden && $('.tgtdlg')) openTarget();
}

/* ---- roles, job emblems, the other character, macro book and lockstyle shown ---- */
// Roles and colours of AioHUD (job_role_color, src/model/party_state.cpp): icon tint, border, text
const ROLE_COLOR = {tank:'var(--r-tank)',healer:'var(--r-healer)',support:'var(--r-support)',dd:'var(--r-dd)'};
const ROLES = ['tank','healer','support','dd'];
const emblem = c => `<span class="em" style="--icon:url(${ICONS[c]})"></span>`;
// Another character with exported jobs, offered when this one has none for the job
const otherChar = () => Object.keys(CHARS).find(c => c !== S.char);
const bookOf = d => { const b = bookFor(d); return b && b.book ? b.book + ' · ' + b.page : '—'; };
const styleOf = d => { const l = d.lockstyle || {}; return esc((l.by_subjob || {})[d.sub] ?? l.default ?? d.lockstyle_fallback ?? '—'); };



/* ---- the set list: cards, their names, the search ---- */
// How many path segments name the card; the rest are its variants
function topOf(path, fam){
  const s = segs(path);
  let n = 2;
  if (fam==='ja') n = 3;
  if (fam==='idle' || fam==='engaged') n = ['me', 'luopan'].includes(s[0]) ? 2 : 1;
  if (fam==='special') n = s[0]==='buff' ? 2 : 1;
  if (fam==='weapons' || fam==='other') n = s.length;
  return s.slice(0, Math.min(n, s.length));
}
function buildCards(d){
  // a set shared under several names (sets.idle.MDT = sets.engaged.MDT) is found by each of them
  const bypath = {}; for (const s of d.sets) { bypath[s.path] = s; for (const a of s.aliases || []) bypath[a] = bypath[a] || s; }
  const cards = [], index = {};
  for (const s of d.sets) {
    const fam = family(s.path, s.pieces);
    const top = topOf(s.path, fam); const key = fam + '|' + top.join('/');
    if (!index[key]) { index[key] = {fam, name: top[top.length-1], top, variants:[]}; cards.push(index[key]); }
    const rest = segs(s.path).slice(top.length).join(' · ');
    index[key].variants.push({label: rest || 'Base', set: s});
  }
  for (const c of cards) c.variants.sort((a,b) => (a.label==='Base'?-1:b.label==='Base'?1:a.label.localeCompare(b.label)));
  const order = ['idle','engaged','fc','ws','ja','midcast','pet','special','weapons','other'];
  const lead = c => c.top.length === 1 && c.top[0] === c.fam ? 0 : 1;
  cards.sort((a,b) => order.indexOf(a.fam)-order.indexOf(b.fam) || lead(a)-lead(b) || a.name.localeCompare(b.name));
  return {cards, bypath};
}
function niceName(card){
  const n = card.name;
  const map = {idle:{fr:'Au repos',en:'Idle'}, engaged:{fr:'En combat',en:'Engaged'}, FC:{fr:'Fast Cast',en:'Fast Cast'}, WS:{fr:'Weaponskills',en:'Weaponskills'},
    MoveSpeed:{fr:'Vitesse de course',en:'Movement speed'}, Doom:{fr:'Doom',en:'Doom'}, TreasureHunter:{fr:'Treasure Hunter',en:'Treasure Hunter'}};
  return (map[n] && map[n][S.lang]) || n;
}
// A card matches the search when one of its variants has the text in its path or in a piece name
function cardMatch(card, q){
  return !q || card.variants.some(v => v.set.path.toLowerCase().includes(q) || Object.values(v.set.pieces).some(p => p.name.toLowerCase().includes(q)));
}


/* ---- the column of figures beside a set ---- */
function globalsHTML(s){
  S._curSet = s;
  const r = charStats(s);
  if (!r) return `<div class="globals">${box('g-you', t('youTitle'), `<p class="muted">${t('noChar')}</p>`)}</div>`;
  const {c, out, set, vsSet} = r;
  const row = (label, o) => { const d = o.set - o.now;
    return statLi(label, o.set, d ? `<em class="delta ${d > 0 ? 'up' : 'down'}">${d > 0 ? '+' : '−'}${Math.abs(d)}</em>` : ''); };
  const v = k => (set[k] || {}).v || 0;
  const pct = (label, sum, cap) => cappedLi(label, sum, cap, '');
  const main = [['HP', out.hp], ['MP', out.mp], [t('defLabel'), out.def], [t('atkLabel'), out.atk], [t('accLabel'), out.acc], [t('evaLabel'), out.eva]]
    .filter(([, o]) => o).map(([l, o]) => row(l, o)).join('');
  const attrs = ATTRS.map(a => row(a.toUpperCase(), out[a])).join('');
  // merits the game counts per level (res/merit_points.lua: "Spell Interruption Rate" 2 % a level)
  const merit = name => Object.entries(c.merits || {}).reduce((n, [k, lv]) => k.toLowerCase().replace(/_/g, ' ') === name ? n + lv : n, 0);
  const sirdMerit = (meritList() || []).find(x => x.key === 'spell_interruption_rate');
  const sirdMerits = sirdMerit ? 2 * meritLevel(sirdMerit) : 2 * merit('spell interruption rate');
  const sird = v('sird') + sirdMerits;
  const gear = damageTakenLines(v) + pct('Haste', v('haste'), 25) + pct('Fast Cast', v('fc'), 80) +
    (sird ? statLi('SIRD', sird + ' %', sirdMerits ? `<em class="delta">${t('withMerits')}</em>` : '', '', `${t('gearOnly')} ${v('sird')} % + ${t('merits')} ${sirdMerits} %`) : '');
  const levels = [c.master_level ? `ML ${c.master_level}` : '', c.jp_spent ? `${c.jp_spent} JP` : ''].filter(Boolean).join(' · ');
  const edited = Object.keys(S.meritEdits[meritKey()] || {}).length;
  const you = fbox('you', 'g-you', t('youTitle') + (edited ? ` <span class="edited">· ${t('meritsEdited', {n: edited})}</span>` : ''),
    `${vsSet ? `<p class="vsset">${t('vsSet')}</p>` : ''}<ul class="statlist big">${main}</ul>`);
  return `<div class="globals">${buffCardHTML()}${targetCardHTML(s)}${you}${fbox('attr', 'g-attr', t('attrTitle'), `<ul class="statlist">${attrs}</ul>`)}` +
    `${fbox('caps', 'g-caps', t('gearKey'), `<ul class="statlist">${gear}</ul>`)}${tankHTML(r)}${offenseHTML(r, s)}` +
    `<p class="note-m">${levels ? esc(levels) + ' · ' : ''}${t('measured', {at: esc(c.at), s: esc(c.sub || '—')})}</p></div>`;
}


