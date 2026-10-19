<!--
  GearSwap Atelier · the character's figures with a set (globals.ts): folded boxes and the measure's note under a
  set's figures (fold: true), or the three open cards of My character. A box's band keeps data-fold (events.js).

  @file    atelier/src/screens/sets/Globals.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {GlobalsView} from './globals';
  import StatLines from './StatLines.svelte';

  let {view, fold}: {view: GlobalsView; fold: boolean} = $props();
</script>

{#if view.noChar}<div class="globals"><section class="box g-you"><header class="boxh"><h3>{@html view.youTitle}</h3></header><div class="boxb"><p class="muted">{@html view.noChar}</p></div></section></div>{:else if fold}<div class="globals">{#each view.boxes as b (b.key)}<section class="box {b.cls}"><button class="boxh bufftoggle" data-fold={b.key} aria-expanded={b.open} title={view.foldTitle}><h3>{@html b.titleHtml}</h3><span class="meta">{b.count || ''}</span></button>{#if b.open}<div class="boxb">{#if b.lead}<p class="vsset">{@html b.lead}</p>{/if}<ul class={b.big ? 'statlist big' : 'statlist'}><StatLines lines={b.lines} /></ul></div>{/if}</section>{/each}<p class="note-m">{@html view.noteHtml}</p></div>{:else}{#each view.boxes as b (b.key)}<section class="box {b.cls}"><header class="boxh"><h3>{@html b.titleHtml}</h3></header><div class="boxb"><ul class={b.big ? 'statlist big' : 'statlist'}><StatLines lines={b.lines} /></ul></div></section>{/each}{/if}
