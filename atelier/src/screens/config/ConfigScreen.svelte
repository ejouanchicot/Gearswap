<!--
  GearSwap Atelier · the job's settings (config.ts): the played jobs on the left, the parts' buttons, the part shown.
  Styles: atelier/app/css (.tabx, .tabmain, .jobcfg, sets.css "the job's settings").

  @file    atelier/src/screens/config/ConfigScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';
  import {configView} from './config';
  import JobList from './JobList.svelte';
  import Keys from './Keys.svelte';
  import Modes from './Modes.svelte';
  import Functions from './Functions.svelte';
  import Macro from './Macro.svelte';

  const view = $derived(legacy.version > 0 ? configView() : null);
</script>

{#if view}
  <div class="pane split"><div class="tabx"><JobList /><div class="tabmain"><div class="jobcfg">
    <div class="seg jobcfgtabs" role="group" aria-label={view.aria}>{#each view.tabs as tb (tb.key)}<button data-jobtab={tb.key} aria-pressed={tb.pressed} title={tb.title}>{tb.label}{#if tb.count !== ''}<span class="count">{tb.count}</span>{/if}</button>{/each}</div>
    {#if view.part.kind === 'keys'}<Keys view={view.part.view} />
    {:else if view.part.kind === 'modes'}<Modes view={view.part.view} />
    {:else if view.part.kind === 'functions'}<Functions view={view.part.view} />
    {:else if view.part.kind === 'macro'}<Macro view={view.part.view} />
    {:else}{@html view.part.html}{/if}
  </div></div></div></div>
{/if}
