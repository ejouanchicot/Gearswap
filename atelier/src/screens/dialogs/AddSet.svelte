<!--
  GearSwap Atelier · the "+ Set" window (addset.ts): its own frame, the steps in its head, Back and Cancel at its foot.

  @file    atelier/src/screens/dialogs/AddSet.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {AddSetView} from './addset';

  let {view}: {view: AddSetView} = $props();
  const b = $derived(view.body);
</script>

<div class="scrim" data-close></div><div class="dialog" role="dialog" aria-label={view.title}><header><h3>{view.title}</h3><div class="steps">{#each view.steps as s, i (i)}<span class={s.on ? 'on' : ''}>{@html s.label}</span>{/each}</div></header>
    <div class="body">{#if b.kind === 'fams'}{#if b.warn}<p class="kwarn small">{b.warn}</p>{/if}{#each b.fams as f (f.f)}<button class="opt" data-addfam={f.f}><span>{@html f.label}<small>{@html f.when}</small></span><span>›</span></button>{/each}{:else if b.kind === 'catalog'}<input id="addq" class="gpq" type="search" placeholder={b.ph} autocomplete="off" spellcheck="false">{#each b.groups as g (g.g)}<details class="wsgroup addgroup" open={g.open} data-addgroup={g.g}><summary><b style="font-family:var(--mono)">{g.label}</b><span class="muted small">{g.count}</span>{#if g.when}<small class="muted">{g.when}</small>{/if}</summary>{#each g.rows as r (r.path)}{#if r.there}<button class="opt addrow" data-q={r.q} data-addopen={r.path}><span style="font-family:var(--mono);font-size:13px">{r.label}</span><span class="state">{@html view.exists + ' ›'}</span></button>{:else}<button class="opt addrow" data-q={r.q} data-addpick={r.path} disabled={!!r.why} title={r.why || undefined}><span style="font-family:var(--mono);font-size:13px">{r.label}</span><span class="state new">{@html view.addNew}</span></button>{/if}{/each}</details>{/each}{:else if b.kind === 'paths'}{#each b.paths as p, i (i)}<button class="opt" data-addopen={p}><span style="font-family:var(--mono);font-size:13px">{p}</span><span class="state">{@html view.exists + ' ›'}</span></button>{/each}{:else if b.kind === 'start'}<p><code>{b.path}</code></p>{#if b.when}<p class="muted small">{b.when}</p>{/if}<p class="muted small">{b.today}</p>{#each b.opts as o (o.k)}<button class="opt" data-addfrom={o.k}><span>{o.a}<small>{o.b}</small></span><span>›</span></button>{/each}{:else}{@html b.html}{/if}</div><footer><button class="btn ghost" data-back disabled={view.first}>{@html view.back}</button><button class="btn ghost" data-close>{@html view.cancel}</button></footer></div>
