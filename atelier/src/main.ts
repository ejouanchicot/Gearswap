// GearSwap Atelier · the page's entry: the Svelte application on the page's body, the bridge the tests use
//
// @file    atelier/src/main.ts
// @author  ejouanchicot
import {mount} from 'svelte';
import App from './App.svelte';
import {openBridge} from './bridge';
import {tankBox, offenseBox, boxHtml} from './screens/sets/figures';
import OptRun from './screens/optimizer/OptRun.svelte';
import {runOpen, runChanged} from './screens/optimizer/run.svelte';

openBridge();
// the figures' boxes worked out here, for the old page's screens that still draw them as HTML (engine.js tankHTML,
// offenseHTML)
window.ATELIER_FIGURES = {tankBox, offenseBox, boxHtml};
// the search window, one component in a box of its own: the old page moves that box between #overlay and the box of
// hidden searches (core.js searchPark); optimizer.js tells it when the search changes
const runBox = document.createElement('div');
runBox.className = 'runbox';
runBox.style.display = 'contents';
mount(OptRun, {target: runBox});
window.ATELIER_RUN = {open: (R: LegacyAny) => runOpen(R, runBox), changed: runChanged};
// on the body itself: the old page's frame (.app, #overlay, #tip) stays a child of <body>, as its styles expect
mount(App, {target: document.body});
