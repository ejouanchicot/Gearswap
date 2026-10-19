<!--
  GearSwap Atelier · the four situations (profiles.ts situations): large in Buffs & target, as the tabs of the party's
  box (who is in each, what it holds), small in the line over the sets. A click is buffs.js data-bufftier.

  @file    atelier/src/screens/profiles/Situations.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {Situation} from './profiles';

  let {list, big, label = ''}: {list: Situation[]; big: boolean; label?: string} = $props();
</script>

{#snippet sit(x: Situation)}<button class="prsit {big ? 'big' : ''}" data-bufftier={x.tier} aria-pressed={x.pressed} title={x.title}><b>{x.tier}</b>{#if big}<span class="prparty">{#each x.party as m, i (i)}<span class="prem" title={m.job} style="--role:{m.color}">{@html m.emblemHtml}</span>{/each}</span><small>{x.what}</small>{#if x.sum}<i>{x.sum}</i>{/if}{/if}</button>{/snippet}
{#if big}<div class="prsits sittabs" role="tablist" aria-label={label}>{#each list as x (x.tier)}{@render sit(x)}{/each}</div>{:else}<span class="prsits compact" role="group">{#each list as x (x.tier)}{@render sit(x)}{/each}</span>{/if}
