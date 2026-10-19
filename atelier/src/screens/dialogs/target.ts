// GearSwap Atelier · the target picker: the search, the order, the reference target, the zones as chips, the favourite
// and last chosen monsters as shortcuts (out of the way while one searches), then every monster as a card (its levels
// as buttons, each coloured by how well you hit it).
// The rules are the old page's tgCardHTML, openTargetPick and tgFilter (target_pick.js): the search and the zone hide
// cards, the order sorts them, here from the page's state (S._tgtQ, S._tgtZone, S._tgtSort) instead of in place. The
// buttons keep the attributes the old handlers read (data-tgtgo, data-tgtfav, data-tgtzone, data-tgtsort,
// data-tgtback; #tgq).
//
// @file    atelier/src/screens/dialogs/target.ts
// @author  ejouanchicot

export interface TgCard { id: string; on: boolean; q: string; zone: string; lv: number; hit: number; fav: boolean; favTitle: string; name: string; estTitle: string | null;
  sub: string; lvText: string; def: string; eva: string; levels: Array<{key: string; tone: string; pressed: boolean; title: string; label: string}>; hidden: boolean }
export interface TargetView {
  title: string; back: string;
  qPh: string; q: string; sortLabel: string; sorts: Array<{k: string; label: string; selected: boolean}>;
  ref: {pressed: boolean; title: string; label: string};
  zones: Array<{z: string; label: string; n: number; pressed: boolean}>;
  strips: Array<{label: string; cards: TgCard[]; hidden: boolean}>;
  cards: TgCard[]; none: {text: string; hidden: boolean}; foot: string; defLabel: string; evaLabel: string;
}

const st = (): LegacyAny => S;

// one monster: its name and zone, its levels' ranges, a button a level (tgCardHTML)
function cardOf(m: LegacyAny, cur: string, you: LegacyAny): TgCard {
  const fav = tgFavs().includes(m.id), on = m.levels.some((x: LegacyAny) => x.key === cur);
  const rates = m.levels.map((x: LegacyAny) => tgRate(you, x.eva)), known = rates.filter((v: number | null) => v != null), worst = known.length ? Math.min(...known) : null;
  const lo = Math.min(...m.levels.map((x: LegacyAny) => x.lv || 0)), top = Math.max(...m.levels.map((x: LegacyAny) => x.lv || 0));
  const range = (k: string) => `${Math.min(...m.levels.map((x: LegacyAny) => x[k]))}${m.levels.length > 1 ? '–' + Math.max(...m.levels.map((x: LegacyAny) => x[k])) : ''}`;
  return {id: m.id, on, q: (m.name + ' ' + m.zone + ' ' + (m.job || '')).toLowerCase(), zone: m.zone, lv: top, hit: worst == null ? -1 : worst, fav, favTitle: t(fav ? 'tgUnfav' : 'tgFav'),
    name: m.name, estTitle: m.est.length ? t('tgEst', {l: m.est.join(', ')}) : null, sub: [m.job, m.zone].filter(Boolean).join(' · '),
    lvText: String(lo === top ? top : lo + '–' + top), def: range('def'), eva: range('eva'),
    levels: m.levels.map((x: LegacyAny, i: number) => { const p = rates[i];
      return {key: x.key, tone: tgTone(p), pressed: x.key === cur, title: t('tgLvTip', {k: x.key, d: x.def, e: x.eva, h: p == null ? '' : t('tgLvHit', {p})}),
        label: x.key.split(' · ')[1] || (x.lv ? 'Lv' + x.lv : x.key)}; }), hidden: false};
}

/** The target picker (openTargetPick with tgFilter's search, zone and order) */
export function targetView(): TargetView {
  const S0 = st(), cur = enemyKey(buffState().enemy), you = tgYou(), all: LegacyAny[] = tgMonsters(), zones = [...new Set(all.map(m => m.zone as string))];
  const byId = Object.fromEntries(all.map(m => [m.id, m])), idOf = (k: string) => { const x = TARGETS[k]; return x ? x.zone + '|' + x.name : null; };
  const favs = tgFavs().map((id: string) => byId[id]).filter(Boolean);
  const recent = [...new Set(tgRecents().map(idOf))].map(id => byId[id as string]).filter(m => m && !favs.includes(m)).slice(0, 6);
  const q = (S0._tgtQ || '').trim().toLowerCase(), zone = S0._tgtZone || '', sort = S0._tgtSort || 'zone';
  const cards = all.map(m => cardOf(m, cur, you));
  if (sort !== 'zone') cards.sort((a, b) => sort === 'lv' ? a.lv - b.lv : b.hit - a.hit);
  let left = 0;
  for (const c of cards) { c.hidden = !((!q || c.q.includes(q)) && (!zone || c.zone === zone)); if (!c.hidden) left++; }
  const strip = (label: string, list: LegacyAny[]) => ({label, cards: list.map(m => cardOf(m, cur, you)), hidden: !!q || !!zone});
  return {title: t('pkTitle'), back: t('pkBack'), qPh: t('pkSearch'), q: S0._tgtQ || '', sortLabel: t('tgSort'),
    sorts: ['zone', 'lv', 'hit'].filter(k => k !== 'hit' || you).map(k => ({k, label: t('tgSort_' + k), selected: sort === k})),
    ref: {pressed: cur === DEFAULT_ENEMY, title: t('tgRef'), label: DEFAULT_ENEMY},
    zones: [{z: '', label: t('tgAllZones'), n: all.length, pressed: zone === ''}].concat(zones.map(z => ({z, label: z || t('tgAllZones'), n: all.filter(m => m.zone === z).length, pressed: zone === z}))),
    strips: [strip(t('tgFavs'), favs), strip(t('tgRecent'), recent)].filter(x => x.cards.length),
    cards, none: {text: t('tgNone'), hidden: left > 0}, foot: `${t('tgCount', {n: all.length, z: zones.length})} · ${t('pkStar')}`, defLabel: t('tgtDef'), evaLabel: t('tgtEva')};
}
