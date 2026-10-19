<!--
  GearSwap Atelier · Compare's body (compare.ts): the pieces that differ, the figures the set is after, the other
  stats folded. The buttons keep the attributes the old page's handlers read (events.js).

  @file    atelier/src/screens/dialogs/Compare.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {CompareView, CmpRow} from './compare';

  let {view}: {view: CompareView} = $props();
</script>

{#snippet head()}<tr><th></th>{#each view.head as c, i (i)}<th>{c.label}{#if c.kept !== null}<span class="keptacts"><button class="linkbtn" data-keptload={c.kept}>{@html view.keptLoadHtml}</button><button class="linkbtn" data-keptdel={c.kept} aria-label={view.keptDel}>×</button></span>{/if}</th>{/each}</tr>{/snippet}
{#snippet row(r: CmpRow)}<tr class={r.cls}><th title={r.title}>{@html r.labelHtml}</th>{#each r.cells as c, i (i)}<td class="{c.best ? 'best' : ''} {c.short ? 'short' : ''}">{c.text + (c.over ? ' ' : '')}{#if c.over}<span class="overl">{c.over}</span>{/if}{#if c.dv}<i class="dv {c.dv.up ? 'up' : 'down'}">{c.dv.text}</i>{/if}{#if c.small}<small>{c.small}</small>{/if}</td>{/each}</tr>{/snippet}

{#if view.sameHtml !== null}<p class="muted">{@html view.sameHtml}</p>{:else}<p class="muted small">{@html view.whyHtml}</p><div class="cmpgrid {view.two ? 'two' : ''}">{#if view.pieces}<section><div class="kicker">{@html view.pieces.titleHtml}</div><table class="cmptbl"><thead>{@render head()}</thead><tbody>{#each view.pieces.rows as pr, i (i)}<tr><th>{@html pr.slotHtml}</th>{#each pr.cells as c, j (j)}<td class={c.chg ? 'chg' : ''}>{#if c.piece}{c.piece.name + (c.piece.rank !== null || c.piece.max ? ' ' : '')}{#if c.piece.rank !== null}<span class="rk">R{c.piece.rank}</span>{#if c.piece.max}{' '}{/if}{/if}{#if c.piece.max}<span class="rk">max</span>{/if}{#if c.piece.augs}<small>{c.piece.augs}</small>{/if}{:else}—{/if}</td>{/each}</tr>{/each}</tbody></table></section>{/if}{#if view.figures}{@const f = view.figures}<section><div class="kicker">{@html f.titleHtml}</div><table class="cmptbl"><thead>{@render head()}</thead><tbody>{#each f.want as r, i (i)}{@render row(r)}{/each}{#if f.more}<tr class="sec"><td colspan={f.more.colspan}><button class="linkbtn foldbtn" data-cmpmore>{@html f.more.labelHtml}</button></td></tr>{#if f.more.open}{#each f.more.rows as r, i (i)}{@render row(r)}{/each}{/if}{/if}</tbody></table></section>{/if}</div>{/if}
