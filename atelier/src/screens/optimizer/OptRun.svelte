<!--
  GearSwap Atelier · the search window (run.svelte.ts), drawn like the game's windows: while the search runs, the clock,
  the best set's equipment, the curve one step a better set, the log as the game's chat, the moogle beside it (runview.ts:
  what each shows, told at a pace that can be read); once done, the same curve, the set found against yours and what to do next. The
  rules are the old page's optRunOpen, optRunClock, optRunPaint, optRunSpark, optRunResult (optimizer.js): the search's
  state stays theirs (S._optRun). Still the old page's HTML: the moogle's scenes (moogle.js), the result's buttons.
  The buttons keep the attributes the old handlers read (data-orhide, data-optstop, data-moglines, data-close...).

  @file    atelier/src/screens/optimizer/OptRun.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {runState, currentRun} from './run.svelte';
  import {pushBtnView} from '../sets/push';
  import PushButton from '../sets/PushButton.svelte';
  import {toldOf, toldValue, equipOf, chartOf, logOf, statusOf, runSeconds, type Chart} from './runview';

  let logEl: HTMLDivElement | undefined = $state();
  let stick = true;

  // the window from the search's state (optimizer.js optRunStep, optRunClock)
  function viewOf(R: LegacyAny) {
    const S0 = S as LegacyAny;
    // (from a start of 0, a gain in % means nothing, 0 / 0: Cover's "Ability pieces" from 0 read "NaN %"; the figure's
    // own gain then, +1)
    const gainOf = (from: number, to: number) => { const d = (R.low ? from / to - 1 : to / from - 1) * 100;
      if (!from || !to || !isFinite(d)) { const n = R.low ? from - to : to - from;
        return {from: t('orFrom', {v: R.fmt(from)}), up: n > 0, pct: n ? `${n > 0 ? '+' : '−'}${R.fmt(Math.abs(n))}` : '='}; }
      return {from: t('orFrom', {v: R.fmt(from)}), up: d > .05, pct: `${d > 0 ? '+' : ''}${d.toFixed(1)} %`}; };
    const res = R.result, now = runSeconds(R), told = toldOf(R, now), eq = equipOf(R, told), tv = toldValue(R, told);
    return {
      kick: R.done ? t('orDone') : R.kick || t('orKick'), title: R.title || shortPath(R.path), clock: R.clockText || '0,0 s', cores: t('orCores', {n: R.cores}),
      chips: R.chips as string[], strip: R.strip as null | Array<{cls: string; title: string}>, finished: !!R.done,
      mog: !!R.mog && !res, lines: !!S0.mogLines, sceneHtml: R.mog ? mogSceneHTML() : '', objLabel: R.objLabel as string,
      rate: R.rateText || '', eq, chart: chartOf(R, told), log: logOf(R, told), status: statusOf(R, now, told),
      hasFloor: !!R.hasFloor, floorsOk: told.steps > 0, nChanged: eq.changed, lowWord: t(R.low ? 'orLower' : 'orHigher'),
      told: tv == null ? '—' : R.fmt(tv), toldGain: tv != null && R.start ? gainOf(R.start, tv) : null, mogBtn: t(S0.mogLines ? 'mogBack' : 'mogLines'),
      result: res ? {found: t(res.changes.length ? 'orFound' : 'orSame'), big: R.fmt(res.best), gain: gainOf(res.start, res.best), mogWinHtml: res.mogWinHtml,
        changed: t('orChanged', {n: res.changes.length}), changes: res.changes, figures: t('orFigures'), figs: res.figs, mine: t('rdvMine'), tri: t('rdvTry'),
        sameWhy: t('orSameWhy'), lack: res.lack, lackLabel: t('orLack'), foot: {close: t('close'), cmp: res.footer.changed ? t('orCompare') : '', save: res.footer.changed && res.footer.live ? t('trySave') : '',
          push: res.footer.changed ? pushBtnView(res.footer.set, res.footer.live) : null}} : null};
  }
  const view = $derived(runState.version > 0 && currentRun() ? viewOf(currentRun()) : null);

  // the log as the game's chat: the newest line at the bottom, followed unless scrolled up to read
  $effect.pre(() => { view?.log; if (logEl) stick = logEl.scrollTop + logEl.clientHeight >= logEl.scrollHeight - 4; });
  $effect(() => { view?.log; if (logEl && stick) logEl.scrollTop = logEl.scrollHeight; });
</script>

{#snippet chartSvg(c: Chart)}<svg class="orchart" viewBox="0 0 {c.w} {c.h}" preserveAspectRatio="xMidYMid meet">
          <defs><linearGradient id="orgold" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ffd86a" stop-opacity=".22"/><stop offset="1" stop-color="#ffd86a" stop-opacity="0"/></linearGradient></defs>
          {#each c.yTicks as y, i (i)}<line class="grid" x1={c.left} x2={c.w - c.right} y1={y.y} y2={y.y}/><text class="tick" x={c.left - 6} y={y.y + 4} text-anchor="end">{y.label}</text>{/each}
          {#if c.pre}<rect class="nofl" x={c.left} y={c.top} width={Math.max(0, c.preX - c.left)} height={c.h - c.top - c.bottom}/><text class="noflt" x={c.left + 4} y={c.h - c.bottom - 6}>{t('orNoFloorZone')}</text><path class="pre" d={c.pre}/>{/if}
          {#if c.base}<line class="base" x1={c.left} x2={c.w - c.right} y1={c.base.y} y2={c.base.y}/><text class="basel" x={c.base.x} y={c.base.y + 15} text-anchor="end">{c.base.label}</text>{/if}
          {#if c.area}<path class="area" d={c.area} fill="url(#orgold)"/><path class="gold" d={c.line}/>{/if}
          {#each c.jumps as j, i (i)}<g><title>{j.title}</title><circle class="dot" cx={j.x} cy={j.y} r="4"/>{#if j.src}<image href={j.src} x={j.x - 13} y={j.y - 36} width="26" height="26"/>{/if}</g>{/each}
          {#if c.end}<text class="endl" x={c.end.x - 2} y={c.end.y - 8} text-anchor="end">{c.end.label}</text>{/if}
        </svg>{/snippet}

{#if view}
  {@const r = view.result}
  <div class="scrim"></div><div class="dialog optrun {view.finished ? 'finished' : ''}" role="dialog" aria-live="polite"><header><div class="orhead"><div><div class="kicker">{view.kick}</div><h3>{view.title}</h3></div><div class="orclock"><span id="orclock">{view.clock}</span><small>{view.cores}</small></div></div><div class="orchips">{#each view.chips as c, i (i)}<span class="orchip">{c}</span>{/each}</div>{#if view.strip}<div class="oastrip">{#each view.strip as x, i (i)}<i class={x.cls} title={x.title}></i>{/each}</div>{/if}</header>{#if r}<div class="body" style="grid-template-rows: auto minmax(0,1fr) auto;"><div class="orhero"><div><div class="orlbl">{r.found + (view.objLabel ? ' · ' : '')}{#if view.objLabel}<b>{view.objLabel}</b>{/if}</div><div class="orbig">{r.big}</div><div class="orgain">{r.gain.from} <b class={r.gain.up ? 'up' : ''}>{r.gain.pct}</b></div></div>{#if view.chart}<div class="orff orresc">{@render chartSvg(view.chart)}</div>{/if}{@html r.mogWinHtml}</div>{#if r.changes.length}<div class="orres"><div><div class="orlbl">{r.changed}</div><ul class="orchg">{#each r.changes as c, i (i)}<li>{@html c.iconHtml}<span class="orfslot">{c.slot}</span><span><s>{c.from}</s> → <b>{c.to}</b>{@html c.porterHtml}</span></li>{/each}</ul></div>{#if r.figs.length}<div><div class="orlbl">{r.figures}</div><table class="orfig"><thead><tr><th></th><th>{r.mine}</th><th>{r.tri}</th></tr></thead><tbody>{#each r.figs as f, i (i)}<tr><th>{f[0]}</th><td>{f[1]}</td><td class={f[3] > 0 ? 'up' : f[3] < 0 ? 'down' : ''}>{f[2]}</td></tr>{/each}</tbody></table></div>{/if}</div>{:else}<p class="muted">{r.sameWhy}</p>{/if}{#if r.lack.length}<p class="orlack">{r.lackLabel} {#each r.lack as g, i (i)}{#if i}{' · '}{/if}<b>{g.name}</b> {g.gain}{/each}</p>{/if}</div><footer><button class="btn ghost" data-close>{@html r.foot.close}</button><span class="sp"></span>{#if r.foot.cmp}<button class="btn ghost" data-cmpopen>{@html r.foot.cmp}</button>{/if}{#if r.foot.save}<button class="btn ghost" data-trysave>{@html r.foot.save}</button>{/if}{#if r.foot.push}<PushButton b={r.foot.push} />{/if}</footer>{:else}<div class="body orff{view.mog ? ' mog' + (view.lines ? ' lines' : '') : ''}">
    <div class="orrow">
      <section class="orpane oreq"><h4>{t('orEquip')}</h4><div class="oreqg">{#each view.eq.cells as c (c.slot)}<div class="orcell" class:hot={c.hot} title={c.name ? c.label + ' : ' + c.name : c.label}>{@html c.html}</div>{/each}</div>
        {#if view.eq.last}<div class="orlast">{t('orLastChange')} <b>{view.eq.last}</b></div>{/if}
        {#if view.hasFloor}<div class="orflo {view.floorsOk ? 'ok' : 'no'}">{view.floorsOk ? t('orFloorsOk') : t('orFloorsNo')}</div>{/if}</section>
      <section class="orpane orcurve"><h4>{view.objLabel} · {view.lowWord}</h4>
        <div class="orbigrow"><span class="orbig" id="orbig">{view.told}</span>{#if view.toldGain}<span class="orgainff {view.toldGain.up ? 'up' : ''}">{t('orVsYours', {g: view.toldGain.pct})}</span>{/if}{#if view.nChanged}<span class="orn">{t('orChanged', {n: view.nChanged})}</span>{/if}</div>
        {#if view.chart}{@render chartSvg(view.chart)}{:else}<div class="orchart wait"></div>{/if}</section>
    </div>
    <div class="orbottom"><div class="orlog" bind:this={logEl}>{#each view.log as l, i (i)}<div class="l {l.k}">{#if l.k === 'gain'}{#each l.changes || [] as c, j (j)}{#if j}{' · '}{/if}{c.slot} ▸ <span class="it">{c.name}</span>{/each} : {#if l.tie}{l.to} · <span class="tie">{t('orLogTie')}</span>{:else}{l.from} → {l.to}{/if}{:else}{l.text}{/if}</div>{/each}</div>{#if view.mog}{@html view.sceneHtml}{/if}</div>
  </div><footer><span class="orst">{view.status}</span><span class="sp"></span><span class="orrate" id="orrate">{view.rate}</span>{#if view.mog}<button class="btn ghost" data-moglines>{view.mogBtn}</button>{/if}<button class="btn ghost" data-orhide>{t('orHide')}</button><button class="btn" data-optstop>{t('optStop')}</button></footer>{/if}</div>
{/if}
