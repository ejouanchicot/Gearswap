// GearSwap Atelier · the character's figures with a set (every stat, folded under a set's figures; My character's
// cards): HP, MP, Defense, Attack, Accuracy, Evasion against what the character has now, the attributes, and the
// stats the game caps (damage taken, Haste, Fast Cast, SIRD with its merits); when it was measured.
// The rules are the old page's globalsHTML (sets_view.js), which keeps S._curSet.
//
// @file    atelier/src/screens/sets/globals.ts
// @author  ejouanchicot
import {row, type StatRow} from './figures';
import {capLine, damageTaken, type Line} from './statlines';

export interface GlobalsBox { key: string; cls: string; titleHtml: string; open: boolean; count: number; lead: string; big: boolean; lines: Line[] }
export interface GlobalsView { noChar: string; youTitle: string; foldTitle: string; boxes: GlobalsBox[]; noteHtml: string }

const st = (): LegacyAny => S;

/** The figures of the set s: folded boxes and the measure's note (only 'stats'), or the three open cards ('cards') */
export function globalsView(s: LegacyAny, only: 'stats' | 'cards'): GlobalsView {
  const S0 = st();
  S0._curSet = s;
  const r = charStats(s) as LegacyAny, foldTitle = t('ttFold');
  if (!r) return {noChar: t('noChar'), youTitle: t('youTitle'), foldTitle, boxes: [], noteHtml: ''};
  const {c, out, set, vsSet} = r;
  const line = (label: string, o: LegacyAny): StatRow => { const d = o.set - o.now;
    return row(label, o.set, d ? `<em class="delta ${d > 0 ? 'up' : 'down'}">${d > 0 ? '+' : '−'}${Math.abs(d)}</em>` : ''); };
  const v = (k: string) => (set[k] || {}).v || 0;
  const main = ([['HP', out.hp], ['MP', out.mp], [t('defLabel'), out.def], [t('atkLabel'), out.atk], [t('accLabel'), out.acc], [t('evaLabel'), out.eva]] as Array<[string, LegacyAny]>)
    .filter(([, o]) => o).map(([l, o]) => line(l, o));
  const attrs = ATTRS.map((a: string) => line(a.toUpperCase(), out[a]));
  // merits the game counts per level (res/merit_points.lua: "Spell Interruption Rate" 2 % a level)
  const sirdMerits = sirdMeritsOf(c), sird = v('sird') + sirdMerits;
  const gear: Line[] = [...damageTaken(v), capLine('Haste', v('haste'), 25, ''), capLine('Fast Cast', v('fc'), 80, '')]
    .concat(sird ? [row('SIRD', sird + ' %', sirdMerits ? `<em class="delta">${t('withMerits')}</em>` : '', '', `${t('gearOnly')} ${v('sird')} % + ${t('merits')} ${sirdMerits} %`)] : []);
  const box = (key: string, cls: string, titleHtml: string, lines: Line[], big = false, lead = ''): GlobalsBox => ({key, cls, titleHtml, open: !!S0.boxOpen[key], count: lines.length, lead, big, lines});
  if (only === 'cards') return {noChar: '', youTitle: '', foldTitle, noteHtml: '',
    boxes: [box('you', 'g-you', t('youTitle'), main, true), box('attr', 'g-attr', t('attrTitle'), attrs), box('caps', 'g-caps', t('gearKey'), gear)]};
  const levels = [c.master_level ? `ML ${c.master_level}` : '', c.jp_spent ? `${c.jp_spent} JP` : ''].filter(Boolean).join(' · ');
  const edited = Object.keys(S0.meritEdits[meritKey()] || {}).length;
  return {noChar: '', youTitle: '', foldTitle,
    boxes: [box('you', 'g-you', t('youTitle') + (edited ? ` <span class="edited">· ${t('meritsEdited', {n: edited})}</span>` : ''), main, true, vsSet ? t('vsSet') : ''),
      box('attr', 'g-attr', t('attrTitle'), attrs), box('caps', 'g-caps', t('gearKey'), gear)],
    noteHtml: (levels ? esc(levels) + ' · ' : '') + t('measured', {at: esc(c.at), s: esc(c.sub || '—')})};
}
