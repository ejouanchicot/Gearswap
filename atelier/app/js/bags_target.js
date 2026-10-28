'use strict';
/* GearSwap Atelier - where every thing of the bags should be: the one sum the Bags view reads.
   The cards of the plan, the "misplaced" marks of the list and the moves sent to the game all come from bpTarget:
   what the cards say will move is what //gs c bags go moves, counted against the room there really is.
   Loaded after bags_view.js and bags_plan.js, whose helpers it uses (atelier/src/legacy/files.ts). */

// From the inventory everything that has bags of its own leaves, but what is carried there to be used: gear a set
// wears, pieces to activate, consumables. (What waits for an NPC or a mule, and what the player filed as kept on the
// character, have no bags: they stay too.)
const BT_INV_STAY = ['gear', 'tools', 'usable'];
let BT_CACHE = null;
// The Storage Slips (01 to 33) live in the bag that has the slips role: it keeps a slot for each one that is not
// in it yet, and a margin, whatever else it holds
const BT_SLIPS = 33, BT_SLIP_MARGIN = 2, btSlip = name => /^Storage Slip/.test(name || '');
const btSlipsLeft = (B, bag) => bvRoles(B, bag).includes('slips') ? Math.max(0, BT_SLIPS - bag.items.filter(it => btSlip((B.items[it.id] || {}).name)).length) : 0;
// The slots of a bag the plan never fills with anything else
const btReserve = (B, bag) => bvRoles(B, bag).includes('slips') ? btSlipsLeft(B, bag) + BT_SLIP_MARGIN : 0;

// One line a thing in a bag: {r, cat, from (bag), n (slots)}, for what the plan may move
function btUnits(B, rows){
  const out = [];
  for (const r of rows) { const cat = bpCat(B, r); if (!BP_ROLES[cat]) continue;
    for (const w of r.where) { const from = B.bags.find(b => b.name === w.bag);
      if (from && from.id >= 0 && from.max && (from.id !== 0 || !BT_INV_STAY.includes(cat))) out.push({r, cat, from, n: w.slots}); } }
  return out;
}
// Why a unit is not where it should be ('' when it is), and whether it only moves if there is room (a surplus)
function btWhy(B, u){
  const roles = bvRoles(B, u.from);
  if (u.from.id === 0) return 'bvW_inv';
  if (roles.includes('free')) return '';
  if (u.cat === 'gear' ? roles.includes('job') || roles.includes('gear') : BP_ROLES[u.cat].some(x => roles.includes(x))) return '';
  if (u.cat === 'gear' && roles.includes('spare')) return 'bvW_spare';
  const why = roles.map(role => bvWrong(u.r, u.from.name, role));
  return why.includes('') ? 'bvW_role' : why[0];
}
// The bags a unit may go to, the first choice first
function btHomes(B, u, why){
  const order = btSlip(u.r.info.name) ? ['slips', 'furnish'] : u.cat !== 'gear' ? BP_ROLES[u.cat] : why === 'bvW_spare' ? ['gear'] : u.r.use.jobs[S.job] ? ['job', 'gear', 'spare'] : ['gear', 'spare', 'job'];
  // (a wardrobe takes equipment only)
  return order.flatMap(role => B.bags.filter(b => b.max && b.id > 0 && bvRoles(B, b).includes(role))).filter(b => b.name !== u.from.name && (bvIsGear(u.r) || !/^Wardrobe/.test(b.name)));
}
// The sum: {moves: [{id, name, from, to, fromName, toName, cat}], noRoom: [{name, cat, bag}], bad: {row key: [{bag, why, to}]}}.
// What empties a bag is placed first, the surplus of the reserve last; a bag's room is counted as the moves go, and
// what found none is tried again once the others have moved.
function bpTarget(B){
  const key = [DATA_GEN, S.char, S.job, B.at, JSON.stringify((S.bagRoles || {})[S.char] || {}), JSON.stringify(bpTags()), !!(typeof catalog === 'function' && catalog())].join('|');
  if (BT_CACHE && BT_CACHE.key === key) return BT_CACHE.val;
  const free = {}, slipRoom = {}, moves = [], noRoom = [], bad = {};
  for (const b of B.bags) if (b.max) { free[b.name] = b.max - (b.count != null ? b.count : b.items.length) - btReserve(B, b); slipRoom[b.name] = btSlipsLeft(B, b); }
  let left = [];
  for (const u of btUnits(B, bvRowsRaw(B, 'all', bvWhere(B)))) { const why = btWhy(B, u); if (why) for (let i = 0; i < u.n; i++) left.push({u, why}); }
  const rank = x => x.why === 'bvW_spare' ? 2 : x.u.cat === 'gear' ? 1 : 0;
  left.sort((a, b) => rank(a) - rank(b));
  const mark = (x, to) => { const list = bad[x.u.r.key] = bad[x.u.r.key] || [], at = list.find(e => e.bag === x.u.from.name);
    if (at) { if (to && !at.to) at.to = to; } else list.push({bag: x.u.from.name, why: x.why, to}); };
  for (let round = 0; round < 3 && left.length; round++) { const next = [];
    for (const x of left) { const slip = btSlip(x.u.r.info.name), to = btHomes(B, x.u, x.why).find(b => free[b.name] > 0 || (slip && slipRoom[b.name] > 0));
      if (!to) { next.push(x); continue; }
      // (a slip takes the slot kept for it)
      if (slip && slipRoom[to.name] > 0) slipRoom[to.name]--; else free[to.name]--;
      free[x.u.from.name]++; mark(x, to.name);
      moves.push({id: x.u.r.id, name: x.u.r.info.name, from: x.u.from.id, to: to.id, fromName: x.u.from.name, toName: to.name, cat: x.u.cat}); }
    if (next.length === left.length) { left = next; break; } left = next; }
  // what found no room: a surplus stays where it is and is in place there, the rest is said
  for (const x of left) if (x.why !== 'bvW_spare') { mark(x, ''); noRoom.push({name: x.u.r.info.name, cat: x.u.cat, bag: x.u.from.name}); }
  BT_CACHE = {key, val: {moves, noRoom, bad}};
  return BT_CACHE.val;
}
// What the plan does to a group of bags: {now, out, in, after} in slots
function btFlow(B, names){
  const T = bpTarget(B), now = names.reduce((n, x) => { const b = B.bags.find(g => g.name === x); return n + (b ? (b.count != null ? b.count : b.items.length) : 0); }, 0);
  const out = T.moves.filter(m => names.includes(m.fromName) && !names.includes(m.toName)).length, into = T.moves.filter(m => names.includes(m.toName) && !names.includes(m.fromName)).length;
  const reserve = names.reduce((n, x) => { const b = B.bags.find(g => g.name === x); return n + (b ? btReserve(B, b) : 0); }, 0);
  return {now, out, in: into, after: now - out + into, reserve};
}
