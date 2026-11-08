<!--
  GearSwap Atelier · the Sets screen (sets.ts): the list of sets (SetList), the set shown and its figures (what they are
  worked out with recalled at their head, the subjob's warning under the set's title). The list's width is the player's (S.listW, dragged by the list's grip: list_prefs.js).

  @file    atelier/src/screens/sets/SetsScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';
  import {setsView} from './sets';
  import SetList from './SetList.svelte';
  import Card from './Card.svelte';
  import Figures from './Figures.svelte';
  import OptPage from '../optimizer/OptPage.svelte';
  import OptColumn from '../optimizer/OptColumn.svelte';

  const view = $derived(legacy.version > 0 ? setsView() : null);
</script>

{#if view}
  <div class="pane split"><div class="setsx ui2" style={view.listW ? `--listw:${view.listW}px` : undefined}><SetList view={view.list} />{#if view.card}{#if view.card.k === 'page'}<OptPage view={view.card.view} />{:else}<Card view={view.card} ctx={view.ctx} />{/if}{/if}{#if view.card && view.card.k === 'card' && view.card.opt}<aside class="globalcol optcol box">{#if view.card.opt.what}<OptPage view={view.card.opt} />{:else}<OptColumn view={view.card.opt} />{/if}</aside>{:else if view.figures !== null}<aside class="globalcol box"><Figures view={view.figures} ctx={view.ctx} /></aside>{/if}</div></div>
{/if}
