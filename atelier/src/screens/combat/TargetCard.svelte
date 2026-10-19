<!--
  GearSwap Atelier · the target's card (targetcard.ts).

  @file    atelier/src/screens/combat/TargetCard.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {TargetCardView} from './targetcard';

  let {view}: {view: TargetCardView} = $props();
</script>

<div class="tgcard"><div class="tgtop"><div class="tgname"><b>{view.name}</b><span class="muted small" title={view.factsTitle}>{view.facts}</span></div>{#if 'p' in view.hit}<div class="tghit {view.hit.tone}" title={view.hit.title}><span>{view.hit.label}</span><b>{view.hit.p + ' %'}</b></div>{:else}<div class="tghit none"><span class="muted small">{view.hit.none}</span></div>{/if}</div>{#each view.gauges as g, i (i)}<div class="tggauge" title={g.tip}><span>{g.label}</span><b>{g.a + (g.z !== g.a ? ' ' : '')}{#if g.z !== g.a}<i>→</i> <em>{g.z}</em>{/if}</b><u style="--left:{g.left}"></u></div>{/each}<div class="tgmore">{#if view.vit}<span>VIT <b>{view.vit}</b></span>{/if}{#if view.hp}<span>HP <b>{view.hp}</b></span>{/if}</div>{#if view.res}<div class="tgres" title={view.res.title}>{#each view.res.items as r, i (i)}<span class={r.bad ? 'bad' : 'good'}>{r.text}</span>{:else}<span class="muted">{view.res.none}</span>{/each}</div>{/if}{#if view.est}<p class="muted small tgest">{view.est}</p>{/if}<button class="btn tgchange" data-tgtpick title={view.change.title}>{view.change.label}</button></div>
