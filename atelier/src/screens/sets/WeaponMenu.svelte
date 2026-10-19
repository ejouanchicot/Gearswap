<!--
  GearSwap Atelier · one weapon state's menu (weapons.ts): its values, Auto first; `title` on the cards' menus only.

  @file    atelier/src/screens/sets/WeaponMenu.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {selSync} from '../../components/selsync';
  import type {WeaponMenu} from './weapons';

  let {menu, title = null}: {menu: WeaponMenu; title?: string | null} = $props();
  const pick = $derived((menu.options.find(o => o.selected) || {value: undefined}).value);
</script>

<select title={title} class={menu.cls} data-wmode={menu.mode} aria-label={menu.desc} use:selSync={pick}>{#each menu.options as o (o.value)}<option value={o.value} selected={o.selected}>{o.label}</option>{/each}</select>
