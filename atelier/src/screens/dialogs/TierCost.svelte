<!--
  GearSwap Atelier · "By party"'s body (tiercost.ts): a row a version of the set, a column a situation.

  @file    atelier/src/screens/dialogs/TierCost.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {TierCostView} from './tiercost';

  let {view}: {view: TierCostView} = $props();
</script>

<p class="muted small">{@html view.whyHtml}</p><table class="cmptbl tctbl"><thead><tr><th>{@html view.setHtml}</th>{#each view.tiers as x (x)}<th>{x}</th>{/each}</tr></thead><tbody>{#each view.rows as r, i (i)}<tr><th>{r.label}</th>{#each r.cells as c, j (j)}{#if c}<td class="{c.best ? 'best' : ''} {c.worn ? 'worn' : ''}">{c.text}{#if c.loss}<i class="dv down">{c.loss}</i>{/if}</td>{:else}<td>—</td>{/if}{/each}</tr>{/each}</tbody></table><ul class="tclist">{#each view.lines as l, i (i)}<li class={l.warn ? 'kwarn' : undefined}>{@html l.html}</li>{/each}</ul><p class="muted small">{@html view.howHtml}</p>
