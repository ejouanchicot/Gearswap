// GearSwap Atelier · the weapons a set is shown with, under its title: a menu for each weapon state of the job
// (MainWeapon, SubWeapon..., Auto first: what the job's code puts there), the stance the weapon rules hang on (PLD's
// HybridMode), then what the job's GearSwap puts with them (off hand, ammo), with « back to Auto » on a forced one.
// A weaponskill's set offers only the weapons that open it. The rules are the old page's weaponMenus and
// weaponResultLines (weapons.js); the menus keep the attributes its handlers read (data-wmode, data-unforce: events.js).
//
// @file    atelier/src/screens/sets/weapons.ts
// @author  ejouanchicot

import type {WsOption} from './wshead';

export interface WeaponMenu { name: string; desc: string; mode: string; cls: string; options: WsOption[] }
export interface WeaponResult { label: string; name: string; note: string; noteTitle: string | null; unforce: string | null; backLabel: string }

const S0 = (): LegacyAny => S;

/** The menus of the job's weapon states for a set, the stance first (weaponMenus); none for a weapon set */
export function weaponMenusView(s: LegacyAny): WeaponMenu[] {
  const d = data() as LegacyAny;
  if (family(s.path, s.pieces) === 'weapons') return [];
  // a weaponskill's set offers only the weapons that open it (its skill; the weapon itself for a relic or prime)
  const ws = wsOfSet(s), only = (m: LegacyAny) => m.name !== 'MainWeapon' || !ws ? m
    : Object.assign({}, m, {values: m.values.filter((v: string) => wsWeaponFits(m, v, ws as string) || v === explicitWeapon(m))});
  const modes = weaponModes(d).filter((m: LegacyAny) => !m.onlyEmpty && !isEmpty(s.pieces[weaponModeSlot(m)])).map(only);
  const hm = modes.length ? hybridMode(d) : null;
  const opt = (v: string, on: boolean, label = v): WsOption => ({value: v, label, selected: on});
  // the stance the job's weapon rules hang on (PLD's HybridMode: its shield and stance weapon), always one of its values
  const stance: WeaponMenu[] = hm ? [{name: hm.name, desc: hm.desc, mode: hm.name, cls: 'wmenu buffsel', options: hm.values.map((v: string) => opt(v, v === chosenWeapon(hm)))}] : [];
  // each weapon state under its name in game (MainWeapon, SubWeapon...): Auto first, what the job's code puts there
  return stance.concat(modes.map((m: LegacyAny) => {
    const ex = explicitWeapon(m), auto = withWeapons(s, m.name).pieces[weaponModeSlot(m)];
    // a gated state (THF's AbyWeapon) with its switch off lays nothing: say so rather than name the main
    const gate = WEAPON_GATES[m.name], off = gate && !/^(on|true)$/i.test((d.modes.find((x: LegacyAny) => x.name === gate.when) || {}).current || '');
    return {name: m.name, desc: m.desc, mode: m.name, cls: `wmenu buffsel ${ex ? 'set' : ''}`,
      options: [opt('', !ex, t('auto') + ' · ' + (off ? gate.when + ' off' : auto && !isEmpty(auto) ? auto.name : '—')), ...m.values.map((v: string) => opt(v, v === ex))]};
  }));
}

/** What the job's GearSwap puts with the weapons, a slot no weapon state names (weaponResultLines) */
export function weaponResults(s: LegacyAny): WeaponResult[] {
  if (family(s.path, s.pieces) === 'weapons') return [];
  const eff = withWeapons(s), f = slotForce(), names = SLOT_NAMES[S0().lang] as Record<string, string>, back = t('backToAuto');
  const stated = new Set(weaponModes(data()).filter((m: LegacyAny) => !m.onlyEmpty).map(weaponModeSlot));
  const out: WeaponResult[] = [];
  for (const slot of ['main', 'sub', 'range', 'ammo']) {
    const p = eff.pieces[slot];
    if (stated.has(slot) || !p || isEmpty(p)) continue;
    const forced = !!f[slot] && f[slot].name === p.name;
    out.push({label: names[slot]!, name: p.name, note: forced ? t('forcedTag') : t(eff.from[slot] ? 'byGearSwap' : 'bySet'),
      noteTitle: forced ? '' : t(eff.from[slot] ? 'ttByGs' : 'ttBySet'), unforce: forced ? slot : null, backLabel: back});
  }
  // a main hand forced on a job whose weapon state names it
  if (f.main && stated.has('main')) out.push({label: names.main!, name: f.main.name, note: t('forcedTag'), noteTitle: null, unforce: 'main', backLabel: back});
  return out;
}

/** The title of a weapon menu and its label: its state's description, then what a weapon menu does */
export const weaponTip = (desc: string) => desc && desc.replace(/\s+/g, '').toLowerCase() !== 'mainweapon' ? desc + ' · ' + t('ttWeapon') : t('ttWeapon');
