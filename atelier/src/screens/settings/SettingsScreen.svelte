<!--
  GearSwap Atelier · the page's Settings (settings.ts): how it looks on the left (theme, language, motion), how it helps
  and computes on the right (the moogle assistant, the engine); two columns on a wide screen, so all of it is in sight.

  @file    atelier/src/screens/settings/SettingsScreen.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {legacy} from '../../stores/legacy.svelte';
  import {settingsView} from './settings';

  const view = $derived(legacy.version > 0 ? settingsView() : null);
</script>

{#if view}
  {@const th = view.theme}{@const lg = view.lang}{@const mo = view.motion}{@const gd = view.guide}{@const en = view.engine}
  <div class="cfg"><header><h2>{view.title}</h2><button class="btn ghost" data-config>{'← ' + view.back}</button></header><div class="cfgcols"><div><section class="box"><h3>{th.title}</h3><p>{th.why}</p><div class="themes">{#each th.cards as c (c.id)}<button class="themecard" data-theme-set={c.id} aria-pressed={c.on}><span class="pv" style={c.pv}><i></i><i></i></span><b>{c.name}</b><small>{c.desc}</small></button>{/each}</div></section><div class="cfgpair"><section class="box"><h3>{lg.title}</h3><p>{lg.why}</p><div class="cfgrow"><div class="seg" role="group" aria-label={lg.title}><button data-lang="fr" aria-pressed={lg.fr}>Français</button><button data-lang="en" aria-pressed={lg.en}>English</button></div></div></section><section class="box"><h3>{mo.title}</h3><p>{mo.why}</p><div class="cfgrow"><div class="seg" role="group" aria-label={mo.title}><button data-motion-set="on" aria-pressed={mo.on}>{mo.onLabel}</button><button data-motion-set="off" aria-pressed={!mo.on}>{mo.offLabel}</button></div></div></section></div></div><div><section class="box"><h3>{gd.title}</h3><p>{gd.why}</p><div class="cfgrow"><div class="seg" role="group" aria-label={gd.title}>{#each gd.modes as m (m.v)}<button data-guide-mode={m.v} aria-pressed={m.on}>{m.label}</button>{/each}</div><button class="btn ghost" data-guide-reset>{gd.reset}</button></div></section><section class="box"><h3>{en.title}</h3><p>{en.why}</p>{#if en.none}<div class="cfgrow"><span>{en.none}</span></div>{:else}<div class="engines">{#each en.cards as c (c.id)}<button class="engcard" data-engine={c.id} aria-pressed={c.on}><b>{c.title + (c.reco ? ' ' : '')}{#if c.reco}<em>{c.reco}</em>{/if}</b><ul>{#each c.lines as l, i (i)}<li>{l}</li>{/each}</ul></button>{/each}</div><p class="englink"><a href={en.url} target="_blank" rel="noopener">{en.link + ' ↗'}</a> <span>{en.url.replace('https://', '')}</span></p>{#if en.fell}<p class="engfell">{en.fell}</p>{/if}{/if}</section></div></div></div>
{/if}
