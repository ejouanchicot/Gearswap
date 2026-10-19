<!--
  GearSwap Atelier · the menu of a slot of the sets' grid (slotmenus.svelte.ts): the slot and its piece, then a button a
  choice.

  @file    atelier/src/screens/dialogs/SlotMenu.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {slotMenuState} from './slotmenus.svelte';

  const v = $derived(slotMenuState.view);
</script>

{#if v}<header><b>{v.title}</b><span>{v.piece}</span></header>{#each v.items as it (it.act)}<button data-slotact={it.act} data-card={v.ci} data-slot={v.slot}>{it.label}{#if it.hint}<small>{it.hint}</small>{/if}</button>{/each}{/if}
