<!--
  GearSwap Atelier · a party picker's body (partypick.ts): the search, the choices by family, a line each in aligned
  columns (icon, name, what it gives, its state). Typing hides the choices
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

<input class="pbpq" type="search" placeholder={view.qPh} autocomplete="off" bind:value={q}>
{#each view.groups as g, i (i)}{@const shown = g.items.filter(x => !w || x.q.includes(w))}
  <section class="pbpg" hidden={!shown.length}><h4>{g.title}<small>{shown.length}</small></h4>
    <div class="ppl">{#each g.items as x (x.value)}<button class="ppr" class:on={x.on} class:held={!!x.tag} {...{[x.attr]: x.value}} data-q={x.q} hidden={!!w && !x.q.includes(w)}>
      <span class="ppi">{#if x.icon}{@html x.icon}{/if}</span><b>{x.label}</b>
      <span class="ppe">{#if x.effects && x.effects.length}{#each x.effects as e, j (j)}<span class:neg={e.neg}>{e.text}</span>{/each}{:else if x.hint}<small>{x.hint}</small>{/if}</span>
      <span class="ppt">{#if x.on}✓ {view.cur}{:else if x.tag}{x.tag}{/if}</span></button>{/each}</div>
  </section>
{/each}
