// GearSwap Atelier · weapon_cycles.js: a job's weapon cycles (MainWeapon, SubWeapon...), edited in the job's settings
// (Configuration → Modes & keys → the weapon mode chosen: atelier/src/screens/config/cycle.ts, CycleEdit.svelte):
// their order, a weapon added (its set created when it has none) or taken out. Every change goes to the Atelier's own
// layer over the states files, <Char>/atelier/overrides/mode_overrides.lua ('+Mode' added, '-Mode' taken out, '=Mode'
// the order: shared/utils/core/mode_overrides.lua), never to the states file; GearSwap reloads.
// (notes/docs-perso/ajouter-arme-2026-11-01/SPEC.md)
// (loaded in the order of atelier/src/legacy/files.ts)

Object.assign(T.fr, {wcyTitle: 'Cycle {m}', wcyCount: '{n} armes · {k} les fait défiler dans cet ordre', wcyCountNoKey: '{n} armes, dans l’ordre où elles défilent',
  wcyLoop: '↺ retour au 1', wcyStart: 'au chargement', wcyEmpty: 'vide : n’équipe rien', wcyNoSet: 'vide : n’équipe rien',
  wcyUp: 'Plus tôt dans le cycle', wcyDown: 'Plus tard dans le cycle', wcyOut: 'Retirer du cycle', wcyLast: 'La seule arme du cycle : un cycle en garde une au moins.',
  wcyReset: 'Ordre d’origine', wcyResetTip: 'Remet les armes dans leur ordre de départ', wcyAdd: 'Ajouter', wcyAddPh: 'tape le nom d’une arme…', wcyBack: 'y était', wcyBackTip: 'Elle était dans ce cycle : elle y revient',
  wcyNewSet: 'Elle rejoint le cycle, prête à être équipée', wcyNone: 'Aucune autre arme de tes sacs ne va dans ce slot.',
  wcyNote: 'Glisse une arme pour la déplacer, ou ◀ ▶ ; ✕ la retire. C’est pris en compte en jeu tout de suite.',
  wcyMoved: '{w} mise en {n} dans le cycle {m}.', wcyResetDone: 'Cycle {m} remis dans son ordre d’origine.', wcyOutDone: '{w} retirée du cycle {m}.', wcyBackDone: '{w} remise dans le cycle {m}.',
  wcyAdding: 'Ajout au cycle {m}…', wcyAddedOnly: '{w} ajoutée à ton cycle {m}.', wcyAddFail: 'Le jeu n’a pas pris le changement : rien n’a changé.',
  wcyAddLater: '{w} ajoutée au cycle {m} : elle sera là au prochain chargement du job. Ajoute-la de nouveau le jeu connecté pour qu’elle s’équipe.',
  wcyNeedGame: 'Connecte le jeu pour ajouter une nouvelle arme.', awCyclesWhere: 'L’ordre de tes armes, en ajouter ou en retirer : Configuration → Modes & touches → Équipement, puis Main / Sub Weapon.', delCycle: ' Et retirée du cycle {m}.'});
Object.assign(T.en, {wcyTitle: '{m} cycle', wcyCount: '{n} weapons · {k} goes through them in this order', wcyCountNoKey: '{n} weapons, in the order they come',
  wcyLoop: '↺ back to 1', wcyStart: 'on load', wcyEmpty: 'empty: equips nothing', wcyNoSet: 'empty: equips nothing',
  wcyUp: 'Earlier in the cycle', wcyDown: 'Later in the cycle', wcyOut: 'Take out of the cycle', wcyLast: 'The cycle’s only weapon: a cycle keeps one at least.',
  wcyReset: 'Original order', wcyResetTip: 'Puts the weapons back in their starting order', wcyAdd: 'Add', wcyAddPh: 'type a weapon’s name…', wcyBack: 'was there', wcyBackTip: 'It was in this cycle: it comes back',
  wcyNewSet: 'It joins the cycle, ready to be worn', wcyNone: 'No other weapon of your bags goes in this slot.',
  wcyNote: 'Drag a weapon to move it, or ◀ ▶; ✕ takes it out. It applies in game right away.',
  wcyMoved: '{w} put at {n} in the {m} cycle.', wcyResetDone: '{m} cycle back to its original order.', wcyOutDone: '{w} taken out of the {m} cycle.', wcyBackDone: '{w} put back in the {m} cycle.',
  wcyAdding: 'Adding to the {m} cycle…', wcyAddedOnly: '{w} added to your {m} cycle.', wcyAddFail: 'The game did not take the change: nothing changed.',
  wcyAddLater: '{w} added to the {m} cycle: it is there at the job’s next load. Add it again with the game linked for it to be worn.',
  wcyNeedGame: 'Link the game to add a new weapon.', awCyclesWhere: 'Your weapons’ order, adding or taking one out: Configuration → Modes & keys → Equipment, then Main / Sub Weapon.', delCycle: ' And taken out of the {m} cycle.'});

// The weapon states GearSwap lays (shared/utils/core/combat_mode.lua WEAPON_STATES) and their slot
const WC_STATES = {MainWeapon: 'main', SubWeapon: 'sub', RangeWeapon: 'range', Shield: 'sub', StanceWeapon: 'main'};
// A cycle's slot as a set name's tag: sets["Colada Sub"] puts Colada in the off hand, sets.Colada being its main hand's
const WC_SLOT_TAG = {main: 'Main', sub: 'Sub', range: 'Range', ammo: 'Ammo'};
// The Atelier's layer for the job shown: the values added ('+'), taken out ('-'), their order ('=')
const wcLayer = () => modeOverrides()[S.job] || {};
const wcAdded = mode => (wcLayer()['+' + mode] || []).slice();
const wcRemoved = mode => (wcLayer()['-' + mode] || []).slice();
const wcOrder = mode => (wcLayer()['=' + mode] || []).slice();
// The values in the layer's order: the ones it names first, the others after them as they were (mode_overrides.lua)
function wcOrdered(values, order){
  const named = [...new Set(order.filter(v => values.includes(v)))];
  return named.concat(values.filter(v => !named.includes(v)));
}
const wcPath = name => /^[A-Za-z_]\w*$/.test(name) ? 'sets.' + name : 'sets["' + name + '"]';
const wcSetAt = path => ((data() || {}).sets || []).find(x => x.path === path);
// The job's weapon cycles: [{name, desc, slot, values}], the values as the layer leaves them now (the export's, read
// after the last load, with what was added, taken out or moved since): right at once, before the game's next export.
// The weapon modes the page shows, and a weapon state whose sets hold no weapon yet (Kaories' BRD SubWeapon:
// sets.Genmei empty, no sets.Demersal), by its name
function wcCycles(){
  const d = data();
  if (!d) return [];
  const shown = weaponModes(d).filter(m => !/^slot:/.test(m.name) && !m.onlyEmpty);
  const bare = d.modes.filter(m => WC_STATES[m.name] && !shown.some(x => x.name === m.name))
    .map(m => ({name: m.name, desc: m.desc || m.name, values: m.values, sets: {}, slot: WC_STATES[m.name]}));
  return shown.concat(bare).map(m => {
    const slots = new Set(m.values.flatMap(v => Object.keys((m.sets[v] || {}).pieces || {})));
    const slot = ['main', 'sub', 'range', 'ammo'].find(s => slots.has(s)) || m.slot;
    // the states file's values (the export's mode_base: shared/utils/core/mode_overrides.lua base_values), else the
    // export's, read after the last load
    const minus = wcRemoved(m.name), base = plainMap(d.mode_base)[m.name], seen = Array.isArray(base) && base.length ? base
      : (d.modes.find(x => x.name === m.name) || {}).values || m.values;
    const full = [...new Set(seen.concat(wcAdded(m.name)))].filter(v => !minus.includes(v));
    return slot ? {name: m.name, desc: m.desc || m.name, slot, values: wcOrdered(full, wcOrder(m.name))} : null;
  }).filter(Boolean);
}
const wcCycle = mode => wcCycles().find(c => c.name === mode) || null;
// The value a weapon takes in a cycle: its own name, unless a set of that name holds it in another slot. GearSwap
// equips sets[value] as it is (shared/utils/equipment/weapon_resolver.lua): sets.Colada chosen as the sub would move
// the main hand
function wcValueFor(c, item){
  const s = wcSetAt(wcPath(item)), p = s && s.pieces[c.slot];
  return !s || (p && p.name === item) ? item : item + ' ' + WC_SLOT_TAG[c.slot];
}
// The weapon a value of a cycle puts on: its set's piece in the cycle's slot, else the value less its slot tag
function wcItemOf(c, value){
  const s = wcSetAt(wcPath(value)), p = s && s.pieces[c.slot];
  return p && p.name ? p.name : value.endsWith(' ' + WC_SLOT_TAG[c.slot]) ? value.slice(0, -WC_SLOT_TAG[c.slot].length - 1) : value;
}
// The weapons a cycle can take: the ones taken out of it here first (back: their value of before), then the ones you
// hold that the job wears in its slot and it does not hold: [{name, value, back}]
function wcChoices(mode){
  const c = wcCycle(mode), owned = ownedOf() || {}, rows = (catalog() || {}).row || {}, out = [];
  if (!c) return out;
  const wears = name => { const r = rows[name]; return !!r && r[2].split(' ').includes(c.slot) && r[3].split(' ').includes(S.job); };
  const held = new Set(c.values.flatMap(v => [v, wcItemOf(c, v)]));
  for (const v of wcRemoved(mode)) if (!held.has(v)) { out.push({name: wcItemOf(c, v), value: v, back: true}); held.add(wcItemOf(c, v)); }
  for (const name of [...new Set((owned[c.slot] || []).map(x => x.name))].sort())
    if (!held.has(name) && wears(name)) out.push({name, value: wcValueFor(c, name), back: false});
  return out;
}

/* ---- the changes: the layer written, GearSwap reloaded ---- */
// The layer with one entry of the job set (an empty list deletes it)
function wcPut(map, key, list){
  map[S.job] = map[S.job] || {};
  if (list && list.length) map[S.job][key] = list; else delete map[S.job][key];
  if (!Object.keys(map[S.job]).length) delete map[S.job];
  return map;
}
// One value out of a cycle: the Atelier's own addition dropped, else a '-'
function wcOutLayer(map, mode, value){
  const plus = wcAdded(mode), minus = wcRemoved(mode);
  return plus.includes(value) ? wcPut(map, '+' + mode, plus.filter(v => v !== value)) : wcPut(map, '-' + mode, minus.concat(minus.includes(value) ? [] : [value]));
}
// Save the layer (noReload: the caller reloads); the toast said after. 'live', 'folder'... as saveFile, or null
async function wcSave(map, toast, noReload){
  if (S._wcBusy) return null;
  S._wcBusy = true;
  try {
    const done = await saveFile('mode_overrides.lua', modesLua(map), !!noReload);
    if (done === null) return null;
    S.modeDirty[S.char] = false; S.modeOv[S.char].at = stamp();
    if (toast) { S.toast = toast; render(); }
    return done;
  } finally { S._wcBusy = false; }
}
// A weapon moved from one place to another (0 first)
async function wcMove(mode, from, to){
  const c = wcCycle(mode);
  if (!c || from === to || from < 0 || to < 0 || from >= c.values.length || to >= c.values.length) return;
  const list = c.values.slice(), [v] = list.splice(from, 1);
  list.splice(to, 0, v);
  await wcSave(wcPut(modeOverrides(), '=' + mode, list), t('wcyMoved', {w: wcItemOf(c, v), n: to + 1, m: c.desc}));
}
async function wcReset(mode){
  const c = wcCycle(mode);
  if (c) await wcSave(wcPut(modeOverrides(), '=' + mode, null), t('wcyResetDone', {m: c.desc}));
}
// Taken out: its set stays; the cycle keeps one weapon at least
async function wcRemove(mode, value){
  const c = wcCycle(mode);
  if (!c || !c.values.includes(value)) return;
  if (c.values.length < 2) { S.toast = t('wcyLast'); render(); return; }
  await wcSave(wcOutLayer(modeOverrides(), mode, value), t('wcyOutDone', {w: wcItemOf(c, value), m: c.desc}));
}
// Added at the end: one taken out here comes back (its '-' dropped); another joins the layer's '+', its set created
// when it has none (push.js createPreview: preview, backup, history), once GearSwap reloaded with it (opt_sets.js
// osReloadWait: the game's catalog holds the new value by then)
async function wcAdd(mode, name){
  const c = wcCycle(mode), w = wcChoices(mode).find(x => x.name === name);
  if (!c || !w) return;
  if (w.back) { await wcSave(wcPut(modeOverrides(), '-' + mode, wcRemoved(mode).filter(v => v !== w.value)), t('wcyBackDone', {w: w.name, m: c.desc})); return; }
  const path = wcPath(w.value), there = setThere(path);
  if (!there && !liveWrite()) { S.toast = t('wcyNeedGame'); render(); return; }
  S.toast = t('wcyAdding', {m: c.desc}); render();
  const done = await wcSave(wcPut(modeOverrides(), '+' + mode, wcAdded(mode).concat([w.value])), '', true);
  if (done === null) { S.toast = t('wcyAddFail'); render(); return; }
  // written through the folder (the game's door did not answer): applied at the next load, no set created now
  if (done !== 'live') { S.toast = t('wcyAddLater', {w: w.name, m: c.desc}); render(); return; }
  if (there) { await reloadIfLoaded(); S.toast = t('wcyAddedOnly', {w: w.name, m: c.desc}); render(); return; }
  await osReloadWait();
  createPreview(path, [path, '#create', pushLine(pushEntry(c.slot, {name: w.name}, ownedOf() || {}))].join('\n') + '\n', null);
}
// A weapon set deleted (push.js delGo): its weapon leaves its cycle too, a value with no set doing nothing; the layer
// saved without a reload (the delete's own reload follows). The words added to the delete's message, or ''
async function wcDropSet(path){
  const keys = segs(path);
  if (keys.length !== 1) return '';
  const c = wcCycles().find(x => x.values.includes(keys[0]));
  if (!c || c.values.length < 2) return '';
  const done = await wcSave(wcOutLayer(modeOverrides(), c.name, keys[0]), '', true);
  return done === null ? '' : t('delCycle', {m: c.desc});
}
// The clicks of the cycle (events.js): data-wcup / data-wcdown / data-wcx = 'Mode|value', data-wcadd = 'Mode|name',
// data-wcreset = 'Mode'; false when the click is not one of them
function wcClick(d){
  const split = s => { const i = s.indexOf('|'); return [s.slice(0, i), s.slice(i + 1)]; };
  if (d.wcup != null || d.wcdown != null) {
    const [mode, v] = split(d.wcup != null ? d.wcup : d.wcdown), c = wcCycle(mode), i = c ? c.values.indexOf(v) : -1;
    if (i >= 0) wcMove(mode, i, i + (d.wcup != null ? -1 : 1));
    return true;
  }
  if (d.wcx != null) { const [mode, v] = split(d.wcx); wcRemove(mode, v); return true; }
  if (d.wcadd != null) { const [mode, n] = split(d.wcadd); wcAdd(mode, n); return true; }
  if (d.wcreset != null) { wcReset(d.wcreset); return true; }
  return false;
}
