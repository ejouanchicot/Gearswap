<!--
  GearSwap Atelier · the figures of a set (figures.ts): its own figures in a block of fixed height (sets.css .ui2own),
  its stats sheet, every stat folded. A box folds by its band (events.js data-fold), every stat by its summary
  (data-ui2all).

  @file    atelier/src/screens/sets/Figures.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {FiguresView} from './figures';
  import StatBox from './StatBox.svelte';

  let {view}: {view: FiguresView} = $props();
</script>

<div class="globals"><h3 class="ui2title">{view.title}</h3><div class="ui2own">{#each view.boxes as b (b.key)}<StatBox box={b} />{/each}{#if view.hp}{@const h = view.hp}<section class="box g-tank"><button class="boxh bufftoggle" data-fold="hpcycle" aria-expanded={h.open} title={h.foldTitle}><h3>{@html h.title}</h3><span class="meta"></span></button>{#if h.open}<div class="boxb"><p class="note-m">{h.note}</p>{#if h.ref}<p class="note-m">{h.ref}</p>{/if}<table class="rdvs optable hpcycle"><thead><tr>{#each h.heads as x, i (i)}<th>{@html x}</th>{/each}</tr></thead><tbody>{#each h.rows as r, i (i)}<tr class={r.mine ? 'obj' : ''}><th title={r.names}>{r.label}</th><td>{r.a}</td><td>{r.b}</td><td class={r.cls}>{r.loss}</td></tr>{/each}</tbody></table></div>{/if}</section>{/if}{@html view.luopanHtml}</div>{@html view.sheetHtml}<details class="lgfold ui2all" data-ui2all open={view.all.open}><summary title={view.all.title}>{view.all.label}</summary>{@html view.all.html}</details></div>
