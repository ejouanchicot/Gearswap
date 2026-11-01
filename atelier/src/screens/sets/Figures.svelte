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
  // the set's figures (Tanking or the attack, a tank's HP cycle, a Cure set's Cure, the stats sheet) as tabs of one box
  // rather than stacked: the last tab picked kept from one set to the next (S.boxOpen.figtab, events.js data-figtab),
  // the stats sheet first
  // the column's tabs (S.boxOpen.figtab, events.js data-figtab): first a summary, the lines of what the set is after
  // (SPEC page-sets-2026-11-01: clear for the one who checks), then every stat of the gear, the set's own figures
  // (Tanking, Attack, Cure), the HP cycle, every stat of the character
  const tabs = $derived([{key: 'summary', label: view.summaryTitle}, ...(view.sheet ? [{key: 'sheetall', label: view.sheetTab}] : []),
    ...view.boxes.map(b => ({key: b.key, label: b.titleHtml})), ...(view.hp ? [{key: 'hpcycle', label: view.hp.title}] : []), {key: 'all', label: view.allTab}]);
  const cur = $derived(tabs.find(x => x.key === (S as LegacyAny).boxOpen.figtab)?.key ?? 'summary');
</script>

{#snippet hpBody(h: NonNullable<FiguresView['hp']>)}<div class="boxb"><p class="note-m">{h.note}</p>{#if h.ref}<p class="note-m">{h.ref}</p>{/if}<table class="rdvs optable hpcycle"><thead><tr>{#each h.heads as x, i (i)}<th>{@html x}</th>{/each}</tr></thead>{#each h.groups as g (g.key)}<tbody><tr class="cygroup"><th colspan="4"><button class="bufftoggle" data-fold={'cyc:' + g.key} aria-expanded={g.open}>{g.label} <small>{g.rows.length}</small></button></th></tr>{#if g.open}{#each g.rows as r, i (i)}<tr class={r.mine ? 'obj' : ''}><th title={r.names}>{r.label}</th><td>{r.a}</td><td>{r.b}</td><td class={r.cls}>{r.loss}</td></tr>{/each}{/if}</tbody>{/each}</table></div>{/snippet}

<div class="globals"><div class="boxh panehead"><h3>{view.title}</h3></div><div class="ui2own"><section class="box g-tank figtabs"><div class="figtabbar" role="tablist">{#each tabs as x (x.key)}<button role="tab" data-figtab={x.key} aria-selected={x.key === cur}>{@html x.label}</button>{/each}</div><div class="figpage">{#if cur === 'summary'}{#if view.sheet && view.sheet.summary.length}<ul class="statlist"><StatLines lines={view.sheet.summary} /></ul>{:else}<p class="muted small">{view.emptyNote}</p>{/if}{:else if cur === 'all'}<div class="figall"><Globals view={view.all.globals} fold={false} /></div>{:else if cur === 'hpcycle' && view.hp}{@render hpBody(view.hp)}{:else if cur === 'sheetall' && view.sheet}<div class="figsheet"><Sheet view={view.sheet} tabbed={true} /></div>{:else}{#each view.boxes.filter(b => b.key === cur) as b (b.key)}<StatBox box={b} tabbed={true} />{/each}{/if}</div></section>{#if view.luopan}{@const lu = view.luopan}<section class="box g-def"><header class="boxh"><h3>{@html lu.title}</h3></header><div class="boxb"><ul class="statlist big">{#each lu.rows as x, i (i)}<li class={x.cls} title={x.title}><span>{@html x.labelHtml}</span><b>{@html x.valueHtml}</b><i>{@html x.extraHtml}</i></li>{/each}</ul>{#if lu.cast}<p class="note-m">{lu.cast}</p>{/if}{#if lu.life}<p class="note-m">{lu.life.note}</p><table class="rdvs optable"><thead><tr>{#each lu.life.heads as h, i (i)}<th>{h}</th>{/each}</tr></thead><tbody>{#each lu.life.rows as r, i (i)}<tr><th>{r.label}</th><td>{r.loss}</td><td>{r.ticks}</td><td class={r.good ? 'better' : ''}>{r.time}</td></tr>{/each}</tbody></table>{/if}{#each lu.notes as n, i (i)}<p class="note-m">{n}</p>{/each}</div></section>{/if}</div></div>
