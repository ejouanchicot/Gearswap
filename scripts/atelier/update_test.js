// The Atelier's update (atelier/app/js/update_core.js) on a player's folder made from an older commit, against a
// GitHub made of this repository: the latest release is HEAD (or --to <ref>), the player's folder holds --from <ref>
// (default HEAD~40) checked out with CRLF, as on Windows, with its manifest. Checks:
//   - every file of the release ends identical (by hash), the dropped ones untouched by the player are gone;
//   - a code file the player edited is reported and replaced, its copy kept; a file of theirs is never touched;
//   - a download with a wrong hash writes nothing; a folder under git is refused;
//   - undoing puts every file back byte for byte.
// Works in a temporary folder only.
//
//   node scripts/atelier/update_test.js [--from <ref>] [--to <ref>]
//
// @author ejouanchicot
// @date   Created: 2026-10-21
const fs = require('fs'), os = require('os'), path = require('path'), cp = require('child_process');
const DATA = path.resolve(__dirname, '../..');
const U = require(path.join(DATA, 'atelier/app/js/update_core.js'));
const arg = (k, d) => { const i = process.argv.indexOf(k); return i > 0 ? process.argv[i + 1] : d; };
const FROM = arg('--from', 'HEAD~40'), TO = arg('--to', 'HEAD');

let done = 0, failed = 0;
function check(what, ok, detail){
  done++;
  if (!ok) { failed++; console.log('FAILED ' + what + (detail ? ': ' + detail : '')); }
}

// {path: blob} of a commit in the update's scope, from scripts/release/release.py itself
function treeOf(ref){
  const py = `import sys, json; sys.path.insert(0, 'scripts/release'); import release; print(json.dumps(release.tree_files(${JSON.stringify(ref)})))`;
  return JSON.parse(cp.execFileSync('python', ['-c', py], {cwd: DATA, encoding: 'utf8', maxBuffer: 1 << 26}));
}
// the bytes of many blobs at once (git cat-file --batch)
function blobs(hashes){
  const out = cp.execFileSync('git', ['cat-file', '--batch'], {cwd: DATA, input: hashes.join('\n') + '\n', maxBuffer: 1 << 28});
  const got = new Map();
  let i = 0;
  for (const h of hashes) {
    const nl = out.indexOf(10, i), head = out.subarray(i, nl).toString().split(' '), size = +head[2];
    got.set(h, new Uint8Array(out.subarray(nl + 1, nl + 1 + size)));
    i = nl + 1 + size + 1;
  }
  return got;
}
// a Windows checkout (core.autocrlf): text files with CRLF
const crlf = b => b.subarray(0, 8000).includes(0) ? b : Buffer.from(Buffer.from(b).toString('latin1').replace(/\r?\n/g, '\r\n'), 'latin1');

function envOver(root){
  const abs = rel => path.join(root, rel);
  return {
    async bytes(rel){ try { return new Uint8Array(fs.readFileSync(abs(rel))); } catch (e) { return null; } },
    async write(rel, bytes){ fs.mkdirSync(path.dirname(abs(rel)), {recursive: true}); fs.writeFileSync(abs(rel), bytes); },
    async remove(rel){ try { fs.unlinkSync(abs(rel)); } catch (e) {} },
    async exists(rel){ return fs.existsSync(abs(rel)); },
  };
}
function snapshot(root){
  const out = {};
  (function walk(d){ for (const e of fs.readdirSync(d, {withFileTypes: true})) {
    const p = path.join(d, e.name);
    if (e.isDirectory()) { if (path.relative(root, p) !== 'update') walk(p); } else out[path.relative(root, p).replace(/\\/g, '/')] = fs.readFileSync(p).toString('base64');
  } })(root);
  return out;
}

(async () => {
  const oldTree = treeOf(FROM), newTree = treeOf(TO);
  const version = fs.readFileSync(path.join(DATA, 'VERSION'), 'utf8').trim();
  const remoteText = JSON.stringify({version, repo: U.REPO, commit: TO, files: newTree});
  const all = blobs([...new Set(Object.values(oldTree).concat(Object.values(newTree)))]);
  const byPath = new Map(Object.entries(newTree).map(([p, h]) => [p, all.get(h)]));

  const fakeFetch = (bad = null) => async url => {
    const ok = (body, type) => ({ok: true, status: 200, json: async () => JSON.parse(body), text: async () => String(body), arrayBuffer: async () => body});
    if (url.endsWith('/releases/latest')) return ok(JSON.stringify({tag_name: 'v' + version, body: 'notes', html_url: 'x'}));
    const m = url.match(/^https:\/\/raw\.githubusercontent\.com\/[^/]+\/[^/]+\/[^/]+\/(.+)$/);
    const p = m && m[1].split('/').map(decodeURIComponent).join('/');
    if (p === U.MANIFEST) return ok(remoteText);
    if (p && byPath.has(p)) { const b = byPath.get(p); return ok(p === bad ? new Uint8Array([1, 2, 3]).buffer : b.buffer.slice(b.byteOffset, b.byteOffset + b.length)); }
    return {ok: false, status: 404};
  };

  // the player's folder: the old version, CRLF, its manifest, a file of theirs, an edited code file
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'upd-'));
  try {
    for (const [p, h] of Object.entries(oldTree)) { fs.mkdirSync(path.dirname(path.join(root, p)), {recursive: true}); fs.writeFileSync(path.join(root, p), crlf(all.get(h))); }
    fs.writeFileSync(path.join(root, 'VERSION'), '3.9.0\r\n');
    fs.writeFileSync(path.join(root, U.MANIFEST), JSON.stringify({version: '3.9.0', files: oldTree}));
    fs.mkdirSync(path.join(root, 'Hero/war/sets'), {recursive: true});
    fs.writeFileSync(path.join(root, 'Hero/war/sets/war_sets.lua'), 'sets.idle = {}\r\n');
    const edited = Object.keys(oldTree).find(p => p.startsWith('shared/') && newTree[p] && newTree[p] !== oldTree[p]);
    if (edited) fs.appendFileSync(path.join(root, edited), '-- mine\r\n');
    const env = envOver(root), before = snapshot(root);

    const rel = await U.latest(fakeFetch()), remote = await U.manifestOf(fakeFetch(), rel.tag);
    check('latest is the tag', rel.version === version, rel.version);
    const inst = await U.installed(env);
    check('installed version read', inst.version === '3.9.0' && !!inst.manifest);
    const pl = await U.plan(env, remote.m, inst);
    const dropped = Object.keys(oldTree).filter(p => !(p in newTree));
    console.log(`plan ${FROM} -> ${TO}: +${pl.add.length} ~${pl.update.length} -${pl.remove.length}, edited ${pl.changed.length}, kept ${pl.kept.length}`);
    check('dropped files removed', pl.remove.length === dropped.length, pl.remove.length + ' vs ' + dropped.length);
    check('the edited file is reported', !edited || pl.changed.includes(edited), edited);
    check('CRLF copies of unchanged files are not downloaded', pl.update.every(p => oldTree[p] !== newTree[p] || p === edited));

    // a wrong hash: nothing written
    const some = pl.add.concat(pl.update);
    if (some.length) {
      let err = null;
      try { await U.download(fakeFetch(some[0]), rel.tag, remote.m, some); } catch (e) { err = e; }
      check('a wrong hash stops the download', err && /hash/.test(err.message), String(err));
      check('nothing written after a failed download', JSON.stringify(snapshot(root)) === JSON.stringify(before));
    }

    const got = await U.download(fakeFetch(), rel.tag, remote.m, some);
    await U.apply(env, pl, got, remote, inst);
    let bad = [];
    for (const [p, h] of Object.entries(newTree)) if (!(await U.same(await env.bytes(p), h))) bad.push(p);
    check('every release file installed', !bad.length, bad.slice(0, 5).join(', '));
    check('dropped files gone', dropped.every(p => !fs.existsSync(path.join(root, p))));
    check('player file untouched', fs.readFileSync(path.join(root, 'Hero/war/sets/war_sets.lua'), 'utf8') === 'sets.idle = {}\r\n');
    check('VERSION is the new one', fs.readFileSync(path.join(root, 'VERSION'), 'utf8').trim() === version);
    const again = await U.plan(env, remote.m, await U.installed(env));
    check('a second check finds nothing to do', !again.add.length && !again.update.length && !again.remove.length);

    const last = await U.lastUpdate(env);
    check('the update can be undone', last && last.from === '3.9.0' && last.to === version);
    await U.rollback(env);
    const after = snapshot(root), diff = Object.keys(Object.assign({}, before, after)).filter(k => before[k] !== after[k]);
    check('undo puts every file back', !diff.length, diff.slice(0, 5).join(', '));

    fs.mkdirSync(path.join(root, '.git'));
    let gitErr = null;
    try { await U.apply(env, pl, got, remote, inst); } catch (e) { gitErr = e; }
    check('a folder under git is refused', gitErr && gitErr.message === 'git');
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
  console.log(`${done} checks, ${failed} failed`);
  process.exit(failed ? 1 : 0);
})().catch(e => { console.error(e); process.exit(1); });
