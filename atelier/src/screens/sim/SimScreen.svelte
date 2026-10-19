<!--
  GearSwap Atelier · Simulate (sim.ts): the job's actions on the left, the options and the game's answer on the right.

  @file    atelier/src/screens/sim/SimScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {selSync} from '../../components/selsync';
  import {legacy} from '../../stores/legacy.svelte';
  import {simView, type SimChip} from './sim';

  const view = $derived(legacy.version > 0 ? simView() : null);
</script>

{#snippet chips(list: SimChip[])}{#each list as c (c.v)}<button data-simopt="{c.key}|{c.v}" aria-pressed={c.on}>{@html c.label}</button>{/each}{/snippet}

{#if view && view.placeholder}
  <div class="pane split"><div class="placeholder"><p>{@html view.placeholder.html}</p>{#if view.placeholder.restart}<button class="btn" data-liverestart>{@html view.placeholder.restart}</button>{/if}</div></div>
{:else if view}
  <div class="pane split"><div class="simx"><aside class="setlist"><div class="search"><input id="simq" type="search" placeholder={view.ph} value={view.q} autocomplete="off" spellcheck="false"></div><div class="scroll">{#if view.groups}{#each view.groups as g (g.key)}<button class="fam {g.here ? 'here' : ''}" data-simgroup={g.key} aria-expanded={g.open}><span>{g.label}</span><span>{g.rows.length}</span></button>{#if g.open}{#each g.rows as r (r.k + '|' + r.n)}<button class="setrow" data-simpick="{r.k}|{r.n}" aria-current={r.current}><b>{r.label}</b></button>{/each}{/if}{/each}{:else}<p class="muted small" style="padding:12px">{@html view.loading}</p>{/if}</div></aside><div class="simmain"><section class="box g-you"><header class="boxh"><h3>{@html view.title}</h3><span class="meta">{@html view.metaHtml}</span></header><div class="boxb"><div class="simopts"><div class="variants">{@render chips(view.targets)}</div><div class="variants">{@render chips(view.status)}</div><label class="chip"><input type="checkbox" class="simrecasts" checked={view.recasts}>{@html ' ' + view.recastsLabel}</label>{#if view.tp}<div class="variants"><span class="simtplbl">TP</span>{@render chips(view.tp.steps)}<input class="tpin" data-sim="1" type="number" min="0" max="3000" step="10" value={view.tp.value} placeholder={view.tp.ph} aria-label="TP"></div>{/if}</div>{#if view.buffs}<div class="simopts"><span class="simtplbl">{@html view.buffs.label}</span><div class="variants">{#each view.buffs.list as b (b.b)}<button data-simbuff={b.b} aria-pressed={b.on}>{b.b}</button>{/each}</div></div>{/if}<details class="simmodes"><summary>{@html view.modesLabel}</summary><div class="simmodegrid">{#each view.modes as m (m.name)}<label class="simmode {m.set ? 'set' : ''}"><span>{m.label}</span><select class="buffsel" data-simstate={m.name} use:selSync={m.cur}>{#each m.values as v (v)}<option selected={v === m.cur}>{v}</option>{/each}</select></label>{/each}</div></details></div></section>{@html view.resultHtml}</div></div></div>
{/if}
