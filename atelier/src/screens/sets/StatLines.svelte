<!--
  GearSwap Atelier · the lines of a stats list (statlines.ts): a row, or a stat the game caps with its gauge.

  @file    atelier/src/screens/sets/StatLines.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {Line} from './statlines';

  let {lines}: {lines: Line[]} = $props();
</script>

{#each lines as x, i (i)}{#if x.k === 'row'}<li class={x.cls} title={x.title}><span>{@html x.labelHtml}</span><b>{@html x.valueHtml}</b><i>{@html x.extraHtml}</i></li>{:else}<li class="capli {x.full ? 'full' : ''}" title={x.title}><span>{@html x.labelHtml}</span><b>{x.value}</b><i>{#if x.capmax}<em class="capmax">{@html x.capmax}</em>{:else}{x.capOf}{/if}</i><u class="gauge" style="--fill:{x.fill}%"></u>{#if x.overl}<em class="overl">{x.overl}</em>{/if}</li>{/if}{/each}
