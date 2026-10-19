// GearSwap Atelier · the menu of a slot of the sets' grid: choose a piece, lock the slot, leave the piece out of the
// searches, empty it, put the set's piece back. The rules are the old page's openSlotMenu (trial.js), which places the
// menu beside the slot and keeps what each choice does (slotMenuAct, data-slotact). The menu is made at its first
// opening, at the end of <body> as the old page made it, one component mounted in it and drawn now (its size places it).
//
// @file    atelier/src/screens/dialogs/slotmenus.svelte.ts
// @author  ejouanchicot
import {mount, flushSync} from 'svelte';
import SlotMenu from './SlotMenu.svelte';

export interface SlotMenuView { ci: number; slot: string; title: string; piece: string; items: Array<{act: string; label: string; hint: string}> }

export const slotMenuState = $state<{view: SlotMenuView | null}>({view: null});

/** The menu of the slot of the card ci, or null when the card is gone */
export function slotMenuView(ci: number, slot: string): SlotMenuView | null {
  const card = (S as LegacyAny)._cards[ci], s = card && shownSet(card, ci);
  if (!s) return null;
  const eff = withWeapons(s), p = eff.pieces[slot], locked = isLocked(s, slot), tried = eff.tried[slot], has = !!p && !isEmpty(p);
  const items: SlotMenuView['items'] = [{act: 'pick', label: t('slotPick'), hint: ''}];
  if (LOCKABLE(slot)) items.push({act: 'lock', label: t(locked ? 'slotUnlock' : 'slotLock'), hint: t(locked ? 'slotUnlockHint' : 'slotLockHint')});
  if (LOCKABLE(slot) && has) items.push({act: 'exclude', label: t(isExcluded(p.name) ? 'slotInclude' : 'slotExclude'), hint: t(isExcluded(p.name) ? 'slotIncludeHint' : 'slotExcludeHint')},
    {act: 'empty', label: t('tryEmpty'), hint: ''});
  if (tried) items.push({act: 'reset', label: t('tryReset'), hint: ''});
  return {ci, slot, title: (SLOT_NAMES[(S as LegacyAny).lang] || {})[slot] || slot, piece: has ? p.name : t('empty'), items};
}

/** The menu shown with this view: made at its first opening, drawn now; returns the menu's element */
export function slotMenuShow(view: SlotMenuView): HTMLElement {
  let menu = document.getElementById('slotmenu');
  if (!menu) {
    menu = document.createElement('div');
    menu.id = 'slotmenu'; menu.className = 'slotmenu'; menu.setAttribute('role', 'menu');
    document.body.appendChild(menu);
    mount(SlotMenu, {target: menu});
  }
  slotMenuState.view = view;
  flushSync();
  return menu;
}
