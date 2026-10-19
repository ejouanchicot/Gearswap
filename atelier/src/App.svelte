<!--
  GearSwap Atelier · the application: the top bar and the job's sections (Svelte, screens/topbar), the screens moved to
  Svelte (screens/config: the job's settings, screens/perso: My character, screens/combat: Buffs & target, screens/sets: Sets, screens/home: the home page and a job with no export, screens/settings: the page's Settings, screens/packages: the Packages page, screens/sim: Simulate) beside the old page's part of the view (#legacyview), and the old page
  while its screens move (notes/docs-perso/audit-atelier-ts-svelte-2026-10-17/RAPPORT.md): its frame (the windows, the
  tooltip), its styles and scripts, loaded in their order (legacy/load.ts).

  @file    atelier/src/App.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {onMount} from 'svelte';
  import {loadLegacy} from './legacy/load';
  import {markLoaded} from './bridge';
  import TopBar from './screens/topbar/TopBar.svelte';
  import Sections from './screens/topbar/Sections.svelte';
  import HomeScreen from './screens/home/HomeScreen.svelte';
  import NoExport from './screens/home/NoExport.svelte';
  import SettingsScreen from './screens/settings/SettingsScreen.svelte';
  import PackagesScreen from './screens/packages/PackagesScreen.svelte';
  import SimScreen from './screens/sim/SimScreen.svelte';
  import ConfigScreen from './screens/config/ConfigScreen.svelte';
  import PersoScreen from './screens/perso/PersoScreen.svelte';
  import CombatScreen from './screens/combat/CombatScreen.svelte';
  import SetsScreen from './screens/sets/SetsScreen.svelte';

  onMount(() => { loadLegacy().then(markLoaded); });
</script>

<div class="app">
  <header class="topbar" id="top"><TopBar /></header>
  <main class="main"><div class="inner"><Sections /><div id="view"><div id="legacyview"></div><HomeScreen /><NoExport /><SettingsScreen /><PackagesScreen /><ConfigScreen /><PersoScreen /><CombatScreen /><SetsScreen /><SimScreen /></div></div></main>
</div>
<div id="overlay" hidden></div>
<div id="tip" class="tip" role="tooltip" hidden></div>

<style>
  /* the view (the old page's part, #legacyview, and the Svelte screens) lays its blocks out as the frame's own children
     (.inner, a column: the sections then the pane, atelier/app/css/base.css), as when the old page drew it all */
  :global(#view), :global(#legacyview) { display: contents; }
</style>
