// GearSwap Atelier · config_page.js: the Settings page (the gear of the top bar): the theme, the language, the engine.
// What the page looks like and how it computes, kept in the browser with the rest of S (core.js KEEP).

// The themes (atelier/app/css/themes.css gives vanadiel and grimoire, base.css dark and light). pv: the colours of
// the small preview on its card: page, panel, line, accent, text, corner radius
const THEMES = [
  {id: 'vanadiel', pv: ['#060D1C', 'linear-gradient(180deg,#1A386E,#0B1A3A)', '#9FB6DC', '#FFE08A', 'rgba(238,243,255,.5)', '3px']},
  {id: 'grimoire', pv: ['#15110C', '#1F180D', '#6B5527', '#D7B25A', 'rgba(239,228,204,.45)', '2px']},
  {id: 'dark', pv: ['#090C11', '#121720', '#313B4A', '#E0B866', 'rgba(233,236,242,.45)', '6px']},
  {id: 'light', pv: ['#EDEFF3', '#FFFFFF', '#C9CED8', '#9A6B12', 'rgba(19,23,32,.4)', '6px']}];
const DEFAULT_THEME = 'vanadiel';
// The theme in force: the one chosen, else the default (a theme saved by an older page that no longer exists too)
const themeNow = () => THEMES.some(x => x.id === S.theme) ? S.theme : DEFAULT_THEME;

Object.assign(T.fr, {grpFiles: 'Fichiers', grpPage: 'Page', grpChar: 'Personnage', cfgTitle: 'Réglages', cfgBack: 'Retour', cfgOpen: 'Réglages',
  cfgTheme: 'Thème', cfgThemeWhy: 'L’habillage de toute la page. Les chiffres et l’organisation ne changent pas.',
  theme_vanadiel: 'Vana’diel', themeD_vanadiel: 'Les fenêtres bleues du jeu, le curseur ▶ sur la ligne choisie.',
  theme_grimoire: 'Grimoire', themeD_grimoire: 'Parchemin sombre et dorures, titres gravés.',
  theme_dark: 'Atelier sombre', themeD_dark: 'Le thème d’origine : sobre, contrasté.',
  theme_light: 'Atelier clair', themeD_light: 'Fond clair, pour une pièce lumineuse.',
  cfgLang: 'Langue', cfgLangWhy: 'La langue de la page. Les noms d’objets, de sorts et de sets restent ceux du jeu.',
  cfgEngine: 'Moteur de calcul', cfgEngineWhy: 'Qui calcule les dégâts et les optimisations. Le nouveau moteur suit ce qui a été mesuré en jeu ; il passe à l’ancien ce qu’il ne sait pas encore calculer.',
  cfgEngineNone: 'Le moteur n’est pas encore chargé : ouvre un set, puis reviens ici.',
  engOldT: 'Ancien moteur', engOwnT: 'Nouveau moteur', engReco: 'conseillé pour la mêlée',
  engOld1: 'Calcule tout : WS physiques, magiques, hybrides et à distance, toutes les abilities, les aftermaths.',
  engOld2: 'Suit des règles plus anciennes : il donne trop de dégâts aux coups critiques (environ un tiers de trop sur une WS à critiques) et ignore les coups « plancher ».',
  engOld3: 'À garder pour un mage, un tireur, ou pour comparer.',
  engOwn1: 'Écrit depuis BG-Wiki et depuis des mesures faites en jeu : coups critiques, coups plancher, TP rendu, effet des abilities.',
  engOwn2: 'Tombe à quelques pourcents des WS mesurées en jeu (Upheaval, Ukko’s Fury).',
  engOwn3: 'Ne calcule pas encore les WS magiques, hybrides et à distance, ni les aftermaths : il les passe à l’ancien moteur, et la liste de ce qu’il a passé s’affiche sous ces deux cartes.',
  engFellNow: 'Depuis ce choix, passé à l’ancien moteur :'});
Object.assign(T.en, {grpFiles: 'Files', grpPage: 'Page', grpChar: 'Character', cfgTitle: 'Settings', cfgBack: 'Back', cfgOpen: 'Settings',
  cfgTheme: 'Theme', cfgThemeWhy: 'The look of the whole page. The figures and the layout do not change.',
  theme_vanadiel: 'Vana’diel', themeD_vanadiel: 'The game’s blue windows, the ▶ cursor on the chosen row.',
  theme_grimoire: 'Grimoire', themeD_grimoire: 'Dark parchment and gilt, engraved titles.',
  theme_dark: 'Atelier dark', themeD_dark: 'The original theme: plain, high contrast.',
  theme_light: 'Atelier light', themeD_light: 'A light background, for a bright room.',
  cfgLang: 'Language', cfgLangWhy: 'The language of the page. Item, spell and set names stay the game’s.',
  cfgEngine: 'Calculation engine', cfgEngineWhy: 'What works out the damage and the optimisations. The new engine follows what was measured in game; it hands the old one what it does not compute yet.',
  cfgEngineNone: 'The engine is not loaded yet: open a set, then come back here.',
  engOldT: 'Old engine', engOwnT: 'New engine', engReco: 'advised for melee',
  engOld1: 'Computes everything: physical, magical, hybrid and ranged weaponskills, every ability, the aftermaths.',
  engOld2: 'Follows older rules: it gives critical hits too much damage (about a third too much on a weaponskill that crits) and ignores the "floor" hits.',
  engOld3: 'Keep it for a mage, a ranged job, or to compare.',
  engOwn1: 'Written from BG-Wiki and from measures taken in game: critical hits, floor hits, TP returned, what abilities do.',
  engOwn2: 'Lands within a few percent of the weaponskills measured in game (Upheaval, Ukko’s Fury).',
  engOwn3: 'Does not compute magical, hybrid and ranged weaponskills yet, nor aftermaths: it hands them to the old engine, and what it handed over is listed under these two cards.',
  engFellNow: 'Since this choice, handed to the old engine:'});

function themeCardHTML(x){
  const [bg, panel, line, accent, ink, r] = x.pv;
  return `<button class="themecard" data-theme-set="${x.id}" aria-pressed="${themeNow() === x.id}">` +
    `<span class="pv" style="--pv-bg:${bg};--pv-panel:${panel};--pv-line:${line};--pv-accent:${accent};--pv-ink:${ink};--pv-r:${r}"><i></i><i></i></span>` +
    `<b>${esc(t('theme_' + x.id))}</b><small>${esc(t('themeD_' + x.id))}</small></button>`;
}
// The two engines side by side: what each computes and where it is right, the one in use lit
function engineCardsHTML(){
  if (!(window.FFXI && FFXI.engine)) return `<div class="cfgrow"><span>${esc(t('cfgEngineNone'))}</span></div>`;
  const now = engineName(), fell = Object.entries(FFXI.engine.fell).sort((a, b) => b[1] - a[1]);
  const card = (id, key, reco) => `<button class="engcard" data-engine="${id}" aria-pressed="${now === id}"><b>${esc(t(key + 'T'))}` +
    `${reco ? ` <em>${esc(t('engReco'))}</em>` : ''}</b><ul>${[1, 2, 3].map(n => `<li>${esc(t(key + n))}</li>`).join('')}</ul></button>`;
  return `<div class="engines">${card('old', 'engOld', false)}${card('own', 'engOwn', true)}</div>` +
    (now === 'own' && fell.length ? `<p class="engfell">${esc(t('engFellNow'))} ${fell.map(([w, n]) => `${n} × ${esc(w)}`).join(' · ')}</p>` : '');
}
function renderConfig(){
  const lang = `<div class="seg" role="group" aria-label="${esc(t('cfgLang'))}"><button data-lang="fr" aria-pressed="${S.lang === 'fr'}">Français</button>` +
    `<button data-lang="en" aria-pressed="${S.lang === 'en'}">English</button></div>`;
  return `<div class="cfg"><header><h2>${esc(t('cfgTitle'))}</h2><button class="btn ghost" data-config>← ${esc(t('cfgBack'))}</button></header>` +
    `<section class="box"><h3>${esc(t('cfgTheme'))}</h3><p>${esc(t('cfgThemeWhy'))}</p><div class="themes">${THEMES.map(themeCardHTML).join('')}</div></section>` +
    `<section class="box"><h3>${esc(t('cfgLang'))}</h3><p>${esc(t('cfgLangWhy'))}</p><div class="cfgrow">${lang}</div></section>` +
    `<section class="box"><h3>${esc(t('cfgEngine'))}</h3><p>${esc(t('cfgEngineWhy'))}</p>${engineCardsHTML()}</section></div>`;
}
