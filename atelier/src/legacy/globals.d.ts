// GearSwap Atelier · what the Svelte screens read of the old page (atelier/app/js/, globals of its scripts), typed as
// far as the screens use it. A screen moved to Svelte reads the old page only through these names; each goes when
// the old file that declares it goes.
//
// @file    atelier/src/legacy/globals.d.ts
// @author  ejouanchicot

/** One job's export of one character (atelier/app/js/core.js recordOf), the fields the screens read */
interface LegacyExport {
  sub?: string;
  at?: string;
  live?: boolean;
  offline?: boolean;
  export_version?: number;
  sets: unknown[];
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
