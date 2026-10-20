<!--
  GearSwap Atelier · a state's name as the game names it (MainWeapon, StanceWeapon), breakable between its words
  only: a label too long for its column goes on two lines as "Stance / Weapon", never "StanceWeapo / n".

  @file    atelier/src/components/StateName.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  let {name}: {name: string} = $props();
  const parts = $derived(name.split(/(?=[A-Z][a-z])/));
</script>

{#each parts as p, i (i)}{#if i}<wbr>{/if}{p}{/each}
