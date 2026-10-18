<!--
  GearSwap Atelier · the Modes part of the job's settings (modes.ts).

  @file    atelier/src/screens/config/Modes.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import Box from '../../components/Box.svelte';
  import type {ModesView} from './modes';

  let {view}: {view: ModesView} = $props();
</script>

<div class="keybar"><span>{@html view.barHtml}</span></div>
<div class="boxgrid cols">
  {#each view.boxes as b (b.key)}
    <Box cls={b.cls} title={b.title} meta={b.meta}><table class="tbl in"><tbody>
      {#each b.rows as m (m.name)}
        <tr><td><b>{m.title}</b><span class="state">state.{m.name}</span>{#if m.help}<span class="shelp">{m.help}</span>{/if}</td><td><span class="values">{#each m.values as v, i (i)}<span class={v.current ? 'def' : ''}>{v.value}</span>{/each}</span></td><td class="r">{@html m.keyHtml}</td></tr>
      {/each}
    </tbody></table></Box>
  {/each}
</div>
