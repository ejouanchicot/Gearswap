// GearSwap Atelier · config_page.js: the Settings page (the gear of the top bar): the theme, the language, the engine
// (drawn by atelier/src/screens/settings: here the themes and the texts).
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
  cfgEngine: 'Moteur de calcul', cfgEngineWhy: 'Ce qui calcule les dégâts et cherche les meilleurs sets : écrit pour cette page, depuis BG Wiki, wiki.ffo.jp, des tests publiés et des mesures faites en jeu. Ce qu’il ne calcule pas, la page le dit à la place du chiffre, avec la raison.',
  engFellNow: 'Non calculé depuis l’ouverture de la page :'});
Object.assign(T.en, {grpFiles: 'Files', grpPage: 'Page', grpChar: 'Character', cfgTitle: 'Settings', cfgBack: 'Back', cfgOpen: 'Settings',
  cfgTheme: 'Theme', cfgThemeWhy: 'The look of the whole page. The figures and the layout do not change.',
  theme_vanadiel: 'Vana’diel', themeD_vanadiel: 'The game’s blue windows, the ▶ cursor on the chosen row.',
  theme_grimoire: 'Grimoire', themeD_grimoire: 'Dark parchment and gilt, engraved titles.',
  theme_dark: 'Atelier dark', themeD_dark: 'The original theme: plain, high contrast.',
  theme_light: 'Atelier light', themeD_light: 'A light background, for a bright room.',
  cfgLang: 'Language', cfgLangWhy: 'The language of the page. Item, spell and set names stay the game’s.',
  cfgEngine: 'Calculation engine', cfgEngineWhy: 'What works out the damage and searches for the best sets: written for this page, from BG Wiki, wiki.ffo.jp, published tests and measures taken in game. What it does not compute, the page says instead of the figure, with the reason.',
  engFellNow: 'Not computed since the page was opened:'});
