<!--
  GearSwap Atelier · the windows that write to GearSwap's files (pushview.ts): pushing, deleting, adding a set, each
  with the file's lines folded (push_view.js data-pushtech keeps the fold's state).

  @file    atelier/src/screens/dialogs/PushView.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {PushView} from './pushview';

  let {view}: {view: PushView} = $props();
</script>

{#if view.kind === 'push'}{@html view.carryHtml}<ul class="orchg pushrows">{#each view.rows as r, i (i)}<li title={r.title}>{@html r.iconHtml}<span class="orfslot">{r.slot}</span><span>{#if r.from}<s>{r.from}</s>{' → '}{/if}{#if r.to.piece}<b>{r.to.text}</b>{:else}<i>{r.to.text}</i>{/if}</span></li>{/each}</ul>{#each view.warnsHtml as w, i (i)}<p class="kwarn">{@html w}</p>{/each}<p class="muted small">{@html view.safeHtml}</p>{:else if view.kind === 'del'}<p>{@html view.introHtml}</p>{#if view.alsoHtml}<p class="kwarn">{@html view.alsoHtml}</p>{/if}<p class="muted small">{@html view.safeHtml}</p>{:else}{@html view.carryHtml}<p class="muted small">{@html view.safeHtml}</p>{/if}<details class="pushtech" data-pushtech open={view.tech.open}><summary>{view.tech.summary}</summary><p class="muted small">{@html view.tech.fileHtml}</p>{@html view.tech.diffHtml}</details>
