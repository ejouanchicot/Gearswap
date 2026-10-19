<!--
  GearSwap Atelier · a block both optimizers share (blocks.ts): the limits' tiles, or the pieces the try changes.

  @file    atelier/src/screens/optimizer/OptBlocks.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {LimitsView, ChangesView} from './blocks';

  let {limits = null, changes = null}: {limits?: LimitsView | null; changes?: ChangesView | null} = $props();
</script>

{#if limits}<h3 class="ophd" title={limits.titleTip || undefined}>{limits.title}</h3><div class="oplimits {limits.many ? 'many' : ''}">{#each limits.tiles as x, i (i)}<label class="oplim" title={x.tip}><span class="oplimn">{x.name}</span><span class="oplimv">{#if x.sign}<i>{x.sign}</i>{/if}<input type="number" step="1" {...x.attr} value={x.value}></span></label>{/each}</div>{/if}{#if changes}<h4 class="ophd2">{@html changes.title}</h4><ul class="opchg">{#each changes.rows as r, i (i)}<li><span class="sl">{r.slot}</span><span>{r.from}</span><span class="to">{r.to}</span></li>{/each}</ul>{/if}
