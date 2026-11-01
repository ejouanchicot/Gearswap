<!--
  GearSwap Atelier · the "+ Set" window as an assistant (addset.ts, add_wizard.js): when, what, the questions that
  change the set, a summary in words; the experts' list of every name. Styles: atelier/app/css/sets.css (.awdlg).

  @file    atelier/src/screens/dialogs/AddSet.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {AddSetView} from './addset';

  let {view}: {view: AddSetView} = $props();
  const b = $derived(view.body);
</script>

<div class="scrim" data-close></div><div class="dialog awdlg" role="dialog" aria-label={view.title}><header><h3>{view.title}</h3><div class="steps">{#each view.steps as s, i (i)}<span class="{s.on ? 'on' : ''} {s.done ? 'done' : ''}">{s.label}{s.done ? ' ✓' : ''}</span>{/each}</div></header>
<div class="body">
{#if b.kind === 'fams'}
  <p class="awq">{b.ask}</p>{#if b.warn}<p class="kwarn small">{b.warn}</p>{/if}
  <div class="awtiles">{#each b.fams as f (f.f)}<button class="awtile" data-awfam={f.f}>{@html f.icon}<b>{@html f.label}</b><small>{@html f.when}</small></button>{/each}</div>
{:else if b.kind === 'subjects'}
  <input id="awq" class="gpq awsearch" type="search" placeholder={b.ph} autocomplete="off" spellcheck="false">
  {#each b.groups as g (g.label)}<section class="awgroup" style={g.color ? `--sc:${g.color}` : undefined}><h4>{g.label} <em>· {g.count}</em></h4>{#snippet chip(c: import('./addset').AwChip)}<button class="awchip {c.all ? 'all' : ''} {c.fam ? 'famc' : ''} {c.has ? 'has' : ''}" data-awsubj={c.key} data-awq={c.q} title={c.has ? b.hasTip : undefined}><span class="nm">{c.label}</span>{#if c.tierList.length}<span class="tiers">{#each c.tierList as x (x)}<i>{x}</i>{/each}</span>{/if}{#if c.has}<span class="hasb">✓</span>{/if}</button>{/snippet}<div class="awchips">{#each g.chips as c (c.key)}{@render chip(c)}{/each}</div>{#each g.packs as p (p.label)}<p class="awsub">{p.label}</p><div class="awchips">{#each p.chips as c (c.key)}{@render chip(c)}{/each}</div>{/each}{#if g.fams.length}<p class="awsub">{b.famLabel}</p><div class="awchips">{#each g.fams as c (c.key)}{@render chip(c)}{/each}</div>{/if}</section>{/each}
  <p class="awnote">✓ : {b.hasTip}. <button class="linkbtn" data-awexpert>{b.expert}</button></p>
{:else if b.kind === 'ask'}
  {#each b.questions as q (q.k)}<section class="awask"><p class="awq">{q.label}</p><div class="awopts">{#each q.opts as o (o.value)}<button class="awopt {o.on ? 'on' : ''}" data-awans={q.k + ':' + o.value} aria-pressed={o.on}><b>{o.label}{#if o.rec}<span class="rec">{view.rec}</span>{/if}</b>{#if o.desc}<small>{o.desc}</small>{/if}</button>{/each}</div></section>{/each}
{:else if b.kind === 'sum'}
  <div class="awrecap"><p class="say">{b.say}</p>
  {#if b.has}<div class="awrow"><span>{b.nameLabel}</span><code>{b.has.path}</code></div><div class="awrow"><span></span><div>{b.has.game}</div></div>
  {:else}<div class="awrow"><span>{b.todayLabel}</span><div>{b.today}</div></div>
  <div class="awrow"><span>{b.startLabel}</span><div class="awopts">{#each b.opts as o (o.k)}<button class="awopt" data-awfrom={o.k} disabled={!!b.block}><b>{o.a}{#if o.rec}<span class="rec">{view.rec}</span>{/if}</b><small>{o.b}</small></button>{/each}</div></div>
  <div class="awrow"><span>{b.nameLabel}</span><div><code>{b.name}</code>{#if b.also}<details class="awalso"><summary>{b.also}</summary>{#each b.alsoList as p (p)}<code>{p}</code>{/each}</details>{/if}</div></div>{/if}
  </div>
  {#if b.block}<p class="kwarn small">{b.block}</p>{:else if !b.has}<p class="awnote">{b.file}</p>{/if}
{:else if b.kind === 'expert'}
  <input id="awq" class="gpq awsearch" type="search" placeholder={b.ph} autocomplete="off" spellcheck="false">
  {#each b.groups as g (g.label)}<section class="awgroup awexp"><h4>{g.label}</h4>{#each g.rows as r (r.path)}<div class="awline" data-awq={r.q}><b>{r.say}</b>{#if r.there}<button class="awtag ok" data-addopen={r.path}>{b.open}</button>{:else}<button class="awtag" data-awpick={r.path} disabled={!!r.why} title={r.why || undefined}>{b.create}</button>{/if}<code>{r.path}</code>{#if r.others.length}<details class="awalso"><summary>+{r.others.length}</summary>{#each r.others as p (p)}<code>{p}</code>{/each}</details>{/if}</div>{/each}</section>{/each}
{:else if b.kind === 'paths'}
  {#each b.paths as p, i (i)}<button class="opt" data-addopen={p}><span style="font-family:var(--mono);font-size:13px">{p}</span><span class="state">{@html view.exists + ' ›'}</span></button>{/each}
{:else}{@html b.html}{/if}
</div>
<footer><button class="btn ghost" data-back disabled={view.first}>{@html view.back}</button><button class="btn ghost" data-close>{@html view.cancel}</button><span class="sp"></span>{#if b.kind === 'ask'}<button class="btn" data-awnext>{b.next}</button>{/if}{#if b.kind === 'sum' && b.has}<button class="btn" data-addopen={b.has.path}>{b.has.open}</button>{/if}</footer></div>
