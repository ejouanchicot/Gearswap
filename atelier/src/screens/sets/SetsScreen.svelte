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
  import Card from './Card.svelte';
  import Figures from './Figures.svelte';

  const view = $derived(legacy.version > 0 ? setsView() : null);
</script>

{#if view}
  <div class="pane split">{@html view.ctxHtml}<div class="setsx" class:ui2={view.ui2} style={view.listW ? `--listw:${view.listW}px` : undefined}><SetList view={view.list} />{#if view.card}{#if view.card.k === 'page'}{@html view.card.html}{:else}<Card view={view.card} />{/if}{/if}{#if view.figures !== null}<aside class="globalcol"><Figures view={view.figures} /></aside>{/if}</div></div>
{/if}
