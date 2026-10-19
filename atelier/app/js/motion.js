// GearSwap Atelier · motion.js: what moves on the page. The page is drawn again whole at each click, so nothing here
// is a CSS animation left to replay at every redraw: motionAfter() (called at the end of render) compares what is
// shown with what was shown before and moves only what changed: the game's hand glides to the chosen row, a figure
// rolls to its new value, a slot whose piece changed flashes, a gauge fills from where it was, a window opens.
// Off in Settings (S.motion) or when the system asks for less motion: the page is then drawn as before.

const MOTION = {key: null, at: 0, rows: new Map(), slots: new Map(), hands: [], live: new Map()};
const motionOn = () => S.motion !== false && !matchMedia('(prefers-reduced-motion: reduce)').matches;
// What is shown: the tab (figures roll and gauges move inside one), the set (a window opens on another) and the set
// without its version (.Group, .Solo, .Trust: a slot flashes when the piece differs from the version shown before)
function motionKey(){
  const tab = [S.char, S.job, S.section, !!S._cfg].join('|'), cur = document.querySelector('#view .setrow[aria-current="true"] code');
  const set = String((S.selPath || {})[S.job] || (cur ? cur.textContent : (S.sel || {})[S.job]));
  // `win`: the set whatever its version (a support profile's, and a weaponskill's buff versions: .Clim, .FanDance.Clim.Solo
  // are all that weaponskill's): going from a version to another is not opening another set, the window does not open again
  const plain = set.replace(/\.(Group|Solo|Trust)$/, ''), ws = plain.match(/^sets\.precast\.WS(\["[^"]*"\]|\.[A-Za-z_]\w*)/);
  return {tab, set: tab + '|' + set, base: tab + '|' + set.replace(/\.(Group|Solo|Trust|Normal)$/, ''), win: tab + '|' + (ws ? ws[0] : plain)};
}

Object.assign(T.fr, {cfgMotion: 'Animations', cfgMotionWhy: 'Le curseur qui glisse, les chiffres qui défilent, les fenêtres qui s’ouvrent. Coupées d’office si ton système demande moins d’animations.',
  cfgMotionOn: 'Activées', cfgMotionOff: 'Coupées'});
Object.assign(T.en, {cfgMotion: 'Animations', cfgMotionWhy: 'The gliding cursor, the rolling figures, the opening windows. Always off when your system asks for reduced motion.',
  cfgMotionOn: 'On', cfgMotionOff: 'Off'});

/* ---- figures ---- */
// A figure as the page writes it: sign, digits (grouped or not), decimals, then what follows (" %", " s")
const MOTION_NUM = /^([+\-−]?)(\d{1,3}(?:[\s  ,]\d{3})+|\d+)(?:([.,])(\d+))?([^]*)$/;
function motionNum(text){
  const m = MOTION_NUM.exec(text.trim());
  if (!m) return null;
  const v = +(m[2].replace(/\D/g, '') + (m[4] ? '.' + m[4] : ''));
  return {v: m[1] === '-' || m[1] === '−' ? -v : v, plus: m[1] === '+', sep: (m[2].match(/\D/) || [''])[0], dot: m[3] || '.', dec: (m[4] || '').length, tail: m[5]};
}
function motionNumText(f, v){
  const [int, dec] = Math.abs(v).toFixed(f.dec).split('.');
  const grouped = f.sep ? int.replace(/\B(?=(\d{3})+$)/g, f.sep) : int;
  return (v < 0 ? '−' : f.plus && v > 0 ? '+' : '') + grouped + (dec ? f.dot + dec : '') + f.tail;
}
// The figure rolls from what it was to what it is, and ends on the page's own text
function motionRoll(el, before, text, t0){
  const a = motionNum(before), b = motionNum(text), ms = 340;
  if (!a || !b || a.tail !== b.tail || el.children.length) return;
  const step = now => {
    if (!el.isConnected) return;
    const k = Math.min(1, (now - t0) / ms), ease = 1 - Math.pow(1 - k, 3);
    el.textContent = k < 1 ? motionNumText(b, a.v + (b.v - a.v) * ease) : text;
    if (k < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
}
// The rows of figures shown, each under a name that holds from one redraw to the next: its block's title, its label
function motionRows(){
  const rows = new Map(), seen = {};
  for (const b of document.querySelectorAll('#view .statlist li > b')) {
    const li = b.parentElement, box = li.closest('details,section,.box,.panel'), head = box && box.querySelector('summary,h3,h4');
    const name = (head ? head.textContent.trim() : '') + '›' + (li.firstElementChild.textContent || '').trim();
    seen[name] = (seen[name] || 0) + 1;
    rows.set(name + '#' + seen[name], {b, li, text: b.textContent, fill: (li.querySelector('.gauge') || {style: {getPropertyValue: () => ''}}).style.getPropertyValue('--fill')});
  }
  return rows;
}

/* ---- the game's hand ---- */
// One hand a list, put where it was then sent to the chosen row: the list is new at each redraw of the old page, the
// hand's place is not. A list the Svelte application keeps between redraws keeps its hand: that one moves (a new one
// each time piled hands up, darker at each redraw)
function motionHands(on){
  const tops = [];
  document.querySelectorAll('#view .setlist .scroll').forEach((box, i) => {
    const row = box.querySelector('.setrow[aria-current="true"]'), kept = box.querySelector(':scope > .hand');
    if (!row) { if (kept) kept.remove(); return; }
    const hand = kept || document.createElement('i'), b = row.querySelector('b') || row;
    hand.className = 'hand'; hand.setAttribute('aria-hidden', 'true');
    // b's place is counted from the list itself (the list is the positioned box, not the row)
    const top = b.offsetTop + b.offsetHeight / 2, was = MOTION.hands[i];
    hand.style.left = b.offsetLeft + 'px';
    hand.style.top = (on && was != null ? was : top) + 'px';
    box.appendChild(hand);
    if (on && was != null && was !== top) { hand.getBoundingClientRect(); hand.style.top = top + 'px'; }
    tops[i] = top;
  });
  MOTION.hands = tops;
}

/* ---- after each redraw ---- */
// What is moving now: {what moves: {since when, how long, its own data}}. A click often draws the page twice (the
// buffs follow the set opened, the game answers): what started on the first drawing goes on, from where it was, on
// the elements of the second, instead of being lost with the elements it was on
const MOTION_MS = {row: 900, fill: 700, slot: 600, win: 150};
function motionStart(kind, k, data){ MOTION.live.set(kind + ':' + k, Object.assign({t0: performance.now(), ms: MOTION_MS[kind]}, data)); }
// An element takes up a movement at the point it has reached (a negative delay starts an animation part-way)
function motionPut(el, cls, live){
  el.classList.add(cls);
  for (const x of cls === 'fills' ? [el.querySelector('.gauge'), el.querySelector('.capmax')] : [el]) if (x) x.style.setProperty('--since', Math.round(live.t0 - performance.now()) + 'ms');
}
function motionApply(rows, slots){
  const now = performance.now();
  for (const [id, live] of MOTION.live) {
    if (now - live.t0 > live.ms) { MOTION.live.delete(id); continue; }
    const kind = id.slice(0, id.indexOf(':')), k = id.slice(kind.length + 1), row = rows.get(k), slot = slots.get(k);
    if (kind === 'row' && row && row.text === live.text) { motionPut(row.b, 'moved', live); motionRoll(row.b, live.before, live.text, live.t0); }
    if (kind === 'fill' && row && row.fill === live.fill) { row.li.style.setProperty('--from', live.from); motionPut(row.li, 'fills', live); }
    if (kind === 'slot' && slot) motionPut(slot.el, 'flash', live);
    if (kind === 'win') for (const el of document.querySelectorAll('#view .detail, #view .cfg section')) motionPut(el, 'opens', live);
  }
}
function motionAfter(){
  const on = motionOn(), key = motionKey(), was0 = MOTION.key || {}, same = key.tab === was0.tab, rows = motionRows(), slots = new Map();
  document.documentElement.dataset.motion = on ? 'on' : 'off';
  for (const el of document.querySelectorAll('#view .slot[data-card][data-slot]')) slots.set(el.dataset.card + '|' + el.dataset.slot, {el, what: el.getAttribute('aria-label')});
  if (on) {
    for (const [k, r] of rows) {
      const was = MOTION.rows.get(k);
      if (same && was && was.text !== r.text) motionStart('row', k, {before: was.text, text: r.text});
      if (r.fill && (!same || !was || was.fill !== r.fill)) motionStart('fill', k, {from: same && was && was.fill ? was.fill : '0%', fill: r.fill});
    }
    if (key.base === was0.base) for (const [k, s] of slots) { const was = MOTION.slots.get(k); if (was && was.what !== s.what) motionStart('slot', k, {}); }
    if (key.win !== was0.win) motionStart('win', '', {});
    motionApply(rows, slots);
  } else MOTION.live.clear();
  motionHands(on && same);
  Object.assign(MOTION, {key, at: performance.now(), rows: new Map([...rows].map(([k, r]) => [k, {text: r.text, fill: r.fill}])),
    slots: new Map([...slots].map(([k, s]) => [k, {what: s.what}]))});
}

// A dialog opens (the overlay shown), a folded block is opened by hand (not by the redraw that opens it again)
// (now, when the page is already read: atelier/src/legacy/load.ts loads this file after the document's end)
function watchDialogs(){
  const overlay = document.getElementById('overlay');
  if (overlay) new MutationObserver(() => { const d = overlay.querySelector('.dialog');
    if (d && !overlay.hidden && motionOn()) d.classList.add('opens'); }).observe(overlay, {attributes: true, attributeFilter: ['hidden']});
}
if (document.readyState === 'loading') addEventListener('DOMContentLoaded', watchDialogs); else watchDialogs();
document.addEventListener('toggle', e => {
  const el = e.target;
  if (el.open && motionOn() && performance.now() - MOTION.at > 120 && el.closest && el.closest('#view')) el.classList.add('unfolds');
}, true);
document.addEventListener('click', e => {
  const b = e.target.closest && e.target.closest('[data-motion-set]');
  if (b) { S.motion = b.dataset.motionSet === 'on'; render(); }
});
