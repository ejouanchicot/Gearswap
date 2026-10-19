<!--
  GearSwap Atelier · a party picker's body (partypick.ts): the search, the choices by family. Typing hides the choices
  and the families that do not match (the old page's pbDlgSearch), the field focused when the window opens.

  @file    atelier/src/screens/dialogs/PartyPick.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {PartyPickView} from './partypick';

  let {view}: {view: PartyPickView} = $props();
  let q = $state('');
  const w = $derived(q.trim().toLowerCase());
</script>

<input class="pbpq" type="search" placeholder={view.qPh} autocomplete="off" bind:value={q}>{#each view.groups as g, i (i)}{@const hidden = !!w && !g.items.some(x => x.q.includes(w))}<section class="pbpg" {hidden}><h4>{g.title}</h4><div class="pbpl">{#each g.items as x (x.value)}<button class="pbpi {x.on ? 'on' : ''}" {...{[x.attr]: x.value}} data-q={x.q} hidden={!!w && !x.q.includes(w)}><b>{x.label}</b><small>{x.hint}</small></button>{/each}</div></section>{/each}
