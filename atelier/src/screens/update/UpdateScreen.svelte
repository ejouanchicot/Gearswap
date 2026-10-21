<!--
  GearSwap Atelier · the update screen (update.ts): the two versions and the search on the left, what installing
  changes, the notes and going back on the right.

  @file    atelier/src/screens/update/UpdateScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';
  import {updateView} from './update';

  const view = $derived(legacy.version > 0 ? updateView() : null);
</script>

{#if view}
  <div class="cfg upd">
    <header><h2>{view.title}</h2><button class="btn ghost" data-config>{'← ' + view.back}</button></header>
    <p class="lede">{view.lede}</p>
    <div class="cfgcols">
      <div>
        <section class="box">
          <dl class="updver"><dt>{view.have.label}</dt><dd>{view.have.v}</dd><dt>{view.latest.label}</dt><dd>{view.latest.v}</dd></dl>
          <div class="cfgrow"><button class="btn ghost" data-updcheck disabled={view.busy}>{view.check}</button></div>
          {#if view.step}<p class="muted">{view.step}</p>{/if}
          {#if view.folder}<p>{view.folder.text}</p><div class="cfgrow"><button class="btn" data-updfolder>{view.folder.btn}</button></div>{/if}
          {#if view.msg}<p class={view.msgCls}>{view.msg}</p>{/if}
          <p class="muted small">{view.safe}</p>
        </section>
      </div>
      <div>
        {#if view.plan}
          <section class="box">
            <p>{view.plan.line}</p>
            {#if view.plan.changed}<p class="small kwarn">{view.plan.changed}</p>{/if}
            {#if view.plan.kept}<p class="small muted">{view.plan.kept}</p>{/if}
            <div class="cfgrow"><button class="btn" data-updapply disabled={view.busy}>{'⬆ ' + view.plan.apply}</button></div>
          </section>
        {/if}
        {#if view.notes}
          <section class="box"><h3>{view.notes.title}</h3><p class="updnotes">{view.notes.text}</p>{#if view.notes.url}<p class="small"><a href={view.notes.url} target="_blank" rel="noopener">{view.notes.more}</a></p>{/if}</section>
        {/if}
        {#if view.undo}
          <section class="box"><p class="small muted">{view.undo.why}</p><div class="cfgrow"><button class="btn ghost" data-updundo>{'↶ ' + view.undo.label}</button></div></section>
        {/if}
      </div>
    </div>
  </div>
{/if}

<style>
  .updver { display: grid; grid-template-columns: max-content 1fr; gap: 4px 14px; margin: 0 0 10px; }
  .updver dt { color: var(--muted); }
  .updver dd { margin: 0; font-weight: 600; }
  .updnotes { white-space: pre-wrap; max-height: 320px; overflow: auto; }
</style>
