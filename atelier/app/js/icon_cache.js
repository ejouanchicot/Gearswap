// GearSwap Atelier · icon_cache.js: the HD item icons, made by the page itself for any player (SPEC
// notes/docs-perso/icones-hd-universelles-2026-10-30). An icon is shown at once as the game's 32x32 .bmp (core.js
// itemImg); once that image is there, the page reads the same bytes from atelier/icons/<id>.js (written beside the
// .bmp by the game: shared/utils/atelier/item_icons.lua; a page opened from the disk may load a script, not read an
// image's pixels), makes the HD icon (icon_hd.js, about 12 ms, one icon at a time so the page stays smooth) and keeps
// it in the browser (IndexedDB 'atelier-icons'): never made again. Without its .js (an older install, an icon not
// written yet) the .bmp stays; with the game connected the game is asked to write it (core.js iconFetch).
//
// @author ejouanchicot
// @date   Created: 2026-10-30

// id -> the HD icon's address for this page's life (an object URL)
const ICON_HD = new Map();
// ids being made, with the images waiting for them; ids without a .js (asked to the game, tried again after)
const ICON_HD_WAIT = new Map(), ICON_JS_NO = new Set(), ICON_QUEUE = [];
// the HD steps' version: an icon_hd.js that draws differently changes it, and the icons are made again
const ICON_HD_KEY = 'v1:';
let ICON_BUSY = false, ICON_DB = null;

function iconDb(){
  return ICON_DB || (ICON_DB = new Promise(ok => {
    try { const r = indexedDB.open('atelier-icons', 1);
      r.onupgradeneeded = () => r.result.createObjectStore('hd');
      r.onsuccess = () => ok(r.result); r.onerror = () => ok(null);
    } catch (e) { ok(null); }   // a browser without it (a private window): made again at each visit
  }));
}
async function iconDbDo(mode, fn){
  const db = await iconDb();
  if (!db) return null;
  return new Promise(ok => { try { const q = fn(db.transaction('hd', mode).objectStore('hd')); q.onsuccess = () => ok(q.result || null); q.onerror = () => ok(null); } catch (e) { ok(null); } });
}

// An icon's bytes from its .js (ATELIER_ICON(id, base64), run by the script tag), or null without one
const ICON_JS_WAIT = new Map();
window.ATELIER_ICON = (id, b64) => {
  const done = ICON_JS_WAIT.get(id);
  if (!done) return;
  ICON_JS_WAIT.delete(id);
  try { done(Uint8Array.from(atob(b64), c => c.charCodeAt(0))); } catch (e) { done(null); }
};
function iconJs(id){
  return new Promise(ok => {
    ICON_JS_WAIT.set(id, ok);
    const s = document.createElement('script');
    s.src = `atelier/icons/${id}.js`;
    s.onload = s.onerror = () => { s.remove(); if (ICON_JS_WAIT.get(id) === ok) { ICON_JS_WAIT.delete(id); ok(null); } };
    document.head.appendChild(s);
  });
}

// The HD icon of an id as a PNG blob: kept from before, else made from its .js; null without a .js
async function iconMake(id){
  const kept = await iconDbDo('readonly', st => st.get(ICON_HD_KEY + id));
  if (kept) return kept;
  const bytes = await iconJs(id), px = bytes && IconHD.hdPixels(bytes);
  if (!px) return null;
  const c = document.createElement('canvas');
  c.width = px.w; c.height = px.h;
  c.getContext('2d').putImageData(new ImageData(new Uint8ClampedArray(px.px.buffer), px.w, px.h), 0, 0);
  const blob = await new Promise(ok => c.toBlob(ok, 'image/png'));
  if (blob) iconDbDo('readwrite', st => st.put(blob, ICON_HD_KEY + id));
  return blob;
}

// The images of an id shown in HD (those drawn again since keep their data-hd and are found in the page)
function iconShow(id, url, imgs){
  const all = new Set([...(imgs || []), ...document.querySelectorAll(`img[data-hd="${id}"]`)]);
  for (const img of all) { img.removeAttribute('data-hd'); img.src = url; }
}
async function iconPump(){
  if (ICON_BUSY) return;
  ICON_BUSY = true;
  while (ICON_QUEUE.length) {
    const id = ICON_QUEUE.shift(), imgs = ICON_HD_WAIT.get(id);
    let blob = null;
    try { blob = await iconMake(id); } catch (e) {}
    ICON_HD_WAIT.delete(id);
    if (blob) { const url = URL.createObjectURL(blob); ICON_HD.set(id, url); iconShow(id, url, imgs); }
    else { ICON_JS_NO.add(id); iconAskGame(id); }
    await new Promise(r => setTimeout(r));
  }
  ICON_BUSY = false;
}

/** The .bmp of an icon is shown (its onload, core.js itemImg): its HD one made, then shown in its place */
function iconHd(img){
  const id = +img.dataset.hd;
  if (!id) return;
  if (ICON_HD.has(id)) { iconShow(id, ICON_HD.get(id), [img]); return; }
  if (ICON_JS_NO.has(id) || typeof IconHD === 'undefined') return;
  const wait = ICON_HD_WAIT.get(id);
  if (wait) { wait.add(img); return; }
  ICON_HD_WAIT.set(id, new Set([img]));
  ICON_QUEUE.push(id);
  iconPump();
}
/** The icons without a .js tried again (the game wrote some: core.js iconFetch) */
function iconHdAgain(){
  ICON_JS_NO.clear();
  document.querySelectorAll('img[data-hd]').forEach(img => { if (img.complete && img.naturalWidth) iconHd(img); });
}
