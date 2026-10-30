// GearSwap Atelier · hud_preview.js: the live preview of the HUD in the Settings' Display (SPEC
// notes/docs-perso/hud-apercu-2026-10-30). The HUD is drawn by GearSwap's own code (its Lua files, embedded by
// scripts/atelier/gen_hud_sources.py in hud_sources.js, run by scripts/atelier/hud_harness.lua) in Lua 5.1 compiled to
// WebAssembly (atelier/lua/lua51.js, the one the Reload button uses), fed with the export's rows and mode values and
// with the character's settings files as Save would write them (the changes waiting included). The text it returns,
// with its colour codes, is shown in a fixed-width font on the HUD's own background.
// hudPreview(d): {html, meta, error} when drawn for the settings as they are now, else null (being drawn: the page is
// drawn again when it is ready).
// (loaded after modules.js and hud_sources.js: see atelier/src/legacy/files.ts)

const HUD = {M: null, booting: null, out: null, busy: false, written: new Map(), sources: false};

// Lua in the page: the WebAssembly module of the Reload button, loaded once
async function hudLua(){
  if (HUD.M) return HUD.M;
  if (!HUD.booting) HUD.booting = (async () => {
    await new Promise(done => window.ATELIER_LUA ? done() : loadScripts(['atelier/lua/lua51.js?v=' + Date.now()], done));
    if (!window.ATELIER_LUA) throw new Error('lua51.js');
    const glue = new Function(ATELIER_LUA.glue + '\nreturn glue;')(), raw = atob(ATELIER_LUA.wasm), bin = new Uint8Array(raw.length);
    for (let i = 0; i < raw.length; i++) bin[i] = raw.charCodeAt(i);
    HUD.M = await glue({wasmBinary: bin, print: () => {}, printErr: () => {}});
    return HUD.M;
  })();
  return HUD.booting;
}
function hudPut(M, path, text){
  if (HUD.written.get(path) === text) return;
  let p = '';
  for (const part of path.split('/').slice(0, -1).filter(Boolean)) { p += '/' + part; try { M.FS.mkdir(p); } catch (e) {} }
  M.FS.writeFile(path, text); HUD.written.set(path, text);
}
const hudLuaStr = s => '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n') + '"';
const hudLuaVal = v => typeof v === 'number' || typeof v === 'boolean' ? String(v) : hudLuaStr(v);

// What the HUD is drawn from: the job's rows bound with this subjob (their key as the page shows it, changed or not),
// the modes and their start values, the character's settings files with the changes waiting
function hudInput(d){
  const keys = (d.keys || []).filter(k => keyActive(k, d.sub)).map(k => {
    const row = Object.entries(k).filter(([, v]) => v !== null && typeof v !== 'object').map(([n, v]) => n + '=' + hudLuaVal(n === 'key' ? (keyOf(k) || '') : v));
    if (!('key' in k)) row.push('key=' + hudLuaStr(keyOf(k) || ''));
    return '{' + row.join(',') + '}';
  });
  const modes = (d.modes || []).map(m => '[' + hudLuaStr(m.name) + ']={current=' + hudLuaStr(modeStart(d, m)) + ',values={' + (m.values || []).map(hudLuaStr).join(',') + '}}');
  const files = modAllFiles(d).map(f => [f.file, modNewText(f, modEdits(f.file))]);
  return {lua: `HUD_IN = {char=${hudLuaStr(S.char)}, job=${hudLuaStr(d.job || S.job)}, sub=${hudLuaStr(d.sub || '')}, keys={${keys.join(',')}}, modes={${modes.join(',')}}}`, files};
}

// The HUD's text with its colour codes (\cs(r,g,b) ... \cr) as HTML, a line a block: a section's title line knows its
// section, a row's line its state (draggable), and each piece the part of the HUD it is (a click opens its colour)
const HUD_BUCKET = {spell: 'spells', enhancing: 'enhancing', ja: 'abilities', weapon: 'weapons', mode: 'modes'};
function hudHtml(text, out){
  const secs = (out && out.sections) || [], rows = (out && out.rows) || [];
  let first = true;
  return String(text).split('\n').map(line => {
    const pieces = [];
    let col = null;
    for (const part of line.split(/(\\cs\(\d+,\d+,\d+\)|\\cr)/)) {
      const m = /^\\cs\((\d+),(\d+),(\d+)\)$/.exec(part);
      if (m) { col = `rgb(${m[1]},${m[2]},${m[3]})`; continue; }
      if (part === '\\cr') { col = null; continue; }
      if (part) pieces.push([part, col]);
    }
    const plain = pieces.map(p => p[0]).join(''), bare = plain.trim();
    const sec = bare && secs.find(s => s.title === bare), row = !sec && bare ? rows.find(r => r.desc && plain.includes(' ' + r.desc + ' ')) : null;
    // the part of each piece: by what the line is, then by its place in the line
    const kind = !bare ? '' : sec ? 'section_title' : row ? 'row' : /^=+$/.test(bare) ? 'separator' : /= (Ctrl|Alt|Windows|Shift)/.test(bare) ? 'legend'
      : bare === '//gs c ui' ? 'footer' : /^Key\s+Function\s+Current$/.test(bare) ? 'columns' : first ? 'title' : '';
    if (bare) first = false;
    const words = pieces.filter(p => p[0].trim());
    const html = pieces.map(([p, c]) => {
      const i = words.findIndex(w => w[0] === p);
      const part = kind === 'row' ? (i === 0 ? 'key' : i === words.length - 1 ? 'value' : 'description')
        : kind === 'columns' ? ['column_key', 'column_function', 'column_current'][Math.max(0, i)] || 'column_current' : kind;
      return `<span style="color:${c || '#fff'}"${part && p.trim() ? ` data-hudpart="${part}"` : ''}>${esc(p)}</span>`;
    }).join('');
    const attrs = sec ? ` data-hudsec="${esc(sec.bucket)}" draggable="true"` : row ? ` data-hudrow="${esc(row.state)}" draggable="true"` : '';
    return `<div class="hl${sec ? ' hsec' : row ? ' hrow' : ''}"${attrs}>${html || ' '}</div>`;
  }).join('');
}

// Lua's answer as JSON (a small encoder: strings, numbers, booleans, tables)
const HUD_JSON = `local function J(v) local t = type(v)
  if t == 'string' then return (string.format('%q', v):gsub('\\\\\\n', '\\\\n')) elseif t == 'number' or t == 'boolean' then return tostring(v)
  elseif t == 'table' then local arr = #v > 0 local o = {}
    if arr then for i = 1, #v do o[i] = J(v[i]) end return '[' .. table.concat(o, ',') .. ']' end
    for k, x in pairs(v) do o[#o + 1] = string.format('%q', tostring(k)) .. ':' .. J(x) end return '{' .. table.concat(o, ',') .. '}'
  end return 'null' end
local f = io.open('/w/out.json', 'w') f:write(J(HUD_OUT)) f:close()`;

async function hudRender(d, key){
  const M = await hudLua();
  if (!HUD.sources) { for (const [p, text] of Object.entries(HUD_SOURCES)) hudPut(M, '/w/data/' + p, text); HUD.sources = true; }
  const inp = hudInput(d);
  for (const [file, text] of inp.files) hudPut(M, '/w/data/' + S.char + '/' + file, text);
  try { M.FS.unlink('/w/out.json'); } catch (e) {}
  const loadstring = M.cwrap('luaL_loadstring', 'number', ['number', 'string']), tolstring = M.cwrap('lua_tolstring', 'string', ['number', 'number', 'number']);
  const L = M._luaL_newstate(); M._luaL_openlibs(L);
  const code = `HUD_ROOT = '/w/'\n${inp.lua}\ndofile('/w/data/scripts/atelier/hud_harness.lua')\n${HUD_JSON}`;
  let error = null;
  if (loadstring(L, code)) error = tolstring(L, -1, 0); else if (M._lua_pcall(L, 0, 0, 0)) error = String(tolstring(L, -1, 0));
  M._lua_close(L);
  let out = null;
  if (!error) { try { out = JSON.parse(M.FS.readFile('/w/out.json', {encoding: 'utf8'})); } catch (e) { error = 'no answer'; } }
  return {key, error, html: out ? hudHtml(out.text, out) : '', meta: out ? out.meta : null, text: out ? out.text : '', sections: out ? out.sections : [], rows: out ? out.rows : []};
}

/* ---- the HUD's colours: UI_CONFIG.lua colors (its parts: ui_style.lua DEFAULT_COLORS when not set) and
   UI_COLOR_CONFIG.lua special / modes (the values ON / OFF, PDT / MDT / Normal) ---- */
const HUD_PARTS = [['title', [255, 255, 255]], ['section_title', [120, 220, 255]], ['description', [180, 180, 180]], ['key', null],
  ['value', null], ['legend', [255, 215, 0]], ['separator', [80, 160, 255]], ['footer', [128, 128, 128]],
  ['column_key', [100, 180, 255]], ['column_function', [120, 200, 255]], ['column_current', [140, 220, 255]]];
const HUD_VALUES = [['special', 'true'], ['special', 'false'], ['modes', 'PDT'], ['modes', 'MDT'], ['modes', 'Normal']];
const hudFile = (d, re) => modAllFiles(d).find(f => re.test(f.file)) || null;
// UI_CONFIG.lua's colors table as the page shows it (the whole table waiting, else the file's)
function hudColors(d){
  const f = hudFile(d, /\/UI_CONFIG\.lua$/); if (!f) return {};
  const ed = modEdits(f.file).colors; if (ed) return Object.assign({}, ed.v);
  const x = modParsed(f).byPath.colors, out = {};
  if (x && x.kind === 'map') for (const c of x.fields) if (Array.isArray(c.value)) out[c.key] = c.value.slice(0, 3);
  return out;
}
function hudStageColors(d, cols){
  const f = hudFile(d, /\/UI_CONFIG\.lua$/), x = f && modParsed(f).byPath.colors; if (!x) return;
  const was = {}; if (x.kind === 'map') for (const c of x.fields) if (Array.isArray(c.value)) was[c.key] = c.value.slice(0, 3);
  const ed = modEdits(f.file), nl = f.text.includes('\r\n') ? '\r\n' : '\n', keys = Object.keys(cols);
  const show = c => Object.keys(c).map(k => k + ' ' + c[k].join(',')).join(' · ') || '—';
  if (JSON.stringify(cols) === JSON.stringify(was)) delete ed.colors;
  else ed.colors = {v: cols, src: keys.length ? '{' + nl + keys.map(k => `    ${k} = {${cols[k].join(', ')}},`).join(nl) + nl + '}' : '{}', before: show(was), after: show(cols), table: true};
  S.toast = ''; render();
}
const hudHex = rgb => '#' + rgb.map(n => Math.max(0, Math.min(255, +n || 0)).toString(16).padStart(2, '0')).join('');
const hudRgb = hex => [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16));
/** The colours of the HUD for the Display's card: {parts: [{id, rgb, auto}], values: [{file, path, rgb}]} */
function hudColorModel(d){
  const cols = hudColors(d), cf = hudFile(d, /\/UI_COLOR_CONFIG\.lua$/);
  return {parts: HUD_PARTS.map(([id, std]) => ({id, rgb: cols[id] || std, auto: !cols[id] && !std, set: !!cols[id]})),
    values: cf ? HUD_VALUES.map(([t, k]) => { const v = modValue(cf.file, t + '.' + k); return Array.isArray(v) ? {file: cf.file, path: t + '.' + k, id: k, rgb: v.slice(0, 3)} : null; }).filter(Boolean) : []};
}
let HUD_PICK_T = null;
for (const ev of ['input', 'change']) document.addEventListener(ev, e => {
  const i = e.target.closest('input[data-hudcolor]'); if (!i) return;
  // while the picker is dragged: once the hand rests (a redraw a pixel would lose the picker)
  clearTimeout(HUD_PICK_T); HUD_PICK_T = setTimeout(() => hudApply(i.dataset.hudcolor, i.value), ev === 'change' ? 0 : 120);
});
document.addEventListener('click', e => {
  const b = e.target.closest('[data-hudcolorreset]'); if (!b) return;
  const cols = hudColors(data()); delete cols[b.dataset.hudcolorreset]; hudStageColors(data(), cols);
});

/* ---- the preview's hands: a click on a part opens its colour, a section or a row dragged changes the order ---- */
// a click on a part of the preview: a small colour window right by it (the page does not move; the browser's own
// picker opens from there, under the player's click)
const HUD_PRESETS = ['#ffffff', '#b4b4b4', '#808080', '#ffd700', '#ffcc33', '#ff9900', '#ff6464', '#96ff96', '#78dcff', '#64b4ff', '#c896ff', '#ff96c8'];
function hudPop(part, txt, x, y){
  document.querySelector('.hudpop')?.remove();
  const d = data(), m = hudColorModel(d), on = txt === 'on' || txt === 'off';
  const v = on ? m.values.find(z => z.id === (txt === 'on' ? 'true' : 'false')) : null, pt = on ? null : m.parts.find(z => z.id === part);
  if (!v && !pt) return;
  const attr = v ? `value|${v.file}|${v.path}` : `part|${part}`, hex = hudHex(v ? v.rgb : pt.rgb || [255, 255, 255]);
  const label = v ? t('hudVal_' + v.id) : t('hudCol_' + part);
  const el = document.createElement('div'); el.className = 'hudpop';
  el.innerHTML = `<header><b>${esc(label)}</b><button type="button" data-hudpopclose aria-label="×">×</button></header>
    <label class="hpcur"><input type="color" value="${hex}" data-hudcolor="${esc(attr)}"><span>${esc(t('hudPick'))}</span></label>
    <div class="hppre">${HUD_PRESETS.map(c => `<button type="button" style="background:${c}" data-hudpreset="${c}" data-hudfor="${esc(attr)}" aria-label="${c}"></button>`).join('')}</div>
    ${pt && pt.set ? `<button type="button" class="hpreset" data-hudcolorreset="${esc(part)}">↺ ${esc(t('hudColReset'))}</button>` : ''}`;
  document.body.appendChild(el);
  const w = el.offsetWidth, h = el.offsetHeight;
  el.style.left = Math.max(8, Math.min(innerWidth - w - 8, x + 12)) + 'px'; el.style.top = Math.max(8, Math.min(innerHeight - h - 8, y + 12)) + 'px';
}
function hudApply(attr, hex){
  const d = data(), [kind, a, b] = attr.split('|'), rgb = hudRgb(hex);
  if (kind === 'part') { const cols = hudColors(d); cols[a] = rgb; hudStageColors(d, cols); } else modStage(a, b, rgb);
}
document.addEventListener('click', e => {
  const p = e.target.closest('.hudtext [data-hudpart]');
  if (p) { const txt = p.textContent.replace(/^[^A-Za-z0-9]+/, '').trim().toLowerCase();
    hudPop(p.dataset.hudpart, p.dataset.hudpart === 'value' ? txt : '', e.clientX, e.clientY); return; }
  const pre = e.target.closest('[data-hudpreset]');
  if (pre) { hudApply(pre.dataset.hudfor, pre.dataset.hudpreset); const i = pre.closest('.hudpop').querySelector('input[type=color]'); if (i) i.value = pre.dataset.hudpreset; return; }
  if (e.target.closest('[data-hudpopclose]') || (!e.target.closest('.hudpop') && !e.target.closest('input[type=color]'))) document.querySelector('.hudpop')?.remove();
});
document.addEventListener('keydown', e => { if (e.key === 'Escape') document.querySelector('.hudpop')?.remove(); });
document.addEventListener('click', e => { const b = e.target.closest('[data-hudresetall]'); if (!b) return;
  for (const k of ['section_order', 'row_order']) if (modField(b.dataset.hudresetall, k)) modStage(b.dataset.hudresetall, k, []); });
let HUD_PDRAG = null;
document.addEventListener('dragstart', e => { const l = e.target.closest && e.target.closest('.hudtext [data-hudsec], .hudtext [data-hudrow]'); if (!l) return;
  HUD_PDRAG = l.dataset.hudsec ? {sec: l.dataset.hudsec} : {row: l.dataset.hudrow}; e.dataTransfer.effectAllowed = 'move';
  try { e.dataTransfer.setData('text/plain', 'hud'); } catch (x) {} l.classList.add('dragging'); });
document.addEventListener('dragend', () => { HUD_PDRAG = null; document.querySelectorAll('.hudtext .dragging, .hudtext .over').forEach(x => x.classList.remove('dragging', 'over')); });
document.addEventListener('dragover', e => { if (!HUD_PDRAG) return; const l = e.target.closest && e.target.closest(HUD_PDRAG.sec ? '.hudtext [data-hudsec]' : '.hudtext [data-hudrow]'); if (!l) return;
  e.preventDefault(); document.querySelectorAll('.hudtext .over').forEach(x => x.classList.remove('over')); l.classList.add('over'); });
document.addEventListener('drop', e => {
  if (!HUD_PDRAG) return; const drag = HUD_PDRAG; HUD_PDRAG = null;
  const d = data(), f = hudFile(d, /\/[A-Z]{3}_HUD\.lua$/); if (!f) return;
  const l = e.target.closest && e.target.closest(drag.sec ? '.hudtext [data-hudsec]' : '.hudtext [data-hudrow]'); if (!l) return;
  e.preventDefault();
  const move = (list, from, to) => { const out = list.filter(x => x !== from), at = out.indexOf(to); out.splice(at < 0 ? out.length : at, 0, from); return out; };
  if (drag.sec) {
    const names = ((HUD.out && HUD.out.sections) || []).map(s => HUD_BUCKET[s.bucket] || s.bucket);
    const from = HUD_BUCKET[drag.sec] || drag.sec, to = HUD_BUCKET[l.dataset.hudsec] || l.dataset.hudsec;
    if (from !== to) hudStage(f.file, 'section_order', move(names, from, to));
  } else {
    const order = hudOrder(d, f.file, 'row_order').order, from = drag.row, to = l.dataset.hudrow;
    if (from !== to && order.includes(from)) hudStage(f.file, 'row_order', move(order, from, to));
  }
});

/** The preview for the settings as they are now, or null while it is drawn (the page is drawn again after) */
function hudPreview(d){
  if (typeof HUD_SOURCES === 'undefined') return {key: '', error: 'hud_sources.js', html: '', meta: null};
  // DATA_GEN (core.js) moves on with every export read: "Reread" draws it again even with no change waiting
  const key = [DATA_GEN, S.char, d.job, d.sub, JSON.stringify((S._modEdits || {})[S.char] || {}), JSON.stringify(modAdds()), JSON.stringify(S.modeOv || {}), JSON.stringify(S.keyOv || {})].join('|');
  if (HUD.out && HUD.out.key === key) return HUD.out;
  if (!HUD.busy) {
    HUD.busy = true;
    hudRender(d, key).then(r => { HUD.out = r; }).catch(e => { HUD.out = {key, error: String(e && e.message || e), html: '', meta: null}; })
      .finally(() => { HUD.busy = false; render(); });
  }
  return HUD.out;   // the last one, kept while the new one is drawn
}
