<!--
  GearSwap Atelier · the hover card's content (tips.svelte.ts), drawn inside #tip (App.svelte): an objective, or a
  piece's card as the game's item window (the player's choice B): its title band (the icon in its cell, the name, its
  slot, rank and bag, the Aug / Rare / Ex badges), the figures it is first read by, its attributes on a line, its other
  stats in small columns by role (the augment's part a small tag beside the total), its effects and conditions on a
  line each, the Shift hint at its foot. Nothing in it scrolls: it is never pointed
  at (card.css).

  @file    atelier/src/screens/sets/Tip.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {tipState} from './tips.svelte';

  const v = $derived(tipState.view);
</script>

{#if v}{#if v.k === 'obj'}<b class="objtipn">{v.name}</b><p class="objtipd">{v.desc}</p>{:else}{@const c = v.card}{#if v.max}<p class="tiphint max">{v.max}</p>{/if}{#if c.k === 'none'}<div class="th">{@html c.iconHtml}<div class="thn"><b>{c.label}</b><small>{c.none}</small></div></div>{:else}<div class="th">{@html c.iconHtml}<div class="thn"><b>{c.name}</b><small><span class="thslot">{c.label}</span>{#if c.rank}<span class="rk">{c.rank.text}</span>{/if}{#if c.where}<span>{c.where}</span>{/if}</small></div>{@html c.badgesHtml}</div>{#if c.hero.length}<div class="thero">{#each c.hero as h (h.label)}<span><small>{h.label}</small>{#if h.value}<b>{h.value}</b>{/if}{#if h.aug}<i class="a" class:only={!h.value}>{h.aug}</i>{/if}</span>{/each}</div>{/if}{#if c.known}{#if c.attrs.length}<div class="attrs">{#each c.attrs as a, i (i)}<span><em>{a.label}</em>{#if a.value}<b>{a.value}</b>{/if}{#if a.aug}<i class="a" class:only={!a.value}>{a.aug}</i>{/if}</span>{/each}</div>{/if}{#if c.roles.length}<div class="tcols">{#each c.roles as g (g.key)}<section class="tcol tr-{g.key}"><h5>{g.label}</h5>{#each g.rows as r, i (i)}<div class="r" title={r.title || null}><span>{r.label}</span><b>{r.value}{#if r.aug}<sup class="a">{r.aug}</sup>{/if}</b></div>{/each}</section>{/each}</div>{/if}{#if c.free.length}<p class="tfx"><i>{c.effects}</i> {c.free.join(' · ')}</p>{/if}{#if c.cond.length}<p class="tfx" title={c.condTitle}><i>{c.condLabel}</i> {c.cond.join(' · ')}</p>{/if}{:else}<p class="muted">{c.noDesc}</p>{/if}{/if}{#if v.hint}<p class="tiphint">{v.hint}</p>{/if}{/if}{/if}
