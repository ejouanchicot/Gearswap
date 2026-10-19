<!--
  GearSwap Atelier · the control of a Modules setting (modules.ts ModCtl): buttons for a choice (an "auto" one with its
  field to force a value), a switch, a number (- / +, a slider, its standard value), a colour and the ready-made ones,
  a text field, the setting as written when the page cannot change it. Lists and tables are still the old page's HTML
  (module_items.js, module_rows.js). The controls
  keep the attributes the old handlers read (data-modfile, data-modpath, data-modopt, data-mcchoice, data-modin,
  data-modbool).

  @file    atelier/src/screens/config/ModCtl.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {ModCtl as Ctl} from './modules';

  import ModCtl from './ModCtl.svelte';

  let {c}: {c: Ctl} = $props();
</script>

{#snippet step(c: Extract<Ctl, {k: 'num'}>, i: number)}{@const b = c.steps[i]!}<button class="mcstep" data-numstep={b.step} {...c.lim} {...c.id} disabled={c.off} title={b.tip} aria-label={b.aria}>{b.sign}</button>{/snippet}

{#if c.k === 'seg'}<span class="modseg">{#each c.btns as b, i (i)}<button {...b.attrs} {...c.id} aria-pressed={b.pressed} disabled={c.off} title={b.tip}>{b.label}</button>{/each}</span>{#if c.input}<input class="modin num" type="text" value={c.input.value} placeholder={c.input.ph} {...c.id} data-modin disabled={c.off} title={c.input.tip}>{/if}{:else if c.k === 'switch'}<button class="modsw" role="switch" aria-checked={c.on} {...c.id} data-modbool disabled={c.off} title={c.tip}><span class="sw {c.on ? 'on' : ''}" aria-hidden="true"></span><b>{@html c.labelHtml}</b></button>{:else if c.k === 'text'}<input class="modin" type="text" value={c.value} {...c.id} data-modin disabled={c.off} title={c.tip}>{:else if c.k === 'num'}{#if c.slide}<input class="modrange" type="range" min={c.slide.min} max={c.slide.max} step={c.slide.step} value={c.value} data-modrange {...c.id} disabled={c.off} title={c.slide.tip}>{/if}<span class="mcfield">{@render step(c, 0)}<input class="modin num" type="text" inputmode="decimal" value={c.value} {...c.lim} {...c.id} data-modin disabled={c.off} title={c.tip}>{#if c.unit}<i class="mcunit">{c.unit}</i>{/if}{@render step(c, 1)}</span>{#if c.std}{#if c.std.is}<small class="mcstd is">{c.std.text}</small>{:else}<button class="mcstd" data-modstd={c.std.v} {...c.id} disabled={c.off} title={c.std.tip}>{c.std.text}</button>{/if}{/if}{:else if c.k === 'color'}<span class="modcolor"><input type="color" value={c.hex} {...c.attrs} disabled={c.off} title={c.tip}><code>{c.hex.toUpperCase()}</code><small>{c.of}</small></span>{:else if c.k === 'presets'}<div class="modpresets"><small>{c.label}</small>{#each c.tiles as p, i (i)}<button class="modpreset" {...p.attrs} aria-pressed={p.pressed} disabled={c.off} title={p.tip}><i style={p.style}></i><span>{p.name}</span></button>{/each}</div>{:else if c.k === 'multi'}{#each c.parts as p, i (i)}<ModCtl c={p} />{/each}{:else if c.k === 'code'}<details class="modadv"><summary>{c.summary}</summary><pre class="modcode">{c.code}</pre></details>{:else}{@html c.html}{/if}
