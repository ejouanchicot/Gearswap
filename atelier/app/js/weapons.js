// GearSwap Atelier · weapons.js: weapon modes, hands, grips, Kraken, forced weapons, the weapon menus
// (cut from atelier.html, loaded by it in order: see the list there)
/* ---- weapons: what the weapon modes put in main / sub / range / ammo ---- */
const WEAPON_SLOTS = new Set(['main', 'sub', 'range', 'ammo']);
const WEAPON_CACHE = new WeakMap();
// Modes whose values name a top-level weapon set (MainWeapon "Excalibur" -> sets.Excalibur),
// the main hand first, the sub and range ones after so they win on their own slots
function weaponModes(d){
  if (!d) return [];
  const cached = WEAPON_CACHE.get(d);
  if (cached && cached.lang === S.lang) return cached.modes;
  const top = {};
  for (const s of d.sets) {
    const m = s.path.match(/^sets(?:\.([\w-]+)|\["([^"]+)"\])$/), slots = Object.keys(s.pieces);
    if (m && slots.length && slots.every(k => WEAPON_SLOTS.has(k))) top[m[1] || m[2]] = s;
  }
  const rank = n => /sub/i.test(n) ? 2 : /range|ammo/i.test(n) ? 3 : /main/i.test(n) ? 0 : 1;
  const modes = d.modes.filter(m => m.values.some(v => top[v]))
    .map(m => ({name: m.name, desc: m.desc || m.name, values: m.values.filter(v => top[v]), current: m.current, sets: top}))
    .sort((a, b) => rank(a.name) - rank(b.name));
  // One-piece weapon sets no mode names (PLD's sets.Duban, sets.Aegis...): a choice per slot,
  // used where neither the set nor a weapon mode fills it; by default the piece the job's sets use most
  // (never the main hand: it comes from the weapon mode, or the stance weapon of the job's rules)
  // never a grip the job's weapon rules lay themselves under a two-handed weapon (PLD's sets.Alber: Alber Strap under
  // Shining One, <job>/combat/<JOB>_WEAPONS.lua grips): it showed as an off hand to choose beside the Shield mode
  const stances = Object.values((d.weapon_rules || {}).stance_weapon || {});
  const grips = new Set(Object.values((d.weapon_rules || {}).grips || {}));
  const named = new Set(modes.flatMap(m => m.values).concat(stances)), free = {};
  for (const [name, s] of Object.entries(top)) {
    const slots = Object.keys(s.pieces);
    if (named.has(name) || slots.length !== 1 || slots[0] === 'main' || grips.has((s.pieces[slots[0]] || {}).name)) continue;
    (free[slots[0]] = free[slots[0]] || []).push(name);
  }
  for (const [slot, values] of Object.entries(free)) {
    const used = {};
    for (const s of d.sets) { const p = s.pieces[slot]; if (p) used[p.name] = (used[p.name] || 0) + 1; }
    const best = values.slice().sort((a, b) => (used[top[b].pieces[slot].name] || 0) - (used[top[a].pieces[slot].name] || 0))[0];
    modes.push({name: 'slot:' + slot, desc: SLOT_NAMES[S.lang][slot], values: values.sort(), current: best, sets: top, onlyEmpty: true});
  }
  // the weapon states whose values name no set (a new job's MainWeapon Free): with the character's equip_without_set
  // on, a value that is an item is worn as is (weapon_resolver.lua), as a mode of its own here; else the state changes
  // nothing in game and the page leaves it out, as the set's own weapons are what is worn
  const has = new Set(modes.map(m => m.name));
  for (const m of d.modes) {
    const slot = WEAPON_STATE_SLOT[m.name];
    if (!slot || has.has(m.name)) continue;
    const items = d.weapon_plain ? m.values.filter(v => isItemName(v)) : [];
    if (items.length) modes.push({name: m.name, desc: m.desc || m.name, values: items, current: m.current,
      sets: Object.fromEntries(items.map(v => [v, {path: v, pieces: {[slot]: {name: v}}}]))});
  }
  WEAPON_CACHE.set(d, {lang: S.lang, modes});
  return modes;
}
// The slot of a weapon state a value can be worn in as an item
const WEAPON_STATE_SLOT = {MainWeapon: 'main', SubWeapon: 'sub', RangeWeapon: 'range'};
const isItemName = v => { const c = catalog(); return !!(c && c.row[v]) || Object.values(ownedOf() || {}).some(l => (l || []).some(x => x.name === v)); };
// The weapon chosen in the page for a mode, else the one the job loads with. A current value that
// names no set (PLD's Shield on 'Auto') lays nothing, as in game: null
function chosenWeapon(m){
  const v = S.weapons[weaponKey(m)];
  if (m.values.includes(v)) return v;
  if (m.values.includes(m.current)) return m.current;
  return m.current && !m.onlyEmpty ? null : m.values[0];
}
const weaponKey = m => S.char + '|' + S.job + '|' + m.name;
// A choice made in the page (never the job's default): it wins over the job's rules
function explicitWeapon(m, ignore){
  const v = S.weapons[weaponKey(m)];
  return m.name !== ignore && v && m.sets && m.sets[v] ? v : null;
}
// The job's weapon rules (<job>/combat/<JOB>_WEAPONS.lua, PLD's set_builder.lua): they hang
// on the Hybrid mode, offered beside the weapons when the rules use it
// PLD's own default (shared/jobs/pld/functions/logic/set_builder.lua): another job wears its weapon set's sub
const DEFAULT_GRIPS = {Shining: 'Alber Strap'};
function hybridMode(d){
  const rules = (d && d.weapon_rules) || {};
  if (!rules.shields && !rules.stance_weapon) return null;
  const m = d.modes.find(x => x.name === 'HybridMode');
  return m ? {name: m.name, desc: m.desc || m.name, values: m.values, current: m.current} : null;
}
// A set as worn, the way the job code builds it: the weapon mode's set on top (the stance's
// weapon first: PLD Tanking holds Burtgang), then the grip of a two-handed weapon or the
// shield the stance gives that weapon; a one-piece weapon set no mode names (a shield) only
// where the slot is still empty. A choice made in the page wins over all of it; `ignore`
// leaves one mode's choice out, to show what the job would put there on its own (Auto)
// The weapon held for a weaponskill (heldWeapon) in the main hand; a two-handed one takes a grip (the one
// your weapon modes use, else the first you own), a one-handed one gives up a grip
function holdWeapon(d, pieces, from, held){
  const owned = ownedOf() || {}, own = (owned.main || []).find(x => x.name === held);
  pieces.main = own && own.augs && own.augs.length ? {name: held, augs: own.augs} : {name: held};
  from.main = t('heldWhy');
  const two = TWO_HANDED.test((itemOf(held) || {})['Skill Type'] || ''), subType = pieces.sub ? (itemOf(pieces.sub.name) || {}).Type : null;
  if (two && subType !== 'Grip') {
    const grips = (owned.sub || []).map(x => x.name).filter(n => (itemOf(n) || {}).Type === 'Grip');
    // the grip the weapon set of that very weapon names (Shining One with Alber Strap), else the first grip a weapon set uses
    const sets = weaponModes(d).flatMap(m => m.values.map(v => m.sets[v].pieces || {}));
    const own = sets.find(p => (p.main || {}).name === held && grips.includes((p.sub || {}).name));
    const used = own ? own.sub.name : sets.map(p => (p.sub || {}).name).find(n => n && grips.includes(n));
    if (used || grips[0]) { pieces.sub = {name: used || grips[0]}; from.sub = t('gripFor', {w: held}); } else delete pieces.sub;
  } else if (!two && subType === 'Grip') delete pieces.sub;
}
// The weapon of a weapon mode a set's path names: a part equal to one of its values (Naegling), else
// the longest value a part starts with (LaphriaAFM3: Laphria); null when none
function weaponOfPath(path, m){
  const parts = segs(path), exact = parts.find(p => m.values.includes(p));
  if (exact) return exact;
  let best = null;
  for (const p of parts) for (const v of m.values) if (p.startsWith(v) && (!best || v.length > best.length)) best = v;
  const job = AFM3_WEAPON[S.job];
  return best || (isAfm3(path) && job && m.values.includes(job) ? job : null) || (isKraken(path) ? krakenWeapon(m) : null);
}
// The pieces forced in the page for this job (main, sub, ammo), over what the job's rules put there; the
// optimizer's free weapons land here too. Never written to a file: in game, the weapon modes decide
const FORCE_SLOTS = ['main', 'sub', 'ammo'];
const forceKey = () => S.char + '|' + S.job;
const slotForce = () => (S.slotForce || {})[forceKey()] || {};
function setForce(slot, piece){
  const f = Object.assign({}, slotForce());
  if (piece) f[slot] = piece; else delete f[slot];
  S.slotForce = Object.assign({}, S.slotForce, {[forceKey()]: f});
}
// Whether the job can hold a weapon in each hand: NIN, DNC, THF, BLU, or a /NIN or /DNC (BaseSetBuilder's rule)
const canDualWield = () => ['NIN', 'DNC', 'THF', 'BLU'].includes(S.job) || ['NIN', 'DNC'].includes((data() || {}).sub);
// An off hand the main hand can take: nothing with Hand-to-Hand, a grip with a two-handed weapon, a shield or
// (dual wield) a weapon with a one-handed one; unknown pieces (no engine loaded) are allowed
function subFits(main, sub){
  return !subWhy(main, sub);
}
// Why an off hand does not fit the main hand ('' when it does)
function subWhy(main, sub){
  const it = itemOf(main && main.name), su = itemOf(sub && sub.name);
  if (!sub || !it || !su) return '';
  if (it['Skill Type'] === 'Hand-to-Hand') return t('subNoH2h');
  const twoHanded = it.Type === 'Weapon' && !(it.slots || []).includes('sub');
  if (twoHanded) return su.Type === 'Grip' ? '' : t('subNeedGrip');
  if (su.Type === 'Grip') return t('subGrip2h');
  return su.Type === 'Shield' || (su.Type === 'Weapon' && canDualWield()) ? '' : t('subNeedDw');
}
// A set named for the Kraken Club (WAR's sets.engaged.NaeglingKC / LoxoticKC, BRD's PDTKC with its Kraken sub;
// shared/jobs/<job>/functions/logic/set_builder.lua) is shown with it
const KRAKEN = 'Kraken Club', isKraken = path => /KC$/.test(segs(path || '').pop() || '');
// the weapon mode's value that holds the Kraken Club in the off hand (WAR's NaeglingKC), or null
const krakenWeapon = m => m.values.find(v => { const sub = ((m.sets[v] || {}).pieces || {}).sub; return sub && sub.name === KRAKEN; }) || null;
// The sets worn under Aftermath Lv.3, and the weapon a job's AFM3 sets named after no weapon go with (WAR's stance
// sets, HoxneAFM3, under Ukonvasara: shared/jobs/war/functions/logic/set_builder.lua)
const AFM3_WEAPON = {WAR: 'Ukonvasara'};
const isAfm3 = path => /AFM3\b/.test(path || '');
function withWeapons(s, ignore){
  const d = data(), rules = (d && d.weapon_rules) || {}, hm = hybridMode(d), hybrid = hm && chosenWeapon(hm);
  const pieces = Object.assign({}, s.pieces), from = {}, picks = [];
  if (family(s.path, s.pieces) === 'weapons') return applyTrial(s, pieces, from, null);
  // a slot the set empties on purpose (GearSwap's `empty`, sets.naked) stays empty: no weapon mode fills it
  const blank = new Set(Object.keys(s.pieces).filter(k => isEmpty(s.pieces[k])));
  let weapon = null, stanceWeapon = null;
  // a weaponskill's set holds a weapon of that weaponskill's skill (Savage Blade: a sword)
  const ws = wsOfSet(s), want = ws && wsSkills()[ws];
  // the job lays its weapon modes on its idle and engaged sets only (shared/jobs/<job>/functions/logic/set_builder.lua):
  // a precast, midcast or ability set wears its own weapons for the action, the modes' only where it names none
  const ownHands = handsOwn(s);
  // a weapon mode laid only while a switch is on, in place of the usual weapons (WEAPON_GATES)
  const isOn = name => { const g = d.modes.find(x => x.name === name); return !!g && /^(on|true)$/i.test(g.current); };
  const gated = Object.entries(WEAPON_GATES).filter(([m, g]) => isOn(g.when)).map(([m]) => m);
  for (const m of weaponModes(d)) {
    const gate = WEAPON_GATES[m.name];
    if (gate && !gated.includes(m.name) && !explicitWeapon(m, ignore)) continue;
    if (gated.some(g => WEAPON_GATES[g].replaces.includes(m.name)) && !explicitWeapon(m, ignore)) continue;
    const ex = explicitWeapon(m, ignore);
    if (m.onlyEmpty) { if (ex) picks.push([m, ex]); else fill(m, chosenWeapon(m), `${m.desc} : ${chosenWeapon(m)}`, true); continue; }
    let v = ex || chosenWeapon(m), why = `${m.desc} : ${v}`;
    // a variant named after a weapon (sets.engaged.Naegling, .NaeglingKC, .LaphriaAFM3) is worn with that weapon,
    // whatever weapon is chosen in the page
    const named = m.name === 'MainWeapon' ? weaponOfPath(s.path, m) : null;
    if (named) { v = named; why = t('weaponByVariant', {v: named}); }
    if (!v) continue;
    const stance = !ex && !named && m.name === 'MainWeapon' && hybrid && (rules.stance_weapon || {})[hybrid];
    if (stance && m.sets[stance]) { v = stanceWeapon = stance; why = `${hybrid} : ${v}`; }
    if (!ex && want && m.name === 'MainWeapon' && !wsWeaponFits(m, v, ws)) {
      const fit = m.values.find(x => wsWeaponFits(m, x, ws));
      if (fit) { v = fit; stanceWeapon = null; why = `${ws} : ${v}`; }
    }
    fill(m, v, why, false);
    if (m.name === 'MainWeapon') weapon = v;
  }
  const held = ws && ignore !== 'held' && ignore !== 'force' && heldWeapon(ws);
  if (held && !blank.has('main')) { holdWeapon(d, pieces, from, held); weapon = null; stanceWeapon = null; }
  // the off hand chosen for this weaponskill (a grip, a shield, a weapon when dual wielding), if the main hand takes it
  const hs = ws && ignore !== 'heldsub' && (S.heldSub || {})[heldKey(ws)];
  const hsOn = hs && !blank.has('sub') && subFits(pieces.main, hs);
  if (hsOn) { pieces.sub = hs; from.sub = t('heldWhy'); }
  const grip = !hsOn && weapon && (rules.grips || (hybridMode(d) ? DEFAULT_GRIPS : {}))[weapon];
  // a shield chosen in the Shield mode (not Auto) wins over the stance's, as in game (shared/jobs/pld/functions/logic/
  // set_builder.lua apply_mode_shield): the mode laid it above; a two-handed weapon keeps its grip
  const shieldMode = weaponModes(d).find(m => m.name === 'Shield');
  const shieldChosen = shieldMode && (explicitWeapon(shieldMode, ignore) || chosenWeapon(shieldMode));
  const shield = !hsOn && !shieldChosen && weapon && hybrid && ((rules.shields || {})[hybrid] || {})[weapon];
  if (grip && !blank.has('sub')) { pieces.sub = {name: grip}; from.sub = t('gripFor', {w: weapon}); }
  else if (shield && !blank.has('sub')) { pieces.sub = {name: shield}; from.sub = t('shieldFor', {w: weapon, m: hybrid}); }
  // the pieces forced in the page (FORCE_SLOTS), over the job's rules (a set named after a weapon keeps its
  // weapons: only the ammo); ignore 'force' for what Auto would give. Not on a weaponskill's set: it holds the
  // weapon that opens it and the off hand chosen for it (S.held, S.heldSub), and its own ammo
  const force = Object.assign({}, ignore === 'force' || ws ? {} : slotForce());
  if (weapon && weaponModes(d).some(m => m.name === 'MainWeapon' && weaponOfPath(s.path, m))) { delete force.main; delete force.sub; }
  for (const slot of FORCE_SLOTS) if (force[slot] && !blank.has(slot)) { pieces[slot] = force[slot]; from[slot] = t('forcedTag'); }
  // a Kraken Club set with no weapon value holding it: the club in the off hand, over the mode's sub (a weapon
  // you chose in the page stays)
  if (isKraken(s.path) && !blank.has('sub') && !(pieces.sub && pieces.sub.name === KRAKEN) && !force.sub && !force.main && !weaponModes(d).some(m => explicitWeapon(m, ignore))) {
    pieces.sub = {name: KRAKEN}; from.sub = t('weaponByVariant', {v: KRAKEN}); }
  for (const [m, v] of picks) fill(m, v, t('yourChoice', {v}), false);
  // an action's set: the hands it names itself go over what the modes laid (the job wears them for the action)
  if (ownHands) for (const slot of ['main', 'sub', 'range']) {
    const p = s.pieces[slot];
    if (p && !isEmpty(p)) { pieces[slot] = p; from[slot] = t('ownWeapon'); }
  }
  // the TP bonus pieces go on last, over the tried ones: the job lays them after the set (job_post_precast)
  const out = applyTrial(s, pieces, from, stanceWeapon), tpg = tpBonusGear(s, out.pieces);
  for (const [slot, name] of Object.entries(tpg || {})) if (!blank.has(slot)) { out.pieces[slot] = {name}; out.from[slot] = t('tpFrom', {tp: S.wsTp}); }
  return out;
  function fill(m, v, why, onlyEmpty){
    for (const [slot, p] of Object.entries(m.sets[v].pieces)) {
      if ((onlyEmpty && pieces[slot] && !isEmpty(pieces[slot])) || blank.has(slot)) continue;
      pieces[slot] = p; from[slot] = why;
    }
  }
}
// Weapon modes laid only while a switch is on, and the modes they replace then: THF's Abyssea
// weapon (shared/jobs/thf/functions/logic/set_builder.lua apply_weapon)
const WEAPON_GATES = {AbyWeapon: {when: 'AbyProc', replaces: ['MainWeapon', 'SubWeapon']}};
function wsWeaponFits(m, v, ws){
  const want = ws && wsSkills()[ws];
  if (!want) return true;
  if (weaponSkillOf(m, v) !== want) return false;
  const lock = wsInfoOf(ws).lock;
  if (!lock) return true;
  const main = ((m.sets[v] && m.sets[v].pieces.main) || {}).name || v;
  return lock.toLowerCase().includes(String(main).toLowerCase());
}
function weaponSkillOf(m, v){
  const main = m.sets[v] && m.sets[v].pieces.main;
  return main ? weaponSkills()[main.name] : null;
}
// A set that wears its own weapons over the weapon modes: not idle, engaged, a weaponskill's or a weapon set (the modes
// and the held weapon choose those)
function handsOwn(s){ return !['idle', 'engaged', 'ws', 'weapons'].includes(family(s.path, s.pieces)) && !isJumpSet(s.path); }
function applyTrial(s, pieces, from, stance){
  for (const [slot, p] of Object.entries(pieces)) if (isEmpty(p)) delete pieces[slot];
  const tried = {}, tr = S._noTrial ? null : S.trial[trialKey(s)];
  // the hands never come from a try (but on a weapon set): the weapon menus and the grid choose them (chooseHand); a
  // try of an older page left on a hand is passed over
  const hands = family(s.path, s.pieces) !== 'weapons' && !handsOwn(s);
  for (const [slot, p] of Object.entries(tr || {})) {
    if (heldAlready(s, slot, p) || (hands && (slot === 'main' || slot === 'sub'))) continue;
    if (p) pieces[slot] = p; else delete pieces[slot]; delete from[slot]; tried[slot] = true;
  }
  return {pieces, from, stance, tried};
}
// Your pieces for a hand or the ammo (a weaponskill's off hand menu, ws_page.js), each name once
function forceList(slot){
  const seen = new Set();
  return ((ownedOf() || {})[slot] || []).filter(x => x && x.name && !isEmpty(x) && !seen.has(x.name) && seen.add(x.name));
}
// What the job's GearSwap puts in the off hand and the ammo slot with the weapon chosen: shown, not chosen (in game the
// weapon state decides them); a piece forced in the page (a click on its slot) says so, with the way back to Auto
function weaponResultLines(s, line){
  const eff = withWeapons(s), f = slotForce(), stated = new Set(weaponModes(data()).filter(m => !m.onlyEmpty).map(weaponModeSlot));
  return ['main', 'sub', 'range', 'ammo'].filter(slot => !stated.has(slot)).map(slot => { const p = eff.pieces[slot];
    if (!p || isEmpty(p)) return '';
    const forced = f[slot] && f[slot].name === p.name;
    return line(SLOT_NAMES[S.lang][slot], `<span class="wauto"><b>${esc(p.name)}</b> <small class="muted">${esc(forced ? t('forcedTag') : t(eff.from[slot] ? 'byGearSwap' : 'bySet'))}</small>` +
      (forced ? ` <button class="linkbtn" data-unforce="${slot}">${esc(t('backToAuto'))}</button>` : '') + `</span>`); }).join('') +
    (f.main && stated.has('main') ? line(SLOT_NAMES[S.lang].main, `<span class="wauto"><b>${esc(f.main.name)}</b> <small class="muted">${esc(t('forcedTag'))}</small> <button class="linkbtn" data-unforce="main">${esc(t('backToAuto'))}</button></span>`) : '');
}
// The slot a weapon state fills: MainWeapon the main hand, an Empty<Slot> switch its slot, another its first value's slot
const weaponModeSlot = m => m.onlyEmpty ? m.name.slice(5).toLowerCase() : (m.name === 'MainWeapon' ? 'main' : Object.keys(m.sets[m.values[0]].pieces)[0]);
function weaponMenus(s){
  const d = data();
  if (family(s.path, s.pieces) === 'weapons') return '';
  // a weaponskill's set offers only the weapons that open it (its skill; the weapon itself for a relic or prime)
  const ws = wsOfSet(s), only = m => m.name !== 'MainWeapon' || !ws ? m
    : Object.assign({}, m, {values: m.values.filter(v => wsWeaponFits(m, v, ws) || v === explicitWeapon(m))});
  const modes = weaponModes(d).filter(m => !m.onlyEmpty && !isEmpty(s.pieces[weaponModeSlot(m)])).map(only);
  const hm = modes.length ? hybridMode(d) : null;
  const opt = (v, on, label = v) => `<option value="${esc(v)}" ${on ? 'selected' : ''}>${esc(label)}</option>`;
  // the stance the job's weapon rules hang on (PLD's HybridMode: its shield and stance weapon), always one of its values
  const stance = hm ? [[hm.name, `<select class="wmenu buffsel" data-wmode="${esc(hm.name)}" aria-label="${esc(hm.desc)}">` +
    hm.values.map(v => opt(v, v === chosenWeapon(hm))).join('') + `</select>`, hm.desc]] : [];
  // each weapon state under its name in game (MainWeapon, SubWeapon...): Auto first, what the job's code puts there
  return stance.concat(modes.map(m => { const ex = explicitWeapon(m), auto = withWeapons(s, m.name).pieces[weaponModeSlot(m)];
    // a gated state (THF's AbyWeapon) with its switch off lays nothing: say so rather than name the main
    const gate = WEAPON_GATES[m.name], off = gate && !/^(on|true)$/i.test((d.modes.find(x => x.name === gate.when) || {}).current || '');
    const sel = `<select class="wmenu buffsel ${ex ? 'set' : ''}" data-wmode="${esc(m.name)}" aria-label="${esc(m.desc)}">` +
      opt('', !ex, t('auto') + ' · ' + (off ? gate.when + ' off' : auto && !isEmpty(auto) ? auto.name : '—')) +
      m.values.map(v => opt(v, v === ex)).join('') + `</select>`;
    return [m.name, sel, m.desc]; }));
}

/* ---- the weapon held for a weaponskill ---- */
// The weapon held for a weaponskill, chosen in the page for that weaponskill only and never written
// to a file: a weapon change resets the TP, so a weaponskill set never holds one. None = the weapon mode's
const heldKey = ws => S.char + '|' + S.job + '|' + ws;
const heldWeapon = ws => (S.held || {})[heldKey(ws)] || null;
