<!--
  GearSwap Atelier · My character (perso.ts): the sets or the played jobs on the left, who the character is, the two
  views, the stats cards, PorterPacker, the merits. The buttons and inputs keep the attributes the old page's
  handlers read (bags_view.js data-persoview, porter.js data-porterwrite, engine.js data-merittab / data-merit,
  data-action="meritreset").

  @file    atelier/src/screens/perso/PersoScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';
  import {persoView} from './perso';
  import Box from '../../components/Box.svelte';
  import JobList from '../config/JobList.svelte';
  import Bags from './Bags.svelte';
  import SetList from '../sets/SetList.svelte';

  const view = $derived(legacy.version > 0 ? persoView() : null);
</script>

{#if view}
  {@const h = view.head}
  <div class="pane split"><div class="tabx" class:setside={view.side !== null}>{#if view.side !== null}<SetList view={view.side} />{:else}<JobList />{/if}<div class="tabmain"><div class="ui2tab persotab">
    <header class="tabhead"><div><h2>{h.char}</h2><p class="muted small">{h.why}</p></div><dl class="herofacts">{#each h.facts as [k, v] (k)}<div><dt>{k}</dt><dd>{v}</dd></div>{/each}</dl><span class="seg persoviews" role="group">{#each h.views as b (b.value)}<button data-persoview={b.value} aria-pressed={b.pressed} title={b.title}>{b.label}</button>{/each}</span></header>
    {#if view.bags !== null}<Bags view={view.bags} />{:else if view.stats}
      {@const st = view.stats}
      <div class="persogrid">{#if st.cardsHtml !== null}{@html st.cardsHtml}{:else}<p class="muted">{@html st.noCharHtml}</p>{/if}{#if st.porter}{@const p = st.porter}<Box cls="g-caps" title={p.title} meta={p.meta}><p class="muted small">{@html p.introHtml}</p>{#if p.newHtml}<p class="small">{@html p.newHtml}</p>{/if}{#if p.add}<p class="small"><b>+ {@html p.add.labelHtml}</b></p><ul class="statlist">{#each p.add.names as n (n)}<li class="porteradd">{n}</li>{/each}</ul>{/if}{#if p.remove}<p class="small"><b>− {@html p.remove.labelHtml}</b></p><ul class="statlist">{#each p.remove.names as n (n)}<li class="porterrm">{n}</li>{/each}</ul>{/if}{#if p.doneHtml}<p class="small">{@html p.doneHtml}</p>{/if}{#if p.write}<button class="btn" data-porterwrite title={p.write.title}>{@html p.write.textHtml}</button>{/if}{#if p.needHtml}<p class="muted small">{@html p.needHtml}</p>{/if}</Box>{/if}</div>
      <h3 class="tabsec">{st.meritsTitle}</h3>
      {@const m = st.merits}
      {#if m.noneHtml}<div class="placeholder"><p>{@html m.noneHtml}</p></div>{:else}
        <div class="meritbar"><p class="muted">{@html m.bar.noteHtml}</p>{#if m.bar.reset}<button class="btn ghost" data-action="meritreset">{@html m.bar.reset.textHtml}</button>{/if}</div>
        <div class="mwrap"><div class="mtabs" role="tablist">{#each m.tabs as tb (tb.key)}<button class="mtab {tb.cls}" role="tab" data-merittab={tb.key} aria-selected={tb.selected} title={tb.title}><b>{tb.label}</b><small>{tb.spent}</small>{#if tb.edited}<i class="mdot"></i>{/if}</button>{/each}</div><section class="mpanel {m.panel.cls}"><ul class="meritlist two">{#each m.panel.rows as r (r.key)}<li class:changed={r.changed}><span title={r.desc}>{r.name}</span><input class="meritin" id="merit-{r.key}" data-merit={r.key} type="number" min="0" max={r.cap} value={r.level} title={r.inputTitle}><i>{r.was}{r.total}</i></li>{/each}</ul></section></div>
      {/if}
    {/if}
  </div></div></div></div>
{/if}
