// GearSwap Atelier · keys.js: key names, keys changed in the page, the key editor, the Keys and Modes tabs
// (loaded in the order of atelier/src/legacy/files.ts)
/* ---- keys: Windower names, physical keys, the player's keyboard layout ---- */
// Windower binds physical keys (DirectInput scan codes, Hook.dll's table) named as on a US
// keyboard; KeyboardEvent.code names the same physical keys, whatever the layout
const CODE_KEY = {Backquote: '`', Minus: '-', Equal: '=', BracketLeft: '[', BracketRight: ']', Backslash: '\\', Semicolon: ';',
  Quote: "'", Comma: ',', Period: '.', Slash: '/', Tab: 'tab', Enter: 'enter', Backspace: 'backspace', Escape: 'escape', Space: 'space',
  ArrowUp: 'up', ArrowDown: 'down', ArrowLeft: 'left', ArrowRight: 'right', Home: 'home', End: 'end', PageUp: 'pageup', PageDown: 'pagedown',
  Insert: 'insert', Delete: 'delete', NumpadMultiply: 'numpad*', NumpadAdd: 'numpad+', NumpadSubtract: 'numpad-', NumpadDecimal: 'numpad.',
  NumpadDivide: 'numpad/', NumpadEnter: 'numpadenter'};
for (let i = 0; i < 26; i++) { const c = String.fromCharCode(65 + i); CODE_KEY['Key' + c] = c.toLowerCase(); }
for (let i = 0; i < 10; i++) { CODE_KEY['Digit' + i] = String(i); CODE_KEY['Numpad' + i] = 'numpad' + i; }
for (let i = 1; i <= 15; i++) CODE_KEY['F' + i] = 'f' + i;
const KEY_CODE = Object.fromEntries(Object.entries(CODE_KEY).map(([c, k]) => [k, c]));
// Keys printed on the player's keyboard: the browser's layout map when it gives one, else a
// layout chosen in the page (the main ones written here)
const LAYOUTS = {
  azerty: {KeyQ: 'a', KeyW: 'z', KeyA: 'q', KeyZ: 'w', KeyM: ',', Semicolon: 'm', Comma: ';', Period: ':', Slash: '!', Digit1: '&', Digit2: 'é',
    Digit3: '"', Digit4: "'", Digit5: '(', Digit6: '-', Digit7: 'è', Digit8: '_', Digit9: 'ç', Digit0: 'à', Minus: ')', Equal: '=', BracketLeft: '^',
    BracketRight: '$', Quote: 'ù', Backquote: '²', Backslash: '*'},
  qwertz: {KeyY: 'z', KeyZ: 'y', Minus: 'ß', Equal: '´', BracketLeft: 'ü', BracketRight: '+', Semicolon: 'ö', Quote: 'ä', Backquote: '^', Backslash: '#', Slash: '-'},
};
let LAYOUT_MAP = null;
try { navigator.keyboard && navigator.keyboard.getLayoutMap().then(m => { LAYOUT_MAP = m; if (S.char && CHARS[S.char]) render(); }, () => {}); } catch (e) {}
function printedKey(code){
  const pick = S.layout || 'auto';
  if (pick === 'auto' && LAYOUT_MAP && LAYOUT_MAP.get(code)) return LAYOUT_MAP.get(code);
  return (LAYOUTS[pick] || {})[code] || null;
}
const MOD_NAMES = {'^': 'Ctrl', '!': 'Alt', '@': 'Win', '#': 'Apps', '~': 'Shift'};
// "^!a" -> {mods: ['^', '!'], key: 'a'}; '%' / '$' (chat closed / open) kept apart
function parseKey(k){
  let i = 0; const mods = []; let chat = '';
  while (i < k.length - 1 && (MOD_NAMES[k[i]] || k[i] === '%' || k[i] === '$')) { if (MOD_NAMES[k[i]]) mods.push(k[i]); else chat = k[i]; i++; }
  return {mods, key: k.slice(i).toLowerCase(), chat};
}
// What the player reads on the key: their keyboard's character for letters and punctuation
function keyCap(key){
  const code = KEY_CODE[key];
  const printed = code && /^(Key|Digit|Minus|Equal|Bracket|Backslash|Semicolon|Quote|Comma|Period|Slash|Backquote)/.test(code) && printedKey(code);
  if (printed) return printed.toUpperCase();
  return key.replace(/^numpad(.+)$/, 'Num $1').replace(/^f(\d+)$/, 'F$1').replace(/^(.)$/, c => c.toUpperCase());
}
function keyLabel(k){
  if (!k) return `<span class="kbd none" title="${esc(t('ttNoKey'))}">${t('noKey')}</span>`;
  const {mods, key} = parseKey(k), cap = keyCap(key), us = key.length === 1 && cap !== key.toUpperCase();
  const parts = mods.map(m => MOD_NAMES[m]).concat(cap);
  return `<span class="kbd"${us ? ` title="${esc(t('usName', {k}))}"` : ''}>` + parts.map(p => '<kbd>'+esc(p)+'</kbd>').join('') + '</span>';
}

/* ---- keys changed in the page, saved into <Char>/atelier/overrides/keybind_overrides.lua ---- */
// S.keyOv[char] = {common: {id: key}, <JOB>: {id: key}}: the whole file, as the page wants it.
// It starts from what the last export read in the file (key_overrides), a later save wins.
function keyOverrides(){
  const c = S.char, mine = S.keyOv[c];
  const latest = latestExport(c, 'key_overrides');
  if (!mine || (latest && !S.keyDirty[c] && (latest.at || '') > (mine.at || ''))) {
    S.keyOv[c] = {at: latest ? latest.at : '', map: JSON.parse(JSON.stringify((latest && latest.key_overrides) || {}))};
  }
  return S.keyOv[c].map;
}
const keyScope = (k, job = S.job) => k.src === 'common' ? 'common' : job;
// The key a row has now: the page's override, else the key of the file (job: the export's, for another job than the shown one)
function keyOf(k, job){
  const ov = k.id ? (keyOverrides()[keyScope(k, job)] || {})[k.id] : undefined;
  return ov !== undefined ? ov : fileKey(k);
}
// The key the key file gives (the export keeps it in file_key when an override changed it)
const fileKey = k => k.file_key !== undefined ? k.file_key : k.key;
const hasOverride = k => !!k.id && (keyOverrides()[keyScope(k)] || {})[k.id] !== undefined;
// Local time, as the export writes it ("2026-10-01 15:22")
const stamp = () => { const d = new Date(), z = n => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${z(d.getMonth() + 1)}-${z(d.getDate())} ${z(d.getHours())}:${z(d.getMinutes())}`; };
function setKey(k, key){
  const map = keyOverrides(), scope = keyScope(k);
  map[scope] = map[scope] || {};
  if (key === undefined || key === fileKey(k)) delete map[scope][k.id]; else map[scope][k.id] = key;
  if (!Object.keys(map[scope]).length) delete map[scope];
  S.keyDirty[S.char] = true;
}
/* ---- mode start values chosen in the page, saved into <Char>/atelier/overrides/mode_overrides.lua ---- */
// S.modeOv[char] = {at, map: {common: {Mode: value}, <JOB>: {Mode: value}}}: the whole file, from what the last export
// read in it (mode_overrides), a later save wins. GearSwap lays it over the states files when a job loads
// (shared/utils/core/mode_overrides.lua).
// The modes every job has (the shared systems): one start value for every job
const COMMON_MODES = new Set(['AutoMedicine', 'CombatMode', 'TreasureMode', 'JumpAuto']);
const plainMap = m => m && !Array.isArray(m) && typeof m === 'object' ? m : {};
function modeOverrides(){
  const c = S.char, mine = S.modeOv[c];
  const latest = latestExport(c, 'mode_overrides');
  if (!mine || (latest && !S.modeDirty[c] && (latest.at || '') > (mine.at || ''))) {
    S.modeOv[c] = {at: latest ? latest.at : '', map: JSON.parse(JSON.stringify(plainMap(latest && latest.mode_overrides)))};
  }
  return S.modeOv[c].map;
}
const modeScope = name => COMMON_MODES.has(name) ? 'common' : S.job;
// The value a mode starts with from its states file: what the export saw before the page's override, else its value then
const modeFileStart = (d, m) => plainMap(d.mode_file)[m.name] ?? m.current;
// The start value now: the page's choice (the mode's own spelling: the game matches without case), else the file's
function modeStart(d, m){
  const ov = (modeOverrides()[modeScope(m.name)] || {})[m.name];
  if (ov === undefined) return modeFileStart(d, m);
  return m.values.find(v => v.toLowerCase() === String(ov).toLowerCase()) || ov;
}
// Choose a start value; the file's own removes the page's choice
function setModeStart(d, name, value){
  const m = d.modes.find(x => x.name === name);
  if (!m) return;
  const map = modeOverrides(), scope = modeScope(name);
  map[scope] = map[scope] || {};
  if (value.toLowerCase() === String(modeFileStart(d, m)).toLowerCase()) delete map[scope][name]; else map[scope][name] = value;
  if (!Object.keys(map[scope]).length) delete map[scope];
  S.modeDirty[S.char] = true;
}
const modeChanges = () => Object.values(modeOverrides()).reduce((n, m) => n + Object.keys(m).length, 0);
Object.assign(T.fr, {modesTitle: 'Modes : valeur de départ et touche', modesHint: 'Clique une valeur : le mode la prendra à chaque chargement du job. La valeur entourée en pointillé est celle de ton fichier ; la choisir à nouveau enlève ton choix. En jeu, la touche fait toujours défiler le mode.',
  modesAway: 'Modes d’un autre subjob que {s}', modeCommon: 'tous les jobs', modeFileTip: 'Valeur de départ dans ton fichier', modeStartTip: 'Valeur de départ choisie', modePickTip: 'Démarrer sur cette valeur',
  modesSaved: '{n} valeur(s) de départ choisie(s) (atelier/overrides/mode_overrides.lua).', savedModes: 'Enregistré dans {p}. En jeu : //gs reload ou change de job.', modesDirty: 'Valeurs de départ changées, pas encore enregistrées.', keysOther: 'Autres touches'});
Object.assign(T.en, {modesTitle: 'Modes: start value and key', modesHint: 'Click a value: the mode takes it at every load of the job. The value outlined with dots is your file’s; choosing it again removes your choice. In game, the key still cycles the mode.',
  modesAway: 'Modes of another subjob than {s}', modeCommon: 'every job', modeFileTip: 'Start value in your file', modeStartTip: 'Start value chosen', modePickTip: 'Start on this value',
  modesSaved: '{n} start value(s) chosen (atelier/overrides/mode_overrides.lua).', savedModes: 'Saved in {p}. In game: //gs reload or change job.', modesDirty: 'Start values changed, not saved yet.', keysOther: 'Other keys'});
// A key bound with the subjob shown: its subjob(s), less the ones it excludes (exclude_subjob), and not
// hidden by its own condition when the game exported it (visible: CombatMode where its settings hide it,
// PLD's MainWeapon in the Tanking stance)
function keyActive(k, sub){
  const only = k.subjobs || (k.subjob ? [k.subjob] : null);
  return (!only || only.includes(sub)) && !(k.exclude || []).includes(sub) && k.visible_now !== false;
}
// A common key gives way to a job or custom key on the same key, unless it is marked override
// (keybind_manager.lua): the two never fight, one of them is simply not bound
const keyYields = (a, b) => a.src === 'common' && b.src !== 'common' ? !a.override : b.src === 'common' && a.src !== 'common' ? !!b.override : false;
function keyBeatenBy(d, row){
  const key = (keyOf(row, d.job) || '').toLowerCase();
  if (!key || !keyActive(row, d.sub)) return null;
  return d.keys.find(k => k !== row && keyActive(k, d.sub) && (keyOf(k, d.job) || '').toLowerCase() === key && keyYields(row, k)) || null;
}
// The keys a job really has (a key, for this subjob, not taken by another): the count of the overview and of the tab
function keysShown(d){
  return d.keys.filter(k => keyOf(k, d.job) && keyActive(k, d.sub) && !keyBeatenBy(d, k));
}
// Other keys bound with the shown subjob on the same key (none when the row itself is not bound)
function keyClash(d, row, key){
  if (!key || !keyActive(row, d.sub)) return [];
  const want = key.toLowerCase();
  return d.keys.filter(k => k !== row && keyActive(k, d.sub) && (keyOf(k) || '').toLowerCase() === want && !keyYields(row, k) && !keyYields(k, row));
}
// What a bind waits for besides the subjob: an alt (dual box), a weapon in hand (keybind_manager.lua)
function keyCondition(k){
  const parts = [];
  if (k.alt) { const a = k.alt, what = [a.name, a.job, a.subjob && '/' + a.subjob, a.weapon].filter(Boolean).map(x => [].concat(x).join('|')).join(' ');
    parts.push(what ? t('keyIfAltIs', {a: what}) : t('keyIfAlt')); }
  if (k.weapon) parts.push(t('keyIfWeapon', {w: [].concat(k.weapon).join(', ')}));
  return parts.join(' · ');
}
// Mote's global keys (libs/Mote-Globals.lua global_on_load), bound on every job before the job's own
const MOTE_BINDS = [['f9', 'OffenseMode', 'cycle OffenseMode'], ['^f9', 'HybridMode', 'cycle HybridMode'], ['!f9', 'RangedMode', 'cycle RangedMode'],
  ['@f9', 'WeaponskillMode', 'cycle WeaponskillMode'], ['f10', null, 'DefenseMode Physical'], ['^f10', 'PhysicalDefenseMode', 'cycle PhysicalDefenseMode'],
  ['!f10', 'Kiting', 'toggle Kiting'], ['f11', null, 'DefenseMode Magical'], ['^f11', 'CastingMode', 'cycle CastingMode'], ['f12', null, 'update (gs c update user)'],
  ['^f12', 'IdleMode', 'cycle IdleMode'], ['!f12', null, 'reset DefenseMode'], ['^-', null, 'toggle SelectNPCTargets'], ['^=', null, 'cycle PCTargetMode']];
// What a key may do wrong: typing in the chat, Mote's own keys, Windower's paste
const MOTE_KEYS = new Set(MOTE_BINDS.map(([k]) => k));
// The job key on a Mote key, which replaces it (the job binds after Mote)
const moteTakenBy = (d, key) => d.keys.find(k => keyActive(k, d.sub) && (keyOf(k) || '').toLowerCase() === key) || null;
function keyWarnings(d, row, key){
  const out = [], {mods, key: name} = parseKey(key || '');
  if (!key) return out;
  for (const k of keyClash(d, row, key)) out.push(t('keyClash', {d: k.desc}));
  if (!mods.length && /^([a-z0-9]|[-=\[\];',.\/`\\]|space|enter|backspace|tab)$/.test(name)) out.push(t('keyTyping'));
  if (MOTE_KEYS.has(key.toLowerCase())) out.push(t('keyMote'));
  if (key.toLowerCase() === '^v') out.push(t('keyPaste'));
  if (!KEY_CODE[name] && !/^(numpad\d|f\d+)$/.test(name)) out.push(t('keyUnknown', {k: name}));
  return out;
}
let KEYEDIT = null;
function openKeyEdit(i){
  const d = data(), k = d.keys[i];
  KEYEDIT = {i, key: keyOf(k), mods: parseKey(keyOf(k) || '').mods};
  renderKeyEdit();
}
function renderKeyEdit(){
  const d = data(), k = d.keys[KEYEDIT.i], key = KEYEDIT.key, file = fileKey(k);
  const warn = keyWarnings(d, k, key);
  const p = parseKey(key || ''), names = Object.values(CODE_KEY);
  const groups = [['letters', names.filter(n => /^[a-z]$/.test(n))], ['digits', names.filter(n => /^\d$/.test(n))],
    ['numpad', names.filter(n => /^numpad/.test(n))], ['fkeys', names.filter(n => /^f\d+$/.test(n))],
    ['punct', names.filter(n => n.length === 1 && !/^[a-z0-9]$/.test(n))], ['others', names.filter(n => n.length > 1 && !/^(numpad|f\d)/.test(n))]];
  const opts = groups.map(([g, list]) => `<optgroup label="${t('kg.' + g)}">${list.map(n => `<option value="${esc(n)}" ${n === p.key ? 'selected' : ''}>${esc(keyCap(n))}${keyCap(n).toLowerCase() !== n ? ` (${esc(n)})` : ''}</option>`).join('')}</optgroup>`).join('');
  const mods = Object.entries(MOD_NAMES).map(([m, n]) => `<label class="chip"><input type="checkbox" class="kmod" value="${esc(m)}" ${p.mods.includes(m) ? 'checked' : ''}>${n}</label>`).join('');
  $('#overlay').innerHTML = `<div class="scrim" data-close></div><div class="dialog keyedit" role="dialog" aria-label="${t('keyEdit')}">
    <header><small class="muted">${esc(k.desc)}${k.state ? ` · <code>state.${esc(k.state)}</code>` : ''}</small><h3>${t('keyEdit')}</h3></header>
    <div class="body">
      <div class="capture" id="kcapture" tabindex="0"><span class="muted small">${t('keyPress')}</span><div class="big">${keyLabel(key)}</div>
        <code class="muted small">${key ? esc(key) : '—'}</code></div>${KEYEDIT.error ? `<p class="kwarn">${esc(t('keyUnknown', {c: KEYEDIT.error}))}</p>` : ''}
      <details class="kmanual"><summary>${t('keyManual')}</summary><div class="kbuild">${mods}<select class="kname topsel">${opts}</select></div></details>
      ${warn.length ? `<ul class="kwarn">${warn.map(w => `<li>${esc(w)}</li>`).join('')}</ul>` : ''}
      <p class="muted small">${t('keyFile', {k: file || '—'})} · ${t('keyLayout')} <select class="klayout">${['auto', 'us', 'azerty', 'qwertz'].map(l => `<option value="${l}" ${(S.layout || 'auto') === l ? 'selected' : ''}>${t('lay.' + l)}</option>`).join('')}</select></p>
    </div>
    <footer><span><button class="btn ghost" data-knone>${t('keyNone')}</button> <button class="btn ghost" data-kfile>${t('keyBack')}</button></span>
      <span><button class="btn ghost" data-close>${t('cancel')}</button> <button class="btn" data-kok>${t('keyOk')}</button></span></footer></div>`;
  $('#overlay').hidden = false;
  const cap = $('#kcapture'); if (cap) cap.focus();
}
// The capture box: the physical key pressed, with its modifiers (Ctrl+W and the like stay with the browser:
// the manual choice is there for those)
document.addEventListener('keydown', e => {
  if (!KEYEDIT || $('#overlay').hidden || !e.target.closest || !e.target.closest('#kcapture')) return;
  e.preventDefault(); e.stopPropagation();
  if (/^(Control|Alt|Shift|Meta|OS|ContextMenu)/.test(e.code)) return;
  // Escape alone closes the window (it can still be picked by hand)
  if (e.code === 'Escape' && !e.ctrlKey && !e.altKey && !e.shiftKey) { closeOverlay(); return; }
  const name = CODE_KEY[e.code];
  if (!name) { KEYEDIT.error = e.code; renderKeyEdit(); return; }
  KEYEDIT.error = null;
  const mods = (e.ctrlKey ? '^' : '') + (e.altKey ? '!' : '') + (e.metaKey ? '@' : '') + (e.shiftKey ? '~' : '');
  KEYEDIT.key = mods + name; renderKeyEdit();
}, true);
document.addEventListener('keyup', e => { if (KEYEDIT && e.target.closest && e.target.closest('#kcapture')) e.preventDefault(); }, true);
function manualKey(){
  const mods = [...document.querySelectorAll('.kmod:checked')].map(x => x.value).join(''), name = ($('.kname') || {}).value;
  if (name) { KEYEDIT.key = mods + name; renderKeyEdit(); const det = $('.kmanual'); if (det) det.open = true; }
}
// The export the page expects (shared/utils/atelier/atelier_export.lua EXPORT_VERSION): an older one lacks data
const EXPORT_VERSION = 4;
// The key of each state with the shown subjob: the job's (as changed in the page), else Mote's own
function keyOfState(d){
  const map = {};
  for (const k of d.keys) { const key = keyOf(k); if (k.state && key && keyActive(k, d.sub) && !keyBeatenBy(d, k) && !map[k.state]) map[k.state] = key; }
  for (const [key, st] of MOTE_BINDS) if (st && !map[st] && !moteTakenBy(d, key)) map[st] = key;
  return map;
}
// A state whose keys all belong to other subjobs, or that the game hides now (Regen and SneakInviAOE off
// /SCH, RuneMode off /RUN, Xp off /RDM, JumpAuto off /DRG, CombatMode where its settings hide it)
function stateElsewhere(d, name){
  const binds = d.keys.filter(k => k.state === name && (keyOf(k) || fileKey(k)));
  return binds.length > 0 && !binds.some(k => keyActive(k, d.sub));
}
// What a mode does, for the job shown (state_help_fr.js; in English state_help_data.js, from the job's page of the docs).
// A job's own text first, then the one every job shares; '' when nobody wrote it
function stateHelp(name){
  const en = S.lang === 'en', own = (en ? STATE_HELP_EN : STATE_HELP_FR)[S.job] || {};
  return own[name] || (en && (STATE_HELP_MORE_EN[S.job] || {})[name]) || (en ? STATE_HELP_COMMON_EN : STATE_HELP_FR['*'])[name] || '';
}
// What a key that is not a mode does, in French (the keys every job has: COMMON_KEYBINDS.lua), and Mote's own keys
const KEY_DESC_FR = {'Alts: follow me (toggle)': 'Tes autres persos te suivent (marche / arrêt)', 'Alts: automation on/off': 'Automatisation de tes autres persos : marche / arrêt',
  'Alts: mirror': 'Tes autres persos t’imitent', 'Sneak (you + alts)': 'Sneak sur toi et tes autres persos', 'Invisible (you + alts)': 'Invisible sur toi et tes autres persos'};
const MOTE_DESC_FR = {'DefenseMode Physical': 'Mode défense physique (pose sets.defense.PDT)', 'DefenseMode Magical': 'Mode défense magique (pose sets.defense.MDT)',
  'update (gs c update user)': 'Remettre ton équipement et afficher tes modes', 'reset DefenseMode': 'Enlever le mode défense',
  'toggle SelectNPCTargets': 'Choisir le monstre avant un sort offensif : marche / arrêt', 'cycle PCTargetMode': 'Changer la façon de viser un joueur'};
const keyDescText = desc => S.lang !== 'en' && KEY_DESC_FR[desc] || desc;
