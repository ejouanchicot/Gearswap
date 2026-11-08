<!--
  GearSwap Atelier · the top bar: the character's banner (its job's emblem, its name, the job and subjob menus), the
  characters, the job's macro book, lockstyle and export, then the files', the game's and the page's commands.
  Drawn again at each redraw of the old page (stores/legacy.svelte.ts), changing only what differs: the button under
  the pointer keeps its hover (the old page had to patch its HTML by hand for that, sets_view.js patchInto).
  The styles are the old page's (atelier/app/css: base.css .topbar, themes.css .hero / .tgrp / .live, fit.css).

  @file    atelier/src/screens/topbar/TopBar.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {selSync} from '../../components/selsync';
  import {legacy} from '../../stores/legacy.svelte';
  import {topBarModel, type Command} from './model';

  // the old page's state is read again at each of its redraws (nothing before its first one)
  const bar = $derived(legacy.version > 0 ? topBarModel() : null);
  // a command's data-* attribute, read by the old page's click handlers (events.js, packages.js)
  const attrs = (c: Command): Record<string, string> => c.attr ? {[c.attr]: ''} : {};
  // each menu's pictogram, line drawings made for 16 px (the game's icons were too busy at that size, the player
  // 2026-11-08): Files a sheet with a folded corner; GearSwap two gears and two arrows that swap them; Page a window.
  // With its name on a wide screen, alone under 1200 px (themes.css), the name then in its tip
  const svg = (body: string) => `<svg class="tmico" viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">${body}</svg>`;
  const gear = (x: number, y: number) => `<circle cx="${x}" cy="${y}" r="3.3" stroke-width="2.6" stroke-dasharray="1.55 1.05"/><circle cx="${x}" cy="${y}" r="1.2" stroke-width="1.4"/>`;
  const MENU_ICON: Record<string, string> = {
    files: svg('<path d="M6 2.8h8.2l4.8 4.8v13.6H6z"/><path d="M14 2.8v5h5"/><path d="M9 12.5h7M9 16.5h5"/>'),
    live: svg(gear(7.2, 7.2) + gear(16.8, 16.8) + '<path d="M13.2 4.6a7.2 7.2 0 0 1 6.2 6.2"/><path d="M19.4 10.8l1.4-2.4M19.4 10.8l-2.6-.8"/>'
      + '<path d="M10.8 19.4a7.2 7.2 0 0 1-6.2-6.2"/><path d="M4.6 13.2l-1.4 2.4M4.6 13.2l2.6.8"/>'),
    page: svg('<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 8.5h18"/><path d="M6 6.3h.01M8.5 6.3h.01M11 6.3h.01" stroke-width="2.2"/>')};
  // the three menus (Files, GearSwap, Page): one open at a time, closed by a pick or a click elsewhere
  let open = $state('');
  const toggle = (k: string) => { open = open === k ? '' : k; };
  $effect(() => {
    if (!open) return;
    const away = (e: MouseEvent) => { if (!(e.target as HTMLElement).closest('.tmenu')) open = ''; };
    document.addEventListener('click', away, true);
    return () => document.removeEventListener('click', away, true);
  });
</script>

{#snippet command(c: Command)}
  <button class="live act" class:mid={c.mid} class:busy={c.busy} {...attrs(c)} disabled={c.disabled} title={c.title}>{c.icon}<span class="lbl"> {c.label}</span></button>
{/snippet}
{#snippet menu(k: string, label: string, alert: boolean, items: Command[], head: import('svelte').Snippet | null, note = '', icon = '')}
  <div class="tmenu" class:open={open === k}>
    <button class="tmbtn" class:alert aria-expanded={open === k} aria-label={label} title={label} onclick={() => toggle(k)}>{#if head}{@render head()}{/if}{#if icon}{@html icon}{/if}<span class="tmlbl">{label}</span><i>▾</i></button>
    {#if open === k}<div class="tmpanel" onclick={() => { open = ''; }} role="presentation">{#if note}<span class="tmnote">{note}</span>{/if}{#each items as c (c.attr || c.label)}<button class="tmi" class:busy={c.busy} {...attrs(c)} disabled={c.disabled} title={c.title}><span class="tmic">{c.icon}</span>{c.label}</button>{/each}</div>{/if}
  </div>
{/snippet}

{#if bar}
  <div class="brand"><svg width="22" height="22" viewBox="0 0 26 26" aria-hidden="true"><path d="M13 1 L22 10 L13 25 L4 10 Z" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M4 10 H22 M13 1 L9 10 L13 25 L17 10 Z" fill="none" stroke="currentColor" stroke-width=".9" opacity=".6"/></svg><b>Atelier</b></div>
  {#if bar.hero}
    {@const h = bar.hero}
    <div class="hero" style:--role={h.role}>
      <span class="crest">
        {#if h.crest}{@html h.crest}{:else}<svg width="20" height="20" viewBox="0 0 26 26" aria-hidden="true"><path d="M13 1 L22 10 L13 25 L4 10 Z" fill="currentColor"/></svg>{/if}
      </span>
      <span class="who"><span class="tmenu tchar" class:open={open === 'char'}><button class="tcharbtn" aria-expanded={open === 'char'} title={bar.chars.label} onclick={() => toggle('char')}>{h.char}<i>▾</i></button>
        {#if open === 'char'}<div class="tmpanel left" onclick={() => { open = ''; }} role="presentation">{#each bar.chars.list as c (c.name)}<button class="tmi" class:cur={c.pressed} data-char={c.name} title={c.title}><span class="tmic">{c.pressed ? '✓' : ''}</span>{c.name}</button>{/each}</div>{/if}</span><span class="plates">
        <select class="topsel jobsel" aria-label={h.job.aria} title={h.job.title} use:selSync={h.job.none ? '' : (h.job.groups.flatMap(g => g.options).find(o => o.selected) || {value: undefined}).value}>
          <option value="" selected={h.job.none}>{h.job.overview}</option>
          {#each h.job.groups as g (g.label)}
            <optgroup label={g.label}>{#each g.options as o (o.value)}<option value={o.value} selected={o.selected}>{o.label}</option>{/each}</optgroup>
          {/each}
        </select>
        {#if h.sub}
          <label class="pick" title={h.sub.title}><small>{h.sub.label}</small><select class="topsel subsel" use:selSync={(h.sub.groups.flatMap(g => g.options).find(o => o.selected) || {value: undefined}).value}>
            {#each h.sub.groups as g (g.label)}
              <optgroup label={g.label}>{#each g.options as o (o.value)}<option value={o.value} selected={o.selected}>{o.label}</option>{/each}</optgroup>
            {/each}
          </select></label>
        {/if}
      </span></span>
    </div>
  {/if}
  {#if bar.facts.length}
    <span class="tsep"></span>
    {#each bar.facts as f (f.label)}
      <div class="tgrp tfact" title={f.label}><small>{f.label}</small><span><b class="readout">{#if f.html}{@html f.text}{:else}{f.text}{/if}{#if f.offline}{' · ' + f.offline}{/if}{#if f.old}{' '}<span class="oldexport" title={f.old.title}>· {f.old.text}</span>{/if}</b></span></div>
    {/each}
  {/if}
  <span class="sp"></span>
  {#if bar.files.list.length}{@render menu('files', bar.files.label, bar.files.list.some(c => c.mid), bar.files.list, null, '', MENU_ICON.files)}{/if}
  {#if bar.live}
    {@const l = bar.live}
    {#if l.lamp}<button class="live on" data-livejump disabled={l.lamp.disabled} title={l.lamp.title}><i class="led"></i>{l.lamp.text}</button>{/if}
    {#snippet lamp()}<i class="tmled" class:on={!!(l.state && l.state.linked)} title={l.state ? l.state.title : ''}></i>{/snippet}
    {@render menu('live', l.label, false, l.list, lamp, l.state ? l.state.text : '', MENU_ICON.live)}
  {/if}
  {@render menu('page', bar.page.label, bar.page.list.some(c => c.mid), bar.page.list, null, '', MENU_ICON.page)}
{/if}
