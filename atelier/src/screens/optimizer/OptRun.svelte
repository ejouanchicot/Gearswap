<!--
  GearSwap Atelier · the search window (run.svelte.ts): while the search runs, the clock, the best found and its gain,
  its curve, a card a walk, the moves as they come; once done, the set found against yours and what to do next. The
  rules are the old page's optRunOpen, optRunClock, optRunPaint, optRunSpark, optRunResult (optimizer.js): the search's
  state stays theirs (S._optRun). Still the old page's HTML: the moogle's scenes (moogle.js), the result's buttons.
  The buttons keep the attributes the old handlers read (data-orhide, data-optstop, data-moglines, data-close...).

  @file    atelier/src/screens/optimizer/OptRun.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {runState, currentRun} from './run.svelte';

  let feedEl: HTMLOListElement | undefined = $state();
  let keep = {top: 0, height: 0};

  // the window from the search's state (the old page's optRunPaint, optRunClock, optRunSpark)
  function viewOf(R: LegacyAny) {
    const S0 = S as LegacyAny, best = R ? optRunBest(R) : null;
    const walks = Object.keys(R.walks).map(w => { const x = R.walks[w];
      return {w, label: walkLabel(w), done: !!x.done, stage: x.stage ? t('orStage_' + x.stage) : '',
        phase: x.done ? t('orWalkDone') : (x.phase ? t('orPhase_' + x.phase) : t('orStarting')) + (x.round ? ' · ' + t('orRound', {n: x.round}) : ''),
        evals: x.painted ? t('orTries', {n: (x.evals || 0).toLocaleString()}) : '', best: x.best ? R.fmt(x.best.raw) : '—', miss: !!(x.best && x.best.miss)}; });
    const gainOf = (from: number, to: number) => { const d = (R.low ? from / to - 1 : to / from - 1) * 100;
      return {from: t('orFrom', {v: R.fmt(from)}), up: d > .05, pct: `${d > 0 ? '+' : ''}${d.toFixed(1)} %`}; };
    let spark: null | {line: string; area: string} = null;
    if (R.series.length >= 2) {
      const xs = R.series.map((x: number[]) => x[0]), ys = R.series.map((x: number[]) => R.low ? -x[1]! : x[1]!);
      const x0 = xs[0], x1 = Math.max(xs[xs.length - 1], x0 + 1), y0 = Math.min(...ys), y1 = Math.max(...ys, y0 + 1e-9);
      const pt = (x: number, y: number) => `${((x - x0) / (x1 - x0) * 240).toFixed(1)},${(60 - (y - y0) / (y1 - y0) * 54).toFixed(1)}`;
      const line = 'M' + R.series.map((_x: number[], i: number) => pt(xs[i], ys[i])).join(' L');
      spark = {line, area: line + ' L240,64 L0,64 Z'};
    }
    const res = R.result;
    return {
      kick: R.done ? t('orDone') : R.kick || t('orKick'), title: R.title || shortPath(R.path), clock: R.clockText || '0,0 s', cores: t('orCores', {n: R.cores}),
      chips: R.chips as string[], strip: R.strip as null | Array<{cls: string; title: string}>, finished: !!R.done,
      mog: !!R.mog && !res, lines: !!S0.mogLines, sceneHtml: R.mog ? mogSceneHTML() : '', objLabel: R.objLabel as string,
      big: R.shown == null || !best ? '—' : R.fmt(Math.abs(R.shown - best.raw) < 1e-4 ? best.raw : R.shown),
      gain: best && R.start ? gainOf(R.start, best.raw) : null, spark, walks,
      feed: (R.feed as LegacyAny[]).map(m => ({val: R.fmt(m.raw), changes: m.changes.map((c: LegacyAny) => ({slot: (SLOT_NAMES[S0.lang] || {})[c.slot] || c.slot, from: c.from, to: c.to})),
        walk: walkLabel(m.walk) + (m.stage === 'nofloor' ? ' · ' + t('orStage_nofloor') : '') + (m.miss ? ' · ' + t('orUnder') : '')})),
      rate: R.rateText || '', mogBtn: t(S0.mogLines ? 'mogBack' : 'mogLines'),
      result: res ? {found: t(res.changes.length ? 'orFound' : 'orSame'), big: R.fmt(res.best), gain: gainOf(res.start, res.best), mogWinHtml: res.mogWinHtml,
        changed: t('orChanged', {n: res.changes.length}), changes: res.changes, figures: t('orFigures'), figs: res.figs, mine: t('rdvMine'), tri: t('rdvTry'),
        sameWhy: t('orSameWhy'), lack: res.lack, lackLabel: t('orLack'), footerHtml: res.footerHtml} : null};
  }
  const view = $derived(runState.version > 0 && currentRun() ? viewOf(currentRun()) : null);

  // scrolled down the feed: what is read stays in place while new moves come in on top
  $effect.pre(() => { view?.feed; if (feedEl) keep = {top: feedEl.scrollTop, height: feedEl.scrollHeight}; });
  $effect(() => { view?.feed; if (feedEl && keep.top > 0) feedEl.scrollTop = keep.top + feedEl.scrollHeight - keep.height; });
</script>

{#if view}
  {@const r = view.result}
  <div class="scrim"></div><div class="dialog optrun {view.finished ? 'finished' : ''}" role="dialog" aria-live="polite"><header><div class="orhead"><div><div class="kicker">{view.kick}</div><h3>{view.title}</h3></div><div class="orclock"><span id="orclock">{view.clock}</span><small>{view.cores}</small></div></div><div class="orchips">{#each view.chips as c, i (i)}<span class="orchip">{c}</span>{/each}</div>{#if view.strip}<div class="oastrip">{#each view.strip as x, i (i)}<i class={x.cls} title={x.title}></i>{/each}</div>{/if}</header>{#if r}<div class="body" style="grid-template-rows: auto minmax(0,1fr) auto;"><div class="orhero"><div><div class="orlbl">{r.found + (view.objLabel ? ' · ' : '')}{#if view.objLabel}<b>{view.objLabel}</b>{/if}</div><div class="orbig">{r.big}</div><div class="orgain">{r.gain.from} <b class={r.gain.up ? 'up' : ''}>{r.gain.pct}</b></div></div><svg class="orspark" id="orspark" viewBox="0 0 240 64" preserveAspectRatio="none"><path class="area" d={view.spark?.area}/><path class="line" d={view.spark?.line}/></svg>{@html r.mogWinHtml}</div>{#if r.changes.length}<div class="orres"><div><div class="orlbl">{r.changed}</div><ul class="orchg">{#each r.changes as c, i (i)}<li>{@html c.iconHtml}<span class="orfslot">{c.slot}</span><span><s>{c.from}</s> → <b>{c.to}</b>{@html c.porterHtml}</span></li>{/each}</ul></div>{#if r.figs.length}<div><div class="orlbl">{r.figures}</div><table class="orfig"><thead><tr><th></th><th>{r.mine}</th><th>{r.tri}</th></tr></thead><tbody>{#each r.figs as f, i (i)}<tr><th>{f[0]}</th><td>{f[1]}</td><td class={f[3] > 0 ? 'up' : f[3] < 0 ? 'down' : ''}>{f[2]}</td></tr>{/each}</tbody></table></div>{/if}</div>{:else}<p class="muted">{r.sameWhy}</p>{/if}{#if r.lack.length}<p class="orlack">{r.lackLabel} {#each r.lack as g, i (i)}{#if i}{' · '}{/if}<b>{g.name}</b> {g.gain}{/each}</p>{/if}</div><footer>{@html r.footerHtml}</footer>{:else}<div class="body{view.mog ? ' mog' + (view.lines ? ' lines' : '') : ''}"><div class="orhero"><div><div class="orlbl">{t('orBest') + ' · '}<b>{view.objLabel}</b></div><div class="orbig" id="orbig">{view.big}</div><div class="orgain" id="orgain">{#if view.gain}{view.gain.from} <b class={view.gain.up ? 'up' : ''}>{view.gain.pct}</b>{/if}</div></div><svg class="orspark" id="orspark" viewBox="0 0 240 64" preserveAspectRatio="none"><path class="area" d={view.spark?.area}/><path class="line" d={view.spark?.line}/></svg></div>{#if view.mog}{@html view.sceneHtml}{/if}<div class="orwalks">{#each view.walks as w (w.w)}<div class="orwalk {w.done ? 'done' : ''}" data-orwalk={w.w}><div class="orwh"><i class="ordot"></i><b>{w.label}</b><span class="orstage">{w.stage}</span></div><div class="orbar"><i></i></div><div class="orws"><span class="orphase">{w.phase}</span><span class="orevals">{w.evals}</span></div><div class="orwbest">{w.best + (w.miss ? ' ' : '')}{#if w.miss}<span class="ormiss">{t('orUnder')}</span>{/if}</div></div>{/each}</div><div class="orlbl">{t('orFeed')}</div><ol class="orfeed" id="orfeed" bind:this={feedEl}>{#each view.feed as m, i (view.feed.length - i)}<li><span class="orfval">{m.val}</span><span class="orfmoves">{#each m.changes as c, j (j)}{#if j}{' · '}{/if}<span class="orfslot">{c.slot}</span> <s>{c.from}</s> → <b>{c.to}</b>{/each}</span><span class="orfwalk">{m.walk}</span></li>{:else}<li class="orempty">{t('orFeedEmpty')}</li>{/each}</ol></div><footer><span class="orrate" id="orrate">{view.rate}</span><span class="sp"></span>{#if view.mog}<button class="btn ghost" data-moglines>{view.mogBtn}</button>{/if}<button class="btn ghost" data-orhide>{t('orHide')}</button><button class="btn" data-optstop>{t('optStop')}</button></footer>{/if}</div>
{/if}
