<!--
  GearSwap Atelier · My character and Bags (perso.ts): the sets, the bags or the played jobs on the left, who the character is,
  the stats cards, PorterPacker, the merits. The buttons and inputs keep the attributes the old page's
  handlers read (porter.js data-porterwrite, engine.js data-merittab / data-merit,
  data-action="meritreset").

  @file    atelier/src/screens/perso/PersoScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import Globals from '../sets/Globals.svelte';
  import {legacy} from '../../stores/legacy.svelte';
  import {persoView} from './perso';
  import Box from '../../components/Box.svelte';
  import JobList from '../config/JobList.svelte';
  import Bags from './Bags.svelte';
  import BagSide from './BagSide.svelte';
  import SetList from '../sets/SetList.svelte';

  const view = $derived(legacy.version > 0 ? persoView() : null);
</script>

{#if view}
  {@const h = view.head}
  <div class="pane split"><div class="tabx" class:setside={view.side !== null}>{#if view.bags !== null && view.bags.none === null}<BagSide view={view.bags} />{:else if view.side !== null}<SetList view={view.side} />{:else}<JobList />{/if}<div class="tabmain"><div class="ui2tab persotab">
    <header class="tabhead"><div><h2>{h.char}</h2><p class="muted small">{h.why}</p></div><dl class="herofacts">{#each h.facts as [k, v] (k)}<div><dt>{k}</dt><dd>{v}</dd></div>{/each}</dl></header>
    {#if view.bags !== null}<Bags view={view.bags} />{:else if view.stats}
      {@const st = view.stats}
      <div class="persogrid">{#if st.cards}<Globals view={st.cards} fold={false} />{:else}<p class="muted">{@html st.noCharHtml}</p>{/if}{#if st.porter}{@const p = st.porter}<Box cls="g-caps porterbox" title={p.title} meta={p.meta}>
        <p class="muted small">{@html p.introHtml}</p>{#if p.newHtml}<p class="small">{@html p.newHtml}</p>{/if}
        <div class="porterfig">{#each p.figures as f (f.label)}<div class="pf {f.tone}"><b>{f.n}</b><small>{f.label}</small></div>{/each}</div>
        {#if p.plain}<p class="porterwarn">{p.plain}</p>{/if}
        {#if p.write}<button class="btn porterbtn" data-porterwrite title={p.write.title}>{@html p.write.textHtml}</button>{/if}{#if p.needHtml}<p class="muted small">{@html p.needHtml}</p>{/if}
        {#if p.add}<details class="porterlist add" open={p.add.names.length <= 12}><summary>+ {@html p.add.labelHtml} <em>{p.add.names.length}</em></summary><div class="pchips">{#each p.add.names as n (n)}<span>{n}</span>{/each}</div></details>{/if}
        {#if p.remove}<details class="porterlist rm" open={p.remove.names.length <= 12}><summary>− {@html p.remove.labelHtml} <em>{p.remove.names.length}</em></summary><div class="pchips">{#each p.remove.names as n (n)}<span>{n}</span>{/each}</div></details>{/if}
        {#if p.doneHtml}<p class="small">{@html p.doneHtml}</p>{/if}</Box>{/if}</div>
      <h3 class="tabsec">{st.meritsTitle}</h3>
      {@const m = st.merits}
      {#if m.noneHtml}<div class="placeholder"><p>{@html m.noneHtml}</p></div>{:else}
        <div class="meritbar"><p class="muted">{@html m.bar.noteHtml}</p>{#if m.bar.reset}<button class="btn ghost" data-action="meritreset">{@html m.bar.reset.textHtml}</button>{/if}</div>
        <div class="mwrap"><div class="mtabs" role="tablist">{#each m.tabs as tb (tb.key)}<button class="mtab {tb.cls}" role="tab" data-merittab={tb.key} aria-selected={tb.selected} title={tb.title}><b>{tb.label}</b><small>{tb.spent}</small>{#if tb.edited}<i class="mdot"></i>{/if}</button>{/each}</div><section class="mpanel {m.panel.cls}"><ul class="meritlist two">{#each m.panel.rows as r (r.key)}<li class:changed={r.changed}><span title={r.desc}>{r.name}</span><input class="meritin" id="merit-{r.key}" data-merit={r.key} type="number" min="0" max={r.cap} value={r.level} title={r.inputTitle}><i>{r.was}{r.total}</i></li>{/each}</ul></section></div>
      {/if}
    {/if}
  </div></div></div></div>
{/if}
