// GearSwap Atelier · moogle.js: the search window's scene. While the optimizer searches, a moogle rummages in a
// chest and throws gear over its shoulders, instead of the lines of the search (still there: a button of the window
// shows them), in a cloud of dust and with a word now and then.
// Drawn only when animations are on (motion.js): with them off the window is the one of before.
// The search done, the moogle faces us beside the result: it hops for joy for a better set, is puzzled by a set that
// was already the best. Images: atelier/app/img/mog/ (small copies of the drawings in atelier/Img/).

const MOG = {timer: null, step: 0, until: 0};
const MOG_IMG = 'atelier/app/img/mog/';
const MOG_OBJS = ['boot', 'shield', 'helm', 'body', 'glove', 'sword'];
// What the moogle says while it digs, in a bubble now and then
const MOG_SAYS = {fr: ['Kupo !', 'Kupo ?', 'Kupopo !', '!', '?!', '…', 'Kupo kupo !', 'Pas ça, kupo !', 'Hmm… kupo ?', 'Kupoooo !', 'Trop petit, kupo !', 'Où est-ce, kupo ?', '!!', 'Ah ! Non, kupo…'],
  en: ['Kupo!', 'Kupo?', 'Kupopo!', '!', '?!', '…', 'Kupo kupo!', 'Not this one, kupo!', 'Hmm… kupo?', 'Kupoooo!', 'Too small, kupo!', 'Where is it, kupo?', '!!', 'Ah! No, kupo…']};
// The dust's drawings in turn (1 the first puff, 2 and 3 the whirl, 4 scattered)
const MOG_SMOKE = [1, 2, 3, 2, 3, 2];
// What the moogle does, in a loop: [pose, how long (ms), what it throws meanwhile]
const MOG_ACT = [['left', 460, 1], ['right', 460, 1], ['left', 380, 1], ['right', 380, 1], ['dive', 1050, 3], ['up', 520, 0], ['right', 420, 1], ['left', 420, 1], ['dive', 800, 2]];

Object.assign(T.fr, {mogLines: 'Voir les calculs', mogBack: 'Voir le Mog', mogAlt: 'Un Mog fouille dans un coffre pendant la recherche', mogWinAlt: 'Le Mog fête le set trouvé', mogSameAlt: 'Le Mog est perplexe : ton set était déjà le meilleur'});
Object.assign(T.en, {mogLines: 'Show the search', mogBack: 'Show the moogle', mogAlt: 'A moogle rummages in a chest while the search runs', mogWinAlt: 'The moogle cheers for the set found', mogSameAlt: 'The moogle is puzzled: your set was already the best'});

const mogOn = () => motionOn();
const mogScene = () => document.querySelector('#overlay .optrun .mogscene');
const mogRand = (a, b) => a + Math.random() * (b - a);
const mogToggleHTML = () => `<button class="btn ghost" data-moglines>${esc(t(S.mogLines ? 'mogBack' : 'mogLines'))}</button>`;
function mogSceneHTML(){
  const img = (n, cls) => `<img class="${cls}" src="${MOG_IMG}${n}.webp" alt="" draggable="false">`;
  return `<div class="mogscene" role="img" aria-label="${esc(t('mogAlt'))}"><div class="mogstage"><i class="mogshadow"></i>${img('chest_back', 'mogback')}` +
    `<div class="mogwho" data-pose="left">${['left', 'right', 'dive', 'up'].map(p => img('mog_' + p, 'p-' + p)).join('')}</div><div class="mogsmoke" data-f="0">${[1, 2, 3, 4].map(n => img('smoke_' + n, 's-' + n)).join('')}</div>${img('chest_front', 'mogfront')}</div></div>`;
}

// The result's moogle, beside the value found. A better set: it hops for joy without end, its four drawings
// following the hop, stars around it. The set was already the best: it is puzzled, its four drawings of that in turn
function mogWinHTML(found){
  if (!mogOn()) return '';
  const img = (file, n) => `<img class="w-${n}" src="${MOG_IMG}${file}.webp" alt="" draggable="false">`;
  const stars = Array.from({length: 9}, (x, i) => `<b class="mogstar" style="--a:${Math.round(i * 40 + mogRand(-12, 12))}deg;--d:${Math.round(mogRand(60, 96))}px"></b>`).join('');
  return `<div class="mogwin ${found ? 'found' : 'same'}" data-pose="${(found ? MOG_WIN : MOG_SAME)[0][0]}" role="img" aria-label="${esc(t(found ? 'mogWinAlt' : 'mogSameAlt'))}">` +
    (found ? stars + MOG_WIN.map(x => img('win_' + x[0], x[0])).join('') : '<b class="mogq">?</b>' + MOG_SAME.map(x => img('same_' + x[0], x[0])).join('')) + `</div>`;
}
// The four drawings, in the order of two hops: on the ground, in the air, on the ground, in the air
const MOG_WIN = [['wow'], ['jump'], ['proud'], ['party']];
// The puzzled ones, each for a sway: it wonders, scratches its head, thinks, shrugs
const MOG_SAME = [['optimal'], ['temple'], ['think'], ['shrug']];
// The drawing follows the hop (moogle.css mogjoy, read on the clock of its animation): one hop is up and down, the
// drawing changes as the moogle leaves the ground and as it lands, as long as the result is shown
function mogWinStart(dlg){
  const el = dlg.querySelector('.mogwin'), first = el && el.querySelector('img');
  if (!el) return;
  const step = () => {
    if (!el.isConnected) return;
    const anim = first.getAnimations()[0], hop = anim ? 2 * anim.effect.getTiming().duration : 680;
    const at = ((anim ? anim.currentTime : performance.now()) + hop * .14) % (hop * 2), ground = at % hop < hop * .28;
    const pose = el.classList.contains('same') ? MOG_SAME[Math.floor((anim ? anim.currentTime : performance.now()) / hop) % MOG_SAME.length][0]
      : MOG_WIN[(at < hop ? 0 : 2) + (ground ? 0 : 1)][0];
    if (el.dataset.pose !== pose) el.dataset.pose = pose;
    requestAnimationFrame(step);
  };
  step();
}
// One piece of gear out of the chest: up from the opening, over a shoulder, down past the chest
function mogThrow(stage, side){
  const el = document.createElement('i'), dir = side || (Math.random() < .5 ? -1 : 1), size = mogRand(46, 72);
  el.className = 'mogfly';
  el.style.cssText = `--x:${Math.round(dir * mogRand(120, 330))}px;--h:${-Math.round(mogRand(120, 235))}px;--rot:${Math.round(dir * mogRand(260, 720))}deg;` +
    `--ms:${Math.round(mogRand(900, 1350))}ms;--s:${Math.round(size)}px;--from:${Math.round(mogRand(-50, 50))}px`;
  el.innerHTML = `<img src="${MOG_IMG}obj_${MOG_OBJS[Math.floor(Math.random() * MOG_OBJS.length)]}.webp" alt="" draggable="false">`;
  el.addEventListener('animationend', e => { if (e.target === el) el.remove(); });
  stage.appendChild(el);
}
// A bubble beside the moogle's head, on one side or the other, for a moment
function mogSay(stage){
  const el = document.createElement('b'), says = MOG_SAYS[S.lang] || MOG_SAYS.en, left = Math.random() < .5;
  el.className = 'mogsay ' + (left ? 'l' : 'r');
  el.textContent = says[Math.floor(Math.random() * says.length)];
  el.style.cssText = `--tilt:${Math.round(mogRand(-6, 6))}deg;top:${Math.round(mogRand(-78, -40))}px`;
  el.addEventListener('animationend', () => el.remove());
  stage.querySelectorAll('.mogsay').forEach(x => x.remove());
  stage.appendChild(el);
}
// The next thing the moogle does. The window hidden (Hide): nothing is drawn, the loop waits
function mogTick(){
  const scene = mogScene(), R = S._optRun;
  if (!R || R.done) return mogStop();
  if (!scene || !scene.offsetParent) return;
  const now = performance.now(), who = scene.querySelector('.mogwho'), stage = scene.querySelector('.mogstage');
  // the dust of the rummaging: its drawings in turn while the moogle digs, the last one (it scatters) as it looks up
  const smoke = scene.querySelector('.mogsmoke'), f = String(who.dataset.pose === 'up' ? 4 : MOG_SMOKE[Math.floor(now / 130) % MOG_SMOKE.length]);
  if (smoke.dataset.f !== f) smoke.dataset.f = f;
  if (now < MOG.until) return;
  const [pose, ms, n] = MOG_ACT[MOG.step++ % MOG_ACT.length];
  who.dataset.pose = pose; MOG.until = now + ms;
  // a word every third thing it does or so
  if (MOG.step % 3 === 1 || pose === 'up') mogSay(stage);
  for (let i = 0; i < n; i++) setTimeout(() => { if (stage.isConnected && scene.offsetParent) mogThrow(stage, pose === 'left' ? 1 : pose === 'right' ? -1 : 0); }, 90 + i * 260);
}
function mogStart(){
  clearInterval(MOG.timer);
  if (!mogScene()) return;
  Object.assign(MOG, {step: 0, until: 0, timer: setInterval(mogTick, 60)});
}
// The search ends: the moogle looks up, nothing more is thrown
function mogStop(){
  clearInterval(MOG.timer); MOG.timer = null;
  const scene = mogScene();
  if (scene) { scene.querySelector('.mogwho').dataset.pose = 'up'; scene.querySelector('.mogsmoke').dataset.f = '0'; }
}
// The window takes its result: the scene and its button go
function mogClear(dlg){
  mogStop();
  const body = dlg && dlg.querySelector('.body');
  if (body) body.classList.remove('mog', 'lines');
}

document.addEventListener('click', e => {
  const b = e.target.closest && e.target.closest('[data-moglines]');
  if (!b) return;
  S.mogLines = !S.mogLines; save();
  const body = b.closest('.optrun').querySelector('.body');
  body.classList.toggle('lines', !!S.mogLines);
  b.textContent = t(S.mogLines ? 'mogBack' : 'mogLines');
});
