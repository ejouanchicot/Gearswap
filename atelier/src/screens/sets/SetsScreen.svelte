<!--
  GearSwap Atelier · the Sets screen (sets.ts): the line over it, the list of sets (SetList), the set shown and its
  figures. The list's width is the player's (S.listW, dragged by the list's grip: list_prefs.js).

  @file    atelier/src/screens/sets/SetsScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';
  import {setsView} from './sets';
  import SetList from './SetList.svelte';

  const view = $derived(legacy.version > 0 ? setsView() : null);
</script>

{#if view}
  <div class="pane split">{@html view.ctxHtml}<div class="setsx" class:ui2={view.ui2} style={view.listW ? `--listw:${view.listW}px` : undefined}><SetList view={view.list} />{@html view.cardHtml}{#if view.globalsHtml !== null}<aside class="globalcol">{@html view.globalsHtml}</aside>{/if}</div></div>
{/if}
