<!--
  GearSwap Atelier · the Push button of a set with pieces on trial (push.ts): push, or open the version that exists.

  @file    atelier/src/screens/sets/PushButton.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {PushBtn} from './push';

  let {b}: {b: PushBtn} = $props();
</script>

{#if b.open}<button class="btn" data-veropen title={b.title}>{@html b.labelHtml}</button>{:else}<button class="btn" data-pushopen disabled={b.disabled} title={b.title}>{@html b.labelHtml}</button>{/if}
