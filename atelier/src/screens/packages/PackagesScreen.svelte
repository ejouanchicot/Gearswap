<!--
  GearSwap Atelier · the Packages page (packages.ts): who and which jobs on the left, two characters, the region and
  the making on the right.

  @file    atelier/src/screens/packages/PackagesScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';
  import {packagesView, type PkgSeg} from './packages';

  const view = $derived(legacy.version > 0 ? packagesView() : null);
</script>

{#snippet segRow(s: PkgSeg)}<div class="seg" role="group">{#each s.opts as o (o.v)}<button data-pkgset={s.key} data-v={o.v} aria-pressed={o.on}>{o.label}</button>{/each}</div>{/snippet}

{#if view}
  {@const w = view.who}{@const jb = view.jobs}{@const bx = view.box}{@const rg = view.region}{@const h = view.holds}
  <div class="cfg pkg"><header><h2>{view.title}</h2><button class="btn ghost" data-pkgopen>{'← ' + view.back}</button></header><p class="lede">{view.lede}</p><div class="cfgcols"><div><section class="box"><h3>{w.title}</h3><p>{w.why}</p><div class="cfgrow"><input id="pkgname" class="inp" placeholder={w.ph} value={w.name} maxlength="15" autocomplete="off"></div>{#if w.kind}<p class="small {w.kind.known ? '' : 'muted'}">{w.kind.text}</p>{/if}<div class="cfgrow pkgknown">{#if w.chars}{#each w.chars as c, i (c.name)}{#if i}{' '}{/if}<button class="btn ghost" data-pkgchar={c.name} aria-pressed={c.on}>{c.name + ' '}<small class="muted">{c.n}</small></button>{/each}{:else}<span>{w.noList}</span>{#if w.folder}<button class="btn ghost" data-pkgfolder>{w.folder}</button>{/if}{/if}</div></section><section class="box"><h3>{jb.title}</h3><p>{jb.why}</p><div class="seg pkgjobs" role="group">{#each jb.jobs as j (j.j)}<button data-pkgjob={j.j} aria-pressed={j.on}>{j.j}</button>{/each}</div><div class="cfgrow"><button class="btn ghost" data-pkgjobs="all">{jb.all}</button><button class="btn ghost" data-pkgjobs="none">{jb.none}</button></div></section></div><div><section class="box"><h3>{bx.title}</h3><p>{bx.why}</p><div class="cfgrow">{@render segRow(bx.seg)}</div>{#if bx.partner}<div class="cfgrow"><input id="pkgpartner" class="inp" placeholder={bx.partner.ph} value={bx.partner.value} maxlength="15" autocomplete="off"></div>{/if}</section><section class="box"><h3>{rg.title}</h3><p>{rg.why}</p><div class="cfgrow">{@render segRow(rg.seg)}</div></section><section class="box"><h3>{h.title}</h3><ul>{#each h.lines as l, i (i)}<li>{l}</li>{/each}</ul><p class="muted small">{h.never}</p><div class="cfgrow"><button class="btn" data-pkgmake disabled={h.busy}>{h.make}</button></div>{#if h.msg}<p class={h.msgCls}>{h.msg}</p>{#if h.doneHow}<p class="muted small">{h.doneHow}</p>{/if}{/if}</section></div></div></div>
{/if}
