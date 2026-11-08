<!--
  GearSwap Atelier · "Tout optimiser" (optsets.ts), in the search window's dress: the start window (its head with the job,
  its count of sets and the time; the bar "Choose" with the shortcuts and starting from scratch; the families on the left,
  a tick each and "ticked / total", the ▶ on the one shown; its sets on the right by their game name, their versions in
  whole words; the foot with the count and ▶ Start), then the summary of the run (a line a set, ticked when worth
  writing).

  @file    atelier/src/screens/dialogs/OptSets.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {OptSetsView} from './optsets';

  let {view}: {view: OptSetsView} = $props();
</script>

<div class="scrim" data-close></div><div class="dialog optrun finished osdlg" class:osstart={!view.finished} role="dialog" aria-label={view.title}>
{#if !view.finished}
  {@const h = view.head}{@const o = view.open}
  <header class="oshead"><span class="kicker">{h.kicker}</span><h3>{h.title}</h3><span class="ostime">{h.about + ' '}<b>{h.time}</b></span></header>
  <div class="osbar"><small>{view.choose}</small><div class="osseg" role="group" aria-label={view.choose}>{#each view.shortcuts as c (c.key)}<button data-osonly={c.key} aria-pressed={c.on}>{c.label}</button>{/each}</div><button class="osswitch" role="switch" data-osscratch aria-checked={view.scratch.on}><i aria-hidden="true"></i><span>{view.scratch.label}</span><em>{view.scratch.why}</em></button></div>
  <div class="body osbody osmain"><nav class="osfams">{#each view.fams as f (f.fam)}<div class="osfamrow" aria-current={f.open}><button class="osck {f.tick}" data-osfam={f.fam} aria-label={f.label} aria-pressed={f.tick === 'on'}></button><button class="osfamname" data-osfamopen={f.fam}><b>{f.label}</b><small>{f.n + '/' + f.total}</small></button></div>{/each}</nav><section class="ossets">{#if o}<h4><span>{o.label}</span><button class="linkbtn" data-osfamall="on">{o.all}</button><button class="linkbtn" data-osfamall="off">{o.none}</button></h4>{#each o.rows as r (r.key)}<div class="osrow"><button class="osrowname" data-osrow={r.key} title={o.rowTip}><i class="osck {r.tick}" aria-hidden="true"></i><b>{r.name}</b></button><span class="osvers">{#each r.vers as v (v.path)}<button data-osset={v.path} aria-pressed={v.on} title={o.verTip}>{v.label}</button>{/each}</span></div>{/each}{/if}</section></div>
  <footer><button class="btn ghost" data-close>{view.close}</button><span class="sp"></span><small class="osfoot">{view.foot}</small>{#if view.go}<button class="btn osgo" data-osgo title={view.mine}>{view.go}</button>{/if}</footer>
{:else}
  <header><div class="orhead"><div><div class="kicker">{view.title}</div><h3>{view.sub}</h3></div></div></header>
  <div class="body osbody">
    {#if view.writing}<p class="oswriting">{view.writing}</p>{/if}
    <div class="oascroll"><table class="cmptbl oatbl ostbl"><thead><tr>{#each view.heads as h, i (i)}<th>{h}</th>{/each}</tr></thead><tbody>{#each view.rows as r (r.path)}<tr class={r.cls}><th>{#if r.tick !== null}<button class="chip" data-ossel={r.path} aria-pressed={r.tick}>{r.tick ? '✓' : '·'}</button>{' '}{/if}{r.label}</th>{#if r.obj}<td>{r.obj}</td><td>{r.vs}</td><td>{r.gain}</td><td>{r.n}</td>{:else}<td colspan="4" class="muted">{r.note}</td>{/if}</tr>{#if r.obj && r.note}<tr class="{r.cls} osnote"><th></th><td colspan="4" class="muted small">{r.note}</td></tr>{/if}{/each}</tbody></table></div>
    {#if view.noLive}<p class="kwarn">{view.noLive}</p>{/if}
  </div>
  <footer><button class="btn ghost" data-close>{view.close}</button>{#if view.undo}<button class="btn ghost" data-osundo>{view.undo}</button>{/if}<span class="sp"></span>{#if view.write}<button class="btn" data-oswrite>{view.write}</button>{/if}</footer>
{/if}
</div>
