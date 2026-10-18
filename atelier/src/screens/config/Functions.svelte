<!--
  GearSwap Atelier · the Functions part of the job's settings: the on / off switches in two columns (modes.ts).

  @file    atelier/src/screens/config/Functions.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import Box from '../../components/Box.svelte';
  import type {FunctionsView} from './modes';

  let {view}: {view: FunctionsView} = $props();
</script>

<div class="keybar"><span>{@html view.barHtml}</span></div>
<div class="boxgrid cols">
  <Box cls="g-mag wide" title={view.title} meta={view.meta}><div class="fn2">
    {#each view.columns as col, c (c)}
      <table class="tbl in"><tbody>
        {#each col as m (m.name)}
          <tr><td class="swcol"><span class="sw" class:on={m.on} aria-hidden="true"></span></td><td><b>{m.title}</b><span class="state">state.{m.name}</span>{#if m.help}<span class="shelp">{m.help}</span>{/if}</td><td>{@html m.on ? view.onHtml : view.offHtml}</td><td class="r">{@html m.keyHtml}</td></tr>
        {/each}
      </tbody></table>
    {/each}
  </div></Box>
</div>
