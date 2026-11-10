<!--
  GearSwap Atelier · Buffs & target (combat.ts, member.ts), the party's buffs first
  (notes/docs-perso/buffs-cible-2026-11-02/SPEC.md, v3 "A + B"): the sets on the left (the one picked is the one the
  results are for); in the middle the fight's settings (the profile, the group of buffs, the monster on one line, its
  card and the other debuffs folded), then the party as the game's list beside the member opened (its slots, each
  opening its window of choices, the rest of its settings); on the right what it all gives you, an effect a card with who
  gives it, and the set opened in each situation. The buttons keep the attributes
  the old page's handlers read (party_builder.js pbClick, buffs.js, profiles.js, target_pick.js).

  @file    atelier/src/screens/combat/CombatScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import FoePanel from './FoePanel.svelte';
  import TargetCard from './TargetCard.svelte';
  import {legacy} from '../../stores/legacy.svelte';
  import {combatView} from './combat';
  import {itemIcon, type FxCard} from './member';
  import type {Item, Block} from './panel';
  // a section's setting lines (Warcry's Savagery), drawn under its tiles
  const extrasOf = (items: Item[]): Block[] => items.flatMap(it => it.k === 'extra' ? [{k: 'extra', ctl: it.ctl} as Block] : []);
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

{#snippet fxcard(c: FxCard)}<div class="kfr" class:foe={c.foe} class:cap={c.cap} title={c.tip}><span class="kfrl">{c.label}</span><span class="kfri">{#each c.sources as x, k (k)}<span>{@html x.emblemHtml}</span>{/each}</span><b>{c.value}{#if c.cap}<small>max</small>{/if}</b>{#if c.p != null}<i class="kfxbar" style="--p:{c.p}%"></i>{/if}</div>{/snippet}
{#snippet opt(it: Item)}{#if it.k === 'row' || it.k === 'am'}<div class="kop"><span class="kopl">{@html itemIcon(it)}{it.label}</span><span class="kopc">{#each it.controls as c, j (j)}<Ctl {c} />{/each}</span>{#if it.k === 'row' && it.effects.length}<span class="kqe">{#each it.effects as e, j (j)}<Eff {e} />{/each}</span>{:else if it.k === 'am' && it.said}<span class="kqe"><span class="muted amwho">{it.said}</span></span>{/if}</div>{/if}{/snippet}
{#snippet band(n: string, title: string, hint: string)}<div class="kband">{#if n}<span class="kn">{n}</span>{/if}<b>{title}</b>{#if hint}<small>{hint}</small>{/if}</div>{/snippet}

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
      <div class="kab">
        <section class="kcard kptcol"><div class="kband"><b>{p.title}</b><small>{p.count}</small></div>
          <div class="kpt">
            {#each p.rows as r (r.tab.key)}
              <button class="kpm" class:on={r.tab.selected} data-pbtab={r.tab.key} aria-pressed={r.tab.selected}>{@html r.tab.emblemHtml}<span class="kpmt"><b>{r.tab.label}</b>{#if r.tab.sub}<small>{r.tab.sub}</small>{/if}</span>
                <span class="kpmi">{#each r.icons as ic, i (i)}<span class:on={ic.on}>{@html ic.html}</span>{/each}</span></button>
            {/each}
            {#if p.add}<button class="kpadd" data-pbaddopen title={p.add.title}>+ {p.add.label}<small>{p.add.left}</small></button>{/if}
          </div>
        </section>
        {#if p.editor}{@const ed = p.editor}
        <section class="kcard kedit">
          <div class="kband"><b>{ed.tab.label}{#if ed.tab.sub} · {ed.tab.sub}{/if}</b><small>{ed.hint}</small>{#if ed.tab.del}<button class="kx" data-pbdel={ed.tab.key} title={ed.removeTitle} aria-label={ed.removeTitle}>✕</button>{/if}</div>
          <div class="ked">
            <div class="kslots" style="--n:{Math.min(4, Math.max(2, ed.slots.length))}">
              {#each ed.slots as sl, i (i)}
                {#if sl.k === 'pick'}<button class="ksl" class:set={sl.set} data-pbpick={sl.key}><span class="kslic" class:on={sl.icon.on}>{@html sl.icon.html}</span><span class="kslb"><small>{sl.label}</small><b>{sl.value}<i>▾</i></b><span class="kqe">{#each sl.gives as e, j (j)}<Eff {e} />{/each}</span></span></button>
                {:else}{@const it = sl.item}<div class="ksl item" class:set={sl.icon.on}><span class="kslic" class:on={sl.icon.on}>{@html sl.icon.html}</span><span class="kslb">{#if it.k === 'row'}<small>{it.label}</small><span class="kqc">{#each it.controls as c, j (j)}<Ctl {c} />{/each}</span>{#if it.effects.length}<span class="kqe">{#each it.effects as e, j (j)}<Eff {e} />{/each}</span>{/if}{:else if it.k === 'am'}<small>{it.label}</small><span class="kqc pbfam">{#each it.controls as c, j (j)}<Ctl {c} />{/each}</span>{#if it.said}<span class="kqe"><span class="muted amwho">{it.said}</span></span>{/if}{/if}</span></div>{/if}
              {/each}
            </div>
            {#if ed.rest}{#each ed.rest.left.concat(ed.rest.right) as bl, i (i)}
              <!-- (a setting's line, Warcry's Savagery once Warcry is on, under the tiles: before 2026-11-07 it turned the section back into a list) -->
              {#if bl.k === 'section' && bl.items.some(it => it.k !== 'extra')}{@const extras = extrasOf(bl.items)}<div class="kopt"><h4>{bl.title}</h4><div class="koptg">{#each bl.items.filter(it => it.k !== 'extra') as it, j (j)}{@render opt(it)}{/each}</div></div>
                {#if extras.length}<div class="krest pbbody" class:pbyou={ed.tab.key === 'you'}><Panel view={{left: extras, right: []}} /></div>{/if}
              {:else}<div class="krest pbbody" class:pbyou={ed.tab.key === 'you'}><Panel view={{left: [bl], right: []}} /></div>{/if}
            {/each}{/if}
          </div>
        </section>
        {/if}
      </div>
    </div>
    <aside class="kcard kresult"><div class="kband" title={view.result.hint}><b>{view.result.title}</b></div>
      <div class="kfx">
        {#if view.result.mine.length || view.result.foes.length}<div class="kfrh" aria-hidden="true">{#each view.result.cols as h (h)}<span>{h}</span>{/each}</div>{/if}
        {#each view.result.mine as c, i (i)}{@render fxcard(c)}{:else}<p class="muted small">{view.result.nothing}</p>{/each}
        {#if view.result.foes.length}<h4 class="kfxh">{view.result.onFoe}</h4>{#each view.result.foes as c, i (i)}{@render fxcard(c)}{/each}{/if}
      </div>
      <section class="kblock pbimpact"><h4>{view.impact.title}</h4>{#if view.impact.note}<p class="muted small">{view.impact.note}</p>{:else}<p class="pbimpset"><b>{view.impact.set}</b> · {view.impact.what}</p><div class="pbimp {view.impact.ws ? 'one' : 'two'}">{#each view.impact.rows as r (r.tier)}<button class="pbimprow" data-bufftier={r.tier} aria-pressed={r.pressed} title={r.title}><span class="pbimpw"><b>{r.tier}</b><small>{r.name}</small></span><span class="pbimpv">{r.a}{#if r.aDiff}<i class={r.aDiff.up ? 'up' : 'down'}>{r.aDiff.text}</i>{/if}</span>{#if !view.impact.ws}<span class="pbimpv">{r.b}{#if r.bDiff}<i class={r.bDiff.up ? 'up' : 'down'}>{r.bDiff.text}</i>{/if}</span>{/if}</button>{/each}</div>{/if}</section>
    </aside></div>
  </div></div></div></div>
{/if}
