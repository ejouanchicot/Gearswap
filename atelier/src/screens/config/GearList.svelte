<!--
  GearSwap Atelier · every piece of equipment of the game, offered while a piece's name is typed (#mrgear, the page's
  gear catalog: the old page's mrGearList, module_rows.js); nothing before the catalog is read.

  @file    atelier/src/screens/config/GearList.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  const names = $derived.by(() => { const c = typeof catalog === 'function' && catalog(); return c ? Object.keys(c.id) : null; });
</script>

{#if names}<datalist id="mrgear">{#each names as n (n)}<option value={n}></option>{/each}</datalist>{/if}
