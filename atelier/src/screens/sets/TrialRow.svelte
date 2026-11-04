<!--
  GearSwap Atelier · the trial's row of a set (trial.ts): what is tried, then its buttons and links.

  @file    atelier/src/screens/sets/TrialRow.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {TrialRow} from './trial';
  import PushButton from './PushButton.svelte';

  // fold: the search's long message behind one line (the optimizer, whose figures are already above it)
  let {row, fold = false}: {row: TrialRow; fold?: boolean} = $props();
</script>

<div class="tryrow {row.saved ? 'saved' : ''}"><h4 class="tryhead">{row.head}</h4><p class="tryline">{#if row.by}<span class="tryby">{row.by}</span>{/if}{@html row.msgHtml}{#if row.gain}{@html ' · ' + row.gain.textHtml + ' '}<span class={row.gain.up ? 'up' : 'down'}>{row.gain.pct}</span>{/if}</p><div class="dacts">{#if row.push}<PushButton b={row.push} />{/if}{#if row.cmp}<button class="btn ghost" data-cmpopen>{@html row.cmp.labelHtml + (row.cmp.kept ? ' ' : '')}{#if row.cmp.kept}<small>{@html row.cmp.kept}</small>{/if}</button>{/if}{#if row.keep}<button class="btn ghost" data-trykeep title={row.keep.tip}>{@html row.keep.labelHtml}</button>{/if}{#if row.save}<button class="btn ghost" data-trysave>{@html row.save}</button>{/if}<span class="sp"></span><span class="dlinks">{#each row.links as l, i (l.attr)}{#if i}<span>·</span>{/if}<button class="linkbtn" {...{[l.attr]: ''}}>{@html l.labelHtml}</button>{/each}</span></div>{#if row.toast}{#if fold}<details class="dtoast dtoastd"><summary>{t('opToastFold')}</summary><p>{row.toast}</p></details>{:else}<p class="dtoast">{row.toast}</p>{/if}{/if}</div>
