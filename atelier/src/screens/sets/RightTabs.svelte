<!--
  GearSwap Atelier · the tabs on top of the Sets screen's right column (rtabs.ts): the set's stats, then the
  optimizer's detail and its search settings, each a click away (events.js data-rtab).

  @file    atelier/src/screens/sets/RightTabs.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {RightTabs} from './rtabs';

  let {r}: {r: RightTabs} = $props();
</script>

<div class="opviews rtabs" role="tablist">{#each r.tabs as x (x.id)}<button role="tab" aria-selected={x.selected} data-rtab={x.id} title={x.tip || undefined}><b>{x.label}{#if x.on}<small class="opon">{x.on}</small>{/if}</b>{#if x.sub}<span>{x.sub}</span>{/if}</button>{/each}</div>
