<!--
  GearSwap Atelier · a job with no export for the character shown: why there is nothing to see (not exported yet, or
  not a job the character plays), and a button to another character (data-char, events.js).
  The old page's renderJob (sets_view.js) drew it in place of the job's sections.

  @file    atelier/src/screens/home/NoExport.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';

  const view = $derived.by(() => {
    if (!(legacy.version > 0) || S._cfg || S._pkg || !S.job || data()) return null;
    const c = S.job, other = otherChar();
    return {c, whyHtml: ' : ' + (plays(c) ? t('placeholder') : t('notPlayed', {c: S.char})), other, otherHtml: other ? t('seeOther', {c: other}) : ''};
  });
</script>

{#if view}<div class="pane "><div class="placeholder"><p><b>{view.c}</b>{@html view.whyHtml}</p>{#if view.other}<button class="btn ghost" data-char={view.other}>{@html view.otherHtml}</button>{/if}</div></div>{/if}
