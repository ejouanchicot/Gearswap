<!--
  GearSwap Atelier · "Optimize every version" once searched (optall.ts), in the search window's dress: its own frame,
  drawn again in place while the versions are written.

  @file    atelier/src/screens/dialogs/OptAll.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {OptAllView} from './optall';

  let {view}: {view: OptAllView} = $props();
</script>

<div class="scrim" data-close></div><div class="dialog optrun finished oadlg" role="dialog"><header><div class="orhead"><div><div class="kicker">{view.kick}</div><h3>{view.base}</h3></div><div class="orclock"><span>{view.secs}</span><small>{view.runs}</small></div></div><div class="orchips">{#each view.chips as c, i (i)}<span class="orchip">{c}</span>{/each}</div></header><div class="body oabody"><div class="orhero"><div><div class="orlbl">{view.label}</div><div class="orbig">{view.big}</div><div class="orgain">{view.sum}</div></div>{@html view.mogWinHtml}</div><div class="oascroll"><table class="cmptbl oatbl"><thead><tr>{#each view.headHtml as h, i (i)}<th>{@html h}</th>{/each}</tr></thead><tbody>{#each view.rows as r, i (i)}{#if r.k === 'wait'}<tr class={r.cls}><th>{r.label}</th><td colspan="4">{r.text}</td></tr>{:else if r.k === 'note'}<tr class={r.cls}><th>{r.label}</th><td colspan="4" class={r.tdCls}>{r.text}</td></tr>{:else}<tr class={r.cls}><th>{#if r.tick}<button class="chip" data-oasel={r.tick.path} aria-pressed={r.tick.on}>{r.tick.on ? '✓' : '·'}</button>{' ' + r.label}{:else}{r.label}{/if}</th><td>{r.best}</td><td>{@html r.vsHtml}</td><td>{r.changed}</td><td class="muted">{r.state}</td></tr>{/if}{/each}</tbody></table><p class="muted small">{view.why}</p>{#if view.noLive}<p class="kwarn">{view.noLive}</p>{/if}</div></div><footer><button class="btn ghost" data-close>{@html view.close}</button><span class="sp"></span>{#if view.save}<button class="btn" data-oago>{view.save}</button>{/if}</footer></div>
