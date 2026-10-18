<!--
  GearSwap Atelier · the panel of the party member chosen in Buffs & target (panel.ts): its sections on one or two
  columns, a line a setting. The controls keep the attributes the old page's handlers read (events.js, buffs.js,
  party_builder.js pbClick).

  @file    atelier/src/screens/combat/Panel.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {PanelView, Block, Item, Control, Effect} from './panel';

  let {view}: {view: PanelView} = $props();
</script>

{#snippet control(c: Control)}{#if c.k === 'select'}<select class={c.cls} {...c.attrs} title={c.title}>{#each c.options as o, i (i)}<option value={o.value} selected={o.selected}>{o.label}</option>{/each}</select>{:else if c.k === 'pick'}<button class="pbpick {c.set ? 'set' : ''}" data-pbpick={c.key} title={c.title}><span>{c.label}</span><i>▾</i></button>{:else if c.k === 'switch'}<button class="tgl pbsw" {...c.attrs} aria-pressed={c.on} title={c.title}></button>{:else if c.k === 'note'}<span class="muted small">{c.text}</span>{:else}{@html c.html}{/if}{/snippet}
{#snippet effect(e: Effect)}{#if e.k === 'gives'}{#each e.list as g, i (i)}<span class={g.neg ? 'pneg' : undefined}>{g.text}</span>{/each}{:else if e.k === 'muted'}<span class="muted">{e.text}</span>{:else if e.k === 'fx'}<span class="pbfx">{#each e.controls as c, i (i)}{@render control(c)}{/each}</span>{:else}{@html e.html}{/if}{/snippet}
{#snippet item(it: Item)}{#if it.k === 'row'}<div class="pbf"><span class="pbfl">{it.label}</span><div class="pbfc">{#each it.controls as c, i (i)}{@render control(c)}{/each}</div><div class="pbfe">{#each it.effects as e, i (i)}{@render effect(e)}{/each}</div></div>{:else if it.k === 'extra'}<div class="pbfextra"><span class="pbfl">{it.label}</span><div class="pbfxc">{@html it.html}</div></div>{:else}{@html it.html}{/if}{/snippet}
{#snippet column(blocks: Block[])}{#each blocks as bl, i (i)}{#if bl.k === 'section'}<section class="pbfsec"><h4>{bl.title}</h4>{#each bl.items as it, j (j)}{@render item(it)}{/each}</section>{:else}<div class="pbfextra">{@html bl.html}</div>{/if}{/each}{/snippet}

<div class="pbform {view.right.length ? '' : 'one'}"><div>{@render column(view.left)}</div>{#if view.right.length}<div>{@render column(view.right)}</div>{/if}</div>
