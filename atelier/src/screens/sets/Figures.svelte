<!--
  GearSwap Atelier · the figures of a set (figures.ts): its own figures in a block of fixed height (sets.css .ui2own),
  its stats sheet, every stat folded. A box folds by its band (events.js data-fold), every stat by its summary
  (data-ui2all).

  @file    atelier/src/screens/sets/Figures.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import Sheet from './Sheet.svelte';
  import Globals from './Globals.svelte';
  import type {FiguresView} from './figures';
  import StatBox from './StatBox.svelte';

  let {view}: {view: FiguresView} = $props();
</script>

<div class="globals"><h3 class="ui2title">{view.title}</h3><div class="ui2own">{#each view.boxes as b (b.key)}<StatBox box={b} />{/each}{#if view.hp}{@const h = view.hp}<section class="box g-tank"><button class="boxh bufftoggle" data-fold="hpcycle" aria-expanded={h.open} title={h.foldTitle}><h3>{@html h.title}</h3><span class="meta"></span></button>{#if h.open}<div class="boxb"><p class="note-m">{h.note}</p>{#if h.ref}<p class="note-m">{h.ref}</p>{/if}<table class="rdvs optable hpcycle"><thead><tr>{#each h.heads as x, i (i)}<th>{@html x}</th>{/each}</tr></thead><tbody>{#each h.rows as r, i (i)}<tr class={r.mine ? 'obj' : ''}><th title={r.names}>{r.label}</th><td>{r.a}</td><td>{r.b}</td><td class={r.cls}>{r.loss}</td></tr>{/each}</tbody></table></div>{/if}</section>{/if}{#if view.luopan}{@const lu = view.luopan}<section class="box g-def"><header class="boxh"><h3>{@html lu.title}</h3></header><div class="boxb"><ul class="statlist big">{#each lu.rows as x, i (i)}<li class={x.cls} title={x.title}><span>{@html x.labelHtml}</span><b>{@html x.valueHtml}</b><i>{@html x.extraHtml}</i></li>{/each}</ul>{#if lu.cast}<p class="note-m">{lu.cast}</p>{/if}{#if lu.life}<p class="note-m">{lu.life.note}</p><table class="rdvs optable"><thead><tr>{#each lu.life.heads as h, i (i)}<th>{h}</th>{/each}</tr></thead><tbody>{#each lu.life.rows as r, i (i)}<tr><th>{r.label}</th><td>{r.loss}</td><td>{r.ticks}</td><td class={r.good ? 'better' : ''}>{r.time}</td></tr>{/each}</tbody></table>{/if}{#each lu.notes as n, i (i)}<p class="note-m">{n}</p>{/each}</div></section>{/if}</div>{#if view.sheet}<Sheet view={view.sheet} />{/if}<details class="lgfold ui2all" data-ui2all open={view.all.open}><summary title={view.all.title}>{view.all.label}</summary><Globals view={view.all.globals} fold={true} /></details></div>
