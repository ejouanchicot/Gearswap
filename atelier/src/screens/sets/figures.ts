// GearSwap Atelier · the figures of a set, the column beside its card (the Sets screen): its own figures in a block of
// fixed height (the attack of an engaged or weaponskill set, the damage taken of the others, a nuke's fight box, the
// HP cycle, the Luopan), then its stats sheet, then every stat folded.
// The boxes are data (StatBox: its rows a label, a figure, a note, a tooltip): the tanking and attack boxes are worked
// out here, the old page's tankHTML / offenseHTML (engine.js) draw these same boxes through boxHtml (the buffs window,
// My character's cards). The rules are the old page's setPanelHTML (layout2.js), tankHTML, offenseHTML, fbox
// (core.js), statLi (stats.js). Still the old page's HTML: the fight box (fight_stats.js), the HP cycle
// (stat_opt.js), the Luopan (luopan.js), the stats sheet (stats.js setStatsHTML), every stat (globalsHTML), the
// extra tanking lines (tankExtraHTML). A field ending in Html is one of the old page's texts it wrote unescaped.
//
// @file    atelier/src/screens/sets/figures.ts
// @author  ejouanchicot

export interface StatRow { k: 'row'; cls: string; title: string | undefined; labelHtml: string; valueHtml: string; extraHtml: string }
export type BoxItem = StatRow | {k: 'html'; html: string};
export interface StatBox { key: string; cls: string; titleHtml: string; open: boolean; summary: string; count: number; noteHtml: string; items: BoxItem[]; foldTitle: string }
export interface FiguresView {
  title: string;
  ownHtml: string;
  boxes: StatBox[];
  afterHtml: string;
  sheetHtml: string;
  all: {open: boolean; title: string; label: string; html: string};
}

const st = (): LegacyAny => S;

// a line of figures: its label, its figure, a note beside, the stat's help as its tooltip (statLi)
function row(label: string, value: unknown, extra = '', cls = '', tip = ''): StatRow {
  return {k: 'row', cls, title: statHelp(label, tip) || undefined, labelHtml: label, valueHtml: String(value), extraHtml: extra};
}
// a box that folds, closed until opened (S.boxOpen); closed, its band says how many lines it holds (fbox)
function box(key: string, cls: string, title: string, items: BoxItem[], summary = '', noteHtml = ''): StatBox {
  const count = items.reduce((n, x) => n + (x.k === 'row' ? 1 : (x.html.match(/<li[ >]/g) || []).length), 0);
  return {key, cls, titleHtml: title, open: !!st().boxOpen[key], summary, count, noteHtml, items, foldTitle: t('ttFold')};
}

/** A box drawn as the old page's HTML, for the old page's own screens */
export function boxHtml(b: StatBox): string {
  const li = (x: BoxItem) => x.k === 'html' ? x.html
    : `<li class="${x.cls}"${x.title ? ` title="${esc(x.title)}"` : ''}><span>${x.labelHtml}</span><b>${x.valueHtml}</b><i>${x.extraHtml}</i></li>`;
  const body = `${b.noteHtml}<ul class="statlist">${b.items.map(li).join('')}</ul>`;
  return `<section class="box ${b.cls}"><button class="boxh bufftoggle" data-fold="${esc(b.key)}" aria-expanded="${b.open}" title="${esc(b.foldTitle)}"><h3>${b.titleHtml}</h3>` +
    `<span class="meta">${b.summary ? `<b class="boxsum">${esc(b.summary)}</b>` : ''}${b.count || ''}</span></button>${b.open ? `<div class="boxb">${body}</div>` : ''}</section>`;
}

/** The damage a hit does to you with the set: physical, magic, breath, enmity, Flash, Phalanx (tankHTML) */
export function tankBox(r: LegacyAny): StatBox {
  const {c, set, B} = r, v = (k: string) => (set[k] || {}).v || 0, mul = B.dmgmul || 1, pmul = mul * (B.pdmgmul || 1);
  const dt = v('dt'), shell = B.shell ? -B.shell / 256 * 100 : 0;
  const pdt = Math.max(Math.max(dt + v('pdt'), -50) + v('pdt2'), -87.5);
  const mdt = Math.max(Math.max(dt + v('mdt') + shell, -50) + v('mdt2'), -87.5);
  const mdb = v('mdb') + traitOf('mdb', c) + giftOf('mdb', c) + (B.mdb || 0);
  const fl = (x: number) => Math.floor(x + 1e-9);
  const phys = fl(1000 * (1 + pdt / 100) * pmul), mag = fl(fl(1000 * (1 + mdt / 100)) / (1 + mdb / 100) * mul);
  const breath = fl(1000 * (1 + Math.max(dt + v('bdt'), -50) / 100) * mul);
  const pctOf = (n: number) => `${signed(Math.round((n / 1000 - 1) * 1000) / 10)} %`;
  // what multiplies the damage taken (Rampart ×0.75, Fan Dance ×0.75...: past the -50 % cap)
  const muls = B._by.filter((e: LegacyAny) => e.k === 'dmgmul' || e.k === 'pdmgmul').map((e: LegacyAny) => `${e.src} ×${Math.round(e.v * 100) / 100}`).join(' · ');
  const items: BoxItem[] = [row(t('physHit'), phys, pctOf(phys), '', muls),
    row(t('magHit'), mag, pctOf(mag), '', t('magTip', {m: Math.round(Math.max(dt + v('mdt') + shell, -50) * 10) / 10, b: mdb})),
    row(t('breathHit'), breath, pctOf(breath))];
  const enm = v('enmity') + (B.enmity || 0), mult = enm >= 0 ? Math.min(1 + enm / 100, 3) : Math.max(1 + enm / 100, .5);
  if (enm) items.push(row(t('enmityLbl'), signed(enm), `×${mult.toFixed(2)}`, '', t('enmTip', {g: v('enmity'), b: B.enmity || 0})));
  if (enm && ['PLD', 'RUN'].includes(st().job)) items.push(row(t('flashLbl'), `${Math.floor(180 * mult)} / ${Math.floor(1280 * mult)}`, ''));
  const extra = tankExtraHTML(c, set, B, enm);
  if (extra) items.push({k: 'html', html: extra});
  const skill = skillLevel(c, 'enhancing magic') + v('skill:enhancing magic skill');
  if (['PLD', 'RUN', 'RDM'].includes(st().job) && skill) {
    const pot = phalanxPotency(skill);
    items.push(row('Phalanx', `−${pot + v('phalanx')}`, '', '', t('phalanxTip', {p: pot, s: skill, g: v('phalanx')})));
  }
  return box('tank', 'g-tank', t('tankTitle'), items, '', `<p class="note-m">${t('tankNote')}</p>`);
}

/** The attack of the set: accuracy, haste, TP a hit, a round, the hit rate, the target's defense, multi-attacks,
 * critical rate (offenseHTML); null without a weapon's delay */
export function offenseBox(r: LegacyAny, s: LegacyAny): StatBox | null {
  const {c, set, B, cur} = r, v = (k: string) => (set[k] || {}).v || 0;
  const pieces = withWeapons(s).pieces, rm = pieceStats(pieces.main), rs = pieceStats(pieces.sub);
  const d1 = rm && rm.weapon && +rm.weapon.Delay;
  if (!d1) return null;
  const d2 = (rs && rs.weapon && +rs.weapon.Delay) || 0, dual = d2 > 0;
  const dw = dual ? v('dw') + traitOf('dw', c) + giftOf('dw', c) : 0;
  const gh = Math.min(v('haste'), 25), mh = Math.min(B.mhaste || 0, 43.75), jh = Math.min(B.jahaste || 0, 25), haste = gh + mh + jh;
  const mdelay = dual ? (d1 + d2) / 2 * (1 - dw / 100) : d1;
  const stp = v('stp') + traitOf('stp', c) + giftOf('stp', c) + (B.stp || 0);
  const tph0 = Math.floor(tpBase(mdelay)), tph = tph0 + Math.floor(tph0 * stp / 100);
  const delay = d1 + (dual ? d2 : 0), round = Math.max(delay * (1 - dw / 100) * (1 - haste / 100), 0.2 * delay) / 60;
  const two = cur.wskill && TWO_HANDED.test(cur.wskill), enemyName = enemyKey(buffState().enemy);
  const eva = Math.max(0, ENEMIES[enemyName][2] - (B.eeva || 0)), cap = two ? 95 : 99;
  const edef = Math.round(ENEMIES[enemyName][1] * (1 - Math.min(B.edefp || 0, 1)));
  const r1 = (n: number) => Math.round(n * 10) / 10;
  // the accuracy the hit rate is worked out from, first: character (weapon skill, DEX, traits, gifts) + the set +
  // food and buffs
  const accB = Math.floor(B.acc || 0), items: BoxItem[] = [];
  if (cur.acc != null) items.push(row(t('accTotal'), cur.acc, t('accTotalNote', {g: v('acc'), b: accB}), '', t('accTotalTip', {g: v('acc'), b: accB, w: cur.wskill || '—', l: cur.level || 0})));
  items.push(row(t('hasteTot'), `${r1(haste)} %`, haste >= 93.75 ? 'cap' : '', '', t('hasteTip', {g: r1(gh), m: r1(mh), j: r1(jh)})),
    row(t('tpHit'), tph, '', '', t('tpTip', {d: Math.round(mdelay), s: stp})), row(t('hitsTo'), Math.ceil(1000 / tph), ''), row(t('roundLbl'), `${r1(round)} s`, ''));
  if (cur.acc != null) { const rate = Math.max(20, Math.min(cap, 75 + 0.5 * (cur.acc - eva)));
    items.push(row(t('hitRate'), `${Math.floor(rate)} %`, `cap ${cap}`, '', t('hitTip', {a: cur.acc, e: eva, n: enemyName}) + (two ? ' · ' + t('twoHand') : ''))); }
  items.push(row(t('enemyDef'), edef, B.edefp ? `−${Math.round(B.edefp * 1000) / 10} %` : '', '', t('enemyDefTip', {n: enemyName})));
  const da = v('da') + traitOf('da', c) + giftOf('da', c) + (B.da || 0), ta = v('ta') + (B.ta || 0);
  if (da || ta || v('qa')) items.push(row(t('multiLbl'), `${r1(da)} · ${ta} · ${v('qa')} %`, ''));
  const crit = v('crit') + (B.crit || 0);
  if (crit) items.push(row(t('critLbl'), `${r1(crit)} %`, ''));
  return box('off', 'g-off', t('offTitle'), items, cur.acc != null ? `${t('accLabel')} ${cur.acc}` : '');
}

/** The column of figures of a set (setPanelHTML), with what it keeps in the page's state (S._curSet) */
export function figuresView(s: LegacyAny): FiguresView {
  const S0 = st();
  S0._curSet = s;
  const r = charStats(s), fam = family(s.path, s.pieces);
  // a nuke set: its damage and the totals it is worked out with (fight_stats.js), not the tanking figures
  const fight = fightBoxHTML(s);
  const off = !fight && r && (fam === 'ws' || fam === 'engaged') ? offenseBox(r, s) : null;
  const boxes = fight ? [] : off ? [off] : r ? [tankBox(r)] : [];
  // (in the old page's order: the set's own figures, every stat, then its HP cycle and Luopan, its sheet)
  const all = {open: !!S0._ui2AllOpen, title: t('ttAllStats'), label: t('ui2All'), html: globalsHTML(s, 'stats')};
  const afterHtml = hpCycleHTML(s) + luopanHTML(s), sheetHtml = setStatsHTML(s);
  return {title: t('ui2SetTitle'), ownHtml: fight || '', boxes, afterHtml, sheetHtml, all};
}
