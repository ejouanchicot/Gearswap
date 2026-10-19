<!--
  GearSwap Atelier · the head of the list of sets (setlist.ts listHead): the search, + (a new set), ⋯ (the list's menu),
  open or close every group, and the menu when it is open. The buttons keep the attributes the old handlers read
  (list_prefs.js: data-listmenu, data-famall, data-listpaths, data-listall, data-listnew, data-listshow, data-listsave;
  events.js: data-action="add", #setq).

  @file    atelier/src/screens/sets/ListHead.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {ListHead} from './setlist';

  let {view}: {view: ListHead} = $props();
</script>

<div class="search"><input id="setq" type="search" placeholder={view.ph} title={view.tip} value={view.q} autocomplete="off" spellcheck="false"><button class="btn ghost lbtn" data-action="add" title={view.addTip}>+</button><button class="btn ghost lbtn" data-listmenu aria-expanded={view.menuOpen} title={view.menuTip}>⋯</button></div>{#if view.fold}<div class="foldall" title={view.fold.tip}><button class="linkbtn" data-famall="1">{'▾ ' + view.fold.open}</button><button class="linkbtn" data-famall="0">{'▸ ' + view.fold.close}</button></div>{/if}{#if view.menu}<div class="listmenu">{#each view.menu as it, i (i)}{#if it.k === 'hr'}<hr>{:else if it.k === 'small'}<small>{it.label}</small>{:else if it.k === 'show'}<button class="lmitem" data-listshow={it.f}><i class="lmck"></i>{it.label + ' '}<em>{it.em}</em></button>{:else}<button class="lmitem" {...it.attrs} aria-pressed={it.on === null ? undefined : it.on} title={it.tip}><i class="lmck">{it.on ? '✓' : ''}</i>{it.label}</button>{/if}{/each}</div>{/if}
