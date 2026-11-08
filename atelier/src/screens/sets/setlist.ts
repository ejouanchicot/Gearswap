// GearSwap Atelier · the list of the job's sets on the left (the Sets screen, Buffs & target, My character's stats),
// drawn as a game menu (notes/docs-perso/theme-ffxi-2026-11-07/SPEC.md § 9): its search, the families as a menu of
// two columns (the player's pinned sets and groups first), ONE family shown at a time under it, each set a row (its
// versions for a party in one row, chosen under the row of the set open; the weaponskills one folding group a weapon,
// the spells by kind of magic), the names a set is shared under folded under it, what is hidden for the subjob shown.
// A search shows every family's sets that match, each family under its name.
// What it keeps in the page's state as it goes: the set shown, the family shown (S.listFam), the rows the arrow keys
// walk (S._rows), the versions ← → walk (S._vers), the families Tab walks (S._famKeys), S.sel, S.variant, S.selPath,
// S.wsList, S._vis. Still the old page's HTML: a row's marks and actions, the groups' picker under a row
// (list_prefs.js), the menu of the list.
//
// @file    atelier/src/screens/sets/setlist.ts
// @author  ejouanchicot

export interface SetVersion { label: string; pick: number; vpick: number; on: boolean }
export interface SetRow { k: 'row'; cls: string; current: boolean; path: string; group: string | null; pick: number; vpick: number; title: string;
  name: string; vers: SetVersion[] | null; tried: boolean; marksHtml: string; code: string | null; pickerHtml: string }
export type ListEntry =
  | {k: 'html'; html: string}
  | {k: 'famsub'; label: string}
  | {k: 'wskill'; key: string; here: boolean; open: boolean; label: string; count: number}
  | SetRow
  | {k: 'aliasfold'; path: string; open: boolean; title: string; label: string}
  | {k: 'alias'; pick: number; vpick: number; title: string; label: string; of: string};
// an entry of the families' menu: a family of the page's, or a section of the player's (pinned sets, a group)
export interface FamTab { key: string; label: string; iconHtml: string; n: number; on: boolean; here: boolean; own: boolean; drag: boolean; tip: string }
// the title of the family shown, with what can be done to it (rename and hide a family, rename and delete a group)
export interface FamTitle { label: string; acts: Array<{attrs: Record<string, string>; sign: string; tip: string}>; editHtml: string }
export interface SetListView {
  head: ListHead;
  fams: FamTab[];
  newGroupHtml: string;
  title: FamTitle | null;
  entries: ListEntry[];
  empty: null | {html: string};
  // the sets hidden for the subjob shown: how many, each by its family and name (a click opens it, shown again), and
  // the button that shows or hides them all
  hidden: null | {title: string; text: string; button: string; sets: Array<{label: string; fam: string; pick: string}>};
  // "Tout optimiser" (opt_sets.js) at the column's foot, always in sight, once the engine is there
  optAll: null | {label: string; tip: string};
  dense: boolean;
  grip: string;
  triedTitle: string;
  versTitle: string;
}
export interface SetList { view: SetListView; cards: LegacyAny[]; sel: number; bypath: LegacyAny; vis: number[]; q: string }

const st = (): LegacyAny => S;

export type ListMenuItem = {k: 'hr'} | {k: 'small'; label: string} | {k: 'show'; f: string; label: string; em: string}
  | {k: 'item'; attrs: Record<string, string>; label: string; on: boolean | null; tip: string};
export interface ListHead { q: string; ph: string; tip: string; key: string; addTip: string; menuOpen: boolean; menuTip: string; menu: ListMenuItem[] | null }

// The list's menu (list_prefs.js keeps what each choice does): the paths, every set, a new group, the engaged modes in
// one run, the families hidden (a button each to show it again), and saving to the files when kept in the browser only
function listMenu(): ListMenuItem[] {
  const p = listPrefs(), item = (attrs: Record<string, string>, label: string, on: boolean | null = null, tip = ''): ListMenuItem => ({k: 'item', attrs, label, on, tip});
  const out: ListMenuItem[] = [item({'data-listpaths': ''}, t('lpPaths'), !!st().listPaths, t('lpPathsTip')), item({'data-listall': ''}, t('lpAll'), !!st()._listAll), {k: 'hr'}, item({'data-listnew': ''}, t('lpNewGroup'))];
  // every engaged mode and its Dual Wield tiers in one run ("Tout optimiser" with only those ticked: eng_modes.js)
  if (engineReady()) out.push({k: 'hr'}, item({'data-optsets': 'eng'}, t('osEngBtn'), null, t('osEngTip')));
  if (p.hide.length) out.push({k: 'hr'}, {k: 'small', label: t('lpHidden')}, ...p.hide.map((f: string): ListMenuItem => ({k: 'show', f, label: listFamLabel(f), em: t('lpShow')})));
  if (st()._listUnsaved) out.push({k: 'hr'}, {k: 'small', label: t('lpBrowserOnly')}, item({'data-listsave': ''}, t('lpSaveFile')));
  return out;
}
function listHead(): ListHead {
  return {q: st().q, ph: t('lpSearchPh'), tip: t('lpSearchTip'), key: '/', addTip: t('ttAdd'), menuOpen: !!st()._listMenu, menuTip: t('ttMenu'), menu: st()._listMenu ? listMenu() : null};
}

// A base set the job never wears by itself, left out of the list: a PLD's sets.idle (its stance wears idle.PDT /
// idle.MDT outside town, sets.idle.Town in town), only the table its idle sets hang from (the player, 2026-11-01)
const hiddenBase = (s: LegacyAny) => !!s && st().job === 'PLD' && s.path === 'sets.idle';

// Each family's game icon on its tile (game_icons.js, game-icons.net): a group of the player's a bag, Pinned a star
const FAM_ICON: Record<string, string> = {idle: 'meditation', engaged: 'crossed-swords', fc: 'hourglass', ws: 'sword-clash', ja: 'muscle-up', midcast: 'spell-book',
  enmity: 'shield-reflect', cure: 'heart-plus', special: 'sunbeams', weapons: 'sword-brandish', pet: 'wolf-head', xp: 'stairs-goal', other: 'tied-scroll'};
const famIcon = (key: string) => key === 'pin' ? '<span class="ico star" aria-hidden="true">★</span>' : playerIcon('gi:' + (key.startsWith('g:') ? 'backpack' : FAM_ICON[key] || 'tied-scroll'));
// The menu's entries: the player's own sections (Pinned, always there to drop a set on; the groups), then the page's
// families in the list's order, each with its count of sets
function famTabs(counts: Map<string, number>, known: Set<string>, shown: string, selFam: string | null): FamTab[] {
  const p = listPrefs(), n = (sets: string[]) => sets.filter(x => known.has(x)).length;
  const own: FamTab[] = [{key: 'pin', label: t('lpPinned'), iconHtml: famIcon('pin'), n: n(p.pins), on: shown === 'pin', here: false, own: true, drag: false, tip: t('ttPinned')},
    ...p.groups.map((g: LegacyAny): FamTab => ({key: 'g:' + g.id, label: g.name, iconHtml: famIcon('g:' + g.id), n: n(g.sets), on: shown === 'g:' + g.id, here: false, own: true, drag: true, tip: t('ttGroup')}))];
  return own.concat([...counts].map(([f, c]) => ({key: f, label: listFamLabel(f), iconHtml: famIcon(f), n: c, on: shown === f, here: f === selFam, own: false, drag: false, tip: t('ttFam', {w: t('famWhen.' + f)})})));
}
// The family shown: the one chosen in the menu; when the set shown is another one than at the last redraw (a click
// elsewhere, a push that opens a version, a reload) and is not in it, the set's own family
function shownFamily(keys: string[], selFam: string | null, selPath: string, reveal: boolean): string {
  const S0 = st(), p = listPrefs(), job = S0.job;
  S0.listFam = S0.listFam || {};
  let shown: string = S0.listFam[job] || '';
  const holds = (k: string) => k === selFam || (k === 'pin' ? p.pins.includes(selPath) : k.startsWith('g:') && ((p.groups.find((g: LegacyAny) => 'g:' + g.id === k) || {}).sets || []).includes(selPath));
  if ((reveal && !holds(shown)) || !keys.includes(shown)) shown = selFam && keys.includes(selFam) ? selFam : keys.find(k => k !== 'pin') || keys[0] || '';
  S0.listFam[job] = shown;
  return shown;
}
function famTitle(shown: string): FamTitle | null {
  const S0 = st(), edit = (what: string, value: string, hint: string) => S0._listEdit === what ? listNameInput(what, value, hint) : '';
  if (shown === 'pin') return {label: '★ ' + t('lpPinned'), acts: [], editHtml: ''};
  if (shown.startsWith('g:')) { const g = listPrefs().groups.find((x: LegacyAny) => 'g:' + x.id === shown); if (!g) return null;
    return {label: g.name, editHtml: edit('group:' + g.id, g.name, t('lpGroupName')),
      acts: [{attrs: {'data-listedit': 'group:' + g.id}, sign: '✎', tip: t('lpRename')}, {attrs: {'data-listdel': g.id}, sign: '🗑', tip: t('lpDelete')}]}; }
  return {label: listFamLabel(shown), editHtml: edit('fam:' + shown, listFamLabel(shown), t('fam.' + shown)),
    acts: [{attrs: {'data-listedit': 'fam:' + shown}, sign: '✎', tip: t('lpRename')}, {attrs: {'data-listhide': shown}, sign: '⦸', tip: t('lpHide')}]};
}

export function setList(d: LegacyExport): SetList {
  const S0 = st(), {cards, bypath} = buildCards(d); S0._cards = cards; S0._bypath = bypath;
  const q: string = S0.q.trim().toLowerCase();
  // only the sets the job can use with the subjob shown (job_access.js); the others are counted under the list and
  // come back on a click, or for a search that names them
  const usable = cards.map((c: LegacyAny) => cardUsable(c)), showAll = !!S0._listAll || !!q;
  const prefs = listPrefs();
  const vis: number[] = cards.map((_c: LegacyAny, i: number) => i).filter((i: number) => cardMatch(cards[i], q) && (showAll || usable[i]) && (!!q || !prefs.hide.includes(cards[i].fam)));
  S0._vis = vis;
  const hidden = cards.reduce((n: number, c: LegacyAny, i: number) => n + (usable[i] ? 0 : c.variants.length), 0);
  // a set just created (push.js createGo): opened as soon as the page has it, whatever was shown meanwhile
  const pend = S0._openNext;
  if (pend && pend.char === S0.char && pend.job === S0.job && bypath[pend.path]) { S0.selPath[S0.job] = pend.path; S0._found = null; S0._openNext = null; }
  const job = S0.job, want = S0.selPath[job];
  const found = S0.char + '|' + job + '|' + ((data() || {}).sub || '') + '|';
  if (want && S0._found !== found + want) {
    cards.forEach((c: LegacyAny, i: number) => c.variants.forEach((v: LegacyAny, k: number) => { if (v.set.path === want || (v.set.aliases || []).includes(want)) { S0.sel[job] = i; S0.variant[job + '|' + i] = k; } }));
    S0._found = found + want;
  }
  if (!vis.includes(S0.sel[job])) S0.sel[job] = vis[0];
  const sel: number = S0.sel[job];
  // (a hidden base, a PLD's sets.idle: its card opens on its first version shown, idle.MDT, not on it)
  if (cards[sel] && hiddenBase(shownSet(cards[sel], sel))) {
    const k = cards[sel].variants.findIndex((v: LegacyAny) => !hiddenBase(v.set));
    if (k >= 0) S0.variant[job + '|' + sel] = k;
  }
  if (cards[sel]) { S0.selPath[job] = shownSet(cards[sel], sel).path; S0._found = found + S0.selPath[job]; }
  // the set shown is in sight in the list: when it is another one than at the last redraw, its family is shown (unless
  // the family shown holds it: a pinned set clicked) and its weaponskill group opens; folded by hand after, it stays so
  const revealKey = S0.char + '|' + job + '|' + S0.selPath[job], reveal = S0._revealed !== revealKey;
  S0._revealed = revealKey;
  if (reveal && cards[sel]) S0._revealNow = true;
  tierFollowsSet(S0.selPath[job], bypath);
  subFollowsSet(S0.selPath[job], bypath);
  objFollowsSet(S0.selPath[job], bypath);
  const vi = (i: number) => Math.min(S0.variant[job + '|' + i] ?? 0, cards[i].variants.length - 1);

  // the families and their counts (a set and its Group, Solo and Trust versions are one; a weaponskill is one), then
  // the family shown
  const lines = (card: LegacyAny) => card.fam === 'ws' ? new Set(card.variants.map((v: LegacyAny) => wsOfSet(v.set) || v.label)).size
    : card.variants.filter((v: LegacyAny) => !card.variants.some((o: LegacyAny) => o !== v && tierLabel(v.label, o.label))).length;
  const counts = new Map<string, number>();
  for (const k of vis) counts.set(cards[k].fam, (counts.get(cards[k].fam) || 0) + lines(cards[k]));
  const where: Record<string, [number, number]> = {};
  cards.forEach((c: LegacyAny, i: number) => c.variants.forEach((v: LegacyAny, k: number) => { where[v.set.path] = [i, k]; }));
  const known = new Set(Object.keys(where)), selFam: string | null = cards[sel] ? cards[sel].fam : null;
  const keys = ['pin', ...prefs.groups.map((g: LegacyAny) => 'g:' + g.id), ...counts.keys()];
  const shown = shownFamily(keys, selFam, S0.selPath[job] || '', reveal);
  S0._famKeys = keys;
  const isShown = (f: string) => !!q || f === shown;

  const rows: Array<[number, number]> = S0._rows = [];
  S0._vers = [];
  const out: ListEntry[] = [];
  let fam: string | null = null;
  // the names a set is shared under, a link to the set they are: folded right under it, whatever their family
  const aliases: LegacyAny[] = aliasRows(cards, q);
  // an idle or engaged name of a set kept in another family (sets.idle.MDT = sets.engaged.MDT) shows in its own family
  // too: right under the card it is a version of, else at the family's end
  const crossAll = aliases.filter(a => ['idle', 'engaged'].includes(a.fam) && cards[a.i].fam !== a.fam);
  const homeOf = (a: LegacyAny) => cards.findIndex((c: LegacyAny) => c.fam === a.fam && c.top.join('/') === topOf(a.path, a.fam).join('/'));
  const aliasEntry = (a: LegacyAny): ListEntry => ({k: 'alias', pick: a.i, vpick: a.k, title: t('aliasTip', {a: a.path, s: a.of}), label: a.label, of: shortPath(a.of)});
  const crossUnder = (i: number) => { for (const a of crossAll.filter(a => homeOf(a) === i))
    out.push(aliasEntry({...a, label: segs(a.path).slice(topOf(a.path, a.fam).length).join(' · ') || shortPath(a.path)})); };
  const crossOf = (f: string) => { if (isShown(f)) for (const a of crossAll.filter(a => a.fam === f && !vis.includes(homeOf(a)))) out.push(aliasEntry({...a, label: shortPath(a.path)})); };

  // the spells' sets by kind of magic (list_prefs.js midcastGroup), each kind a folding group
  const grouped = !q && vis.filter(k => cards[k].fam === 'midcast').length > MIDCAST_GROUP_FROM;
  const kindOf = (k: number) => grouped && cards[k].fam === 'midcast' ? midcastGroup(niceName(cards[k]), cards[k].variants.map((v: LegacyAny) => v.set.path)) : '';
  const order = !grouped ? vis : vis.map((k, n) => [k, n] as [number, number]).sort((a, b) => cards[a[0]].fam === 'midcast' && cards[b[0]].fam === 'midcast'
    ? (MIDCAST_ORDER.indexOf(kindOf(a[0])) - MIDCAST_ORDER.indexOf(kindOf(b[0])) || midcastRank(niceName(cards[a[0]])) - midcastRank(niceName(cards[b[0]])) || a[1] - b[1])
    : a[1] - b[1]).map(x => x[0]);
  let kind: string | null = null;
  for (const i of order) {
    const c = cards[i];
    if (c.fam !== fam) {
      if (fam) crossOf(fam);
      fam = c.fam; kind = null;
      // a search lists every family that matches, each under its name
      if (q) out.push({k: 'famsub', label: listFamLabel(fam!)});
    }
    if (!isShown(c.fam)) continue;
    if (kindOf(i)) {
      const mine = kindOf(i), key = job + '|mc:' + mine, here = !!cards[sel] && cards[sel].fam === 'midcast' && kindOf(sel) === mine;
      if (reveal && here) S0.wsList = Object.assign({}, S0.wsList, {[key]: true});
      if (mine !== kind) { kind = mine;
        out.push({k: 'wskill', key: 'mc:' + mine, here, open: !!(S0.wsList || {})[key], label: t('mcGrp_' + mine), count: order.filter(k => kindOf(k) === mine).length}); }
      if (!(S0.wsList || {})[key]) continue;
    }
    // (an enhancing set's version named Composure reads as what it is: the one cast on the others, stat_opt.js enhTarget)
    // the card of a whole family (Idle, Engaged: the family's title names it already) with no set of its own (an
    // empty sets.idle): its versions side by side, each by its name alone (MDT, PDT, Regen), not "Idle · MDT"
    const flat = c.top.length === 1 && c.top[0] === c.fam && !c.variants.some((v: LegacyAny) => v.label === 'Base' && !hiddenBase(v.set));
    const nameOf = (v: LegacyAny, k: number) => k === 0 && !flat ? niceName(c) + (v.label !== 'Base' ? ` · ${v.label}` : '') : enhTarget(v.set) === 'Others' ? t('enhBtnOthers')
      : c.fam === 'midcast' && listModeValue(v.label) ? `${v.label} · ${t('lpModeTag')}` : v.label;
    const code = (v: LegacyAny) => S0.listPaths ? v.set.path : null;
    // its names folded under it: a line to open them (a search opens them)
    const aliasFold = (v: LegacyAny, k: number) => {
      let mine = aliases.filter(a => a.i === i && a.k === k);
      // the spells an enmity set is worn for (sets.midcast['Geist Wall'] = sets.midcast.SIRDEnmity: a PLD's /BLU spells,
      // Flash, Jettatura) listed open under it, each by its name: folded, a new player did not find them (2026-11-01)
      if (c.fam === 'enmity') {
        for (const a of mine.filter(a => a.fam === 'midcast')) out.push(aliasEntry({...a, label: segs(a.path).pop() as string}));
        mine = mine.filter(a => a.fam !== 'midcast');
      }
      if (!mine.length) return;
      const key = job + '|' + v.set.path, open = !!q || !!(S0._aliasOpen || {})[key];
      out.push({k: 'aliasfold', path: v.set.path, open, title: t('ttAlias'), label: `${open ? '▾' : '▸'} ${t('aliasCount', {n: mine.length})}`});
      if (open) for (const a of mine) out.push(aliasEntry(a));
    };
    const row = (v: LegacyAny, k: number) => {
      if (q && k > 0 && !cardMatch({variants: [v]}, q)) return;
      if (hiddenBase(v.set)) return;
      rows.push([i, k]);
      // (a set hidden for the subjob, shown again: said on its plate)
      const other = usable[i] ? '' : `<small class="rowother" title="${esc(t('accTip', {m: job, s: (data() || {}).sub || '?'}))}">${esc(t('accOther'))}</small>`;
      out.push({k: 'row', cls: `setrow ${k === 0 || flat ? 'base' : 'var'} ${usable[i] ? '' : 'nouse'}`, current: i === sel && k === vi(i), path: v.set.path, group: null, pick: i, vpick: k,
        title: t('ttRow', {p: v.set.path}), name: nameOf(v, k), vers: null, tried: false, marksHtml: other + listMarks(v.set) + listRowActs(v.set.path), code: code(v), pickerHtml: listGroupPicker(v.set.path)});
      aliasFold(v, k);
    };
    // a set and its versions for a party (Group, Solo, Trust) are ONE row, the set's name alone; the row of the set
    // open shows its versions under its name, in whole words. The row opens the version shown, else the one of the
    // party the figures are worked out with, else the set itself
    const tierRow = (v: LegacyAny, k: number, tiers: Array<[LegacyAny, number, string]>) => {
      const all: Array<[LegacyAny, number, string]> = [[v, k, 'Full'] as [LegacyAny, number, string]].concat(tiers), on = all.find(x => i === sel && x[1] === vi(i));
      const go = on || all.find(x => x[2] === buffTier()) || all[0]!, path = go[0].set.path;
      rows.push([i, go[1]]);
      if (on) S0._vers = all.map(x => [i, x[1]]);
      out.push({k: 'row', cls: `setrow ${k === 0 || flat ? 'base' : 'var'}`, current: !!on, path, group: null, pick: i, vpick: go[1],
        title: t('ttRowVers', {v: go[2], p: path, l: all.map(x => x[2]).join(', ')}), name: nameOf(v, k),
        vers: on ? all.map(x => ({label: x[2], pick: i, vpick: x[1], on: x === on})) : null,
        tried: all.some(x => trialCount(x[0].set)) && !trialCount(go[0].set), marksHtml: listMarks(go[0].set) + listRowActs(path), code: code(go[0]), pickerHtml: listGroupPicker(path)});
      all.forEach(x => aliasFold(x[0], x[1]));
    };
    // the rows of a list of variants ([variant, its rank]); a search shows each version on its own line
    const emit = (items: Array<[LegacyAny, number]>) => {
      const used = new Set<number>();
      items.forEach(([v, k], n) => {
        if (used.has(k)) return;
        const tiers = q ? [] : items.filter(([o, ok], m) => m !== n && !used.has(ok) && tierLabel(o.label, v.label)).map(([o, ok]) => [o, ok, tierLabel(o.label, v.label)!] as [LegacyAny, number, string]);
        if (!tiers.length) return row(v, k);
        tiers.forEach(x => used.add(x[1]));
        tierRow(v, k, tiers);
      });
    };
    const ranked = c.variants.map((v: LegacyAny, k: number) => [v, k] as [LegacyAny, number]);
    // a spell set's versions: the set itself, then the ones a mode picks, then the spell types of the job's code, then the rest
    if (c.fam === 'midcast' && !q) { const types = (window.ATELIER_FAMILIES || {})[niceName(c)] || {};
      const rank = (v: LegacyAny, k: number) => k === 0 || v.label === 'Base' ? -1 : listModeValue(v.label) ? 0 : types[v.label] ? 1 : 2;
      emit(ranked.sort((x: [LegacyAny, number], y: [LegacyAny, number]) => rank(x[0], x[1]) - rank(y[0], y[1]) || x[1] - y[1])); crossUnder(i); continue; }
    if (c.fam !== 'ws') { emit(ranked); crossUnder(i); continue; }
    // weaponskills: the common set, then one folding group a weapon (closed until opened, a search opens them)
    row(c.variants[0], 0);
    const bySkill = new Map<string, Array<[LegacyAny, number]>>();
    c.variants.forEach((v: LegacyAny, k: number) => { if (!k) return; const sk = wsSkills()[wsOfSet(v.set) as string] || t('varOther');
      if (!bySkill.has(sk)) bySkill.set(sk, []); bySkill.get(sk)!.push([v, k]); });
    for (const [sk, items] of [...bySkill].sort((a, b) => a[0].localeCompare(b[0]))) {
      const here = i === sel && items.some(([, k]) => k === vi(i));
      if (reveal && here) S0.wsList = Object.assign({}, S0.wsList, {[job + '|' + sk]: true});
      const open = !!q || !!(S0.wsList || {})[job + '|' + sk];
      // one row a weaponskill, whatever its versions: they are chosen under its row; a search lists them all
      const byWs = new Map<string, Array<[LegacyAny, number]>>();
      items.forEach(x => { const ws = wsOfSet(x[0].set) || x[0].label; if (!byWs.has(ws)) byWs.set(ws, []); byWs.get(ws)!.push(x); });
      out.push({k: 'wskill', key: sk, here, open, label: sk, count: q ? items.length : byWs.size});
      if (!open) continue;
      if (q) { emit(items); continue; }
      for (const [ws, group] of byWs) {
        const head = group.find(([v]) => v.label === ws);
        if (!head || group.length < 2) { emit(group); continue; }
        tierRow(head[0], head[1], group.filter(x => x !== head).map(([v, k]) => [v, k, v.label.startsWith(ws + ' · ') ? v.label.slice(ws.length + 3) : v.label] as [LegacyAny, number, string]));
      }
    }
  }
  if (fam) crossOf(fam);
  // a section of the player's own shown: its sets, each as one plain row (an empty group says how to fill it)
  if (!q && (shown === 'pin' || shown.startsWith('g:'))) out.push(...ownRows(shown, where, known, cards, sel, vi));
  const empty = vis.length ? null : {html: esc(t('noMatch'))};
  const who = job + '/' + ((data() || {}).sub || '?');
  const hide = hidden && !q ? {title: t('accTip', {m: job, s: (data() || {}).sub || '?'}), text: t('accHidden', {n: hidden, j: who}), button: t(S0._listAll ? 'accHide' : 'accShow'),
    sets: cards.flatMap((c: LegacyAny, i: number) => usable[i] ? [] : c.variants.map((v: LegacyAny, k: number) => ({fam: listFamLabel(c.fam), pick: i + '|' + k,
      label: niceName(c) + (v.label !== 'Base' ? ' · ' + v.label : '')})))} : null;
  return {view: {head: listHead(), fams: famTabs(counts, known, q ? '' : shown, selFam), newGroupHtml: S0._listEdit === 'new' ? listNameInput('new', '', t('lpGroupName')) : '',
    title: q ? null : famTitle(shown), entries: empty ? [] : out, empty, hidden: hide,
    optAll: engineReady() ? {label: t('osBtn'), tip: t('osBtnTip')} : null, dense: S0.listDense === 'compact',
    grip: t('lpResize'), triedTitle: t('rowTry'), versTitle: t('lpVersTip')}, cards, sel, bypath, vis, q};
}

// The rows of the pinned sets or of a group; a set no longer in the file is left out, and stays in the arrangement in
// case it comes back. The arrow keys walk them too
function ownRows(key: string, where: Record<string, [number, number]>, known: Set<string>, cards: LegacyAny[], sel: number, vi: (i: number) => number): ListEntry[] {
  const S0 = st(), p = listPrefs(), group = key === 'pin' ? '' : key.slice(2);
  const sets: string[] = (key === 'pin' ? p.pins : ((p.groups.find((g: LegacyAny) => g.id === group) || {}).sets || [])).filter((x: string) => known.has(x));
  if (!sets.length) return key === 'pin' ? [] : [{k: 'html', html: `<p class="grpempty">${esc(t('lpEmptyGroup'))}</p>`}];
  return sets.map(path => { const [i, k] = where[path]!, c = cards[i], v = c.variants[k], cur = i === sel && k === vi(i);
    S0._rows.push([i, k]);
    return {k: 'html', html: `<div class="setrow own base" aria-current="${cur}" draggable="true" data-rowpath="${esc(path)}" data-rowgroup="${esc(group)}"><button class="tname" data-pick="${i}" data-vpick="${k}" title="${esc(t('ttRow', {p: path}))}">` +
      `<b>${esc(niceName(c) + (v.label !== 'Base' ? ' · ' + v.label : ''))}</b></button><span class="rowmarks">${listMarks(v.set)}${listRowActs(path, group)}</span>` +
      `${S0.listPaths ? `<code>${esc(path)}</code>` : ''}</div>`} as ListEntry; });
}
