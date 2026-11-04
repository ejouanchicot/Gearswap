// GearSwap Atelier · scripts/atelier/lib/browser.js: the browser the page's tests drive, found once for all of them
// (scripts/atelier/clicks, the parity and layout checks, scripts/audit). Each used to load Puppeteer from inside the
// MCP puppeteer server's own folder and Chrome from one fixed path: a machine without them in those very places ran
// no test at all.
//   puppeteer  $PUPPETEER (a folder or a module name), else a puppeteer or puppeteer-core installed for node
//              (`npm i -g puppeteer`), else the one the MCP puppeteer server brings (%APPDATA%\npm\node_modules)
//   CHROME     $CHROME, else the first of the usual installs of Chrome, then Edge, that exists
//
// @file    scripts/atelier/lib/browser.js
// @author  ejouanchicot
'use strict';
const fs = require('fs');
const path = require('path');

const APPDATA = process.env.APPDATA || '';
const LOCAL = process.env.LOCALAPPDATA || '';

function loadPuppeteer(){
  const tries = [process.env.PUPPETEER, 'puppeteer', 'puppeteer-core',
    path.join(APPDATA, 'npm/node_modules/puppeteer'),
    path.join(APPDATA, 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer')].filter(Boolean);
  for (const name of tries) {
    try { return require(name); } catch (e) { /* the next place */ }
  }
  throw new Error('Puppeteer not found: npm i -g puppeteer, or set PUPPETEER to its folder (tried ' + tries.join(', ') + ')');
}

const CHROMES = [process.env.CHROME,
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  LOCAL && path.join(LOCAL, 'Google/Chrome/Application/chrome.exe'),
  'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
  'C:/Program Files/Microsoft/Edge/Application/msedge.exe'].filter(Boolean);
const CHROME = CHROMES.find(p => fs.existsSync(p)) || CHROMES[0];

module.exports = {get puppeteer(){ return loadPuppeteer(); }, CHROME};
