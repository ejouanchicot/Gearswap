// GearSwap Atelier · the party's pickers in Buffs & target: a song, a roll, a bubble, a storm or a food for a slot (each
// choice by family, a line each: the game's icon, its name, what it gives with the member's gear, the slot already
// holding it; None to take it off), and the jobs to add to the party (by what they bring).
// The rules are the old page's pbOpenPick and pbOpenAdd (party_builder.js): their lists stay PB_PICK's and
// pbAddGroups'. The search on top hides the choices and the families that do not match (pbDlgSearch), here in the
// window itself. The buttons keep the attributes the old handlers read (data-pbchoose, data-pbadd).
//
// @file    atelier/src/screens/dialogs/partypick.ts
// @author  ejouanchicot
import {buffIcon} from '../combat/member';

const st = (): LegacyAny => S;

export interface PickItem { attr: 'data-pbchoose' | 'data-pbadd'; value: string; q: string; on: boolean; label: string; hint: string;
  /** a slot's choice: the game's icon, what it gives with the gear set (Songs +9...), the other slot that holds it */
  icon?: string; effects?: Array<{text: string; neg: boolean}>; tag?: string;
  /** a few words under its name (a roll: what it gives, its lucky and unlucky numbers) */
  desc?: string }
export interface PartyPickView { qPh: string; groups: Array<{title: string; items: PickItem[]}>; cur?: string }


// What a choice gives with the gear set on the member (buffs.js tables, as buffTotals adds them up): a song with its
// Songs+ (to its own limit), a roll at the number chosen with Rolls+, a bubble with Geomancy+, a food, a storm
function effectsOf(kind: string, key: string, v: string, b: LegacyAny): Array<{text: string; neg: boolean}> {
  const fx = (k: string, x: unknown) => ({text: fxShort(k, x as number), neg: PB_FOE.includes(k)});
  if (kind === 'song' && SONGS[v]) {
    const S0 = SONGS[v], plus = v === 'Aria of Passion' ? ariaPlus(b) : Math.min(S0.lim, +(b.songsPlus || 0));
    return Object.entries(S0).filter(([k]) => k !== 'lim').map(([k, x]) => { const n = (x as number[])[0]! + plus * (x as number[])[1]!; return fx(k, k === 'atk' ? Math.floor(n) : n); });
  }
  if (kind === 'roll' && ROLLS[v]) {
    const n = Math.max(0, ROMAN.indexOf(b[key + 'n'] || 'XI'));
    return Object.entries(ROLLS[v]).map(([k, x]) => { const [vals, step] = x as [number[], number]; return fx(k, vals[n]! + (+(b.rollsPlus || 0)) * step); });
  }
  if (['indi', 'geo', 'entrust'].includes(kind)) {
    const d = BUBBLES[v] || GEO_DEBUFFS[v];
    return d ? Object.entries(d).map(([k, x]) => fx(k, (x as number[])[0]! + (+(b.geoPlus || 0)) * (x as number[])[1]!)) : [];
  }
  if (kind === 'food' && FOODS[v]) return Object.entries(FOODS[v]).map(([k, x]) => fx(k, x));
  if (kind === 'storm' && STORMS[v]) return Object.entries(STORMS[v]).map(([k, x]) => fx(k, x));
  return [];
}

// a roll's few words: what it gives, its lucky and unlucky numbers (buffs.js ROLL_WHAT, ROLL_LUCK)
function ppDescOf(kind: string, v: string): string {
  if (kind !== 'roll') return '';
  const what = (ROLL_WHAT[st().lang === 'en' ? 'en' : 'fr'] || {})[v] || '', luck = ROLL_LUCK[v];
  return [what, luck ? t('pbLuck', {l: luck[0], u: luck[1]}) : ''].filter(Boolean).join(' · ');
}

/** A slot's picker (pbOpenPick): its title, its choices (icon, figures, the slot already holding it), None when it holds one */
export function pickView(key: string): null | {title: string; view: PartyPickView; none: null | {value: string; label: string}} {
  const kind = key.replace(/\d+$/, ''), P = PB_PICK[kind], b = buffState(), cur = b[key];
  if (!P) return null;
  // the other slots of the same kind (song1..song3 for song0): the choice they hold, said on its line
  const held: Record<string, string> = {};
  for (const k of Object.keys(b)) if (k !== key && /\d$/.test(k) && k.replace(/\d+$/, '') === kind && b[k]) held[b[k]] = P.title(k.match(/\d+$/)![0]);
  const item = (v: string): PickItem => { const h = P.hint(v);
    // (searched by its name, what it gives and its few words: "double" finds Fighter's, "haste" the Marches)
    const fx = effectsOf(kind, key, v, b), desc = ppDescOf(kind, v);
    return {attr: 'data-pbchoose', value: `${key}|${v}`, q: [v, h, desc, ...fx.map(e => e.text)].join(' ').toLowerCase(), on: v === cur, label: v, hint: h && h.toLowerCase() !== v.toLowerCase() ? h : '',
      icon: buffIcon(kind, v), effects: fx, tag: v !== cur && held[v] ? t('pbHeldIn', {s: held[v]}) : '', desc}; };
  const groups = P.groups().filter(([, list]: [string, string[]]) => list.length).map(([g, list]: [string, string[]]) => ({title: g, items: list.map(item)}));
  return {title: P.title(key.match(/\d+$/) ? key.match(/\d+$/)![0] : ''), view: {qPh: t('pbSearch'), groups, cur: t('pbCurrent')}, none: cur ? {value: `${key}|`, label: t('pbNone')} : null};
}

/** The jobs to add to the party (pbOpenAdd), or null when it is full */
export function addView(): null | {title: string; view: PartyPickView} {
  const shown = pbShown(buffState()), left = PB_MAX - shown.length - 1;
  if (left <= 0) return null;
  const groups = pbAddGroups(shown).map(([g, l, hint]: [string, string[], (j: string) => string]) => ({title: g,
    items: l.map(j => ({attr: 'data-pbadd' as const, value: j, q: (j + ' ' + hint(j)).toLowerCase(), on: false, label: j, hint: hint(j)}))}));
  return {title: t('pbAddTitle', {n: left}), view: {qPh: t('pbSearch'), groups}};
}
