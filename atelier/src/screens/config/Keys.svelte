<!--
  GearSwap Atelier · the Modes & keys part of the job's settings (keys.ts): the modes with their start value and key,
  then the other keys. The buttons keep the attributes the old page's handlers read (events.js data-modestart,
  data-keyedit, data-keysall, data-keysundo, data-keyssave): the window that changes a key is still the old page's
  (keys.js openKeyEdit).

  @file    atelier/src/screens/config/Keys.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import Box from '../../components/Box.svelte';
  import type {KeysView, KeyRow, ModeRow} from './keys';

  let {view}: {view: KeysView} = $props();
</script>

{#snippet note(r: KeyRow)}{#if r.note}<span class="kwas">{r.note}</span>{/if}{/snippet}
{#snippet help(r: KeyRow)}{#if r.help}<span class="shelp">{r.help}</span>{/if}{/snippet}
{#snippet mode(m: ModeRow)}
  <tr class:changed={m.changed}><td><b>{m.title}</b>{#if m.common}<span class="kwas">{view.modes.commonText}</span>{/if}<span class="state">state.{m.name}</span>{#if m.help}<span class="shelp">{m.help}</span>{/if}</td><td><span class="values mstart">{#each m.values as v (v.value)}<button type="button" class:def={v.start} class:file={v.file} data-modestart={m.name + '|' + v.value} title={v.tip} aria-pressed={v.start}>{v.value}</button>{/each}</span></td><td class="kcol">{@html m.keyHtml}</td><td class="r">{#if m.edit !== null}<button class="kedit" data-keyedit={m.edit} title={view.editHtml}>✎</button>{/if}</td></tr>
{/snippet}

<div class="keybar" class:dirty={view.bar.dirty}><span>{@html view.bar.textHtml}</span>{#if view.bar.others}<button class="linkbtn" data-keysall title={view.bar.others.title}>{@html view.bar.others.textHtml}</button>{/if}{#if view.bar.dirty}<span class="sp"></span><button class="btn ghost" data-keysundo>{@html view.bar.undoHtml}</button><button class="btn" data-keyssave>{@html view.bar.saveHtml}</button>{/if}</div>
{#if view.toast}<p class="toast">{view.toast}</p>{/if}
<div class="boxgrid cols">
  <Box cls="g-attr wide" title={view.modes.title} meta={view.modes.meta}><p class="shelp mhint">{view.modes.hint}</p><table class="tbl in"><tbody>
    {#each view.modes.rows as m (m.name)}{@render mode(m)}{/each}
  </tbody></table></Box>
  {#each view.boxes as b (b.key)}
    <Box cls={b.cls} title={b.title} meta={b.meta}><table class="tbl in"><tbody>
      {#each b.rows as r, n (n)}
        <tr class:other-sub={r.other} class:changed={r.changed}><td class="kcol">{@html r.keyHtml}{#if r.clash}<span class="kclash" title={r.clash}>!</span>{/if}</td><td>{#if r.code}<code>{r.code}</code>{:else}{r.desc}{/if}{#if r.was !== null}<span class="kwas">{@html view.wasHtml} {@html r.was}</span>{/if}{#if r.helpFirst}{@render help(r)}{@render note(r)}{:else}{@render note(r)}{@render help(r)}{/if}</td><td class="sub">{r.sub}</td><td class="r">{#if r.edit !== null}<button class="kedit" data-keyedit={r.edit} title={view.editHtml}>✎</button>{/if}</td></tr>
      {/each}
    </tbody></table></Box>
  {/each}
  {#if view.modes.away}<Box cls="g-caps wide" title={view.modes.away.title} meta={String(view.modes.away.rows.length)}><table class="tbl in"><tbody>
    {#each view.modes.away.rows as m (m.name)}{@render mode(m)}{/each}
  </tbody></table></Box>{/if}
</div>
