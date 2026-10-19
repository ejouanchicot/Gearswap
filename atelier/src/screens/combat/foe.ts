// GearSwap Atelier · what lowers the target (Buffs & target, "Other debuffs"): the usual ones always in view (Dia,
// Distract with Saboteur, Light Shot), the other jobs one tab each (lit when something of it is on, its switch on the
// right); a tab is a grid of its abilities, each with what it takes off; then every debuff on the target, whatever its
// tab, and the total in the band.
// The rules are the old page's foePanelHTML (buff_panels.js). The buttons keep the attributes the old handlers read
// (data-foetab, data-foeseg, data-foeja, data-buffflag, data-buff, the tab's switch data-poff).
//
// @file    atelier/src/screens/combat/foe.ts
// @author  ejouanchicot

export interface FoeChip { k: 'chip'; attrs: Record<string, string>; label: string; on: boolean; tip: string; off: boolean; over: boolean }
export type FoeCtl = FoeChip | {k: 'seg'; chips: FoeChip[]} | {k: 'select'; attrs: Record<string, string>; title: string; options: Array<{value: string; label: string; selected: boolean}>} | {k: 'note'; text: string};
export interface FoeCell { label: string; ctls: FoeCtl[]; fx: string[] | null; wide: string }
export interface FoeView {
  tabs: Array<{id: string; label: string; lit: boolean; selected: boolean; title: string}>; sw: {key: string; on: boolean; tip: string; aria: string}; curOn: boolean; cells: FoeCell[];
  onTitle: string; on: Array<{src: string; fx: string}>; none: string; total: string; down: boolean;
}
type Line = [string, FoeCtl[], string[] | null, string?];

const JA_TIP: Record<string, string> = {'Lunar Cry': 'lunarTip', 'Banish II': 'banishTip', 'Dark Shot': 'darkShotTip'};
const FLOW_TABS = ['BLU', 'BST', 'WS'];
const ON_KEYS = ['edefp', 'eeva', 'emdb', 'emeva', 'eres', 'estatp', 'ecrit', 'eatkp', 'egambit', 'eresu', 'eallstat', 'eslow', 'edot', 'estr', 'edex', 'evit', 'eagi', 'eint', 'emnd', 'echr'];

const chip = (attrs: Record<string, string>, label: string, on: unknown, tip = '', off = false, over = false): FoeChip => ({k: 'chip', attrs, label, on: !!on, tip, off, over});

/** What lowers the target, for the buffs and target chosen (b) */
export function foeView(b: LegacyAny): FoeView {
  const FJ = FOE_JA as LegacyAny;
  const key = enemyKey(b.enemy), T = targetInfo(null);
  const short = (k: string, v: LegacyAny) => foeText(k, v, b) ?? fxText(k, v);
  const seg = (k: string, tiers: Record<string, LegacyAny>, full = false): FoeCtl => ({k: 'seg', chips: Object.keys(tiers).map(v =>
    chip({'data-foeseg': k, 'data-v': v}, full ? v : v.replace(/^(Dia|Distract)\s?/, '') || 'I', b[k] === v))});
  const ja = (n: string, over = false) => chip({'data-foeja': n}, FJ.BST[n] ? n.split(': ')[1]! : n, (b.foeJa || []).includes(n),
    [JA_TIP[n] ? t(JA_TIP[n]) : FJ.COR[n] && FJ.COR[n].shot ? t('shotTip', {d: FJ.COR[n].shot}) : FJ.BST[n] ? n : '', over ? t('ddOver') : ''].filter(Boolean).join(' · '), false, over);
  const by = (src: (s: string) => boolean): string[] => T.B._by.filter((e: LegacyAny) => src(e.src)).map((e: LegacyAny) => short(e.k, e.v));
  // Saboteur's multiplier on this target, on its own button (x2 a monster, x1.25 an NM, more with the gloves)
  const nm = isNmTarget(key), sabX = nm ? (b.sabGloves ? 1.39 : 1.25) : (b.sabGloves ? 2.14 : 2);
  const geoSrc = (v: string) => GEO_DEBUFFS[v.replace(/^(Entrust )?(Indi|Geo)-/, '')];
  const nmGeo = (x: string) => geoKeep(key) < 1 ? `${x} (NM −${Math.round((1 - geoKeep(key)) * 100)} %)` : x;
  // a Magic Evasion down: a grey note (the targets' Magic Evasion is not known, so it changes no damage)
  const note = (label: string, k: string, v: LegacyAny = {}): Line => [label, [{k: 'note', text: `${t(k, v)} · ${t('infoNotCounted')}`}], null, 'wide'];
  // BLM: Bio, Bio II (Bio III is a RDM's: its tab) and Impact; the six elemental debuffs, Archmage's Sabots +3 under them
  const blmLines = (names: string[]): Line[] => { const el = names.filter(n => FOE_JA_FX[n].elem);
    return [['', [seg('dia', {'Bio': 1, 'Bio II': 1}, true)], by(v => v === 'Bio' || v === 'Bio II')], ['', [ja('Impact')], by(v => v === 'Impact')],
      ['', el.map(n => ja(n)), by(v => el.includes(v)), 'wide'],
      ['', [chip({'data-buffflag': 'sabots'}, 'Archmage’s Sabots +3', b.sabots, t('sabotsTip'))], b.sabots ? [t('sabotsOn')] : [], 'wide']]; };
  const runLines = (): Line[] => [[t('runesLbl'), [{k: 'select', attrs: {'data-buff': 'rune'}, title: '', options: Object.entries(RUNES).map(([r, el]) =>
      ({value: r, label: `${r} · ${t('el_' + el)}`, selected: r === runeOf(b)}))},
      {k: 'seg', chips: ['1', '2', '3'].map(n => chip({'data-foeseg': 'runes', 'data-v': n}, n, String(runeCount(b)) === n, t('runesTip')))}], null, 'wide'],
    ['', [ja('Gambit')], by(v => v === 'Gambit'), 'wide'],
    note('Rayke', 'raykeInfo', {e: t('el_' + RUNES[runeOf(b)]), n: runeCount(b)})];
  // many abilities: their buttons in one block (a weaker one struck through), what they take off in the list under
  const flowLines = (names: string[], off: string[]): Line[] => [['', names.map(n => ja(n, off.includes(n))), null, 'wide flow']];
  const brdLines = (): Line[] => [note('Threnody II', 'threnNote'),
    ['', [ja('Carnage Elegy')], by(v => v === 'Carnage Elegy')], ['', [ja('Foe Requiem VII')], by(v => v === 'Foe Requiem VII')]];
  const evdOver = DISTRACT[b.distract] && !foeCounted(b).distractWins ? [t('ddOver')] : [];
  const has = (n: string) => (b.foeJa || []).includes(n);
  // a tab a job, each with its switch (id: the key b.off keeps), its lines [label, controls, what they take off, wide]
  const tabs: Array<{id: string; label: string; on: boolean; lines: Line[]}> = [
    {id: 'Dia', label: 'WHM', on: (!!DIA[b.dia] && b.dia !== 'Dia III') || has('Banish II'), lines: [['Dia', [seg('dia', {'Dia': 1, 'Dia II': 1})],
      b.dia === 'Dia III' ? [] : by(v => !!DIA[v]), 'wide'], ['', [ja('Banish II')], by(v => v === 'Banish II'), 'wide']]},
    {id: 'Distract', label: 'RDM', on: !!DISTRACT[b.distract] || DIA_OWNER[b.dia] === 'Distract',
      lines: [['Dia · Bio', [seg('dia', {'Dia III': 1, 'Bio III': 1}, true)], by(v => (v === 'Dia III' || v === 'Bio III')), 'wide'],
        ['Distract', [seg('distract', DISTRACT), chip({'data-buffflag': 'saboteur'}, b.saboteur ? `Saboteur ×${sabX}` : 'Saboteur', b.saboteur, `${t('sabTip')} · ${nm ? 'NM' : t('sabMobShort')} ×${sabX}`),
          chip({'data-buffflag': 'sabGloves'}, 'Lethargy +3', b.sabGloves, 'Lethargy Gantherots +3', !b.saboteur)], by(v => /^Distract/.test(v)).concat(evdOver), 'wide'],
        note('Frazzle III', 'frazzleNote')]},
    {id: 'Light Shot', label: 'COR', on: !!(b.lightshot && DIA[b.dia]) || Object.keys(FJ.COR).some(has),
      lines: [['', [chip({'data-buffflag': 'lightshot'}, 'Light Shot', b.lightshot, t('lsTip'), !DIA[b.dia])], by(v => v === 'Light Shot')],
        ['', [ja('Dark Shot')], by(v => v === 'Dark Shot')],
        ['', [...Object.keys(FJ.COR).filter(n => FJ.COR[n].shot).map(n => ja(n)),
          {k: 'seg', chips: ['1', '2'].map(v => chip({'data-foeseg': 'corShots', 'data-v': v}, t('corShotN', {n: v}), (b.corShots || '2') === v, t('corShotsTip')))}], null, 'wide flow']]},
    ...(Object.entries(FJ) as Array<[string, LegacyAny]>).filter(([job]) => !['RDM', 'WHM', 'COR'].includes(job)).map(([job, list]) => {
      const names = Object.keys(list), off = names.filter(n => has(n) && !foeJaActive(b).includes(n));
      const own: Line[] = job === 'BLM' ? blmLines(names) : job === 'RUN' ? runLines() : job === 'BRD' ? brdLines() : FLOW_TABS.includes(job) ? flowLines(names, off)
        : names.filter(n => !FOE_JA_FX[n].smnImpact).map((n): Line => ['', [ja(n)], by(v => v === n).concat(off.includes(n) ? [t('ddOver')] : [])]);
      const smn: Line[] = job === 'SMN' ? [['', [ja('Impact (Fenrir)'), {k: 'select', attrs: {'data-buff': 'smnSkill'}, title: t('smnSkillTip'),
        options: SMN_SKILLS.map((v: number) => ({value: String(v), label: t('smnSkillOpt', {n: v}), selected: v === smnSkill(b)}))}], by(v => v === 'Impact (Fenrir)'), 'wide']] : [];
      const dnc: Line[] = job === 'DNC' ? [['', [chip({'data-buffflag': 'dncSub'}, t('dncSubLbl'), b.dncSub, t('dncSubTip'))], null], note('Stutter Step', 'stutterNote')] : [];
      // BRD's switch here is Threnody's own: the BRD one is Party support's songs
      return {id: FOE_SW[job] || job, label: job === 'WS' ? t('foeWsTab') : job, on: names.some(has) || DIA_OWNER[b.dia] === job,
        lines: own.concat(smn, dnc, job === 'NIN' ? [note('Ninjutsu', 'ninNote')] : [])};
    }),
  ];
  const offOf = b.off || {}, cur = tabs.find(x => x.id === (S as LegacyAny)._foeTab) || tabs.find(x => x.on) || tabs[0]!, curOn = !offOf[cur.id];
  // everything on the target, whatever its tab: what lays it, what it takes off; a line a debuff, its effects together
  const bySrc = new Map<string, string[]>();
  for (const e of T.B._by.filter((e: LegacyAny) => ON_KEYS.includes(e.k))) bySrc.set(e.src, (bySrc.get(e.src) || []).concat(geoSrc(e.src) ? nmGeo(short(e.k, e.v)) : short(e.k, e.v)));
  const total = [T.defDown ? short('edefp', T.defDown) : '', T.B.eeva ? short('eeva', T.B.eeva) : ''].filter(Boolean).join(' · ');
  return {tabs: tabs.map(x => ({id: x.id, label: x.label, lit: x.on && !offOf[x.id], selected: x === cur, title: t('ttFoeTab', {j: x.label})})), sw: {key: cur.id, on: curOn, tip: t('pOffTip'), aria: `${cur.id} ${curOn ? 'ON' : 'OFF'}`}, curOn,
    cells: cur.lines.map(([label, ctls, fx, wide]) => ({label, ctls, fx, wide: wide || ''})),
    onTitle: t('foeOnTitle'), on: [...bySrc].map(([src, fx]) => ({src, fx: fx.join(' · ')})), none: t('foeNoneOn'), total: total || t('foeNone'), down: !!total};
}
