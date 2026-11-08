<!--
  GearSwap Atelier · the head of the list of sets (setlist.ts listHead): the search as a bar (its magnifier, its field,
  "/" to reach it from the keyboard: events.js), + (a new set) and ⋯ (the list's menu) the same height on its line, and
  the menu when it is open. The buttons keep the attributes the old handlers read (list_prefs.js: data-listmenu,
  data-listpaths, data-listall, data-listnew, data-listshow, data-listsave; events.js: data-action="add", #setq).

  @file    atelier/src/screens/sets/ListHead.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {ListHead} from './setlist';

  let {view}: {view: ListHead} = $props();
</script>

<div class="search"><label class="sbox" title={view.tip}><svg viewBox="0 0 16 16" aria-hidden="true"><circle cx="7" cy="7" r="5"/><path d="M11 11l4 4"/></svg><input id="setq" type="search" placeholder={view.ph} value={view.q} autocomplete="off" spellcheck="false"><kbd>{view.key}</kbd></label><button class="btn ghost lbtn" data-action="add" title={view.addTip}>+</button><button class="btn ghost lbtn" data-listmenu aria-expanded={view.menuOpen} title={view.menuTip}>⋯</button></div>{#if view.menu}<div class="listmenu">{#each view.menu as it, i (i)}{#if it.k === 'hr'}<hr>{:else if it.k === 'small'}<small>{it.label}</small>{:else if it.k === 'show'}<button class="lmitem" data-listshow={it.f}><i class="lmck"></i>{it.label + ' '}<em>{it.em}</em></button>{:else}<button class="lmitem" {...it.attrs} aria-pressed={it.on === null ? undefined : it.on} title={it.tip}><i class="lmck">{it.on ? '✓' : ''}</i>{it.label}</button>{/if}{/each}</div>{/if}
