// GearSwap Atelier · target_pick.js: the target, as a monster's card and a picker one enjoys using.
// The card (the "Buffs & target" tab): who it is, your chance to hit it with the set opened, its Defense and Evasion
// as gauges that show what the debuffs take off, its VIT and HP, what it resists.
// The picker: every monster as a card in a grid, by zone; a search, the zones as a filter, favourites and the last
// ones chosen on top. A monster's levels are buttons on its card, each in the colour of your chance to hit it at
// that level with the set opened (green, amber, red): the difficulty is read before choosing.
// The data: atelier/targets.js (TARGETS). S.tgtFav[char] the favourites, S.tgtRecent[char] the last chosen.

Object.assign(T.fr, {tgChange: 'Changer de cible', tgHit: 'Tu la touches', tgHitTip: 'Ta précision avec le set ouvert ({a}) contre son évasion une fois les debuffs comptés ({e}). Plafond {c} %.',
  tgNoAcc: 'ouvre un set Engaged pour voir ton taux de toucher', tgDefTip: 'Sa défense : {a} au départ, {b} une fois Dia, Frailty et les autres debuffs comptés. Plus elle est basse, plus tu frappes fort.',
  tgEvaTip: 'Son évasion : {a} au départ, {b} une fois Distract et les autres debuffs comptés. Plus elle est basse, plus tu touches.',
  tgRes: 'Résistances', tgNoRes: 'aucune résistance connue', tgEst: 'Estimé : {l}. Ces chiffres ne sont pas mesurés.', tgRef: 'Une cible de référence, pas un monstre : les valeurs qu’utilisent les guides.',
  tgAllZones: 'Toutes', tgFavs: 'Favoris', tgRecent: 'Récents', tgFav: 'Mettre en favori', tgUnfav: 'Retirer des favoris', tgNone: 'Aucun monstre ne correspond.',
  tgLvTip: '{k} : Déf {d} · Éva {e}{h}', tgLvHit: ' · tu la touches à {p} %', tgSort: 'Trier', tgSort_zone: 'par zone', tgSort_lv: 'par niveau', tgSort_hit: 'du plus facile au plus dur',
  tgRes_slash: 'Tranchant', tgRes_pierce: 'Perçant', tgRes_blunt: 'Contondant', tgRes_ranged: 'Distance', tgRes_magic: 'Magie', tgRes_breath: 'Souffle', tgCount: '{n} monstre(s), {z} zone(s)'});
Object.assign(T.en, {tgChange: 'Change target', tgHit: 'You hit it', tgHitTip: 'Your accuracy with the set opened ({a}) against its evasion once the debuffs are counted ({e}). Cap {c} %.',
  tgNoAcc: 'open an Engaged set to see your hit rate', tgDefTip: 'Its defense: {a} at first, {b} once Dia, Frailty and the other debuffs are counted. The lower, the harder you hit.',
  tgEvaTip: 'Its evasion: {a} at first, {b} once Distract and the other debuffs are counted. The lower, the more you hit.',
  tgRes: 'Resistances', tgNoRes: 'no known resistance', tgEst: 'Estimated: {l}. These figures are not measured.', tgRef: 'A reference target, not a monster: the values the guides use.',
  tgAllZones: 'All', tgFavs: 'Favourites', tgRecent: 'Recent', tgFav: 'Make it a favourite', tgUnfav: 'Take out of the favourites', tgNone: 'No monster matches.',
  tgLvTip: '{k}: Def {d} · Eva {e}{h}', tgLvHit: ' · you hit it {p} % of the time', tgSort: 'Sort', tgSort_zone: 'by zone', tgSort_lv: 'by level', tgSort_hit: 'easiest first',
  tgRes_slash: 'Slashing', tgRes_pierce: 'Piercing', tgRes_blunt: 'Blunt', tgRes_ranged: 'Ranged', tgRes_magic: 'Magic', tgRes_breath: 'Breath', tgCount: '{n} monster(s), {z} zone(s)'});

/* ---- your chance to hit, with the set opened ---- */
// {acc, cap, down}: the set's accuracy, the cap of its weapon (95 % two-handed, 99 %), the Evasion the debuffs take
// off; null when the page cannot tell (no set opened, no stats measured)
function tgYou(){
  try { const s = S._curSet, r = s && charStats(s);
    if (!r || !r.cur || r.cur.acc == null) return null;
    return {acc: r.cur.acc, cap: r.cur.wskill && TWO_HANDED.test(r.cur.wskill) ? 95 : 99, down: (r.B && r.B.eeva) || 0};
  } catch (e) { return null; }
}
const tgRate = (you, eva) => you ? Math.floor(Math.max(20, Math.min(you.cap, 75 + 0.5 * (you.acc - Math.max(0, eva - you.down))))) : null;
const tgTone = p => p == null ? '' : p >= 90 ? 'easy' : p >= 70 ? 'mid' : 'hard';

/* ---- the card ---- */
function targetCardPanel(b){
  const key = enemyKey(b.enemy), x = TARGETS[key] || {}, T0 = targetInfo(null), you = tgYou(), p = tgRate(you, T0.eva);
  const defA = Math.max(1, T0.defAfter), evaA = T0.evaAfter;
  // a gauge: the full bar is the stat at first, the lit part what is left of it
  const gauge = (label, a, z, tip) => `<div class="tggauge" title="${esc(tip)}"><span>${esc(label)}</span><b>${a}${z !== a ? ` <i>→</i> <em>${z}</em>` : ''}</b>` +
    `<u style="--left:${a ? Math.max(0, Math.min(100, z / a * 100)).toFixed(1) : 100}%"></u></div>`;
  const res = Object.entries(x.res || {}).filter(([, v]) => v).map(([k, v]) => `<span class="${v < 0 ? 'bad' : 'good'}">${esc(t('tgRes_' + k))} ${v > 0 ? '+' : '−'}${Math.abs(Math.round(v * 100) / 100)} %</span>`).join('');
  const hit = you ? `<div class="tghit ${tgTone(p)}" title="${esc(t('tgHitTip', {a: you.acc, e: evaA, c: you.cap}))}"><span>${esc(t('tgHit'))}</span><b>${p} %</b></div>`
    : `<div class="tghit none"><span class="muted small">${esc(t('tgNoAcc'))}</span></div>`;
  const facts = [x.lv ? 'Lv ' + x.lv : '', x.job, x.zone].filter(Boolean).join(' · ') || t('pkDefault');
  return `<div class="tgcard"><div class="tgtop"><div class="tgname"><b>${esc(x.name || key)}</b><span class="muted small" title="${esc(x.zone ? '' : t('tgRef'))}">${esc(facts)}</span></div>${hit}</div>` +
    gauge(t('tgtDef'), T0.def, defA, t('tgDefTip', {a: T0.def, b: defA})) + gauge(t('tgtEva'), T0.eva, evaA, t('tgEvaTip', {a: T0.eva, b: evaA})) +
    `<div class="tgmore">${x.vit ? `<span>VIT <b>${x.vit}</b></span>` : ''}${x.hp ? `<span>HP <b>${fmtDmg(x.hp)}</b></span>` : ''}</div>` +
    (x.zone ? `<div class="tgres" title="${esc(t('tgRes'))}">${res || `<span class="muted">${esc(t('tgNoRes'))}</span>`}</div>` : '') +
    (x.est && x.est.length ? `<p class="muted small tgest">* ${esc(t('tgEst', {l: x.est.join(', ')}))}</p>` : '') +
    `<button class="btn tgchange" data-tgtpick title="${esc(t('ttTgtPick'))}">${esc(t('tgChange'))}</button></div>`;
}

/* ---- the picker ---- */
const tgFavs = () => { S.tgtFav = S.tgtFav || {}; return S.tgtFav[S.char] = S.tgtFav[S.char] || []; };
const tgRecents = () => { S.tgtRecent = S.tgtRecent || {}; return S.tgtRecent[S.char] = S.tgtRecent[S.char] || []; };
// the monsters, one a name and a zone, with their levels
function tgMonsters(){
  const out = new Map();
  for (const x of Object.values(TARGETS)) { if (x.key === DEFAULT_ENEMY) continue;
    const id = x.zone + '|' + x.name;
    if (!out.has(id)) out.set(id, {id, name: x.name, zone: x.zone, job: x.job, est: x.est || [], levels: []});
    out.get(id).levels.push(x); }
  return [...out.values()];
}
function tgCardHTML(m, cur, you){
  const fav = tgFavs().includes(m.id), on = m.levels.some(x => x.key === cur);
  const rates = m.levels.map(x => tgRate(you, x.eva)), worst = rates.filter(v => v != null).length ? Math.min(...rates.filter(v => v != null)) : null;
  const lv = m.levels.map((x, i) => { const p = rates[i], label = x.key.split(' · ')[1] || (x.lv ? 'Lv' + x.lv : x.key);
    return `<button class="tglv ${tgTone(p)}" data-tgtgo="${esc(x.key)}" aria-pressed="${x.key === cur}" ` +
      `title="${esc(t('tgLvTip', {k: x.key, d: x.def, e: x.eva, h: p == null ? '' : t('tgLvHit', {p})}))}">${esc(label)}</button>`; }).join('');
  const lo = Math.min(...m.levels.map(x => x.lv || 0)), top = Math.max(...m.levels.map(x => x.lv || 0));
  return `<div class="tgm ${on ? 'on' : ''}" data-q="${esc((m.name + ' ' + m.zone + ' ' + (m.job || '')).toLowerCase())}" data-zone="${esc(m.zone)}" data-lv="${top}" data-hit="${worst == null ? -1 : worst}">` +
    `<button class="ract tgstar" data-tgtfav="${esc(m.id)}" aria-pressed="${fav}" title="${esc(t(fav ? 'tgUnfav' : 'tgFav'))}">${fav ? '★' : '☆'}</button>` +
    `<div class="tgmh"><b>${esc(m.name)}${m.est.length ? ' <i title="' + esc(t('tgEst', {l: m.est.join(', ')})) + '">*</i>' : ''}</b>` +
    `<span class="muted small">${esc([m.job, m.zone].filter(Boolean).join(' · '))}</span></div>` +
    `<div class="tgmf"><span>Lv <b>${lo === top ? top : lo + '–' + top}</b></span><span>${esc(t('tgtDef'))} <b>${Math.min(...m.levels.map(x => x.def))}${m.levels.length > 1 ? '–' + Math.max(...m.levels.map(x => x.def)) : ''}</b></span>` +
    `<span>${esc(t('tgtEva'))} <b>${Math.min(...m.levels.map(x => x.eva))}${m.levels.length > 1 ? '–' + Math.max(...m.levels.map(x => x.eva)) : ''}</b></span></div><div class="tglvs">${lv}</div></div>`;
}
function openTargetPick(){
  S._buffDlg = false; S._tgtPick = true;
  const cur = enemyKey(buffState().enemy), you = tgYou(), all = tgMonsters(), zones = [...new Set(all.map(m => m.zone))];
  const byId = Object.fromEntries(all.map(m => [m.id, m])), idOf = k => { const x = TARGETS[k]; return x ? x.zone + '|' + x.name : null; };
  const favs = tgFavs().map(id => byId[id]).filter(Boolean), recent = [...new Set(tgRecents().map(idOf))].map(id => byId[id]).filter(m => m && !favs.includes(m)).slice(0, 6);
  const strip = (label, list) => list.length ? `<section class="tgstrip"><h4>${esc(label)}</h4><div class="tggrid">${list.map(m => tgCardHTML(m, cur, you)).join('')}</div></section>` : '';
  const zoneBtn = (z, n) => `<button class="chip" data-tgtzone="${esc(z)}" aria-pressed="${(S._tgtZone || '') === z}">${esc(z || t('tgAllZones'))}<small>${n}</small></button>`;
  const sort = ['zone', 'lv', 'hit'].filter(k => k !== 'hit' || you).map(k => `<option value="${k}" ${(S._tgtSort || 'zone') === k ? 'selected' : ''}>${esc(t('tgSort_' + k))}</option>`).join('');
  const body = `<div class="tgtools"><input id="tgq" class="tgq" type="search" placeholder="${esc(t('pkSearch'))}" autocomplete="off" spellcheck="false">` +
    `<label class="tgsort muted small">${esc(t('tgSort'))} <select class="buffsel" data-tgtsort>${sort}</select></label>` +
    `<button class="chip tgref" data-tgtgo="" aria-pressed="${cur === DEFAULT_ENEMY}" title="${esc(t('tgRef'))}">${esc(DEFAULT_ENEMY)}</button></div>` +
    `<div class="tgzones">${zoneBtn('', all.length)}${zones.map(z => zoneBtn(z, all.filter(m => m.zone === z).length)).join('')}</div>` +
    `<div class="tgbody">${strip(t('tgFavs'), favs)}${strip(t('tgRecent'), recent)}<section class="tgall"><div class="tggrid">${all.map(m => tgCardHTML(m, cur, you)).join('')}</div>` +
    `<p class="muted small tgnone" hidden>${esc(t('tgNone'))}</p></section></div>` +
    `<p class="muted small tgfoot">${esc(t('tgCount', {n: all.length, z: zones.length}))} · ${esc(t('pkStar'))}</p>`;
  $('#overlay').innerHTML = `<div class="scrim" data-close></div><div class="dialog tgdlg" role="dialog" aria-label="${esc(t('pkTitle'))}">` +
    `<header><h3>${esc(t('pkTitle'))}</h3><button class="btn ghost" data-tgtback>${esc(t('pkBack'))}</button></header><div class="body">${body}</div></div>`;
  $('#overlay').hidden = false;
  tgFilter();
  const q = $('#tgq'); if (q) { q.value = S._tgtQ || ''; q.focus(); }
}
// the cards the search and the zone leave, in the order asked: hidden and moved in place (no redraw while typing)
function tgFilter(){
  const grid = document.querySelector('.tgall .tggrid');
  if (!grid) return;
  const q = (S._tgtQ || '').trim().toLowerCase(), zone = S._tgtZone || '', sort = S._tgtSort || 'zone';
  const cards = [...grid.children];
  if (sort !== 'zone') cards.sort((a, b) => sort === 'lv' ? +a.dataset.lv - +b.dataset.lv : +b.dataset.hit - +a.dataset.hit).forEach(c => grid.appendChild(c));
  let left = 0;
  for (const c of cards) { const ok = (!q || c.dataset.q.includes(q)) && (!zone || c.dataset.zone === zone); c.hidden = !ok; if (ok) left++; }
  const none = document.querySelector('.tgnone'); if (none) none.hidden = left > 0;
  // the favourites and the last chosen are shortcuts: out of the way while one searches
  for (const s of document.querySelectorAll('.tgstrip')) s.hidden = !!q || !!zone;
}
document.addEventListener('click', e => {
  const b = e.target.closest && e.target.closest('button'), d = b ? b.dataset : {};
  if (!b || !b.closest('.tgdlg')) return;
  if (d.tgtgo != null) { const st = buffState(); if (d.tgtgo) st.enemy = d.tgtgo; else delete st.enemy;
    if (d.tgtgo) { const r = tgRecents(); S.tgtRecent[S.char] = [d.tgtgo].concat(r.filter(k => k !== d.tgtgo)).slice(0, 12); }
    S._tgtPick = false; S._globals = null; save(); closeOverlay(); return render(); }
  if (d.tgtfav) { const f = tgFavs(), i = f.indexOf(d.tgtfav); if (i < 0) f.push(d.tgtfav); else f.splice(i, 1); save(); return openTargetPick(); }
  if (d.tgtzone != null) { S._tgtZone = d.tgtzone; for (const x of b.parentElement.children) x.setAttribute('aria-pressed', String(x === b)); return tgFilter(); }
});
document.addEventListener('input', e => { if (e.target && e.target.id === 'tgq') { S._tgtQ = e.target.value; tgFilter(); } });
document.addEventListener('change', e => { if (e.target && e.target.dataset && 'tgtsort' in e.target.dataset) { S._tgtSort = e.target.value; openTargetPick(); } });
