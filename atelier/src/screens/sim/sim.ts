// GearSwap Atelier · Simulate: the game's own GearSwap runs an action without doing it. On the left the job's actions
// (a folding group each magic skill, the Trust, the abilities, the weaponskills, the ranged attack; the target chosen
// narrows them, a search opens them all), on the right the options (target, status, recasts, TP, the buffs the job's
// code reads, its modes) and what the game wore step by step.
// The rules are the old page's renderSim (simulate.js), which keeps asking the game (simPrepare, before this is drawn:
// the actions, the buffs, the action chosen run again), the run itself and the result (simResultHTML, drawn as HTML:
// its cards share the sets' stats code). The buttons and fields keep the attributes the old handlers read (data-simpick,
// data-simgroup, data-simopt, data-simbuff, data-simstate, .simrecasts, .tpin, #simq).
//
// @file    atelier/src/screens/sim/sim.ts
// @author  ejouanchicot

export interface SimChip { key: string; v: string; label: string; on: boolean }
export interface SimGroup { key: string; label: string; open: boolean; here: boolean; rows: Array<{k: string; n: string; label: string; current: boolean}> }
export interface SimView {
  placeholder: null | {html: string; restart: string};
  q: string; ph: string; loading: string; groups: SimGroup[] | null;
  targets: SimChip[]; status: SimChip[]; recasts: boolean; recastsLabel: string;
  tp: null | {steps: SimChip[]; value: string; ph: string};
  buffs: null | {label: string; list: Array<{b: string; on: boolean}>};
  title: string; modesLabel: string; modes: Array<{name: string; label: string; set: boolean; values: string[]; cur: string}>;
  metaHtml: string; resultHtml: string;
}

// The job's actions in their groups: closed until opened (a search opens them all), the chosen action's group marked
function groupsOf(st: LegacyAny): SimGroup[] | null {
  const acts = (S as LegacyAny)._simActions && (S as LegacyAny)._simActions.list || null, q = (st.q || '').toLowerCase();
  if (!acts) return null;
  const row = (k: string, n: string, label?: string) => ({k, n, label: label || n, current: st.kind === k && st.name === n});
  const group = (label: string, rows: SimGroup['rows'], names?: string[]): SimGroup[] => { if (!rows.length) return [];
    const key = S.job + '|' + label;
    return [{key, label, open: !!q || !!(S as LegacyAny).simOpen[key], here: !!st.name && (names || []).includes(st.name), rows}]; };
  // the target chosen narrows the list: on me, what can aim at oneself; on the enemy, what can aim at one
  const match = (n: string) => (!q || n.toLowerCase().includes(q)) && aimHas((acts.aim || {})[n], st.target);
  const magic = acts.magic || (acts.ma && acts.ma.length ? {Magic: acts.ma} : {});
  const order = Object.keys(magic).sort((a, b) => (MAGIC_ORDER.indexOf(a) + 1 || 99) - (MAGIC_ORDER.indexOf(b) + 1 || 99) || a.localeCompare(b));
  const mine = st.target === 'auto' || st.target === 'me', foe = st.target === 'auto' || st.target === 'enemy';
  return [...order.flatMap(sk => group(magicLabel(sk), magic[sk].filter(match).map((n: string) => row('ma', n)), magic[sk])),
    ...(acts.trust && (!q || 'trust'.includes(q)) && mine ? group('Trust', [row('ma', acts.trust, t('simTrust'))], [acts.trust]) : []),
    ...group(t('simAbilities'), (acts.ja || []).filter(match).map((n: string) => row('ja', n)), acts.ja),
    ...group(t('simWs'), (acts.ws || []).filter(match).map((n: string) => row('ws', n)), acts.ws),
    ...(acts.ra && (!q || t('simRanged').toLowerCase().includes(q)) && foe ? group(t('simRangedGroup'), [row('ra', 'Ranged', t('simRanged'))], ['Ranged']) : [])];
}

/** Simulate for the job shown, or null when another section is */
export function simView(): SimView | null {
  const d = data() as LegacyAny;
  if (S.section !== 'sim' || S._cfg || S._pkg || !d) return null;
  const c = S.char as string, none = {q: '', ph: '', loading: '', groups: null, targets: [], status: [], recasts: false, recastsLabel: '', tp: null, buffs: null,
    title: '', modesLabel: '', modes: [], metaHtml: '', resultHtml: ''};
  if (!liveOk(c) || ((S as LegacyAny)._live[c] || {}).job !== S.job) return Object.assign(none, {placeholder: {html: t('simNeedLive', {j: S.job}), restart: ''}});
  if ((S as LegacyAny)._simActions && (S as LegacyAny)._simActions.old) return Object.assign(none, {placeholder: {html: t('simOld'), restart: t('liveRestart')}});
  const st = simState(), chip = (key: string, v: string, label: string) => ({key, v, label, on: String(st[key]) === String(v)});
  const simBuffs: string[] = (((S as LegacyAny)._simBuffs && (S as LegacyAny)._simBuffs.opts) || {}).buffs || [];
  const modes = d.modes.filter((m: LegacyAny) => m.values.length > 1 && m.values.length <= 12 && !modeHidden(m) && !/^[A-Z]{3}Song\d$/.test(m.name));
  const steps: number[] = st.kind === 'ws' ? simTpSteps(st.name) : [];
  return {placeholder: null, q: st.q || '', ph: t('simSearch'), loading: t('simLoading'), groups: groupsOf(st),
    targets: [chip('target', 'auto', t('simAuto')), chip('target', 'me', t('simMe')), chip('target', 'ally', t('simAlly')), chip('target', 'enemy', t('simEnemy'))],
    status: [chip('status', 'Engaged', t('simEngaged')), chip('status', 'Idle', t('simIdle'))], recasts: !!st.recasts, recastsLabel: t('simRecasts'),
    tp: st.kind === 'ws' ? {steps: steps.map(v => chip('tp', String(v), String(v))), value: st.tp && !steps.includes(+st.tp) ? String(st.tp) : '', ph: t('tpOther')} : null,
    // the buffs the job's code reads (GET /sim_buffs): only these count, never the ones on you now
    buffs: simBuffs.length ? {label: t('wornBuffs'), list: simBuffs.map(b => ({b, on: (st.buffs || []).includes(b)}))} : null,
    title: t('simTitle'), modesLabel: t('simModes'),
    modes: modes.map((m: LegacyAny) => { const cur = (st.states || {})[m.name] ?? m.current; return {name: m.name, label: m.desc || m.name, set: cur !== m.current, values: m.values, cur}; }),
    metaHtml: ((S as LegacyAny)._simBusy ? t('simRunning') + ' · ' : '') + statPickBtn(), resultHtml: simResultHTML(d)};
}
