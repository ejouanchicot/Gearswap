<!--
  GearSwap Atelier · the row of the job's sections over the page (sections.ts), drawn again at each redraw of the old
  page. Styles: atelier/app/css/base.css .sections, themes.css.

  @file    atelier/src/screens/topbar/Sections.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';
  import {sectionTabs} from './sections';

  const tabs = $derived(legacy.version > 0 ? sectionTabs() : null);
</script>

{#if tabs}
  <div class="sections" role="tablist">
    {#each tabs as s (s.key)}
      <button role="tab" aria-selected={s.selected} data-section={s.key} title={s.title}>{s.label}{#if s.count !== ''}<span class="count">{s.count}</span>{/if}</button>
    {/each}
  </div>
{/if}
