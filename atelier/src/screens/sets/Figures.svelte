<!--
  GearSwap Atelier · the figures of a set (figures.ts): its own figures in a block of fixed height (sets.css .ui2own),
  its stats sheet, every stat folded. A box folds by its band (events.js data-fold), every stat by its summary
  (data-ui2all).

  @file    atelier/src/screens/sets/Figures.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import Sheet from './Sheet.svelte';
  import StatLines from './StatLines.svelte';
  import Globals from './Globals.svelte';
  import type {FiguresView} from './figures';
  import StatBox from './StatBox.svelte';

  let {view}: {view: FiguresView} = $props();
  // the column's tabs, the last one picked kept from one set to the next (S.boxOpen.figtab, events.js data-figtab):
  // a summary (the caps the set is after, then the few lines of its own figures: Tanking, Attack, a nuke's, a Cure's), every stat of
  // the gear by group, a tank's HP cycle, the character's figures with the set
  const tabs = $derived([{key: 'summary', label: view.summaryTitle}, ...(view.sheet ? [{key: 'sheetall', label: view.sheetTab}] : []),
    ...(view.hp ? [{key: 'hpcycle', label: view.hp.title}] : []), {key: 'all', label: view.allTab}]);
  const cur = $derived(tabs.find(x => x.key === (S as LegacyAny).boxOpen.figtab)?.key ?? 'summary');
</script>

{#snippet hpBody(h: NonNullable<FiguresView['hp']>)}<div class="boxb"><p class="note-m">{h.note}</p>{#if h.ref}<p class="note-m">{h.ref}</p>{/if}<table class="rdvs optable hpcycle"><thead><tr>{#each h.heads as x, i (i)}<th>{@html x}</th>{/each}</tr></thead>{#each h.groups as g (g.key)}<tbody><tr class="cygroup"><th colspan="4"><button class="bufftoggle" data-fold={'cyc:' + g.key} aria-expanded={g.open}>{g.label} <small>{g.rows.length}</small></button></th></tr>{#if g.open}{#each g.rows as r, i (i)}<tr class={r.mine ? 'obj' : ''}><th title={r.names}>{r.label}</th><td>{r.a}</td><td>{r.b}</td><td class={r.cls}>{r.loss}</td></tr>{/each}{/if}</tbody>{/each}</table></div>{/snippet}

<div class="globals"><div class="boxh panehead"><h3>{view.title}</h3></div><div class="ui2own"><section class="box g-tank figtabs"><div class="figtabbar" role="tablist">{#each tabs as x (x.key)}<button role="tab" data-figtab={x.key} aria-selected={x.key === cur}>{@html x.label}</button>{/each}</div><div class="figpage">{#if cur === 'summary'}<div class="figsum">{#if view.sheet && view.sheet.caps.length}<section class="figsec"><p class="figlead">{view.capsTitle}</p><ul class="statlist"><StatLines lines={view.sheet.caps} /></ul></section>{/if}{#each view.boxes as b (b.key)}<section class="figsec"><p class="figlead">{@html b.titleHtml}</p>{#if b.brief}<ul class="statlist">{#each b.brief as x, i (i)}{#if x.k === 'row'}<li class={x.cls} title={x.title}><span>{@html x.labelHtml}</span><b>{@html x.valueHtml}</b><i>{@html x.extraHtml}</i></li>{/if}{/each}</ul>{:else}<StatBox box={b} tabbed={true} />{/if}</section>{/each}{#if !view.boxes.length && !(view.sheet && view.sheet.caps.length)}<p class="muted small">{view.emptyNote}</p>{/if}</div>{:else if cur === 'all'}<div class="figall"><Globals view={view.all.globals} fold={false} /></div>{:else if cur === 'hpcycle' && view.hp}{@render hpBody(view.hp)}{:else if cur === 'sheetall' && view.sheet}<div class="figsheet"><Sheet view={view.sheet} tabbed={true} /></div>{/if}</div></section>{#if view.luopan}{@const lu = view.luopan}<section class="box g-def"><header class="boxh"><h3>{@html lu.title}</h3></header><div class="boxb"><ul class="statlist big">{#each lu.rows as x, i (i)}<li class={x.cls} title={x.title}><span>{@html x.labelHtml}</span><b>{@html x.valueHtml}</b><i>{@html x.extraHtml}</i></li>{/each}</ul>{#if lu.cast}<p class="note-m">{lu.cast}</p>{/if}{#if lu.life}<p class="note-m">{lu.life.note}</p><table class="rdvs optable"><thead><tr>{#each lu.life.heads as h, i (i)}<th>{h}</th>{/each}</tr></thead><tbody>{#each lu.life.rows as r, i (i)}<tr><th>{r.label}</th><td>{r.loss}</td><td>{r.ticks}</td><td class={r.good ? 'better' : ''}>{r.time}</td></tr>{/each}</tbody></table>{/if}{#each lu.notes as n, i (i)}<p class="note-m">{n}</p>{/each}</div></section>{/if}</div></div>
