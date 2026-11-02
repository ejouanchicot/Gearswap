<!--
  GearSwap Atelier · one setting of Buffs & target (panel.ts Control): a list, a button opening a list, a switch, a note
  or a chip. Drawn in a member's panel (Panel.svelte) and on its line of the party (CombatScreen.svelte). The controls
  keep the attributes the old page's handlers read (events.js, buffs.js, party_builder.js pbClick).

  @file    atelier/src/screens/combat/Ctl.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {selSync} from '../../components/selsync';
  import type {Control} from './panel';

  let {c}: {c: Control} = $props();
</script>

{#if c.k === 'select'}<select class={c.cls} {...c.attrs} title={c.title} use:selSync={(c.options.find(o => o.selected) || {}).value}>{#each c.options as o, i (i)}<option value={o.value} selected={o.selected}>{o.label}</option>{/each}</select>{:else if c.k === 'pick'}<button class="pbpick {c.set ? 'set' : ''}" data-pbpick={c.key} title={c.title}><span>{c.label}</span><i>▾</i></button>{:else if c.k === 'switch'}<button class="tgl pbsw" {...c.attrs} aria-pressed={c.on} title={c.title}></button>{:else if c.k === 'note'}<span class="muted small">{c.text}</span>{:else}<button class="chip" {...c.attrs} aria-pressed={c.pressed} disabled={c.disabled} title={c.title}>{c.label}</button>{/if}
