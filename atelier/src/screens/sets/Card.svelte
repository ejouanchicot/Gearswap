<!--
  GearSwap Atelier · the card of the set shown (card.ts), laid out as a screen of the game (the player, 2026-11-08):
  - the title line: the set's name, at its right undoing the optimizer's last run (while there is one) and deleting
    the set; its versions as the window's tabs under it; under it one band, what it is
    (when it is worn, a weaponskill's facts) and its path; a weaponskill's settings (its weapon, its TP) full width;
  - then two blocks side by side: at the left the gear as the game's equipment grid (tight cells, the icon filling its
    cell), under it the optimizer's button and the one that wears it in game; at the right an info panel with its tabs (the set: its goals,
    limits, what it seeks, its notes; its weapons' menus; its code, a button in the tabs' bar copying it; the legend)
    and, at its foot, what it inherits;
  - its figures under it on a narrow window.
  The slots and buttons keep the attributes the old page's handlers read (events.js data-card / data-slot /
  data-variant / data-cardtab, trial.js data-unslot).

  @file    atelier/src/screens/sets/Card.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import TrialRow from './TrialRow.svelte';
  import TitleBox from './TitleBox.svelte';
  import WsHead from './WsHead.svelte';
  import WeaponMenu from './WeaponMenu.svelte';
  import StateName from '../../components/StateName.svelte';
  import type {CardView, VerButton, SlotView} from './card';
  import Figures from './Figures.svelte';
  import type {CtxBar} from './sets';

  // ctx: what the figures are worked out with (for the figures under the card on a narrow screen) and the subjob's
  // warning, shown under the set's title
  let {view, ctx = null}: {view: CardView; ctx?: CtxBar | null} = $props();
  const title = $derived(view.title);
  // the Lua tab's Copy: the set as its file writes it, to paste or give to someone (the page shows its quoted names
  // with non-breaking spaces so a line never breaks inside one: plain spaces again in the copy)
  let copied = $state('');
  const luaText = () => [view.lua.head, ...view.lua.lines.map(l => `    ${l.slot} = ${l.value},`), ...(view.lua.note ? [`    -- ${view.lua.note}`] : []), view.lua.tail]
    .join('\n').replace(/\u00a0/g, ' ');
  function copyLua() {
    const text = luaText(), done = () => { copied = view.lua.head; };
    const old = () => { const box = document.createElement('textarea'); box.value = text; document.body.appendChild(box); box.select(); document.execCommand('copy'); box.remove(); done(); };
    if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(text).then(done, old); else old();
  }
</script>

{#snippet lua()}<div class="setlua" aria-label={view.lua.head}><code class="lh">{view.lua.head}</code>{#each view.lua.lines as l (l.slot)}<code class="ll {l.tried ? 'tried' : ''}" title={l.full}><span class="lk">{l.slot}</span> = <span class="lv">{l.value}</span>,</code>{/each}{#if view.lua.note}<code class="ln">-- {view.lua.note}</code>{/if}<code class="lh">{view.lua.tail}</code></div>{/snippet}
{#snippet ver(b: VerButton)}<button aria-pressed={b.pressed} data-card={view.ci} data-variant={b.i} title={b.title}>{b.label}</button>{/snippet}
{#snippet slot(x: SlotView)}<button class={x.cls} data-card={x.ci} data-slot={x.slot} aria-label={x.aria}>{#if x.reset}<span class="unslot" role="button" tabindex="0" data-unslot={x.slot} data-card={x.ci} title={x.reset.title}>↺</span>{/if}{#if x.lock}<span class="lk" title={x.lock.title}><svg viewBox="0 0 12 12" width="9" height="9" aria-hidden="true"><path d="M3.5 5V3.6a2.5 2.5 0 0 1 5 0V5" fill="none" stroke="currentColor" stroke-width="1.5"/><rect x="2" y="5" width="8" height="6" rx="1.2" fill="currentColor"/></svg></span>{/if}{#if x.empty}<span class="elbl">{x.label}</span>{:else}{@html x.iconHtml}{#if x.aug}<span class="mk">◆</span>{/if}{#if x.rank !== null}<span class="rk">R{x.rank}</span>{/if}{/if}</button>{/snippet}

{#snippet setPage()}
  {#if view.chips}
    {#if view.chips.objs.length}<p class="cvsec">{view.chips.objsHead}</p>{#each view.chips.objs as c, i (i)}<div class="cvln obj" title={c.of ? c.label + ' : ' + c.value + ' (' + c.of + ')' : undefined}><i></i><b>{c.value}</b><span>{c.label}</span>{#if c.of}<small>{c.of}</small>{/if}</div>{/each}{/if}
    {#if view.chips.floors.length}<p class="cvsec" title={view.chips.floorsTip}>{view.chips.floorsHead}</p>{#each view.chips.floors as c, i (i)}<div class="cvln {c.ok ? 'ok' : 'ko'}" title={c.tip}><i>{c.ok ? '✓' : '✗'}</i><b>{c.value}</b><span>{c.label}</span><small>{c.of}</small></div>{/each}{/if}
  {/if}
  {@html view.wantsHtml}
  {#if view.notes.fam}<p class="famnote {view.notes.fam.none ? 'none' : ''}">{@html view.notes.fam.textHtml}</p>{/if}
  {#if view.notes.base}<p class="famnote">{view.notes.base}</p>{/if}
{/snippet}
{#snippet weapPage()}{#if view.ctl && view.ctl.k === 'picks'}<div class="setctl"><div class="wpicks">{#each view.ctl.menus as m (m.menu.mode)}<div class="wpick"><span class="wslbl" title={m.tip}><StateName name={m.menu.name} /></span><div class="wsval"><WeaponMenu menu={m.menu} title={m.tip} /></div></div>{/each}{#each view.ctl.results as r, i (i)}<div class="wpick"><span class="wslbl">{r.label}</span><div class="wsval"><span class="wauto"><b>{r.name}</b>{' '}<small class="muted" title={r.noteTitle}>{r.note}</small>{#if r.unforce}{' '}<button class="linkbtn" data-unforce={r.unforce}>{r.backLabel}</button>{/if}</span></div></div>{/each}</div></div>{/if}{/snippet}
{#snippet legendPage()}<div class="legend mini lgline">{#each view.legend.items as it, i (i)}<span class={it.off ? 'off' : ''} title={it.tip}>{@html it.markHtml}{it.label}</span>{/each}</div><p class="eqhint">{@html view.legend.hintHtml}</p>{/snippet}

<article class="detail cv2" class:simple={view.simple}><div class="boxh panehead"><h3>{view.pane}</h3></div>
  <header class="cvhead">
    <div class="cvtop"><div class="cvname"><TitleBox view={title} />{#if title.prev || title.del}<span class="setacts cvacts">{#if title.prev}<button class="btn ghost" data-tryprev title={title.prev.title}>{title.prev.label}</button>{/if}{#if title.del}<button class="btn ghost delset" data-setdel disabled={title.del.off} title={title.del.title}>{@html title.del.labelHtml}</button>{/if}</span>{/if}</div>{#if view.versions.k === 'row'}<div class="setvers cvvers"><div class="verseg" role="group" aria-label={view.versions.label}>{#each view.versions.buttons as b, i (i)}{@render ver(b)}{/each}</div></div>{/if}</div>
    <div class="cvwhen" title={title.factsTip || title.when || undefined}>{#if title.when}<span class="setwhen">{title.when}</span>{/if}{#if title.facts.length}<span class="wsfacts">{#each title.facts as f, i (i)}<span>{f}</span>{/each}</span>{/if}<code class="path wspath" title={title.pathTip}>{title.path}</code></div>
    {#if view.versions.k === 'grid'}<div class="setvers grid cvgrid"><span class="kicker">{view.versions.label}</span><div class="vergrid" role="group" style="--n:{view.versions.cols.length}"><span></span>{#each view.versions.cols as c (c)}<span class="vh">{c}</span>{/each}{#each view.versions.rows as r, i (i)}<span class="vr">{r.label}</span>{#each r.cells as b, j (j)}{#if b}{@render ver(b)}{:else}<i class="vnone">—</i>{/if}{/each}{/each}</div></div>{/if}
    {#if ctx && ctx.warn}<p class="kwarn subwarn"><span>{ctx.warn.text}</span> <button class="btn" data-subfix={ctx.warn.sub}>{ctx.warn.fix}</button></p>{/if}
    {#if view.ctl && view.ctl.k === 'ws'}<div class="setctl cvws"><WsHead view={view.ctl.view} /></div>{/if}
    {#if view.trial && view.trial.k !== 'idle'}<div class="trybar"><TrialRow row={view.trial.row} /></div>{/if}
  </header>
  <div class="cvbody">
    <div class="cvgear"><div class="slots">{#each view.slots as x (x.slot)}{@render slot(x)}{/each}</div>{#if title.opt}<button class="btn cvopt" data-optview title={title.opt.title}>{@html title.opt.labelHtml.replace(/\s*→\s*$/, '')}</button>{/if}<button class="btn eqbtn cveq" data-equipset disabled={!view.equip.on} title={view.equip.why}>{view.equip.label}</button>
    </div>
    <section class="cvinfo"><div class="cvtabs" role="tablist">{#each view.tabs as x (x.key)}<button role="tab" data-cardtab={x.key} aria-selected={x.key === view.tab}>{x.label}</button>{/each}{#if view.tab === 'lua'}<button class="btn cvcopy" onclick={copyLua} title={t('cvCopyTip')}>{copied === view.lua.head ? t('copied') : t('cvCopy')}</button>{/if}</div>
      <div class="cvpage cv-{view.tab}">{#if view.tab === 'weap'}{@render weapPage()}{:else if view.tab === 'lua'}{@render lua()}{:else if view.tab === 'legend'}{@render legendPage()}{:else}{@render setPage()}{/if}</div>
      <footer class="cvfoot">{#each view.footHtml as f, i (i)}<span>{@html f}</span>{/each}</footer></section>
  </div>
  <div class="globals-inline"><Figures view={view.figures} {ctx} /></div></article>
