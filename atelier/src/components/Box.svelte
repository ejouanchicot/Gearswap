<!--
  GearSwap Atelier · a compartment: a card with a title band in its section's colour (cls: g-def, g-tank, g-mag...),
  the old page's box() (atelier/app/js/core.js), styles in atelier/app/css (.box, .boxh, .boxb).
  `meta`: what the band says on its right (a count, a file).

  @file    atelier/src/components/Box.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {Snippet} from 'svelte';

  let {cls, title, meta, children}: {cls: string; title: string; meta?: string; children: Snippet} = $props();
</script>

<section class="box {cls}"><header class="boxh"><h3>{title}</h3>{#if meta}<span class="meta">{meta}</span>{/if}</header><div class="boxb">{@render children()}</div></section>
