// GearSwap Atelier · what the Svelte screens read of the old page (atelier/app/js/, globals of its scripts), typed as
// far as the screens use it. A screen moved to Svelte reads the old page only through these names; each goes when
// the old file that declares it goes.
//
// @file    atelier/src/legacy/globals.d.ts
// @author  ejouanchicot

/** A key of the job, as the export lists it (keys.js) */
interface LegacyKey { id?: string; src: string; desc: string; state?: string; subjob?: string; key?: string; file_key?: string; visible_now?: boolean }
/** A mode of the job (state.<name>) */
interface LegacyMode { name: string; desc?: string; values: string[]; current: string }
/** A macro book entry: a book and page, or one by subjob */
interface LegacyBook { book?: number; page?: number; [sub: string]: unknown }

/** One job's export of one character (atelier/app/js/core.js recordOf), the fields the screens read */
interface LegacyExport {
  sub: string;
  at?: string;
  live?: boolean;
  offline?: boolean;
  export_version?: number;
  sets: unknown[];
  keys: LegacyKey[];
  modes: LegacyMode[];
  temp_binds?: Record<string, string>;
  macro?: {default?: unknown; solo?: Record<string, LegacyBook>; dualbox?: Record<string, Record<string, LegacyBook>>};
  lockstyle?: {default?: number | string; by_subjob?: Record<string, number | string>};
  lockstyle_fallback?: number | string;
  porterpacker?: {file: string; exists?: boolean; wanted?: string[]; add: string[]; remove: string[]};
}

/** The game's state of a character (atelier/app/js/live.js S._live) */
interface LegacyLive { ok?: boolean; job?: string; sub?: string }

/** An order to the game under way (live.js liveBusyStart) */
interface LegacyBusy { what: string; until: number; was: {ok: boolean; job?: string; sub?: string; link: boolean} }

/** The old page's state (core.js S): the keys the screens read */
interface LegacyState {
  char: string;
  job: string | null;
  section: string;
  lang: 'fr' | 'en';
  subs: Record<string, string>;
  _cfg?: boolean;
  _pkg?: boolean;
  _refresh?: 'busy' | 'none' | 'fail' | null;
  _refreshErr?: string;
  _live: Record<string, LegacyLive | undefined>;
  _liveBusy?: LegacyBusy | null;
  toast?: string;
  keysAll?: boolean;
  keyDirty: Record<string, boolean | undefined>;
  meritEdits: Record<string, Record<string, number> | undefined>;
  [key: string]: unknown;
}

declare const S: LegacyState;
/** The jobs: [code, name, role] (core.js) */
declare const JOBS: Array<[string, string, string]>;
declare const ROLES: string[];
declare const ROLE_COLOR: Record<string, string>;
declare const CHARS: Record<string, {jobs: string[]}>;
declare const EXPORT_VERSION: number;
/** The text of a key in the page's language, {name} filled (i18n.js) */
declare function t(key: string, args?: Record<string, unknown>): string;
/** The page's texts by language (i18n.js and the Object.assign of each file) */
declare const T: Record<'fr' | 'en', Record<string, string | undefined>>;
declare function data(): LegacyExport | null | undefined;
declare function emblem(job: string): string;
declare function jobGroups(): Array<{label: string | null; jobs: Array<[string, string, string]>; master?: boolean}>;
declare function masterOf(job: string): number | null;
declare function plays(job: string): boolean;
declare function bookOf(d: LegacyExport): string;
declare function styleOf(d: LegacyExport): string;
declare function subsOf(char: string, job: string | null): string[];
declare function subOf(char: string, job: string | null): string;
declare function exportsOf(char: string, job: string | null): Record<string, LegacyExport>;
declare function defaultSub(char: string, job: string | null): string;
declare function sameAsOf(char: string, job: string | null): Record<string, string>;
declare function allSubs(char: string, job: string | null): string[];
declare function liveConf(char: string): unknown;
declare function linkConf(char: string): unknown;
declare function linkOk(char?: string): boolean;
declare const renderPackages: undefined | (() => string);

// ---- the job's settings (keys.js, core.js, sets_view.js, layout2.js, modules.js) ----
/** Text made safe for HTML (core.js) */
declare function esc(text: unknown): string;
declare const JOB_CFG: string[];
declare function jobCfgTab(): string;
declare function keysShown(d: LegacyExport): LegacyKey[];
declare function modFiles(d: LegacyExport): unknown[];
/** A job's level badge (ML or level), as HTML */
declare function jobBadge(job: string): string;
declare function keyOf(k: LegacyKey): string | undefined;
declare function fileKey(k: LegacyKey): string | undefined;
declare function hasOverride(k: LegacyKey): boolean;
declare function keyActive(k: LegacyKey, sub: string): boolean;
declare function keyClash(d: LegacyExport, k: LegacyKey, key: string | undefined): LegacyKey[];
declare function keyBeatenBy(d: LegacyExport, k: LegacyKey): LegacyKey | null;
declare function keyCondition(k: LegacyKey): string;
/** A key as the keyboard's caps, as HTML ("no key" when none) */
declare function keyLabel(key: string | undefined): string;
declare function keyDescText(desc: string): string;
declare function stateHelp(name: string): string;
declare const MOTE_BINDS: Array<[string, string, string]>;
declare const MOTE_DESC_FR: Record<string, string>;
declare function moteTakenBy(d: LegacyExport, key: string): LegacyKey | null;
declare function keyOverrides(): Record<string, Record<string, string>>;
declare function keyOfState(d: LegacyExport): Record<string, string>;
declare function stateElsewhere(d: LegacyExport, name: string): boolean;
declare function modeHidden(m: LegacyMode): boolean;
declare function macroAlt(d: LegacyExport): string | null;
declare function bookFor(d: LegacyExport, alt?: string | null): {book: number; page: number} | null;

// ---- the Modules part (modules.js, module_ux.js, module_rest_fr.js, module_catalog.js) ----
/** A setting of a config file, as the page's Lua reader gives it (modules.js luaSettings) */
interface LegacyField {
  key?: string; index?: number; path: string; kind: string; value: unknown; fields: LegacyField[];
  doc?: string[]; note?: string; a: number; b: number;
}
/** A config file of the export (atelier_configs.lua) */
interface LegacyConfigFile { file: string; text: string; hash?: string; scope: 'job' | 'common' }
interface LegacyParsed { head: {name?: string; tag?: string; about?: string}; fields: LegacyField[]; byPath: Record<string, LegacyField> }
/** An option of the catalog (module_catalog.js) */
interface LegacyCatalogItem { file?: string; key?: string; only?: string; when?: string; choices?: unknown[]; rgb?: boolean; presets?: unknown; cols?: unknown; [k: string]: unknown }
interface LegacyFamily { id: string; group: string; fr: string; en: string; tip: [string, string]; use?: [string, string]; items: LegacyCatalogItem[] }
interface LegacyGroup { id: string; fr: string; en: string }
/** One option of a family that a file of the character holds (modules.js mcRows) */
interface LegacyCatalogRow { it: LegacyCatalogItem; f: LegacyConfigFile; x: LegacyField; id: string; title: string; desc: string }
interface LegacyEdit { v: unknown; before: string; after: string; src: string }

declare const MOD_CATALOG: LegacyFamily[];
declare const MOD_GROUPS: LegacyGroup[];
declare function modShown(d: LegacyExport): LegacyConfigFile;
declare function modCount(): number;
declare function modParsed(f: LegacyConfigFile): LegacyParsed;
declare function modEdits(file: string): Record<string, LegacyEdit | undefined>;
declare function modCanWrite(f: LegacyConfigFile): boolean;
declare function modRestFr(file: string, path: string): null | {title: string; desc: string; map?: boolean};
declare function modName(x: LegacyField): string;
declare function modDoc(lines?: string[]): string;
declare function modValue(file: string, path: string): unknown;
declare function modFileInfo(f: LegacyConfigFile): {name: string; what: string};
declare function modKnown(d: LegacyExport, f: LegacyConfigFile): Record<string, LegacyCatalogRow>;
declare function modFileGroup(f: LegacyConfigFile): string;
declare function modGroupName(g: LegacyGroup): string;
declare function mcRows(d: LegacyExport, fam: LegacyFamily): LegacyCatalogRow[];
declare function mcScope(d: LegacyExport, r: LegacyCatalogRow): {cls: string; text: string; tip: string};
/** A setting's control (switch, choices, number, chips, rows, colour...), as the old page's HTML */
declare function modControl(f: LegacyConfigFile, x: LegacyField, val: unknown, id: string, off: string, lopts?: unknown): string;
declare function mcControl(r: LegacyCatalogRow, val: unknown, id: string, off: string): string;
declare function mxColorMap(x: LegacyField): unknown;
declare function mxColorList(f: LegacyConfigFile, x: LegacyField): boolean;
declare function modColorMap(f: LegacyConfigFile, x: LegacyField, off: string): string;
declare function mxTitle(file: string, path: string): string;
declare function mxCut(text: unknown): string;
declare function mxNorm(text: unknown): string;
declare function mxHit(words: string[], ...texts: unknown[]): boolean;
declare function mxValText(v: unknown): string;
declare const MX_MAX: number;
declare function liveOk(char?: string): boolean;
declare const JOB_GUIDE_FR: Record<string, [string, Array<[string, string]>] | undefined>;
declare const JOB_GUIDE_EN: Record<string, [string, Array<[string, string]>] | undefined>;

// ---- My character (layout2.js renderPerso, engine.js merits, porter.js, sets_view.js, bags_view.js) ----
/** The list of sets on the left of a tab, as the old page's HTML, with the cards it shows (sets_view.js) */
declare function setListHTML(d: LegacyExport): {aside: string; vis: unknown[]; cards: unknown[]; sel: number};
declare function shownSet(card: unknown, i: number): unknown;
declare function ui2CurrentSet(d: LegacyExport): unknown;
declare function charStats(set: unknown): unknown;
/** The character's stats as cards, the old page's HTML (sets_view.js) */
declare function globalsHTML(set: unknown, only: string): string;
/** The character as the game measured it (engine.js) */
declare function measuredChar(): null | {at?: string; sub?: string; jp_spent?: number; merit_list?: LegacyMerit[]};
declare function jaLevels(): {ml?: number; sub?: number};
declare function shownJobLoaded(): boolean;
interface LegacyMerit { id: number; key: string; en: string; desc: string; level: number }
declare function meritList(): LegacyMerit[] | null;
declare function meritKey(): string;
declare function meritLevel(m: LegacyMerit): number;
declare function meritCap(m: LegacyMerit): number;
declare function meritEffect(m: LegacyMerit): null | {per: number; unit: string};
declare const MERIT_GROUPS: Array<[number, number, string]>;
declare const MERIT_COLORS: Record<string, string>;
/** The Bags view, still the old page's HTML (bags_view.js) */
declare function renderBags(): string;
