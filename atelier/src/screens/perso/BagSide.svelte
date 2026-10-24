<!--
  GearSwap Atelier · the bags on the left of My character > Bags (bags.ts), in place of the played jobs: every bags
  and the plan first, then the bags on the character, in the Mog House and stored elsewhere, one line each (how full,
  what it is for, how many things are misplaced in it). A click shows the bag in the middle (bags_view.js data-bagsel).

  @file    atelier/src/screens/perso/BagSide.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {BagsView, BagTile} from './bags';

  let {view}: {view: BagsView} = $props();
</script>

{#snippet tile(b: BagTile)}<button class="bvtile {b.cls}" data-bagsel={b.name} aria-pressed={b.pressed} title={b.title}><b>{b.name}</b>{#if b.kind === 'bag'}<span class="bvnum">{b.used}<i>/{b.max}</i></span><span class="bvbar"><i style="width:{b.pct}%"></i></span>{:else}<span class="bvnum">{b.used}</span><span class="bvbar"></span>{/if}<small class="bvrole" title={b.role.title}><span>{b.role.short}</span>{#if b.role.bad}<i title={b.role.bad.title}>{b.role.bad.n}</i>{/if}</small></button>{/snippet}

<aside class="setlist joblist bagside"><div class="scroll"><div class="bvtop"><div class="bvgroup"><div class="bvtiles"><button class="bvtile all" data-bagsel="all" aria-pressed={view.all.pressed} title={view.all.title}><b>{view.all.label}</b><span class="bvnum">{view.all.total}<i>/{view.all.room}</i></span><span class="bvbar"><i style="width:{view.all.pct}%"></i></span><small class="bvrole">{view.all.sub}</small></button><button class="bvtile plan" data-bagsel="plan" aria-pressed={view.plan.pressed} title={view.plan.title}><b>{view.plan.label}</b><span class="bvnum"></span><span class="bvbar"></span><small class="bvrole">{view.plan.sub}</small></button></div></div>{#each view.groups as g (g.place)}<div class="bvgroup {g.place} {g.state}"><h4><span>{g.title}</span>{#if g.mark}<em title={g.mark.title}>{g.mark.text}</em>{/if}</h4><div class="bvtiles">{#each g.tiles as b (b.name)}{@render tile(b)}{/each}</div></div>{/each}</div></div></aside>
