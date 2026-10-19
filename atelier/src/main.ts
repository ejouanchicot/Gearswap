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
import Dialog from './screens/dialogs/Dialog.svelte';
import {dialogShow, dialogUpdate, type DialogSpec} from './screens/dialogs/dialogs.svelte';
import {compareView} from './screens/dialogs/compare';
import {gearPickView} from './screens/dialogs/gearpick';
import {targetView} from './screens/dialogs/target';
import {pickView, addView} from './screens/dialogs/partypick';
import {pushView, delView, addSetView} from './screens/dialogs/pushview';
import {tierCostView} from './screens/dialogs/tiercost';
import {historyView} from './screens/dialogs/history';
import {optAllView} from './screens/dialogs/optall';
import {statPickView} from './screens/dialogs/statpick';

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
// the windows over the page (trial.js showDialog, openCompare), the same way
const dialogBox = document.createElement('div');
dialogBox.className = 'dialogbox';
dialogBox.style.display = 'contents';
mount(Dialog, {target: dialogBox});
window.ATELIER_DIALOG = {show: (d: DialogSpec) => dialogShow(d, dialogBox), update: dialogUpdate, compareView, gearPickView, targetView, pickView, addView, pushView, delView, addSetView, tierCostView, historyView, optAllView, statPickView};
// on the body itself: the old page's frame (.app, #overlay, #tip) stays a child of <body>, as its styles expect
mount(App, {target: document.body});
