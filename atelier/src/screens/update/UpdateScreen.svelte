<!--
  GearSwap Atelier · the update screen (update.ts): the two versions and the search on the left, what installing
  changes, the notes and going back on the right.

  @file    atelier/src/screens/update/UpdateScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';
  import {updateView, type NoteRun} from './update';

  const view = $derived(legacy.version > 0 ? updateView() : null);
</script>

{#snippet runs(list: NoteRun[])}{#each list as r, i (i)}{#if r.code}<code>{r.text}</code>{:else if r.bold}<strong>{r.text}</strong>{:else}{r.text}{/if}{/each}{/snippet}

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
          <section class="box"><h3>{view.notes.title}</h3>
            <div class="updnotes">
              {#each view.notes.blocks as b, i (i)}
                {#if b.k === 'h'}<h4>{@render runs(b.runs)}</h4>
                {:else if b.k === 'p'}<p>{@render runs(b.runs)}</p>
                {:else}<ul>{#each b.items as it, j (j)}<li>{@render runs(it)}</li>{/each}</ul>{/if}
              {/each}
            </div>
            {#if view.notes.url}<p class="small updmore"><a href={view.notes.url} target="_blank" rel="noopener">{view.notes.more + ' ↗'}</a></p>{/if}</section>
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
  .updnotes { max-height: 420px; overflow: auto; padding-right: 6px; line-height: 1.55; }
  .updnotes > :first-child { margin-top: 0; }
  .updnotes p { margin: 0 0 10px; }
  .updnotes > p:first-child { font-size: 1.05em; color: var(--ink); }
  .updnotes h4 { margin: 16px 0 6px; padding-bottom: 4px; border-bottom: 1px solid var(--line); color: var(--ink);
    font-size: 13.5px; font-weight: 650; }
  .updnotes ul { margin: 0 0 10px; padding: 0; list-style: none; }
  .updnotes li { position: relative; padding: 3px 0 3px 18px; }
  .updnotes li::before { content: ''; position: absolute; left: 4px; top: .85em; width: 6px; height: 6px;
    border-radius: 50%; background: var(--accent); }
  .updnotes strong { font-weight: 650; color: var(--ink); }
  .updnotes code { font-family: var(--mono); font-size: .9em; padding: 1px 5px; border-radius: var(--radius-s);
    background: var(--panel-2); border: 1px solid var(--line); white-space: nowrap; }
  .updmore { margin: 10px 0 0; padding-top: 8px; border-top: 1px solid var(--line); }
  .updmore a { color: var(--accent); text-decoration: none; font-weight: 600; }
  .updmore a:hover { text-decoration: underline; }
</style>
