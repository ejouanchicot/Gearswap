// GearSwap Atelier · the Bags view of My character: every bag as a tile (how full, what it is for, how many things
// are misplaced in it), where the character stands (zone, Mog House, moogles), the state of the tidy-up, then the
// bag shown (or all of them) with its search, filters and the items, or the plan's cards.
// The rules are the old page's renderBags, bvTileHTML, bvTileRole, bvListHTML, bvItemHTML, bvUseHTML, bvRolePick
// (bags_view.js), bpSelBarHTML, renderBagPlan, bpCardHTML, bpStatusHTML (bags_plan.js), bvPlaceHTML (bags_place.js);
// the data (the bags, the plan's one sum, who wears what) stays theirs. The buttons keep the attributes the old
// handlers read (data-bagsel, data-bagcat, data-baguse, data-bagdup, data-bagpc, data-bagrole, data-bpick, data-bptag,
// data-bpall, data-bpnone, data-bpsee, data-bpunk, data-bpwrong, data-bpopen, data-bpmule, data-plrun, data-plwhere,
// data-gtuto; the search box #bagq).
//
// @file    atelier/src/screens/perso/bags.ts
// @author  ejouanchicot

export interface BagTile { name: string; kind: 'porter' | 'locked' | 'bag'; cls: string; pressed: boolean; title: string; used: number; max: number; pct: number;
  role: {title: string; short: string; bad: null | {title: string; n: number}} }
export interface BagGroup { place: string; state: string; title: string; mark: null | {title: string; text: string}; tiles: BagTile[] }
export interface BagItem { id: string; split: boolean; bad: boolean; picked: boolean; unk: boolean; title: string; iconHtml: string; name: string;
  badLine: string; augs: string; use: null | {none: string} | {lock: string; jobs: string[]; more: number; cfg: string}; places: null | {prefix: string; bags: string[]}; n: number }
export interface PlanCard { key: string; cls: string; tip: string; title: string; free: boolean; need: number; now: number; room: string; nowTip: string;
  pct: number; verdict: {ok: boolean; text: string; left: string}; flow: string; bags: string[]; mule: null | {title: string; text: string};
  see: Array<{cat: string; title: string; label: string}> }
export interface BagsView {
  none: string | null;
  at: string; tuto: {title: string; text: string};
  place: null | {title: string; here: string; zone: string; chips: Array<{cls: string; title: string; text: string}>; run: null | {title: string; text: string}; where: {title: string; text: string}};
  toast: string;
  all: {pressed: boolean; title: string; label: string; total: number; room: number; pct: number; sub: string};
  plan: {pressed: boolean; title: string; label: string; sub: string};
  groups: BagGroup[];
  status: {state: string; icon: string; title: string; small: string; chips: Array<{key: string; n: number; label: string; attr: string; value: string; warn: boolean}>;
    unsaved: null | {title: string; text: string}; planText: string};
  body: {kind: 'plan'; title: string; why: string; whyTitle: string; open: {n: number; title: string; text: string}; toast: string; cards: PlanCard[];
      note: {warn: boolean; text: string; unk: string; porter: string}}
    | {kind: 'list'; title: string; roles: Array<{label: string; title: string; bag: string; part: string; options: Array<{value: string; label: string; selected: boolean}>}>;
      filters: {q: string; placeholder: string; cats: Array<{value: string; label: string; pressed: boolean}>; use: {title: string; options: Array<{value: string; label: string; pressed: boolean}>};
        pc: {title: string; label: string; options: Array<{value: string; label: string; selected: boolean}>}; dup: {on: boolean; title: string; label: string}};
      sel: {n: number; pickTip: string; title: string; all: string; cats: Array<{value: string; label: string}>; auto: {title: string; text: string}; none: string};
      list: {none: string; count: string; cats: Array<{name: string; count: number; items: BagItem[]}>}};
}

// ---- a bag as a tile (bvTileHTML, bvTileRole) ----
function tileOf(B: LegacyAny, bag: LegacyAny, sel: string): BagTile {
  const used: number = bag.count != null ? bag.count : bag.items.length, lit = bvLit(bag.name);
  const n = bvRows(B, bag.name, bvWhere(B)).filter(r => r.bad.length).length;
  const role = {title: bvRoleName(B, bag), short: bvRoleShort(B, bag), bad: n ? {title: t('bvBadN', {n}), n} : null};
  const base = {name: bag.name, pressed: sel === bag.name, used, role};
  if (!bag.max) return {...base, kind: 'porter', cls: lit, max: 0, pct: 0,
    title: t('bvPorterTip', {c: used}) + (lit ? ' ' + t(lit === 'open' ? 'plPorterOpen' : 'plPorterShut') : '')};
  const free = bag.max - used, pct = Math.round(100 * used / bag.max), shut = bvShut(bag.name);
  if (bag.locked) return {...base, kind: 'locked', cls: 'full shut', max: bag.max, pct, title: t('bvLockedTip', {b: bag.name, c: used})};
  return {...base, kind: 'bag', cls: `${free <= 0 ? 'full' : pct >= 90 ? 'tight' : ''} ${lit}`.trim(), max: bag.max, pct: Math.min(100, pct),
    title: t('bvTileTip', {b: bag.name, c: used, m: bag.max, f: Math.max(0, free)}) + (shut ? ' ' + t('plTileShut', {w: shut}) : lit === 'open' ? ' ' + t('plTileOpen') : '')};
}

// a group of bags (on the character, the Mog House, stored elsewhere): it says so when all of them are open or closed here
function groupOf(B: LegacyAny, place: string, title: string, sel: string): BagGroup | null {
  const list = (B.bags as LegacyAny[]).filter(b => b.place === place);
  if (!list.length) return null;
  const lit = list.map(b => bvLit(b.name)), on = lit.filter(x => x === 'open').length;
  const state = !lit.some(Boolean) ? '' : on === lit.length ? 'open' : on ? 'part' : 'shut';
  return {place, state, title, tiles: list.map(b => tileOf(B, b, sel)),
    mark: state ? {title: t('plGroupTip'), text: state === 'part' ? t('plGroupPart', {n: on, m: lit.length}) : t(state === 'open' ? 'plGroupOpen' : 'plGroupShut')} : null};
}

// ---- where the character stands (bvPlaceHTML) ----
function placeOf(): BagsView['place'] {
  const p = bvPlace();
  if (!p) return null;
  const seen = plList(p.moogles), chips: Array<{cls: string; title: string; text: string}> = [];
  if (p.mog_house) chips.push({cls: 'good', title: '', text: t('plHouse')});
  // one chip a kind of moogle: the nearest the game shows, else what BG-Wiki lists for this zone
  const kinds = [...new Set([...seen.map(m => m.name as string), ...Object.keys(MOOGLE_PLACES).filter(n => MOOGLE_PLACES[n]!.some(([z]) => z === p.zone))])];
  for (const n of kinds) {
    const m = seen.find(x => x.name === n), at = (MOOGLE_PLACES[n] || []).find(([z]) => z === p.zone);
    chips.push(m ? {cls: m.near ? 'good' : '', title: n === 'Nomad Moogle' ? t('plNomad') : '', text: t(m.near ? 'plNear' : 'plFar', {n, d: m.dist})}
      : {cls: '', title: '', text: t('plZone', {n, p: at && at[1] ? ' (' + at[1] + ')' : ''})});
  }
  // with a Porter Moogle within reach: the chain PorterPacker, wardrobes, refill, asked from here
  const run = seen.some(m => m.name === 'Porter Moogle' && m.near) ? {title: t('plRunTip'), text: t('plRun')} : null;
  return {title: t('plTip'), here: t('plHere'), zone: p.zone || '?', chips, run, where: {title: t('plWhereTip'), text: t('plWhere')}};
}

// ---- the state of the tidy-up (bpStatusHTML) ----
function statusOf(B: LegacyAny): BagsView['status'] {
  const p = bpPlan(B), bad = p.lines.filter(bpLineBad), wrong = bvRows(B, 'all', bvWhere(B)).filter(r => r.bad.length).length;
  const need = (id: string) => (p.lines.find(l => l.id === id) || {need: 0}).need as number;
  const todo = bpMoves(B).moves.length, state = bad.length ? 'bad' : todo ? 'todo' : 'ok', run = B.run;
  const last = run ? ' · ' + t(run.stopped ? 'bpRunStop' : 'bpRunDone', {at: run.at, n: run.moved, s: run.skipped}) : '';
  const chips = [
    {key: 'unk', n: p.unknown, label: t('bpChUnk'), attr: 'data-bpunk', value: '', warn: true},
    {key: 'wrong', n: wrong, label: t('bpChWrong'), attr: 'data-bpwrong', value: '', warn: true},
    {key: 'mule', n: need('mule'), label: t('bpChMule'), attr: 'data-bpsee', value: 'mule', warn: false},
    {key: 'npc', n: need('npc'), label: t('bpChNpc'), attr: 'data-bpsee', value: 'npc', warn: false}].filter(c => c.n);
  return {state, icon: {bad: '✖', todo: '➜', ok: '✔'}[state]!, chips, planText: t('bpChPlan'),
    title: state === 'bad' ? t('bpStBad', {n: bad.length}) : state === 'todo' ? t('bpStTodo', {n: todo}) : t('bpStOk'),
    small: state === 'bad' ? bad.map(l => ((l.ids || [l.id]) as string[]).map(bpCatName).join(' + ')).join(' · ') : state === 'todo' ? t('bpStTodoWhy') : t('bpStOkWhy') + last,
    unsaved: S._bagUnsaved ? {title: t('bpUnsavedTip'), text: t('bpUnsaved')} : null};
}

// ---- the plan: a card a category (renderBagPlan, bpCardHTML) ----
function cardOf(l: LegacyAny): PlanCard {
  const ids: string[] = l.ids || [l.id], name = ids.map(bpCatName).join(' + '), bad = bpLineBad(l);
  const pct = l.room ? Math.min(100, Math.round(100 * (l.free ? 0 : l.now) / l.room)) : 0, cats = ids.filter(c => BP_CATS.includes(c));
  const verdict = l.free ? {ok: true, text: t('bpFrees', {n: l.need}), left: ''} : !l.room ? {ok: false, text: t('bpNoBag'), left: ''}
    : l.over ? {ok: false, text: t('bpOver', {n: l.over}), left: ''} : l.id === 'job' && l.need > l.room ? {ok: false, text: t('bpJobOver', {n: l.need - l.room}), left: ''}
    : {ok: true, text: t(l.out || l.in ? 'bpOk' : 'bpDone'), left: t('bpLeft', {n: l.room - l.after - l.reserve})};
  return {key: ids.join('+'), cls: bad ? 'bad' : l.free ? 'free' : pct >= 90 ? 'tight' : 'ok', tip: [name, l.reserve ? t('bpReserve', {n: l.reserve}) : '', l.note || ''].filter(Boolean).join('\n'),
    title: ids.map(c => bpCatName(c).split(' (')[0]).join(' + '), free: !!l.free, need: l.need, now: l.now, room: String(l.room || '—'), nowTip: t('bpNowTip'), pct, verdict,
    flow: l.free || !(l.out || l.in) ? '' : [l.out ? t('bpOutN', {n: l.out}) : '', l.in ? t('bpInN', {n: l.in}) : ''].filter(Boolean).join(' · ') + ' → ' + t('bpAfterN', {n: l.after}),
    bags: l.bags, mule: l.id === 'mule' && l.need ? {title: t('bpMuleTip'), text: t('bpMuleGo')} : null,
    see: cats.map(c => ({cat: c, title: t('bpSeeCat', {c: bpCatName(c)}), label: cats.length > 1 ? bpCatName(c).split(' (')[0]! : t('bpSee')}))};
}

// ---- an item of the list (bvItemHTML, bvUseHTML) ----
function useOf(r: LegacyAny): BagItem['use'] {
  const u = r.use, jobs = (Object.entries(u.jobs) as Array<[string, number]>).sort((a, b) => b[1] - a[1]), ls = bvLockSets(r);
  const lock = ls.length ? t('bvLs', {l: ls.join(' ')}) : '';
  if (!jobs.length && !u.files.size && !lock) return bvIsGear(r) ? {none: t('bvNoSet')} : null;
  const max = lock ? 3 : 4;
  return {lock, jobs: jobs.slice(0, max).map(([j]) => j), more: Math.max(0, jobs.length - max), cfg: u.files.size ? t('bvCfg') : ''};
}

function itemOf(B: LegacyAny, r: LegacyAny, sel: string): BagItem {
  const others = sel === 'all' ? r.where : r.where.filter((w: LegacyAny) => w.bag !== sel);
  const tip = [r.info.name + (r.n > 1 ? ' ×' + r.n : ''), r.augs ? r.augs.join(' · ') : '',
    r.where.map((w: LegacyAny) => w.bag + (w.slip ? ' (' + w.slip + ')' : '') + (w.n > 1 ? ' ×' + w.n : '')).join(', '), bvUseTip(r)].filter(Boolean).join('\n');
  const why = r.bad.map((x: LegacyAny) => x.bag + ' : ' + t(x.why)).join('\n') + (r.bad.length ? '\n' + t('bvGoes', {d: bpDest(B, r)}) : '');
  const cat = bpCat(B, r), mine = !!bpTags()[r.id], lock = bpLock()[r.id];
  return {id: String(r.id), split: r.where.length > 1, bad: r.bad.length > 0, picked: ((S._bagPick || new Set()) as Set<string>).has(String(r.id)), unk: cat === 'unknown',
    title: tip + '\n' + t('bpCatTip', {c: bpCatName(cat), m: mine ? t('bpByYou') : ''}) + (cat === 'npc' && bpNpc(r.info.name) ? '\n' + t('bpNpcAt', {n: bpNpc(r.info.name)}) : '')
      + (lock ? '\n' + t('bpLockOf', {l: lock.join(', ')}) : '') + (why ? '\n⚠ ' + why : ''),
    iconHtml: itemIco(r.info.name, r.id), name: r.info.name,
    badLine: r.bad.length ? (sel === 'all' ? r.bad.map((x: LegacyAny) => bvShort(x.bag)).join(', ') + ' ' : '') + '→ ' + bpDest(B, r) : '',
    augs: r.augs ? r.augs.join(' · ') : '', use: useOf(r), places: others.length ? {prefix: sel === 'all' ? '' : '+ ', bags: others.map((w: LegacyAny) => bvShort(w.bag))} : null, n: r.n};
}

// the list under the filters: by category, sorted (bvListHTML)
function listOf(B: LegacyAny, sel: string): Extract<BagsView['body'], {kind: 'list'}>['list'] {
  const where = bvWhere(B), all = bvRows(B, sel, where), rows = bvFilter(all);
  if (!rows.length) return {none: t(all.length ? 'bvNoHit' : 'bvEmpty'), count: '', cats: []};
  rows.sort((a, b) => bvRank(a.info.cat) - bvRank(b.info.cat) || a.info.name.localeCompare(b.info.name));
  const cats = [...new Set(rows.map(r => r.info.cat as string))];
  return {none: '', count: t('bvCount', {n: rows.length, s: rows.reduce((n, r) => n + r.slots, 0)}),
    cats: cats.map(c => { const list = rows.filter(r => r.info.cat === c); return {name: bvCatName(c), count: list.length, items: list.map(r => itemOf(B, r, sel))}; })};
}

// what the bag shown is for: one menu, two for a bag that is not a wardrobe (bvRolePick)
function rolesOf(B: LegacyAny, bag: LegacyAny): Extract<BagsView['body'], {kind: 'list'}>['roles'] {
  const [cur, also] = bvRoles(B, bag), wardrobe = /^Wardrobe/.test(bag.name);
  const list = wardrobe ? ['free', 'job', 'gear', 'spare', 'unused', 'craft'] : bag.place === 'porter' ? ['archive'] : BV_ROLES.filter(r => r !== 'job');
  const opts = (sel: string | undefined, none: boolean) => (none ? [{value: '', label: '—', selected: false}] : [])
    .concat(list.filter(r => !none || (r !== 'free' && r !== cur)).map(r => ({value: r, label: t('bvR_' + r), selected: r === sel})));
  const out = [{label: t('bvRoleOf'), title: t('bvRoleTip'), bag: bag.name, part: '0', options: opts(cur, false)}];
  // a second role for a bag that is not a wardrobe: two kinds of things share its room
  if (!(wardrobe || bag.place === 'porter' || cur === 'free')) out.push({label: t('bvRole2'), title: t('bvRole2Tip'), bag: bag.name, part: '1', options: opts(also, true)});
  return out;
}

/** The Bags view for the old page's state now */
export function bagsView(): BagsView {
  const B = bvBags();
  const empty = {at: '', tuto: {title: '', text: ''}, place: null, toast: '', all: {pressed: false, title: '', label: '', total: 0, room: 0, pct: 0, sub: ''},
    plan: {pressed: false, title: '', label: '', sub: ''}, groups: [], status: {state: '', icon: '', title: '', small: '', chips: [], unsaved: null, planText: ''},
    body: {kind: 'plan' as const, title: '', why: '', whyTitle: '', open: {n: 0, title: '', text: ''}, toast: '', cards: [], note: {warn: false, text: '', unk: '', porter: ''}}};
  if (!B) return {none: t('bvNone'), ...empty};
  const bags = B.bags as LegacyAny[], sel = bags.some(b => b.name === S.bagSel) ? String(S.bagSel) : 'all', sized = bags.filter(b => b.max);
  const total = sized.reduce((n, b) => n + (b.count != null ? b.count : b.items.length), 0), room = sized.reduce((n, b) => n + b.max, 0);
  const head = {none: null, at: t('bvAt', {at: B.at || '?'}), tuto: {title: t('gTutoTip'), text: t('gTuto')}, place: placeOf(),
    toast: S.toast && S.bagSel !== 'plan' ? S.toast : '',
    all: {pressed: sel === 'all', title: t('bvAllTip'), label: t('bvAll'), total, room, pct: Math.round(100 * total / room), sub: t('bvAllSub')},
    plan: {pressed: S.bagSel === 'plan', title: t('bpPlanTip'), label: t('bpPlan'), sub: t('bpPlanSub')},
    groups: [groupOf(B, 'self', t('bvSelf'), sel), groupOf(B, 'house', t('bvHouse'), sel), groupOf(B, 'porter', t('bvPorter'), sel)].filter((g): g is BagGroup => !!g),
    status: statusOf(B)};
  if (S.bagSel === 'plan') {
    const p = bpPlan(B), n = bpMoves(B).moves.length;
    return {...head, body: {kind: 'plan', title: t('bpTitle'), why: t('bpWhyS'), whyTitle: t('bpWhy'), open: {n, title: t('bpOpenTip'), text: t('bpOpen', {n})},
      toast: S.toast || '', cards: p.lines.filter(l => l.need || l.room).map(cardOf),
      note: {warn: !!p.unknown, text: p.unknown ? t('bpUnknown', {n: p.unknown}) : t('bpAllGood'), unk: p.unknown ? t('bpSee') : '', porter: p.porter ? t('bpPorter', {n: p.porter}) : ''}}};
  }
  const have = new Set(Object.values(B.items as Record<string, {cat: string}>).map(i => i.cat));
  const cats = ['all', ...BV_CATS.filter(c => have.has(c)), ...[...have].filter(c => !BV_CATS.includes(c))];
  const shown = bvFilter(bvRows(B, sel, bvWhere(B))).length, n = ((S._bagPick || new Set()) as Set<string>).size;
  return {...head, body: {kind: 'list', title: sel === 'all' ? t('bvAll') : sel, roles: sel === 'all' ? [] : rolesOf(B, bags.find(b => b.name === sel)),
    filters: {q: String(S.bagQ || ''), placeholder: t('bvSearch'),
      cats: cats.map(c => ({value: c, label: c === 'all' ? t('bvCatAll') : bvCatName(c), pressed: (S.bagCat || 'all') === c})),
      use: {title: t('bvUseTip', {j: bvUsage().jobs.join(' ') || '—'}), options: [['all', 'bvUseAll'], ['unk', 'bpUnk'], ['bad', 'bvUseBad'], ['lock', 'bvUseLock'],
        ['none', 'bvUseNone'], ['one', 'bvUseOne'], ['many', 'bvUseMany']].map(([value, k]) => ({value: value!, label: t(k!), pressed: (S.bagUse || 'all') === value}))},
      pc: {title: t('bpPcTip'), label: t('bpPc'), options: [{value: '', label: t('bvCatAll'), selected: !S.bagPc}].concat([...BP_CATS, 'unknown'].map(c => ({value: c, label: bpCatName(c), selected: S.bagPc === c})))},
      dup: {on: !!S.bagDup, title: t('bvDupTip'), label: t('bvDup')}},
    sel: {n, pickTip: t('bpPickTip'), title: t('bpSel', {n}), all: t('bpSelAll', {n: shown}), cats: BP_CATS.map(c => ({value: c, label: bpCatName(c)})),
      auto: {title: t('bpAutoTip'), text: t('bpAuto')}, none: t('bpSelNone')},
    list: listOf(B, sel)}};
}
