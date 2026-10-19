<!--
  GearSwap Atelier · the history's body (history.ts): a fold an entry, Undo while it can be undone.

  @file    atelier/src/screens/dialogs/History.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {HistoryView} from './history';

  let {view}: {view: HistoryView} = $props();
</script>

{#if view.toast}<p class="ok">{view.toast}</p>{/if}{#each view.entries as e, i (i)}<details class="histrow {e.undone ? 'undone' : ''}"><summary class="histhead"><span class="histtag {e.kind}">{e.tag}</span><b>{e.job}</b><code>{e.path}</code><span class="muted small">{e.at}</span><span class="sp"></span>{#if e.state.k === 'undone'}<span class="muted small">{e.state.text}</span>{:else if e.state.k === 'undo'}<button class="btn ghost" data-pushundo={e.state.id}>{@html e.state.html}</button>{:else}<span class="muted small" title={e.state.title}>{@html e.state.html}</span>{/if}</summary><p class="muted small histfile">{e.file}</p>{#if e.deleted}<ul><li><del>{e.deleted.text}</del>{@html e.deleted.html}</li></ul>{/if}<ul>{#each e.changes as c, j (j)}<li><b>{@html c.slotHtml}</b>{c.before ? ' ' : ' + '}{#if c.before}<del>{c.before}</del>{' → '}{/if}<ins>{c.after}</ins></li>{/each}</ul></details>{:else}<p class="muted">{@html view.emptyHtml}</p>{/each}
