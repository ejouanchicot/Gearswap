// GearSwap Atelier · tips.js: the page's own tooltip for everything that carries a `title`. The browser draws its
// tooltip right under the system's small arrow: under the glove pointer (cursor.css), which is larger, it was half
// hidden. This one is placed clear of the glove and said by the moogle, in a small bubble (tips.css); with the
// assistant turned off in Settings it is a plain box in the look of the theme. An element's title is moved to
// data-tip the first time the pointer comes over it (the page is redrawn often: nothing to do at each redraw), and
// kept as its aria-label when it has no other name.

const TIP = {el: null, timer: null, leave: null, x: 0, y: 0};
const TIP_WAIT = 380;
// the glove's size under the pointer's point: the tooltip starts past it
const tipGlove = () => ['vanadiel', 'grimoire'].includes(document.documentElement.dataset.theme) ? {dx: 18, dy: 40} : {dx: 12, dy: 22};
function tipBox(){
  let box = document.getElementById('gtip');
  if (!box) { box = document.createElement('div'); box.id = 'gtip'; box.className = 'gtip'; box.setAttribute('role', 'tooltip'); box.hidden = true;
    box.innerHTML = '<span class="gtipmog"></span><span class="gtiptxt"></span>'; document.body.appendChild(box); }
  return box;
}
// The element under the pointer that has something to say, its title taken off so the browser shows nothing itself
function tipTarget(node){
  const el = node && node.closest && node.closest('[title], [data-tip]');
  if (!el || el.closest('#gtip')) return null;
  if (el.hasAttribute('title')) {
    const text = el.getAttribute('title');
    el.removeAttribute('title');
    if (!text.trim()) return null;
    el.dataset.tip = text;
    if (!el.getAttribute('aria-label') && !el.textContent.trim()) el.setAttribute('aria-label', text);
  }
  return el.dataset.tip ? el : null;
}
function tipHide(){
  clearTimeout(TIP.timer); clearTimeout(TIP.leave); TIP.el = null;
  const box = document.getElementById('gtip');
  if (box) box.hidden = true;
}
// Where the moogle's fingertip is in its drawing, from its left (the pose pointing up, the one pointing down)
const TIP_FINGER = {up: .72, down: .2};
// The plain box (assistant off): under the glove and to its right, over the pointer near the bottom of the window
function tipPlacePlain(box, w, h){
  const g = tipGlove(), under = TIP.y + g.dy + h <= innerHeight - 8;
  box.style.left = Math.max(8, Math.min(TIP.x + g.dx, innerWidth - w - 8)) + 'px';
  box.style.top = (under ? TIP.y + g.dy : Math.max(8, TIP.y - h - 12)) + 'px';
}
// The moogle stands right under the line it talks about, its finger raised into it, just at the left of the pointer
// (the glove hangs to the right and down: it hides nothing of it); its bubble at its left, at its right when the
// left has no room. No room under the line: it stands over it and points down. A tall block (not a line): under
// the glove instead of under the block's far edge
function tipPlace(box){
  const w = box.offsetWidth, h = box.offsetHeight;
  if (!box.classList.contains('mog') || !TIP.el || !TIP.el.isConnected) return tipPlacePlain(box, w, h);
  const r = TIP.el.getBoundingClientRect(), tall = r.height > 70, mog = 46;
  const foot = tall ? TIP.y + 38 : r.bottom + 2, under = foot + h <= innerHeight - 8, pose = under ? 'up' : 'down';
  const rev = TIP.x + 6 - w >= 8, tip = TIP_FINGER[pose] * mog;
  // rev: the moogle is the last thing of the box, its finger a little at the left of the pointer's point
  const left = rev ? TIP.x - 8 - (w - mog + tip) : Math.min(TIP.x + 40, innerWidth - w - 8);
  box.classList.toggle('rev', rev);
  box.style.left = Math.max(8, left) + 'px';
  box.style.top = Math.max(8, under ? foot : (tall ? TIP.y : r.top) - h - 2) + 'px';
  tipPose(box, pose);
}
// The moogle points at what it talks about: up when it stands under the line, down when it stands over it
function tipPose(box, pose){
  const mog = box.querySelector('.gtipmog');
  if (!box.classList.contains('mog') || mog.dataset.pose === pose || typeof guideMogHTML !== 'function') return;
  mog.dataset.pose = pose; mog.innerHTML = guideMogHTML(pose);
}
function tipShow(el){
  if (TIP.el !== el || !el.isConnected) return;
  const box = tipBox();
  box.querySelector('.gtiptxt').textContent = el.dataset.tip;
  box.classList.toggle('mog', typeof guideState !== 'function' || guideState().mode !== 'off');
  box.hidden = false;
  tipPose(box, 'up');
  tipPlace(box);
}
// The page is redrawn every couple of seconds while the game is connected: the element under a pointer that has not
// moved is replaced by its twin. A tooltip already up must not go and come back for that: it stays when the new
// element says the same thing, and a short wait (TIP_GRACE) covers the instant the pointer is over nothing
const TIP_GRACE = 160;
const tipShown = () => { const box = document.getElementById('gtip'); return !!box && !box.hidden; };
document.addEventListener('mouseover', e => {
  const el = tipTarget(e.target);
  if (el === TIP.el) return;
  if (el && TIP.el && tipShown() && el.dataset.tip === TIP.el.dataset.tip) { clearTimeout(TIP.leave); TIP.el = el; return; }
  clearTimeout(TIP.leave);
  if (!el) { if (tipShown()) TIP.leave = setTimeout(tipHide, TIP_GRACE); else tipHide(); return; }
  tipHide();
  TIP.el = el; TIP.x = e.clientX; TIP.y = e.clientY;
  TIP.timer = setTimeout(() => tipShow(el), TIP_WAIT);
});
document.addEventListener('mousemove', e => {
  TIP.x = e.clientX; TIP.y = e.clientY;
  const box = document.getElementById('gtip');
  if (box && !box.hidden) tipPlace(box);
});
for (const ev of ['mousedown', 'keydown', 'wheel']) document.addEventListener(ev, tipHide, true);
// The glove bends its finger while a button of the mouse is held (cursor.css :root.pressing): said by a class as
// well as by :active, which the page's redraw under the pointer can take off before the eye has seen it
document.addEventListener('pointerdown', () => document.documentElement.classList.add('pressing'), true);
for (const ev of ['pointerup', 'pointercancel', 'blur', 'dragend']) addEventListener(ev, () => document.documentElement.classList.remove('pressing'), true);
document.addEventListener('mouseleave', tipHide);
