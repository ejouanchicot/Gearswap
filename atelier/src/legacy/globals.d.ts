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
/** The Modules part, still the old page's HTML (modules.js) */
declare function renderModules(d: LegacyExport): string;
