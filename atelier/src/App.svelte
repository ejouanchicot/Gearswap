<!--
  GearSwap Atelier · the application: the top bar and the job's sections (Svelte, screens/topbar), the screens moved to
  Svelte (screens/config: the job's settings, screens/perso: My character, screens/combat: Buffs & target, screens/sets: Sets, screens/home: the home page and a job with no export, screens/settings: the page's Settings, screens/packages: the Packages page, screens/update: the update screen, screens/sim: Simulate), and what is left of the old page
  (atelier/app, its state, data and clicks; atelier/src/README.md): its frame (the windows, the tooltip), its styles and
  scripts, loaded in their order (legacy/load.ts, legacy/files.ts).

  @file    atelier/src/App.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {onMount} from 'svelte';
  import Tip from './screens/sets/Tip.svelte';
  import {loadLegacy} from './legacy/load';
  import {markLoaded} from './bridge';
  import TopBar from './screens/topbar/TopBar.svelte';
  import Sections from './screens/topbar/Sections.svelte';
  import HomeScreen from './screens/home/HomeScreen.svelte';
  import NoExport from './screens/home/NoExport.svelte';
  import SettingsScreen from './screens/settings/SettingsScreen.svelte';
  import PackagesScreen from './screens/packages/PackagesScreen.svelte';
  import UpdateScreen from './screens/update/UpdateScreen.svelte';
  import SimScreen from './screens/sim/SimScreen.svelte';
  import ConfigScreen from './screens/config/ConfigScreen.svelte';
  import PersoScreen from './screens/perso/PersoScreen.svelte';
  import CombatScreen from './screens/combat/CombatScreen.svelte';
  import SetsScreen from './screens/sets/SetsScreen.svelte';

  onMount(() => { loadLegacy().then(markLoaded); });
</script>

<div class="app">
  <header class="topbar" id="top"><TopBar /></header>
  <main class="main"><div class="inner"><Sections /><div id="view"><HomeScreen /><NoExport /><SettingsScreen /><UpdateScreen /><PackagesScreen /><ConfigScreen /><PersoScreen /><CombatScreen /><SetsScreen /><SimScreen /></div></div></main>
</div>
<div id="overlay" hidden></div>
<div id="tip" class="tip" role="tooltip" hidden><Tip /></div>

<style>
  /* the view (the Svelte screens) lays its blocks out as the frame's own children
     (.inner, a column: the sections then the pane, atelier/app/css/base.css), as when the old page drew it all */
  :global(#view) { display: contents; }
</style>
