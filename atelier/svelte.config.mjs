// GearSwap Atelier · Svelte's settings, read by the build (vite.config.mts) and by `npm run check` (svelte-check):
// the components' <script lang="ts"> goes through Vite's TypeScript.
//
// @file    atelier/svelte.config.mjs
// @author  ejouanchicot
import {vitePreprocess} from '@sveltejs/vite-plugin-svelte';

export default {preprocess: vitePreprocess()};
