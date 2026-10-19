// GearSwap Atelier · the list of the job's sets on the left (the Sets screen, Buffs & target, My character's stats):
// its search, the player's own sections (pinned sets, groups), then the page's categories, each set a row (its
// versions for a party in one row, the weaponskills one folding group a weapon, the spells by kind of magic), the
// names a set is shared under folded under it, what is hidden for the subjob shown.
// The rules are the old page's setListHTML (sets_view.js), with what it keeps in the page's state as it goes (the set
// shown, the categories opened for it, the rows the arrow keys walk: S.sel, S.variant, S.selPath, S.famOpen, S.wsList,
// S._rows, S._vis, S._fams). Still the old page's HTML: a category's head (listFamHead), a row's marks and actions,
// the groups' picker under a row (list_prefs.js), the player's own sections, the list's top and menu.
//
// @file    atelier/src/screens/sets/setlist.ts
// @author  ejouanchicot

export interface SetRow { k: 'row'; cls: string; current: boolean; path: string; group: string | null; pick: number; vpick: number; title: string;
  name: string; ver: string; tried: boolean; marksHtml: string; code: string | null; pickerHtml: string }
export type ListEntry =
  | {k: 'html'; html: string}
  | {k: 'wskill'; key: string; here: boolean; open: boolean; label: string; count: number}
  | SetRow
  | {k: 'aliasfold'; path: string; open: boolean; title: string; label: string}
  | {k: 'alias'; pick: number; vpick: number; title: string; label: string; of: string};
export interface SetListView {
  head: ListHead;
  ownHtml: string;
  entries: ListEntry[];
  empty: null | {html: string};
  hidden: null | {title: string; text: string; button: string};
  grip: string;
  triedTitle: string;
}
export interface SetList { view: SetListView; cards: LegacyAny[]; sel: number; bypath: LegacyAny; vis: number[]; q: string }

const st = (): LegacyAny => S;

/** The list for the job shown, worked out as the old page did, with the same marks left in the page's state */
export type ListMenuItem = {k: 'hr'} | {k: 'small'; label: string} | {k: 'show'; f: string; label: string; em: string}
  | {k: 'item'; attrs: Record<string, string>; label: string; on: boolean | null; tip: string};
export interface ListHead { q: string; ph: string; tip: string; addTip: string; menuOpen: boolean; menuTip: string; fold: null | {tip: string; open: string; close: string}; menu: ListMenuItem[] | null }

// The list's menu (list_prefs.js keeps what each choice does): open or close all, the paths, every set, a new group,
// the groups hidden (a button each to show it again), and saving to the files when the choices are in the browser only
function listMenu(): ListMenuItem[] {
  const p = listPrefs(), item = (attrs: Record<string, string>, label: string, on: boolean | null = null, tip = ''): ListMenuItem => ({k: 'item', attrs, label, on, tip});
  const out: ListMenuItem[] = [item({'data-famall': '1'}, t('lpOpenAll')), item({'data-famall': '0'}, t('lpCloseAll')), {k: 'hr'},
    item({'data-listpaths': ''}, t('lpPaths'), !!(S as LegacyAny).listPaths, t('lpPathsTip')), item({'data-listall': ''}, t('lpAll'), !!(S as LegacyAny)._listAll), {k: 'hr'}, item({'data-listnew': ''}, t('lpNewGroup'))];
  if (p.hide.length) out.push({k: 'hr'}, {k: 'small', label: t('lpHidden')}, ...p.hide.map((f: string): ListMenuItem => ({k: 'show', f, label: listFamLabel(f), em: t('lpShow')})));
  if ((S as LegacyAny)._listUnsaved) out.push({k: 'hr'}, {k: 'small', label: t('lpBrowserOnly')}, item({'data-listsave': ''}, t('lpSaveFile')));
  return out;
}
// The search, + and ⋯, then open or close every group (in sight, not only in the menu), and the menu when open
function listHead(q: string): ListHead {
  return {q: (S as LegacyAny).q, ph: t('searchShort'), tip: t('lpSearchTip'), addTip: t('ttAdd'), menuOpen: !!(S as LegacyAny)._listMenu, menuTip: t('ttMenu'),
    fold: q ? null : {tip: t('lpFoldTip'), open: t('lpOpenAll'), close: t('lpCloseAll')}, menu: (S as LegacyAny)._listMenu ? listMenu() : null};
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
  const job = S0.job, want = S0.selPath[job];
  const found = S0.char + '|' + job + '|' + ((data() || {}).sub || '') + '|';
  if (want && S0._found !== found + want) {
    cards.forEach((c: LegacyAny, i: number) => c.variants.forEach((v: LegacyAny, k: number) => { if (v.set.path === want || (v.set.aliases || []).includes(want)) { S0.sel[job] = i; S0.variant[job + '|' + i] = k; } }));
    S0._found = found + want;
  }
  if (!vis.includes(S0.sel[job])) S0.sel[job] = vis[0];
  const sel: number = S0.sel[job];
  if (cards[sel]) { S0.selPath[job] = shownSet(cards[sel], sel).path; S0._found = found + S0.selPath[job]; }
  // the set shown is in sight in the list: when it is another one than at the last redraw (a click, a reload of the
  // page, a push that opens a version), its category and its weaponskill group open; folded by hand after, they stay so
  const revealKey = S0.char + '|' + job + '|' + S0.selPath[job], reveal = S0._revealed !== revealKey;
  S0._revealed = revealKey;
  if (reveal && cards[sel]) { S0.famOpen[job + '|' + cards[sel].fam] = true; S0._revealNow = true; }
  tierFollowsSet(S0.selPath[job], bypath);
  subFollowsSet(S0.selPath[job], bypath);
  objFollowsSet(S0.selPath[job], bypath);
  const vi = (i: number) => Math.min(S0.variant[job + '|' + i] ?? 0, cards[i].variants.length - 1);
  const rows: Array<[number, number]> = S0._rows = [];
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
  const crossOf = (f: string) => { if (famOpen(f, q)) for (const a of crossAll.filter(a => a.fam === f && !vis.includes(homeOf(a)))) out.push(aliasEntry({...a, label: shortPath(a.path)})); };

  // the spells' sets by kind of magic (list_prefs.js midcastGroup), each kind a folding group
  const grouped = !q && vis.filter(k => cards[k].fam === 'midcast').length > MIDCAST_GROUP_FROM;
  const kindOf = (k: number) => grouped && cards[k].fam === 'midcast' ? midcastGroup(niceName(cards[k])) : '';
  const order = !grouped ? vis : vis.map((k, n) => [k, n] as [number, number]).sort((a, b) => cards[a[0]].fam === 'midcast' && cards[b[0]].fam === 'midcast'
    ? (MIDCAST_ORDER.indexOf(kindOf(a[0])) - MIDCAST_ORDER.indexOf(kindOf(b[0])) || midcastRank(niceName(cards[a[0]])) - midcastRank(niceName(cards[b[0]])) || a[1] - b[1])
    : a[1] - b[1]).map(x => x[0]);
  let kind: string | null = null;
  for (const i of order) {
    const c = cards[i];
    if (c.fam !== fam) {
      if (fam) crossOf(fam);
      fam = c.fam; kind = null;
      // the sets of the category (a set and its Group, Solo and Trust versions are one; a weaponskill is one)
      const lines = (card: LegacyAny) => card.fam === 'ws' ? new Set(card.variants.map((v: LegacyAny) => wsOfSet(v.set) || v.label)).size
        : card.variants.filter((v: LegacyAny) => !card.variants.some((o: LegacyAny) => o !== v && tierLabel(v.label, o.label))).length;
      const n = vis.filter(k => cards[k].fam === fam).reduce((m, k) => m + lines(cards[k]), 0);
      out.push({k: 'html', html: listFamHead(fam!, n, !!cards[sel] && cards[sel].fam === fam, famOpen(fam!, q))});
    }
    // a category is closed until opened (a search opens them all)
    if (!famOpen(c.fam, q)) continue;
    if (kindOf(i)) {
      const mine = kindOf(i), key = job + '|mc:' + mine, here = !!cards[sel] && cards[sel].fam === 'midcast' && kindOf(sel) === mine;
      if ((reveal && here) || S0._openAllSub) S0.wsList = Object.assign({}, S0.wsList, {[key]: true});
      if (mine !== kind) { kind = mine;
        out.push({k: 'wskill', key: 'mc:' + mine, here, open: !!(S0.wsList || {})[key], label: t('mcGrp_' + mine), count: order.filter(k => kindOf(k) === mine).length}); }
      if (!(S0.wsList || {})[key]) continue;
    }
    // (an enhancing set's version named Composure reads as what it is: the one cast on the others, stat_opt.js enhTarget)
    const nameOf = (v: LegacyAny, k: number) => k === 0 ? niceName(c) + (v.label !== 'Base' ? ` · ${v.label}` : '') : enhTarget(v.set) === 'Others' ? t('enhBtnOthers')
      : c.fam === 'midcast' && listModeValue(v.label) ? `${v.label} · ${t('lpModeTag')}` : v.label;
    const code = (v: LegacyAny) => S0.listPaths ? v.set.path : null;
    // its names folded under it: a line to open them (a search opens them)
    const aliasFold = (v: LegacyAny, k: number) => {
      const mine = aliases.filter(a => a.i === i && a.k === k);
      if (!mine.length) return;
      const key = job + '|' + v.set.path, open = !!q || !!(S0._aliasOpen || {})[key];
      out.push({k: 'aliasfold', path: v.set.path, open, title: t('ttAlias'), label: `${open ? '▾' : '▸'} ${t('aliasCount', {n: mine.length})}`});
      if (open) for (const a of mine) out.push(aliasEntry(a));
    };
    const row = (v: LegacyAny, k: number) => {
      if (q && k > 0 && !cardMatch({variants: [v]}, q)) return;
      rows.push([i, k]);
      out.push({k: 'row', cls: `setrow ${k === 0 ? '' : 'var'} ${usable[i] ? '' : 'nouse'}`, current: i === sel && k === vi(i), path: v.set.path, group: null, pick: i, vpick: k,
        title: t('ttRow', {p: v.set.path}), name: nameOf(v, k), ver: '', tried: false, marksHtml: listMarks(v.set) + listRowActs(v.set.path), code: code(v), pickerHtml: listGroupPicker(v.set.path)});
      aliasFold(v, k);
    };
    // a set and its versions for a party (Group, Solo, Trust) are ONE row, the set's name alone: the versions are
    // chosen in the set's head; the row opens the version shown, else the one of the party the figures are worked
    // out with, else the set itself
    const tierRow = (v: LegacyAny, k: number, tiers: Array<[LegacyAny, number, string]>) => {
      const all: Array<[LegacyAny, number, string]> = [[v, k, 'Full'] as [LegacyAny, number, string]].concat(tiers), on = all.find(x => i === sel && x[1] === vi(i));
      const go = on || all.find(x => x[2] === buffTier()) || all[0]!, path = go[0].set.path;
      rows.push([i, go[1]]);
      out.push({k: 'row', cls: `setrow ${k === 0 ? '' : 'var'}`, current: !!on, path, group: null, pick: i, vpick: go[1],
        title: t('ttRowVers', {v: go[2], p: path, l: all.map(x => x[2]).join(', ')}), name: nameOf(v, k), ver: on && on[2] !== 'Full' ? on[2] : '',
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
      if ((reveal && here) || S0._openAllSub) S0.wsList = Object.assign({}, S0.wsList, {[job + '|' + sk]: true});
      const open = !!q || !!(S0.wsList || {})[job + '|' + sk];
      // one row a weaponskill, whatever its versions: they are chosen in the set's head; a search lists them all
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
  const empty = vis.length ? null : {html: mogSorryHTML(esc(t('noMatch')))};
  const who = job + '/' + ((data() || {}).sub || '?');
  const hide = hidden && !q ? {title: t('accTip', {m: job, s: (data() || {}).sub || '?'}), text: t('accHidden', {n: hidden, j: who}), button: t(S0._listAll ? 'accHide' : 'accShow')} : null;
  S0._fams = [...new Set(vis.map(i => cards[i].fam))];
  S0._openAllSub = false;
  // the player's own sections first (pinned sets, groups: list_prefs.js), each set as one plain row
  const where: Record<string, [number, number]> = {};
  cards.forEach((c: LegacyAny, i: number) => c.variants.forEach((v: LegacyAny, k: number) => { where[v.set.path] = [i, k]; }));
  const ownRow = (path: string, group: string) => { const [i, k] = where[path]!, c = cards[i], v = c.variants[k], cur = i === sel && k === vi(i);
    return `<div class="setrow own" aria-current="${cur}" draggable="true" data-rowpath="${esc(path)}" data-rowgroup="${esc(group)}"><button class="tname" data-pick="${i}" data-vpick="${k}" title="${esc(t('ttRow', {p: path}))}">` +
      `<b>${esc(niceName(c) + (v.label !== 'Base' ? ' · ' + v.label : ''))}</b></button><span class="rowmarks">${listMarks(v.set)}${listRowActs(path, group)}</span>` +
      `${S0.listPaths ? `<code>${esc(path)}</code>` : ''}</div>`; };
  const ownHtml = q ? '' : listOwnSections(ownRow, new Set(Object.keys(where)), q);
  return {view: {head: listHead(q), ownHtml, entries: empty ? [] : out, empty, hidden: hide, grip: t('lpResize'), triedTitle: t('rowTry')}, cards, sel, bypath, vis, q};
}
