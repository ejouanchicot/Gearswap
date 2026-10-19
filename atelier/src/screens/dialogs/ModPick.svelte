<!--
  GearSwap Atelier · the body of a Modules' picker (modpick.ts): the search, then the tiles by part.

  @file    atelier/src/screens/dialogs/ModPick.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {ModPickView} from './modpick';

  let {view}: {view: ModPickView} = $props();
</script>

<input id="miq" class="tgq" type="search" placeholder={view.ph} autocomplete="off"><div id="mibody" class="mibody">{#each view.blocks as b, i (i)}{#if 'h' in b}<h4>{b.h}</h4><div class="migrid">{#each b.tiles as x (x.n)}<button class="mitile{x.act ? ' act' : ''}{x.other ? ' other' : ''}" data-mipick={x.n} disabled={x.disabled} title={x.title}>{@html x.icoHtml}<span>{x.label}{#if x.kind}<small>{' · ' + x.kind}</small>{/if}{#if x.wsw}<small class="wsw">{' · ' + x.wsw}</small>{/if}</span></button>{/each}</div>{:else}<p class={b.small ? 'muted small' : 'muted'}>{b.p}</p>{/if}{/each}</div>
