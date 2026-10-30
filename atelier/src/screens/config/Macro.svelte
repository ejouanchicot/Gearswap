<!--
  GearSwap Atelier · the Macro book & lockstyle part of the job's settings (macro.ts), in the frame of the three parts (ProFrame.svelte). The alt's buttons keep the
  attribute the old page's handler reads (events.js data-macroalt).

  @file    atelier/src/screens/config/Macro.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import ProFrame from './ProFrame.svelte';
  import type {MacroView, MacroHead, MacroTable, MacroEdit} from './macro';

  let {view}: {view: MacroView} = $props();
</script>

{#snippet tables(list: MacroTable[])}{#each list as tb, i (i)}<div class="subh">{tb.title}</div><table class="tbl in"><tbody>{#each tb.rows as r (r.key)}<tr><td class="sub">{r.key}</td><td>{@html r.cellHtml}</td></tr>{/each}</tbody></table>{/each}{/snippet}

{#snippet edit(e: MacroEdit | null)}{#if e}
  {#if e.note}<p class="menote">{e.note}</p>{/if}
  {#if e.rows.length}<div class="mtiles">{#each e.rows as r (r.who)}<div class="mtile" class:cur={r.current} class:def={r.who === 'def'}>
    {#if r.current}<span class="mribbon">{view.nowText}</span>{/if}
    <header>{@html r.iconHtml}<b title={r.tip}>{r.label}</b>{#if r.del}<button type="button" class="medel" data-mdel={r.del} title={r.delTip} aria-label={r.delTip}>×</button>{/if}</header>
    {#each r.vals as v (v.field)}<div class="mstep"><small>{v.label}</small>
      <button type="button" data-mstep={v.field + '|-1'} disabled={e.ro} aria-label="−">−</button>
      <input type="number" min="1" max={v.max} value={v.value} data-mfield={v.field} disabled={e.ro}>
      <button type="button" data-mstep={v.field + '|1'} disabled={e.ro} aria-label="+">+</button></div>{/each}
  </div>{/each}
  {#if e.add}<label class="mtile madd"><span class="maddplus">+</span><select data-madd={e.add.attr}><option value="">{e.add.label}</option>{#each e.add.options as o (o)}<option value={o}>/{o}</option>{/each}</select></label>{/if}
  </div>{/if}
{/if}{/snippet}
{#snippet hero(icon: string, h: MacroHead)}<div class="mhero">{@html icon}<div><small>{view.nowText}</small><span class="mbig">{@html h.bigHtml}</span><p>{@html h.lineHtml}</p></div></div>{/snippet}

<ProFrame nav={view.pro.nav} head={view.pro.head} detail={view.pro.detail} foot={view.pro.foot} credit={view.credit}>
  {#if view.pro.part === 'book'}
    {#if view.book.alts}<div class="variants" role="group"><span class="simtplbl">{@html view.book.alts.labelHtml}</span>{#each view.book.alts.options as o (o.value)}<button data-macroalt={o.value} aria-pressed={o.pressed} title={view.book.alts.title}>{o.label}</button>{/each}</div>{/if}
    {@render hero(view.heroBook, view.book.head)}{@render edit(view.book.edit)}{@render tables(view.book.tables)}
  {:else}
    {@render hero(view.heroStyle, view.style.head)}{@render edit(view.style.edit)}{@render tables(view.style.tables)}
  {/if}
</ProFrame>
