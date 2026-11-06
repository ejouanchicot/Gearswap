<!--
  GearSwap Atelier · the stats optimizer in the column beside the set (optpage.ts optPageView, statpage.ts): the set's
  card stays in sight and shows the pieces found as a trial (notes/docs-perso/page-sets-2026-11-01/SPEC.md). Its head
  (the set, the close button: data-optback), the search's buttons, what is looked for (the objectives folded but the
  first), the result reduced to the lines that matter. The trial's bar is the card's.

  @file    atelier/src/screens/optimizer/OptColumn.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import StatPage from './StatPage.svelte';
  import type {OptPageView} from './optpage';

  let {view}: {view: OptPageView} = $props();
  // once pieces are tried (a search done), its result first, right under the buttons; what is looked for after it
  const tried = $derived(!!view.statResult && view.statResult.heads.length > 1);
  // what is looked for (objectives, floors, search), folded behind one line (data-fold="optset"): the buttons and the
  // result are what most come for. Read from the view, made again at each redraw (S itself is not reactive: a value
  // read from it here would never change)
  const setOpen = $derived(view.settingsOpen);
</script>

<section class="optcolumn" class:simple={view.simple}><header class="optchead boxh panehead"><h3 class="display">{view.head.title}</h3><span class="opset">{view.head.set}</span><span class="muted small">{view.head.ctx}</span><span class="sp"></span><button class="btn ghost" data-optback title={view.head.backTitle}>✕</button></header><div class="opgo">{@html view.head.goHtml}</div>{#if view.noEngine !== null}<p class="tpnote">{view.noEngine}</p>{:else}<div class="optcbody">{#if view.statResult && (!view.simple || tried)}<StatPage result={view.statResult} compact={true} />{/if}{#if view.statWhat}<button class="wline" data-fold="optset" aria-expanded={setOpen}><b>{view.settings}</b> <span class="wcaret">{setOpen ? '▾' : '▸'}</span></button>{#if setOpen}<StatPage what={view.statWhat} compact={true} />{/if}{/if}</div>{/if}</section>
