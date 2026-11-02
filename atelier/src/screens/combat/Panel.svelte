<!--
  GearSwap Atelier · the panel of the party member chosen in Buffs & target (panel.ts): its sections on one or two
  columns, a line a setting (a setting: Ctl.svelte, what it gives: Eff.svelte). The controls keep the attributes the old page's handlers read (events.js, buffs.js,
  party_builder.js pbClick).

  @file    atelier/src/screens/combat/Panel.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {selSync} from '../../components/selsync';
  import Ctl from './Ctl.svelte';
  import Eff from './Eff.svelte';
  import type {PanelView, Block, Item, ExtraCtl} from './panel';

  let {view}: {view: PanelView} = $props();
</script>

{#snippet extraCtl(x: ExtraCtl)}{#if x.kind === 'warcry'}<span class="flbl">Savagery</span><span class="fseg">{#each [0, 1, 2, 3, 4, 5] as n (n)}<button class="chip" data-savagery={n} data-wparty={x.party ? '1' : undefined} aria-pressed={n === x.lv} disabled={!x.on}>{n}</button>{/each}</span><button class="chip" data-agoge data-wparty={x.party ? '1' : undefined} aria-pressed={x.agoge} disabled={!x.on}>Agoge Mask +3/+4</button><span class="muted small">{x.note}</span>{:else}<span class="flbl">{x.label}</span><select class="buffsel" data-buff="pSamba" use:selSync={(x.opts.find(o => o.on) || {v: ''}).v}>{#each x.opts as o (o.v)}<option value={o.v} selected={o.on}>{o.label}</option>{/each}</select>{/if}{/snippet}

{#snippet item(it: Item)}{#if it.k === 'row'}<div class="pbf"><span class="pbfl">{it.label}</span><div class="pbfc">{#each it.controls as c, i (i)}<Ctl {c} />{/each}</div><div class="pbfe">{#each it.effects as e, i (i)}<Eff {e} />{/each}</div></div>{:else if it.k === 'extra'}<div class="pbfextra"><span class="pbfl">{it.label}</span><div class="pbfxc">{@render extraCtl(it.ctl)}</div></div>{:else}<div class="pbf"><span class="pbfl">{it.label}</span><div class="pbfc"><div class="pbfam">{#each it.controls as c, i (i)}<Ctl {c} />{/each}</div></div><div class="pbfe"><span class="muted small amwho">{it.said}</span></div></div>{/if}{/snippet}
{#snippet column(blocks: Block[])}{#each blocks as bl, i (i)}{#if bl.k === 'section'}<section class="pbfsec"><h4>{bl.title}</h4>{#each bl.items as it, j (j)}{@render item(it)}{/each}</section>{:else}<div class="pbfextra">{@render extraCtl(bl.ctl)}</div>{/if}{/each}{/snippet}

<div class="pbform {view.right.length ? '' : 'one'}"><div>{@render column(view.left)}</div>{#if view.right.length}<div>{@render column(view.right)}</div>{/if}</div>
