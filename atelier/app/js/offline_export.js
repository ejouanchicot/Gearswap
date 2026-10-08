// GearSwap Atelier · offline_export.js: every job of a character exported from its files, inside the page
// (loaded by atelier/index.html after live.js; also by scripts/atelier/offline_export_test.js under Node)
//
// What scripts/atelier/atelier_all.py does with Python and lua5.1, done here with nothing to install: the job files
// are run by Lua 5.1 compiled to WebAssembly (atelier/lua/lua51.js), read from the Windower folder the player picked
// once. Same rules as the Python script, kept side by side with it:
//   - a job whose files did not change since its last export here is left as it is;
//   - a job that changed: its main subjob, then the subjobs that had a file of their own (the 20 others the first
//     time and with allSubs); a subjob showing the same as the main one keeps no file;
//   - what only the game knows (bags, measured stats) comes from the last in-game export; the bags are the
//     character's, so the newest in-game export of any job brings the others up to date.
// The item icons are not written here (they come from the game's DAT files: //gs c atelier, or the .bat).
//
// The core (OfflineExport.run) reads and writes through `env`, so the same code runs in the page (folder handles,
// a worker) and under Node (the test, against the Python script's output):
//   env.list(rel) -> [{name, dir}] | null      env.meta(rel) -> {size, mtime} | null
//   env.bytes(rel) -> Uint8Array               env.text(rel) -> string | null
//   env.write(rel, text)                       env.remove(rel)
//   env.lua(sources, tasks, onDone) -> [{char, job, sub, rel, text, error}]   (rel: under the data folder)
// Every `rel` is relative to the Windower folder, with '/'.
const OfflineExport = (() => {
  const DATA = 'addons/GearSwap/data';
  const JOBS = 'WAR MNK WHM BLM RDM THF PLD DRK BST BRD RNG SAM NIN DRG SMN BLU COR PUP DNC SCH GEO RUN'.split(' ');
  // Subjob used when the job was never exported (atelier_all.py USUAL_SUB)
  const USUAL_SUB = {BLM: 'RDM', BLU: 'WAR', BRD: 'WHM', BST: 'DNC', COR: 'NIN', DNC: 'WAR', DRG: 'SAM', DRK: 'SAM', GEO: 'RDM', MNK: 'WAR',
    NIN: 'WAR', PLD: 'WAR', PUP: 'WAR', RDM: 'NIN', RNG: 'WAR', RUN: 'BLU', SAM: 'WAR', SCH: 'RDM', SMN: 'WHM', THF: 'DNC', WAR: 'SAM', WHM: 'SCH'};
  // never part of what an export is made from: written by the game or by the Atelier itself
  const SKIP_DIRS = new Set(['saved', 'logs', 'backups', 'exports', '__pycache__']);
  // what the job code can read outside the data folder (Windower's resources and libraries, GearSwap's, PorterPacker's lists)
  const OUTSIDE = ['res', 'addons/libs', 'addons/GearSwap/libs', 'addons/GearSwap/libs-dev', 'addons/PorterPacker'];
  const DATA_SKIP = new Set(['.git', 'node_modules', 'docs', 'notes', 'icons', 'engine', 'backups', '__pycache__', '.claude', 'exports', 'logs']);

  /* ---- an export file: its header lines, then one JSON value ---- */
  const stable = v => Array.isArray(v) ? v.map(stable) : v && typeof v === 'object'
    ? Object.keys(v).sort().reduce((o, k) => { o[k] = stable(v[k]); return o; }, {}) : v;
  const same = (a, b) => JSON.stringify(stable(a === undefined ? null : a)) === JSON.stringify(stable(b === undefined ? null : b));
  function parseExport(text){
    if (!text) return null;
    try { return JSON.parse(text.slice(text.lastIndexOf('] = ') + 4).trim().replace(/;$/, '')); } catch (e) { return null; }
  }
  function formatExport(data){
    const c = JSON.stringify(data.player), j = JSON.stringify(data.job), s = JSON.stringify(data.sub);
    return `window.ATELIER_SUBS = window.ATELIER_SUBS || {};\nATELIER_SUBS[${c}] = ATELIER_SUBS[${c}] || {};\n` +
      `ATELIER_SUBS[${c}][${j}] = ATELIER_SUBS[${c}][${j}] || {};\nATELIER_SUBS[${c}][${j}][${s}] = ${JSON.stringify(stable(data))};\n`;
  }
  // Two exports of a job show the same thing: sets, keys and modes (the macro book and lockstyle of each subjob are in both)
  const sameContent = (a, b) => ['sets', 'keys', 'modes'].every(k => same(a[k], b[k]));

  /* ---- where things are ---- */
  const charDir = char => `${DATA}/${char}`;
  async function exportFolder(env, char){
    // a tidied folder (shared/utils/core/char_paths.lua), else saved/atelier/
    for (const d of ['_common', 'common']) if (await env.list(`${charDir(char)}/${d}`)) return `${charDir(char)}/atelier/exports`;
    return `${charDir(char)}/saved/atelier`;
  }
  async function jobsOf(env, char){
    const pat = new RegExp('^' + char + '_([A-Z]{3})\\.lua$');
    return ((await env.list(charDir(char))) || []).map(e => !e.dir && (e.name.match(pat) || [])[1]).filter(Boolean).sort();
  }
  // Exports of this job already on the disk: one per subjob, and the <JOB>.js of before 2026-10-01
  async function previousExports(env, folder, job){
    const out = [], pat = new RegExp('^' + job + '(_[A-Z]+)?\\.js$');
    for (const e of ((await env.list(folder)) || []).filter(e => !e.dir && pat.test(e.name)).sort((a, b) => a.name < b.name ? -1 : 1)) {
      const data = parseExport(await env.text(`${folder}/${e.name}`));
      if (data) out.push([e.name, data]);
    }
    return out;
  }
  const subOfName = (job, name) => name.slice(job.length + 1, -3);
  // The subjob of the last in-game export, else the one an offline run started with (main_sub), else a usual one
  function firstSub(job, previous){
    const key = d => [d.offline ? 0 : 1, d.main_sub ? 1 : 0, d.at || ''];
    const cmp = (a, b) => { const x = key(a[1]), y = key(b[1]); for (let i = 0; i < 3; i++) if (x[i] !== y[i]) return x[i] < y[i] ? 1 : -1; return 0; };
    const best = (previous.slice().sort(cmp)[0] || [])[1] || {};
    return best.sub && (!best.offline || best.main_sub) ? best.sub : USUAL_SUB[job] || 'WAR';
  }

  /* ---- the files a load reads, and what an export is made from ---- */
  // Every .lua the job code can ask for: {metas: Map(rel -> {size, mtime}), dirs: {rel: [names]}}
  async function sources(env, char){
    const metas = new Map(), dirs = {};
    const walk = async (rel, keepDir) => {
      const entries = await env.list(rel);
      if (!entries) return;
      dirs[rel] = entries.map(e => e.name);
      for (const e of entries) {
        const r = rel + '/' + e.name;
        if (e.dir) { if (keepDir(r, e.name)) await walk(r, keepDir); }
        else if (/\.lua$/i.test(e.name)) metas.set(r, await env.meta(r));
      }
    };
    for (const d of OUTSIDE) await walk(d, () => true);
    // the data folder: everything but the other characters' folders (a folder holding <Name>_<JOB>.lua)
    const top = (await env.list(DATA)) || [], others = new Set();
    for (const e of top) if (e.dir && e.name !== char && /^[A-Z]/.test(e.name) && (await jobsOf(env, e.name)).length) others.add(e.name);
    // nor the page's own folder (data/atelier: no Lua the job reads; <Char>/atelier/overrides and shared/utils/atelier stay)
    await walk(DATA, (r, name) => !DATA_SKIP.has(name) && !(r === `${DATA}/${name}` && (others.has(name) || name === 'atelier')));
    return {metas, dirs};
  }
  // A short value of a long text (53 bits, cyrb53): enough to tell two states of the files apart
  function hash(text){
    let a = 0xdeadbeef, b = 0x41c6ce57;
    for (let i = 0; i < text.length; i++) { const c = text.charCodeAt(i); a = Math.imul(a ^ c, 2654435761); b = Math.imul(b ^ c, 1597334677); }
    a = Math.imul(a ^ (a >>> 16), 2246822507) ^ Math.imul(b ^ (b >>> 13), 3266489909);
    b = Math.imul(b ^ (b >>> 16), 2246822507) ^ Math.imul(a ^ (a >>> 13), 3266489909);
    return 'js:' + (4294967296 * (2097151 & b) + (a >>> 0)).toString(16);
  }
  // What a job's export is made from, as one value: the character's folder without the other jobs', shared/, the
  // export scripts, the Porter slips and the newest in-game export of the job (atelier_all.py fingerprint)
  function fingerprint(src, char, job, slips, previous, main){
    const base = charDir(char) + '/', other = new Set(JOBS.filter(j => j !== job).map(j => j.toLowerCase()));
    const otherEntry = new RegExp('^' + char + '_(?!' + job + '\\.)[A-Z]{3}\\.lua$');
    const marks = [];
    for (const [rel, m] of src.metas) {
      let mine = false;
      if (rel.startsWith(base)) { const parts = rel.slice(base.length).split('/');
        mine = !parts.slice(0, -1).some(p => SKIP_DIRS.has(p) || other.has(p)) && !(parts.length === 1 && otherEntry.test(parts[0])); }
      else mine = rel.startsWith(`${DATA}/shared/`) || rel.startsWith(`${DATA}/scripts/atelier/`);
      if (mine) marks.push(rel + '|' + m.size + '|' + m.mtime);
    }
    // the main subjob's own in-game export aside: this run writes over it (counted, the job was redone once more)
    const inGame = previous.reduce((x, [, d]) => !d.offline && d.sub !== main && (d.at || '') > x ? d.at : x, '');
    return hash(marks.sort().join('\n') + '\n' + hash(slips || '') + '\n' + inGame);
  }

  /* ---- the bags: the character's, carried from the last in-game export ---- */
  // Item id and name (lower case) -> job mask, name -> id (equippable items first), from res/items.lua (read once a run)
  async function itemTables(env){
    const text = (await env.text('res/items.lua')) || '', ids = {}, masks = {};
    const pat = /\[(\d+)\] = \{id=\d+,en="((?:[^"\\]|\\.)*)",ja="(?:[^"\\]|\\.)*",enl="((?:[^"\\]|\\.)*)"([^\n]*)/g;
    for (let m; (m = pat.exec(text));) {
      for (const name of [m[2].toLowerCase(), m[3].toLowerCase()]) if (!(name in ids) || m[4].includes('slots=')) ids[name] = +m[1];
      const jobs = m[4].match(/[,{]jobs=(\d+)/);
      if (jobs) { masks[m[1]] = +jobs[1]; if (!(m[2].toLowerCase() in masks)) masks[m[2].toLowerCase()] = +jobs[1]; }
    }
    return {ids, masks};
  }
  // Whether a job can wear an item (id, or name): true, false, or null when the item is unknown
  function wears(tables, job, key){
    const mask = tables.masks[typeof key === 'string' ? key.toLowerCase() : key];
    return mask == null ? null : Math.floor(mask / 2 ** (JOBS.indexOf(job) + 1)) % 2 === 1;
  }
  // One slot's list brought up to date from a newer one made on another job: what the newer job could wear and no
  // longer lists goes, what it lists and this job can wear comes
  function mergeLists(mine, newer, key, wearHere, wearThere, keep){
    const there = new Map(newer.map(x => [key(x), x]));
    const out = mine.filter(x => there.has(key(x)) || keep(x) || wearThere(x) !== true).map(x => there.has(key(x)) ? there.get(key(x)) : x);
    const have = new Set(out.map(key));
    return out.concat(newer.filter(x => !have.has(key(x)) && wearHere(x) === true));
  }
  const isSlip = c => !!(c.where && c.where.length) && c.where.every(w => w.startsWith('Slip '));
  const copyKey = c => JSON.stringify([c.name, c.augs || []]);
  function mergeBags(tables, mine, job, newer, newerJob){
    const ident = c => c.id || c.name || '', out = {items: {}, owned: {}};
    const slots = k => [...new Set(Object.keys(mine[k] || {}).concat(Object.keys(newer[k] || {})))].sort();
    for (const slot of slots('items')) {
      const names = mergeLists((mine.items || {})[slot] || [], (newer.items || {})[slot] || [], n => n, n => wears(tables, job, n), n => wears(tables, newerJob, n), () => false);
      if (names.length) out.items[slot] = names;
    }
    for (const slot of slots('owned')) {
      const copies = mergeLists((mine.owned || {})[slot] || [], (newer.owned || {})[slot] || [], copyKey, c => wears(tables, job, ident(c)), c => wears(tables, newerJob, ident(c)), isSlip);
      // stable, by name (the Python script's sorted())
      if (copies.length) out.owned[slot] = copies.map((c, i) => [c, i]).sort((a, b) => (a[0].name || '') < (b[0].name || '') ? -1 : (a[0].name || '') > (b[0].name || '') ? 1 : a[1] - b[1]).map(x => x[0]);
    }
    return out;
  }
  // When the game last read the bags an export lists: its own time, or bags_at for one made outside the game
  const bagsTime = d => d.offline ? d.bags_at || '' : d.at || '';
  // The bags' copies plus the Porter slips' pieces an export outside the game holds
  function withSlips(owned, data){
    const out = {};
    for (const [slot, copies] of Object.entries(owned)) out[slot] = copies.slice();
    for (const [slot, copies] of Object.entries(data.owned || {})) {
      const mine = out[slot] = out[slot] || [];
      for (const c of copies) if (isSlip(c) && !mine.some(m => copyKey(m) === copyKey(c))) mine.push(c);
    }
    return out;
  }
  // Mark the file as made outside the game and give it what only the game sees (atelier_all.py finish)
  function finish(data, sub, carry, names, main){
    data.offline = true;
    if (main) { data.main_sub = true; data.src = carry.src == null ? null : carry.src; }
    const filled = v => v && Object.keys(v).length;
    if (filled(carry.items) && !filled(data.items)) { data.items = carry.items; for (const list of Object.values(carry.items)) for (const n of list) names.add(n); }
    if (filled(carry.owned)) { data.owned = withSlips(carry.owned, data); data.bags_at = carry.bags_at == null ? null : carry.bags_at; }
    const measured = carry.chars || {};
    if (!filled(data.char) && Object.keys(measured).length)
      data.char = measured[sub] || Object.values(measured).sort((a, b) => (a.at || '') < (b.at || '') ? -1 : (a.at || '') > (b.at || '') ? 1 : 0).pop();
    return data;
  }

  /* ---- the run ---- */
  // opts: {allSubs, force, onProgress(step, n, total, what)}, step = read | start | jobs | subs | write; returns {exported, failed: [[job, sub, error]], unchanged, patched}
  async function run(env, char, opts = {}){
    const say = opts.onProgress || (() => {}), folder = await exportFolder(env, char);
    const jobs = await jobsOf(env, char);
    say('read');
    const src = await sources(env, char), tables = await itemTables(env);
    const slips = await env.text(`${charDir(char)}/saved/slip_items.lua`);
    const prev = {}, first = {}, carry = {}, own = {}, known = {}, files = {}, unchanged = new Set();
    for (const job of jobs) prev[job] = await previousExports(env, folder, job);
    // the export of any job whose bags the game read last
    let newest = null;
    for (const job of jobs) for (const [, d] of prev[job]) if (d.owned && Object.keys(d.owned).length && bagsTime(d) && (!newest || bagsTime(d) > bagsTime(newest[1]))) newest = [job, d];
    for (const job of jobs) {
      const previous = prev[job];
      first[job] = firstSub(job, previous);
      const fp = fingerprint(src, char, job, slips, previous, first[job]);
      const before = (previous.find(([, d]) => d.main_sub && d.sub === first[job]) || [])[1] || {};
      if (!opts.force && before.src === fp) unchanged.add(job);
      const mine = [...new Set(previous.map(([name]) => subOfName(job, name)))].filter(s => s && s !== first[job]).sort();
      // every other subjob when the main export is not one made here (never exported, or the game wrote over it: which
      // subjobs show the same as which, same_as, went with it)
      own[job] = opts.allSubs || !before.main_sub ? null : mine;
      known[job] = own[job] === null ? null : before.same_as || null;
      // an export made outside the game only carries the items it was given: an in-game one first
      const key = d => [d.offline ? 0 : 1, d.at || ''];
      const withItems = previous.map(p => p[1]).filter(d => d.items && Object.keys(d.items).length)
        .sort((a, b) => { const x = key(a), y = key(b); return x[0] !== y[0] ? x[0] - y[0] : x[1] < y[1] ? -1 : x[1] > y[1] ? 1 : 0; });
      const last = withItems[withItems.length - 1] || {}, chars = {};
      for (const [, d] of previous.slice().sort((a, b) => (a[1].at || '') < (b[1].at || '') ? -1 : (a[1].at || '') > (b[1].at || '') ? 1 : 0))
        if (d.char && Object.keys(d.char).length) chars[d.char.sub || d.sub] = d.char;
      let bags = {items: last.items || null, owned: last.owned || null, bags_at: bagsTime(last)};
      if (newest && newest[0] !== job && bags.bags_at < bagsTime(newest[1]))
        bags = Object.assign(mergeBags(tables, bags, job, newest[1], newest[0]), {bags_at: bagsTime(newest[1])});
      carry[job] = Object.assign(bags, {chars, src: fp});
      files[job] = previous.map(([name]) => subOfName(job, name)).filter(Boolean);
    }
    const names = new Set(), done = [], failed = [], patched = [];
    let families = null;
    const path = (job, sub) => `${folder}/${job}_${sub}.js`;
    const read = async (job, sub) => parseExport(await env.text(path(job, sub)));
    const write = (job, sub, data) => env.write(path(job, sub), formatExport(data));
    // the jobs left as they are still follow the bags
    for (const job of [...unchanged].sort()) for (const sub of files[job]) {
      const data = await read(job, sub), c = carry[job];
      if (!(data && data.offline && c.owned && Object.keys(c.owned).length)) continue;
      const owned = withSlips(c.owned, data);
      if (same(owned, data.owned) && same(c.items, data.items)) continue;
      data.owned = owned; data.items = c.items || data.items; data.bags_at = c.bags_at == null ? null : c.bags_at;
      for (const list of Object.values(data.items || {})) for (const n of list) names.add(n);
      await write(job, sub, data); patched.push([job, sub]);
    }
    const todo = jobs.filter(j => !unchanged.has(j));
    // the main subjob of each job that changed, then its other subjobs
    const lua = async (tasks, what) => { let n = 0;
      return env.lua(src, tasks.map(([job, sub]) => ({char, job, sub})), r => { families = r.families || families; say(what, ++n, tasks.length, r.job + '/' + r.sub); }); };
    if (todo.length) say('start');
    for (const r of todo.length ? await lua(todo.map(j => [j, first[j]]), 'jobs') : []) {
      const data = r.text && parseExport(r.text);
      if (!data) { failed.push([r.job, r.sub, r.error || 'no export']); continue; }
      await write(r.job, r.sub, finish(data, r.sub, carry[r.job], names, true)); done.push([r.job, r.sub]);
    }
    const more = [];
    for (const [job, sub] of done) for (const s of own[job] === null ? JOBS : own[job]) if (s !== job && s !== sub) more.push([job, s]);
    for (const r of more.length ? await lua(more, 'subs') : []) {
      const mine = r.text && parseExport(r.text), main = await read(r.job, first[r.job]);
      if (!mine) { failed.push([r.job, r.sub, r.error || 'no export']); continue; }
      // a subjob that shows the same as the main one keeps no file: the page shows the main one for it
      if (main && sameContent(main, mine)) { await env.remove(path(r.job, r.sub)); continue; }
      await write(r.job, r.sub, finish(mine, r.sub, carry[r.job], names, false)); done.push([r.job, r.sub]);
    }
    say('write');
    const isDone = (job, sub) => done.some(d => d[0] === job && d[1] === sub);
    for (const job of todo) {
      // subjobs kept because they differ from the main one may still be alike: one file per content, the others
      // removed and named in the main file's same_as (atelier_all.py group_twins)
      const groups = [], sameAs = {};
      for (const [name, data] of await previousExports(env, folder, job)) {
        const sub = subOfName(job, name);
        if (!sub || sub === first[job]) continue;
        const twin = groups.find(g => sameContent(g[1], data));
        if (!twin) { groups.push([sub, data]); continue; }
        if (data.offline) { await env.remove(path(job, sub)); sameAs[sub] = twin[0];
          const i = done.findIndex(d => d[0] === job && d[1] === sub); if (i >= 0) done.splice(i, 1); }
      }
      for (const [sub, keep] of Object.entries(known[job] || {}))
        if (!(sub in sameAs) && groups.some(g => g[0] === keep) && (await env.meta(path(job, sub))) === null) sameAs[sub] = keep;
      const main = await read(job, first[job]);
      if (main) { main.same_as = sameAs; await write(job, first[job], main); }
      // exports made outside the game that are now the same as the main one go; an in-game export always stays
      await env.remove(`${folder}/${job}.js`);
      for (const [name, data] of await previousExports(env, folder, job)) {
        const sub = subOfName(job, name);
        if (sub && data.offline && !isDone(job, sub)) await env.remove(`${folder}/${name}`);
      }
    }
    await addIcons(env, tables, done.concat(patched), names, read, write);
    await writeIndex(env, families);
    return {exported: done.length, failed, unchanged: unchanged.size, patched: patched.length};
  }
  // The icon id and the game's description of the bag items an export lists (the icon files themselves are the game's)
  async function addIcons(env, tables, list, names, read, write){
    if (!names.size) return;
    const found = {};
    for (const n of names) if (n.toLowerCase() in tables.ids) found[n] = tables.ids[n.toLowerCase()];
    const wanted = new Set(Object.values(found).map(String)), texts = {};
    const pat = /\[(\d+)\] = \{id=\d+,en="((?:[^"\\]|\\.)*)"/g, src = (await env.text('res/item_descriptions.lua')) || '';
    for (let m; (m = pat.exec(src));) if (wanted.has(m[1])) texts[m[1]] = m[2].split('\\n').join('\n').split('\\"').join('"').split('\\\\').join('\\');
    for (const [job, sub] of list) {
      const data = await read(job, sub);
      if (!(data && data.items && Object.keys(data.items).length)) continue;
      const icons = data.icons = data.icons && !Array.isArray(data.icons) ? data.icons : {}, descs = data.descs = data.descs && !Array.isArray(data.descs) ? data.descs : {};
      for (const slot of Object.values(data.items)) for (const n of slot) if (n in found) {
        if (!(n in icons)) icons[n] = found[n];
        if (String(found[n]) in texts && !(String(found[n]) in descs)) descs[String(found[n])] = texts[String(found[n])];
      }
      await write(job, sub, data);
    }
  }
  // data/atelier/index.js: every export of every character, the live link files, the spell families kept (they come
  // from the game: shared/utils/atelier/atelier_families.lua); `families`: a load's own, for an index that has none
  async function writeIndex(env, families){
    const entries = [], seen = new Set();
    for (const c of ((await env.list(DATA)) || []).filter(e => e.dir && !/^[_.]/.test(e.name)).map(e => e.name).sort())
      for (const sub of ['/atelier/exports/', '/saved/atelier/', '/atelier/'])
        for (const e of ((await env.list(DATA + '/' + c + sub.replace(/\/$/, ''))) || []).filter(e => !e.dir).map(e => e.name).sort()) {
          const m = e.match(/^([A-Z]{3})_?([A-Z]*)\.js$/);
          if (!m || seen.has(c + '|' + m[1] + '|' + m[2])) continue;
          seen.add(c + '|' + m[1] + '|' + m[2]);
          const entry = {char: c, file: c + sub + e, job: m[1]};
          if (m[2]) entry.sub = m[2];
          entries.push(entry);
        }
    const live = ((await env.list(DATA + '/atelier')) || []).filter(e => !e.dir && /^(live|link)_.+\.js$/.test(e.name)).map(e => 'atelier/' + e.name).sort();
    const old = (await env.text(DATA + '/atelier/index.js')) || '', fam = old.match(/^window\.ATELIER_FAMILIES = .*;$/m) || (families ? [families] : null);
    await env.write(DATA + '/atelier/index.js', `window.ATELIER_INDEX = ${JSON.stringify(entries)};\nwindow.ATELIER_LIVE_FILES = ${JSON.stringify(live)};\n${fam ? fam[0] + '\n' : ''}`);
  }
  /* ---- Lua 5.1 in WebAssembly: one job loaded as scripts/atelier/load_job.lua does ---- */
  // Self-contained (its text is also the worker's): luaRunnerFactory()(glueFactory, wasmBinary) ->
  //   {put(rel, bytes), dirs(map), run(char, job, sub) -> {char, job, sub, rel, text, error}}
  // Windows does not tell upper from lower case in a file name and the job code counts on it (include('Mote-Include')
  // finds mote-include.lua): every file is kept under its lower-case path and every path Lua opens is lowered.
  function luaRunnerFactory(){
    const DATA = 'addons/GearSwap/data';
    const LUA_PRELUDE = `
    local function norm(p) return (tostring(p):gsub('\\\\', '/'):lower()) end
    local io_open, _loadfile, _dofile = io.open, loadfile, dofile
    io.open = function(p, mode) return io_open(norm(p), mode) end
    loadfile = function(p) return _loadfile(norm(p)) end
    dofile = function(p) return _dofile(norm(p)) end
    local DIRS = _dofile('/w/__dirs.lua')
    -- windower.get_dir of load_job.lua asks the system: dir /b "<folder>"
    io.popen = function(cmd)
        local p = cmd:match('^dir /b "(.-)"')
        local names = p and DIRS[(norm(p):gsub('/$', ''))] or {}
        local i = 0
        return {lines = function() return function() i = i + 1 return names[i] end end, close = function() end}
    end
    os.execute = function() return 0 end
    os.exit = function(code) error('EXIT ' .. tostring(code), 0) end
    `;
    async function makeLuaRunner(glueFactory, wasmBinary) {
      let stdout = [], stderr = [];
      const M = await glueFactory({wasmBinary, print: s => stdout.push(s), printErr: s => stderr.push(s)});
      const FS = M.FS, made = new Set();
      const loadstring = M.cwrap('luaL_loadstring', 'number', ['number', 'string']);
      const tolstring = M.cwrap('lua_tolstring', 'string', ['number', 'number', 'number']);
      const mkdirs = dir => { let p = '';
        for (const part of dir.split('/').filter(Boolean)) { p += '/' + part; if (!made.has(p)) { try { FS.mkdir(p); } catch (e) {} made.add(p); } } };
      const vpath = rel => '/w/' + rel.replace(/\\/g, '/').toLowerCase();
      const q = s => '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"';
      const exec = (L, code) => {
        if (loadstring(L, code)) return 'syntax: ' + tolstring(L, -1, 0);
        return M._lua_pcall(L, 0, 0, 0) ? String(tolstring(L, -1, 0)) : null;
      };
      return {
        put(rel, bytes) { const p = vpath(rel); mkdirs(p.slice(0, p.lastIndexOf('/'))); FS.writeFile(p, bytes); },
        del(rel) { try { FS.unlink(vpath(rel)); } catch (e) {} },
        dirs(map) {
          FS.writeFile('/w/__dirs.lua', 'return {' + Object.entries(map).map(([d, names]) => `[${q(vpath(d).replace(/\/$/, ''))}]={${names.map(q).join(',')}}`).join(',\n') + '}');
        },
        run(char, job, sub) {
          stdout = []; stderr = [];
          // the folders an export writes into (windower.create_dir does nothing here)
          for (const d of ['atelier/exports', 'saved/atelier', 'logs']) mkdirs(vpath(`${DATA}/${char}/${d}`));
      mkdirs(vpath(`${DATA}/atelier`));
          const L = M._luaL_newstate();
          M._luaL_openlibs(L);
          const script = vpath(`${DATA}/scripts/atelier/load_job.lua`);
          const error = exec(L, LUA_PRELUDE) || exec(L, `arg = {[0]=${q(script)}, ${q(char)}, ${q(job)}, ${q(sub)}, ""}
    dofile(${q(script)})`);
          M._lua_close(L);
          // load_job.lua prints where it wrote, under the data folder ("Kaories/atelier/exports/GEO_DRK.js")
          const rel = error ? null : (stdout[stdout.length - 1] || '').trim() || null;
          let text = null;
          if (rel) { try { text = FS.readFile(vpath(DATA + '/' + rel), {encoding: 'utf8'}); FS.unlink(vpath(DATA + '/' + rel)); } catch (e) {} }
          // the export also writes the spell families into atelier/index.js: handed back for an index that has none
      let families = null;
      try { families = (FS.readFile(vpath(`${DATA}/atelier/index.js`), {encoding: 'utf8'}).match(/^window\.ATELIER_FAMILIES = .*;$/m) || [])[0] || null; } catch (e) {}
      return {char, job, sub, rel, text, families, error: error || (text ? null : stderr.join(' ').trim() || 'no export written')};
        },
      };
    }
    return makeLuaRunner;
  }
  return {run, sources, parseExport, formatExport, luaRunnerFactory, DATA};
})();
if (typeof module !== 'undefined') module.exports = OfflineExport;

/* ---- in the page: the Windower folder, a worker for Lua, the button ---- */
if (typeof document !== 'undefined') {
  Object.assign(T.fr, {refreshBtn: 'Relire les fichiers', refreshNone: 'Rien reçu', refreshFail: 'Lecture échouée',
    refreshTip: 'Relit les jobs de ce perso depuis ses fichiers, sans le jeu : seuls les jobs modifiés sont refaits (Maj+clic : tous, avec tous leurs subs). Le contenu des sacs reste celui du dernier //gs c atelier en jeu',
    refreshNoneTip: 'Aucune réponse en 3 minutes. Lance une fois « Atelier - export all jobs.bat » dans le dossier data : il active ce bouton',
    refreshP_read: 'Lecture des fichiers…', refreshP_start: 'Démarrage de Lua…', refreshP_jobs: 'Job {n} / {m} · {w}', refreshP_subs: 'Sub {n} / {m} · {w}', refreshP_write: 'Écriture…',
    refreshLast: 'Dernière lecture : {e} export(s) refait(s), {u} job(s) inchangé(s).', refreshLastFail: 'Dernière lecture : {f} job(s) en échec ({l}).',
    refreshNoLua: 'Le fichier atelier/lua/lua51.js manque : la page ne peut pas lancer Lua.',
    wfolderTitle: 'Où est Windower ?', wfolderWrong: 'Choisis le dossier de Windower lui-même : celui qui contient « addons » et « res ».',
    wfolderWhy: 'Pour relire tes jobs sans le jeu, la page a besoin de lire tes fichiers GearSwap et les ressources de Windower. Montre-lui une fois le dossier de Windower :'});
  Object.assign(T.en, {refreshBtn: 'Reload from files', refreshNone: 'No response', refreshFail: 'Reload failed',
    refreshTip: 'Reloads this character\'s jobs from the files, without the game: only the jobs that changed are redone (Shift+click: all of them, with every subjob). The bags stay as of the last //gs c atelier in game',
    refreshNoneTip: 'No response after 3 minutes. Run "Atelier - export all jobs.bat" in the data folder once: it enables this button',
    refreshP_read: 'Reading the files…', refreshP_start: 'Starting Lua…', refreshP_jobs: 'Job {n} / {m} · {w}', refreshP_subs: 'Sub {n} / {m} · {w}', refreshP_write: 'Writing…',
    refreshLast: 'Last reload: {e} export(s) redone, {u} job(s) unchanged.', refreshLastFail: 'Last reload: {f} job(s) failed ({l}).',
    refreshNoLua: 'The file atelier/lua/lua51.js is missing: the page cannot run Lua.',
    wfolderTitle: 'Where is Windower?', wfolderWrong: 'Pick the Windower folder itself: the one that holds "addons" and "res".',
    wfolderWhy: 'To reload your jobs without the game, the page needs to read your GearSwap files and Windower\'s resources. Show it the Windower folder once:'});
}
// The Windower folder (the one holding addons and res), kept in the browser once picked, while it still lets the page in
async function oxWindowerFolder(){
  let dir = null;
  try { dir = await idb('readonly', st => st.get('windower')); } catch (e) {}
  if (!dir) return null;
  let perm = await dir.queryPermission({mode: 'readwrite'});
  if (perm !== 'granted') perm = await dir.requestPermission({mode: 'readwrite'});
  return perm === 'granted' ? dir : null;
}
async function oxPickWindower(){
  const dir = await window.showDirectoryPicker({id: 'atelier-windower', mode: 'readwrite'});
  const sub = async (d, n) => { try { return await d.getDirectoryHandle(n); } catch (e) { return null; } };
  let data = dir;
  for (const n of ['addons', 'GearSwap', 'data']) data = data && await sub(data, n);
  if (!data || !(await sub(dir, 'res'))) throw new Error(t('wfolderWrong'));
  // the data folder inside it serves the page's saves too (live.js dataFolder)
  try { await idb('readwrite', st => st.put(dir, 'windower')); await idb('readwrite', st => st.put(data, 'data')); } catch (e) {}
  return dir;
}
// OfflineExport's `env` over a folder handle (paths relative to it, with '/')
function oxEnv(root){
  const dirs = new Map([['', root]]), handles = new Map();
  const split = rel => { const i = rel.lastIndexOf('/'); return [i < 0 ? '' : rel.slice(0, i), rel.slice(i + 1)]; };
  const dirOf = async (rel, create) => {
    if (dirs.has(rel)) return dirs.get(rel);
    const [up, name] = split(rel), parent = await dirOf(up, create);
    if (!parent) return null;
    try { const h = await parent.getDirectoryHandle(name, {create: !!create}); dirs.set(rel, h); return h; } catch (e) { return null; }
  };
  const fileOf = async (rel, create) => {
    if (handles.has(rel)) return handles.get(rel);
    const [up, name] = split(rel), parent = await dirOf(up, create);
    if (!parent) return null;
    try { const h = await parent.getFileHandle(name, {create: !!create}); handles.set(rel, h); return h; } catch (e) { return null; }
  };
  const file = async rel => { const h = await fileOf(rel); try { return h ? await h.getFile() : null; } catch (e) { handles.delete(rel); return null; } };
  return {
    async list(rel){ const d = await dirOf(rel); if (!d) return null;
      const out = [];
      try { for await (const [name, h] of d.entries()) { const isDir = h.kind === 'directory'; out.push({name, dir: isDir}); (isDir ? dirs : handles).set(rel + '/' + name, h); } }
      catch (e) { dirs.delete(rel); return null; }
      return out; },
    async meta(rel){ const f = await file(rel); return f ? {size: f.size, mtime: f.lastModified} : null; },
    async bytes(rel){ const f = await file(rel); return f ? new Uint8Array(await f.arrayBuffer()) : new Uint8Array(0); },
    async text(rel){ const f = await file(rel); return f ? f.text() : null; },
    async write(rel, text){ const h = await fileOf(rel, true), w = await h.createWritable(); await w.write(text); await w.close(); },
    async remove(rel){ const [up, name] = split(rel), d = await dirOf(up); handles.delete(rel); try { if (d) await d.removeEntry(name); } catch (e) {} },
    lua(src, tasks, onDone){ return oxLua(this, src, tasks, onDone); },
  };
}
// Lua in workers, kept between two runs with the files they were sent: only what changed on the disk goes again.
// A page opened from the disk cannot start a worker from a file: its text is built here (the runner's own source,
// the loader's from atelier/lua/lua51.js).
const OX_POOL = [], OX_BYTES = new Map();
function oxWorker(){
  const code = `const makeLuaRunner = (${OfflineExport.luaRunnerFactory.toString()})();\nlet runner = null;\n` +
    `onmessage = async e => { const m = e.data; try {\n` +
    `  if (m.init) { const glue = new Function(m.init.glue + '\\nreturn glue;')(), raw = atob(m.init.wasm), bin = new Uint8Array(raw.length);\n` +
    `    for (let i = 0; i < raw.length; i++) bin[i] = raw.charCodeAt(i);\n` +
    `    runner = await makeLuaRunner(glue, bin); postMessage({id: m.id}); }\n` +
    `  else if (m.files) { for (const rel of m.gone) runner.del(rel); for (const [rel, bytes] of m.files) runner.put(rel, bytes); runner.dirs(m.dirs); postMessage({id: m.id}); }\n` +
    `  else postMessage({id: m.id, result: runner.run(m.task.char, m.task.job, m.task.sub)});\n` +
    `} catch (x) { postMessage({id: m.id, error: String(x && x.message || x)}); } };`;
  const w = new Worker(URL.createObjectURL(new Blob([code], {type: 'text/javascript'}))), waiting = new Map();
  let seq = 0;
  w.onmessage = e => { const p = waiting.get(e.data.id); waiting.delete(e.data.id); if (p) (e.data.error ? p[1](new Error(e.data.error)) : p[0](e.data.result)); };
  w.onerror = e => { for (const p of waiting.values()) p[1](new Error(e.message || 'worker')); waiting.clear(); };
  const call = msg => new Promise((ok, ko) => { const id = ++seq; waiting.set(id, [ok, ko]); w.postMessage(Object.assign({id}, msg)); });
  return {call, sent: new Map(), ready: call({init: {glue: ATELIER_LUA.glue, wasm: ATELIER_LUA.wasm}})};
}
async function oxLua(env, src, tasks, onDone){
  // one worker for a few loads (about 0.6 s each), three for a sweep of every subjob
  const n = Math.max(1, Math.min(tasks.length > 8 ? 3 : 1, (navigator.hardwareConcurrency || 2) - 1));
  while (OX_POOL.length < n) OX_POOL.push(oxWorker());
  const pool = OX_POOL.slice(0, n), stamp = m => m.size + '|' + m.mtime;
  for (const w of pool) {
    await w.ready;
    const need = [...src.metas].filter(([rel, m]) => w.sent.get(rel) !== stamp(m)), gone = [...w.sent.keys()].filter(rel => !src.metas.has(rel));
    const files = [];
    for (const [rel, m] of need) {
      const have = OX_BYTES.get(rel);
      if (!have || have.stamp !== stamp(m)) OX_BYTES.set(rel, {stamp: stamp(m), bytes: await env.bytes(rel)});
      files.push([rel, OX_BYTES.get(rel).bytes]);
    }
    await w.call({files, gone, dirs: src.dirs});
    for (const rel of gone) w.sent.delete(rel);
    for (const [rel, m] of need) w.sent.set(rel, stamp(m));
  }
  const results = new Array(tasks.length);
  let next = 0;
  await Promise.all(pool.map(async w => { while (next < tasks.length) { const i = next++; results[i] = await w.call({task: tasks[i]}); onDone(results[i]); } }));
  return results;
}
// The button: in a browser that can open a folder (Chrome, Edge), everything happens in the page; else the
// gsatelier:// link runs the Python script (live.js refreshByLink)
function refreshFromFiles(all){
  if (S._refresh === 'busy') return;
  if (!window.showDirectoryPicker) return refreshByLink();
  const label = text => { const el = document.querySelector('[data-refreshfiles] .lbl'); if (el) el.textContent = ' ' + text; };
  const go = async root => {
    S._refresh = 'busy'; render();
    try {
      await new Promise(done => window.ATELIER_LUA ? done() : loadScripts(['atelier/lua/lua51.js?v=' + Date.now()], done));
      if (!window.ATELIER_LUA) throw new Error(t('refreshNoLua'));
      const res = await OfflineExport.run(oxEnv(root), S.char, {allSubs: !!all, force: !!all, onProgress: (k, a, b, w) => label(t('refreshP_' + k, {n: a, m: b, w}))});
      try { sessionStorage.setItem('atelierRefresh', JSON.stringify({e: res.exported, u: res.unchanged, failed: res.failed.map(f => f[0] + '/' + f[1])})); } catch (e) {}
      location.reload();
    } catch (e) { S._refresh = 'fail'; S._refreshErr = String(e && e.message || e); render(); }
  };
  oxWindowerFolder().then(root => root ? go(root)
    : openFolderDialog(async () => { go(await oxPickWindower()); }, () => {}, {title: t('wfolderTitle'), why: t('wfolderWhy'), path: pageFolder().replace(/\\addons\\GearSwap\\data$/i, '')}));
}
