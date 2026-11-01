<!--
  GearSwap Atelier · "Tout optimiser" (optsets.ts): the start window (the sets by family, ticks, the time it should take),
  then the summary of the run (a line a set, ticked when worth writing), in the search window's dress.

  @file    atelier/src/screens/dialogs/OptSets.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {OptSetsView} from './optsets';

  let {view}: {view: OptSetsView} = $props();
</script>

<div class="scrim" data-close></div><div class="dialog optrun finished osdlg" role="dialog" aria-label={view.title}><header><div class="orhead"><div><div class="kicker">{view.title}</div><h3>{view.sub}</h3></div></div></header>
<div class="body osbody">
{#if !view.finished}
  <div class="osshort">{#each view.shortcuts as c (c.key)}<button class="btn ghost" data-osonly={c.key}>{c.label}</button>{/each}<button class="osscratch" data-osscratch aria-pressed={view.scratch.on}><i>{view.scratch.on ? '✓' : ''}</i>{view.scratch.label}</button></div>
  <div class="osfams">{#each view.fams as f (f.fam)}<section class="osfam"><button class="osfamhead" data-osfam={f.fam} aria-pressed={f.all}><i>{f.all ? '✓' : ''}</i>{f.label}</button>{#each f.sets as x (x.path)}<button class="osset" data-osset={x.path} aria-pressed={x.on}><i>{x.on ? '✓' : ''}</i>{x.label}</button>{/each}</section>{/each}</div>
  <p class="muted small">{view.mine}</p>
{:else}
  {#if view.writing}<p class="oswriting">{view.writing}</p>{/if}
  <div class="oascroll"><table class="cmptbl oatbl ostbl"><thead><tr>{#each view.heads as h, i (i)}<th>{h}</th>{/each}</tr></thead><tbody>{#each view.rows as r (r.path)}<tr class={r.cls}><th>{#if r.tick !== null}<button class="chip" data-ossel={r.path} aria-pressed={r.tick}>{r.tick ? '✓' : '·'}</button>{' '}{/if}{r.label}</th>{#if r.obj}<td>{r.obj}</td><td>{r.vs}</td><td>{r.gain}</td><td>{r.n}</td>{:else}<td colspan="4" class="muted">{r.note}</td>{/if}</tr>{#if r.obj && r.note}<tr class="{r.cls} osnote"><th></th><td colspan="4" class="muted small">{r.note}</td></tr>{/if}{/each}</tbody></table></div>
  {#if view.noLive}<p class="kwarn">{view.noLive}</p>{/if}
{/if}
</div>
<footer><button class="btn ghost" data-close>{view.close}</button>{#if view.undo}<button class="btn ghost" data-osundo>{view.undo}</button>{/if}<span class="sp"></span>{#if !view.finished && view.go}<button class="btn" data-osgo>{view.go}</button>{/if}{#if view.write}<button class="btn" data-oswrite>{view.write}</button>{/if}</footer></div>
