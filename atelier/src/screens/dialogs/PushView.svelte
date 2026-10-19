<!--
  GearSwap Atelier · the windows that write to GearSwap's files (pushview.ts): pushing, deleting, adding a set, each
  with the file's lines folded (push_view.js data-pushtech keeps the fold's state).

  @file    atelier/src/screens/dialogs/PushView.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import MogNote from '../../components/MogNote.svelte';
  import type {PushView, DiffLine} from './pushview';

  let {view}: {view: PushView} = $props();
</script>

{#snippet diff(lines: DiffLine[])}<div class="diff">{#each lines as l, i (i)}<div class={l.k}>{(l.k === 'add' ? '+ ' : l.k === 'del' ? '− ' : '  ') + l.text}</div>{/each}</div>{/snippet}

{#if view.kind === 'push'}<MogNote pose="carry" html={view.carryHtml} /><ul class="orchg pushrows">{#each view.rows as r, i (i)}<li title={r.title}>{@html r.iconHtml}<span class="orfslot">{r.slot}</span><span>{#if r.from}<s>{r.from}</s>{' → '}{/if}{#if r.to.piece}<b>{r.to.text}</b>{:else}<i>{r.to.text}</i>{/if}</span></li>{/each}</ul>{#each view.warnsHtml as w, i (i)}<p class="kwarn">{@html w}</p>{/each}<p class="muted small">{@html view.safeHtml}</p>{:else if view.kind === 'del'}<p>{@html view.introHtml}</p>{#if view.alsoHtml}<p class="kwarn">{@html view.alsoHtml}</p>{/if}<p class="muted small">{@html view.safeHtml}</p>{:else if view.kind === 'create' && view.create}<p>{@html view.create.whereHtml}</p>{@render diff(view.create.diff)}<p class="muted small">{view.create.note}</p>{:else}<MogNote pose="carry" html={view.carryHtml} /><p class="muted small">{@html view.safeHtml}</p>{/if}{#if view.tech}<details class="pushtech" data-pushtech open={view.tech.open}><summary>{view.tech.summary}</summary><p class="muted small">{@html view.tech.fileHtml}</p>{@render diff(view.tech.diff)}</details>{/if}
