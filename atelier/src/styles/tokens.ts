// GearSwap Atelier · the page's measures, once: the widths where a layout changes and the spacing steps. The colours
// and radii are CSS variables of the themes (atelier/app/css/base.css, themes.css: --ink, --accent, --panel, --line,
// --radius...), which the Svelte components read as they are.
//
// The old page cuts its layouts at 25 different widths (2026-10-17 audit); the components use these four only, and
// the old styles move to them as their screens move to Svelte.
//
// @file    atelier/src/styles/tokens.ts
// @author  ejouanchicot

/** Window widths, in px, from which a layout changes (min-width) */
export const BREAKPOINTS = {
  /** a tablet or a narrow window: two columns stack, forms take one column */
  narrow: 760,
  /** the sets page shows its three columns (list, set, stats) */
  wide: 1100,
  /** room to keep the top bar on one line with several characters */
  large: 1500,
  /** very wide screens: more room for the stats column */
  ultra: 1800
} as const;

/** Spacing steps, in px: gaps, paddings, margins */
export const SPACE = [0, 4, 8, 12, 16, 24, 32] as const;

/** A media query for a breakpoint, for a component's script (a component's <style> writes the number itself) */
export const atLeast = (bp: keyof typeof BREAKPOINTS): string => `(min-width: ${BREAKPOINTS[bp]}px)`;
