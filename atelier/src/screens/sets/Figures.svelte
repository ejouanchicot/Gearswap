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

<div class="globals"><h3 class="ui2title">{view.title}</h3><div class="ui2own">{#each view.boxes as b (b.key)}<StatBox box={b} />{/each}{@html view.afterHtml}</div>{@html view.sheetHtml}<details class="lgfold ui2all" data-ui2all open={view.all.open}><summary title={view.all.title}>{view.all.label}</summary>{@html view.all.html}</details></div>
