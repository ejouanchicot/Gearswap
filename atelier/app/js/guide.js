// GearSwap Atelier · guide.js: the moogle assistant. It speaks by itself only the first time: a welcome visit that
// points at the page's own elements, then one word a page the first time that page is opened. After that it waits in
// its corner (bottom right): a click gives the help of the page shown. What it says: guide_texts.js.
// S.guide = {mode: 'full' (visit and words) | 'ask' (only when clicked) | 'off' (not shown), seen: {tour, <page>}},
// kept in the browser with the rest of S. guideAfter() is called at the end of each render.

const GUIDE = {page: null, timer: null, tour: null, steps: [], asked: false};
function guideState(){
  const g = S.guide && typeof S.guide === 'object' ? S.guide : {};
  return S.guide = {mode: ['full', 'ask', 'off'].includes(g.mode) ? g.mode : 'full', seen: g.seen || {}};
}
const guideLang = () => S.lang === 'en' ? 'en' : 'fr';
const guideBusy = () => !document.getElementById('overlay').hidden || GUIDE.tour != null;
// The page shown, as guide_texts.js names it
function guidePage(){
  if (S._cfg) return 'config';
  if (!S.job || !data()) return 'home';
  if (document.querySelector('#view .oppage')) return 'opt';
  // the job's settings: the help is that of the part shown (keys, modes, switches, macro book)
  if (S.section === 'jobcfg') return jobCfgTab();
  if (S.section === 'perso' && S.persoView === 'bags' && GUIDE_PAGES.fr.bags) return 'bags';
  return GUIDE_PAGES.fr[S.section] ? S.section : S.section === 'merits' ? 'perso' : 'sets';
}

Object.assign(T.fr, {gBtn: 'Aide du Mog', gOk: 'Compris', gMore: 'En savoir plus', gQuiet: 'Ne plus me montrer d’astuces', gTourAgain: 'Refaire la visite',
  gNext: 'Suivant', gPrev: 'Précédent', gSkip: 'Passer la visite', gEnd: 'C’est parti !', gStart: 'Oui, montre-moi', gTuto: 'Le tutoriel pas à pas', gTutoTip: 'Le Mog t’explique cette page étape par étape, en te montrant chaque élément.', gHere: 'Sur cette page',
  cfgGuide: 'Assistant Mog', cfgGuideWhy: 'Le Mog te fait visiter la page la première fois, dit un mot à ta première visite de chaque onglet, puis attend en bas à droite : un clic sur lui donne l’aide de la page où tu es.',
  gMode_full: 'Visite et astuces', gMode_ask: 'Seulement quand je clique', gMode_off: 'Coupé', gReset: 'Tout revoir depuis le début'});
Object.assign(T.en, {gBtn: 'Moogle help', gOk: 'Got it', gMore: 'Tell me more', gQuiet: 'Stop showing me tips', gTourAgain: 'Take the visit again',
  gNext: 'Next', gPrev: 'Back', gSkip: 'Skip the visit', gEnd: 'Let’s go!', gStart: 'Yes, show me', gTuto: 'The step-by-step tutorial', gTutoTip: 'The moogle explains this page step by step, showing you each element.', gHere: 'On this page',
  cfgGuide: 'Moogle assistant', cfgGuideWhy: 'The moogle shows you around the first time, says a word on your first visit of each tab, then waits at the bottom right: a click on it gives the help of the page you are on.',
  gMode_full: 'Visit and tips', gMode_ask: 'Only when I click', gMode_off: 'Off', gReset: 'See everything again from the start'});

/* ---- the moogle and what it shows ---- */
// Its two drawings of a pose (mouth shut, mouth open): it talks for a moment when it comes up
const guideMogHTML = pose => `<span class="gmog talks" aria-hidden="true">${['quiet', 'talk'].map(n =>
  `<img class="g-${n}" src="atelier/app/img/mog/guide_${pose}_${n}.webp" alt="" draggable="false">`).join('')}</span>`;
const guideDrop = id => { const el = document.getElementById(id); if (el) el.remove(); };
function guideAdd(id, cls, html){
  guideDrop(id);
  const el = document.createElement('div');
  el.id = id; el.className = cls; el.innerHTML = html;
  document.body.appendChild(el);
  return el;
}
// The moogle in a pose that moves (moogle.css .mogspr: four frames side by side in one image, scripts/atelier/
// mog_sprites.py): idle (it flies), sleep, sorry, carry (gear in its arms)
const mogSprite = (pose, size) => `<i class="mogspr mog-${pose}" ${size ? `style="--s:${size}px"` : ''} aria-hidden="true"></i>`;
// Something failed or was not found: the sorry moogle beside the reason (the Svelte screens' own: atelier/src/components/MogNote.svelte)
const mogSorryHTML = html => `<div class="mognote sorry">${mogSprite('sorry', 84)}<p>${html}</p></div>`;
// Its button in the corner (not drawn when the assistant is off): it flies there, and falls asleep when nobody has
// touched the page for a while (MOG_SLEEP_MS), until the pointer moves again
const MOG_SLEEP_MS = 120000;
let MOG_SEEN = Date.now();
function mogAwake(){ MOG_SEEN = Date.now(); const b = document.getElementById('mogbtn'); if (b && b.classList.contains('asleep')) b.classList.remove('asleep'); }
for (const ev of ['pointermove', 'pointerdown', 'keydown', 'wheel']) addEventListener(ev, mogAwake, {passive: true, capture: true});
setInterval(() => { const b = document.getElementById('mogbtn'); if (b && Date.now() - MOG_SEEN > MOG_SLEEP_MS) b.classList.add('asleep'); }, 5000);
function guideButton(){
  let b = document.getElementById('mogbtn');
  if (!b) { b = document.createElement('button'); b.id = 'mogbtn'; b.className = 'mogbtn'; b.innerHTML = mogSprite('idle'); document.body.appendChild(b); }
  b.hidden = guideState().mode === 'off';
  b.title = t('gBtn'); b.setAttribute('aria-label', t('gBtn'));
  // a dot on it when the page as it is deserves a look (a missing piece, another subjob in game...): it does not
  // speak by itself, the dot says a click is worth it
  let warn = 0;
  if (!b.hidden && GUIDE.tour == null) { try { warn = guideContext(guidePage()).filter(x => x.warn).length; } catch (e) { warn = 0; } }
  b.classList.toggle('haswarn', warn > 0);
}
// One word about a page, the first time it is opened: beside the button, nothing behind it is blocked
function guideNote(page){
  const p = GUIDE_PAGES[guideLang()][page];
  guideAdd('gnote', 'gnote', `${guideMogHTML('tips')}<div class="gbub" role="status"><b>${esc(p.title)}</b><p>${esc(p.intro)}</p><div class="gacts">` +
    (guideTuto(page) ? `<button class="btn" data-gtuto>${esc(t('gTuto'))}</button><button class="linkbtn" data-gok>${esc(t('gOk'))}</button>` : `<button class="btn" data-gok>${esc(t('gOk'))}</button>`) + `<button class="linkbtn" data-ghelp>${esc(t('gMore'))}</button>` +
    `<button class="linkbtn" data-gquiet>${esc(t('gQuiet'))}</button></div></div>`);
}
// The help of the page shown (a click on the button): first what the page is like right now (guide_context.js:
// read from the state, each line with "Show me" when an element of the page is the answer), then what is always
// true of the page
function guideHelp(){
  const page = guidePage(), p = GUIDE_PAGES[guideLang()][page], now = GUIDE.now = guideContext(page);
  guideDrop('gnote');
  const nowHTML = now.length ? `<h4>${esc(t('gcNow'))}</h4><ul class="gnow">${now.map((x, i) => `<li class="${x.warn ? 'warn' : ''}">${esc(x.text)}` +
    (x.sel && document.querySelector(x.sel) ? ` <button class="linkbtn" data-gshow="${i}">${esc(t('gcShow'))}</button>` : '') + `</li>`).join('')}</ul><h4>${esc(t('gcTips'))}</h4>` : '';
  guideAdd('ghelp', 'ghelp', `<div class="gbub" role="dialog" aria-label="${esc(t('gBtn'))}"><small>${esc(t('gHere'))}</small><b>${esc(p.title)}</b><p>${esc(p.intro)}</p>` +
    `${nowHTML}<ul>${p.tips.map(x => `<li>${esc(x)}</li>`).join('')}</ul><div class="gacts">${guideTuto(page) ? `<button class="btn" data-gtuto>${esc(t('gTuto'))}</button>` : ''}<button class="btn" data-gclose>${esc(t('close'))}</button>` +
    `<button class="linkbtn" data-gtour>${esc(t('gTourAgain'))}</button></div></div>${guideMogHTML('show')}`);
}
// "Show me": the moogle goes to the element a line is about and lights it, as in the visit (one step, then it ends)
function guideShow(i){
  const x = (GUIDE.now || [])[i];
  if (!x || !x.sel || !document.querySelector(x.sel)) return;
  guideDrop('ghelp');
  GUIDE.steps = [[x.sel, x.text]]; GUIDE.tour = 0; GUIDE.single = true;
  guideAdd('gtour', 'gtour', `<div class="gscrim"></div><div class="gspot"></div><div class="gcard"></div>`);
  guideTourDraw();
}

/* ---- the welcome visit ---- */
// The steps whose element is on the page now (a job with no set opened has no gear to show: those are passed)
function guideSteps(){
  return GUIDE_TOUR[guideLang()].filter(([sel]) => { const el = sel && document.querySelector(sel); return !sel || (el && el.getClientRects().length); });
}
function guideTourStart(){
  guideDrop('gnote'); guideDrop('ghelp');
  GUIDE.steps = guideSteps(); GUIDE.tour = 0;
  guideAdd('gtour', 'gtour', `<div class="gscrim"></div><div class="gspot"></div><div class="gcard"></div>`);
  guideTourDraw();
}
// A page's tutorial (guide_bags.js GUIDE_TUTO): a visit of that page alone, each step with the state it needs
const guideTuto = page => typeof GUIDE_TUTO === 'object' && GUIDE_TUTO[page] ? GUIDE_TUTO[page][guideLang()] : null;
function guideTutoStart(){
  const page = guidePage(), steps = guideTuto(page);
  if (!steps) return;
  guideDrop('gnote'); guideDrop('ghelp');
  GUIDE.steps = steps; GUIDE.tour = 0; GUIDE.tuto = page;
  guideAdd('gtour', 'gtour', `<div class="gscrim"></div><div class="gspot"></div><div class="gcard"></div>`);
  guideTourDraw();
}
function guideTourEnd(){
  GUIDE.tour = null; guideDrop('gtour');
  if (GUIDE.single) { GUIDE.single = false; return; }
  if (GUIDE.tuto) { guideState().seen[GUIDE.tuto] = true; GUIDE.tuto = null; save(); return; }
  const g = guideState(); g.seen.tour = true; g.seen[guidePage()] = true; save();
}
function guideTourDraw(){
  const i = GUIDE.tour, n = GUIDE.steps.length, [sel, text, prep] = GUIDE.steps[i];
  // a tutorial's step puts the view in the state it talks about, before looking for what it points at
  if (prep && typeof GUIDE_PREP === 'object' && GUIDE_PREP[prep] && GUIDE_PREP[prep]()) { save(); render(); }
  const box = document.getElementById('gtour');
  if (!box) return;
  const el = sel && document.querySelector(sel), r = el && el.getBoundingClientRect();
  if (r && (r.top < 0 || r.bottom > innerHeight) && r.height < innerHeight && sel !== '#mogbtn') el.scrollIntoView({block: 'center'});
  box.querySelector('.gcard').innerHTML = `${guideMogHTML(el ? 'point' : 'hello')}<div class="gbub"><p>${esc(text)}</p><div class="gacts">` +
    `<button class="btn" data-gnext>${esc(t(GUIDE.single ? 'gOk' : i === 0 ? 'gStart' : i === n - 1 ? 'gEnd' : 'gNext'))}</button>` +
    (i > 0 ? `<button class="linkbtn" data-gprev>${esc(t('gPrev'))}</button>` : '') +
    (i < n - 1 ? `<button class="linkbtn" data-gskip>${esc(t('gSkip'))}</button>` : '') + (GUIDE.single ? '' : `<span class="gcount">${i + 1} / ${n}</span>`) + `</div></div>`;
  guideTourPlace();
}
// The light on the element and the card beside it, the moogle always between the element and its bubble so that
// nothing hides what it shows: at the element's right (it points to the left: its drawing mirrored, bubble at its
// right), else at its left (it points to the right, bubble at its left), else under it (it points up) or over it (it points down)
function guideTourPlace(){
  const box = document.getElementById('gtour'), step = GUIDE.tour != null && GUIDE.steps[GUIDE.tour];
  if (!box || !step) return;
  const el = step[0] && document.querySelector(step[0]), spot = box.querySelector('.gspot'), card = box.querySelector('.gcard');
  const w = card.offsetWidth, h = card.offsetHeight, W = innerWidth, H = innerHeight, clamp = (v, a, b) => Math.max(a, Math.min(b, v));
  box.classList.toggle('nospot', !el);
  if (!el) { card.style.left = (W - w) / 2 + 'px'; card.style.top = (H - h) / 2 + 'px'; return; }
  const b = el.getBoundingClientRect(), r = {left: Math.max(b.left - 6, 4), top: Math.max(b.top - 6, 4), right: Math.min(b.right + 6, W - 4), bottom: Math.min(b.bottom + 6, H - 4)};
  Object.assign(spot.style, {left: r.left + 'px', top: r.top + 'px', width: r.right - r.left + 'px', height: r.bottom - r.top + 'px'});
  const where = r.right + 14 + w <= W - 8 ? 'right' : r.left - 14 - w >= 8 ? 'left' : r.bottom + 14 + h <= H - 8 ? 'under' : 'over';
  const beside = where === 'right' || where === 'left', midY = (r.top + r.bottom) / 2;
  const left = where === 'right' ? r.right + 14 : where === 'left' ? r.left - 14 - w : clamp(r.left + 24, 8, W - w - 8);
  const top = beside ? clamp(midY - h / 2, 8, H - h - 8) : where === 'under' ? r.bottom + 14 : Math.max(8, r.top - 14 - h);
  card.style.left = left + 'px'; card.style.top = top + 'px';
  card.dataset.where = where;
  guideSetPose(card, {right: 'point', left: 'point', under: 'up', over: 'down'}[where], where === 'right');
}
// A pose drawn towards the right serves for the left too, mirrored
function guideSetPose(card, pose, mirrored){
  card.querySelector('.gmog').classList.toggle('flip', !!mirrored);
  for (const img of card.querySelectorAll('.gmog img')) { const src = img.src.replace(/guide_[a-z]+_/, 'guide_' + pose + '_'); if (img.src !== src) img.src = src; }
}
function guideTourMove(d){
  if (GUIDE.tour == null) return;
  const i = GUIDE.tour + d;
  if (i >= GUIDE.steps.length) return guideTourEnd();
  GUIDE.tour = Math.max(0, i); guideTourDraw();
}

/* ---- after each redraw ---- */
// The first load: the visit. A page opened for the first time: its word, a moment after it is drawn, unless a
// window is open (it then waits for the next redraw)
function guideAfter(){
  const g = guideState(), page = guidePage();
  guideButton();
  // nothing exported yet (the welcome page): the visit waits for something to show
  if (!CHARS[S.char]) return;
  if (GUIDE.tour != null) return guideTourPlace();
  if (page === GUIDE.page) return;
  GUIDE.page = page; clearTimeout(GUIDE.timer); guideDrop('gnote'); guideDrop('ghelp');
  if (g.mode !== 'full' || (g.seen.tour && g.seen[page])) return;
  GUIDE.timer = setTimeout(() => {
    if (guidePage() !== page || guideBusy()) { GUIDE.page = null; return; }
    if (!g.seen.tour) return guideTourStart();
    g.seen[page] = true; save(); guideNote(page);
  }, 800);
}
function guideSetMode(mode){
  guideState().mode = mode; save();
  if (mode !== 'full') { guideDrop('gnote'); clearTimeout(GUIDE.timer); }
  if (mode === 'off') guideDrop('ghelp');
  render();
}
// From the help or the Settings: the visit again, on the Sets tab (what it points at is there)
function guideTourAgain(){
  S._cfg = false; if (S.job) S.section = 'sets';
  render();
  setTimeout(guideTourStart, 350);
}
const GUIDE_CLICKS = {
  gok: () => guideDrop('gnote'), gclose: () => guideDrop('ghelp'), ghelp: guideHelp, gtour: guideTourAgain,
  gquiet: () => guideSetMode('ask'), gtuto: guideTutoStart, gnext: () => guideTourMove(1), gprev: () => guideTourMove(-1), gskip: guideTourEnd};
document.addEventListener('click', e => {
  const at = q => e.target.closest && e.target.closest(q), mode = at('[data-guide-mode]');
  if (at('#mogbtn')) return document.getElementById('ghelp') ? guideDrop('ghelp') : guideHelp();
  if (mode) return guideSetMode(mode.dataset.guideMode);
  if (at('[data-guide-reset]')) { S.guide = {mode: 'full', seen: {}}; save(); return guideTourAgain(); }
  if (at('[data-gshow]')) return guideShow(+at('[data-gshow]').dataset.gshow);
  for (const [k, fn] of Object.entries(GUIDE_CLICKS)) if (at(`[data-${k}]`)) return fn();
});
document.addEventListener('keydown', e => {
  if (GUIDE.tour == null) return;
  if (e.key === 'Escape') guideTourEnd();
  else if (e.key === 'ArrowRight' || e.key === 'Enter') { e.preventDefault(); guideTourMove(1); }
  else if (e.key === 'ArrowLeft') guideTourMove(-1);
}, true);
addEventListener('resize', guideTourPlace);
