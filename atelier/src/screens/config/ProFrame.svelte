<!--
  GearSwap Atelier · the frame of the job's settings (SPEC notes/docs-perso/config-pro-2026-10-30): the categories on
  the left (a search, then the categories under small headings), the options in one column in the middle, the detail
  of the option chosen on the right, the bar of the changes at the bottom. The three parts (Modes & keys, Settings,
  Macro book & lockstyle) give their own content; the look is atelier/app/css/config.css.

  @file    atelier/src/screens/config/ProFrame.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {Snippet} from 'svelte';
  import type {ProNav, ProDetail, ProFoot} from './pro';

  // credit: the icons' authors (pro.ts iconCredit), small at the bottom of the categories
  let {nav, head, detail, foot, credit = '', children}: {nav: ProNav; head: {iconHtml: string; title: string; sub: string}; detail: ProDetail | null; foot: ProFoot; credit?: string; children: Snippet} = $props();
</script>

<div class="cfgx">
  <nav class="cfg-nav">
    {#if nav.search}<label class="cfg-search"><span aria-hidden="true">⌕</span><input id={nav.search.id} type="search" value={nav.search.value} placeholder={nav.search.placeholder} autocomplete="off">{#if nav.search.value}<button type="button" data-modqclear aria-label={nav.search.clear}>×</button>{/if}</label>{/if}
    {#each nav.groups as g, gi (gi)}{#if g.label}<div class="cfg-nl">{g.label}</div>{/if}
      {#each g.items as it (it.id)}<button type="button" class="cfg-ni" class:on={it.current} {...it.attr}>{@html it.iconHtml}<span>{it.name}</span>{#if it.dot}<i class="cfg-dot" aria-hidden="true"></i>{/if}<small>{it.count}</small></button>{/each}
    {/each}
    {#if credit}<small class="cfg-credit">{credit}</small>{/if}
  </nav>
  <section class="cfg-list">
    <header class="cfg-head"><span class="cfg-hic">{@html head.iconHtml}</span><div><h1>{head.title}</h1>{#if head.sub}<p>{head.sub}</p>{/if}</div></header>
    {@render children()}
  </section>
  <aside class="cfg-det">
    {#if detail}
      <div class="cfg-hero"><span class="cfg-hic big">{@html detail.iconHtml}</span><div><h2>{detail.title}</h2>{#if detail.tag}<span class="cfg-tag">{detail.tag}</span>{/if}</div></div>
      {#if detail.what}<p class="cfg-what">{detail.what}</p>{/if}
      {#if detail.example}<div class="cfg-box"><h4>{detail.exampleTitle}</h4><p>{detail.example}</p></div>{/if}
      {#if detail.kv.length}<dl class="cfg-kv">{#each detail.kv as [k, v], i (i)}<dt>{k}</dt><dd>{v}</dd>{/each}</dl>{/if}
      {#if detail.reset}<button type="button" class="cfg-reset" {...detail.reset.attrs}>↺ {detail.reset.label}</button>{/if}
      {#if detail.foot}<small class="cfg-dfoot">{detail.foot}</small>{/if}
    {/if}
  </aside>
  <footer class="cfg-foot">
    {#if foot.msg}<span class="cfg-msg">{foot.msg}</span>{/if}
    {#if foot.n}
      <details class="cfg-wait"><summary><i aria-hidden="true"></i>{foot.text}</summary><ul>{#each foot.lines as l, i (i)}<li><b>{l.title}</b><span class="was">{l.was}</span><span aria-hidden="true">→</span><span class="now">{l.now}</span><button type="button" {...l.revert} title={foot.revertTip} aria-label={foot.revertTip}>×</button></li>{/each}</ul></details>
      <span class="cfg-sp"></span>
      {#if foot.undo}<button type="button" class="cfg-btn ghost" {...foot.undo.attrs}>{foot.undo.label}</button>{/if}
      {#if foot.save}<button type="button" class="cfg-btn" {...foot.save.attrs}>{foot.save.label}</button>{/if}
    {:else}<span class="cfg-ok">✓ {foot.ok}</span>{/if}
  </footer>
</div>
