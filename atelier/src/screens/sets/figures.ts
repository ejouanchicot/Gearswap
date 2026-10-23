// GearSwap Atelier · the figures of a set, the column beside its card (the Sets screen): its own figures in a block of
// fixed height (the attack of an engaged or weaponskill set, the damage taken of the others, a nuke's fight box, the
// HP cycle, the Luopan), then its stats sheet, then every stat folded.
// The boxes are data (StatBox: its rows a label, a figure, a note, a tooltip): the tanking and attack boxes are worked
// out here, the old page's tankHTML / offenseHTML (engine.js) draw these same boxes through boxHtml (the buffs window,
// My character's cards). The rules are the old page's setPanelHTML (layout2.js), tankHTML, offenseHTML, fbox
// (core.js), statLi (stats.js), fightBoxHTML (fight_stats.js), hpCycleHTML (stat_opt.js), luopanHTML (luopan.js). The stats sheet: sheet.ts; every stat: globals.ts. A field ending in Html is one of the old page's texts it wrote unescaped.
//
// @file    atelier/src/screens/sets/figures.ts
// @author  ejouanchicot

import {globalsView, type GlobalsView} from './globals';
import {sheetView, type SheetView} from './sheet';

export interface StatRow { k: 'row'; cls: string; title: string | undefined; labelHtml: string; valueHtml: string; extraHtml: string }
export type BoxItem = StatRow | {k: 'html'; html: string};
// bare: only its note, no list (a nuke set the engine cannot sheet)
export interface StatBox { key: string; cls: string; titleHtml: string; open: boolean; summary: string; count: number; noteHtml: string; items: BoxItem[]; foldTitle: string; bare?: boolean }
export interface FiguresView {
  title: string;
  boxes: StatBox[];
  hp: HpCycleView | null;
  luopan: LuopanView | null;
  sheet: SheetView | null;
  all: {open: boolean; title: string; label: string; globals: GlobalsView};
}

const st = (): LegacyAny => S;

// a line of figures: its label, its figure, a note beside, the stat's help as its tooltip (statLi)
export function row(label: string, value: unknown, extra = '', cls = '', tip = ''): StatRow {
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

// The lines under the damage taken (stat_opt.js): a PLD's block with an ultimate shield, the enemy's critical hits
// left, a Cure set's Cure IV (on yourself: within the HP its Fast Cast leaves), the Enmity a tank loses on a hit
function tankExtra(c: LegacyAny, set: LegacyAny, B: LegacyAny, enm: number): StatRow[] {
  const S0 = st(), v = (k: string) => (set[k] || {}).v || 0, rows: StatRow[] = [], sub = (S0._curSet ? withWeapons(S0._curSet).pieces.sub : null) || {};
  const sh = ULTIMATE_SHIELDS[sub.name];
  if (sh && S0.job === 'PLD') {
    const rate = Math.min(100, (sh[0] + (B.block || 0)) * (B.blockmul || 1));
    rows.push(row(t('tkBlock'), `${Math.round(rate)} %`, `−${sh[1]} %`, '', t('tkBlockTip', {s: sub.name, b: sh[0], r: sh[1]})));
  }
  const merit = ((c.merits || {}).enemy_critical_hit_rate || 0), gear = v('ecrit');
  if (['PLD', 'RUN'].includes(S0.job) || gear) {
    const left = Math.max(1, 10 - merit + gear), over = Math.max(0, 1 - (10 - merit + gear));
    rows.push(row(t('tkCrit'), `${left} %`, over ? t('tkOver', {n: over}) : '', '', t('tkCritTip', {m: merit, g: gear})));
  }
  const cs = S0._curSet, F = (window as LegacyAny).FFXI;
  if (cs && /cur(e|a)/i.test(cs.path) && family(cs.path, cs.pieces) !== 'fc' && engineReady() && F.opt.cureIV) {
    const fig = statFigures(cs), pair = cureGap(cs);
    // the figures it is worked out with, to set beside the game's (MND / VIT measured, the page's buffs in)
    const b = statBase(cs), g: Record<string, number> = {};
    for (const [slot, p] of Object.entries(optPieces(withWeapons(cs).pieces)) as Array<[string, LegacyAny]>) { const sv = withVec(p, slot).st; for (const k of ['mnd', 'vit', 'heal']) g[k] = (g[k] || 0) + (sv[k] || 0); }
    const mnd = b.mnd + g.mnd, vit = b.vit + g.vit, heal = b.heal + g.heal;
    const parts = t('tkCureParts', {m: mnd, mb: b.mnd, mg: g.mnd, v: vit, vb: b.vit, vg: g.vit, s: heal, p: Math.floor(mnd / 2) + Math.floor(vit / 4) + heal});
    rows.push(row(t('tkCure'), `${fig.cureIV} HP`, pair ? t('tkCureSelf', {h: fig.cureSelf}) : '', '', parts + ' ' + t('statCure4Tip')));
  }
  if (['PLD', 'RUN'].includes(S0.job)) {
    const held: LegacyAny = S0._curSet ? withWeapons(S0._curSet).pieces : {};
    // Crusade counted as the optimizer counts it (statBase: always up for a tank)
    const crusade = jaOn(buffState(), 'Crusade') ? 0 : CRUSADE_ENMITY;
    const b1 = Math.max(0, Math.min(100, enm + crusade)) / 2, b2 = Math.min(50, Object.values(held).reduce((n: number, p: LegacyAny) => n + (p && ENMITY_LOSS_GEAR[p.name] || 0), 0));
    const all = Math.round((1 - (1 - b1 / 100) * (1 - b2 / 100)) * 1000) / 10;
    if (all) rows.push(row(t('tkLoss'), `−${all} %`, `${b1} % × ${b2} %`, '', t('tkLossTip')));
  }
  return rows;
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
  items.push(...tankExtra(c, set, B, enm));
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

/** The "In combat" box of a nuke set (fight_stats.js fightFigures): the spell's damage in its band, the totals it is
 * worked out with (magic accuracy and hit rate first, the burst's bonus as the engine counts it), each line's tooltip
 * where its value comes from; open until the player folds it. Null for a set that is no nuke set */
function fightBox(s: LegacyAny): StatBox | null {
  if (!isNukeSet(s.path) || !engineReady()) return null;
  const f = fightFigures(s), ctx = f && f.ctx, r = f && f.r;
  const S0 = st();
  if (!('fight' in S0.boxOpen)) S0.boxOpen.fight = true;
  // a case our engine does not compute says why (fight_stats.js notComputedText)
  if (f && f.why) return {...box('fight', 'g-mag', esc(t('fightTab')), [], '', `<p class="note-m">${esc(notComputedText(f.why))}</p>`), bare: true};
  if (!r || !r.sheet) return null;
  const sheet = r.sheet, enemy = (ctx.enemy && ctx.enemy.stats) || {}, spells = ctx.spells && ctx.spells.length ? ctx.spells : ['Thunder'], gear = setStats(s).total;
  const sit = nukeSituation(s), layers = sit.layers.some((L: LegacyAny) => !L.spells) || !!sit.belt ? t('fightLayers') : '';
  const fmt = (v: number, pct?: boolean) => Math.round(v * 10) / 10 + (pct ? ' %' : '');
  const rows: BoxItem[] = FIGHT_LINES.filter((x: LegacyAny) => sheet[x.sheet]).map((x: LegacyAny) => {
    const v = sheet[x.sheet], g = x.key ? (gear[x.key] || {}).v || 0 : null, cap = x.cap ? x.cap() : null;
    const tip = (g != null ? t('fightFrom', {g: fmt(g, x.pct), r: fmt(v - g, x.pct), l: layers}) : '') + (cap != null && v > cap ? ' ' + t('fightMbdCap', {v: fmt(v), c: cap}) : '');
    return row(esc(t(x.label)), fmt(cap != null ? Math.min(v, cap) : v, x.pct), cap != null && v >= cap ? `<em class="capmax">${t('capMax')}</em>` : '', '', tip);
  });
  // the burst's bonus as calc_magic.js burstBonusTerm counts it: the first capped, the second and the job's trait on top
  const mb = {a: sheet['Magic Burst Damage'] || 0, b: sheet['Magic Burst Damage II'] || 0, t: sheet['Magic Burst Damage Trait'] || 0, c: CALC.BURST_GEAR_CAP};
  if (mb.a || mb.b || mb.t) rows.splice(4, 0, row(esc(t('fightMbdAll')), '+' + fmt(Math.min(mb.a, mb.c) + mb.b + mb.t, true), '', '', t('fightMbdAllFrom', mb)));
  rows.unshift(row(esc(t('fightMacc')), fmt(r.macc), '', '', fightMaccTip(sheet, enemy, spells[0], isBurstSet(s.path), r.macc)),
    row(esc(t('fightHit')), fmt(100 * r.hitRate, true), '', '', t('fightHitCap', {e: enemy['Magic Evasion'] || 0})));
  return box('fight', 'g-mag', esc(t('fightTab')), rows, fmtDmg(r.damage), `<p class="note-m">${esc(t('fightHead', {sp: spells.join(', '), foe: f.input.enemy || ''}))}</p>`);
}

export interface HpCycleView { open: boolean; title: string; foldTitle: string; note: string; ref: string; heads: string[];
  rows: Array<{mine: boolean; names: string; label: string; a: string; b: string; cls: string; loss: string}> }

/** A tank's HP cycle (PLD, RUN: the Guide_Paladin's HP management): every action's sets, idle -> precast -> midcast ->
 * idle, what each takes off the max HP, worst first; the line of the set shown marked; open until folded (it is what a
 * tank checks on every set). Null for another job, or before the engine */
function hpCycle(s: LegacyAny): HpCycleView | null {
  const F = (window as LegacyAny).FFXI;
  if (!['PLD', 'RUN'].includes(S.job as string) || !engineReady() || !F.opt.statFigures) return null;
  // the idle the cycle starts from: the set shown when it is one (idle.PDT, idle.MDT...), else sets.idle
  const S0 = st(), idle = family(s.path, s.pieces) === 'idle' ? s : (S0._bypath || {})['sets.idle'];
  if (!idle) return null;
  const r = charStats(idle, {}), naked = r ? r.cur.hp : 0, hp = (x: LegacyAny) => x ? setMaxHp(x, naked) : null, top = hp(idle) as number, ref = hpRef(idle);
  const rows = hpCycleRows().map((x: LegacyAny) => {
    const a = hp(x.pre), b = hp(x.mid), low = Math.min(top, a == null ? top : a, b == null ? top : b);
    return Object.assign(x, {a, b, loss: top - low});
  }).sort((x: LegacyAny, y: LegacyAny) => y.loss - x.loss || x.names[0].localeCompare(y.names[0]));
  const mine = (x: LegacyAny) => [x.pre, x.mid].some(z => z && (z.path === s.path || (z.aliases || []).includes(s.path))) || x.names.some((n: string) => s.path.endsWith('.' + n) || s.path.endsWith(`["${n}"]`));
  const cls = (x: LegacyAny) => x.self ? '' : x.loss > HP_SPREAD ? 'short' : x.loss > 0 ? 'warn' : 'better';
  const names = (x: LegacyAny) => (x.ja ? t('cyJa') + ' · ' : '') + x.names.sort().join(', ');
  if (S0.boxOpen.hpcycle === undefined) S0.boxOpen.hpcycle = true;
  return {open: !!S0.boxOpen.hpcycle, title: t('cyTitle'), foldTitle: t('ttFold'), note: t('cyNote', {i: top, n: shortPath(idle.path)}),
    ref: ref ? t('statRefLine', {h: ref.hp, f: shortPath(ref.path), a: ref.hp, b: ref.hp + HP_SPREAD}) + (top > ref.hp + HP_SPREAD ? ' ' + t('cyIdleHigh', {n: top - ref.hp}) : '') : '',
    heads: [t('cyAct'), t('cyPre'), t('cyMid'), t('cyLoss')],
    rows: rows.map((x: LegacyAny) => { const n = names(x); return {mine: mine(x), names: x.names.join(', '), label: n.length > 24 ? n.slice(0, 23) + '…' : n,
      a: String(x.a ?? '—'), b: String(x.b ?? '—'), cls: cls(x), loss: x.self ? t('cyOnPurpose') : x.loss ? '−' + x.loss : '0'}; })};
}

export interface LuopanView { title: string; rows: StatRow[]; cast: string;
  life: null | {note: string; heads: string[]; rows: Array<{label: string; loss: string; ticks: string; good: boolean; time: string}>}; notes: string[] }

/** A GEO's Luopan (luopan.js): on the cast set what the cast takes (Geomancy, the luopan's HP, Concentric Pulse's
 * charm); on a set worn with the luopan out (one that holds damage taken or Regen for it, or is named for it), its
 * damage taken, Regen and HP, how long it lives in each case, where its HP come from. Null on any other set */
function luopanOf(s: LegacyAny): LuopanView | null {
  if (S.job !== 'GEO' || !s) return null;
  if (isLuopanCast(s)) {
    const g = luopanGear(withWeapons(s).pieces), n = luopanCharm(g.duration);
    const rows = [row(t('luGeo'), `+${g.geo}`, esc(g.geo ? t('luGeoFrom', {p: g.geoFrom}) : t('luGeoNone')), '', t('luGeoTip')),
      row(t('luHp'), luNumber(LUOPAN.hp + g.hp), g.hp ? esc(t('luHpGear', {n: g.hp})) : '')].concat(g.duration ? [row(t('luCharm'), `−${n}`, '', '', t('luCharmTip', {p: g.duration, n}))] : []);
    return {title: t('luCastTitle'), rows, cast: t('luCastOnly'), life: null, notes: []};
  }
  const pieces = withWeapons(s).pieces, worn = luopanGear(pieces), fam = family(s.path, s.pieces);
  // a file with no set named for the luopan: its idle and engaged sets that hold something for it
  const named = (((data() as LegacyAny) || {}).sets || []).some((x: LegacyAny) => !x.empty && isLuopanWorn(x));
  if (!(named ? isLuopanWorn(s) : (worn.dt || worn.regen) && ['idle', 'engaged'].includes(fam))) return null;
  const cast = luopanCastSet(), f = luopanFigures(pieces, cast ? withWeapons(cast).pieces : null), g = f.g;
  const gearDt = -g.dt, miss = Math.round((f.useful - gearDt) * 10) / 10, n = luopanCharm(g.duration);
  const dtNote = miss > 0 ? t('luDtShort', {n: miss}) : miss < 0 ? t('luDtOver', {n: -miss}) : '';
  const rows = [row(t('luDt'), `${signed(f.total)} %`, `${esc(t('luDtGear', {g: gearDt, n: f.useful}))}${dtNote ? ' · ' + esc(dtNote) : ''}`, miss > 0 ? 'short' : '', t('luDtTip')),
    row(t('luRegen'), signed(g.regen), '', '', t('luRegenTip')), row(t('luHp'), luNumber(f.hp), g.hp ? esc(t('luHpGear', {n: g.hp})) : '')];
  if (g.duration) rows.push(row(t('luCharm'), `−${n}`, '', '', t('luCharmTip', {p: g.duration, n})));
  return {title: t('luTitle'), rows, cast: '', notes: (g.hp ? [t('luScaled', {n: g.hp, l: f.base})] : []).concat(cast ? t('luFrom', {s: shortPath(cast.path)}) : t('luFromNone')),
    life: {note: t('luLife'), heads: [t('luCase'), t('luLoss'), t('luTicks'), t('luTime')], rows: f.rows.map(([k, r]: [string, LegacyAny]) => ({label: t(k),
      loss: r.heals ? t('luHeals') : String(r.net), ticks: r.ticks == null ? '—' : String(r.ticks), good: !!(r.heals || r.capped), time: r.heals || r.capped ? t('luCap') : luClock(r.secs)}))}};
}

/** A Cure set's healing (a Cure on the others, the Healing Magic set; not a self Cure's, the tank box has it): the HP
 *  a Cure IV heals and what it is worked out with (atelier/opt.js statFigures cureOther). Open unless closed */
function cureBox(s: LegacyAny): StatBox | null {
  if (family(s.path, s.pieces) !== 'midcast' || !/cur(e|a|aga)|healing magic/i.test([s.path, ...(s.aliases || [])].join(' ')) || /self/i.test(s.path)) return null;
  const f = statFigures(s);
  if (!f || f.cureOther == null) return null;
  const pct = (v: number, m: number) => `+${v} %`, of = (m: number) => t('cbOf', {m});
  const lost = (raw: number, cap: number) => raw > cap ? t('cbLost', {n: raw - cap}) : of(cap);
  const items: BoxItem[] = [
    row(t('cbHeal'), `<b>${f.cureOther}</b>`, t('cbHealX')),
    row(t('cbCp'), pct(Math.min(50, f.cureRaw), 50), lost(f.cureRaw, 50), f.cureRaw > 50 ? 'over' : ''),
    row(t('cbCp2'), pct(f.cure2, 30), [lost(f.cure2Raw, 30), ...Object.entries(f.setBonuses || {}).map(([sn, x]: [string, LegacyAny]) => t('cbSet', {s: sn, n: x.count, b: x.bonus}))].join(' · '), f.cure2Raw > 30 ? 'over' : ''),
    row(t('cbPower'), String(f.curePower), t('cbPowerX', {m: f.cureMnd, v: f.cureVit, s: f.cureSkill})),
    row(t('cbEnm'), String(f.enmity)),
    row(t('cbCmp'), `+${f.cmp || 0} %`, t('cbCmpX', {g: f.cmpGear || 0, t: (f.cmp || 0) - (f.cmpGear || 0)}) + (f.cmp >= 100 ? ' · ' + t('cbCmpCap') : ''))];
  // open until closed: its fold key notes the closing (events.js flips S.boxOpen[key], unset at first)
  const b = box('cureShut', 'g-skill', t('cbTitle'), items, String(f.cureOther), `<p class="note-m">${esc(t('cbNote'))}</p>`);
  b.open = !st().boxOpen.cureShut;
  return b;
}

/** The column of figures of a set (setPanelHTML), with what it keeps in the page's state (S._curSet) */
export function figuresView(s: LegacyAny): FiguresView {
  const S0 = st();
  S0._curSet = s;
  const r = charStats(s), fam = family(s.path, s.pieces);
  // a nuke set: its damage and the totals it is worked out with (fight_stats.js), not the tanking figures
  const fight = fightBox(s);
  const off = !fight && r && (fam === 'ws' || fam === 'engaged') ? offenseBox(r, s) : null;
  const cure = cureBox(s), boxes = [...(cure ? [cure] : []), ...(fight ? [fight] : off ? [off] : r ? [tankBox(r)] : [])];
  // (in the old page's order: the set's own figures, every stat, then its HP cycle and Luopan, its sheet)
  const all = {open: !!S0._ui2AllOpen, title: t('ttAllStats'), label: t('ui2All'), globals: globalsView(s, 'stats')};
  const hp = hpCycle(s), luopan = luopanOf(s), sheet = sheetView(s);
  return {title: t('ui2SetTitle'), boxes, hp, luopan, sheet, all};
}
