<!--
  GearSwap Atelier · Buffs & target (combat.ts), the party's buffs first (notes/docs-perso/buffs-cible-2026-11-02/SPEC.md):
  the sets on the left (the one picked is the one the results are for); in the middle the fight's settings (the profile,
  the group of buffs, the monster on one line, its card and the other debuffs folded), then the party as the game's
  list, each member's main settings on its line and all of them under it when opened; on the right what it all gives
  you (tiles, the set opened in each situation, every buff). The buttons keep the attributes
  the old page's handlers read (party_builder.js pbClick, buffs.js, profiles.js, target_pick.js).

  @file    atelier/src/screens/combat/CombatScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import FoePanel from './FoePanel.svelte';
  import TargetCard from './TargetCard.svelte';
  import {legacy} from '../../stores/legacy.svelte';
  import {combatView, type SumRow} from './combat';
  import type {Item} from './panel';
  import Panel from './Panel.svelte';
  import Ctl from './Ctl.svelte';
  import Eff from './Eff.svelte';
  import SetList from '../sets/SetList.svelte';
  import Situations from '../profiles/Situations.svelte';
  import Picker from '../profiles/Picker.svelte';

  const view = $derived(legacy.version > 0 ? combatView() : null);
  // the monster's whole card, folded under its line
  let foeOpen = $state(false);
</script>

{#snippet sum(r: SumRow)}<li class="{r.low ? 'neg' : ''} {r.foe ? 'foe' : ''}" title={r.title}><span>{r.name}</span><b>{r.value}</b></li>{/snippet}
{#snippet band(n: string, title: string, hint: string)}<div class="kband">{#if n}<span class="kn">{n}</span>{/if}<b>{title}</b>{#if hint}<small>{hint}</small>{/if}</div>{/snippet}
{#snippet quick(it: Item)}{#if it.k === 'row'}<span class="kq"><span class="kql">{it.label}</span><span class="kqc">{#each it.controls as c, i (i)}<Ctl {c} />{/each}</span>{#if it.effects.length}<span class="kqe">{#each it.effects as e, i (i)}<Eff {e} />{/each}</span>{/if}</span>{:else if it.k === 'am'}<span class="kq wide pbfam"><span class="kql">{it.label}</span><span class="kqc">{#each it.controls as c, i (i)}<Ctl {c} />{/each}</span>{#if it.said}<span class="kqe"><span class="muted amwho">{it.said}</span></span>{/if}</span>{/if}{/snippet}

{#if view}
  {@const h = view.head}
  {@const p = view.party}
  <div class="pane split"><div class="tabx setside"><SetList view={view.side} /><div class="tabmain"><div class="ui2tab combattab kfight">
    <div class="kcols"><div class="kmain">
      <section class="kcard kfightcard"><div class="kband"><b title={view.fight.hint}>{view.fight.title}</b><span class="kbandacts">{#if h.undo}<button class="btn prupd" data-buffundo title={h.undo.title}>{h.undo.text}</button>{/if}<button class="btn ghost" data-buffendgame title={h.endgame.title}>{@html h.endgame.textHtml}</button><button class="btn ghost" data-buffreset disabled={h.reset.disabled} title={h.reset.title}>{@html h.reset.textHtml}</button></span></div>
        <div class="kset">
          <span class="kfield" title={view.fight.hint}><span class="klbl">{view.fight.profile}</span><span class="kprof"><Picker view={view.profBar.picker} /></span></span>
          <span class="kfield"><span class="klbl">{view.fight.group}</span><Situations list={view.sits.list} big={false} label="" /></span>
        </div>
        <div class="kfoeline"><span class="klbl">{view.fight.vs}</span><span class="kfoename"><b>{view.target.card.name}</b><small title={view.target.card.factsTitle}>{view.target.card.facts}</small></span>
          {#each view.target.card.gauges as g, i (i)}<span class="kfoeg" title={g.tip}>{g.label} <b>{g.a}</b>{#if g.z !== g.a} → <em>{g.z}</em>{/if}</span>{/each}
          {#if 'p' in view.target.card.hit}<span class="kfoehit {view.target.card.hit.tone}" title={view.target.card.hit.title}>{view.target.card.hit.label} <b>{view.target.card.hit.p} %</b></span>{/if}
          <span class="ksp"></span><button class="btn" data-tgtpick title={view.target.card.change.title}>{view.target.card.change.label}</button><button class="linkbtn" aria-expanded={foeOpen} onclick={() => foeOpen = !foeOpen}>{foeOpen ? view.fight.foeLess : view.fight.foeMore}</button></div>
        {#if foeOpen}<div class="kfoe"><TargetCard view={view.target.card} /></div>{/if}
        {#if view.other}{@const o = view.other}<details class="pbother kother" data-pbother open={o.open}><summary title={o.title}><span class="pbot"><b>{o.label}</b><small>{o.who}</small></span><span class="pbosum"><span class="meta {o.down ? 'down' : ''}">{o.total}</span></span><span class="pbohint"><i class="o">{o.openText}</i><i class="s">{o.shutText}</i></span></summary><div class="pbotherb"><FoePanel view={o.foe} /></div></details>{/if}
      </section>
      <section class="kcard kptcard">{@render band('', p.title + ' · ' + p.count, p.hint)}
        <div class="kparty">
          {#each p.rows as r (r.tab.key)}
            <div class="kmem" class:open={r.open}>
              <div class="kmemrow">
                <button class="kwho" data-pbtab={r.tab.key} aria-expanded={r.open} title={p.moreTitle}>{@html r.tab.emblemHtml}<span><b>{r.tab.label}</b>{#if r.tab.sub}<small>{r.tab.sub}</small>{/if}</span><i>{r.open ? '▴' : '▾'}</i></button>
                <div class="kquick">{#each r.quick as it, i (i)}{@render quick(it)}{/each}{#if !r.quick.length}<span class="kgives">{#each r.tab.gives as g, i (i)}<span class={g.neg ? 'pneg' : undefined}>{g.text}</span>{:else}<span class="muted">{p.nothing}</span>{/each}</span>{/if}</div>
                {#if r.tab.del}<button class="kx" data-pbdel={r.tab.key} title={p.removeTitle} aria-label={p.removeTitle}>✕</button>{:else}<span></span>{/if}
              </div>
              {#if r.panel}<div class="kmore pbbody" class:pbyou={r.tab.key === 'you'}><Panel view={r.panel} /></div>{/if}
            </div>
          {/each}
          {#if p.add}<button class="kadd" data-pbaddopen title={p.add.title}><b>+ {p.add.label}</b><small>{p.add.left}</small></button>{/if}
        </div>
      </section>
    </div>
    <aside class="kcard kresult">{@render band('', view.result.title, '')}
      <div class="ktiles">{#each view.result.tiles as tl (tl.label)}<div class="ktile" class:cap={tl.cap} title={tl.title || undefined}><b>{tl.value}</b><small>{tl.label}</small></div>{/each}</div>
      <section class="kblock pbimpact"><h4>{view.impact.title}</h4>{#if view.impact.note}<p class="muted small">{view.impact.note}</p>{:else}<p class="pbimpset"><b>{view.impact.set}</b> · {view.impact.what}</p><div class="pbimp {view.impact.ws ? 'one' : 'two'}">{#each view.impact.rows as r (r.tier)}<button class="pbimprow" data-bufftier={r.tier} aria-pressed={r.pressed} title={r.title}><span class="pbimpw"><b>{r.tier}</b><small>{r.name}</small></span><span class="pbimpv">{r.a}{#if r.aDiff}<i class={r.aDiff.up ? 'up' : 'down'}>{r.aDiff.text}</i>{/if}</span>{#if !view.impact.ws}<span class="pbimpv">{r.b}{#if r.bDiff}<i class={r.bDiff.up ? 'up' : 'down'}>{r.bDiff.text}</i>{/if}</span>{/if}</button>{/each}</div>{/if}</section>
      <section class="kblock"><h4>{view.total.onYou}</h4>{#if view.total.mine.length}<ul class="pbsum">{#each view.total.mine as r, i (i)}{@render sum(r)}{/each}</ul>{:else}<p class="muted small pbsumnone">{view.total.nothing}</p>{/if}{#if view.total.foes.length}<h4 class="foe">{view.total.onFoe}</h4><ul class="pbsum">{#each view.total.foes as r, i (i)}{@render sum(r)}{/each}</ul>{/if}</section>
    </aside></div>
  </div></div></div></div>
{/if}
