<!--
  GearSwap Atelier · the name of a set (card.ts TitleView), on the card's title line (Card.svelte): its family or a
  weaponskill's weapon over it, then its name, its version and its tag. What it is (when it is worn, a weaponskill's
  facts) and its path are the band under the title line (Card.svelte); its actions the card's commands.

  @file    atelier/src/screens/sets/TitleBox.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {TitleView} from './card';

  let {view}: {view: TitleView} = $props();
</script>

<div class="settitle"><div class="stname">{#if view.kicker}<span class="kicker">{view.kicker}</span>{/if}<h2>{view.name}{#if view.version}<em class="wsver">{' · ' + view.version}</em>{/if}{#if view.tag}<em class="wsver">{' · ' + view.tag}</em>{/if}</h2></div></div>
