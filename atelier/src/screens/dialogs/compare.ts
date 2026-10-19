// GearSwap Atelier · Compare: the set as your file has it, as the game wears it when the page saved pieces, the trial
// and each draft kept, side by side: the pieces that differ, then the figures the set is after (a weaponskill's
// damage, an engaged set's round, a stats set's figures, the damage taken against its caps, the stats it wants), the
// other stats folded.
// The rules are the old page's openCompare, engCmpRows (trial.js) and statCmpRows (stat_opt.js): the columns stay
// theirs (compareColumns). A field ending in Html is one of the old page's texts it wrote unescaped. The buttons keep
// the attributes the old handlers read (events.js data-keptload, data-keptdel, data-cmpmore).
//
// @file    atelier/src/screens/dialogs/compare.ts
// @author  ejouanchicot

export interface CmpCell { best: boolean; short: boolean; text: string; over: string; dv: null | {up: boolean; text: string}; small: string }
export interface CmpRow { cls: string; labelHtml: string; title: string | undefined; cells: CmpCell[] }
export interface CmpPiece { name: string; rank: number | null; max: boolean; augs: string }
export interface CompareView {
  whyHtml: string;
  sameHtml: string | null;
  two: boolean;
  head: Array<{label: string; kept: number | null}>;
  keptLoadHtml: string;
  keptDel: string;
  pieces: null | {titleHtml: string; rows: Array<{slotHtml: string; cells: Array<{chg: boolean; piece: CmpPiece | null}>}>};
  figures: null | {titleHtml: string; want: CmpRow[]; more: null | {open: boolean; labelHtml: string; count: number; colspan: number; rows: CmpRow[]}};
}

const st = (): LegacyAny => S;
const r1 = (n: number) => Math.round(n * 10) / 10;
const cell = (best: boolean, text: string, dv: CmpCell['dv'] = null, extra: Partial<CmpCell> = {}): CmpCell => ({best, short: false, text, over: '', dv, small: '', ...extra});

// an engaged set's round per column: real time, the engine's average, rounds, DPS, TP a round, the swings and hits
// landed, the best in bold and each column's gap to the first (engCmpRows)
function engRows(s: LegacyAny, cols: LegacyAny[]): CmpRow[] {
  if (family(s.path, s.pieces) !== 'engaged') return [];
  const rr = cols.map(c => withTrialAs(s, c.tr, () => engRound(s)));
  if (!rr.some(Boolean)) return [];
  const row = (label: string, get: (r: LegacyAny) => number | null, fmt: (v: number) => string, low: boolean): CmpRow => {
    const v = rr.map(r => r ? get(r) : null), ok = v.filter((x): x is number => x != null), best = low ? Math.min(...ok) : Math.max(...ok);
    return {cls: 'want', labelHtml: esc(label), title: undefined, cells: v.map((x, i) => { const dv = x != null && v[0] ? (x / v[0] - 1) * 100 : 0;
      return cell(x === best && ok.some(y => y !== x), x == null ? '—' : fmt(x), i && Math.abs(dv) > .05 ? {up: (low ? -dv : dv) > 0, text: `${dv > 0 ? '+' : ''}${dv.toFixed(1)} %`} : null); })};
  };
  const at = (st().optOpts || {}).engAt || 1000, sec = (x: number) => x.toFixed(2) + ' s';
  return [row(t('cmpEngReal', {at}), r => r.real ? r.real.time : r.time, sec, true), row(t('cmpEngAvg'), r => r.time, sec, true),
    row(t('rdvRounds'), r => r.real ? r.real.rounds : null, x => x.toFixed(2), true), row('DPS', r => r.dps, fmtDmg, false), row(t('cmpEngTp'), r => r.tp, x => String(Math.round(x)), false),
    row(t('rdvAttacks'), r => r.attacks ? r.attacks.swings : null, x => x.toFixed(2), false), row(t('rdvLanded'), r => r.attacks ? r.attacks.hits : null, x => x.toFixed(2), false)];
}

// a stats set's figures per column, its objectives first, then the heal, the gap, each action's enmity (statCmpRows)
function statRowsOf(s: LegacyAny, cols: LegacyAny[]): CmpRow[] {
  if (!statSet(s) || !engineReady() || !FFXI.opt.statFigures) return [];
  const figs = cols.map(c => withTrialAs(s, c.tr, () => statFigures(s)));
  const rows = statRows(s).filter((r: LegacyAny, i: number) => i < 3 || ['gap', 'ref', 'cure4', 'phalanx'].includes(r.id) || r.id.startsWith('act:'));
  const seen = new Set<string>(), out: CmpRow[] = [];
  for (const r of rows.filter((r: LegacyAny) => !seen.has(r.id) && seen.add(r.id))) {
    const vals = figs.map(f => f ? r.get(f) : null);
    if (vals.every(v => v == null)) continue;
    const ok = vals.filter(v => v != null), best = r.low ? Math.min(...ok) : Math.max(...ok);
    out.push({cls: 'want', labelHtml: esc(r.label), title: r.tip || undefined, cells: vals.map((v, i) => { const dv = v != null && vals[0] != null ? v - vals[0] : 0, up = r.low ? dv < 0 : dv > 0;
      return cell(v === best && vals.some(x => x !== v), v == null ? '—' : r.fmt(v), i && dv ? {up, text: `${dv > 0 ? '+' : '−'}${Math.round(Math.abs(dv) * 10) / 10}`} : null,
        {short: !!(r.floor && v != null && !r.floor(v))}); })});
  }
  return out;
}

/** Compare for a set (openCompare) */
export function compareView(s: LegacyAny): CompareView {
  const S0 = st();
  // SIRD counted with the merits, as under the set (sets_view.js sirdMeritsOf): the cap reads 102 % all in
  const sirdM = sirdMeritsOf(measuredChar());
  const cols: LegacyAny[] = compareColumns(s), ref = cols[0];
  const num = (c: LegacyAny, k: string) => ((c.stats[k] || {}).v || 0) + (baseKey(k) === 'sird' && c.stats[k] ? sirdM : 0);
  const slots = SLOTS.filter((slot: string) => cols.some(c => !samePiece(c.pieces[slot], ref.pieces[slot])));
  // the stats the set is after first (always shown, by weight), then the others that differ
  const {want} = setWants(s), all = [...new Set(cols.flatMap(c => Object.keys(c.stats)))] as string[];
  const stats0 = Object.assign({}, ...cols.map(c => c.stats)), sorter = S0.statSort === 'name' ? statSorter(s, stats0) : null;
  // damage taken goes on two lines of its own (physical, magic), each part shown
  const isDt = (k: string) => DT_KEYS.includes(baseKey(k));
  const wanted = all.filter(k => !isDt(k) && wantOf(want, k) >= 0.3 && statVisible(k, s)).sort(sorter || ((a: string, b: string) => wantOf(want, b) - wantOf(want, a) || statOrder(a, b)));
  const keys = all.filter(k => !isDt(k) && !wanted.includes(k) && statVisible(k, s) && cols.some(c => num(c, k) !== num(ref, k))).sort(sorter || statOrder);
  const head = cols.map(c => ({label: c.label as string, kept: c.kept != null ? c.kept as number : null}));
  const pieceOf = (p: LegacyAny): CmpPiece | null => p ? {name: p.name, rank: p.rank != null ? p.rank : null, max: !!p.capeMax, augs: p.augs && p.augs.length ? p.augs.join(' · ') : ''} : null;
  const pieceRows = slots.map((slot: string) => ({slotHtml: (SLOT_NAMES[S0.lang] || {})[slot] || slot,
    cells: cols.map((c, i) => ({chg: !!i && !samePiece(c.pieces[slot], ref.pieces[slot]), piece: pieceOf(c.pieces[slot])}))}));
  const rowsOf = (list: string[], cls: string): CmpRow[] => list.map(k => { const e = (cols.find(c => c.stats[k]) || ref).stats[k];
    // the better column for that stat in bold (less is better for damage taken)
    const vals = cols.map(c => num(c, k)), better = GOOD_DOWN.has(baseKey(k)) ? Math.min(...vals) : Math.max(...vals);
    return {cls, labelHtml: esc(statLabel(k, e)), title: undefined, cells: vals.map((v, i) => { const dv = v - vals[0]!;
      return cell(v === better && vals.some(x => x !== v), fmtStat({v, unit: e.unit}), i && dv ? {up: (GOOD_DOWN.has(baseKey(k)) ? -dv : dv) > 0, text: fmtStat({v: dv, unit: e.unit})} : null); })}; });
  // DT + PDT and DT + MDT (Shell included, as under the set): the total against the -50 % cap, then each part; the
  // first layer stops at -50 %, the II stat adds past it, -87.5 % in all
  const B = buffTotals(), shell = B.shell ? Math.round(-B.shell / 256 * 1000) / 10 : 0;
  const dtRow = (label: string, part: string, extra: (c: LegacyAny) => Array<[string, number]>): CmpRow[] => {
    const parts = cols.map(c => { const v = (k: string) => num(c, k), list = ([['DT', v('dt')], [part.toUpperCase(), v(part)]] as Array<[string, number]>).concat(extra(c)).filter(x => x[1]);
      const two = list.filter(x => / II$/.test(x[0])).reduce((a, x) => a + x[1], 0);
      return {sum: list.reduce((a, x) => a + x[1], 0) - two, two, list}; });
    if (!parts.some(x => x.sum || x.two) || !statVisible('dt', s)) return [];
    const eff = (x: {sum: number; two: number}) => Math.max(Math.max(x.sum, -50) + x.two, -87.5), best = Math.min(...parts.map(eff));
    // with a II stat the line is the total: named as the set's stats name it (sets/statlines.ts layeredLine)
    if (parts.some(x => x.two)) label = part === 'pdt' ? t('pdtTotal') : t('mdtTotal');
    return [{cls: 'want', labelHtml: esc(label), title: undefined, cells: parts.map((x, i) => { const dv = eff(x) - eff(parts[0]!);
      return cell(eff(x) === best && parts.some(y => eff(y) !== eff(x)), `${signed(r1(eff(x)))} %`, i && dv ? {up: dv < 0, text: `${signed(r1(dv))} %`} : null,
        {over: x.sum < -50 ? t('cmpOver', {n: r1(-50 - x.sum)}) : '', small: x.list.map(([n, v]) => `${n} ${signed(r1(v))}`).join(' · ')}); })}];
  };
  // what multiplies the damage taken past the cap (Fan Dance, Rampart: sets/statlines.ts mulLine), each column with its own hands
  const mulRow = (label: string, part: string, mkeys: string[], extra: (c: LegacyAny) => Array<[string, number]>): CmpRow[] => {
    const by = (B._by || []).filter((e: LegacyAny) => mkeys.includes(e.k) && e.v !== 1);
    if (!by.length || !statVisible('dt', s)) return [];
    const mulOf = (e: LegacyAny, c: LegacyAny) => e.src === 'Fan Dance' ? 1 - danceFloor('fan', c.pieces) / 100 : e.v;
    const tot = cols.map(c => { const v = (k: string) => num(c, k), two = extra(c).filter(x => / II$/.test(x[0])).reduce((a, x) => a + x[1], 0);
      const gear = Math.max(Math.max(v('dt') + v(part) + extra(c).filter(x => !/ II$/.test(x[0])).reduce((a, x) => a + x[1], 0), -50) + two, -87.5);
      return {gear, all: (by.reduce((m: number, e: LegacyAny) => m * mulOf(e, c), 1 + gear / 100) - 1) * 100, how: by.map((e: LegacyAny) => `× ${e.src} ${signed(r1((mulOf(e, c) - 1) * 100))} %`).join(' ')}; });
    const best = Math.min(...tot.map(x => x.all));
    return [{cls: 'want', labelHtml: esc(label), title: undefined, cells: tot.map((x, i) => { const dv = x.all - tot[0]!.all;
      return cell(x.all === best && tot.some(y => y.all !== x.all), `${signed(r1(x.all))} %`, i && r1(dv) ? {up: dv < 0, text: `${signed(r1(dv))} %`} : null,
        {small: `${t('mulGear')} ${signed(r1(x.gear))} % ${x.how}`}); })}];
  };
  const pExtra = (c: LegacyAny): Array<[string, number]> => [['PDT II', num(c, 'pdt2')]], mExtra = (c: LegacyAny): Array<[string, number]> => [['MDT II', num(c, 'mdt2')], ['Shell', shell]];
  const dtRows = dtRow(t('pdtEff'), 'pdt', pExtra).concat(mulRow(t('pdtWithMul'), 'pdt', ['dmgmul', 'pdmgmul'], pExtra),
    dtRow(shell ? t('mdtShell') : t('mdtEff'), 'mdt', mExtra), mulRow(t('mdtWithMul'), 'mdt', ['dmgmul'], mExtra));
  // the weaponskill's average damage per column (the engine)
  const dmg = cols.map(c => withTrialAs(s, c.tr, () => wsDamage(s)));
  const dmgRows: CmpRow[] = dmg.some(v => v != null) ? [{cls: 'want dmgrow', labelHtml: t('cmpDmg', {tp: S0.wsTp || 3000}), title: undefined, cells: dmg.map((v, i) => {
    const dv = v != null && dmg[0] != null ? (v / dmg[0] - 1) * 100 : 0, best = Math.max(...dmg.filter(x => x != null));
    return cell(v === best && dmg.some(x => x !== v), v == null ? '—' : fmtDmg(v), i && dv ? {up: dv > 0, text: `${dv > 0 ? '+' : ''}${dv.toFixed(1)} %`} : null); })}] : [];
  // what the set is after: the stats that differ shown, the ones every column has alike folded with the rest
  const differs = (k: string) => cols.some(c => num(c, k) !== num(ref, k)), wantedDiff = wanted.filter(differs), wantedSame = wanted.filter(k => !differs(k));
  const wantRows = dmgRows.concat(engRows(s, cols), statRowsOf(s, cols), dtRows, rowsOf(wantedDiff, 'want')), statRowsAll = rowsOf(wantedSame, '').concat(rowsOf(keys, ''));
  const pieces = pieceRows.length ? {titleHtml: t('cmpPieces'), rows: pieceRows} : null;
  const figures = wantRows.length || statRowsAll.length ? {titleHtml: t('cmpWanted'), want: wantRows,
    more: statRowsAll.length ? {open: !!S0._cmpMore, labelHtml: `${S0._cmpMore ? '▾' : '▸'} ${t('cmpStats')} · ${wantedSame.length + keys.length}`, count: wantedSame.length + keys.length,
      colspan: cols.length + 1, rows: statRowsAll} : null} : null;
  const any = slots.length || keys.length || wanted.length;
  return {whyHtml: t('cmpWhy'), sameHtml: any ? null : t('cmpSame'), two: cols.length <= 3 && !!pieces && !!figures, head, keptLoadHtml: t('keptLoad'), keptDel: t('keptDel'),
    pieces: any ? pieces : null, figures: any ? figures : null};
}
