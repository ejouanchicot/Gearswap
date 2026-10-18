// GearSwap Atelier · the page's entry: the Svelte application on the page's body, the bridge the tests use
//
// @file    atelier/src/main.ts
// @author  ejouanchicot
import {mount} from 'svelte';
import App from './App.svelte';
import {openBridge} from './bridge';
import {tankBox, offenseBox, boxHtml} from './screens/sets/figures';

openBridge();
// the figures' boxes worked out here, for the old page's screens that still draw them as HTML (engine.js tankHTML,
// offenseHTML)
window.ATELIER_FIGURES = {tankBox, offenseBox, boxHtml};
// on the body itself: the old page's frame (.app, #overlay, #tip) stays a child of <body>, as its styles expect
mount(App, {target: document.body});
