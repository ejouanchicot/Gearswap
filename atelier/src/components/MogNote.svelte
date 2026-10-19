<!--
  GearSwap Atelier · the moogle beside a word (the old page's mogSorryHTML, guide.js, kept for its own windows): sorry when
  something failed or was not found, carrying gear when it is about to go into the player's files. Its pose moves
  (moogle.css .mogspr: four frames in one image).

  @file    atelier/src/components/MogNote.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  let {pose, html}: {pose: 'sorry' | 'carry'; html: string} = $props();
</script>

<div class="mognote {pose}"><i class="mogspr mog-{pose}" style="--s:84px" aria-hidden="true"></i><p>{@html html}</p></div>
