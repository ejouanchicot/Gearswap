// GearSwap Atelier · the "+ Set" window as an assistant (add_wizard.js reads the export's catalog into situations):
// 1. when (tiles), 2. what (the subjects of that kind, spells by school), 3. only the questions whose answers change the
// set worn (on whom, which tier, which mode, which profile...), 4. a summary in words with the one name written in the
// file, or the set already there opened. "See every possible name" lists every situation for experts, one line each.
// SPEC: notes/docs-perso/creation-set-2026-11-01/SPEC.md. An export with no catalog keeps the kind's sets (and the
// weaponskill list of push.js addWsList). The buttons carry the attributes events.js reads (data-awfam, data-awsubj,
// data-awans, data-awnext, data-awexpert, data-awpick, data-awfrom, data-addopen, data-back, data-close).
//
// @file    atelier/src/screens/dialogs/addset.ts
// @author  ejouanchicot

export interface AwChip { key: string; label: string; tiers: string; tierList: string[]; has: boolean; q: string; all: boolean; fam: boolean; color?: string; where?: string }
export interface AwTab { key: string; label: string; color: string; count: string; on: boolean }
export interface AwOpt { value: string; label: string; desc: string; rec: boolean; on: boolean }
export interface AwRow { q: string; say: string; path: string; there: boolean; others: string[]; why: string }
export type AddBody =
  | {kind: 'fams'; ask: string; warn: string; fams: Array<{f: string; icon: string; label: string; when: string}>}
  | {kind: 'subjects'; ask: string; ph: string; tabs: AwTab[]; color: string; all: AwChip | null; subs: AwTab[]; chips: AwChip[]; results: AwChip[] | null; none: string; expert: string; hasTip: string}
  | {kind: 'ask'; questions: Array<{k: string; label: string; opts: AwOpt[]}>; next: string}
  | {kind: 'sum'; say: string; has: null | {path: string; open: string; game: string}; today: string; todayLabel: string; startLabel: string;
      opts: Array<{k: string; a: string; b: string; rec: boolean}>; nameLabel: string; name: string; also: string; alsoList: string[]; file: string; block: string}
  | {kind: 'addw'; say: string; set: string; why: string; added: boolean; go: string; block: string}
  | {kind: 'expert'; ph: string; groups: Array<{label: string; rows: AwRow[]}>; create: string; open: string}
  | {kind: 'paths'; paths: string[]}
  | {kind: 'html'; html: string};
export interface AddSetView { title: string; steps: Array<{label: string; on: boolean; done: boolean}>; body: AddBody; first: boolean; back: string; cancel: string; exists: string; rec: string }

const FAM_ORDER = ['idle', 'engaged', 'fc', 'midcast', 'ws', 'ja', 'cure', 'enmity', 'pet', 'special', 'xp', 'weapons', 'other'];
// the page's icons (game-icons.net, game_icons.js, drawn by player_words.js playerIcon): one idea, one icon, as the
// Configuration screen's (atelier/src/screens/config/modules.ts)
const FAM_GI: Record<string, string> = {idle: 'meditation', engaged: 'crossed-swords', fc: 'hourglass', midcast: 'magic-swirl', ws: 'sword-brandish',
  ja: 'muscle-up', cure: 'heart-bottle', enmity: 'on-target', pet: 'two-shadows', special: 'sunbeams', xp: 'upgrade', weapons: 'gear-hammer', other: 'cog'};
const SPELL_FAMS = new Set(['midcast', 'fc', 'cure']);
// a school's colour, as the game's spell icons tint them (white magic light, black magic dark, the elements' red...)
const SCHOOL_COLOR: Record<string, string> = {'Enhancing Magic': '#6fd3a2', 'Enfeebling Magic': '#b48cff', 'Elemental Magic': '#ff8a65', 'Healing Magic': '#8fd0ff',
  'Divine Magic': '#ffe08a', 'Dark Magic': '#9a7bd8', Ninjutsu: '#7fb2c9', Singing: '#ff9fc9', 'Blue Magic': '#6aa8ff', Geomancy: '#d8b56a', 'Summoning Magic': '#c9e27a'};
// the series a school's spells come in, by name (BG Wiki's categories): shown apart under their name
const PACKS: Array<[string, RegExp]> = [['awPackBar', /^Bar/], ['awPackGain', /^(Gain|Boost)-/], ['awPackEn', /^En(fire|blizzard|aero|stone|thunder|water)/],
  ['awPackSpikes', / Spikes$/], ['awPackTele', /^(Teleport|Recall|Warp|Retrace|Escape)/], ['awPackStorm', /storm( II)?$/], ['awPackNa', /na$/]];
const A = (): LegacyAny => (S as LegacyAny)._aw;
const modeOf = (x: LegacyAny) => x.q.mode ? x.q.mode.state + '=' + x.q.mode.value : '';
const qv = (x: LegacyAny, k: string) => k === 'mode' ? modeOf(x) : (x.q[k] || '');

// a subject's name as the list shows it
function subjLabel(x: LegacyAny): string {
  const s = x.subject;
  if (s.kind === 'school') return t('awSchoolAll', {s: awSchoolName(s.name)});
  if (s.kind === 'family') return t('awFamily') + ' : ' + awFamName(s.name);
  if (s.kind === 'set') return s.name ? s.name : t('fam.' + x.fam) + ' · ' + t('awGeneral');
  return s.name;
}
// the group a subject sits in
function subjGroup(x: LegacyAny): string {
  const s = x.subject;
  if (s.kind === 'ws') return (wsSkills() as LegacyAny)[s.name] || t('awOtherWs');
  if (s.kind === 'ability' || x.fam === 'ja') return t('awAbilities');
  if (s.kind === 'set') return t('awSets');
  if (s.school) return awSchoolName(s.school);
  return s.kind === 'family' ? t('awFamilies') : t('awGeneral');
}
// the tiers a spell's situations name, in order (Haste · Haste II)
const ROMAN: Record<string, number> = {I: 1, II: 2, III: 3, IV: 4, V: 5, VI: 6};
const tierNo = (n: string) => { const m = / (II|III|IV|V|VI)$/.exec(n); return m ? ROMAN[m[1]!]! : 1; };
// (the catalog keeps one line a path: tier I shares its name with the all-tiers set, sets.midcast.Haste; a spell with
// other tiers has its tier I too)
const tiersOf = (list: LegacyAny[]) => [...new Set(list.map(x => x.tier || x.q.scope).filter(Boolean).concat(list[0] && list[0].subject.kind === 'spell' && list.some(x => x.tier || x.q.scope) ? [list[0].subject.name] : []))].sort((a: string, b: string) => tierNo(a) - tierNo(b) || a.localeCompare(b)) as string[];

/** A situation said in words: "Porté quand tu lances Haste ou Haste II sur un allié, avec Composure actif." */
export function awSay(x: LegacyAny, all: LegacyAny[]): string {
  const s = x.subject;
  // a weaponskill or an ability: its name, then what narrows it; a set of its own (idle, engaged...): its catalog line
  if (s.kind === 'ws' || s.kind === 'ability') return t('awSay', {w: [t('awSayUse', {s: s.name})].concat(extras(x)).join(', ')});
  if (!SPELL_FAMS.has(x.fam)) return catalogWhen(x.e.path) || x.e.fr || x.e.when || shortPath(x.e.path);
  const tiers = tiersOf(all.filter(y => y.fam === x.fam && y.subject.kind === s.kind && y.subject.name === s.name));
  const what = s.kind === 'school' ? t('awSchoolSay', {s: awSchoolName(s.name)}) : s.kind === 'family' ? t('awFamSay', {s: awFamName(s.name)})
    : s.kind === 'set' ? subjLabel(x) : x.q.scope ? x.q.scope : tiers.length === 2 ? t('awTiersOf', {a: tiers[0], b: tiers[1]}) : tiers.length > 2 ? t('awTiersRange', {a: tiers[0], b: tiers[tiers.length - 1]}) : s.name;
  const parts = [t(x.fam === 'fc' ? 'awSayFc' : 'awSaySpell', {s: what})];
  return t('awSay', {w: parts.concat(extras(x)).join(', ')});
}
// what narrows a situation, in words: on whom, a buff, a mode, a profile, a version
function extras(x: LegacyAny): string[] {
  const out: string[] = [];
  if (x.q.target === 'others') out.push(x.subject.name === 'Cure' ? t('awSayOthersCure') : t('awSayOthers'));
  if (x.q.target === 'self') out.push(t('awSaySelf'));
  if (x.q.buff) out.push(t('awSayBuff', {b: x.q.buff}));
  if (x.q.mode) out.push(t('awSayMode', {m: x.q.mode.state, v: x.q.mode.value}));
  if (x.q.profile) out.push(t('awSayProf', {p: x.q.profile}));
  if (x.q.variant) out.push('(' + x.q.variant + ')');
  return out;
}

// Step 1: the kinds
function famsBody(list: LegacyAny[] | null, cards: LegacyAny[]): AddBody {
  const fams: string[] = list ? [...new Set(list.map(x => x.fam as string))] : [...new Set(cards.map((c: LegacyAny) => c.fam as string))];
  fams.sort((a, b) => (FAM_ORDER.indexOf(a) + 1 || 99) - (FAM_ORDER.indexOf(b) + 1 || 99));
  return {kind: 'fams', ask: t('awWhenQ'), warn: list ? '' : t('addNoCatalog'), fams: fams.map(f => ({f, icon: playerIcon('gi:' + (FAM_GI[f] || 'cog')), label: t('fam.' + f), when: t('famWhen.' + f)}))};
}

// Step 2: the subjects of the kind, by group (a school for the spells)
function subjectsBody(list: LegacyAny[]): AddBody {
  const mine = list.filter(x => awInFam(x, A().fam)), by = new Map<string, LegacyAny[]>();
  for (const x of mine) { const k = awSubjKey(x.subject); if (!by.has(k)) by.set(k, []); by.get(k)!.push(x); }
  const groups = new Map<string, AwChip[]>(), colors = new Map<string, string>();
  const rank = (c: AwChip) => (c.all ? 0 : 1);
  for (const [key, xs] of by) {
    const x = xs[0], g = subjGroup(x), tiers = tiersOf(xs), label = subjLabel(x);
    const tierList = x.subject.kind === 'spell' && tiers.length > 1 ? tiers.map(n => n.slice(x.subject.name.length).trim() || 'I') : [];
    if (!colors.has(g)) colors.set(g, SCHOOL_COLOR[x.subject.school || x.subject.name] || '');
    const chip: AwChip = {key, label, tierList, tiers: tierList.join(' · '),
      has: xs.some(y => isThere(y.e)), q: (label + ' ' + tiers.join(' ') + ' ' + g).toLowerCase(), all: x.subject.kind === 'school', fam: x.subject.kind === 'family'};
    if (chip.fam) chip.label = awFamName(x.subject.name);
    if (!groups.has(g)) groups.set(g, []);
    groups.get(g)!.push(chip);
  }
  const sorted = (l: AwChip[]) => l.sort((a, b) => rank(a) - rank(b) || a.label.localeCompare(b.label));
  // the long series of a school apart, each under its name (30 Bar- spells hid the others)
  const packOf = (c: AwChip) => c.fam || c.all ? null : PACKS.find(p => p[1].test(c.label));
  const out = [...groups].map(([label, chips]) => {
    const packs = PACKS.map(p => ({label: t(p[0]), chips: sorted(chips.filter(c => packOf(c) === p))})).filter(p => p.chips.length > 1);
    const packed = new Set(packs.flatMap(p => p.chips));
    return {label, color: colors.get(label) || '', count: String(chips.filter(c => !c.fam && !c.all).length), chips: sorted(chips.filter(c => !c.fam && !packed.has(c))), packs, fams: sorted(chips.filter(c => c.fam))}; });
  out.sort((a, b) => (a.label === t('awSets') ? 1 : 0) - (b.label === t('awSets') ? 1 : 0) || b.chips.length - a.chips.length);
  // the weapons: a tab "Add a weapon", a sub-tab a cycle (add_wizard.js awWeaponChoices)
  if (A().fam === 'weapons') {
    const choices = awWeaponChoices(), modes = [...new Set(choices.map(c => c.desc))];
    if (choices.length) out.push({label: t('awAddW'), color: '', count: String(choices.length), chips: [],
      packs: modes.map(m => ({label: m, chips: choices.filter(c => c.desc === m).map(c => ({key: 'addw:' + c.mode + ':' + c.name, label: c.name, tierList: [], tiers: '',
        has: c.added, q: c.name.toLowerCase(), all: false, fam: false}))})), fams: []});
  }
  const st = A(), q = (st.q || '').trim().toLowerCase();
  // the search: every school at once, a name or one of its words starting with what is typed (Paralyze, not
  // Barparalyze); the names that start with it first
  if (q) {
    const hit = (c: AwChip) => { const l = c.label.toLowerCase(); return l.startsWith(q) || l.split(/[\s\-\/·()]+/).some(w => w.startsWith(q)); };
    const results = out.flatMap(g => [...g.chips, ...g.packs.flatMap(p => p.chips), ...g.fams].filter(c => !c.all && hit(c)).map(c => ({...c, color: g.color, where: g.label})))
      .sort((a, b) => Number(!a.label.toLowerCase().startsWith(q)) - Number(!b.label.toLowerCase().startsWith(q)) || a.label.localeCompare(b.label));
    return {kind: 'subjects', ask: t('awWhatQ'), ph: t('awSearch'), tabs: [], color: '', all: null, subs: [], chips: [], results, none: t('awNone'), expert: t('awExpert'), hasTip: t('awHas')};
  }
  // a tab a school (Sets last); in it a tab its spells, a tab each long series, a tab its families
  const cur = out.find(g => g.label === st.tab) || out[0]!;
  const all = cur.chips.find(c => c.all) || null, spells = cur.chips.filter(c => !c.all);
  const subsAll: Array<{key: string; label: string; chips: AwChip[]}> = [{key: 'spells', label: t(cur.label === t('awSets') ? 'awSets' : 'awSpells'), chips: spells},
    ...cur.packs.map(p => ({key: p.label, label: p.label, chips: p.chips})), ...(cur.fams.length ? [{key: 'fams', label: t('awFamilies'), chips: cur.fams}] : [])].filter(s => s.chips.length);
  const sub = subsAll.find(s => s.key === st.sub) || subsAll[0] || {key: '', label: '', chips: []};
  return {kind: 'subjects', ask: t('awWhatQ'), ph: t('awSearch'),
    tabs: out.map(g => ({key: g.label, label: g.label, color: g.color, count: String(g.chips.filter(c => !c.all).length + g.packs.reduce((n, p) => n + p.chips.length, 0)), on: g === cur})),
    color: cur.color, all, subs: subsAll.length > 1 ? subsAll.map(s => ({key: s.key, label: s.label, color: '', count: String(s.chips.length), on: s === sub})) : [],
    chips: sub.chips, results: null, none: t('awNone'), expert: t('awExpert'), hasTip: t('awHas')};
}

// the label and words of an answer
function optOf(k: string, v: string, xs: LegacyAny[]): {label: string; desc: string; rec: boolean} {
  const subj = xs[0] ? xs[0].subject : {name: ''};
  if (k === 'target') return v === 'others' ? (subj.name === 'Cure' ? {label: t('awOthersCure'), desc: t('awOthersCureD'), rec: false} : {label: t('awOthers') + ' · ' + t('awOthersComp'), desc: t('awOthersD'), rec: false})
    : v === '' && xs.some(x => x.q.target === 'self') ? {label: t('awAnyone'), desc: t('awAnyoneD'), rec: true} : {label: t('awSelf'), desc: t('awSelfD'), rec: false};
  if (k === 'scope') return v ? {label: t('awOnly', {s: v}), desc: t('awOnlyD'), rec: false} : {label: t('awAllTiers'), desc: t('awAllTiersD', {l: tiersOf(xs).join(', ')}), rec: true};
  if (k === 'mode') { const [m, val] = v.split('='); const st = (xs.find(x => x.q.mode) || {q: {mode: {state: m}}}).q.mode.state;
    return v ? {label: t('awInMode', {v: val}), desc: t('awInModeD', {m, v: val}), rec: false} : {label: t('awAnyMode'), desc: t('awAnyModeD', {m: st}), rec: true}; }
  if (k === 'profile') return v ? {label: t('awProf', {p: v}), desc: t('awProfD', {p: v}), rec: false} : {label: t('awFull'), desc: t('awFullD'), rec: true};
  if (k === 'buff') { const b = (xs.find(x => x.q.buff) || {q: {}}).q.buff || v; return v ? {label: t('awWith', {b}), desc: t('awWithD', {b}), rec: false} : {label: t('awWithout', {b}), desc: t('awWithoutD'), rec: true}; }
  // a version the catalog names by a key of its own: its line in words
  const one = xs.find(x => (x.q.variant || '') === v);
  return v ? {label: v, desc: one ? catalogWhen(one.e.path) || one.e.fr || '' : '', rec: false} : {label: t('awPlain'), desc: '', rec: true};
}
const QLABEL: Record<string, (xs: LegacyAny[]) => string> = {target: () => t('awQTarget'), scope: () => t('awQScope'), profile: () => t('awQProfile'), variant: () => t('awQVariant'),
  mode: xs => t('awQMode', {m: (xs.find(x => x.q.mode) || {q: {mode: {state: ''}}}).q.mode.state}), buff: xs => t('awQBuff', {b: (xs.find(x => x.q.buff) || {q: {}}).q.buff || ''})};

// Step 3: the questions, each one's answers among the situations the earlier answers leave (a gone answer reset)
function askBody(xs: LegacyAny[]): AddBody {
  const ans = A().ans, qs = awQuestions(xs), questions: Array<{k: string; label: string; opts: AwOpt[]}> = [];
  let left = xs;
  for (const q of qs) {
    const vals = [...new Set(left.map((x: LegacyAny) => qv(x, q.k)))].sort((a: string, b: string) => (a === '') === (b === '') ? a.localeCompare(b) : a === '' ? -1 : 1) as string[];
    if (!(q.k in ans) || !vals.includes(ans[q.k])) ans[q.k] = vals[0];
    if (vals.length > 1) questions.push({k: q.k, label: QLABEL[q.k]!(xs), opts: vals.map(v => ({value: v, ...optOf(q.k, v, xs), on: ans[q.k] === v}))});
    left = left.filter((x: LegacyAny) => qv(x, q.k) === ans[q.k]);
  }
  return {kind: 'ask', questions, next: t('awNext')};
}

// Step 4: what the answers lead to, in words; the set already there opened, else what it starts with
function sumBody(xs: LegacyAny[], all: LegacyAny[]): AddBody {
  const st = A(), pick = st.pick && xs.find((x: LegacyAny) => x.e.path === st.pick);
  askBody(xs);
  const match = pick ? xs.filter((x: LegacyAny) => ['target', 'buff', 'scope', 'mode', 'profile', 'variant'].every(k => qv(x, k) === qv(pick, k))) : awMatching(xs, st.ans);
  const list = match.length ? match : xs, x = pick || awPreferred(list), there = list.filter((y: LegacyAny) => isThere(y.e));
  st.path = x.e.path;
  const say = awSay(x, all), others = list.filter((y: LegacyAny) => y !== x).map((y: LegacyAny) => y.e.path);
  const comp = x.q.target === 'others' && x.e.base ? x.e.base + '.Composure' : null;
  const base = comp && setThere(comp) ? comp : x.e.base && setThere(x.e.base) ? x.e.base : null, live = liveWrite();
  st.base = base;
  const block = !live ? t('awNoWay') : !parentThere(x.e) ? t('awParent', {p: shortPath(parentOf(x.e.path) as string)}) : '';
  const opts: Array<{k: string; a: string; b: string; rec: boolean}> = [];
  if (base) opts.push({k: 'copy', a: t('awCopy'), b: t('awCopyD'), rec: true});
  opts.push({k: 'empty', a: t('awEmpty'), b: t('awEmptyD'), rec: !base}, {k: 'worn', a: t('awWorn'), b: t('awWornD'), rec: false});
  const subjName = subjLabel(x);
  return {kind: 'sum', say, has: there.length ? {path: there[0].e.path, open: t('awOpen'), game: t('awHasGame')} : null,
    todayLabel: t('awToday'), today: base ? cardName(base) : t('awTodayNone'), startLabel: t('awStart'), opts, nameLabel: t('awName'),
    name: there.length ? there[0].e.path : x.e.path, also: others.length ? t('awAlso', {n: others.length}) : '', alsoList: others,
    file: t('awFile', {s: subjName}), block};
}
// A set's name as a player reads it (its card's name, its version)
function cardName(path: string): string { return shortPath(path).replace(/\["([^"]+)"\]/g, '.$1').replace(/^midcast\./, '').replace(/^\./, '').split('.').join(' · '); }

// The experts' list: every situation of the kind, one line each (the one name first, the others folded)
function expertBody(list: LegacyAny[]): AddBody {
  const mine = list.filter(x => awInFam(x, A().fam)), bySubj = new Map<string, LegacyAny[]>();
  for (const x of mine) { const k = awSubjKey(x.subject); if (!bySubj.has(k)) bySubj.set(k, []); bySubj.get(k)!.push(x); }
  const groups = [...bySubj.values()].map(xs => {
    const bySit = new Map<string, LegacyAny[]>();
    for (const x of xs) { const k = ['target', 'buff', 'scope', 'mode', 'profile', 'variant'].map(q => qv(x, q)).join('|'); if (!bySit.has(k)) bySit.set(k, []); bySit.get(k)!.push(x); }
    const rows: AwRow[] = [...bySit.values()].map(sit => { const p = awPreferred(sit), say = awSay(p, list), there = sit.some((y: LegacyAny) => isThere(y.e));
      return {q: (say + ' ' + sit.map((y: LegacyAny) => y.e.path).join(' ')).toLowerCase(), say, path: there ? sit.find((y: LegacyAny) => isThere(y.e)).e.path : p.e.path, there,
        others: sit.filter((y: LegacyAny) => y !== p).map((y: LegacyAny) => y.e.path), why: there || liveWrite() ? '' : t('awNoWay')}; });
    rows.sort((a, b) => Number(b.there) - Number(a.there) || a.say.localeCompare(b.say));
    return {label: xs[0].subject.kind === 'school' ? subjLabel(xs[0]) : subjGroup(xs[0]) + ' · ' + subjLabel(xs[0]), rows};
  });
  groups.sort((a, b) => b.rows.filter(r => r.there).length - a.rows.filter(r => r.there).length || a.label.localeCompare(b.label));
  return {kind: 'expert', ph: t('awSearch'), groups, create: t('awCreate'), open: t('awExists')};
}

// An export with no catalog: the kind's sets there (the weaponskills: push.js addWsList)
function oldBody(cards: LegacyAny[]): AddBody {
  if (A().fam === 'ws') return {kind: 'html', html: addWsList(cards)};
  return {kind: 'paths', paths: cards.filter((c: LegacyAny) => c.fam === A().fam).flatMap((c: LegacyAny) => c.variants.map((v: LegacyAny) => v.set.path))};
}

// The summary of a weapon added to a cycle (add_wizard.js awAddWeapon / awDelWeapon)
function addwBody(): AddBody {
  const w = A().addw, cycle = awWeaponCycles().find((c: LegacyAny) => c.name === w.mode), last = cycle && cycle.values.length ? cycle.values[cycle.values.length - 1] : '';
  const there = setThere(awWeaponPath(w.name)), set = there ? t('awSetThere') : `${awWeaponPath(w.name)} = { ${w.slot} = '${w.name}' }`;
  return w.added ? {kind: 'addw', say: t('awAddedSay', {w: w.name, m: w.desc}), set: '', why: t('awDelWhy'), added: true, go: t('awDelGo'), block: ''}
    : {kind: 'addw', say: last ? t('awAddSay', {w: w.name, m: w.desc, a: last}) : t('awAddSayFirst', {w: w.name, m: w.desc}), set, why: t('awAddWhy'), added: false,
      go: t('awAddGo'), block: liveWrite() ? '' : t('awNoWay')};
}

/** The "+ Set" window at its step (add_wizard.js awRender) */
export function addStepView(): AddSetView {
  const st = A(), list = awSituations(), cards = (S as LegacyAny)._cards || buildCards(data() as LegacyAny).cards;
  const xs = list && st.subj ? awOfSubject() : [];
  const body: AddBody = st.expert && list ? expertBody(list) : st.step === 0 ? famsBody(list, cards) : !list ? oldBody(cards)
    : st.step === 1 ? subjectsBody(list) : st.addw ? addwBody() : st.step === 2 ? askBody(xs) : sumBody(xs, list);
  const steps = ['awStepWhen', 'awStepWhat', 'awStepAsk', 'awStepSum'].map((k, i) => ({label: `${i + 1}. ${t(k)}`, on: i === st.step && !st.expert, done: i < st.step}));
  return {title: t('awTitle') + (st.addw && st.step >= 2 ? ' · ' + st.addw.name : st.subj && xs[0] && st.step >= 2 ? ' · ' + subjLabel(xs[0]) : ''), steps, body, first: st.step === 0 && !st.expert, back: st.expert ? t('awBackToWizard') : t('back'), cancel: t('cancel'), exists: t('exists'), rec: t('awRec')};
}
