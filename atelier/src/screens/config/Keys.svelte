<!--
  GearSwap Atelier · the Modes & keys part of the job's settings (keys.ts), in the frame of the three parts
  (ProFrame.svelte; SPEC notes/docs-perso/config-pro-2026-10-30): on the left the themes of the modes, then all the
  keys and another subjob's modes; in the middle a line a mode (its icon, its name as the game shows it, what it is,
  its values for the start value, its key), or the list of the keys with their conflicts; on the right the mode chosen.
  The buttons keep the attributes the old page's handlers read (events.js data-modestart, data-keyedit,
  data-keysundo, data-keyssave; keys.js data-keyspart, data-modesel, data-keysfilter, select[data-modelist]): the
  window that changes a key is still the old page's (keys.js openKeyEdit).

  @file    atelier/src/screens/config/Keys.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import ProFrame from './ProFrame.svelte';
  import type {KeysView, ModeRow} from './keys';

  let {view}: {view: KeysView} = $props();
  const g = $derived(view.game);
  const p = $derived(view.pro);
</script>

{#snippet keybtn(html: string, edit: number | null)}{#if edit !== null}<button type="button" class="kbtn" data-keyedit={edit} title={view.change.tip}><span class="kcaps">{#if html}{@html html}{:else}<i>{view.change.none}</i>{/if}</span><span class="kgo">{view.change.text}</span></button>{:else}<span class="kcaps">{@html html}</span>{/if}{/snippet}
{#snippet option(m: ModeRow)}
  <div class="cfg-r" class:sel={m.sel} class:chg={m.changed} data-modesel={m.name}>
    <span class="cfg-ri">{@html m.iconHtml}</span>
    <div class="cfg-rt"><b title={m.title}>{m.label}</b>{#if m.hint}<span>{m.hint}</span>{/if}</div>
    <div class="cfg-c">
      {#if m.ctl.k === 'switch'}<span class="modsw"><button type="button" class="sw-btn" role="switch" aria-checked={m.ctl.on} data-modestart={m.ctl.attr} title={m.ctl.tip}><span class="sw" class:on={m.ctl.on} aria-hidden="true"></span></button></span>
      {:else if m.ctl.k === 'seg'}<span class="modseg">{#each m.ctl.opts as o (o.attr)}<button type="button" aria-pressed={o.on} class:file={o.file} data-modestart={o.attr} title={o.tip}>{o.label}</button>{/each}</span>
      {:else}<select class="modin" data-modelist={m.ctl.name}>{#each m.ctl.opts as o (o.value)}<option value={o.value} selected={o.on}>{o.label}</option>{/each}</select>{/if}
      {@render keybtn(m.keyHtml, m.edit)}
    </div>
  </div>
{/snippet}

<ProFrame nav={p.nav} head={p.head} detail={p.detail} foot={p.foot} credit={view.credit}>
  {#if !p.keys}
    <div class="cfg-grp">{#each g.rows as m (m.name)}{@render option(m)}{/each}</div>
  {:else}
    {@const L = view.list}
    <div class="kfilters">{#each L.filters as fl (fl.id)}<button type="button" class:on={fl.on} class:bad={fl.bad} data-keysfilter={fl.id}>{fl.label}</button>{/each}{#if view.bar.others}<button type="button" class="kothers" data-keysall title={view.bar.others.title}>{@html view.bar.others.textHtml}</button>{/if}</div>
    {#if L.conflicts}
      <div class="cfg-sec bad"><span>{L.conflicts.title}</span><small>{L.conflicts.why}</small></div>
      <div class="cfg-grp">{#each L.conflicts.items as c, n (n)}<div class="cfg-r krow2"><span class="cfg-ri bad">!</span><div class="cfg-rt"><b>{c.names.join('  ·  ')}</b></div><div class="cfg-c"><span class="kst clash">{L.conflicts.chip}</span>{@render keybtn(c.keyHtml, c.edit)}</div></div>{/each}</div>
    {:else if L.none}<p class="kgood">{L.none}</p>{/if}
    {#each L.boxes as b (b.key)}<div class="cfg-sec"><span>{b.title}</span><small>{b.meta}</small></div>
      <div class="cfg-grp">{#each b.rows as r, n (n)}<div class="cfg-r krow2" class:chg={r.changed} class:dim={r.st === 'other' || r.st === 'hidden'}><span class="cfg-ri">⌨</span><div class="cfg-rt"><b>{#if r.code}<code>{r.code}</code>{:else}{r.desc}{/if}{#if r.sub}<em class="ksub">{r.sub}</em>{/if}</b>{#if r.help}<span title={r.help}>{r.help}</span>{/if}</div><div class="cfg-c"><span class="kst {r.st}" title={r.stTip}>{r.stText}</span>{@render keybtn(r.keyHtml, r.edit)}</div></div>{/each}</div>
    {/each}
    {#if L.mote}<details class="kmote" open={L.mote.open}><summary><b>{L.mote.box.title}</b> <span>({L.mote.box.rows.length})</span><small>{L.mote.why}</small></summary>
      <div class="kmotegrid">{#each L.mote.box.rows as r, n (n)}<div class="kmrow" class:taken={r.st === 'taken'} title={r.help || r.desc}><span class="kcaps">{@html r.keyHtml}</span><span class="kmd">{r.desc}</span>{#if r.st === 'taken'}<span class="kst taken" title={r.stTip}>{r.stText}</span>{/if}</div>{/each}</div>
    </details>{/if}
  {/if}
</ProFrame>
