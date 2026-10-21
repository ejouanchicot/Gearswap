// GearSwap Atelier · update_core.js: what an update does, with no page around it (update.js draws it; also loaded by
// scripts/atelier/update_test.js under Node)
//
// A release is a tag v<version> on GitHub whose commit holds release_manifest.json: each file the update replaces with
// its git blob hash (scripts/release/release.py). An update:
//   1. reads the latest release (api.github.com) and its manifest (raw.githubusercontent.com, at the tag);
//   2. hashes the player's files as git does (a text file also with its CRLF made LF: git stores LF, the player's
//      copy may be CRLF) and lists what to add, replace and remove. A file the last update installed and the new
//      version drops is removed only when the player left it as it was; a code file the player changed is replaced
//      all the same (it is code, not a setting), its copy kept;
//   3. downloads every file first and checks each against its hash: one failure and nothing is written;
//   4. copies what it replaces or removes into one file, atelier/update_backup.json (atelier/ always exists: no folder
//      to make, windower.create_dir having hung AtelierLink once), then writes, the manifest last. Only the last
//      update can be undone.
// Player folders are never in a manifest, so never touched. A folder under git (the author's) is never updated.
// The browser downloads, so GitHub's certificate is checked (Windower's Lua does not check it); the env reads and writes
// the files through AtelierLink (update.js): a file the browser writes carries the Mark of the Web, and Windows Defender
// took our own update.js for a trojan that way.

const UpdCore = (() => {
  const REPO = 'ejouanchicot/Gearswap', MANIFEST = 'release_manifest.json', BACKUP = 'atelier/update_backup.json';
  const API = 'https://api.github.com/repos/' + REPO, RAW = 'https://raw.githubusercontent.com/' + REPO + '/';
  const enc = new TextEncoder(), dec = new TextDecoder();
  const subtle = () => (globalThis.crypto && globalThis.crypto.subtle);

  // git's hash of a file: sha1("blob <size>\0" + bytes)
  async function blobHash(bytes){
    const head = enc.encode('blob ' + bytes.length + '\0'), all = new Uint8Array(head.length + bytes.length);
    all.set(head); all.set(bytes, head.length);
    const h = new Uint8Array(await subtle().digest('SHA-1', all));
    return Array.from(h, b => b.toString(16).padStart(2, '0')).join('');
  }
  // as git decides: a NUL in the first 8000 bytes makes a file binary
  const isText = bytes => !bytes.subarray(0, 8000).includes(0);
  function lfOf(bytes){
    const out = new Uint8Array(bytes.length);
    let n = 0;
    for (let i = 0; i < bytes.length; i++) if (!(bytes[i] === 13 && bytes[i + 1] === 10)) out[n++] = bytes[i];
    return out.subarray(0, n);
  }
  // Whether the player's bytes are that blob: as they are, or with CRLF made LF for a text file
  async function same(bytes, hash){
    if (!bytes || !hash) return false;
    if (await blobHash(bytes) === hash) return true;
    return isText(bytes) && bytes.includes(13) && await blobHash(lfOf(bytes)) === hash;
  }

  // 4.0.10 > 4.0.9; a missing version is older than any
  function newer(a, b){
    const p = v => String(v || '').split('.').map(x => parseInt(x, 10) || 0);
    const x = p(a), y = p(b);
    for (let i = 0; i < Math.max(x.length, y.length); i++) if ((x[i] || 0) !== (y[i] || 0)) return (x[i] || 0) > (y[i] || 0);
    return false;
  }

  async function getJson(fetchFn, url){
    const r = await fetchFn(url, {cache: 'no-store'});
    if (!r.ok) throw new Error(r.status === 404 ? 'none' : 'http ' + r.status);
    return r.json();
  }
  /** The latest release: {tag, version, notes, url, date}; throws 'none' when there is none */
  async function latest(fetchFn){
    const r = await getJson(fetchFn, API + '/releases/latest');
    return {tag: r.tag_name, version: String(r.tag_name || '').replace(/^v/, ''), notes: r.body || '', url: r.html_url || '', date: r.published_at || ''};
  }
  const rawUrl = (tag, path) => RAW + encodeURIComponent(tag) + '/' + path.split('/').map(encodeURIComponent).join('/');
  /** The manifest of a release: {version, files: {path: hash}}, and its text (written as it came) */
  async function manifestOf(fetchFn, tag){
    const r = await fetchFn(rawUrl(tag, MANIFEST), {cache: 'no-store'});
    if (!r.ok) throw new Error('manifest http ' + r.status);
    const text = await r.text(), m = JSON.parse(text);
    if (!m || typeof m.files !== 'object') throw new Error('manifest');
    return {m, text};
  }

  /** What is installed: the version (VERSION) and the manifest of the last update (null for an older folder) */
  async function installed(env){
    const v = await env.bytes('VERSION'), mb = await env.bytes(MANIFEST);
    let m = null;
    try { m = mb ? JSON.parse(dec.decode(mb)) : null; } catch (e) { m = null; }
    return {version: v ? dec.decode(v).trim() : '', manifest: m && typeof m.files === 'object' ? m : null};
  }

  /** What the update changes: {add, update, remove, changed (code files the player edited), kept (theirs, left)} */
  async function plan(env, remote, inst, progress){
    const out = {add: [], update: [], remove: [], changed: [], kept: []};
    const was = inst && inst.manifest ? inst.manifest.files : null, paths = Object.keys(remote.files);
    // an env that reads in batches (AtelierLink) reads them all first
    if (env.preload) await env.preload(paths.concat(was ? Object.keys(was).filter(p => !(p in remote.files)) : []), progress);
    for (let i = 0; i < paths.length; i++) {
      const p = paths[i], b = await env.bytes(p);
      if (progress && i % 25 === 0) progress('scan', i, paths.length);
      if (!b) { out.add.push(p); continue; }
      if (await same(b, remote.files[p])) continue;
      out.update.push(p);
      if (was && was[p] && !(await same(b, was[p]))) out.changed.push(p);
    }
    for (const p of was ? Object.keys(was) : []) {
      if (p in remote.files) continue;
      const b = await env.bytes(p);
      if (!b) continue;
      (await same(b, was[p]) ? out.remove : out.kept).push(p);
    }
    return out;
  }

  /** Every file to write, downloaded and checked against its hash: Map path -> bytes; throws on the first failure */
  async function download(fetchFn, tag, remote, paths, progress, lanes = 6){
    const got = new Map(), todo = paths.slice();
    let done = 0;
    async function lane(){
      while (todo.length) {
        const p = todo.shift(), r = await fetchFn(rawUrl(tag, p), {cache: 'no-store'});
        if (!r.ok) throw new Error(p + ': http ' + r.status);
        const b = new Uint8Array(await r.arrayBuffer());
        if (await blobHash(b) !== remote.files[p]) throw new Error(p + ': hash');
        got.set(p, b);
        if (progress) progress('get', ++done, paths.length);
      }
    }
    await Promise.all(Array.from({length: Math.min(lanes, paths.length)}, lane));
    return got;
  }

  // bytes <-> base64, the copies' form in the backup file (JSON holds text only)
  function toB64(bytes){
    let s = '';
    for (let i = 0; i < bytes.length; i += 0x8000) s += String.fromCharCode.apply(null, bytes.subarray(i, i + 0x8000));
    return btoa(s);
  }
  function fromB64(text){
    const s = atob(text), out = new Uint8Array(s.length);
    for (let i = 0; i < s.length; i++) out[i] = s.charCodeAt(i);
    return out;
  }

  /** The copy first, then the files, the manifest last */
  async function apply(env, pl, got, remote, inst, progress, now = new Date()){
    if (await env.exists('.git')) throw new Error('git');
    const touched = pl.update.concat(pl.remove), had = await env.bytes(MANIFEST), files = {};
    for (const p of touched) files[p] = toB64(await env.bytes(p));
    if (had) files[MANIFEST] = toB64(had);
    const undo = {from: inst.version || '', to: remote.m.version, at: now.toISOString(),
      added: pl.add.concat(had ? [] : [MANIFEST]), replaced: pl.update.concat(had ? [MANIFEST] : []), removed: pl.remove, files};
    // written before the first file: an update stopped halfway (a file held open) can be undone too
    await env.write(BACKUP, enc.encode(JSON.stringify(undo)));
    const writes = pl.add.concat(pl.update);
    for (let i = 0; i < writes.length; i++) {
      await env.write(writes[i], got.get(writes[i]));
      if (progress) progress('write', i + 1, writes.length);
    }
    for (const p of pl.remove) await env.remove(p);
    await env.write(MANIFEST, enc.encode(remote.text));
  }

  /** The last update, if it can be undone: {from, to, at, added, replaced, removed, files} */
  async function lastUpdate(env){
    const b = await env.bytes(BACKUP);
    if (!b) return null;
    try { const u = JSON.parse(dec.decode(b)); return u && u.files ? u : null; } catch (e) { return null; }
  }
  /** Puts the files of the last update back as they were, then drops the copy; returns what it undid */
  async function rollback(env){
    if (await env.exists('.git')) throw new Error('git');
    const u = await lastUpdate(env);
    if (!u) throw new Error('nothing');
    for (const p of u.replaced.concat(u.removed)) {
      if (!(p in u.files)) throw new Error(p + ': no copy');
      await env.write(p, fromB64(u.files[p]));
    }
    for (const p of u.added) await env.remove(p);
    await env.remove(BACKUP);
    return u;
  }

  return {REPO, MANIFEST, blobHash, same, newer, latest, manifestOf, installed, plan, download, apply, lastUpdate, rollback};
})();
if (typeof module !== 'undefined') module.exports = UpdCore;
