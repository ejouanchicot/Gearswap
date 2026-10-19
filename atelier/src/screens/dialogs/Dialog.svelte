<!--
  GearSwap Atelier · a window over the page (dialogs.svelte.ts): its title, its body, Close and its own buttons. The
  old page's showDialog (trial.js); drawn anew at each opening ({#key}), as the old page's were.

  @file    atelier/src/screens/dialogs/Dialog.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {dialogState, currentDialog} from './dialogs.svelte';
  import Compare from './Compare.svelte';
  import GearPick from './GearPick.svelte';
  import Target from './Target.svelte';
  import PartyPick from './PartyPick.svelte';
  import PushViewBody from './PushView.svelte';
  import TierCost from './TierCost.svelte';
  import History from './History.svelte';
  import OptAll from './OptAll.svelte';
  import StatPick from './StatPick.svelte';
  import AddSet from './AddSet.svelte';
  import BagDialog from './BagDialog.svelte';

  const d = $derived(dialogState.version > 0 ? currentDialog() : null);
</script>

{#key dialogState.opened}{#if d && d.target}<Target view={d.target} />{:else if d && d.optAll}<OptAll view={d.optAll} />{:else if d && d.statPick}<StatPick view={d.statPick} />{:else if d && d.addSet}<AddSet view={d.addSet} />{:else if d}<div class="scrim" data-close></div><div class="dialog {d.cls}" role="dialog" aria-label={d.ariaLabel}><header><h3>{@html d.titleHtml}</h3></header>
    <div class="body">{#if d.compare}<Compare view={d.compare} />{:else if d.gearPick}<GearPick view={d.gearPick} />{:else if d.partyPick}<PartyPick view={d.partyPick} />{:else if d.push}<PushViewBody view={d.push} />{:else if d.tierCost}<TierCost view={d.tierCost} />{:else if d.history}<History view={d.history} />{:else if d.bags}<BagDialog view={d.bags} />{:else if d.lua !== undefined}<textarea class="luabox" id="luabox" readonly spellcheck="false">{d.lua}</textarea>{:else}{@html d.bodyHtml || ''}{/if}</div><footer><button class="btn ghost" data-close>{t('close')}</button>{@html d.buttonsHtml || ''}</footer></div>{/if}{/key}
