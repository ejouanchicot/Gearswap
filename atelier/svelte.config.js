// GearSwap Atelier · Svelte's settings, read by the build (vite.config.ts) and by `npm run check` (svelte-check):
// the components' <script lang="ts"> goes through Vite's TypeScript.
//
// @file    atelier/svelte.config.js
// @author  ejouanchicot
import {vitePreprocess} from '@sveltejs/vite-plugin-svelte';

export default {preprocess: vitePreprocess()};
