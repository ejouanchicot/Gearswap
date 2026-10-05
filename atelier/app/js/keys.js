// GearSwap Atelier · keys.js: key names, keys changed in the page, the key editor, the Keys and Modes tabs
// (cut from atelier.html, loaded by it in order: see the list there)
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
  if (!k) return `<span class="kbd none">${t('noKey')}</span>`;
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
const EXPORT_VERSION = 3;
const KEY_COLORS = {job: 'g-def', custom: 'g-attr', combat: 'g-off', treasure: 'g-res', common: 'g-other'};
function renderKeys(d){
  const groups = {};
  // a row without a key (HUD only) is shown when the page changed it; the keys of other
  // subjobs only on demand (PLD's Phalanx SIRD: ^numpad2 but on /SCH, ^numpad3 on /SCH)
  let hidden = 0;
  d.keys.forEach((k, i) => { if (!keyOf(k) && !fileKey(k) && !hasOverride(k)) return;
    if (!keyActive(k, d.sub) && !S.keysAll) { hidden++; return; }
    (groups[k.src] = groups[k.src] || []).push([k, i]); });
  const row = ([k, i]) => { const key = keyOf(k), file = fileKey(k), changed = k.id && key !== file;
    const clash = keyClash(d, k, key).length, beaten = keyBeatenBy(d, k), cond = keyCondition(k);
    const note = k.visible_now === false ? t('keyHiddenNow') : beaten ? t('keyYieldsTo', {d: esc(beaten.desc)}) : '';
    return `<tr class="${keyActive(k, d.sub) && !beaten ? '' : 'other-sub'} ${changed ? 'changed' : ''}"><td class="kcol">${keyLabel(key)}${clash ? `<span class="kclash" title="${esc(t('keyClashShort'))}">!</span>` : ''}</td>` +
      `<td>${esc(k.desc)}${changed ? `<span class="kwas">${t('keyWas')} ${keyLabel(file)}</span>` : ''}${note || cond ? `<span class="kwas">${[note, esc(cond)].filter(Boolean).join(' · ')}</span>` : ''}</td>` +
      `<td class="sub">${k.subjob?'/'+esc(k.subjob):''}</td>` +
      `<td class="r">${k.id ? `<button class="kedit" data-keyedit="${i}" title="${t('keyEdit')}">✎</button>` : ''}</td></tr>`; };
  const moteRows = MOTE_BINDS.map(([key, , what]) => { const by = moteTakenBy(d, key);
    return `<tr class="${by ? 'other-sub' : ''}"><td class="kcol">${keyLabel(key)}</td><td>${esc(what)}${by ? `<span class="kwas">${t('keyTakenBy', {d: esc(by.desc)})}</span>` : ''}</td><td class="sub"></td><td class="r"></td></tr>`; }).join('');
  const boxes = ['job','custom','combat','treasure','common'].filter(g => groups[g]).map(g =>
    box(KEY_COLORS[g], t('keyGroups.'+g), `<table class="tbl in"><tbody>${groups[g].map(row).join('')}</tbody></table>`,
      `<span class="meta">${groups[g].length} · ${t('source.'+g).replace('{J}', S.job)}.lua</span>`)).join('') +
    box('g-caps', t('keyGroups.mote'), `<table class="tbl in"><tbody>${moteRows}</tbody></table>`, `<span class="meta">${MOTE_BINDS.length} · libs/Mote-Globals.lua</span>`) +
    // the keys //gs c tb bound for this game session (saved/temp_binds.lua)
    (Object.keys(d.temp_binds || {}).length ? box('g-res', t('keyGroups.temp'), `<table class="tbl in"><tbody>${Object.entries(d.temp_binds).sort()
      .map(([key, cmd]) => `<tr><td class="kcol">${keyLabel(key)}</td><td><code>${esc(cmd)}</code></td><td class="sub"></td><td class="r"></td></tr>`).join('')}</tbody></table>`,
      `<span class="meta">${Object.keys(d.temp_binds).length} · saved/temp_binds.lua</span>`) : '');
  const changes = Object.values(keyOverrides()).reduce((n, m) => n + Object.keys(m).length, 0);
  const noid = !d.keys.some(k => k.id);
  const others = hidden || S.keysAll ? `<button class="linkbtn" data-keysall>${S.keysAll ? t('keysHideOther', {s: d.sub}) : t('keysShowOther', {n: hidden})}</button>` : '';
  const bar = `<div class="keybar ${S.keyDirty[S.char] ? 'dirty' : ''}"><span>${noid ? t('keysNoId') : S.keyDirty[S.char] ? t('keysDirty') : changes ? t('keysSaved', {n: changes}) : t('keysHint')}</span>${others}` +
    `${S.keyDirty[S.char] ? `<span class="sp"></span><button class="btn ghost" data-keysundo>${t('keysUndo')}</button><button class="btn" data-keyssave>${t('keysSave')}</button>` : ''}</div>`;
  const toast = S.toast ? `<p class="toast">${esc(S.toast)}</p>` : '';
  return `${bar}${toast}<div class="boxgrid cols">${boxes}</div>`;
}
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
function modeTable(list, keyOf){
  return `<table class="tbl in"><tbody>` +
    list.map(m => `<tr><td><b>${esc(m.desc || m.name)}</b><span class="state">state.${esc(m.name)}</span></td>
      <td><span class="values">${m.values.map(v => `<span class="${v===m.current?'def':''}">${esc(v)}</span>`).join('')}</span></td><td class="r">${keyLabel(keyOf[m.name])}</td></tr>`).join('') + `</tbody></table>`;
}
function renderModes(d){
  const keyOf = keyOfState(d);
  const all = d.modes.filter(m => !modeHidden(m) && !/^[A-Z]{3}Song\d$/.test(m.name));
  const away = all.filter(m => stateElsewhere(d, m.name)), shown = all.filter(m => !away.includes(m));
  const keyed = shown.filter(m => keyOf[m.name]), other = shown.filter(m => !keyOf[m.name]);
  return `<div class="boxgrid one">${box('g-attr', t('modesKeyed'), modeTable(keyed, keyOf), `<span class="meta">${keyed.length}</span>`)}` +
    (other.length ? box('g-other', t('modesOther'), modeTable(other, keyOf), `<span class="meta">${other.length}</span>`) : '') +
    (away.length ? box('g-caps', t('modesElsewhere', {s: esc(d.sub)}), modeTable(away, {}), `<span class="meta">${away.length}</span>`) : '') +
    `</div><p class="note-foot">${t('atLoad', {at: esc(d.at || '—')})}</p>`;
}
