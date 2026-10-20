<!--
  GearSwap Atelier · the hover card's content (tips.svelte.ts), drawn inside #tip (App.svelte): an objective, or a piece's card.

  @file    atelier/src/screens/sets/Tip.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import {tipState} from './tips.svelte';

  const v = $derived(tipState.view);
</script>

{#if v}{#if v.k === 'obj'}<b class="objtipn">{v.name}</b><p class="objtipd">{v.desc}</p>{:else}{@const c = v.card}{#if v.max}<p class="tiphint max">{v.max}</p>{/if}{#if c.k === 'none'}<div class="th">{@html c.iconHtml}<div><b>{c.label}</b><small>{c.none}</small></div></div>{:else}<div class="th">{@html c.iconHtml}<div><b>{c.name}</b><small>{c.label + c.weapon}{#if c.rank}{' · '}<span class="rk">{c.rank.text}</span>{/if}{c.where ? ' · ' + c.where : ''}</small></div>{@html c.badgesHtml}</div>{#if c.known}{#if c.attrs.length}<div class="attrs">{#each c.attrs as a, i (i)}<span>{a.label}{#if a.aug}<i class="a">{a.aug}</i>{/if}<b>{a.value}</b></span>{/each}</div>{/if}<div class="rows">{#each c.rows as r, i (i)}<div class="r" title={r.title || null}><span>{r.label}</span><b>{#if r.aug}<i class="a">{r.aug}</i>{/if}{r.value}</b></div>{/each}</div>{#if c.free.length}<div class="k">{c.effects}</div><ul>{#each c.free as f, i (i)}<li>{f}</li>{/each}</ul>{/if}{#if c.cond.length}<div class="k">{c.condTitle}</div><ul>{#each c.cond as f, i (i)}<li>{f}</li>{/each}</ul>{/if}{:else}<p class="muted">{c.noDesc}</p>{/if}{/if}{#if v.hint}<p class="tiphint">{v.hint}</p>{/if}{/if}{/if}
