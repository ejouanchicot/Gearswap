<!--
  GearSwap Atelier · the Modules part of the job's settings (modules.ts): the search and the two views on top, the
  left column, the presentation, the options, the file opened, the changes that wait. The buttons keep the attributes
  the old page's handlers read (modules.js, module_ux.js: data-modview, data-modfam, data-modopen, data-modgrp,
  data-modsave, data-modundo, data-modrevert, data-modqclear; the search box #modq); a setting's control is the old
  page's HTML (ModCtl.svelte: numbers, colours, lists, tables).

  @file    atelier/src/screens/config/Modules.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import ModCtl from './ModCtl.svelte';
  import Box from '../../components/Box.svelte';
  import type {ModulesView, ModItem, ModRow, ModCard, Nav} from './modules';

  let {view}: {view: ModulesView} = $props();
</script>

{#snippet card(c: ModCard)}<div class="mccard" class:changed={c.changed} class:tall={c.tall}><div class="mck"><b>{c.title}</b>{#if c.desc}<p>{c.desc}</p>{/if}<span class="mcscope {c.scope.cls}" title={c.scope.tip}>{c.scope.text}</span></div><div class="modv"><ModCtl c={c.ctl} /></div></div>{/snippet}
{#snippet key(r: ModRow)}<div class="modk"><b>{r.key.name}</b>{#if r.key.code !== null}<code>{r.key.code}</code>{/if}{#if r.key.doc}<p>{r.key.doc}</p>{/if}</div>{/snippet}
{#snippet row(r: ModRow)}{#if r.grp}<div class="modrow grp" class:tint={!!r.tintHtml} style="--d:{r.depth}">{@render key(r)}{#if r.tintHtml}<div class="modv">{@html r.tintHtml}</div>{/if}</div>{:else}<div class="modrow" class:changed={r.changed} class:tall={r.tall} style="--d:{r.depth}">{@render key(r)}<div class="modv">{#if r.ctl}<ModCtl c={r.ctl} />{/if}</div></div>{/if}{/snippet}
{#snippet items(list: ModItem[])}{#each list as it, i (i)}{#if it.kind === 'part'}<h4 class="modpart">{it.title}{#if it.why}<small>{it.why}</small>{/if}</h4>{:else if it.kind === 'card'}{@render card(it.card)}{:else}{@render row(it.row)}{/if}{/each}{/snippet}
{#snippet nav(n: Nav)}<nav class="modnav box">{#if n.intro}<button class="modfile" data-modfam={n.intro.value} aria-current={n.intro.current} title={n.intro.title}><b>{n.intro.name}</b><small>{n.intro.small}</small></button>{/if}{#each n.groups as g (g.id)}<div class="modgrp" class:open={g.open}><button class="modgrph" data-modgrp={g.id} data-open={g.open} aria-expanded={g.open} title={g.title}><i aria-hidden="true">▸</i><b>{g.name}</b>{#if g.changed}<em class="moddot">{g.changed}</em>{/if}<small>{g.count}</small></button>{#if g.open}{#each g.entries as e (e.value)}{#if e.attr === 'data-modopen'}<button class="modfile" data-modopen={e.value} aria-current={e.current} title={e.title}><b>{e.name}</b><small>{e.small}</small>{#if e.dot}<i class="moddot">{e.dot}</i>{/if}</button>{:else}<button class="modfile" data-modfam={e.value} aria-current={e.current} title={e.title}><b>{e.name}</b><small>{e.small}</small>{#if e.dot}<i class="moddot">{e.dot}</i>{/if}</button>{/if}{/each}{/if}</div>{/each}</nav>{/snippet}

{#if view.none !== null}
  <div class="keybar"><span>{view.none}</span></div>
{:else}
  <div class="keybar modtop"><input id="modq" class="tgq" type="search" value={view.top.q} placeholder={view.top.placeholder} title={view.top.title} autocomplete="off">{#if view.top.clear}<button class="btn ghost" data-modqclear title={view.top.clear.title}>{view.top.clear.text}</button>{:else}<span class="modhint">{view.top.hint}</span>{/if}<span class="seg modviews" role="group">{#each view.top.views as v (v.value)}<button data-modview={v.value} aria-pressed={v.pressed} title={v.title}>{v.label}</button>{/each}</span></div>
  {#if view.top.lock}<div class="modlock"><b>{view.top.lock.title}</b><span>{view.top.lock.text}</span></div>{/if}
  {#if view.toast}<p class="toast">{view.toast}</p>{/if}
  {#if view.body}
    {@const b = view.body}
    {#if b.kind === 'search'}
      <div class="modpanel modfound"><Box cls="g-attr wide" title={b.title}><div class="modrows">{@render items(b.items)}{#if b.more}<p class="muted modnone">{b.more}</p>{/if}{#if b.none}<p class="muted modnone">{b.none}</p>{/if}</div></Box></div>
    {:else if b.kind === 'intro'}
      <div class="modlayout">{@render nav(b.nav)}<div class="modpanel"><Box cls="g-attr wide" title={b.intro.title}><div class="mccards mcintro"><section><h4>{b.intro.job}</h4>{#if b.intro.lead}<p class="mclead">{b.intro.lead}</p>{/if}{#if b.intro.points.length}<ul class="mcpoints">{#each b.intro.points as pt, i (i)}<li>{#if pt.b}<b>{pt.b}</b>{/if}<span>{pt.text}</span></li>{/each}</ul>{/if}<p class="mcnext">{@html b.intro.where}{' '}{#each b.intro.links as l, i (l.tab)}{#if i}{' · '}{/if}<button class="linkbtn" data-jobtab={l.tab}>{l.label}</button>{/each}{#if b.intro.own}{' · '}<button class="linkbtn" data-modfam="job">{b.intro.own.label}</button>{/if}</p></section><section><h4>{b.intro.allTitle}</h4><p class="mclead">{b.intro.allWhy}</p>{#each b.intro.groups as g (g.name)}<h5>{g.name}</h5><div class="mcmods">{#each g.mods as m (m.fam)}<button class="mcmod" data-modfam={m.fam} title={m.title}><b>{m.name}</b><span>{m.tip}</span><i>{m.count + ' →'}</i></button>{/each}</div>{/each}</section></div></Box></div></div>
    {:else if b.kind === 'family'}
      <div class="modlayout">{@render nav(b.nav)}<div class="modpanel"><Box cls="g-attr wide" title={b.title} meta={b.meta}><div class="mccards"><div class="mcabout"><p>{b.tip}</p>{#if b.use}<p class="mcuse"><b>{b.use.label}</b>{b.use.text}</p>{/if}</div>{#each b.cards as c, i (i)}{@render card(c)}{/each}</div></Box></div></div>
    {:else}
      <div class="modlayout">{@render nav(b.nav)}<div class="modpanel"><Box cls="g-attr wide" title={b.title} meta={b.meta} metaTitle={b.metaTitle}><div class="modrows"><div class="mcabout"><p>{b.what}</p><p class="mcuse"><span class="mcscope {b.scope.cls}" title={b.scope.tip}>{b.scope.text}</span></p>{#if b.manual}<details class="modabout"><summary>{b.manual.summary}</summary><pre>{b.manual.text}</pre></details>{/if}</div>{@render items(b.items)}{#if b.adv}<details class="modadvall"><summary>{b.adv.summary}</summary>{#each b.adv.rows as r, i (i)}{@render row(r)}{/each}</details>{/if}{#if b.empty}<p class="muted modnone">{b.empty}</p>{/if}</div></Box></div></div>
    {/if}
  {/if}
  {#if view.save}
    <div class="modsave" role="region"><div class="mshead"><b title={view.save.tip}>{view.save.title}</b><span class="sp"></span><button class="btn ghost" data-modundo title={view.save.undo.title}>{view.save.undo.text}</button><button class="btn" data-modsave title={view.save.save.title}>{view.save.save.text}</button></div><ul>{#each view.save.lines as l (l.file + '|' + l.path)}<li><b>{l.title}</b><span class="was">{l.was}</span><i aria-hidden="true">→</i><span class="now">{l.now}</span><button data-modrevert data-modfile={l.file} data-modpath={l.path} title={view.save.revert} aria-label={view.save.revert}>×</button></li>{/each}</ul></div>
  {/if}
{/if}
