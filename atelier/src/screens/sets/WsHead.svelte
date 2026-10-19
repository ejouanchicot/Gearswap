<!--
  GearSwap Atelier · the head of a weaponskill set (wshead.ts): the weapon line and the TP line, each with its ⓘ.

  @file    atelier/src/screens/sets/WsHead.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {selSync} from '../../components/selsync';
  import type {WsHeadView, WsLine, WsOption} from './wshead';

  let {view}: {view: WsHeadView} = $props();
  const pick = (o: WsOption[]) => (o.find(x => x.selected) || {value: undefined}).value;
</script>

{#snippet lbl(l: WsLine)}<span class="wslbl">{l.label + (l.tip ? ' ' : '')}{#if l.tip}<button type="button" class="helpbtn" data-help={l.help} aria-expanded={l.open} aria-label="?" title={l.helpTip}>ⓘ</button>{/if}</span>{/snippet}
{#snippet help(l: WsLine)}{#if l.open}<p class="wshelp">{l.tip}</p>{/if}{/snippet}
{#snippet opts(list: WsOption[])}{#each list as o (o.disabled ? "!" + o.label : o.value)}<option value={o.disabled ? o.label : o.value} selected={o.selected} disabled={o.disabled}>{o.label}</option>{/each}{/snippet}

{#if view.tp}{@const tp = view.tp}<div class="wshead">{#if view.weapon}{@const w = view.weapon}{#if w.k === 'menus'}{#each w.lines as m, i (i)}<div class="wsline"><span class="wslbl">{m.label}</span><div class="wsval">{@html m.selHtml}</div></div>{/each}{:else}<div class="wsline">{@render lbl(w.line)}<div class="wsval"><select class="heldsel buffsel {w.held.set ? 'set' : ''}" data-heldws={w.ws} title={w.held.title} use:selSync={pick(w.held.options)}>{@render opts(w.held.options)}</select><select class="heldsubsel buffsel {w.sub.set ? 'set' : ''}" data-heldws={w.ws} aria-label="Sub" title={w.sub.title} use:selSync={pick(w.sub.options)}>{@render opts(w.sub.options)}</select></div></div>{@render help(w.line)}{/if}{/if}<div class="wsline">{@render lbl(tp.line)}<div class="wsval">{#each tp.chips as c (c.v)}<button data-wstp={c.v} aria-pressed={c.pressed} title={c.title}>{@html c.label}</button>{/each}<input class="tpin" type="number" min="0" max="3000" step="10" value={tp.input.value} placeholder={tp.input.ph} aria-label="TP" title={tp.input.title}>{#if tp.res}<span class="tpres">{'→ '}<b>{tp.res.total}</b>{' TP' + (tp.res.over ? ' ' : '')}{#if tp.res.over}<span class="tpover">{@html tp.res.over}</span>{/if}</span>{/if}{#if tp.fallback}<span class="muted small">{@html tp.fallback}</span>{/if}<span class="tpbtot">{'TP Bonus '}<b>{'+' + tp.tb.total}</b>{#if tp.tb.bits}{' '}<span class="muted small">{'(' + tp.tb.bits + ')'}</span>{/if}</span></div></div>{@render help(tp.line)}{#if tp.old}<p class="kwarn">{@html tp.old}</p>{/if}</div>{/if}
