<!--
  GearSwap Atelier · the application. Until the screens move to Svelte (notes/docs-perso/audit-atelier-ts-svelte-
  2026-10-17/RAPPORT.md), it holds the old page: the frame its code draws into (the top bar, the view, the windows,
  the tooltip), then its styles and scripts, loaded in their order (legacy/load.ts).

  @file    atelier/src/App.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {onMount} from 'svelte';
  import {loadLegacy} from './legacy/load';
  import {markLoaded} from './bridge';

  onMount(() => { loadLegacy().then(markLoaded); });
</script>

<div class="app">
  <header class="topbar" id="top"></header>
  <main class="main"><div class="inner" id="view"></div></main>
</div>
<div id="overlay" hidden></div>
<div id="tip" class="tip" role="tooltip" hidden></div>
