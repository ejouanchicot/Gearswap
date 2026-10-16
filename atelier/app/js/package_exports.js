// GearSwap Atelier · package_exports.js: the Atelier's exports put in a player's package (data/make_package.py), so
// the page shows the character's jobs and sets the first time it is opened. OfflineExport (offline_export.js) runs on
// the package's own files: GearSwap's come from the package, what lies outside GearSwap (Windower's res/ and
// addons/libs/) from the Windower folder of whoever makes the package. The main subjob of each job only: the game's
// first //gs c atelier brings the bags and the other subjobs.
//
// Used by the Packages page (packages.js, loaded only when a package is made) and under Node by
// scripts/atelier/package_exports_cli.js (make_package.py on the command line). Left out of a package, as packages.js.
const PackageExports = (() => {
  const GS = 'addons/GearSwap';
  const inside = rel => rel === GS || rel.startsWith(GS + '/');
  // of the Windower folder, only what every install has: never the maker's own lists (addons/PorterPacker)
  const shared = rel => ['res', 'addons/libs'].some(d => rel === d || rel.startsWith(d + '/'));
  const decoder = new TextDecoder(), encoder = new TextEncoder();

  // OfflineExport's env over the package: `files` a Map(rel -> bytes, rel from the Windower folder, under
  // addons/GearSwap/), `outside` an env over the Windower folder for the rest, `lua(env, src, tasks, onDone)` the Lua
  // runner; what the export writes goes into `files` and `written` (rel -> text)
  function env(files, outside0, written, lua){
    // one date for every file of this run: a Lua worker kept from another run sends a file again when its date changed
    const stamp = Date.now();
    const none = async () => null;
    const outside = {list: rel => shared(rel) ? outside0.list(rel) : none(), meta: rel => shared(rel) ? outside0.meta(rel) : none(),
      bytes: async rel => shared(rel) ? outside0.bytes(rel) : new Uint8Array(0), text: rel => shared(rel) ? outside0.text(rel) : none()};
    return {
      async list(rel){
        if (!inside(rel)) return outside.list(rel);
        const seen = new Map(), pre = rel + '/';
        for (const k of files.keys()) if (k.startsWith(pre)) { const rest = k.slice(pre.length), i = rest.indexOf('/');
          const name = i < 0 ? rest : rest.slice(0, i); seen.set(name, seen.get(name) || i >= 0); }
        return seen.size ? [...seen].map(([name, dir]) => ({name, dir})) : null;
      },
      async meta(rel){ if (!inside(rel)) return outside.meta(rel); const b = files.get(rel); return b ? {size: b.length, mtime: stamp} : null; },
      async bytes(rel){ return inside(rel) ? files.get(rel) || new Uint8Array(0) : outside.bytes(rel); },
      async text(rel){ if (!inside(rel)) return outside.text(rel); const b = files.get(rel); return b ? decoder.decode(b) : null; },
      async write(rel, text){ files.set(rel, encoder.encode(text)); written.set(rel, text); },
      async remove(rel){ files.delete(rel); written.delete(rel); },
      lua(src, tasks, onDone){ return lua(this, src, tasks, onDone); },
    };
  }
  // The icons of the items the exports name (their "icons" field), copied from the maker's data/atelier/icons/: the
  // game writes them there (//gs c atelier), the player's own only after a first export in game. [[rel, bytes]]
  async function icons(written, outside){
    const ids = new Set();
    for (const [rel, text] of written) {
      const m = rel.includes('/atelier/exports/') && text.match(/"icons":(\{[^{}]*\})/);
      if (m) for (const id of Object.values(JSON.parse(m[1]))) ids.add(+id);
    }
    const out = [];
    for (const id of [...ids].sort((a, b) => a - b)) {
      const rel = `${GS}/data/atelier/icons/${id}.bmp`, b = await outside.bytes(rel);
      if (b && b.length) out.push([rel, b]);
    }
    return out;
  }
  // The exports of `name` made from the package's files, and their icons:
  // {result (OfflineExport.run's), files: [[rel, text]], icons: [[rel, bytes]]}
  async function run(files, outside, lua, name, onProgress){
    const OX = typeof OfflineExport !== 'undefined' ? OfflineExport : require('./offline_export.js');
    const written = new Map();
    const result = await OX.run(env(files, outside, written, lua), name, {mainOnly: true, force: true, onProgress});
    return {result, files: [...written], icons: await icons(written, outside)};
  }
  return {run, env};
})();
if (typeof module !== 'undefined') module.exports = PackageExports;
