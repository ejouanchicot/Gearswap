<!--
  GearSwap Atelier · a set's stats sheet (sheet.ts): its head with the stats filter, the tabs, the group shown, the
  notes.

  @file    atelier/src/screens/sets/Sheet.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {SheetView} from './sheet';
  import StatLines from './StatLines.svelte';

  let {view}: {view: SheetView} = $props();
</script>

<div class="setstats"><div class="sshead"><span class="kicker">{@html view.kickerHtml}</span>{@html view.pickHtml}</div><div class="stabs" role="tablist">{#each view.tabs as g (g.key)}<button role="tab" data-stattab={g.key} aria-selected={g.selected} title={g.title}>{g.label}<small>{g.n}</small></button>{/each}</div>{#if view.body}<div class="stabbody">{#if view.body.k === 'lines'}<ul class="statlist"><StatLines lines={view.body.lines} /></ul>{:else}<ul class="condlist">{#each view.body.items as c, i (i)}<li><b>{c.piece}</b><span>{c.text}</span></li>{/each}</ul>{/if}</div>{/if}{#each view.notesHtml as n, i (i)}<p>{@html n}</p>{/each}</div>
