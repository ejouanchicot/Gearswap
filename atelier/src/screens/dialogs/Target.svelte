<!--
  GearSwap Atelier · the target picker (target.ts): its own frame (a Back button in its head, no foot), the search,
  the order, the zones, the shortcuts, every monster. Typing and a zone redraw it in place (the field keeps its caret).

  @file    atelier/src/screens/dialogs/Target.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {selSync} from '../../components/selsync';
  import type {TargetView, TgCard} from './target';

  let {view}: {view: TargetView} = $props();
</script>

{#snippet card(c: TgCard, hide: boolean)}<div class="tgm {c.on ? 'on' : ''}" data-q={c.q} data-zone={c.zone} data-lv={c.lv} data-hit={c.hit} hidden={hide && c.hidden}><button class="ract tgstar" data-tgtfav={c.id} aria-pressed={c.fav} title={c.favTitle}>{c.fav ? '★' : '☆'}</button><div class="tgmh"><b>{c.name + (c.estTitle !== null ? ' ' : '')}{#if c.estTitle !== null}<i title={c.estTitle}>*</i>{/if}</b><span class="muted small">{c.sub}</span></div><div class="tgmf"><span>Lv <b>{c.lvText}</b></span><span>{view.defLabel} <b>{c.def}</b></span><span>{view.evaLabel} <b>{c.eva}</b></span></div><div class="tglvs">{#each c.levels as l (l.key)}<button class="tglv {l.tone}" data-tgtgo={l.key} aria-pressed={l.pressed} title={l.title}>{l.label}</button>{/each}</div></div>{/snippet}

<div class="scrim" data-close></div><div class="dialog tgdlg" role="dialog" aria-label={view.title}><header><h3>{view.title}</h3><button class="btn ghost" data-tgtback>{view.back}</button></header><div class="body"><div class="tgtools"><input id="tgq" class="tgq" type="search" placeholder={view.qPh} value={view.q} autocomplete="off" spellcheck="false"><label class="tgsort muted small">{view.sortLabel} <select class="buffsel" data-tgtsort use:selSync={(view.sorts.find(o => o.selected) || {k: undefined}).k}>{#each view.sorts as o (o.k)}<option value={o.k} selected={o.selected}>{o.label}</option>{/each}</select></label><button class="chip tgref" data-tgtgo="" aria-pressed={view.ref.pressed} title={view.ref.title}>{view.ref.label}</button></div><div class="tgzones">{#each view.zones as z (z.z)}<button class="chip" data-tgtzone={z.z} aria-pressed={z.pressed}>{z.label}<small>{z.n}</small></button>{/each}</div><div class="tgbody">{#each view.strips as s, i (i)}<section class="tgstrip" hidden={s.hidden}><h4>{s.label}</h4><div class="tggrid">{#each s.cards as c (c.id)}{@render card(c, false)}{/each}</div></section>{/each}<section class="tgall"><div class="tggrid">{#each view.cards as c (c.id)}{@render card(c, true)}{/each}</div><p class="muted small tgnone" hidden={view.none.hidden}>{view.none.text}</p></section></div><p class="muted small tgfoot">{view.foot}</p></div></div>
