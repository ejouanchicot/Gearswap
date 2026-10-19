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
  import Situations from '../profiles/Situations.svelte';
  import Picker from '../profiles/Picker.svelte';
  import OptPage from '../optimizer/OptPage.svelte';

  const view = $derived(legacy.version > 0 ? setsView() : null);
</script>

{#if view}
  {@const c = view.ctx}
  <div class="pane split"><div class="ctxbar"><span class="ctxwhat" title={c.title}><span class="muted small">{c.label}</span></span><Situations list={c.sits} big={false} /><Picker view={c.picker} /><span class="ctxwhat" title={c.title}>· {c.enemy}</span> <button class="linkbtn" data-section="combat" title={c.edit.title}>{c.edit.label}</button>{#if c.warn}<p class="kwarn subwarn"><span title={c.warn.text}>{c.warn.text}</span> <button class="btn" data-subfix={c.warn.sub}>{c.warn.fix}</button></p>{/if}</div><div class="setsx" class:ui2={view.ui2} style={view.listW ? `--listw:${view.listW}px` : undefined}><SetList view={view.list} />{#if view.card}{#if view.card.k === 'page'}<OptPage view={view.card.view} />{:else}<Card view={view.card} />{/if}{/if}{#if view.figures !== null}<aside class="globalcol"><Figures view={view.figures} /></aside>{/if}</div></div>
{/if}
