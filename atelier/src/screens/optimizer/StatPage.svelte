<!--
  GearSwap Atelier · the stats optimizer's two columns (statpage.ts): what is searched (side 'what') and the result
  (side 'result').

  @file    atelier/src/screens/optimizer/StatPage.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import TrialRow from '../sets/TrialRow.svelte';
  import OptBlocks from './OptBlocks.svelte';
  import {selSync} from '../../components/selsync';
  import type {StatWhatView, StatResultView} from './statpage';

  let {what = null, result = null}: {what?: StatWhatView | null; result?: StatResultView | null} = $props();
</script>

{#if what}{@const w = what}<OptBlocks limits={w.floors} />{@html w.floorsAfterHtml}<h3 class="ophd">{@html w.titleHtml}</h3>{#if w.help}<p class="wshelp">{w.help}</p>{/if}<div class="opobjs" role="radiogroup">{#each w.groups as g, i (i)}<div class="opgrp"><span class="opgrph">{g.label}</span>{#each g.objs as o (o.k)}<button class="opobj {o.on ? 'on' : ''}" role="radio" aria-checked={o.on} data-statobj={o.k} data-objtip={o.desc}><b>{o.name}</b><span>{o.desc}</span></button>{/each}</div>{/each}</div>{#if w.toggle}<button class="linkbtn opallbtn" data-statobjall>{w.toggle}</button>{/if}<div class="opparams"><span class="opf">{w.then.label}</span>{#each w.then.selects as sel (sel.i)}<select class="buffsel" data-statthen={sel.i} use:selSync={sel.value}><option value={sel.none.value} selected={sel.none.selected}>{sel.none.label}</option>{#each sel.groups as g (g.label)}<optgroup label={g.label}>{#each g.options as o (o.value)}<option value={o.value} selected={o.selected}>{o.label}</option>{/each}</optgroup>{/each}</select>{/each}</div>{#if w.own}<div class="opparams"><label class="opf opwrap" title={w.own.tip}><input type="checkbox" data-statkeep checked={w.own.checked}>{' ' + w.own.label}</label></div>{/if}{#each w.notes as n, i (i)}<p class="muted small">{n}</p>{/each}{#each w.boxes as b (b.key)}<div class="opparams"><label class="opf opwrap"><input type="checkbox" data-enhbox={b.key} checked={b.checked}>{' ' + b.label}</label></div>{/each}{#if w.enf}<p class="small"><b>{w.enf.kind}</b>{' ' + w.enf.spells}</p><p class="muted small">{w.enf.note}</p>{#if w.enf.sab}<div class="opparams"><label class="opf opwrap"><input type="checkbox" data-enfsab checked={w.enf.sab.checked}>{' ' + w.enf.sab.label}</label></div>{/if}{/if}<OptBlocks search={w.search} />{#if w.weaponsNote}<p class="muted small">{w.weaponsNote}</p>{/if}{/if}{#if result}{@const r = result}<h3 class="ophd">{@html r.titleHtml}</h3><div class="opbig"><div><span class="muted small">{@html r.labelHtml}</span><div class="opval"><b>{r.value}</b>{#if r.delta}<em class={r.delta.up ? 'up' : 'down'}>{r.delta.text}</em>{/if}</div>{#if r.wasHtml}<span class="muted small">{@html r.wasHtml}</span>{/if}{#if r.shield}<span class="muted small">{r.shield}</span>{/if}</div></div><div class="opres"><table class="rdvs optable"><thead><tr><th></th>{#each r.heads as h, i (i)}<th>{@html h}</th>{/each}</tr></thead><tbody>{#each r.rows as row, i (i)}<tr class={row.obj ? 'obj' : ''}><th title={row.tip || undefined}>{row.label}</th>{#each row.cells as c, j (j)}<td class="{c.better ? 'better' : ''} {c.bad ? 'short' : ''}">{c.text}</td>{/each}</tr>{/each}</tbody></table><div class="opside"><OptBlocks changes={r.changes} /></div></div>{#if r.trial}<TrialRow row={r.trial} />{:else}<p class="muted small">{r.noTry}</p>{/if}{/if}
