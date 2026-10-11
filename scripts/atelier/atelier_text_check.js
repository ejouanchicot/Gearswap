// The words of the Atelier page's Configuration tab, checked against what the characters really have: nothing a player
// sees there may be left without its explanation, and nothing explained may point at a setting that does not exist.
//
//   node scripts/atelier/atelier_text_check.js [Character ...]      (default: every character with exports)
//
// From the exports (<Char>/atelier/exports/*.js), for every job:
//   1. every mode shown has its explanation in French and in English (state_help_fr.js, state_help_data.js);
//   2. every settings file has its French name and purpose (module_catalog.js MOD_FILE_FR) and its group;
//   3. every entry of the options catalog (MOD_CATALOG) is a setting some job's files hold, and can be changed;
//   4. every job has its presentation in both languages (job_guide_fr.js, job_guide_data.js);
//   5. every module has its group, its "what it does" in both languages;
//   6. every other setting of every file (the Advanced view) has its French name (module_rest_fr.js).
// Exit code 1 when a check fails. Run it after a change to a settings file, a states file, the catalog or the docs
// the page's texts come from (then: python scripts/atelier/build_state_help.py, build_job_guides.py).
//
// @author ejouanchicot
// @date   Created: 2026-10-11
const fs = require('fs'), path = require('path');
const DATA = path.resolve(__dirname, '../..'), JS = path.join(DATA, 'atelier/app/js');
const OX = require(path.join(JS, 'offline_export.js'));
const read = f => fs.readFileSync(path.join(JS, f), 'utf8');

// the page's own code, outside the page: the catalog, the texts and the reader of settings files
const T = {fr: {}, en: {}}, S = {char: '', lang: 'fr', job: ''};
const api = new Function('T', 'S', 'document', 't', 'esc', ['usables_data.js', 'job_guide_data.js', 'job_guide_fr.js', 'state_help_data.js', 'state_help_fr.js', 'module_catalog.js', 'module_rows.js', 'module_rest_fr.js', 'module_ux.js', 'modules.js'].map(read).join('\n') +
  ';return {MOD_CATALOG, MOD_GROUPS, MOD_FILE_FR, MOD_FILE_GROUP, JOB_GUIDE_EN, JOB_GUIDE_FR, STATE_HELP_EN, STATE_HELP_FR, STATE_HELP_COMMON_EN, STATE_HELP_MORE_EN, mcRows, modParsed, modKnown, modRestFr};')(T, S, {addEventListener() {}}, k => k, s => s);

const isChar = n => fs.existsSync(path.join(DATA, n, 'atelier/exports'));
const chars = process.argv.slice(2).length ? process.argv.slice(2) : fs.readdirSync(DATA).filter(isChar);
const HIDDEN_MODE = /^[A-Z]{3}Song\d$/;          // keys.js renderModes leaves these out
const fails = [], say = (what, list) => { console.log((list.length ? 'FAIL ' : 'ok   ') + what + (list.length ? ': ' + list.length : '')); for (const l of list.slice(0, 40)) console.log('       ' + l); if (list.length) fails.push(what); };

const noHelp = new Map(), noFile = new Set(), noGroup = new Set(), noRest = new Set(), shown = new Set(), jobs = new Set();
let rest = 0;
let modes = 0, files = 0;
for (const c of chars) {
  const dir = path.join(DATA, c, 'atelier/exports');
  for (const f of fs.readdirSync(dir).filter(n => n.endsWith('.js'))) {
    const d = OX.parseExport(fs.readFileSync(path.join(dir, f), 'utf8'));
    if (!d) { fails.push('unreadable export'); console.log('FAIL unreadable export ' + c + '/' + f); continue; }
    S.char = c; S.job = d.job; jobs.add(d.job);
    for (const m of d.modes || []) {
      if (HIDDEN_MODE.test(m.name)) continue;
      modes++;
      const fr = (api.STATE_HELP_FR[d.job] || {})[m.name] || api.STATE_HELP_FR['*'][m.name];
      const en = (api.STATE_HELP_EN[d.job] || {})[m.name] || (api.STATE_HELP_MORE_EN[d.job] || {})[m.name] || api.STATE_HELP_COMMON_EN[m.name];
      if (!fr || !en) { const k = m.name + ' (' + (m.desc || '') + ')' + (fr ? ' no English' : en ? ' no French' : ''); noHelp.set(k, (noHelp.get(k) || new Set()).add(d.job)); }
    }
    for (const cf of d.configs || []) {
      files++;
      const base = cf.file.split('/').pop(), pat = base.replace(/^[A-Z]{3}_/, '{JOB}_');
      if (!api.MOD_FILE_FR[base] && !api.MOD_FILE_FR[pat]) noFile.add(base);
      if (cf.scope !== 'job' && !api.MOD_FILE_GROUP[base] && !api.MOD_FILE_GROUP[pat]) noGroup.add(base);
    }
    for (const cf of d.configs || []) { const known = api.modKnown(d, cf), base = cf.file.split('/').pop().replace(/^[A-Z]{3}_/, '{JOB}_');
      for (const x of Object.values(api.modParsed(cf).byPath)) if (!known[x.path]) { rest++; if (!api.modRestFr(cf.file, x.path)) noRest.add(base + '  ' + x.path); } }
    if (d.configs) for (const fam of api.MOD_CATALOG) for (const r of api.mcRows(d, fam)) if (r.id) shown.add(r.id);
  }
}
console.log(chars.join(', ') + ': ' + jobs.size + ' jobs, ' + modes + ' modes, ' + files + ' settings files\n');
say('every mode shown is explained in French and English', [...noHelp].map(([k, s]) => k + '  [' + [...s].join(' ') + ']'));
say('every settings file has a French name and purpose', [...noFile]);
say('every character settings file has a group', [...noGroup]);
const orphans = []; api.MOD_CATALOG.forEach(fam => fam.items.forEach((it, i) => { if (!shown.has(fam.id + '.' + i)) orphans.push(fam.id + ': ' + it.file + ' ' + it.key); }));
say('every catalog entry is a setting some job holds', files ? orphans : ['no export holds settings files yet (reload the job in game, or //gs c atelier all)']);
say('every other setting of the Advanced view has its French name (' + rest + ' read)', [...noRest]);
say('every job has its presentation in French and English', [...jobs].filter(j => !api.JOB_GUIDE_FR[j] || !api.JOB_GUIDE_EN[j]));
const groups = new Set(api.MOD_GROUPS.map(g => g.id));
say('every module has a group and says what it does in both languages', api.MOD_CATALOG.filter(m => !groups.has(m.group) || !(m.tip && m.tip[0] && m.tip[1]) || !m.fr || !m.en).map(m => m.id));
say('every catalog entry has a title in both languages', api.MOD_CATALOG.flatMap(m => m.items.filter(it => !it.fr[0] || !it.en[0]).map(it => m.id + ': ' + it.key)));
console.log(fails.length ? '\n' + fails.length + ' check(s) failed' : '\nall the texts are in place');
process.exit(fails.length ? 1 : 0);
