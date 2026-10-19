<!--
  GearSwap Atelier · the stats picker (statpick.ts): its own frame, a box a group of stats.

  @file    atelier/src/screens/dialogs/StatPick.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {StatPickView} from './statpick';

  let {view}: {view: StatPickView} = $props();
</script>

<div class="scrim" data-close></div><div class="dialog statpickdlg" role="dialog" aria-label={view.title}>
    <header><h3>{view.title}</h3><p class="muted small">{@html view.whyHtml}</p>{@html view.toolsHtml}</header>
    <div class="body"><div class="pickgrid">{#each view.groups as gr (gr.g)}<section class="box g-{gr.g} pickcol"><header class="boxh"><h3>{gr.title}</h3><span class="meta">{gr.on}/{gr.n} · <button class="linkbtn" data-statgroup="{gr.g}|1">{@html gr.all}</button> · <button class="linkbtn" data-statgroup="{gr.g}|0">{@html gr.none}</button></span></header><div class="pickrows">{#each gr.rows as r (r.k)}<label class="pickrow"><input type="checkbox" class="statpick" data-stat={r.k} checked={r.checked}><span>{r.label}</span></label>{/each}</div></section>{/each}</div></div>
    <footer><span><button class="btn ghost" data-statall>{@html view.allHtml}</button> <button class="btn ghost" data-statnone>{@html view.noneHtml}</button></span>
      <button class="btn" data-close>{@html view.closeHtml}</button></footer></div>
