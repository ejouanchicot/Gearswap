<!--
  GearSwap Atelier · a set's stats sheet (sheet.ts): its head with the stats filter, every group of stats in a box of
  its own (two columns when the pane is wide enough), what only applies sometimes last, the notes.

  @file    atelier/src/screens/sets/Sheet.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {SheetView, SheetGroup} from './sheet';
  import StatLines from './StatLines.svelte';

  // tabbed: shown in the figures' Stats du set tab (Figures.svelte), which names it: no title of its own
  let {view, tabbed = false}: {view: SheetView; tabbed?: boolean} = $props();
  // two columns of boxes, each box to the shorter one by its lines (no hole under a short box); side by side when the
  // pane is wide enough, one under the other otherwise (sets.css .sgcol)
  const cols = $derived.by(() => { const a: SheetGroup[] = [], b: SheetGroup[] = []; let ha = 0, hb = 0;
    for (const g of view.groups) { const n = 2 + (g.body.k === 'lines' ? g.body.lines.length : g.body.items.length);
      if (ha <= hb) { a.push(g); ha += n; } else { b.push(g); hb += n; } }
    return [a, b]; });
</script>

{#snippet group(g: SheetGroup)}<section class="box sgroup sg-{g.key}"><header class="boxh" title={g.title}><h3>{g.label}</h3><span class="meta">{g.body.k === 'lines' ? g.body.lines.length : g.body.items.length}</span></header><div class="boxb">{#if g.body.k === 'lines'}<ul class="statlist"><StatLines lines={g.body.lines} /></ul>{:else}<ul class="condlist">{#each g.body.items as c, i (i)}<li><b>{c.piece}</b><span>{c.text}</span></li>{/each}</ul>{/if}</div></section>{/snippet}
<div class="setstats"><div class="sshead">{#if !tabbed}<span class="kicker">{@html view.kickerHtml}</span>{/if}{@html view.pickHtml}</div><div class="sgroups">{#each cols as col, i (i)}<div class="sgcol">{#each col as g (g.key)}{@render group(g)}{/each}</div>{/each}</div>{#if view.cond}<div class="sgcond">{@render group(view.cond)}</div>{/if}{#each view.notesHtml as n, i (i)}<p>{@html n}</p>{/each}</div>
