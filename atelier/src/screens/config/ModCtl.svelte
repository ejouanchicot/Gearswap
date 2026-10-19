<!--
  GearSwap Atelier · the control of a Modules setting (modules.ts ModCtl): buttons for a choice (an "auto" one with its
  field to force a value), a switch, a text field, the setting as written when the page cannot change it. Numbers,
  colours, lists and tables are still the old page's HTML (module_ux.js, module_items.js, module_rows.js). The controls
  keep the attributes the old handlers read (data-modfile, data-modpath, data-modopt, data-mcchoice, data-modin,
  data-modbool).

  @file    atelier/src/screens/config/ModCtl.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {ModCtl} from './modules';

  let {c}: {c: ModCtl} = $props();
</script>

{#if c.k === 'seg'}<span class="modseg">{#each c.btns as b, i (i)}<button {...b.attrs} {...c.id} aria-pressed={b.pressed} disabled={c.off} title={b.tip}>{b.label}</button>{/each}</span>{#if c.input}<input class="modin num" type="text" value={c.input.value} placeholder={c.input.ph} {...c.id} data-modin disabled={c.off} title={c.input.tip}>{/if}{:else if c.k === 'switch'}<button class="modsw" role="switch" aria-checked={c.on} {...c.id} data-modbool disabled={c.off} title={c.tip}><span class="sw {c.on ? 'on' : ''}" aria-hidden="true"></span><b>{@html c.labelHtml}</b></button>{:else if c.k === 'text'}<input class="modin" type="text" value={c.value} {...c.id} data-modin disabled={c.off} title={c.tip}>{:else if c.k === 'code'}<details class="modadv"><summary>{c.summary}</summary><pre class="modcode">{c.code}</pre></details>{:else}{@html c.html}{/if}
