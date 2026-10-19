<!--
  GearSwap Atelier · a block both optimizers share (blocks.ts): the limits' tiles, the search, or the pieces the try changes.

  @file    atelier/src/screens/optimizer/OptBlocks.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {selSync} from '../../components/selsync';
  import type {LimitsView, ChangesView, SearchView} from './blocks';

  let {limits = null, changes = null, search = null}: {limits?: LimitsView | null; changes?: ChangesView | null; search?: SearchView | null} = $props();
</script>

{#if limits}<h3 class="ophd" title={limits.titleTip || undefined}>{limits.title}</h3><div class="oplimits {limits.many ? 'many' : ''}">{#each limits.tiles as x, i (i)}<label class="oplim" title={x.tip}><span class="oplimn">{x.name}</span><span class="oplimv">{#if x.sign}<i>{x.sign}</i>{/if}<input type="number" step="1" {...x.attr} value={x.value}></span></label>{/each}</div>{/if}{#if changes}<h4 class="ophd2">{@html changes.title}</h4><ul class="opchg">{#each changes.rows as r, i (i)}<li><span class="sl">{r.slot}</span><span>{r.from}</span><span class="to">{r.to}</span></li>{/each}</ul>{/if}{#if search}{@const q = search}<h4 class="ophd2">{@html q.title}</h4><div class="seg optabs" role="group">{#each q.tabs as x (x.id)}<button data-optab={x.id} aria-pressed={x.pressed} title={x.tip}>{x.label}{#if x.on}<small class="opon">{x.on}</small>{/if}</button>{/each}</div><div class="optab">{#if q.menu}{@const m = q.menu}<div class="opsels"><span title={m.tip || undefined}>{m.label}</span><select class="buffsel" data-optopt={m.key} title={m.tip || undefined} use:selSync={(m.options.find(o => o.selected) || {value: undefined}).value}>{#each m.options as o (o.value)}<option value={o.value} selected={o.selected}>{o.label}</option>{/each}</select></div>{/if}<div class="opsws">{#each q.switches as x (x.k)}<label class="opsw {x.off ? 'off' : ''}" title={x.tip || undefined}><input type="checkbox" disabled={x.off} data-optopt={x.off ? undefined : x.k} checked={!x.off && x.checked}><span>{x.label}</span></label>{/each}</div>{#if q.special}<p class="muted small">{q.special}</p>{/if}{#if q.locks}<p class="oplocks">{q.locks.text + ' '}<button class="linkbtn" data-locksclear>{q.locks.clear}</button></p>{/if}{#if q.excl}<p class="oplocks">{q.excl.label + ' '}{#each q.excl.items as x, i (x.n)}{#if i}{' '}{/if}<button class="opexcl" data-unexclude={x.n} title={x.tip}>{x.n + ' ×'}</button>{/each}{#if q.excl.clear}{' '}<button class="linkbtn" data-exclclear>{q.excl.clear}</button>{/if}</p>{/if}</div>{/if}
