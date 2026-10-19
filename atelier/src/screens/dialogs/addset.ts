// GearSwap Atelier · the "+ Set" window: 1. which kind, 2. which set (the export's catalog, one folding group a catalog
// line, a search over them; a set there opens, one not there yet can be created once its parent table is), 3. what it
// starts from (a copy of the set worn in its place today, nothing, what you wear in game).
// The rules are the old page's renderAdd (add_set.js), which keeps the steps (addStep, addFam, addPath), the search
// (addFilter hides rows in place) and what the game is sent. An export with no catalog keeps the kind's sets, and the
// weaponskill list stays the HTML of push.js (addWsList). The buttons keep the attributes the old handlers read
// (data-addfam, data-addopen, data-addpick, data-addfrom, data-addgroup, data-back).
//
// @file    atelier/src/screens/dialogs/addset.ts
// @author  ejouanchicot

export interface AddRow { q: string; path: string; label: string; there: boolean; why: string }
export type AddBody =
  | {kind: 'fams'; warn: string; fams: Array<{f: string; label: string; when: string}>}
  | {kind: 'catalog'; ph: string; groups: Array<{g: string; label: string; count: string; when: string; open: boolean; rows: AddRow[]}>}
  | {kind: 'paths'; paths: string[]}
  | {kind: 'html'; html: string}
  | {kind: 'start'; path: string; when: string; today: string; opts: Array<{k: string; a: string; b: string}>};
export interface AddSetView { title: string; steps: Array<{label: string; on: boolean}>; body: AddBody; first: boolean; back: string; cancel: string; exists: string; addNew: string }

const FAM_ORDER = ['idle', 'engaged', 'fc', 'ws', 'ja', 'cure', 'midcast', 'enmity', 'pet', 'special', 'xp', 'weapons', 'other'];

// Step 1: the kinds, in the page's order
function famsBody(cat: LegacyAny[] | null, cards: LegacyAny[]): AddBody {
  const fams: string[] = cat ? [...new Set(cat.map(catFamily))] : [...new Set(cards.map((c: LegacyAny) => c.fam as string))];
  fams.sort((a, b) => FAM_ORDER.indexOf(a) - FAM_ORDER.indexOf(b));
  return {kind: 'fams', warn: cat ? '' : t('addNoCatalog'), fams: fams.map(f => ({f, label: t('fam.' + f), when: t('famWhen.' + f)}))};
}

// Step 2: the kind's catalog lines (the ones with a set there first), in each the sets to create first
function catalogBody(cat: LegacyAny[]): AddBody {
  const live = liveWrite(), groups: LegacyAny = {};
  for (const e of cat.filter(e => catFamily(e) === addFam)) (groups[e.group] = groups[e.group] || []).push(e);
  const have = (list: LegacyAny[]) => list.filter(isThere).length;
  const order = Object.keys(groups).sort((a, b) => Number(have(groups[b]) > 0) - Number(have(groups[a]) > 0) || groups[a].length - groups[b].length);
  const row = (e: LegacyAny): AddRow => {
    const there = isThere(e), why = there ? '' : !live ? t('pushNeedsGame') : !parentThere(e) ? t('addParentFirst', {p: shortPath(parentOf(e.path) as string)}) : '';
    return {q: (shortPath(e.path) + ' ' + (e.when || '')).toLowerCase(), path: e.path, label: shortPath(e.path), there, why};
  };
  return {kind: 'catalog', ph: t('addSearch'), groups: order.map(g => { const list = groups[g];
    return {g, label: lineLabel(g), count: t('addCount', {n: list.length, h: have(list)}), when: list[0].when || '',
      open: list.length === 1 || !!((S as LegacyAny)._addOpen || {})[g], rows: list.filter((e: LegacyAny) => !isThere(e)).concat(list.filter(isThere)).map(row)}; })};
}

// Step 3: what the new set starts from
function startBody(): AddBody {
  const e = (catalogEntries() || []).find((x: LegacyAny) => x.path === addPath);
  if (!e) return {kind: 'html', html: ''};
  const base = e.base && setThere(e.base) ? e.base : null, opts: Array<{k: string; a: string; b: string}> = [];
  if (base) opts.push({k: 'copy', a: t('fromCopy', {b: shortPath(base)}), b: t('fromCopyD')});
  opts.push({k: 'empty', a: t('fromEmpty'), b: t('fromEmptyD')}, {k: 'worn', a: t('fromWorn'), b: t('fromWornD')});
  return {kind: 'start', path: shortPath(e.path), when: e.when || '', today: base ? t('addToday', {b: shortPath(base)}) : t('addTodayNone'), opts};
}

// Step 2 of an export with no catalog: the kind's sets there (the weaponskills: push.js addWsList)
function oldBody(cards: LegacyAny[]): AddBody {
  if (addFam === 'ws') return {kind: 'html', html: addWsList(cards)};
  return {kind: 'paths', paths: cards.filter((c: LegacyAny) => c.fam === addFam).flatMap((c: LegacyAny) => c.variants.map((v: LegacyAny) => v.set.path))};
}

/** The "+ Set" window at its step (renderAdd) */
export function addStepView(): AddSetView {
  const cat = catalogEntries(), cards = (S as LegacyAny)._cards || buildCards(data() as LegacyAny).cards;
  const body = addStep === 0 ? famsBody(cat, cards) : addStep === 1 ? (cat ? catalogBody(cat) : oldBody(cards)) : startBody();
  return {title: t('addTitle'), steps: [t('step1'), t('step2'), t('step3')].map((label, i) => ({label: `${i + 1}. ${label}`, on: i === addStep})), body,
    first: addStep === 0, back: t('back'), cancel: t('cancel'), exists: t('exists'), addNew: t('addNew')};
}
