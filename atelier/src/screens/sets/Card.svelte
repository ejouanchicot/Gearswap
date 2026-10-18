<!--
  GearSwap Atelier · the card of the set shown (card.ts): its head, its versions, the equipment's sixteen slots, the
  line under them, the legend and notes, its figures. The slots and buttons keep the attributes the old page's
  handlers read (events.js data-card / data-slot / data-variant, trial.js data-unslot).

  @file    atelier/src/screens/sets/Card.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {CardView, VerButton, SlotView} from './card';

  let {view}: {view: CardView} = $props();
</script>

{#snippet ver(b: VerButton)}<button aria-pressed={b.pressed} data-card={view.ci} data-variant={b.i} title={b.title}>{b.label}</button>{/snippet}
{#snippet slot(x: SlotView)}<button class={x.cls} data-card={x.ci} data-slot={x.slot} aria-label={x.aria}>{#if x.reset}<span class="unslot" role="button" tabindex="0" data-unslot={x.slot} data-card={x.ci} title={x.reset.title}>↺</span>{/if}{#if x.lock}<span class="lk" title={x.lock.title}><svg viewBox="0 0 12 12" width="9" height="9" aria-hidden="true"><path d="M3.5 5V3.6a2.5 2.5 0 0 1 5 0V5" fill="none" stroke="currentColor" stroke-width="1.5"/><rect x="2" y="5" width="8" height="6" rx="1.2" fill="currentColor"/></svg></span>{/if}{#if x.empty}<span class="elbl">{x.label}</span>{:else}{@html x.iconHtml}{#if x.aug}<span class="mk">◆</span>{/if}{#if x.rank !== null}<span class="rk">R{x.rank}</span>{/if}{/if}</button>{/snippet}

<article class="detail"><header><div class="settop">{@html view.titleHtml}{#if view.versions.k === 'none'}<div class="setvers none"></div>{:else if view.versions.k === 'grid'}<div class="setvers grid"><span class="kicker">{view.versions.label}</span><div class="vergrid" role="group" style="--n:{view.versions.cols.length}"><span></span>{#each view.versions.cols as c (c)}<span class="vh">{c}</span>{/each}{#each view.versions.rows as r, i (i)}<span class="vr">{r.label}</span>{#each r.cells as b, j (j)}{#if b}{@render ver(b)}{:else}<i class="vnone">—</i>{/if}{/each}{/each}</div></div>{:else}<div class="setvers"><span class="kicker">{view.versions.label}</span><div class="verseg" role="group">{#each view.versions.buttons as b, i (i)}{@render ver(b)}{/each}</div></div>{/if}{#if view.ctl}<div class="setctl">{#if view.ctl.picks}<div class="wpicks">{@html view.ctl.html}</div>{:else}{@html view.ctl.html}{/if}</div>{/if}</div>{@html view.trialHtml}</header>
    <div class="dbody"><div class="eqcol"><div class="slotcol"><div class="slots">{#each view.slots as x (x.slot)}{@render slot(x)}{/each}</div>{@html view.equipHtml}</div><footer>{#each view.footHtml as f, i (i)}<span>{@html f}</span>{/each}</footer>{@html view.wantsHtml}{@html view.legendHtml}{@html view.notesHtml}</div></div>
    <div class="globals-inline">{@html view.globalsHtml}</div></article>
