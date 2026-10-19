<!--
  GearSwap Atelier · Buffs & target (combat.ts): the sets on the left, the profiles' bar, the party as tabs in the box of
  the situation shown, the chosen member's panel, the other debuffs; beside them the target, what it all changes for
  the set opened and the total. The buttons keep the attributes the old page's handlers read (party_builder.js
  pbClick, buffs.js, profiles.js).

  @file    atelier/src/screens/combat/CombatScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';
  import {combatView, type PartyTab, type SumRow} from './combat';
  import Box from '../../components/Box.svelte';
  import Panel from './Panel.svelte';
  import SetList from '../sets/SetList.svelte';
  import Situations from '../profiles/Situations.svelte';
  import Picker from '../profiles/Picker.svelte';

  const view = $derived(legacy.version > 0 ? combatView() : null);
</script>

{#snippet tab(tb: PartyTab, removeTitle: string, nothing: string)}<div class="pbtab" role="tab" tabindex="0" data-pbtab={tb.key} aria-selected={tb.selected}><span class="pbtabh">{@html tb.emblemHtml}<b>{tb.label}</b>{#if tb.sub}<small>{tb.sub}</small>{/if}{#if tb.del}<button class="pbx" data-pbdel={tb.key} title={removeTitle} aria-label={removeTitle}>×</button>{/if}</span><span class="pbtabg">{#if tb.gives.length}{#each tb.gives as g, i (i)}<span class={g.neg ? 'pneg' : undefined}>{g.text}</span>{/each}{:else}<span class="muted">{nothing}</span>{/if}</span></div>{/snippet}
{#snippet sum(r: SumRow)}<li class="{r.low ? 'neg' : ''} {r.foe ? 'foe' : ''}" title={r.title}><span>{r.name}</span><b>{r.value}</b></li>{/snippet}

{#if view}
  {@const h = view.head}
  {@const p = view.party}
  <div class="pane split"><div class="tabx setside"><SetList view={view.side} /><div class="tabmain"><div class="ui2tab combattab">
    <header class="tabhead"><div><h2>{h.title}</h2><p class="muted small">{h.why}</p></div><div class="tabacts">{#if h.undo}<button class="btn prupd" data-buffundo title={h.undo.title}>{h.undo.text}</button>{/if}<button class="btn ghost" data-buffendgame title={h.endgame.title}>{@html h.endgame.textHtml}</button><button class="btn ghost" data-buffreset disabled={h.reset.disabled} title={h.reset.title}>{@html h.reset.textHtml}</button></div></header>
    <section class="profbar"><div class="prrow"><span class="kicker">{view.profBar.label}</span><div class="prchips"><Picker view={view.profBar.picker} /></div></div></section>
    <div class="pblayout"><div class="pbmain"><section class="box cbbox"><Situations list={view.sits.list} big={true} label={view.sits.label} /><div class="boxb"><div class="cbhd"><b>{p.title}</b><span class="muted small">{p.count}</span></div><div class="pbtabs" role="tablist">{#each p.tabs as tb (tb.key)}{@render tab(tb, p.removeTitle, p.nothing)}{/each}{#if p.add}<button class="pbtab pbtabadd" data-pbaddopen title={p.add.title}><b>+ {p.add.label}</b><small>{p.add.left}</small></button>{/if}</div><section class="pbpanel"><div class="pbbody" class:pbyou={p.you}><Panel view={p.panel} /></div></section></div></section>{#if view.other}{@const o = view.other}<details class="pbother" data-pbother open={o.open}><summary title={o.title}><span class="pbot"><b>{o.label}</b><small>{o.who}</small></span><span class="pbosum">{@html o.totalHtml}</span><span class="pbohint"><i class="o">{o.openText}</i><i class="s">{o.shutText}</i></span></summary><div class="pbotherb">{@html o.bodyHtml}</div></details>{/if}</div><aside class="pbside"><Box cls="g-off" title={view.target.title} meta={view.target.meta}>{@html view.target.html}</Box><Box cls="g-buff pbimpact" title={view.impact.title}>{#if view.impact.note}<p class="muted small">{view.impact.note}</p>{:else}<p class="pbimpset"><b>{view.impact.set}</b> · {view.impact.what}</p><div class="pbimp {view.impact.ws ? 'one' : 'two'}">{#each view.impact.rows as r (r.tier)}<button class="pbimprow" data-bufftier={r.tier} aria-pressed={r.pressed} title={r.title}><span class="pbimpw"><b>{r.tier}</b><small>{r.name}</small></span><span class="pbimpv">{r.a}{#if r.aDiff}<i class={r.aDiff.up ? 'up' : 'down'}>{r.aDiff.text}</i>{/if}</span>{#if !view.impact.ws}<span class="pbimpv">{r.b}{#if r.bDiff}<i class={r.bDiff.up ? 'up' : 'down'}>{r.bDiff.text}</i>{/if}</span>{/if}</button>{/each}</div>{/if}</Box><Box cls="g-def" title={view.total.title}><h4 class="pbsumh">{view.total.onYou}</h4>{#if view.total.mine.length}<ul class="pbsum">{#each view.total.mine as r, i (i)}{@render sum(r)}{/each}</ul>{:else}<p class="muted small pbsumnone">{view.total.nothing}</p>{/if}{#if view.total.foes.length}<h4 class="pbsumh foe">{view.total.onFoe}</h4><ul class="pbsum">{#each view.total.foes as r, i (i)}{@render sum(r)}{/each}</ul>{/if}</Box></aside></div>
  </div></div></div></div>
{/if}
