// GearSwap Atelier · the page's Settings (the gear of the top bar): the theme (a card each, its small preview), the
// language, the motion, the moogle assistant, the calculation engine (where it comes from, and what it did not compute
// since the page was opened).
// The rules are the old page's renderConfig (config_page.js), motionConfigHTML (motion.js) and guideConfigHTML
// (guide.js), which keep the themes, the texts and the clicks (data-theme-set, data-lang, data-motion-set,
// data-guide-mode, data-guide-reset, data-config).
//
// @file    atelier/src/screens/settings/settings.ts
// @author  ejouanchicot

export interface SettingsView {
  title: string; back: string;
  theme: {title: string; why: string; cards: Array<{id: string; on: boolean; pv: string; name: string; desc: string}>};
  lang: {title: string; why: string; fr: boolean; en: boolean};
  motion: {title: string; why: string; on: boolean; onLabel: string; offLabel: string};
  guide: {title: string; why: string; modes: Array<{v: string; on: boolean; label: string}>; reset: string};
  engine: {title: string; why: string; fell: string};
}

// The engine: where it comes from, and what it did not compute since the page was opened (calc_bridge.js
// FFXI.engine.fell: the reasons, each said as the page says it)
function engineView(): SettingsView['engine'] {
  const F = (window as LegacyAny).FFXI, fell = (Object.entries((F && F.engine && F.engine.fell) || {}) as Array<[string, number]>).sort((a, b) => b[1] - a[1]);
  return {title: t('cfgEngine'), why: t('cfgEngineWhy'),
    fell: fell.length ? t('engFellNow') + ' ' + fell.map(([w, n]) => `${n} × ${notComputedText(w).replace(/^[^:]+: /, '')}`).join(' · ') : ''};
}

/** The Settings page, or null when it is not the one shown (the packages come first; the update screen is one of its pages) */
export function settingsView(): SettingsView | null {
  if (!S._cfg || S._upd || (S._pkg && typeof renderPackages === 'function')) return null;
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
