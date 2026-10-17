<!--
  GearSwap Atelier · the application: the top bar and the job's sections (Svelte, screens/topbar), then the old page while its screens move
  to Svelte (notes/docs-perso/audit-atelier-ts-svelte-2026-10-17/RAPPORT.md): the frame its code draws into (the
  view, the windows, the tooltip), its styles and scripts, loaded in their order (legacy/load.ts).

  @file    atelier/src/App.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {onMount} from 'svelte';
  import {loadLegacy} from './legacy/load';
  import {markLoaded} from './bridge';
  import TopBar from './screens/topbar/TopBar.svelte';
  import Sections from './screens/topbar/Sections.svelte';

  onMount(() => { loadLegacy().then(markLoaded); });
</script>

<div class="app">
  <header class="topbar" id="top"><TopBar /></header>
  <main class="main"><div class="inner"><Sections /><div id="view"></div></div></main>
</div>
<div id="overlay" hidden></div>
<div id="tip" class="tip" role="tooltip" hidden></div>

<style>
  /* the old page's view lays its blocks out as the frame's own children (.inner, a column: the sections then the pane,
     atelier/app/css/base.css), as when the sections were drawn inside it */
  :global(#view) { display: contents; }
</style>
