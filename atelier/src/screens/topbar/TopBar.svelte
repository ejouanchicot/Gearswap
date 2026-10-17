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
  import {legacy} from '../../stores/legacy.svelte';
  import {topBarModel, type Command} from './model';

  // the old page's state is read again at each of its redraws (nothing before its first one)
  const bar = $derived(legacy.version > 0 ? topBarModel() : null);
  // a command's data-* attribute, read by the old page's click handlers (events.js, packages.js)
  const attrs = (c: Command): Record<string, string> => c.attr ? {[c.attr]: ''} : {};
</script>

{#snippet command(c: Command)}
  <button class="live act" class:mid={c.mid} class:busy={c.busy} {...attrs(c)} disabled={c.disabled} title={c.title}>{c.icon}<span class="lbl"> {c.label}</span></button>
{/snippet}

{#if bar}
  <div class="brand"><svg width="22" height="22" viewBox="0 0 26 26" aria-hidden="true"><path d="M13 1 L22 10 L13 25 L4 10 Z" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M4 10 H22 M13 1 L9 10 L13 25 L17 10 Z" fill="none" stroke="currentColor" stroke-width=".9" opacity=".6"/></svg><b>Atelier</b></div>
  {#if bar.hero}
    {@const h = bar.hero}
    <div class="hero" style:--role={h.role}>
      <span class="crest">
        {#if h.crest}{@html h.crest}{:else}<svg width="20" height="20" viewBox="0 0 26 26" aria-hidden="true"><path d="M13 1 L22 10 L13 25 L4 10 Z" fill="currentColor"/></svg>{/if}
      </span>
      <span class="who"><b>{h.char}</b><span class="plates">
        <select class="topsel jobsel" aria-label={h.job.aria} title={h.job.title}>
          <option value="" selected={h.job.none}>{h.job.overview}</option>
          {#each h.job.groups as g (g.label)}
            <optgroup label={g.label}>{#each g.options as o (o.value)}<option value={o.value} selected={o.selected}>{o.label}</option>{/each}</optgroup>
          {/each}
        </select>
        {#if h.sub}
          <label class="pick" title={h.sub.title}><small>{h.sub.label}</small><select class="topsel subsel">
            {#each h.sub.groups as g (g.label)}
              <optgroup label={g.label}>{#each g.options as o (o.value)}<option value={o.value} selected={o.selected}>{o.label}</option>{/each}</optgroup>
            {/each}
          </select></label>
        {/if}
      </span></span>
    </div>
  {/if}
  <span class="tsep"></span>
  <div class="tgrp"><small>{bar.chars.label}</small><span><div class="seg" role="group">
    {#each bar.chars.list as c (c.name)}<button aria-pressed={c.pressed} data-char={c.name} title={c.title}>{c.name}</button>{/each}
  </div></span></div>
  {#if bar.facts.length}
    <span class="tsep"></span>
    {#each bar.facts as f (f.label)}
      <div class="tgrp"><small>{f.label}</small><span><b class="readout">{#if f.html}{@html f.text}{:else}{f.text}{/if}{#if f.offline}{' · ' + f.offline}{/if}{#if f.old}{' '}<span class="oldexport" title={f.old.title}>· {f.old.text}</span>{/if}</b></span></div>
    {/each}
  {/if}
  <span class="sp"></span>
  {#if bar.files.list.length}
    <div class="tgrp"><small>{bar.files.label}</small><span>{#each bar.files.list as c (c.attr)}{@render command(c)}{/each}</span></div>
  {/if}
  {#if bar.live}
    {@const l = bar.live}
    <div class="tgrp"><small>{l.label}</small><span>
      {#if l.lamp}<button class="live on" data-livejump disabled={l.lamp.disabled} title={l.lamp.title}><i class="led"></i>{l.lamp.text}</button>{/if}
      {#if l.state}<span class="live" class:mid={l.state.linked} title={l.state.title}>{l.state.text}</span>{/if}
      {#each l.list as c (c.label)}{@render command(c)}{/each}
    </span></div>
  {/if}
  <div class="tgrp"><small>{bar.page.label}</small><span>{#each bar.page.list as c (c.attr)}{@render command(c)}{/each}</span></div>
{/if}
