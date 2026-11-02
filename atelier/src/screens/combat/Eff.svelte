<!--
  GearSwap Atelier · what a setting of Buffs & target gives (panel.ts Effect): its gains (a cut or the target's in red),
  a muted word, settings of its own, or the old page's HTML.

  @file    atelier/src/screens/combat/Eff.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import Ctl from './Ctl.svelte';
  import type {Effect} from './panel';

  let {e}: {e: Effect} = $props();
</script>

{#if e.k === 'gives'}{#each e.list as g, i (i)}<span class={g.neg ? 'pneg' : undefined}>{g.text}</span>{/each}{:else if e.k === 'muted'}<span class="muted">{e.text}</span>{:else if e.k === 'fx'}<span class="pbfx">{#each e.controls as c, i (i)}<Ctl {c} />{/each}</span>{:else}{@html e.html}{/if}
