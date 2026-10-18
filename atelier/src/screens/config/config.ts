// GearSwap Atelier · the job's settings, as one tab with its parts: Keys, Modes, Functions, Macro book & lockstyle,
// Modules. Shown on a job with an export when its section is the job's settings (never over the page's settings or
// the packages). The part chosen is the old page's S.jobTab (layout2.js jobCfgTab); the parts' buttons keep the
// attribute its handler reads (events.js data-jobtab).
//
// @file    atelier/src/screens/config/config.ts
// @author  ejouanchicot
import {keysView, type KeysView} from './keys';
import {modesView, functionsView, type ModesView, type FunctionsView} from './modes';
import {macroView, type MacroView} from './macro';
import {modulesView, type ModulesView} from './modules';

export interface ConfigTab { key: string; label: string; count: number | ''; title: string; pressed: boolean }
export type ConfigPart =
  | {kind: 'keys'; view: KeysView} | {kind: 'modes'; view: ModesView} | {kind: 'functions'; view: FunctionsView}
  | {kind: 'macro'; view: MacroView} | {kind: 'modules'; view: ModulesView};
export interface ConfigView { aria: string; tabs: ConfigTab[]; part: ConfigPart }

const LABELS: Record<string, string> = {keys: 'sectionsKeys', modes: 'sectionsModes', functions: 'sectionsFunctions',
  macro: 'sectionsMacro', modules: 'sectionsModules'};

function partOf(cur: string, d: LegacyExport): ConfigPart {
  if (cur === 'keys') return {kind: 'keys', view: keysView(d)};
  if (cur === 'modes') return {kind: 'modes', view: modesView(d)};
  if (cur === 'functions') return {kind: 'functions', view: functionsView(d)};
  if (cur === 'macro') return {kind: 'macro', view: macroView(d)};
  return {kind: 'modules', view: modulesView(d)};
}

/** The job's settings for the old page's state now, or null when they are not shown */
export function configView(): ConfigView | null {
  if (S.section !== 'jobcfg' || S._cfg || (S._pkg && typeof renderPackages === 'function') || !S.job) return null;
  const d = data();
  if (!d) return null;
  const cur = jobCfgTab();
  const count = (k: string): number | '' => k === 'keys' ? keysShown(d).length : k === 'modules' ? modFiles(d).length || '' : '';
  return {
    aria: t('ui2JobCfg'),
    tabs: JOB_CFG.map(key => ({key, label: t(LABELS[key]!), count: count(key), title: t('ttTab_' + key, {n: count(key)}), pressed: key === cur})),
    part: partOf(cur, d)
  };
}
