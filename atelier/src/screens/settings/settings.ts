// GearSwap Atelier · the page's Settings (the gear of the top bar): the theme (a card each, its small preview), the
// language, the motion, the moogle assistant, the calculation engine (the two side by side, the one in use lit, and
// what fell back to wsdist since the Atelier's engine was chosen).
// The rules are the old page's renderConfig (config_page.js), motionConfigHTML (motion.js) and guideConfigHTML
// (guide.js), which keep the themes, the texts and the clicks (data-theme-set, data-lang, data-motion-set,
// data-guide-mode, data-guide-reset, data-engine, data-config).
//
// @file    atelier/src/screens/settings/settings.ts
// @author  ejouanchicot

export interface SettingsView {
  title: string; back: string;
  theme: {title: string; why: string; cards: Array<{id: string; on: boolean; pv: string; name: string; desc: string}>};
  lang: {title: string; why: string; fr: boolean; en: boolean};
  motion: {title: string; why: string; on: boolean; onLabel: string; offLabel: string};
  guide: {title: string; why: string; modes: Array<{v: string; on: boolean; label: string}>; reset: string};
  engine: {title: string; why: string; none: string; cards: Array<{id: string; on: boolean; title: string; reco: string; lines: string[]}>; link: string; url: string; fell: string};
}

const WSDIST_URL = 'https://github.com/IzaKastra/wsdist_beta';

// The two engines: whose each is and what it computes, the one in use lit; none until the engine is loaded
function engineView(): SettingsView['engine'] {
  const base = {title: t('cfgEngine'), why: t('cfgEngineWhy'), link: t('engLink'), url: WSDIST_URL, fell: ''};
  const F = (window as LegacyAny).FFXI;
  if (!(F && F.engine)) return Object.assign(base, {none: t('cfgEngineNone'), cards: []});
  const now = engineName(), fell = (Object.entries(F.engine.fell) as Array<[string, number]>).sort((a, b) => b[1] - a[1]);
  const card = (id: string, key: string, reco: boolean) => ({id, on: now === id, title: t(key + 'T'), reco: reco ? t('engReco') : '', lines: [1, 2, 3].map(n => t(key + n))});
  return Object.assign(base, {none: '', cards: [card('old', 'engOld', false), card('own', 'engOwn', true)],
    fell: now === 'own' && fell.length ? t('engFellNow') + ' ' + fell.map(([w, n]) => `${n} × ${w}`).join(' · ') : ''});
}

/** The Settings page, or null when it is not the one shown (the packages come first) */
export function settingsView(): SettingsView | null {
  if (!S._cfg || (S._pkg && typeof renderPackages === 'function')) return null;
  const mode = guideState().mode;
  return {title: t('cfgTitle'), back: t('cfgBack'),
    theme: {title: t('cfgTheme'), why: t('cfgThemeWhy'), cards: THEMES.map((x: LegacyAny) => { const [bg, panel, line, accent, ink, r] = x.pv;
      return {id: x.id, on: themeNow() === x.id, name: t('theme_' + x.id), desc: t('themeD_' + x.id),
        pv: `--pv-bg:${bg};--pv-panel:${panel};--pv-line:${line};--pv-accent:${accent};--pv-ink:${ink};--pv-r:${r}`}; })},
    lang: {title: t('cfgLang'), why: t('cfgLangWhy'), fr: (S as LegacyAny).lang === 'fr', en: (S as LegacyAny).lang === 'en'},
    motion: {title: t('cfgMotion'), why: t('cfgMotionWhy'), on: (S as LegacyAny).motion !== false, onLabel: t('cfgMotionOn'), offLabel: t('cfgMotionOff')},
    guide: {title: t('cfgGuide'), why: t('cfgGuideWhy'), modes: ['full', 'ask', 'off'].map(v => ({v, on: mode === v, label: t('gMode_' + v)})), reset: t('gReset')},
    engine: engineView()};
}
