<!--
  GearSwap Atelier · the Macro book & lockstyle part of the job's settings (macro.ts). The alt's buttons keep the
  attribute the old page's handler reads (events.js data-macroalt).

  @file    atelier/src/screens/config/Macro.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import Box from '../../components/Box.svelte';
  import type {MacroView, MacroHead, MacroTable} from './macro';

  let {view}: {view: MacroView} = $props();
</script>

{#snippet head(h: MacroHead)}<div class="bighead"><span class="big">{@html h.bigHtml}</span><p>{@html h.lineHtml}</p></div>{/snippet}
{#snippet tables(list: MacroTable[])}{#each list as tb, i (i)}<div class="subh">{tb.title}</div><table class="tbl in"><tbody>{#each tb.rows as r (r.key)}<tr><td class="sub">{r.key}</td><td>{@html r.cellHtml}</td></tr>{/each}</tbody></table>{/each}{/snippet}

<div class="keybar"><span>{@html view.hintHtml}</span></div>
<div class="boxgrid cols">
  <Box cls="g-tank" title={view.book.title}>{#if view.book.alts}<div class="variants" role="group"><span class="simtplbl">{@html view.book.alts.labelHtml}</span>{#each view.book.alts.options as o (o.value)}<button data-macroalt={o.value} aria-pressed={o.pressed} title={view.book.alts.title}>{o.label}</button>{/each}</div>{/if}{@render head(view.book.head)}{@render tables(view.book.tables)}</Box>
  <Box cls="g-buff" title={view.style.title}>{@render head(view.style.head)}{@render tables(view.style.tables)}</Box>
</div>
