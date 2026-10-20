// ============================================================================
// Foreign GearSwap converter - his job keys in <JOB>_KEYBINDS.lua
// ============================================================================
// The keys his job file binds (foreign_eval.lua: `bind <key> <command>`), Mote's own F9-F12 and Ctrl+-/=
// left out (ours are Mote's too), added to the template's keybind file:
//   - a game command (input /ws "Evisceration" <t>, /penury) is kept as it is
//   - a GearSwap command (gs c ...) only through the map's key_commands ({'gs c cycle treasuremode':
//     'cyclestate TreasureMode'}): his own commands do not exist here; the others are said, not bound
//   - a key a CUSTOM entry of the map already binds is left to it
//   - his key wins over a template key on the same key (that template line is commented out)
//
//   node write_keys.js <eval.json> <map.js|-> <template_KEYBINDS.lua> <out.lua> [<report.json>]
//
// @file    scripts/convert/write_keys.js
// @author  ejouanchicot
// @version 1.0
// @date    Created: 2026-10-16
// ============================================================================
'use strict';
const fs = require('fs');
const [evalPath, mapPath, templatePath, outPath, reportPath] = process.argv.slice(2);
const data = JSON.parse(fs.readFileSync(evalPath, 'utf8'));
const map = mapPath && mapPath !== '-' ? require(require('path').resolve(mapPath)) : {};

const MOTE = /^(f9|\^f9|!f9|@f9|f10|\^f10|!f10|f11|\^f11|f12|\^f12|!f12|\^-|\^=)$/;
const customKeys = new Set((map.custom || []).map(c => (c.entry || c).key).filter(Boolean));
const commands = Object.fromEntries(Object.entries(map.key_commands || {}).map(([k, v]) => [k.toLowerCase(), v]));
const q = s => JSON.stringify(s);
const mine = new Map(), left = [];
for (const line of data.binds || []) {
  const m = /^bind\s+(\S+)\s+(.+)$/.exec(line.trim());
  if (!m || MOTE.test(m[1])) continue;
  const [, key, cmd] = m;
  if (customKeys.has(key)) continue;
  let command = null;
  if (/^input\s+\//.test(cmd)) command = cmd.replace(/^input\s+/, '');
  else if (/^\//.test(cmd)) command = cmd;
  else if (commands[cmd.toLowerCase()] !== undefined) command = commands[cmd.toLowerCase()];
  if (command) mine.set(key, command);           // a key bound twice: the last one, as in game
  else left.push(`${key}: ${cmd}`);
}

let text = fs.readFileSync(templatePath, 'utf8');
const taken = [];
for (const key of mine.keys()) {
  const re = new RegExp(`^([ \\t]*)(\\{\\s*key\\s*=\\s*"${key.replace(/[\^$.*+?()[\]{}|\\]/g, '\\$&')}".*)$`, 'mg');
  text = text.replace(re, (all, ind, rest) => { taken.push(key); return `${ind}-- ${rest}  -- ${data.player}'s own key below`; });
}
if (mine.size) {
  const lines = [`    -- ${data.player}'s own keys (converted from his ${data.file})`];
  for (const [key, command] of mine) {
    const desc = command.replace(/^\/\w+\s+/, '').replace(/"/g, '').replace(/\s*<[^>]*>\s*$/, '') || command;
    lines.push(`    { key = ${q(key)}, command = ${q(command)}, desc = ${q(desc)} },`);
  }
  // before the closing brace of the binds table: `<X>Keybinds.binds = {` matched brace by brace (strings and
  // comments skipped; a template may close its last entry and the table on one line, `}}`)
  const open = /\w+\.binds\s*=\s*\{/.exec(text);
  if (!open) throw new Error('no binds table in ' + templatePath);
  let depth = 0, i = open.index + open[0].length - 1, close = -1;
  for (; i < text.length; i++) {
    const c = text[i];
    if (c === '-' && text[i + 1] === '-') { i = text.indexOf('\n', i); if (i < 0) break; continue; }
    if (c === '"' || c === "'") { for (i++; i < text.length && text[i] !== c; i++) if (text[i] === '\\') i++; continue; }
    if (c === '{') depth++;
    else if (c === '}' && --depth === 0) { close = i; break; }
  }
  if (close < 0) throw new Error('binds table not closed in ' + templatePath);
  // the entry before: a comma after it (the last one may have none)
  let k = close - 1;
  while (k > 0 && /\s/.test(text[k])) k--;
  const before = text.slice(0, k + 1) + (text[k] === ',' || text[k] === '{' ? '' : ',');
  text = before + '\n\n' + lines.join('\n') + '\n' + text.slice(close);
}
fs.writeFileSync(outPath, text);
if (reportPath) fs.writeFileSync(reportPath, JSON.stringify({kept: [...mine], over_template: taken, left}, null, 1));
console.log(`${data.job}: ${mine.size} keys of his kept` + (taken.length ? `, ${taken.length} over a template key` : '') +
  (left.length ? `, ${left.length} left out` : ''));
