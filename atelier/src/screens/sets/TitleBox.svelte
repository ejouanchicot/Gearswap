<!--
  GearSwap Atelier · the title of a set (card.ts TitleView), one shape whatever its content so nothing under it moves
  from a set to the next: the name on a line (its family over it), what it is on the next (when it is worn, or a
  weaponskill's facts), its path on the third; each line keeps its height and cuts what is too long (the whole text in
  its tooltip); the actions at the right (the optimizer: data-optview; deleting it: push.js delButton, its HTML).

  @file    atelier/src/screens/sets/TitleBox.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {TitleView} from './card';

  let {view}: {view: TitleView} = $props();
</script>

<div class="settitle"><div class="stmain"><div class="stname">{#if view.kicker}<span class="kicker">{view.kicker}</span>{/if}<h2>{view.name + (view.version || view.tag ? ' ' : '')}{#if view.version}<span class="wsver">{'· ' + view.version}</span>{/if}{#if view.version && view.tag}{' '}{/if}{#if view.tag}<span class="wsver">{'· ' + view.tag}</span>{/if}</h2></div><div class="stwhat" title={view.factsTip || undefined}>{#if view.when}<span class="muted small setwhen">{view.when}</span>{/if}{#if view.facts.length}<span class="wsfacts">{#each view.facts as f, i (i)}<span>{f}</span>{/each}</span>{/if}</div><code class="path wspath" title={view.pathTip}>{view.path}</code></div><span class="setacts">{#if view.opt}<button class="btn" data-optview title={view.opt.title}>{@html view.opt.labelHtml}</button>{/if}{@html view.delHtml}</span></div>
