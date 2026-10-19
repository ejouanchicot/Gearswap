<!--
  GearSwap Atelier · a window over the page (dialogs.svelte.ts): its title, its body, Close and its own buttons. The
  old page's showDialog (trial.js); drawn anew at each opening ({#key}), as the old page's were.

  @file    atelier/src/screens/dialogs/Dialog.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {dialogState, currentDialog} from './dialogs.svelte';
  import Compare from './Compare.svelte';

  const d = $derived(dialogState.version > 0 ? currentDialog() : null);
</script>

{#key dialogState.opened}{#if d}<div class="scrim" data-close></div><div class="dialog {d.cls}" role="dialog"><header><h3>{@html d.titleHtml}</h3></header>
    <div class="body">{#if d.compare}<Compare view={d.compare} />{:else}{@html d.bodyHtml || ''}{/if}</div><footer><button class="btn ghost" data-close>{t('close')}</button>{@html d.buttonsHtml || ''}</footer></div>{/if}{/key}
