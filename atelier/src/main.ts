// GearSwap Atelier · the page's entry: the Svelte application on the page's body, the bridge the tests use
//
// @file    atelier/src/main.ts
// @author  ejouanchicot
import {mount} from 'svelte';
import App from './App.svelte';
import {openBridge} from './bridge';

openBridge();
// on the body itself: the old page's frame (.app, #overlay, #tip) stays a child of <body>, as its styles expect
mount(App, {target: document.body});
