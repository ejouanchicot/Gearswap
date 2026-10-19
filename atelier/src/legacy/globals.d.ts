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
declare function mxColorMap(x: LegacyField): unknown;
declare function mxColorList(f: LegacyConfigFile, x: LegacyField): boolean;
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
/* ---- the list of sets (sets_view.js, list_prefs.js), loosely typed ---- */
declare function buildCards(d: LegacyExport): {cards: LegacyAny[]; bypath: LegacyAny};
declare function cardUsable(c: LegacyAny): boolean;
declare function cardMatch(c: LegacyAny, q: string): boolean;
declare function listPrefs(): LegacyAny;
declare function tierFollowsSet(path: string, bypath: LegacyAny): void;
declare function subFollowsSet(path: string, bypath: LegacyAny): void;
declare function objFollowsSet(path: string, bypath: LegacyAny): void;
declare function famOpen(fam: string, q: string): boolean;
declare function topOf(path: string, fam: string): string[];
declare function segs(path: string): string[];
declare const MIDCAST_GROUP_FROM: number;
declare const MIDCAST_ORDER: string[];
declare function midcastGroup(name: string): string;
declare function midcastRank(name: string): number;
declare function niceName(card: LegacyAny): string;
declare function listFamHead(fam: string, n: number, here: boolean, open: boolean): string;
declare function enhTarget(s: LegacyAny): string;
declare function listModeValue(label: string): unknown;
declare function listMarks(s: LegacyAny): string;
declare function listRowActs(path: string, group?: string): string;
declare function listGroupPicker(path: string): string;
declare function trialCount(s: LegacyAny): number;
declare function wsSkills(): Record<string, string>;
declare function mogSorryHTML(html: string): string;
declare function listOwnSections(rowOf: (path: string, group: string) => string, known: Set<string>, q: string): string;
declare function tierLabel(label: string, head: string): string | null;
declare function aliasRows(cards: LegacyAny[], q: string): LegacyAny[];
interface Window { ATELIER_FAMILIES?: Record<string, Record<string, unknown>> }
declare function shownSet(card: unknown, i: number): LegacyAny;
declare function ui2CurrentSet(d: LegacyExport): unknown;
declare function charStats(set: unknown): unknown;
/** The character's stats as cards, the old page's HTML (sets_view.js) */
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

// ---- the Bags view (bags_view.js, bags_plan.js, bags_target.js, bags_place.js, module_items.js) ----
// The bags' data is the old page's own (the export's bags, the plan's sum): typed loosely, the view reads its fields
/* eslint-disable @typescript-eslint/no-explicit-any */
type LegacyAny = any;
declare function bvBags(): LegacyAny;
declare function bvWhere(B: LegacyAny): LegacyAny;
declare function bvRows(B: LegacyAny, sel: string, where: LegacyAny): LegacyAny[];
declare function bvFilter(rows: LegacyAny[]): LegacyAny[];
declare function bvRank(cat: string): number;
declare function bvShort(bag: string): string;
declare function bvCatName(cat: string): string;
declare const BV_CATS: string[];
declare function bvLit(bag: string): string;
declare function bvShut(bag: string): string;
declare function bvRoleName(B: LegacyAny, bag: LegacyAny): string;
declare function bvRoleShort(B: LegacyAny, bag: LegacyAny): string;
declare function bvRoles(B: LegacyAny, bag: LegacyAny): string[];
declare const BV_ROLES: string[];
declare function bvUseTip(r: LegacyAny): string;
declare function bvLockSets(r: LegacyAny): string[];
declare function bvIsGear(r: LegacyAny): boolean;
declare function bvUsage(): {jobs: string[]};
declare function bvPlace(): LegacyAny;
declare function bvFit(): void;
declare function plList(v: unknown): LegacyAny[];
declare const MOOGLE_PLACES: Record<string, Array<[string, string?]>>;
declare function bpCat(B: LegacyAny, r: LegacyAny): string;
declare function bpCatName(cat: string): string;
declare function bpDest(B: LegacyAny, r: LegacyAny): string;
declare function bpTags(): Record<string, string>;
declare function bpNpc(name: string): string;
declare function bpLock(): Record<string, string[]>;
declare function bpPlan(B: LegacyAny): {lines: LegacyAny[]; unknown: number; porter: number};
declare function bpLineBad(l: LegacyAny): boolean;
declare function bpMoves(B: LegacyAny): {moves: LegacyAny[]; noRoom: string[]};
declare const BP_CATS: string[];
/** An item's icon, as the old page's HTML (module_items.js) */
declare function itemIco(name: string, id?: number): string;

/* ---- Buffs & target (party_builder.js, buffs.js, buff_panels.js, profiles.js), loosely typed ---- */
declare function ui2(): boolean;
declare function buffState(): LegacyAny;
declare function buffCount(): number;
declare function buffKey(): string;
declare function buffTier(): string;
declare function buffTotals(): LegacyAny;
declare function pbShown(b: LegacyAny): string[];
declare function pbYouBody(b: LegacyAny): string;
declare function pbBody(job: string, b: LegacyAny, shown: string[]): string;
declare function pbJaJobs(): Map<string, LegacyAny[]>;
declare function pbImpactRows(s: LegacyAny): LegacyAny[];
declare const PB_JOBS: LegacyAny[];
declare const PB_MAX: number;
declare const PB_FOE: string[];
declare const TRUST_NAMES: Record<string, string | undefined>;
declare const FOE_JA: Record<string, Record<string, LegacyAny> | undefined>;
declare function enemyKey(enemy: unknown): string;
declare function fxShort(key: string, value: number): string;
declare function withAftermath(B: LegacyAny, main: unknown): LegacyAny;
declare function shownMain(): unknown;
declare function jasOf(): LegacyAny[];
declare function roundSet(s: LegacyAny): boolean;
declare function wsOfSet(s: LegacyAny): unknown;
declare function engineReady(): boolean;
declare function fmtDmg(n: number): string;
declare function shortPath(path: string): string;
declare function family(path: string, pieces?: unknown): string;
declare function songSlots(b: LegacyAny): number[];
declare const ARIA_HORN: Record<string, number>;
declare const ROMAN: string[];
declare const PROTECT: Record<string, number>;
declare const SHELL: Record<string, number>;
declare const AUSPICE_FEET: Record<string, number>;
declare function isNmTarget(key: string): boolean;
declare const EN_SKILLS: number[];
declare const DISTRACT: Record<string, number>;
declare function jaOn(b: LegacyAny, name: string): boolean;
declare function jaTip(ja: LegacyAny): string;
/* ---- the Sets screen (sets_view.js, layout2.js, stats.js), loosely typed ---- */
declare const SLOT_NAMES: Record<string, Record<string, string>>;
declare const SLOTS: string[];
declare function isLocked(s: LegacyAny, slot: string): boolean;
declare function LOCKABLE(slot: string): boolean;
declare function pieceStats(p: LegacyAny, slot?: string): LegacyAny;
declare function holdState(slot: string, p: LegacyAny): string;
declare function icon(name: string): string;
declare function variantGroups(card: LegacyAny): {groups: Map<string, LegacyAny>; skills: Record<string, string>};
declare function withWeapons(s: LegacyAny): LegacyAny;
declare function ownedOf(): Record<string, LegacyAny[]>;
declare function baseOnly(s: LegacyAny): boolean;
declare function isNukeSet(path: string): boolean;
declare function statSet(s: LegacyAny): boolean;
declare function optPageOpen(s: LegacyAny): boolean;
declare function wsHeadHTML(card: LegacyAny, ci: number, vi: number, s: LegacyAny): string;
declare function weaponMenus(s: LegacyAny): Array<[string, string, string]> | null;
declare function weaponResultLines(s: LegacyAny, pick: (lbl: string, body: string) => string): string;
declare function trialBar(s: LegacyAny): string;
declare function ui2Wants(s: LegacyAny): string;
/* ---- the figures of a set (engine.js, fight_stats.js, stat_opt.js, luopan.js, stats.js), loosely typed ---- */
declare function charStats(s: LegacyAny, pieces?: LegacyAny): LegacyAny;
declare function setStatsHTML(s: LegacyAny): string;
declare function statHelp(label: string, detail?: string): string;
declare function traitOf(stat: string, c: LegacyAny): number;
declare function giftOf(stat: string, c: LegacyAny): number;
declare function skillLevel(c: LegacyAny, name: string): number;
declare function phalanxPotency(skill: number): number;
declare function tpBase(delay: number): number;
declare const TWO_HANDED: RegExp;
declare const ENEMIES: Record<string, LegacyAny>;
declare function signed(n: number): string;
interface Window { ATELIER_FIGURES?: {tankBox: unknown; offenseBox: unknown; boxHtml: unknown} }
/* ---- the situations and profiles (profiles.js, buffs.js), loosely typed ---- */
declare const TIERS: string[];
declare function tierBuffsOf(tier: string): LegacyAny;
declare function profSummary(b: LegacyAny): string;
declare function profAll(): Record<string, LegacyAny>;
declare function profActive(): string | null;
declare function profChanged(name: string): boolean;
declare const PROF_FAVS: number;
declare const ROLE_COLOR: Record<string, string>;
declare const JOBS: LegacyAny[];
/* ---- the optimizer's page (opt_page.js, optimizer.js, ws_page.js, stat_opt.js, nuke_layers.js), loosely typed ---- */
declare function opObj(kind: string): string;
declare function opObjList(kind: string): string[];
declare function opObjLabel(kind: string, k: string): string;
declare function avgRange(o: LegacyAny): [number, number];
declare function optSettingsHelp(hit: boolean): string;
declare function opLimitHTML(attr: string, label: string, value: unknown): string;
declare function opLimitsHTML(title: string, tiles: string[], extra?: string): string;
declare function opSearchHTML(o: LegacyAny, ws: boolean, noWeapons?: unknown): string;
declare function opChangesHTML(s: LegacyAny): string;
declare function opFigures(s: LegacyAny, kind: string, plain?: boolean): LegacyAny;
declare function opRows(kind: string, obj: string): LegacyAny[];
declare function opNum(v: unknown, n?: number): string;
declare function nukeSpells(s: LegacyAny): string[];
declare function nukeSpellList(s: LegacyAny): string[];
declare function nukeKey(s: LegacyAny): string;
declare function cycleWsSets(s: LegacyAny): LegacyAny[];
declare function cycleWsSet(s: LegacyAny): LegacyAny;
declare function cycleInput(s: LegacyAny): LegacyAny;
declare function pdtLabel(): string;
declare function helpBtn(key: string): string;
declare function trialRow(s: LegacyAny): string;
declare function roundCalcHTML(x: LegacyAny, real: LegacyAny): string;
declare function isJumpSet(path: string): boolean;
declare function searchParked(): boolean;
declare function optGoButtons(act: string): string;
declare function noEngineText(): string;
declare function statWhatHTML(s: LegacyAny): string;
declare function statResultHTML(s: LegacyAny): string;
/* ---- the search window (optimizer.js, moogle.js), loosely typed ---- */
interface Window { ATELIER_RUN?: {open: (R: LegacyAny) => void; changed: () => void} }
declare function optRunBest(R: LegacyAny): LegacyAny;
declare function walkLabel(w: string): string;
declare function mogSceneHTML(): string;
/* ---- the windows over the page (trial.js, stats.js, drawer.js, stat_opt.js), loosely typed ---- */
interface Window { ATELIER_DIALOG?: {show: (d: LegacyAny) => void; compareView: (s: LegacyAny) => LegacyAny; gearPickView: (...a: LegacyAny[]) => LegacyAny; update: (d: LegacyAny) => void; targetView: () => LegacyAny; pickView: (key: string) => LegacyAny; addView: () => LegacyAny; pushView: (...a: LegacyAny[]) => LegacyAny; delView: (...a: LegacyAny[]) => LegacyAny; addSetView: (...a: LegacyAny[]) => LegacyAny; tierCostView: (...a: LegacyAny[]) => LegacyAny; historyView: (...a: LegacyAny[]) => LegacyAny; optAllView: (R: LegacyAny) => LegacyAny; statPickView: () => LegacyAny; addStepView: () => LegacyAny; placesView: () => LegacyAny; porterView: () => LegacyAny; bagSendView: (mule: boolean) => LegacyAny; modPickView: (q: string) => LegacyAny} }
declare function compareColumns(s: LegacyAny): LegacyAny[];
declare function sirdMeritsOf(c: LegacyAny): number;
declare function setWants(s: LegacyAny): {want: LegacyAny};
declare function wantOf(want: LegacyAny, key: string): number;
declare function statVisible(k: string, s?: LegacyAny): boolean;
declare function statOrder(a: string, b: string): number;
declare const DT_KEYS: string[];
declare function baseKey(k: string): string;
declare function samePiece(a: LegacyAny, b: LegacyAny): boolean;
declare function statLabel(k: string, e: LegacyAny): string;
declare function fmtStat(e: {v: number; unit?: unknown}): string;
declare const GOOD_DOWN: Set<string>;
declare function danceFloor(kind: string, pieces: LegacyAny): number;
declare function wsDamage(s: LegacyAny): number | null;
declare function withTrialAs<X>(s: LegacyAny, tr: LegacyAny, fn: () => X): X;
declare function statSorter(s: LegacyAny, stats: LegacyAny): ((a: string, b: string) => number) | null;
declare function statFigures(s: LegacyAny): LegacyAny;
declare function statRows(s: LegacyAny): LegacyAny[];
declare function engRound(s: LegacyAny, plain?: boolean): LegacyAny;
declare const FFXI: LegacyAny;
declare function gpStats(s: LegacyAny): string[];
declare function gpValue(p: LegacyAny, slot: string, key: string): LegacyAny;
declare function gpInSrc(o: LegacyAny, src: string): boolean;
declare function gpKinds(rows: LegacyAny[]): Array<[string, number]>;
declare function gpSorts(fx: string): Array<[string, string]>;
declare const GP_SORT: Record<string, ((a: LegacyAny, b: LegacyAny) => number) | undefined>;
declare const GP_SRC: Array<[string, string]>;
declare const WEAPON_SLOTS: Set<string>;
declare function itemKind(name: string): string;
declare function whereLabel(w: string): string;
declare function wantsLine(s: LegacyAny): string;
declare function tgFavs(): string[];
declare function tgRecents(): string[];
declare function tgMonsters(): LegacyAny[];
declare function tgRate(you: LegacyAny, eva: number): number | null;
declare function tgTone(p: number | null): string;
declare function tgYou(): LegacyAny;
declare const TARGETS: Record<string, LegacyAny>;
declare const DEFAULT_ENEMY: string;
declare const PB_PICK: Record<string, LegacyAny>;
declare function pbAddGroups(shown: string[]): Array<[string, string[], (j: string) => string]>;
declare function diffHTML(before: string, after: string): string;
declare function isEmpty(p: LegacyAny): boolean;
declare function oaShort(R: LegacyAny, path: string): string;
declare const OA_EPS: number;
declare function liveWrite(): boolean;
declare const STAT_DEF: Record<string, LegacyAny>;
declare const STAT_GROUPS: Array<[string, string, string]>;
declare function statGroup(k: string): string;
declare function statShown(k: string): boolean;
declare function statPickTools(): string;
declare let addStep: number;
declare let addFam: string | null;
declare let addPath: string | null;
declare function catalogEntries(): LegacyAny[] | null;
declare function catFamily(e: LegacyAny): string;
declare function setThere(path: string): boolean;
declare function isThere(e: LegacyAny): boolean;
declare function parentOf(path: string): string | null;
declare function parentThere(e: LegacyAny): boolean;
declare function lineLabel(g: string): string;
declare function addWsList(cards: LegacyAny[]): string;
declare function bpMuleMoves(B: LegacyAny): {moves: LegacyAny[]; noRoom: string[]};
declare function mrNames(v: LegacyAny): string[];
declare const USABLE_ITEMS: LegacyAny[];
declare function miUsed(): string[];
declare function mxActs(): {ja: string[]; ma: string[]};
declare function mxActsUsed(file: string): string[];
declare const JA_ACCESS: LegacyAny;
declare const SPELL_ACCESS: LegacyAny;
declare function accessSpellsOf(n: string): LegacyAny[];
declare function miIsMode(v: LegacyAny): boolean;
declare function miLabel(v: string): string;
declare const WS_ACCESS: LegacyAny;
declare function mxWsWeapon(path: string): {name: string; kind: string} | null;
declare function mxWsGiven(): LegacyAny;
declare function mxSpell(n: string): boolean;
declare function isExcluded(name: string): boolean;
interface Window { ATELIER_SLOTMENU?: {view: (ci: number, slot: string) => LegacyAny; show: (v: LegacyAny) => HTMLElement} }
declare const WELCOME: {state: string; msg: string};
declare function counts(c: string): {sets: number; keys: number};
declare function recordOf(c: string, j: string): LegacyAny;
declare function engineName(): string;
declare function guideState(): {mode: string; seen: LegacyAny};
declare const THEMES: Array<{id: string; pv: string[]}>;
declare function themeNow(): string;
declare const PKG: LegacyAny;
declare const PKG_JOBS: string[];
declare function pkgKnownOf(name: string): LegacyAny;
declare const MAGIC_ORDER: string[];
declare function aimHas(aim: LegacyAny, target: string): boolean;
declare function magicLabel(sk: string): string;
declare function simState(): LegacyAny;
declare function simTpSteps(ws: string): number[];
declare function simResultHTML(d: LegacyAny): string;
declare function statPickBtn(): string;
declare function otherChar(): string | undefined;
declare function listFamLabel(f: string): string;
declare function familyNote(s: LegacyAny): string;
declare function warcryTp(b: LegacyAny, party?: boolean): number;
declare function amKind(w: string | null): string;
declare function aftermathOf(w: string | null): {fx: LegacyAny[]; note: string; text: string};
declare function isAfm3(path: string): boolean;
declare const PRIME_PDL: Set<string | null>;
declare const ROLL_JOB: Record<string, [string, ...LegacyAny[]]>;
declare function rollJobOn(b: LegacyAny, i: number): boolean;
declare function targetInfo(x: LegacyAny): LegacyAny;
declare function foeText(k: string, v: LegacyAny, b: LegacyAny): string | null | undefined;
declare function fxText(k: string, v: LegacyAny): string;
declare const GEO_DEBUFFS: Record<string, LegacyAny>;
declare function geoKeep(key: string): number;
declare const FOE_JA_FX: Record<string, LegacyAny>;
declare const RUNES: Record<string, string>;
declare function runeOf(b: LegacyAny): string;
declare function runeCount(b: LegacyAny): number;
declare function foeCounted(b: LegacyAny): LegacyAny;
declare const DIA: Record<string, LegacyAny>;
declare const DIA_OWNER: Record<string, string>;
declare function foeJaActive(b: LegacyAny): string[];
declare const FOE_SW: Record<string, string>;
declare const SMN_SKILLS: number[];
declare function smnSkill(b: LegacyAny): number;
declare function wsInfoOf(ws: string): LegacyAny;
declare function modOptions(x: LegacyAny): string[] | null;
declare function modAuto(x: LegacyAny): boolean;
declare function modShow(v: LegacyAny): string;
declare function mxNumOpts(x: LegacyAny, opts?: LegacyAny): {range: [number, number, number?] | null; step: number; std: LegacyAny; unit: string};
declare function mxHex(r: LegacyAny, g: LegacyAny, b: LegacyAny): string;
declare function mrCols(x: LegacyAny): string[];
declare function mrCol(x: LegacyAny, k: string, opts: LegacyAny): LegacyAny;
declare function mrUnfilled(x: LegacyAny, r: LegacyAny): boolean;
declare function mrCellShow(v: LegacyAny): string;
declare function mrEmpty(v: LegacyAny): boolean;
declare const MR_SLOTS: string[];
declare function catalog(): LegacyAny;
declare function deletable(path: string): boolean;
declare function nukeSituation(s: LegacyAny): LegacyAny;
declare function autoBelt(): LegacyAny;
declare const NUKE_SITS: Record<string, LegacyAny>;
declare const ORPHEUS: string;
declare const OBI: string;
declare function nukeLayersApply(s: LegacyAny): boolean;
declare const NUKE_LAYERS: Record<string, LegacyAny[]>;
declare function setPieces(path: string): LegacyAny;
declare function shortSet(path: string): string;
declare function mpThreshold(): number;
declare function fightFigures(s: LegacyAny): LegacyAny;
declare function fightWhyNot(fell: LegacyAny): string;
declare const FIGHT_LINES: LegacyAny[];
declare function setStats(s: LegacyAny): LegacyAny;
declare const CALC: LegacyAny;
declare function fightMaccTip(sheet: LegacyAny, enemy: LegacyAny, spell: string, burst: boolean, macc: number): string;
declare function isBurstSet(path: string): boolean;
declare function setMaxHp(x: LegacyAny, nakedHp: number): number;
declare function hpRef(s: LegacyAny): LegacyAny;
declare function hpCycleRows(): LegacyAny[];
declare const HP_SPREAD: number;
declare function isLuopanCast(s: LegacyAny): boolean;
declare function isLuopanWorn(s: LegacyAny): boolean;
declare function luopanGear(pieces: LegacyAny): LegacyAny;
declare function luopanCharm(duration: number): number;
declare function luopanCastSet(): LegacyAny;
declare function luopanFigures(pieces: LegacyAny, cast: LegacyAny): LegacyAny;
declare function luNumber(n: number): string;
declare function luClock(secs: number): string;
declare const LUOPAN: LegacyAny;
declare const ULTIMATE_SHIELDS: Record<string, [number, number]>;
declare function cureGap(s: LegacyAny): LegacyAny;
declare function statBase(s: LegacyAny): LegacyAny;
declare function optPieces(p: LegacyAny): LegacyAny;
declare function withVec(p: LegacyAny, slot: string): LegacyAny;
declare const CRUSADE_ENMITY: number;
declare const ENMITY_LOSS_GEAR: Record<string, number>;
declare const ATTRS: string[];
