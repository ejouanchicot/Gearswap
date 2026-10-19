// GearSwap Atelier · the target's card (Buffs & target, on the right): its name and where it lives, your chance to
// hit it, its Defense and Evasion as gauges (the full bar what it has, the lit part what is left after the debuffs),
// its VIT and HP, its resistances, the figures guessed, and the button that changes it.
// The rules are the old page's targetCardPanel (target_pick.js), which keeps your accuracy (tgYou) and the hit rate
// (tgRate). The button keeps data-tgtpick (target_pick.js opens the picker).
//
// @file    atelier/src/screens/combat/targetcard.ts
// @author  ejouanchicot

export interface Gauge { label: string; a: number; z: number; tip: string; left: string }
export interface TargetCardView {
  name: string; facts: string; factsTitle: string;
  hit: {tone: string; title: string; label: string; p: number} | {none: string};
  gauges: Gauge[]; vit: number | null; hp: string; res: null | {title: string; items: Array<{bad: boolean; text: string}>; none: string};
  est: string; change: {title: string; label: string};
}

// a gauge: the full bar is the stat at first, the lit part what is left of it
const gauge = (label: string, a: number, z: number, tip: string): Gauge => ({label, a, z, tip, left: (a ? Math.max(0, Math.min(100, z / a * 100)).toFixed(1) : '100') + '%'});

/** The card of the target chosen in b */
export function targetCardView(b: LegacyAny): TargetCardView {
  const key = enemyKey(b.enemy), x = TARGETS[key] || {}, T0 = targetInfo(null), you = tgYou(), p = tgRate(you, T0.eva);
  const defA = Math.max(1, T0.defAfter), evaA = T0.evaAfter;
  const res = (Object.entries(x.res || {}) as Array<[string, number]>).filter(([, v]) => v)
    .map(([k, v]) => ({bad: v < 0, text: `${t('tgRes_' + k)} ${v > 0 ? '+' : '−'}${Math.abs(Math.round(v * 100) / 100)} %`}));
  return {name: x.name || key, facts: [x.lv ? 'Lv ' + x.lv : '', x.job, x.zone].filter(Boolean).join(' · ') || t('pkDefault'), factsTitle: x.zone ? '' : t('tgRef'),
    hit: you ? {tone: tgTone(p), title: t('tgHitTip', {a: you.acc, e: evaA, c: you.cap}), label: t('tgHit'), p: p as number} : {none: t('tgNoAcc')},
    gauges: [gauge(t('tgtDef'), T0.def, defA, t('tgDefTip', {a: T0.def, b: defA})), gauge(t('tgtEva'), T0.eva, evaA, t('tgEvaTip', {a: T0.eva, b: evaA}))],
    vit: x.vit || null, hp: x.hp ? fmtDmg(x.hp) : '', res: x.zone ? {title: t('tgRes'), items: res, none: t('tgNoRes')} : null,
    est: x.est && x.est.length ? '* ' + t('tgEst', {l: x.est.join(', ')}) : '', change: {title: t('ttTgtPick'), label: t('tgChange')}};
}
