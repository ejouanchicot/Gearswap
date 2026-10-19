<!--
  GearSwap Atelier · the button of the profile in use and its picker (profiles.ts picker): the search, the situations
  as a filter, the favourites, this job's, the others; what to do when the profile was changed, a new one, the
  favourites as quick buttons (the full form only). The clicks and the names typed are profiles.js's.

  @file    atelier/src/screens/profiles/Picker.svelte
  @author  ejouanchicot
-->
<script lang="ts">
  import type {Picker} from './profiles';

  let {view}: {view: Picker} = $props();
</script>

<span class="prpickwrap"><button class="prpickbtn {view.btn.set ? 'set' : ''} {view.btn.mod ? 'mod' : ''}" data-profopen={view.btn.which} aria-expanded={view.btn.open} title={view.btn.title}><span>{view.btn.label}</span>{#if view.btn.modText}<em>{view.btn.modText}</em>{/if}<i>▾</i></button>{#if view.panel}{@const p = view.panel}<div class="prpanel" role="dialog"><div class="prtools"><input id="profq" class="prq" type="search" placeholder={p.qPh} value={p.q} autocomplete="off" spellcheck="false"><div class="seg prtiers" role="group">{#each p.tiers as x (x.value)}<button data-proftier={x.value} aria-pressed={x.pressed}>{x.label}</button>{/each}</div></div><div class="prlist">{#each p.sections as sec, i (i)}<div class="prsec" hidden={sec.hidden}><h5>{sec.label}<span>{sec.count}</span></h5>{#each sec.rows as r (r.name)}{#if r.editing}<div class="prrow2 edit"><input class="listname prname" data-profname="rename:{r.name}" value={r.name} placeholder={r.namePh} maxlength="40" autocomplete="off" spellcheck="false"></div>{:else}<div class="prrow2 {r.on ? 'on' : ''}" data-q={r.q} data-tier={r.tier} hidden={r.hidden}><button class="ract prstar" data-proffav={r.name} aria-pressed={r.fav} title={r.favTitle}>{r.fav ? '★' : '☆'}</button><button class="prgo" data-profload={r.name} title={r.loadTitle}><b>{r.name}</b><small>{r.sub}</small><i>{r.sum}</i></button><span class="practs"><button class="ract" data-profedit="rename:{r.name}" title={r.renameTitle}>✎</button><button class="ract" data-profdel={r.name} title={r.deleteTitle}>×</button></span></div>{/if}{/each}</div>{/each}<p class="muted small prnomatch" hidden={p.noMatch.hidden}>{p.noMatch.text}</p></div><div class="prfoot muted small">{p.count}</div></div>{/if}</span>{#if view.update}<button class="btn prupd" data-profupdate={view.update.name} title={view.update.title}>{view.update.text}</button>{/if}{#if view.add}{#if view.add.editing}<input class="listname prname" data-profname="new" placeholder={view.add.ph} maxlength="40" autocomplete="off" spellcheck="false">{:else}<button class="btn {view.add.ghost ? 'ghost' : ''} prnew" data-profedit="new" title={view.add.title}>{view.add.text}</button>{/if}{/if}{#if view.favs.length}<span class="prfavs">{#each view.favs as f (f.name)}<button class="chip prfav {f.on ? 'on' : ''}" data-profload={f.name} title={f.title}>★ {f.name}</button>{/each}</span>{/if}{#if view.none}<span class="muted small prnone">{view.none}</span>{/if}
