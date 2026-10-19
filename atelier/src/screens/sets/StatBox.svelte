<!--
  GearSwap Atelier · a box of figures that folds (figures.ts StatBox): its band says its title, a figure that counts
  and how many lines it holds; open, its lines (a label, a figure, a note, the stat's help as tooltip). The old page's
  fbox (core.js) and statLi (stats.js); the band's click is events.js data-fold.

  @file    atelier/src/screens/sets/StatBox.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {StatBox} from './figures';

  let {box}: {box: StatBox} = $props();
</script>

<section class="box {box.cls}"><button class="boxh bufftoggle" data-fold={box.key} aria-expanded={box.open} title={box.foldTitle}><h3>{@html box.titleHtml}</h3><span class="meta">{#if box.summary}<b class="boxsum">{box.summary}</b>{/if}{box.count || ''}</span></button>{#if box.open}<div class="boxb">{@html box.noteHtml}{#if !box.bare}<ul class="statlist">{#each box.items as x, i (i)}{#if x.k === 'row'}<li class={x.cls} title={x.title}><span>{@html x.labelHtml}</span><b>{@html x.valueHtml}</b><i>{@html x.extraHtml}</i></li>{:else}{@html x.html}{/if}{/each}</ul>{/if}</div>{/if}</section>
