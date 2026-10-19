<!--
  GearSwap Atelier · the body of a bags' small window (bagdlg.ts): the moogles' places, the Porter Moogle run, the
  bags plan's moves before they are sent.

  @file    atelier/src/screens/dialogs/BagDialog.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {BagDialogView} from './bagdlg';

  let {view}: {view: BagDialogView} = $props();
</script>

{#if view.kind === 'places'}<p>{view.why}</p><table class="pltable"><thead><tr><th>{view.zoneCol}</th>{#each view.kinds as k (k)}<th>{k}</th>{/each}</tr></thead><tbody>{#each view.rows as r (r.z)}<tr class={r.here ? 'here' : ''}><th>{r.z + (r.here ? ' ' : '')}{#if r.here}<em>{view.you}</em>{/if}</th>{#each r.cells as c, i (i)}<td class={c.yes ? 'yes' : ''}>{#if c.yes}{c.pos ? '✔ ' : '✔'}{#if c.pos}<small>{c.pos}</small>{/if}{:else}<i>–</i>{/if}</td>{/each}</tr>{/each}</tbody></table><h4>{view.gives}</h4><ul class="plgives">{#each view.givesRows as [n, d] (n)}<li><b>{n}</b>{d}</li>{/each}</ul><p class="muted small">{view.src}</p>{:else if view.kind === 'porter'}<p>{view.why}</p><ol class="plsteps">{#each view.steps as s, i (i)}<li>{s}</li>{/each}</ol><p class="bpnote warn">{view.naked}</p><p class="muted small">{view.cmd}</p>{:else}<p>{view.why}</p><ul class="bpsafe">{#each view.safe as s, i (i)}<li>{s}</li>{/each}</ul>{#if view.groups.length}<h4>{view.count}</h4>{#each view.groups as g (g.k)}<details class="bpgo"><summary><b>{g.k}</b><i>{g.n}</i></summary><p>{g.names}</p></details>{/each}{:else}<p class="muted">{view.none}</p>{/if}{#if view.noRoom}<p class="bpnote warn">{view.noRoom}</p>{/if}{/if}
