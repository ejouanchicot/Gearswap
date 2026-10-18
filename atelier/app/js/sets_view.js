// GearSwap Atelier · sets_view.js: rendering: the side, the set list, a set's card, the Macro / Functions tabs, the job list
// (loaded by atelier/index.html, in the order of the list there)
/* ---- render ---- */
// The top bar is the Svelte application's (atelier/src/screens/topbar, told at the end of render). Here only what the
// whole document follows: its language and its theme
function renderSide(){
  document.documentElement.lang = S.lang;
  document.documentElement.setAttribute('data-theme', themeNow());
}
function counts(c){ const d = recordOf(S.char, c); return d ? {sets:d.sets.length, keys:keysShown(d).length} : null; }
function renderHome(){
  // nothing exported yet: how to fill the page (welcome.js)
  if (!CHARS[S.char]) return welcomeHTML();
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
// The legend of the gear grid: every look a cell can take, each with what it means in its tooltip. The three about
// what you hold (not yours, to upgrade, at the Porter Moogle) are lit when the set has such a piece
Object.assign(T.fr, {lgEmpty: 'vide', lgAug: 'augmentée', lgRank: 'rang',
  lgT_own: 'Une pièce que ce set définit lui-même.', lgT_inh: 'Une pièce que ce set ne définit pas : elle vient du set sur lequel il est construit.',
  lgT_weap: 'L’arme choisie par ton mode d’arme, pas par le set.', lgT_try: 'Une pièce que tu essaies dans la page : rien n’est encore écrit dans tes fichiers. La flèche ↺ dans le coin la retire.',
  lgT_empty: 'Rien dans cet emplacement.', lgT_lock: 'Emplacement verrouillé : l’optimiseur n’y touche pas. Ctrl+clic sur une case pour la verrouiller ou la libérer.',
  lgT_aug: 'La pièce porte des augments.', lgT_rank: 'Le rang de la pièce.',
  lgT_missing: 'Tu ne possèdes pas cette pièce.', lgT_short: 'Tu l’as, mais pas encore à ce rang ou avec ces augments.',
  lgT_porter: 'Elle est rangée chez le Porter Moogle : à retirer avant de pouvoir la porter.'});
Object.assign(T.en, {lgEmpty: 'empty', lgAug: 'augmented', lgRank: 'rank',
  lgT_own: 'A piece this set defines itself.', lgT_inh: 'A piece this set does not define: it comes from the set it is built on.',
  lgT_weap: 'The weapon chosen by your weapon mode, not by the set.', lgT_try: 'A piece you are trying in the page: nothing is written to your files yet. The ↺ arrow in the corner takes it off.',
  lgT_empty: 'Nothing in this slot.', lgT_lock: 'Locked slot: the optimizer leaves it alone. Ctrl+click a cell to lock or free it.',
  lgT_aug: 'The piece carries augments.', lgT_rank: 'The piece’s rank.',
  lgT_missing: 'You do not own this piece.', lgT_short: 'You have it, but not yet at this rank or with these augments.',
  lgT_porter: 'It is stored with the Porter Moogle: to take out before you can wear it.'});
function legendHTML(holds){
  const item = (mark, label, tip, off) => `<span class="${off ? 'off' : ''}" title="${esc(t(tip))}">${mark}${esc(t(label))}</span>`;
  return `<div class="legend mini lgline">` + item('<i></i>', 'lgOwn', 'lgT_own') + item('<i class="inh"></i>', 'lgInh', 'lgT_inh') +
    item('<i class="weap"></i>', 'lgWeap', 'lgT_weap') + item('<i class="try"></i>', 'lgTry', 'lgT_try') + item('<i class="empty"></i>', 'lgEmpty', 'lgT_empty') +
    item('<i class="lock"></i>', 'lgLock', 'lgT_lock') + item('<b class="mk">◆</b>', 'lgAug', 'lgT_aug') + item('<b class="rk">R15</b>', 'lgRank', 'lgT_rank') +
    item('<i class="miss"></i>', 'lg_missing', 'lgT_missing', !holds.missing.length) + item('<i class="short"></i>', 'lg_short', 'lgT_short', !holds.short.length) +
    item('<i class="porter"></i>', 'lg_porter', 'lgT_porter', !holds.porter.length) + `</div><p class="eqhint">${t('lgHint')}</p>`;
}
function slotHTML(s, ci, slot, own, q, eff){
  const p = eff.pieces[slot], label = SLOT_NAMES[S.lang][slot], tried = eff.tried[slot];
  // locked for the optimizers (trial.js): a padlock in the corner
  const lock = isLocked(s, slot) && LOCKABLE(slot) ? `<span class="lk" title="${esc(t('lockTip'))}"><svg viewBox="0 0 12 12" width="9" height="9" aria-hidden="true"><path d="M3.5 5V3.6a2.5 2.5 0 0 1 5 0V5" fill="none" stroke="currentColor" stroke-width="1.5"/><rect x="2" y="5" width="8" height="6" rx="1.2" fill="currentColor"/></svg></span>` : '';
  const reset = tried ? `<span class="unslot" role="button" tabindex="0" data-unslot="${slot}" data-card="${ci}" title="${t('tryReset')}">↺</span>` : '';
  if (!p) return `<button class="slot empty ${tried?'tried':''} ${lock ? 'locked' : ''}" data-card="${ci}" data-slot="${slot}" aria-label="${label} : —">${reset}${lock}<span class="elbl">${label}</span></button>`;
  const weap = eff.from[slot], inh = !weap && s.base && !own.has(slot), hit = q && p.name.toLowerCase().includes(q);
  const r = pieceStats(p, slot), augmented = r && Object.keys(r.aug).length;
  // the name, its stats, base and augments are in the hover card (showTip)
  const hold = holdState(slot, p);
  return `<button class="slot ${inh?'inh':''} ${weap?'weap':''} ${hit?'hit':''} ${tried?'tried':''} ${lock ? 'locked' : ''} ${hold ? 'own-' + hold : ''}" data-card="${ci}" data-slot="${slot}" aria-label="${label} : ${esc(p.name)}${hold ? ' · ' + t('lg_' + hold) : ''}">` +
    `${reset}${lock}${icon(p.name)}${augmented?'<span class="mk">◆</span>':''}${r && r.rank != null ? `<span class="rk">R${r.rank}</span>` : ''}</button>`;
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
// The title of every set, one shape whatever its content so nothing under it moves from a set to the next: the name
// on a line, what it is on the next (when it is worn, or a weaponskill's facts), its path on the third; each line
// keeps its height and cuts what is too long (the whole text in its tooltip); the actions at the right
function setTitleBox(kicker, name, what, whatTip, path, acts){
  return `<div class="settitle"><div class="stmain"><div class="stname">${kicker ? `<span class="kicker">${esc(kicker)}</span>` : ''}<h2>${name}</h2></div>` +
    `<div class="stwhat" ${whatTip ? `title="${esc(whatTip)}"` : ''}>${what}</div><code class="path wspath" title="${esc(t('ttPath'))}">${esc(path)}</code></div>${acts}</div>`;
}
// The title of a weaponskill set: its weapon, its name and version, what it uses (type, attributes, hits,
// fTP by TP, critical hits, fTP on every hit: the weaponskill database, exported as ws_info), the set's path
function wsTitleHTML(s, acts = ''){
  const ws = wsOfSet(s);
  // the common set is one of the job's base sets: never deleted from the page (set_push.lua PROTECTED)
  if (!ws) return setTitleBox(t('wsKick'), esc(t('wsCommon')), '', '', s.path, acts);
  const info = wsInfoOf(ws), version = segs(s.path).slice(segs(s.path).lastIndexOf(ws) + 1).join(' · ');
  const n = v => (+v).toLocaleString(S.lang === 'fr' ? 'fr-FR' : 'en-US', {minimumFractionDigits: 1, maximumFractionDigits: 3});
  const mods = typeof info.mods === 'string' ? [info.mods] : Object.entries(info.mods || {}).map(([k, v]) => `${v} % ${k}`);
  const ftp = info.ftp && info.ftp['1000'] != null ? 'fTP ' + ['1000', '2000', '3000'].map(k => info.ftp[k] != null ? n(info.ftp[k]) : '—').join(' / ') : '';
  const facts = [info.type ? t('wsType_' + info.type) : '', mods.join(' + '), info.hits ? t(info.hits > 1 ? 'wsHitN' : 'wsHit1', {n: info.hits}) : '', ftp,
    info.crit ? t('wsCritTag') : '', info.replicating ? t('wsReplTag') : '', info.element ? info.element : ''].filter(Boolean);
  return setTitleBox((wsSkills()[ws] || '') + ' · ' + t('wsKickOne'), esc(ws) + (version ? ` <span class="wsver">· ${esc(version)}</span>` : ''),
    facts.length ? `<span class="wsfacts">${facts.map(f => `<span>${esc(f)}</span>`).join('')}</span>` : '', facts.join(' · '), s.path, acts);
}
// The versions of the set shown (Full = the set itself, Group, Solo, Trust, or its other variants), right under its
// title as one row of buttons: the list of sets has one line a set, its versions are chosen here. The row keeps its
// place when the set has no version (nothing under it moves from a set to the next)
function setVersionsHTML(card, ci, vi){
  const groups = [...variantGroups(card).groups.values()];
  const cur = groups.find(g => g.main === vi || g.subs.some(x => x.i === vi)) || (card.fam === 'ws' ? groups[0] : null);
  if (!cur || !cur.subs.length) return `<div class="setvers none"></div>`;
  const tiers = cur.subs.some(x => /^(Group|Solo|Trust)$/.test(x.label));
  // an enhancing set's versions read as their target (stat_opt.js enhTarget): "Composure" is the one cast on the others
  // (the set itself and its Composure version only: any other version keeps its own name)
  const shown = (i, txt) => { const v = card.variants[i], on = enhTarget(v.set);
    return on && (v.label === 'Base' || /composure/i.test(v.label)) ? t('enhBtn' + on) : txt; };
  const btn = (i, txt) => `<button aria-pressed="${i === vi}" data-card="${ci}" data-variant="${i}" title="${esc(T[S.lang]['ttVer' + txt] ? t('ttVer' + txt) : t('ttVer'))}">${esc(shown(i, txt))}</button>`;
  const grid = tiers ? versionGridHTML(cur, btn) : '';
  if (grid) return `<div class="setvers grid"><span class="kicker">${esc(t('verLbl'))}</span>${grid}</div>`;
  return `<div class="setvers"><span class="kicker">${esc(t('verLbl'))}</span><div class="verseg" role="group">` +
    (cur.main != null ? btn(cur.main, tiers ? 'Full' : t('verSet')) : '') + cur.subs.map(x => btn(x.i, x.label)).join('') + `</div></div>`;
}
// A set with versions of two kinds (a DNC weaponskill: a dance, Climactic Flourish, each with its support versions:
// up to 24): a table, one line a buff version (the set itself first, then Clim, then each dance and its Clim), one
// column a support profile; a version the file does not write is a dash. One kind only: the row of buttons above
function versionGridHTML(cur, btn){
  const cell = (i, label) => { const parts = label.split(' · '), tier = TIER_LABELS.includes(parts[parts.length - 1]) ? parts.pop() : 'Full'; return {i, tier, row: parts.join(' · ')}; };
  const cells = (cur.main != null ? [{i: cur.main, tier: 'Full', row: ''}] : []).concat(cur.subs.map(x => cell(x.i, x.label)));
  const rows = [...new Set(cells.map(c => c.row))];
  if (rows.length < 2) return '';
  const rank = r => !r ? '' : (r.split(' · ')[0] === 'Clim' ? '0' : '1') + r;
  rows.sort((a, b) => rank(a).localeCompare(rank(b)));
  const cols = ['Full'].concat(TIER_LABELS.filter(x => cells.some(c => c.tier === x)));
  const at = (r, tier) => cells.find(c => c.row === r && c.tier === tier);
  return `<div class="vergrid" role="group" style="--n:${cols.length}"><span></span>${cols.map(c => `<span class="vh">${esc(c)}</span>`).join('')}` +
    rows.map(r => `<span class="vr">${esc(r || t('verSet'))}</span>` + cols.map(c => { const x = at(r, c); return x ? btn(x.i, c) : '<i class="vnone">—</i>'; }).join('')).join('') + `</div>`;
}
// The top of a set other than a weaponskill's: what it is on the left (its family, when it is worn, its
// name and variant, its path), its variants and the weapons it is shown with on the right
function setHeadHTML(card, ci, vi, s, acts){
  const when = t('famWhen.' + card.fam), label = card.variants[vi].label;
  const fam = t('fam.' + card.fam), name = niceName(card);
  // an enhancing set: on whom it is cast, beside its name and as the line under it (stat_opt.js enhTarget)
  const on = enhTarget(s), tag = on ? ` <span class="wsver">· ${esc(t('enhTag' + on))}</span>` : '';
  // what the set is, on the whole width in one or two lines: its family, name and variant, when it is worn, its path
  const title = setTitleBox(fam !== name ? fam : '', esc(name) + (label && label !== 'Base' ? ` <span class="wsver">· ${esc(label)}</span>` : '') + tag,
    on ? `<span class="muted small setwhen">${esc(t('enhWhen' + on))}</span>` : when ? `<span class="muted small setwhen">${esc(when)}</span>` : '', '', s.path, acts);
  // the weapons' menus side by side under the versions, a label over each
  const pick = (lbl, body) => `<div class="wpick"><span class="wslbl">${esc(lbl)}</span><div class="wsval">${body}</div></div>`;
  const menus = weaponMenus(s), tipOf = desc => desc && desc.replace(/\s+/g, '').toLowerCase() !== 'mainweapon' ? desc + ' · ' + t('ttWeapon') : t('ttWeapon');
  // the weapon states as in game, then what the job's GearSwap puts with them (off hand, ammo)
  const picks = (menus ? menus.map(([name, sel, desc]) => pick(name, sel).replace('<span class="wslbl">', `<span class="wslbl" title="${esc(tipOf(desc))}">`).replace('<select class="wmenu', `<select title="${esc(tipOf(desc))}" class="wmenu`)).join('') : '') +
    (family(s.path, s.pieces) !== 'weapons' ? weaponResultLines(s, pick) : '');
  const bar = `<div class="setctl"><div class="wpicks">${picks}</div></div>`;
  return `<div class="settop">${title}${setVersionsHTML(card, ci, vi)}${bar}</div>`;
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
  else foot.push(`<span title="${esc(t('ttDefined'))}">${Object.keys(s.pieces).length ? t('defined',{n:'<b>'+Object.keys(s.pieces).length+'</b>'}) : t('emptySet')}</span>`);
  if (s.aliases && s.aliases.length) foot.push(`<details><summary>${t('sharedCount', {n: s.aliases.length})}</summary><p>${s.aliases.map(a => esc(shortPath(a))).join(' · ')}</p></details>`);
  const holds = {missing: [], short: [], porter: []};
  for (const slot of SLOTS) { const st = holdState(slot, eff.pieces[slot]); if (st && !holds[st].includes(eff.pieces[slot].name)) holds[st].push(eff.pieces[slot].name); }
  // at the Porter Moogle: which slip, to take it out
  const slipOf = n => [...new Set(Object.values(ownedOf()).flat().filter(x => x.name === n).flatMap(x => x.where || []))].map(w => w.replace(/^Slip/, 'slip')).join(', ');
  if (holds.porter.length) foot.push(`<span class="holdporter">${t('holdPorter', {l: esc(holds.porter.map(n => n + ' (' + slipOf(n) + ')').join(', '))})}</span>`);
  if (holds.missing.length) foot.push(`<span class="holdmiss">${t('holdMissing', {l: esc(holds.missing.join(', '))})}</span>`);
  if (holds.short.length) foot.push(`<span class="holdshort">${t('holdShort', {l: esc(holds.short.join(', '))})}</span>`);
  // the legend, always in sight on one line under the grid (legendHTML): folded, its title took the room it needs
  const legend = legendHTML(holds);
  const ws = card.fam === 'ws' && family(s.path, s.pieces) === 'ws', head = ws ? wsTitleHTML(s) : '';
  // the page in three bands: what the set is (a weaponskill set: the weaponskill, what its figures are worked out with),
  // the equipment beside its stats, then the optimizer on the whole width
  const locked = baseOnly(s), optable = !locked && ((ws && wsOfSet(s)) || isNukeSet(s.path) || roundSet(s) || statSet(s));
  if (optable && optPageOpen(s)) return optPageHTML(s, ws && wsOfSet(s));
  // its actions on the title line: the optimizer, then deleting it
  const acts = `<span class="setacts">${optable && engineReady() ? `<button class="btn" data-optview title="${esc(t('ttOptOpen'))}">${t('optOpenBtn')}</button>` : ''}${(ws && !wsOfSet(s)) || locked ? '' : delButton(s)}</span>`;
  const top = ws ? `<div class="settop">${wsTitleHTML(s, acts)}${wsOfSet(s) ? setVersionsHTML(card, ci, vi) : '<div class="setvers none"></div>'}` +
      (wsOfSet(s) ? `<div class="setctl">${wsHeadHTML(card, ci, vi, s)}</div>` : '') + `</div>`
    : setHeadHTML(card, ci, vi, s, acts);
  // a family's note and a base set's go under the gear, where nothing is left to push down (over it, the gear moved
  // from a set with a note to one without)
  const notes = familyNoteHTML(card, s) + (locked && !ws ? `<p class="famnote">${esc(t('baseOnly', {l: data().sets.filter(x => x.base === s.path).map(x => shortPath(x.path)).join(', ')}))}</p>` : '');
  return `<article class="detail"><header>${top}${trialBar(s)}</header>
    <div class="dbody"><div class="eqcol"><div class="slotcol"><div class="slots">${slots}</div>${equipBtnHTML()}</div><footer>${foot.map(f => '<span>'+f+'</span>').join('')}</footer>${ui2() ? ui2Wants(s) : ''}${legend}${notes}</div>${ui2() ? '' : setStatsHTML(s)}</div>
    <div class="globals-inline">${(S._globals = {s, html: ui2() ? setPanelHTML(s) : globalsHTML(s)}).html}</div></article>`;
}
const famOpen = (fam, q) => !!q || !!S.famOpen[S.job + '|' + fam];
// The game on this job with another subjob than the page shows (the live link, live.js): every figure is then the other
// subjob's (its base attributes, traits, sets), said with a button to show the game's
function subWarnHTML(){
  const L = (S._live || {})[S.char], d = data();
  if (!L || !L.ok || L.job !== S.job || !d || !L.sub || L.sub === 'NONE' || L.sub === d.sub) return '';
  const text = t('subWarn', {g: L.job + '/' + L.sub, p: S.job + '/' + d.sub});
  return `<p class="kwarn subwarn"><span title="${esc(text)}">${esc(text)}</span> <button class="btn" data-subfix="${esc(L.sub)}">${esc(t('subFix', {s: L.sub}))}</button></p>`;
}
// A version of a set for a party: the label of a variant against its set's ("Laphria · Group" against "Laphria",
// "Trust" against the family's own set, "Base"); null for anything else
const TIER_LABELS = ['Group', 'Solo', 'Trust'];
function tierLabel(label, head){
  const rest = head === 'Base' ? label : label.startsWith(head + ' · ') ? label.slice(head.length + 3) : '';
  return TIER_LABELS.includes(rest) ? rest : null;
}
Object.assign(T.fr, {rowTry: 'Des pièces sont à l’essai dans ce set', rowVoid: 'vide', listPaths: 'Chemins', openShort: 'Déplier', closeShort: 'Replier', listPathsTip: 'Montre sous chaque set son nom dans ton fichier (sets.engaged.Laphria…)', searchShort: 'Chercher…'});
Object.assign(T.en, {rowTry: 'Pieces are on trial in this set', rowVoid: 'empty', listPaths: 'Paths', openShort: 'Open', closeShort: 'Close', listPathsTip: 'Shows under each set its name in your file (sets.engaged.Laphria…)', searchShort: 'Search…'});
// The variant of a card shown in its detail
function shownSet(card, ci){ return card.variants[Math.min(S.variant[S.job + '|' + ci] ?? 0, card.variants.length - 1)].set; }

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
function renderJob(){
  const c = S.job, d = data();
  let body;
  if (!d) body = `<div class="placeholder"><p><b>${c}</b> : ${plays(c)?t('placeholder'):t('notPlayed',{c:S.char})}</p>${otherChar()?`<button class="btn ghost" data-char="${otherChar()}">${t('seeOther',{c:otherChar()})}</button>`:''}</div>`;
  else {
    // the Merits are in My character; the keys, modes, switches and macro book are the parts of the job's settings
    // (a page kept on one of those four names, or sent there by a link, opens that part)
    if (ui2() && S.section === 'merits') S.section = 'perso';
    if (!ui2() && ['combat', 'perso'].includes(S.section)) S.section = 'sets';
    // the job's settings, My character, Buffs & target and Sets are the Svelte application's (atelier/src/screens/config,
    // screens/perso, screens/combat, screens/sets)
    if (S.section === 'jobcfg' || S.section === 'perso' || S.section === 'combat' || S.section === 'sets') return '';
    body = {sim: renderSim}[S.section](d);
  }
  // the row of the sections over it is the Svelte application's (atelier/src/screens/topbar/Sections.svelte)
  return `<div class="pane ${d ? 'split' : ''}">${body}</div>`;
}
// Re-render, keeping the focus of the search box and the scroll of each block
// while the view stays the same (the set detail goes back to its top for another set)
// (.globalcol: the right column, its compartments folded and unfolded in place)
// What tells a folded block from the others of the page: its classes and its title without the figures in it
// (without the classes an animation leaves on it for a moment: motion.js)
const foldKey = el => [...el.classList].filter(c => !MOTION_MARKS.includes(c)).join(' ') + '|' + ((el.querySelector('summary') || {}).textContent || '').replace(/[\d.,%−+-]+/g, '').trim().slice(0, 60);
const MOTION_MARKS = ['opens', 'unfolds', 'flash', 'rolls', 'fills'];
const SCROLLERS = ['.pane', '.setlist .scroll', '.detail', '.globalcol'];
// A click redraws the page whole: no block may jump back to its top for it. Beside the four above (which have their
// own rules), every block that was scrolled is found again by its place in the page (the tag and first class of each
// of its ancestors, and its rank among its like) and put back where it was
const scrollKind = e => e.tagName + '.' + (e.classList[0] || '');
function scrollKeep(){
  const own = SCROLLERS.join(','), out = [];
  for (const el of document.querySelectorAll('#view *')) {
    if (!el.scrollTop || el.matches(own)) continue;
    const path = [];
    for (let e = el; e && e.id !== 'view'; e = e.parentElement) {
      let rank = 0;
      for (let s = e.previousElementSibling; s; s = s.previousElementSibling) if (scrollKind(s) === scrollKind(e)) rank++;
      path.unshift([scrollKind(e), rank]);
    }
    out.push({path, top: el.scrollTop});
  }
  return out;
}
function scrollPut(kept){
  for (const {path, top} of kept) {
    let el = $('#view');
    for (const [kind, rank] of path) { el = el && [...el.children].filter(c => scrollKind(c) === kind)[rank]; }
    if (el) el.scrollTop = top;
  }
}
function render(){
  // a row of the list is being dragged: the page waits (a redraw would take the row from under the pointer)
  if (LIST_DRAG) return;
  // one of the four old tab names (a page kept on it, a link): the job's settings, on that part; settled before the
  // view is named, so that the scroll kept for this view is found again
  if (JOB_CFG.includes(S.section)) { S.jobTab = S.section; S.section = 'jobcfg'; }
  const view = [S.char, S.job, S.section, S.section === 'jobcfg' ? S.jobTab : ''].join('|'), set = view + '|' + S.sel[S.job];
  const tops = SCROLLERS.map(q => { const el = $(q); return el ? el.scrollTop : 0; });
  const kept = S._view === view ? scrollKeep() : [];
  const a = document.activeElement, id = a && a.id, pos = a && a.selectionStart;
  // a folded block the player opened stays open through a redraw of the same tab: a click inside it (a job, a
  // tab, a mode) draws the page again, and the block closed under the pointer (2026-10-10)
  const opened = S._view === view ? new Set([...document.querySelectorAll('#view details[open]')].map(foldKey)) : new Set();
  renderSide(); $('#legacyview').innerHTML = S._pkg && typeof renderPackages === 'function' ? renderPackages() : S._cfg ? renderConfig() : S.job ? renderJob() : renderHome(); save();
  // the Svelte screens (atelier/src/: the top bar, the sections, the screens moved) read the state again now, before
  // the focus, the folded blocks and the scroll are put back: theirs too (they are in #view beside #legacyview)
  if (window.__atelier && window.__atelier.redraw) window.__atelier.redraw();
  for (const el of document.querySelectorAll('#view details:not([open])')) if (opened.has(foldKey(el))) el.open = true;
  // another view starts at the top: a block the Svelte screens keep between redraws (the list of sets) would
  // otherwise stay where it was scrolled for the job or tab before
  SCROLLERS.forEach((q, i) => { const el = $(q);
    if (el) el.scrollTop = S._view === view && (q !== '.detail' || S._set === set) ? tops[i] : 0; });
  scrollPut(kept);
  scrollBack(view, set);
  // the set shown, newly chosen: its row brought into the list's sight (nothing moves when it is already there)
  if (S._revealNow) { S._revealNow = false; const cur = $('.setlist .setrow[aria-current="true"]'), box = cur && cur.closest('.scroll');
    if (cur) { cur.scrollIntoView({block: 'nearest', inline: 'nearest'}); if (box) box.scrollLeft = 0; } }
  S._view = view; S._set = set;
  if (id) { const el = document.getElementById(id); if (el) { el.focus(); if (pos != null && el.setSelectionRange) el.setSelectionRange(pos, pos); } }
  if (S._buffDlg && !$('#overlay').hidden && $('.buffdlg')) openBuffs();
  if (S._tgtDlg && !$('#overlay').hidden && $('.tgtdlg')) openTarget();
  shapeKeep();
  motionAfter();
  guideAfter();
}
// A block whose size follows its content (the set's own figures: an attack block, a tank's defense block, both) is
// given the tallest size it ever had for this character and job at this width: after the tallest set was seen once,
// nothing under it moves again, in this visit and the next ones (S.shapes, kept in the browser)
const SHAPES = {own: '.globalcol .ui2own', top: '.setsx.ui2 .detail > header:not(.ophead) > .settop'};
function shapeKeep(){
  S.shapes = S.shapes || {};
  let learnt = false;
  for (const [key, q] of Object.entries(SHAPES)) {
    const el = $(q);
    if (!el || !el.clientWidth) continue;
    const k = [S.char, S.job, key, Math.round(el.clientWidth / 40)].join('|');
    el.style.minHeight = '';
    const h = Math.ceil(el.getBoundingClientRect().height);
    if (h > (S.shapes[k] || 0)) { S.shapes[k] = h; learnt = true; }
    el.style.minHeight = S.shapes[k] + 'px';
  }
  if (learnt) save();
}

// After a reload of the page (F5): back where it was, whatever the tab: Settings open if it was, the folded blocks
// that were open, every block scrolled (the four above and any other, found again by its place) and the page itself.
// Kept in this browser only: the page works without it. Put back at the first redraw that shows the same view, and
// again at the redraws of the next seconds (the game's data comes after the files' and makes the page longer),
// until the player scrolls, clicks or types
const SCROLL_STORE = 'atelier_scroll', SCROLL_BACK_MS = 4000;
let SCROLL_KEPT = null;
try { SCROLL_KEPT = JSON.parse(localStorage.getItem(SCROLL_STORE) || 'null'); } catch (e) { SCROLL_KEPT = null; }
if (SCROLL_KEPT && SCROLL_KEPT.cfg) S._cfg = true;
function scrollBack(view, set){
  const kept = SCROLL_KEPT;
  if (!kept || S._scrollBack === true) return;
  // the files are still being read (no tab drawn yet): wait for the redraw that follows
  if (!$(kept.cfg ? '.cfg' : '.pane')) return;
  if (kept.view !== view || !!kept.cfg !== !!S._cfg) { S._scrollBack = true; return; }
  if (!S._scrollBack) S._scrollBack = Date.now();
  else if (Date.now() - S._scrollBack > SCROLL_BACK_MS) { S._scrollBack = true; return; }
  const open = new Set(kept.open || []);
  for (const el of document.querySelectorAll('#view details:not([open])')) if (open.has(foldKey(el))) el.open = true;
  SCROLLERS.forEach((q, i) => { const el = $(q); if (el && (kept.tops || [])[i] && (q !== '.detail' || kept.set === set)) el.scrollTop = kept.tops[i]; });
  scrollPut(kept.kept || []);
  if (kept.win) scrollTo({top: kept.win});
}
// the player moved: what was kept no longer says where the page should be
for (const ev of ['wheel', 'pointerdown', 'keydown', 'touchstart']) addEventListener(ev, () => { S._scrollBack = true; }, {passive: true, capture: true});
function scrollStore(){
  try { localStorage.setItem(SCROLL_STORE, JSON.stringify({view: S._view, set: S._set, cfg: !!S._cfg, tops: SCROLLERS.map(q => ($(q) || {}).scrollTop || 0),
    kept: scrollKeep(), win: window.scrollY || 0, open: [...document.querySelectorAll('#view details[open]')].map(foldKey)})); } catch (e) {}
}
window.addEventListener('beforeunload', scrollStore);
window.addEventListener('pagehide', scrollStore);

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
  if (fam==='weapons' || fam==='other' || fam==='xp') n = s.length;
  // a Cure set's card: down to its Cure name (precast.FC.CureSelf, midcast.CureSelf), its versions under it
  if (fam==='cure') n = s.findIndex(x => /^Cur/.test(x)) + 1 || s.length;
  return s.slice(0, Math.min(n, s.length));
}
function buildCards(d){
  // a set shared under several names (sets.idle.MDT = sets.engaged.MDT) is found by each of them
  const bypath = {}; for (const s of d.sets) { bypath[s.path] = s; for (const a of s.aliases || []) bypath[a] = bypath[a] || s; }
  const cards = [], index = {};
  for (const s of d.sets) {
    const fam = cardFamily(s.path, s.pieces);
    const top = topOf(s.path, fam); const key = fam + '|' + top.join('/');
    if (!index[key]) { index[key] = {fam, name: top[top.length-1], top, variants:[]}; cards.push(index[key]); }
    const rest = segs(s.path).slice(top.length).join(' · ');
    index[key].variants.push({label: rest || 'Base', set: s});
  }
  for (const c of cards) c.variants.sort((a,b) => (a.label==='Base'?-1:b.label==='Base'?1:a.label.localeCompare(b.label)));
  const order = ['idle','engaged','fc','ws','ja','cure','midcast','enmity','pet','special','xp','weapons','other'];
  const lead = c => c.top.length === 1 && c.top[0] === c.fam ? 0 : 1;
  cards.sort((a,b) => order.indexOf(a.fam)-order.indexOf(b.fam) || lead(a)-lead(b) || a.name.localeCompare(b.name));
  return {cards, bypath};
}
function niceName(card){
  const n = card.name;
  // the game's and GearSwap's own words in every language (a category or a set is not translated: the player reads
  // "engaged" in the file and in every guide); only what the file abbreviates is written out
  const map = {idle: 'Idle', engaged: 'Engaged', FC: 'Fast Cast', WS: 'Weaponskills', TreasureHunter: 'Treasure Hunter'};
  return map[n] || n;
}
// A card matches the search when one of its variants has the text in its path, in a name it is shared under
// (sets.midcast.Flash = sets.FullEnmity) or in a piece name
function cardMatch(card, q){
  return !q || card.variants.some(v => v.set.path.toLowerCase().includes(q) || (v.set.aliases || []).some(a => a.toLowerCase().includes(q))
    || Object.values(v.set.pieces).some(p => p.name.toLowerCase().includes(q)));
}
// The names a set is shared under, each in the family its own name belongs to (sets.midcast.Flash = sets.FullEnmity
// is a spell's set: listed with the spells), a link to the set it is: [{fam, label, path, of, i, k}]
function aliasRows(cards, q){
  const out = [];
  cards.forEach((c, i) => c.variants.forEach((v, k) => { for (const a of v.set.aliases || []) {
    if (q && !a.toLowerCase().includes(q)) continue;
    out.push({fam: cardFamily(a, v.set.pieces), label: segs(a).pop(), path: a, of: v.set.path, i, k}); } }));
  return out.sort((a, b) => a.label.localeCompare(b.label));
}


// The SIRD of the merits (res/merit_points.lua: "Spell Interruption Rate" 2 % a level), as the Merits tab has them
function sirdMeritsOf(c){
  const m = (meritList() || []).find(x => x.key === 'spell_interruption_rate');
  if (m) return 2 * meritLevel(m);
  return 2 * Object.entries((c && c.merits) || {}).reduce((n, [k, lv]) => k.toLowerCase().replace(/_/g, ' ') === 'spell interruption rate' ? n + lv : n, 0);
}
/* ---- the column of figures beside a set ---- */
function globalsHTML(s, only){
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
  const sirdMerits = sirdMeritsOf(c);
  const sird = v('sird') + sirdMerits;
  const gear = damageTakenLines(v) + pct('Haste', v('haste'), 25) + pct('Fast Cast', v('fc'), 80) +
    (sird ? statLi('SIRD', sird + ' %', sirdMerits ? `<em class="delta">${t('withMerits')}</em>` : '', '', `${t('gearOnly')} ${v('sird')} % + ${t('merits')} ${sirdMerits} %`) : '');
  const levels = [c.master_level ? `ML ${c.master_level}` : '', c.jp_spent ? `${c.jp_spent} JP` : ''].filter(Boolean).join(' · ');
  const edited = Object.keys(S.meritEdits[meritKey()] || {}).length;
  const you = fbox('you', 'g-you', t('youTitle') + (edited ? ` <span class="edited">· ${t('meritsEdited', {n: edited})}</span>` : ''),
    `${vsSet ? `<p class="vsset">${t('vsSet')}</p>` : ''}<ul class="statlist big">${main}</ul>`);
  // the new layout's "every stat" fold ('stats') and My character tab ('cards': open, without the note): the
  // character's figures alone (layout2.js)
  if (only === 'cards') return box('g-you', t('youTitle'), `<ul class="statlist big">${main}</ul>`) +
    box('g-attr', t('attrTitle'), `<ul class="statlist">${attrs}</ul>`) + box('g-caps', t('gearKey'), `<ul class="statlist">${gear}</ul>`);
  if (only === 'stats') return `<div class="globals">${you}${fbox('attr', 'g-attr', t('attrTitle'), `<ul class="statlist">${attrs}</ul>`)}` +
    `${fbox('caps', 'g-caps', t('gearKey'), `<ul class="statlist">${gear}</ul>`)}<p class="note-m">${levels ? esc(levels) + ' · ' : ''}${t('measured', {at: esc(c.at), s: esc(c.sub || '—')})}</p></div>`;
  return `<div class="globals">${buffCardHTML()}${targetCardHTML(s)}${you}${fbox('attr', 'g-attr', t('attrTitle'), `<ul class="statlist">${attrs}</ul>`)}` +
    `${fbox('caps', 'g-caps', t('gearKey'), `<ul class="statlist">${gear}</ul>`)}${tankHTML(r)}${hpCycleHTML(s)}${luopanHTML(s)}${offenseHTML(r, s)}${porterHTML()}` +
    `<p class="note-m">${levels ? esc(levels) + ' · ' : ''}${t('measured', {at: esc(c.at), s: esc(c.sub || '—')})}</p></div>`;
}


