<!--
  GearSwap Atelier · what lowers the target (foe.ts): the jobs' tabs in two rows and the tab's switch, the tab's grid
  (each ability with what it takes off), then every debuff on the target.

  @file    atelier/src/screens/combat/FoePanel.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {selSync} from '../../components/selsync';
  import type {FoeView, FoeCtl, FoeChip} from './foe';

  let {view}: {view: FoeView} = $props();
</script>

{#snippet chip(c: FoeChip)}<button class="chip{c.over ? ' over' : ''}" {...c.attrs} aria-pressed={c.on} disabled={c.off} title={c.tip || undefined}>{c.label}</button>{/snippet}
{#snippet ctl(c: FoeCtl)}{#if c.k === 'chip'}{@render chip(c)}{:else if c.k === 'seg'}<span class="fseg">{#each c.chips as x, i (i)}{@render chip(x)}{/each}</span>{:else if c.k === 'select'}<select class="buffsel set" {...c.attrs} title={c.title || undefined} use:selSync={(c.options.find(o => o.selected) || {}).value}>{#each c.options as o, i (i)}<option value={o.value} selected={o.selected}>{o.label}</option>{/each}</select>{:else}<span class="fnote" title={c.text}>{c.text}</span>{/if}{/snippet}

<div class="foetabs ftab7"><div class="ftabs7" role="tablist">{#each view.tabs as x, i (i)}<button class="foetab {x.lit ? 'on' : ''}" role="tab" data-foetab={x.id} aria-selected={x.selected} title={x.title}>{x.label}</button>{/each}</div><span class="foetabsw"><button class="tgl" data-poff={view.sw.key} aria-pressed={view.sw.on} title={view.sw.tip} aria-label={view.sw.aria}></button></span></div><div class="ftabgrid {view.curOn ? '' : 'off'}">{#each view.cells as c, i (i)}<div class="fcell {c.wide}">{#if c.label}<span class="flbl">{c.label}</span>{/if}<div class="fctl">{#each c.ctls as x, j (j)}{@render ctl(x)}{/each}</div>{#if c.fx}<span class="ffx {c.fx.length && view.curOn ? 'on' : ''}" title={c.fx.join(' · ')}>{!view.curOn ? '' : c.fx.join(' · ') || '—'}</span>{/if}</div>{/each}</div><div class="kicker foeonk">{view.onTitle}</div>{#if view.on.length}<ul class="foeon">{#each view.on as e, i (i)}<li><span>{e.src}</span><b>{e.fx}</b></li>{/each}</ul>{:else}<p class="muted small foeonempty">{view.none}</p>{/if}
