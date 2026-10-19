<!--
  GearSwap Atelier · the home page (home.ts): the played jobs in a table, or how to fill the page when nothing is
  exported yet. A row keeps data-job (events.js opens the job), the files' button data-wcread (welcome.js).

  @file    atelier/src/screens/home/HomeScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';
  import {homeView} from './home';

  const view = $derived(legacy.version > 0 ? homeView() : null);
</script>

{#if view && view.welcome}
  {@const w = view.welcome}
  <div class="cfg welcome"><header><h2>{w.title}</h2></header><p class="lede">{w.lede}</p><div class="cfgcols"><section class="box"><h3>{w.gameT}</h3><ol>{#each w.steps as parts, i (i)}<li>{#each parts as x, j (j)}{#if j % 2}<code>{x}</code>{:else}{x}{/if}{/each}</li>{/each}</ol><p class="muted small">{w.gameWhy}</p></section><section class="box"><h3>{w.filesT}</h3><p>{w.files1}</p><p class="muted small">{w.filesWhy}</p><div class="cfgrow"><button class="btn" data-wcread disabled={w.busy}>{w.btn}</button></div>{#if w.msg}<p class={w.fail ? 'kwarn' : 'muted'}>{w.msg}</p>{/if}</section></div></div>
{:else if view && view.table}
  {@const tb = view.table}
  <header class="pagehead"><div class="kicker">{@html tb.kicker}</div><h1 class="display">{tb.char}</h1><p class="lede">{@html tb.summary}</p></header>
  <div class="pane"><div class="tblwrap"><table class="tbl click"><thead><tr>{#each tb.heads as h, i (i)}<th class={i === 3 || i === 4 ? 'r' : undefined}>{@html h}</th>{/each}</tr></thead><tbody>{#each tb.rows as r (r.c)}<tr data-job={r.c} class={r.dim ? 'dim' : ''} style="--role:{r.roleColor}"><td><span class="jobcell">{@html r.emblemHtml}<b>{r.c}</b><span class="muted">{@html r.name}</span>{@html r.badgeHtml}</span></td><td><span class="role">{@html r.role}</span></td><td class="sub">{r.sub}</td><td class="num r">{r.sets}</td><td class="num r">{r.keys}</td><td class="num">{@html r.bookHtml}</td><td class="num">{@html r.styleHtml}</td><td class="num muted">{@html r.atHtml}</td></tr>{/each}</tbody></table></div><p class="note-foot">{@html tb.foot}</p></div>
{/if}
