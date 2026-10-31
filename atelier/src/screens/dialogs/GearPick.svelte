<!--
  GearSwap Atelier · the pieces' window of a slot (gearpick.ts): its filters, the pieces as cards. The search field
  hides the cards in place (events.js #drawq: the window is drawn anew at each filter, never while typing).

  @file    atelier/src/screens/dialogs/GearPick.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {selSync} from '../../components/selsync';
  import type {GearPickView, GpOption} from './gearpick';

  let {view}: {view: GearPickView} = $props();
</script>

{#snippet menu(name: string, list: GpOption[])}<select class="buffsel gpsel" data-gpsel={name} use:selSync={(list.find(o => o.selected) || {k: undefined}).k}>{#each list as o (o.k)}<option value={o.k} selected={o.selected}>{o.label}</option>{/each}</select>{/snippet}

<div class="gpgrid"><aside class="gpside"><input id="drawq" class="gpq" type="search" placeholder={view.qPh} autocomplete="off" spellcheck="false"><h4>{view.fromLabel}</h4><div class="gpseg" role="group">{#each view.src as x (x.k)}<button data-gpsrc={x.k} aria-pressed={x.pressed}>{x.label}</button>{/each}</div><h4>{view.sortLabel}</h4>{@render menu('sort', view.sorts)}{#if view.kinds}<h4>{view.kinds.label}</h4>{@render menu('kind', view.kinds.options)}{/if}<h4>{view.fxLabel}</h4>{@render menu('fx', view.fxs)}{#if view.junk}<label class="chk gpjunk"><input type="checkbox" data-gpjunk checked={view.junk.checked}> {view.junk.label}</label>{/if}{#if view.emptyHtml !== null}<button class="btn ghost" data-tryempty>{@html view.emptyHtml}</button>{/if}</aside><section class="gpmain"><div class="gphead"><span class="muted small">{view.count}</span>{#if view.wantsHtml}<p class="gpwants small">{@html view.wantsHtml}</p>{/if}</div><div class="choice gplist">{#each view.items as x (x.i)}<button type="button" class="gpcard {x.orig ? 'orig' : ''} {x.cur ? 'cur' : ''} {x.junk ? 'junk' : ''}" data-try={x.i} hidden={x.hide} data-junkhid={x.hide ? '' : undefined}>{@html x.iconHtml}<span class="gpinfo"><span class="gpname"><b>{x.name}</b>{#if x.rank !== null}<span class="rk">R{x.rank}</span>{/if}{@html x.tagHtml}{#if x.up}<span class="tag up {x.up.on ? 'on' : ''}" data-trymax={x.i} role="button" tabindex="0" title={x.up.title}>{x.up.text}</span>{/if}</span>{#if x.augs}<span class="augl">◆ {x.augs}</span>{/if}{#if x.fit}<span class="fitl">{x.fit}</span>{:else if x.why}<span class="whyl">{x.why}</span>{/if}<small>{x.where}</small></span>{#if x.val}<span class="gpval"><b>{x.val.text}</b>{#if x.val.gap}<small class={x.val.gap.cls}>{x.val.gap.text}</small>{/if}</span>{/if}</button>{/each}{#if !view.items.some(x => !x.hide)}<p class="muted">{view.none}</p>{/if}</div></section></div>
